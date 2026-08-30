local addonName, addon = ...

local ICON_TEXTURE = "Interface\\Icons\\Achievement_General"

local LDB    = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
local DBIcon = LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)

-- ------------------------------------------------------------------ broker
-- The launcher is also what LDB display addons (Titan, ChocolateBar, ElvUI
-- datatexts) pick up, so it carries the pretty label rather than the key.
local dataObject = LDB and LDB:NewDataObject(addonName, {
    type  = "launcher",
    label = "Outgrow Crests Tracker",
    icon  = ICON_TEXTURE,

    OnClick = function(_, mouseButton)
        if mouseButton == "RightButton" then
            addon:CycleSeason()
        else
            addon:ToggleDisplay()
        end
    end,

    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Outgrow Crests Tracker", 1.0, 0.82, 0.0)

        local season = addon.GetSeason and addon:GetSeason()
        if season then
            tooltip:AddLine(season.fullName .. " — " .. season.crest .. "s", 0.7, 0.7, 0.7)
        end

        tooltip:AddLine(" ")
        tooltip:AddLine("|cffffffffLeft-click|r to toggle the window", 0.7, 0.7, 0.7)
        tooltip:AddLine("|cffffffffRight-click|r to switch season", 0.7, 0.7, 0.7)
        tooltip:AddLine("|cffffffffDrag|r to reposition", 0.7, 0.7, 0.7)
    end,
})

-- ------------------------------------------------------------------ init
function addon:InitMinimapButton()
    if not DBIcon or not dataObject then
        return
    end

    if not DBIcon:IsRegistered(addonName) then
        DBIcon:Register(addonName, dataObject, self.db.minimap)
    end
end

function addon:IsMinimapButtonHidden()
    return self.db and self.db.minimap and self.db.minimap.hide or false
end

function addon:SetMinimapButtonHidden(hide)
    if not DBIcon or not DBIcon:IsRegistered(addonName) then
        return
    end

    self.db.minimap.hide = hide and true or false
    if hide then
        DBIcon:Hide(addonName)
    else
        DBIcon:Show(addonName)
    end
end
