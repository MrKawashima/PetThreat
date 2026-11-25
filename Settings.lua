local _, A = ...
local panel, minimap, labels = nil, nil, {}
local previewMode = 2
local function bordered(parent, width, height, x, y)
    local f = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
    f:SetSize(width, height)
    f:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
    f:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8', edgeFile='Interface\\Buttons\\WHITE8X8',
        edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
    f:SetBackdropColor(0.05, 0.075, 0.09, 0.98)
    f:SetBackdropBorderColor(0.18, 0.26, 0.29, 1)
    -- Decorative panels must remain behind controls and labels.
    f:SetFrameLevel(parent:GetFrameLevel())
    return f
end
local function roundIcon(parent, size, x, y)
    local icon = parent:CreateTexture(nil, 'ARTWORK')
    icon:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
    icon:SetSize(size, size)
    icon:SetTexture('Interface\\Icons\\Ability_Hunter_BeastTaming')
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local mask = parent:CreateMaskTexture()
    mask:SetAllPoints(icon)
    mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask', 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
    icon:AddMaskTexture(mask)
    return icon
end
local function fill(parent, x, y, width, height, r, g, b, a)
    local t = parent:CreateTexture(nil, 'BACKGROUND')
    t:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
    t:SetSize(width, height)
    t:SetColorTexture(r, g, b, a or 1)
    return t
end
local function text(parent, content, x, y, font)
    local label = parent:CreateFontString(nil, 'OVERLAY', font or 'GameFontHighlight')
    label:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
    label:SetText(content)
    return label
end
-- Match the dark controls and teal selection used by WhatsNext.
local function button(parent, title, x, y, width, action)
    local b = CreateFrame('Button', nil, parent, 'BackdropTemplate')
    b:SetSize(width, 25)
    b:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
    b:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8', edgeFile='Interface\\Buttons\\WHITE8X8',
        edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
    local caption = b:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    caption:SetPoint('CENTER'); caption:SetWidth(width - 6)
    b.SetText = function(self, value) self.text = value; caption:SetText(value) end
    local function paint(self, hover)
        local selected = self.selected or hover
        self:SetBackdropColor(selected and 0.12 or 0.08, selected and 0.23 or 0.13, selected and 0.25 or 0.16, 1)
        self:SetBackdropBorderColor(selected and 0.38 or 0.23, selected and 0.85 or 0.36, selected and 0.69 or 0.39, 1)
        caption:SetTextColor(selected and 0.70 or 0.87, selected and 1 or 0.92, selected and 0.85 or 0.94)
    end
    b.SetSelected = function(self, value) self.selected = value; paint(self, false) end
    b:SetScript('OnEnter', function(self) paint(self, true) end)
    b:SetScript('OnLeave', function(self) paint(self, false) end)
    b:SetText(title); b:SetSelected(false)
    b:SetScript('OnClick', action)
    return b
end
local function checkbox(parent, title, y, key)
    local b = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
    b:SetSize(26, 26)
    b:SetPoint('TOPLEFT', parent, 'TOPLEFT', 18, y)
    text(parent, title, 48, y - 6)
    b:SetScript('OnClick', function(self)
        if key == 'enabled' then A.Command(self:GetChecked() and 'on' or 'off')
        else A.Command((key == 'screenWarning' and 'screenwarning ' or 'sound ') .. (self:GetChecked() and 'on' or 'off')) end
    end)
    labels[key] = b
end
local function stepper(parent, title, y, key, low, high)
    text(parent, title, 22, y - 6)
    labels[key] = text(parent, '', 341, y - 6)
    button(parent, '-', 301, y, 27, function() A.Command(key .. ' ' .. math.max(low, A.db[key] - 1)) end)
    button(parent, '+', 405, y, 27, function() A.Command(key .. ' ' .. math.min(high, A.db[key] + 1)) end)
end
local function positionMinimap()
    if not minimap then return end
    local angle = math.rad(A.db.minimapAngle)
    local radius = (Minimap:GetWidth() / 2) + 8
    minimap:ClearAllPoints()
    minimap:SetPoint('CENTER', Minimap, 'CENTER', math.cos(angle) * radius, math.sin(angle) * radius)
end
function A.RefreshSettings()
    if not panel then return end
    labels.position:SetText(A.db.position == 'above' and 'Position: Above health bar' or 'Position: Below health bar')
    labels.warn:SetText(A.db.warn .. '%')
    labels.gap:SetText(A.db.gap .. ' px')
    labels.size:SetText(A.db.size)
    labels.enabled:SetChecked(A.db.enabled)
    labels.sound:SetChecked(A.db.sound)
    labels.screenWarning:SetChecked(A.db.screenWarning)
    labels.above:SetSelected(A.db.position == 'above')
    labels.below:SetSelected(A.db.position == 'below')
    local preview = labels.preview
    preview:ClearAllPoints()
    preview:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF', A.db.size, 'OUTLINE')
    preview:SetPoint(A.db.position == 'above' and 'BOTTOM' or 'TOP', labels.bar,
        A.db.position == 'above' and 'TOP' or 'BOTTOM', 0, A.db.position == 'above' and A.db.gap or -A.db.gap)
    if previewMode == 1 then preview:SetText('42.3% threat'); preview:SetTextColor(0.4, 1, 0.4)
    elseif previewMode == 2 then preview:SetText(A.db.warn .. '.0% EASE OFF'); preview:SetTextColor(1, 0.65, 0.1)
    else preview:SetText('AGGRO ON YOU'); preview:SetTextColor(1, 0.2, 0.2) end
    positionMinimap()
end
function A.ToggleSettings()
    if not panel then return end
    A.RefreshSettings()
    panel:SetShown(not panel:IsShown())
end
function A.CreateSettings()
    if panel then return end
    panel = CreateFrame('Frame', 'PetThreatSettings', UIParent, 'BackdropTemplate')
    panel:SetSize(460, 610)
    panel:SetPoint('CENTER')
    panel:SetFrameStrata('DIALOG')
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag('LeftButton')
    panel:SetScript('OnDragStart', function(self) self:StartMoving() end)
    panel:SetScript('OnDragStop', function(self) self:StopMovingOrSizing() end)
    panel:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8', edgeFile='Interface\\Buttons\\WHITE8X8',
        edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
    panel:SetBackdropColor(0.035, 0.055, 0.07, 0.98)
    panel:SetBackdropBorderColor(0.18, 0.26, 0.29, 1)
    fill(panel, 1, -1, 458, 3, 0.38, 0.85, 0.69)
    roundIcon(panel, 38, 25, -24)
    text(panel, 'PetThreat', 76, -25, 'GameFontNormalLarge'):SetTextColor(0.38, 0.85, 0.69)
    text(panel, 'HUNTER & WARLOCK COMPANION', 77, -48, 'GameFontHighlightSmall'):SetTextColor(0.65, 0.75, 0.80)
    button(panel, 'X', 414, -16, 28, function() panel:Hide() end)
    UISpecialFrames[#UISpecialFrames + 1] = 'PetThreatSettings'
    bordered(panel, 420, 160, 20, -78)
    text(panel, 'Nameplate preview', 34, -91, 'GameFontNormal'):SetTextColor(0.38, 0.85, 0.69)
    labels.bar = CreateFrame('Frame', nil, panel)
    labels.bar:SetSize(250, 17); labels.bar:SetPoint('TOPLEFT', panel, 'TOPLEFT', 105, -151)
    labels.bar:SetFrameLevel(panel:GetFrameLevel() + 1)
    bordered(labels.bar, 260, 27, -5, 5)
    local health = labels.bar:CreateTexture(nil, 'ARTWORK')
    health:SetPoint('TOPLEFT'); health:SetSize(180, 17)
    health:SetTexture('Interface\\TargetingFrame\\UI-StatusBar')
    health:SetVertexColor(0.72, 0.13, 0.09)
    labels.preview = panel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    button(panel, 'Cycle preview', 165, -202, 130, function() previewMode = previewMode % 3 + 1; A.RefreshSettings() end)
    labels.position = text(panel, '', 26, -253, 'GameFontNormal')
    labels.position:SetTextColor(0.65, 0.80, 0.85)
    labels.above = button(panel, 'Above', 24, -276, 200, function() A.Command('above') end)
    labels.below = button(panel, 'Below', 236, -276, 200, function() A.Command('below') end)
    bordered(panel, 420, 124, 20, -314)
    stepper(panel, 'Warn before aggro', -328, 'warn', 50, 99)
    stepper(panel, 'Text size', -365, 'size', 8, 30)
    stepper(panel, 'Distance from bar', -402, 'gap', 0, 60)
    checkbox(panel, 'Enable pet threat', -449, 'enabled')
    checkbox(panel, 'Play warning sound', -478, 'sound')
    checkbox(panel, 'Show center-screen warning', -507, 'screenWarning')
    button(panel, 'Test display', 24, -546, 200, function() panel:Hide(); A.Command('test') end)
    button(panel, 'Reset settings', 236, -546, 200, function() A.Command('reset') end)
    text(panel, 'Blue = display only  |  Grey = no percentage available', 26, -585, 'GameFontHighlightSmall')
    panel:Hide()

    minimap = CreateFrame('Button', 'PetThreatMinimapButton', Minimap)
    minimap:SetSize(31, 31)
    minimap:SetFrameStrata('MEDIUM')
    minimap:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    -- A clipped portrait inside Blizzard's circular minimap tracking rim.
    minimap.icon = roundIcon(minimap, 20, 7, -5)
    local rim = minimap:CreateTexture(nil, 'OVERLAY')
    rim:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
    rim:SetSize(54, 54)
    rim:SetPoint('TOPLEFT', minimap, 'TOPLEFT', 0, 0)
    minimap:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight', 'ADD')
    minimap:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    minimap:RegisterForDrag('LeftButton')
    minimap:SetScript('OnClick', function(_, mouse)
        if mouse == 'RightButton' then A.Command('sound ' .. (A.db.sound and 'off' or 'on'))
        else A.ToggleSettings() end
    end)
    minimap:SetScript('OnDragStart', function(self)
        GameTooltip:Hide()
        self:SetScript('OnUpdate', function()
            local mx, my = Minimap:GetCenter()
            if not mx then return end
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            A.db.minimapAngle = math.deg(math.atan2(cy / scale - my, cx / scale - mx))
            positionMinimap()
        end)
    end)
    minimap:SetScript('OnDragStop', function(self) self:SetScript('OnUpdate', nil) end)
    minimap:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:AddLine('PetThreat', 0.5, 0.85, 1)
        GameTooltip:AddLine('Left-click: Settings', 1, 1, 1)
        GameTooltip:AddLine('Right-click: Toggle sound', 1, 1, 1)
        GameTooltip:AddLine('Drag: Move around minimap', 1, 1, 1)
        GameTooltip:Show()
    end)
    minimap:SetScript('OnLeave', function() GameTooltip:Hide() end)
    A.RefreshSettings()
end
