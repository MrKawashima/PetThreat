local _, A = ...
local active
local damage = {RANGE_DAMAGE=true, SPELL_DAMAGE=true, SWING_DAMAGE=true}
local function sample()
    return A.Call(function()
        local _, _, p = UnitDetailedThreatSituation('player', 'target')
        if issecretvalue and issecretvalue(p) then return nil, 'protected' end
        if type(p) == 'number' and p == p and p >= 0 and p < math.huge then return p, 'readable' end
        return nil, 'missing'
    end)
end
local function finish()
    local s = active
    if not s then return end
    s.frame:UnregisterEvent(s.event)
    active = nil
    if s.pending then s.unmatched = s.unmatched + 1 end
    local result = string.format('Latency [' .. s.reference .. ']: %d samples; %d hits; %d overlapping; %d unmatched; %d unreadable polls; %d unreadable events.',
        #s.samples, s.hits, s.overlap, s.unmatched, s.unreadable, s.hiddenEvents)
    if #s.samples > 0 then
        table.sort(s.samples)
        local sum = 0
        for _, v in ipairs(s.samples) do sum = sum + v end
        result = result .. string.format(' Event -> changed threat: min %.0f / avg %.0f / max %.0f ms.',
            s.samples[1], sum / #s.samples, s.samples[#s.samples])
    else result = result .. ' No valid timing samples (this does not mean zero delay).' end
    if s.event == 'UNIT_COMBAT' then result = result .. ' Target damage from ANY attacker; not specifically your shot.' end
    A.db.latencyReport = result
    s.say(result)
    s.say('Observed timing, not server latency. Pet/other threat changes can affect it. Polling: 50 ms plus frame time. /petthreat latency report')
end
function A.LatencyPoll()
    local s = active
    if not s then return end
    local now = GetTime()
    if now >= s.stop then finish(); return end
    local guid = A.Call(UnitGUID, 'target')
    local p, state = sample()
    if type(guid) ~= 'string' or guid ~= s.guid then
        if s.pending then s.unmatched = s.unmatched + 1 end
        s.guid, s.last, s.pending = guid, p, nil
        return
    end
    if state ~= 'readable' then
        s.unreadable = s.unreadable + 1
        if s.pending then s.unmatched = s.unmatched + 1 end
        s.last, s.pending = nil, nil
        if not s.notified then s.say('Latency: threat is ' .. (state or 'unavailable') .. '; these values cannot be timed.'); s.notified = true end
        return
    end
    if s.pending then
        local elapsed = now - s.pending.time
        if elapsed > 2 then
            s.unmatched = s.unmatched + 1; s.pending = nil
        elseif p ~= s.pending.before then
            if not s.pending.ambiguous then
                local ms = elapsed * 1000
                s.samples[#s.samples + 1] = ms
                if #s.samples <= 8 then s.say(string.format('%s -> changed threat: %.0f ms (%.1f%% -> %.1f%%)', s.reference, ms, s.pending.before, p)) end
            end
            s.pending = nil
        end
    end
    s.last = p
end
local function recordHit(guid)
    local s = active
    if not s then return end
    if type(guid) ~= 'string' then s.hiddenEvents = s.hiddenEvents + 1; return end
    s.hits = s.hits + 1
    if guid ~= s.guid or s.last == nil then
        s.unmatched = s.unmatched + 1; A.LatencyPoll(); return
    end
    if s.pending then
        s.pending.ambiguous = true; s.overlap = s.overlap + 1
    else s.pending = {time=GetTime(), before=s.last} end
    A.LatencyPoll()
end
function A.LatencyHit()
    local s = active
    if not s or s.event ~= 'COMBAT_LOG_EVENT_UNFILTERED' then return end
    local _, event, _, source, _, _, _, dest = A.Call(CombatLogGetCurrentEventInfo)
    if type(event) ~= 'string' or type(source) ~= 'string' or type(dest) ~= 'string' then
        s.hiddenEvents = s.hiddenEvents + 1; return
    end
    if not damage[event] or source ~= A.Call(UnitGUID, 'player') then return end
    local guid = A.Call(UnitGUID, 'target')
    if type(guid) ~= 'string' or dest ~= guid then return end
    recordHit(guid)
end
function A.LatencyUnitCombat(unit, action)
    local s = active
    if not s or s.event ~= 'UNIT_COMBAT' then return end
    -- Sanitize event metadata; the possibly protected damage amount is never read.
    unit, action = A.Call(function() return unit, action end)
    if type(unit) ~= 'string' or type(action) ~= 'string' then
        s.hiddenEvents = s.hiddenEvents + 1; return
    end
    if unit ~= 'target' or action ~= 'WOUND' then return end
    recordHit(A.Call(UnitGUID, 'target'))
end
function A.LatencyCommand(value, frame, say)
    if value == 'report' then say(A.db.latencyReport or 'No saved latency report. /petthreat latency on'); return end
    if value == 'off' then finish(); return end
    if value ~= 'on' and value ~= '' then say('/petthreat latency on | off | report'); return end
    if active then say('Latency measurement is already running (30 seconds).'); return end
    local event, reason = 'COMBAT_LOG_EVENT_UNFILTERED'
    if type(CombatLogGetCurrentEventInfo) ~= 'function' then reason = 'combat log API missing'
    elseif A.Call(C_CombatLog and C_CombatLog.IsCombatLogRestricted) == true then reason = 'combat log restricted' end
    if not reason then
        local ok, registered = pcall(frame.RegisterEvent, frame, event)
        if not ok or registered == false then reason = 'combat log event registration rejected' end
    end
    if reason then
        event = 'UNIT_COMBAT'
        say('Latency: ' .. reason .. '. Trying target damage events instead.')
        local ok, registered = pcall(frame.RegisterEvent, frame, event)
        if not ok or registered == false then
            say('Latency unavailable: target damage event registration rejected too.'); return
        end
    end
    local p = sample()
    active = {frame=frame, say=say, stop=GetTime()+30, guid=A.Call(UnitGUID, 'target'), last=p,
        event=event, reference=reason and 'Target damage (any attacker)' or 'Player hit log',
        samples={}, hits=0, overlap=0, unmatched=0, unreadable=0, hiddenEvents=0}
    say('Measuring for 30 seconds. Keep one target; fire single shots at least 3 seconds apart. Timing starts at a damage event, not the shot animation.')
    if reason then say('Fallback includes damage from your pet and other attackers. Results are not a measurement of your shots specifically.') end
end
