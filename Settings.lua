local _, A = ...
local panel, minimap, labels = nil, nil, {}
local previewMode = 2
local function bordered(parent, width, height, x, y)
    local f = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
    f:SetSize(width, height)
    f:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
    f:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile='Interface\\Tooltips\\UI-Tooltip-Border', tile=true, tileSize=16, edgeSize=16,
        insets={left=4,right=4,top=4,bottom=4}})
    f:SetBackdropColor(0.10, 0.14, 0.10, 0.95)
    f:SetBackdropBorderColor(0.48, 0.42, 0.26)
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
local function button(parent, title, x, y, width, action)
    local b = CreateFrame('Button', nil, parent, 'UIPanelButtonTemplate')
    b:SetSize(width, 25)
    b:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
    b:SetText(title)
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
        else A.Command('sound ' .. (self:GetChecked() and 'on' or 'off')) end
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
    labels.above:SetText(A.db.position == 'above' and '|cff9dff70Above  [selected]|r' or 'Above')
    labels.below:SetText(A.db.position == 'below' and '|cff9dff70Below  [selected]|r' or 'Below')
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
    panel:SetSize(460, 580)
    panel:SetPoint('CENTER')
    panel:SetFrameStrata('DIALOG')
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag('LeftButton')
    panel:SetScript('OnDragStart', function(self) self:StartMoving() end)
    panel:SetScript('OnDragStop', function(self) self:StopMovingOrSizing() end)
    panel:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border', tile=true,tileSize=32,edgeSize=32,
        insets={left=11,right=12,top=12,bottom=11}})
    panel:SetBackdropColor(0.65, 0.72, 0.62, 1)
    roundIcon(panel, 38, 25, -24)
    text(panel, 'PetThreat', 76, -25, 'GameFontNormalLarge')
    text(panel, 'HUNTER COMPANION', 77, -48, 'GameFontHighlightSmall'):SetTextColor(0.65, 0.78, 0.55)
    local close = CreateFrame('Button', nil, panel, 'UIPanelCloseButton')
    close:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -6, -6)
    close:SetScript('OnClick', function() panel:Hide() end)
    UISpecialFrames[#UISpecialFrames + 1] = 'PetThreatSettings'
    bordered(panel, 420, 160, 20, -78)
    text(panel, 'Nameplate preview', 34, -91, 'GameFontNormal')
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
    labels.above = button(panel, 'Above', 24, -276, 200, function() A.Command('above') end)
    labels.below = button(panel, 'Below', 236, -276, 200, function() A.Command('below') end)
    bordered(panel, 420, 124, 20, -314)
    stepper(panel, 'Warn before aggro', -328, 'warn', 50, 99)
    stepper(panel, 'Text size', -365, 'size', 8, 30)
    stepper(panel, 'Distance from bar', -402, 'gap', 0, 60)
    checkbox(panel, 'Enable pet threat', -449, 'enabled')
    checkbox(panel, 'Play warning sound', -478, 'sound')
    button(panel, 'Test display', 24, -516, 200, function() panel:Hide(); A.Command('test') end)
    button(panel, 'Reset settings', 236, -516, 200, function() A.Command('reset') end)
    text(panel, 'Blue = display only  |  Grey = no percentage available', 26, -555, 'GameFontHighlightSmall')
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
