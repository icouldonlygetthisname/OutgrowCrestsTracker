local addonName, addon = ...

addon.Config = {}
local Config = addon.Config

-- Enum.ItemRedundancySlot as of 12.1.0. Mirrored so slot lists can be written
-- by name and still resolve if a constant is ever renamed or added.
local SLOT = Enum.ItemRedundancySlot or {
    Head = 0, Neck = 1, Shoulder = 2, Chest = 3, Waist = 4, Legs = 5,
    Feet = 6, Wrist = 7, Hand = 8, Finger = 9, Trinket = 10, Cloak = 11,
    Twohand = 12, MainhandWeapon = 13, OnehandWeapon = 14,
    OnehandWeaponSecond = 15, Offhand = 16,
}
Config.SLOT = SLOT

local SLOT_LABELS = {
    Head                = "Head",
    Neck                = "Neck",
    Shoulder            = "Shoulder",
    Chest               = "Chest",
    Waist               = "Waist",
    Legs                = "Legs",
    Feet                = "Feet",
    Wrist               = "Wrist",
    Hand                = "Hands",
    Finger              = "Finger",
    Trinket             = "Trinket",
    Cloak               = "Back",
    Twohand             = "Two-Hand",
    MainhandWeapon      = "Main Hand",
    OnehandWeapon       = "One-Hand",
    OnehandWeaponSecond = "One-Hand (2)",
    Offhand             = "Off Hand",
}

Config.slotNames = {}
for key, index in pairs(SLOT) do
    Config.slotNames[index] = SLOT_LABELS[key] or key
end

-- Resolve a list of Enum.ItemRedundancySlot key names to indices, dropping any
-- the running client does not define.
local function ResolveSlots(keys)
    local indices = {}
    for _, key in ipairs(keys) do
        local index = SLOT[key]
        if index then
            indices[#indices + 1] = index
        end
    end
    return indices
end

-- Armor slots always count toward every achievement.
Config.armorSlots = ResolveSlots({
    "Head", "Neck", "Shoulder", "Chest", "Waist", "Legs",
    "Feet", "Wrist", "Hand", "Finger", "Trinket", "Cloak",
})

-- Weapon groups — only the active configuration counts. A group is "active"
-- when every slot in it reports a watermark.
Config.weaponGroups = {
    { label = "Two-Hand",   slots = ResolveSlots({ "Twohand" }) },
    { label = "Weapon + Off Hand", slots = ResolveSlots({ "MainhandWeapon", "Offhand" }) },
    { label = "Dual Wield", slots = ResolveSlots({ "OnehandWeapon", "OnehandWeaponSecond" }) },
}

-- Tier colors are shared across seasons.
local TIER_COLORS = {
    Adventurer = { 0.12, 1.00, 0.00 },
    Veteran    = { 0.00, 0.44, 0.87 },
    Champion   = { 0.63, 0.13, 0.94 },
    Hero       = { 1.00, 0.50, 0.00 },
    Myth       = { 1.00, 0.00, 0.00 },
}

-- Crest discount achievement series, newest season last.
--
-- Each season supersedes the previous one: C_ItemUpgrade high watermarks reset
-- with the season, so only the active season's thresholds can be evaluated
-- against live data. Past seasons are kept so completed runs stay inspectable.
Config.seasons = {
    {
        key          = "dawn",
        name         = "Season 1",
        fullName     = "Midnight Season 1",
        crest        = "Dawncrest",
        minInterface = 120000,
        achievements = {
            { id = 61809, name = "Adventurer of the Dawn", tier = "Adventurer", ilvl = 237 },
            { id = 42767, name = "Veteran of the Dawn",    tier = "Veteran",    ilvl = 250 },
            { id = 42768, name = "Champion of the Dawn",   tier = "Champion",   ilvl = 263 },
            { id = 42769, name = "Hero of the Dawn",       tier = "Hero",       ilvl = 276 },
            { id = 42770, name = "Myth of the Dawn",       tier = "Myth",       ilvl = 285 },
        },
    },
    {
        key          = "mist",
        name         = "Season 2",
        fullName     = "Midnight Season 2",
        crest        = "Mistcrest",
        minInterface = 120100,
        achievements = {
            { id = 62410, name = "Adventurer of the Mist", tier = "Adventurer", ilvl = 282 },
            { id = 62411, name = "Veteran of the Mist",    tier = "Veteran",    ilvl = 295 },
            { id = 62412, name = "Champion of the Mist",   tier = "Champion",   ilvl = 308 },
            { id = 62414, name = "Hero of the Mist",       tier = "Hero",       ilvl = 321 },
            { id = 62416, name = "Myth of the Mist",       tier = "Myth",       ilvl = 331 },
        },
    },
}

Config.maxAchievements = 0
for _, season in ipairs(Config.seasons) do
    for _, achiev in ipairs(season.achievements) do
        achiev.color = TIER_COLORS[achiev.tier] or { 1, 1, 1 }
    end
    if #season.achievements > Config.maxAchievements then
        Config.maxAchievements = #season.achievements
    end
end

-- Newest season the running client actually ships.
function Config:GetSeasonIndexForClient()
    local _, _, _, interfaceVersion = GetBuildInfo()
    local index = 1
    for i, season in ipairs(self.seasons) do
        if interfaceVersion and interfaceVersion >= season.minInterface then
            index = i
        end
    end
    return index
end

function Config:IsValidSeasonIndex(index)
    return type(index) == "number" and self.seasons[index] ~= nil
end
