local _, A = ...
local call = A.Call
local defaults = { position = 'below', gap = 4, size = 13, warn = 85, sound = true, screenWarning = false, enabled = true, minimapAngle = 220 }
local plates, db, ready, demoUntil = {}, nil, false, 0
local lastSound, lastLevel = -10, 0
local frame = CreateFrame('Frame')
local banner = CreateFrame('Frame', nil, UIParent)
banner:SetSize(500, 35)
banner:SetPoint('CENTER', UIParent, 'CENTER', 0, 160)
banner.text = banner:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
banner.text:SetAllPoints()
banner:Hide()
local function say(text)
    DEFAULT_CHAT_FRAME:AddMessage('|cff80dfffPetThreat:|r ' .. text)
end
local function hideAll()
    for _, entry in pairs(plates) do entry.smooth = nil; if entry.label then entry.label:Hide() end end
    banner:Hide()
    lastLevel = 0
end
local function read(unit, grouped)
    if call(UnitExists, unit) ~= true or call(UnitIsDeadOrGhost, unit) == true then return nil, 0 end
    if call(UnitCanAttack, 'player', unit) ~= true or call(UnitIsPlayer, unit) == true then return nil, 0 end
    -- Some client/nameplate combinations provide better data through target.
    if unit ~= 'target' and call(UnitIsUnit, unit, 'target') == true then unit = 'target' end
    local pt, ps, percent = A.Threat('player', unit)
    local petTank, petStatus, _, _, petThreat = A.Threat('pet', unit)
    if petStatus == nil then petStatus = call(UnitThreatSituation, 'pet', unit) end
    if petTank == nil and type(petStatus) == 'number' then petTank = petStatus >= 2 end
    -- Target identity is a fallback only when the API has no tank-state answer.
    if petTank == nil then petTank = call(UnitIsUnit, unit .. 'target', 'pet') end
    if pt == nil then pt = call(UnitIsUnit, unit .. 'target', 'player') end
    if ps == nil then ps = call(UnitThreatSituation, 'player', unit) end
    if pt == nil and type(ps) == 'number' then pt = ps >= 2 end
    if not grouped and petTank == nil and pt == nil then return 'Waiting for threat', 0 end
    return A.Classify(pt, ps, percent, petTank, petThreat, db.warn, grouped)
end
local function draw(entry, unit, text, level, percent)
    local displayed = A.SmoothPercent(entry, percent, level, GetTime())
    if displayed then
        text = string.format('%.1f%% %s', math.floor(displayed * 10) / 10, level == 1 and 'EASE OFF' or 'threat')
    end
    if not text then if entry.label then entry.label:Hide() end return end
    local plate = call(C_NamePlate and C_NamePlate.GetNamePlateForUnit, unit)
    if not plate or (plate.IsForbidden and plate:IsForbidden()) then
        if entry.label then entry.label:Hide() end
        return
    end
    -- Only add our own FontString; never recolor or resize Blizzard's frames.
    if not entry.label or entry.plate ~= plate then
        if entry.label then entry.label:Hide() end
        entry.plate = plate
        -- Reuse labels when Blizzard recycles a nameplate frame.
        entry.label = plate.PetThreatLabel or plate:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        plate.PetThreatLabel = entry.label
    end
    local label = entry.label
    local unitFrame = plate.UnitFrame
    local health = unitFrame and (unitFrame.healthBar or unitFrame.HealthBarsContainer and unitFrame.HealthBarsContainer.healthBar)
    local anchor = health or unitFrame or plate
    label:ClearAllPoints()
    if db.position == 'above' then
        label:SetPoint('BOTTOM', anchor, 'TOP', 0, db.gap)
    else
        label:SetPoint('TOP', anchor, 'BOTTOM', 0, -db.gap)
    end
    label:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF', db.size, 'OUTLINE')
    label:SetText(text)
    local restrictedDisplay = false
    if text == 'Waiting for threat' or text == 'Pet tanking - no %' then
        restrictedDisplay = A.DisplayRestrictedPercent(label, unit)
        if not restrictedDisplay then label:SetText(text) end
    end
    if level == 2 then label:SetTextColor(1, 0.2, 0.2)
    elseif level == 1 then label:SetTextColor(1, 0.65, 0.1)
    elseif restrictedDisplay then label:SetTextColor(0.55, 0.8, 1)
    elseif text == 'Waiting for threat' or text == 'Pet tanking - no %' then label:SetTextColor(0.7, 0.7, 0.7)
    else label:SetTextColor(0.4, 1, 0.4) end
    label:Show()
end
local function update()
    if not ready then return end
    A.LatencyPoll()
    local now = GetTime()
    if demoUntil > now then
        banner.text:SetText('PREVIEW: 85% - EASE OFF')
        banner.text:SetTextColor(1, 0.65, 0.1)
        if db.screenWarning then banner:Show() else banner:Hide() end
        for unit, entry in pairs(plates) do pcall(draw, entry, unit, '85% EASE OFF', 1) end
        return
    end
    local grouped = call(IsInGroup) == true or call(IsInRaid) == true
    if not db.enabled or (not grouped and (call(UnitExists, 'pet') ~= true or call(UnitIsDeadOrGhost, 'pet') == true)) then hideAll(); return end
    local highest = 0
    for unit, entry in pairs(plates) do
        local text, level, percent = read(unit, grouped)
        local ok = pcall(draw, entry, unit, text, level, percent)
        if not ok and entry.label then entry.label:Hide() end
        highest = math.max(highest, level)
    end
    -- Still warn about the current target when its nameplate is out of range.
    local _, targetLevel = read('target', grouped)
    highest = math.max(highest, targetLevel)
    if highest > 0 then
        banner.text:SetText(highest == 2 and 'AGGRO ON YOU' or (grouped and 'EASE OFF - you may pull aggro' or 'EASE OFF - your pet may lose aggro'))
        banner.text:SetTextColor(1, highest == 2 and 0.2 or 0.65, 0.1)
        if db.screenWarning then banner:Show() else banner:Hide() end
        if db.sound and highest > lastLevel and now - lastSound >= 3 then
            call(PlaySound, SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959, 'Master')
            lastSound = now
        end
    else banner:Hide() end
    lastLevel = highest
end
local function slash(message)
    local command, value = message:lower():match('^%s*(%S*)%s*(.-)%s*$')
    local n = tonumber(value)
    if command == 'latency' then
        A.LatencyCommand(value, frame, say)
        return
    elseif command == 'debug' then
        say('v0.3.10 | Build: ' .. A.Describe(GetBuildInfo))
        say('Group / raid: ' .. A.Describe(IsInGroup) .. ' / ' .. A.Describe(IsInRaid))
        say('Target player [tanking,status,scaled%,raw%,threat]: ' .. A.Describe(UnitDetailedThreatSituation, 'player', 'target'))
        say('Target pet: ' .. A.Describe(UnitDetailedThreatSituation, 'pet', 'target'))
        say('Status player / pet: ' .. A.Describe(UnitThreatSituation, 'player', 'target') .. ' / ' .. A.Describe(UnitThreatSituation, 'pet', 'target'))
        say('Target attacks pet: ' .. A.Describe(UnitIsUnit, 'targettarget', 'pet'))
        for _, alias in ipairs({'pettarget', 'focus', 'mouseover'}) do
            say(alias .. ' player: ' .. A.Describe(UnitDetailedThreatSituation, 'player', alias))
        end
        for token in pairs(plates) do
            say(token .. ' player: ' .. A.Describe(UnitDetailedThreatSituation, 'player', token))
            say(token .. ' pet: ' .. A.Describe(UnitDetailedThreatSituation, 'pet', token))
        end
        return
    elseif command == 'above' or command == 'below' then db.position = command
    elseif command == 'warn' and n and n >= 50 and n <= 99 then db.warn = math.floor(n)
    elseif command == 'gap' and n and n >= 0 and n <= 60 then db.gap = math.floor(n)
    elseif command == 'size' and n and n >= 8 and n <= 30 then db.size = math.floor(n)
    elseif command == 'screenwarning' and (value == 'on' or value == 'off') then db.screenWarning = value == 'on'
    elseif command == 'sound' and (value == 'on' or value == 'off') then db.sound = value == 'on'
    elseif command == 'on' or command == 'off' then db.enabled = command == 'on'; demoUntil = 0
    elseif command == 'test' then demoUntil = GetTime() + 8
    elseif command == 'reset' then for k, v in pairs(defaults) do db[k] = v end
    else
        say('/petthreat above | below | warn 85 | sound on/off | screenwarning on/off | gap 4 | size 13 | test | on/off | reset')
        say('Current: ' .. db.position .. ', warning ' .. db.warn .. '%, sound ' .. (db.sound and 'on' or 'off'))
        say('/petthreat latency on | off | report: measure hit-to-threat timing')
        return
    end
    update()
    if A.RefreshSettings then A.RefreshSettings() end
    say('Updated. /petthreat for settings.')
end
frame:SetScript('OnEvent', function(_, event, unit, ...)
    if event == 'COMBAT_LOG_EVENT_UNFILTERED' then A.LatencyHit(); return end
    if event == 'UNIT_COMBAT' then A.LatencyUnitCombat(unit, ...); return end
    if event == 'PLAYER_LOGIN' then
        local _, _, _, interface = GetBuildInfo()
        -- Forever uses interface 160xx, even on builds sharing Mainline architecture.
        if (type(interface) == 'number' and interface >= 100000) or
            (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and not (type(interface) == 'number' and interface >= 16000 and interface < 17000)) then
            say('Retail is not supported.'); frame:UnregisterAllEvents(); frame:SetScript('OnUpdate', nil); return
        end
        local _, class = UnitClass('player')
        if class ~= 'HUNTER' then frame:UnregisterAllEvents(); frame:SetScript('OnUpdate', nil); return end
        PetThreatDB = type(PetThreatDB) == 'table' and PetThreatDB or {}
        db = PetThreatDB
        for k, v in pairs(defaults) do if type(db[k]) ~= type(v) then db[k] = v end end
        if db.position ~= 'above' and db.position ~= 'below' then db.position = 'below' end
        db.warn = math.max(50, math.min(99, db.warn))
        db.gap = math.max(0, math.min(60, db.gap))
        db.size = math.max(8, math.min(30, db.size))
        ready = true
        A.db, A.Command = db, slash
        SLASH_PETTHREAT1 = '/petthreat'
        SlashCmdList.PETTHREAT = function(message)
            if message:match('^%s*$') or message:lower() == 'gui' then
                if A.ToggleSettings then A.ToggleSettings() end
            else slash(message) end
        end
        if A.CreateSettings then A.CreateSettings() end
        for _, e in ipairs({'NAME_PLATE_UNIT_ADDED', 'NAME_PLATE_UNIT_REMOVED', 'UNIT_THREAT_LIST_UPDATE', 'UNIT_THREAT_SITUATION_UPDATE', 'UNIT_PET', 'PLAYER_TARGET_CHANGED', 'PLAYER_ENTERING_WORLD', 'GROUP_ROSTER_UPDATE'}) do pcall(frame.RegisterEvent, frame, e) end
        if C_NamePlate and C_NamePlate.GetNamePlates then
            for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
                local token = call(function() return plate.namePlateUnitToken end)
                if type(token) == 'string' then plates[token] = {} end
            end
        end
        say('Ready. Enable enemy nameplates (V). /petthreat for settings.')
    elseif event == 'NAME_PLATE_UNIT_ADDED' then plates[unit] = {}
    elseif event == 'NAME_PLATE_UNIT_REMOVED' then
        if plates[unit] and plates[unit].label then plates[unit].label:Hide() end
        plates[unit] = nil
    elseif event == 'PLAYER_ENTERING_WORLD' or event == 'GROUP_ROSTER_UPDATE' or event == 'UNIT_PET' then hideAll()
    end
    update()
end)
local elapsed = 0
frame:SetScript('OnUpdate', function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.05 then elapsed = 0; update() end
end)
frame:RegisterEvent('PLAYER_LOGIN')
