local addonName, addon = ...

local ICON_TEXTURE  = "Interface\\Icons\\Achievement_General"
local BUTTON_RADIUS = 104
local DEFAULT_ANGLE = 220

-- ------------------------------------------------------------------ button
local button = CreateFrame("Button", "OutgrowCrestsTrackerMinimapBtn", Minimap)
button:SetSize(33, 33)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:SetMovable(true)
button:RegisterForDrag("LeftButton")
button:RegisterForClicks("LeftButtonUp")

local overlay = button:CreateTexture(nil, "OVERLAY")
overlay:SetSize(53, 53)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT")

local bg = button:CreateTexture(nil, "BACKGROUND")
bg:SetSize(20, 20)
bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
bg:SetPoint("TOPLEFT", 7, -5)

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetSize(17, 17)
icon:SetTexture(ICON_TEXTURE)
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
icon:SetPoint("TOPLEFT", 7, -6)

button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- ------------------------------------------------------------------ position
local function UpdatePosition(degrees)
    local angle = math.rad(degrees)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(angle) * BUTTON_RADIUS,
        math.sin(angle) * BUTTON_RADIUS)
end

-- ------------------------------------------------------------------ dragging
-- 12.1.0 added Frame:SetOnUpdateMode, so the drag handler can be installed once
-- and simply switched off instead of assigning and clearing the script.
local supportsUpdateMode = button.SetOnUpdateMode ~= nil and Enum.OnUpdateMode ~= nil

local function OnDragUpdate()
    local mx, my   = Minimap:GetCenter()
    local cx, cy   = GetCursorPosition()
    local scale    = Minimap:GetEffectiveScale()
    local degrees  = math.deg(math.atan2(cy / scale - my, cx / scale - mx)) % 360

    if addon.db and addon.db.minimap then
        addon.db.minimap.degrees = degrees
    end
    UpdatePosition(degrees)
end

local function SetDragging(enabled)
    if supportsUpdateMode then
        button:SetOnUpdateMode(enabled and Enum.OnUpdateMode.RunWhenVisible
                                       or Enum.OnUpdateMode.Disabled)
    else
        button:SetScript("OnUpdate", enabled and OnDragUpdate or nil)
    end
end

if supportsUpdateMode then
    button:SetScript("OnUpdate", OnDragUpdate)
end
SetDragging(false)

-- ------------------------------------------------------------------ events
local function ShowButtonTooltip(owner, anchor)
    GameTooltip:SetOwner(owner, anchor)
    GameTooltip:AddLine("Outgrow Crests Tracker", 1.0, 0.82, 0.0)
    if addon.GetSeason then
        local season = addon:GetSeason()
        GameTooltip:AddLine(season.fullName .. " — " .. season.crest .. "s", 0.7, 0.7, 0.7)
    end
    GameTooltip:AddLine("|cffffffffLeft-click|r to toggle window", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("|cffffffffDrag|r to reposition", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end

button:SetScript("OnClick", function()
    addon:ToggleDisplay()
end)

button:SetScript("OnEnter", function(self)
    ShowButtonTooltip(self, "ANCHOR_LEFT")
end)

button:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

button:SetScript("OnDragStart", function()
    SetDragging(true)
end)

button:SetScript("OnDragStop", function()
    SetDragging(false)
end)

-- ------------------------------------------------------------------ init
button:Hide()

function addon:InitMinimapButton()
    local degrees = (self.db and self.db.minimap and self.db.minimap.degrees) or DEFAULT_ANGLE
    UpdatePosition(degrees)
    button:Show()

    if AddonCompartmentFrame and AddonCompartmentFrame.RegisterAddon then
        AddonCompartmentFrame:RegisterAddon({
            text = "Outgrow Crests Tracker",
            icon = ICON_TEXTURE,
            notCheckable = true,
            registerForAnyClick = true,
            func = function() addon:ToggleDisplay() end,
            funcOnEnter = function(entry) ShowButtonTooltip(entry, "ANCHOR_LEFT") end,
            funcOnLeave = function() GameTooltip:Hide() end,
        })
    end
end
