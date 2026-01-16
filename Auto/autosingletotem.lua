-- ========================================
-- 🪬 AUTO TOTEM MODULE - ULTRA STABLE
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========================================
-- SERVICES & REMOTES
-- ========================================
local Net = ReplicatedStorage.Packages["_Index"]["sleitnick_net@0.2.0"].net
local SpawnTotemRemote = Net["RE/SpawnTotem"]
local RE_EquipToolFromHotbar = Net["RE/EquipToolFromHotbar"]

local Replion = require(ReplicatedStorage.Packages.Replion)
local clientData = Replion.Client:WaitReplion("Data")

-- ========================================
-- TOTEM DATA
-- ========================================
local TOTEM_DATA = {
    ["Luck Totem"] = {Id = 1, Duration = 3601}, 
    ["Mutation Totem"] = {Id = 2, Duration = 3601}, 
    ["Shiny Totem"] = {Id = 3, Duration = 3601}
}

-- ========================================
-- STATE VARIABLES
-- ========================================
local AUTO_1_TOTEM_ACTIVE = false
local AUTO_1_TOTEM_THREAD = nil
local nextSpawnTime1 = 0
local selectedTotemName = "Luck Totem"

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

local function GetTotemUUIDsByName(totemName)
    local inv = clientData:Get("Inventory")
    local list = {}

    if not inv or not inv.Totems then return list end

    local targetId = TOTEM_DATA[totemName] and TOTEM_DATA[totemName].Id
    if not targetId then return list end

    for _, item in pairs(inv.Totems) do
        if item and item.UUID and tonumber(item.Id) == targetId then
            local count = item.Count or 1
            if count >= 1 then
                table.insert(list, item.UUID)
            end
        end
    end

    return list
end

-- ========================================
-- SPAWN FUNCTIONS
-- ========================================

local function SpawnSingleTotem()
    local totemUUIDs = GetTotemUUIDsByName(selectedTotemName)
    if #totemUUIDs < 1 then return false end

    local uuid = totemUUIDs[1]
    
    -- Simpan status auto fish sebelumnya
    local wasAutoFishEnabled = _G.AutoFishEnabled or false
    local wasAutoFishEnabledV2 = _G.AutoFishEnabledV2 or false
    local wasAutoFishEnabledV3 = _G.AutoFishEnabledV3 or false
    
    -- Matikan semua auto fish
    _G.AutoFishEnabled = false
    _G.AutoFishEnabledV2 = false
    _G.AutoFishEnabledV3 = false
    
    task.wait(0.5)
    
    -- Spawn totem
    pcall(function() 
        SpawnTotemRemote:FireServer(uuid) 
    end)
    
    task.wait(2)
    
    -- Spam equip rod sampai benar-benar ke-equip
    for i = 1, 10 do
        pcall(function()
            RE_EquipToolFromHotbar:FireServer(1)
        end)
        task.wait(0.15)
    end
    
    task.wait(0.5)
    
    -- Nyalakan kembali auto fish yang sebelumnya aktif
    if wasAutoFishEnabled then
        _G.AutoFishEnabled = true
    end
    if wasAutoFishEnabledV2 then
        _G.AutoFishEnabledV2 = true
    end
    if wasAutoFishEnabledV3 then
        _G.AutoFishEnabledV3 = true
    end
    
    return true
end

-- ========================================
-- AUTO LOOP FUNCTIONS
-- ========================================

local function Run1TotemLoop()
    if AUTO_1_TOTEM_THREAD then 
        task.cancel(AUTO_1_TOTEM_THREAD) 
    end
    
    AUTO_1_TOTEM_THREAD = task.spawn(function()
        while AUTO_1_TOTEM_ACTIVE do
            local currentTime = os.time()
            
            if currentTime >= nextSpawnTime1 then
                local success = SpawnSingleTotem()
                
                if success then
                    local duration = TOTEM_DATA[selectedTotemName].Duration
                    nextSpawnTime1 = os.time() + duration
                else
                    nextSpawnTime1 = os.time() + 30
                end
            end
            
            task.wait(1)
        end
    end)
end

-- ========================================
-- MODULE EXPORTS
-- ========================================

local function Enable1Totem()
    if AUTO_1_TOTEM_ACTIVE then return end
    AUTO_1_TOTEM_ACTIVE = true
    nextSpawnTime1 = 0
    Run1TotemLoop()
    print("✅ Auto 1 Totem AKTIF!")
end

local function Disable1Totem()
    if not AUTO_1_TOTEM_ACTIVE then return end
    AUTO_1_TOTEM_ACTIVE = false
    
    if AUTO_1_TOTEM_THREAD then 
        task.cancel(AUTO_1_TOTEM_THREAD) 
    end
    
    print("❌ Auto 1 Totem MATI")
end

local function SetTotemType(totemName)
    selectedTotemName = totemName
    print("🪬 Selected Totem:", totemName)
end

-- ========================================
-- RETURN MODULE
-- ========================================

return {
    Enable1Totem = Enable1Totem,
    Disable1Totem = Disable1Totem,
    SetTotemType = SetTotemType,
    GetTotemNames = function() 
        return {"Luck Totem", "Mutation Totem", "Shiny Totem"} 
    end
}
