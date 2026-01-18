-- ========================================
-- 🌟 AUTO FAVORITE MODULE - ULTRA STABLE V2
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
    print("🔔 Fish obtained event triggered!")
    
    if not extraData or not extraData.InventoryItem then 
        print("❌ No extraData or InventoryItem")
        return 
    end
    
    local inventoryItem = extraData.InventoryItem
    if inventoryItem.Favorited then 
        print("⭐ Already favorited, skipping")
        return 
    end

    local uuid = inventoryItem.UUID
    if not uuid then 
        print("❌ No UUID found")
        return 
    end

    local shouldFavorite = false

    -- CHECK NAME (Priority #1)
    if not shouldFavorite and AUTO_FAVORITE_NAME_ENABLED then
        local fishData = getFishData(itemId)
        local fishName = fishData and fishData.Data and fishData.Data.Name

        if fishName and AUTO_FAVORITE_FISH_NAMES[fishName] then
            shouldFavorite = true
            print("🎯 Name match:", fishName)
        end
    end

    -- CHECK TIER (Priority #2)
    if not shouldFavorite and AUTO_FAVORITE_ENABLED then
        local fishData = getFishData(itemId)
        if fishData and fishData.Data and AUTO_FAVORITE_TIERS[fishData.Data.Tier] then
            shouldFavorite = true
            print("🏆 Tier match:", fishData.Data.Tier)
        end
    end

    -- CHECK VARIANT (Priority #3)
    if not shouldFavorite and AUTO_FAVORITE_VARIANT_ENABLED then
        local variantId = metadata and metadata.VariantId
        if variantId and variantId ~= "None" and AUTO_FAVORITE_VARIANTS[variantId] then
            shouldFavorite = true
            print("✨ Variant match:", variantId)
        end
    end

    -- EXECUTE FAVORITE
    if shouldFavorite then
        task.delay(0.75, function()
            pcall(function()
                FavoriteEvent:FireServer(uuid)
            end)
            print("⭐ Auto Favorited:", itemId, "UUID:", uuid)
        end)
    else
        print("⏭️ No match, skipping favorite")
    end
end

-- ===============================
-- MODULE FUNCTIONS
-- ===============================

local function EnableAutoFavorite()
    -- 🔥 FORCE DISCONNECT DULU SEBELUM CONNECT BARU
    for _, conn in pairs(Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    Connections = {}
    
    IsActive = true
    
    -- Connect listener
    local conn = NotificationEvent.OnClientEvent:Connect(OnFishObtained)
    table.insert(Connections, conn)
    
    print("✅ Auto Favorite Module AKTIF! (Event Listener Connected)")
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
-- FORCE RESTART HELPER
-- ===============================

local function ForceRestart()
    -- Cek apakah ada setting yang aktif
    local hasActiveSettings = AUTO_FAVORITE_ENABLED or 
                              AUTO_FAVORITE_VARIANT_ENABLED or 
                              AUTO_FAVORITE_NAME_ENABLED
    
    if hasActiveSettings then
        -- 🔥 FORCE RESTART MODULE
        DisableAutoFavorite()
        task.wait(0.1)
        EnableAutoFavorite()
        print("🔄 Module restarted dengan settings baru!")
    else
        -- Kalo gak ada settings, matiin aja
        DisableAutoFavorite()
        print("⚠️ Semua settings kosong, module dimatikan")
    end
end

-- ===============================
-- SETTER FUNCTIONS (UPDATED!)
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
    else
        print("⚠️ Tier settings cleared")
    end
    
    -- 🔥 FORCE RESTART!
    ForceRestart()
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
    else
        print("⚠️ Variant settings cleared")
    end
    
    -- 🔥 FORCE RESTART!
    ForceRestart()
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
    else
        print("⚠️ Fish name settings cleared")
    end
    
    -- 🔥 FORCE RESTART!
    ForceRestart()
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
