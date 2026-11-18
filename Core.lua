local _, A = ...
local unpack = unpack or table.unpack
local function pack(...) return { n = select('#', ...), ... } end
-- Secret values are discarded before comparison, formatting or table indexing.
function A.Call(fn, ...)
    if type(fn) ~= 'function' then return nil end
    local args = pack(...)
    local ok, result = pcall(function()
        local values = pack(fn(unpack(args, 1, args.n)))
        for i = 1, values.n do
            if issecretvalue and issecretvalue(values[i]) then values[i] = nil end
        end
        return values
    end)
    if ok then return unpack(result, 1, result.n) end
end
-- Blizzard explicitly permits secret arguments to FontString:SetFormattedText.
-- This path only displays the live value; Lua never compares or formats it.
-- Reference: Blizzard_APIDocumentationGenerated/SimpleFontStringAPIDocumentation.lua
function A.DisplayRestrictedPercent(label, unit)
    if type(UnitDetailedThreatSituation) ~= 'function' or type(issecretvalue) ~= 'function' then return false end
    local ok, displayed = pcall(function()
        local _, _, percent = UnitDetailedThreatSituation('player', unit)
        if issecretvalue(percent) then
            label:SetFormattedText('%.1f%% threat', percent)
            return true
        end
        return false
    end)
    return ok and displayed == true
end
function A.Describe(fn, ...)
    if type(fn) ~= 'function' then return 'API missing' end
    local args = pack(...)
    local ok, result = pcall(function()
        local values, out = pack(fn(unpack(args, 1, args.n))), {}
        for i = 1, values.n do
            local v = values[i]
            if issecretvalue and issecretvalue(v) then out[i] = 'HIDDEN'
            elseif v == nil then out[i] = 'nil'
            elseif type(v) == 'boolean' or type(v) == 'number' or type(v) == 'string' then out[i] = tostring(v)
            else out[i] = type(v) end
        end
        return values.n == 0 and 'no data' or table.concat(out, ', ')
    end)
    return ok and result or 'API error'
end
-- Try only live unit aliases whose identity matches this exact enemy.
-- Never cache a target's threat percentage after the target changes.
function A.Threat(actor, unit)
    local tank, status, percent, raw, amount = A.Call(UnitDetailedThreatSituation, actor, unit)
    if type(percent) == 'number' then return tank, status, percent, raw, amount end
    for _, alias in ipairs({'target', 'pettarget', 'focus', 'mouseover'}) do
        if alias ~= unit and A.Call(UnitExists, alias) == true and A.Call(UnitIsUnit, unit, alias) == true then
            local t, s, p, r, a = A.Call(UnitDetailedThreatSituation, actor, alias)
            if type(p) == 'number' then return t, s, p, r, a end
        end
    end
    return tank, status, percent, raw, amount
end
function A.Classify(playerTank, status, percent, petTank, petThreat, threshold)
    if playerTank == true and (petTank == true or (type(petThreat) == 'number' and petThreat > 0)) then
        return 'AGGRO ON YOU', 2
    end
    if petTank ~= true then return nil, 0 end
    if type(percent) == 'number' and percent == percent and percent >= 0 and percent < math.huge then
        local warning = percent >= threshold
        return string.format('%.1f%% %s', math.floor(percent * 10) / 10, warning and 'EASE OFF' or 'threat'), warning and 1 or 0
    end
    if status == 1 then return 'EASE OFF', 1 end
    if status == 0 then return 'Pet tanking - no %', 0 end
    return 'Threat unavailable', 0
end
