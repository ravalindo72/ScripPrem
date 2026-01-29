-- ========================================
-- 🌟 AUTO FAVORITE MODULE - ULTRA STABLE (Instant & Collaborative)
-- ========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IsActive = false
local Connections = {}

-- State
local AUTO_FAVORITE_TIERS = {}
local AUTO_FAVORITE_ENABLED = false
local AUTO_FAVORITE_VARIANTS = {}
local AUTO_FAVORITE_VARIANT_ENABLED = false
local AUTO_FAVORITE_NAME_ENABLED = false
local AUTO_FAVORITE_FISH_NAMES = {}

-- Getters for Self-Healing
local FishNamesGetter = nil
local TiersGetter = nil
local VariantsGetter = nil


-- Tier mapping
local TIER_MAP = {
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythic"] = 6,
    ["SECRET"] = 7
}

-- Services & Events
local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local FavoriteEvent = net["RE/FavoriteItem"]
local NotificationEvent = net["RE/ObtainedNewFishNotification"]
local itemsModule = require(ReplicatedStorage:WaitForChild("Items"))

-- ===============================
-- HELPER FUNCTIONS
-- ===============================

local function getFishData(itemId)
    for _, fish in pairs(itemsModule) do
        if fish.Data and fish.Data.Id == itemId then
            return fish
        end
    end
    return nil
end

local function LoadFishNames()
    local fishList = {}
    local fishLookup = {}
    
    for _, fish in pairs(itemsModule) do
        if fish.Data and fish.Data.Type == "Fish" and fish.Data.Name then
            fishLookup[fish.Data.Name] = true
        end
    end
    
    for name in pairs(fishLookup) do
        table.insert(fishList, name)
    end
    
    table.sort(fishList)
    return fishList, fishLookup
end

-- ===============================
-- MAIN AUTO FAVORITE LOGIC
-- ===============================

local function OnFishObtained(itemId, metadata, extraData)
    if not extraData or not extraData.InventoryItem then return end
    local inventoryItem = extraData.InventoryItem
    if inventoryItem.Favorited then return end

    local uuid = inventoryItem.UUID
    if not uuid then return end

    -- Check if ANY filter is enabled
    if not (AUTO_FAVORITE_NAME_ENABLED or AUTO_FAVORITE_ENABLED or AUTO_FAVORITE_VARIANT_ENABLED) then
        return
    end

    local fishData = getFishData(itemId)
    local fishName = fishData and fishData.Data and fishData.Data.Name
    local fishTier = fishData and fishData.Data and fishData.Data.Tier
    local variantId = metadata and metadata.VariantId or "None"

    -- Logic: COLLABORATIVE FILTERING (AND Logic)
    -- If a filter category is enabled, the item MUST match that filter.
    
    -- 1. Check Name Filter
    if AUTO_FAVORITE_NAME_ENABLED then
        if not fishName or not AUTO_FAVORITE_FISH_NAMES[fishName] then
            return -- Failed Name Check
        end
    end

    -- 2. Check Tier Filter
    if AUTO_FAVORITE_ENABLED then
        if not fishTier or not AUTO_FAVORITE_TIERS[fishTier] then
            return -- Failed Tier Check
        end
    end

    -- 3. Check Variant Filter
    if AUTO_FAVORITE_VARIANT_ENABLED then
        if variantId == "None" or not AUTO_FAVORITE_VARIANTS[variantId] then
            return -- Failed Variant Check
        end
    end

    -- If we survived all checks, execute favorite IMMEDIATELY
    -- REMOVED DELAY FOR INSTANT SPEED
    pcall(function()
        FavoriteEvent:FireServer(uuid)
    end)
    print("⭐ Auto Favorited (Instant):", fishName)
end

-- ===============================
-- MODULE FUNCTIONS
-- ===============================

local function EnableAutoFavorite()
    if IsActive then return end
    IsActive = true
    
    -- Connect listener
    local conn = NotificationEvent.OnClientEvent:Connect(OnFishObtained)
    table.insert(Connections, conn)
    
    print("✅ Auto Favorite Module AKTIF!")
end

local function DisableAutoFavorite()
    if not IsActive then return end
    IsActive = false
    
    -- Disconnect semua
    for _, conn in pairs(Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    Connections = {}
    
    print("❌ Auto Favorite Module MATI")
end

-- ===============================
-- SETTER FUNCTIONS
-- ===============================

local function SetTiers(tierNames)
    AUTO_FAVORITE_TIERS = {}
    AUTO_FAVORITE_ENABLED = false
    
    for _, tierName in ipairs(tierNames) do
        local tier = TIER_MAP[tierName]
        if tier then
            AUTO_FAVORITE_TIERS[tier] = true
            AUTO_FAVORITE_ENABLED = true
        end
    end
    
    if AUTO_FAVORITE_ENABLED then
        print("✅ Auto Favorite Tiers:", table.concat(tierNames, ", "))
    end
end

local function SetVariants(variantNames)
    AUTO_FAVORITE_VARIANTS = {}
    AUTO_FAVORITE_VARIANT_ENABLED = false
    
    for _, variantName in ipairs(variantNames) do
        AUTO_FAVORITE_VARIANTS[variantName] = true
        AUTO_FAVORITE_VARIANT_ENABLED = true
    end
    
    if AUTO_FAVORITE_VARIANT_ENABLED then
        print("✨ Auto Favorite Variants:", table.concat(variantNames, ", "))
    end
end

local function SetFishNames(fishNames)
    AUTO_FAVORITE_FISH_NAMES = {}
    AUTO_FAVORITE_NAME_ENABLED = false
    
    for _, name in ipairs(fishNames) do
        AUTO_FAVORITE_FISH_NAMES[name] = true
        AUTO_FAVORITE_NAME_ENABLED = true
    end
    
    if AUTO_FAVORITE_NAME_ENABLED then
        print("🐟 Auto Favorite Names:", table.concat(fishNames, ", "))
    end
end



-- ===============================
-- RETURN MODULE
-- ===============================

return {
    Enable = EnableAutoFavorite,
    Disable = DisableAutoFavorite,
    SetTiers = SetTiers,
    SetVariants = SetVariants,
    SetFishNames = SetFishNames,

    GetFishNames = LoadFishNames,
    IsActive = function() return IsActive end
}
