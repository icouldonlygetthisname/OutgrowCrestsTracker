local addonName, addon = ...

local eventFrame = CreateFrame("Frame")

-- Events that can move a high watermark or complete an achievement.
local REFRESH_EVENTS = {
    "PLAYER_EQUIPMENT_CHANGED",
    "PLAYER_AVG_ITEM_LEVEL_UPDATE",
    "ITEM_UPGRADE_MASTER_UPDATE",
    "ACHIEVEMENT_EARNED",
}

local slotCache = nil

-- C_ItemUpgrade.GetHighWatermarkForSlot carries MayReturnNothing, and 12.x can
-- hand back secret values instead of numbers, so reject anything not directly
-- comparable rather than erroring on the first comparison.
local function ReadWatermark(index)
    if not C_ItemUpgrade or not C_ItemUpgrade.GetHighWatermarkForSlot then
        return nil
    end

    local ok, charWM, acctWM = pcall(C_ItemUpgrade.GetHighWatermarkForSlot, index)
    if not ok or type(charWM) ~= "number" or charWM <= 0 then
        return nil
    end

    return charWM, (type(acctWM) == "number") and acctWM or 0
end

local function BuildSlot(index, charWM, acctWM)
    return {
        slotIndex     = index,
        name          = addon.Config.slotNames[index] or ("Slot " .. index),
        charWatermark = charWM,
        acctWatermark = acctWM,
    }
end

-- Query all equipment slot watermarks, keeping only the active weapon group.
function addon:GetSlotData()
    if slotCache then
        return slotCache
    end

    local Config = self.Config
    local slots  = {}

    for _, index in ipairs(Config.armorSlots) do
        local charWM, acctWM = ReadWatermark(index)
        if charWM then
            slots[#slots + 1] = BuildSlot(index, charWM, acctWM)
        end
    end

    -- Among weapon groups where every slot reports a watermark, take the one
    -- with the highest minimum — that is the configuration being played.
    local bestGroup, bestMin = nil, -1
    for _, group in ipairs(Config.weaponGroups) do
        local entries = {}
        local minWM   = math.huge

        for _, index in ipairs(group.slots) do
            local charWM, acctWM = ReadWatermark(index)
            if not charWM then
                entries = nil
                break
            end
            entries[#entries + 1] = BuildSlot(index, charWM, acctWM)
            if charWM < minWM then
                minWM = charWM
            end
        end

        if entries and #entries > 0 and minWM > bestMin then
            bestMin   = minWM
            bestGroup = entries
        end
    end

    if bestGroup then
        for _, entry in ipairs(bestGroup) do
            slots[#slots + 1] = entry
        end
    end

    table.sort(slots, function(a, b) return a.slotIndex < b.slotIndex end)

    -- An empty result usually means the watermarks are not populated yet, so
    -- leave the cache clear and retry on the next query.
    if #slots > 0 then
        slotCache = slots
    end

    return slots
end

function addon:InvalidateSlotData()
    slotCache = nil
end

-- ------------------------------------------------------------------ seasons
function addon:GetSeasonIndex()
    local index = self.db and self.db.seasonIndex
    if self.Config:IsValidSeasonIndex(index) then
        return index
    end
    return self.Config:GetSeasonIndexForClient()
end

function addon:GetSeason()
    return self.Config.seasons[self:GetSeasonIndex()]
end

function addon:SetSeasonIndex(index)
    if not self.Config:IsValidSeasonIndex(index) then
        return false
    end
    if self.db then
        self.db.seasonIndex = index
    end
    self:OnSeasonChanged()
    return true
end

function addon:CycleSeason()
    local seasons = self.Config.seasons
    self:SetSeasonIndex(self:GetSeasonIndex() % #seasons + 1)
end

-- ------------------------------------------------------------------ database
local function InitDB()
    OutgrowCrestsTrackerDB = OutgrowCrestsTrackerDB or {}
    local db = OutgrowCrestsTrackerDB

    db.minimap = db.minimap or { degrees = 220 }
    if not addon.Config:IsValidSeasonIndex(db.seasonIndex) then
        db.seasonIndex = addon.Config:GetSeasonIndexForClient()
    end

    addon.db = db
end

-- ------------------------------------------------------------------ events
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        InitDB()
        addon:InitMinimapButton()
        for _, refreshEvent in ipairs(REFRESH_EVENTS) do
            eventFrame:RegisterEvent(refreshEvent)
        end
        return
    end

    addon:InvalidateSlotData()
    addon:RefreshDisplay()
end)
eventFrame:RegisterEvent("PLAYER_LOGIN")

-- ------------------------------------------------------------------ commands
local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd200Outgrow Crests Tracker:|r " .. msg)
end

local function PrintUsage()
    Print("|cffffffff/crests|r toggle the window")
    Print("|cffffffff/crests season|r cycle the tracked season")
    for i, season in ipairs(addon.Config.seasons) do
        Print(string.format("|cffffffff/crests season %d|r %s (%s)",
            i, season.fullName, season.crest))
    end
end

SLASH_OUTGROWCRESTSTRACKER1 = "/outgrow"
SLASH_OUTGROWCRESTSTRACKER2 = "/crests"
SlashCmdList["OUTGROWCRESTSTRACKER"] = function(input)
    local command, argument = strsplit(" ", strtrim(input or ""):lower())

    if command == "" then
        addon:ToggleDisplay()
    elseif command == "season" then
        local index = tonumber(argument)
        if index then
            if not addon:SetSeasonIndex(index) then
                Print("No such season: " .. argument)
                return
            end
        else
            addon:CycleSeason()
        end
        Print("Now tracking " .. addon:GetSeason().fullName .. ".")
    else
        PrintUsage()
    end
end
