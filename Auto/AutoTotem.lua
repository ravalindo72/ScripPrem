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
local RF_EquipOxygenTank = Net["RF/EquipOxygenTank"]
local RF_UnequipOxygenTank = Net["RF/UnequipOxygenTank"]
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
local AUTO_9_TOTEM_ACTIVE = false
local AUTO_9_TOTEM_THREAD = nil
local AUTO_1_TOTEM_ACTIVE = false
local AUTO_1_TOTEM_THREAD = nil
local stateConnection = nil
local nextSpawnTime = 0
local nextSpawnTime1 = 0
local selectedTotemName = "Luck Totem"
local savedCFrame = nil

-- ========================================
-- REFERENCE POSITIONS (9 SPOTS)
-- ========================================
local REF_CENTER = Vector3.new(93.932, 9.532, 2684.134)
local REF_SPOTS = {
    Vector3.new(45.0468979, 9.51625347, 2730.19067),
    Vector3.new(145.644608, 9.51625347, 2721.90747),
    Vector3.new(84.6406631, 10.2174253, 2636.05786),
    Vector3.new(45.0468979, 110.516253, 2730.19067),
    Vector3.new(145.644608, 110.516253, 2721.90747),
    Vector3.new(84.6406631, 111.217425, 2636.05786),
    Vector3.new(45.0468979, -92.483747, 2730.19067),
    Vector3.new(145.644608, -92.483747, 2721.90747),
    Vector3.new(84.6406631, -93.782575, 2636.05786),
}

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

local function GetFlyPart()
    local char = Players.LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or 
           char:FindFirstChild("Torso") or 
           char:FindFirstChild("UpperTorso")
end

-- ========================================
-- FLY ENGINE V3
-- ========================================

local function MaintainAntiFallState(enable)
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end

    if enable then
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

        if not stateConnection then
            stateConnection = RunService.Heartbeat:Connect(function()
                if hum and AUTO_9_TOTEM_ACTIVE then
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                end
            end)
        end
    else
        if stateConnection then 
            stateConnection:Disconnect()
            stateConnection = nil 
        end
        
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    end
end

local function EnableV3Physics()
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local mainPart = GetFlyPart()
    
    if not mainPart or not hum then return end

    if char:FindFirstChild("Animate") then 
        char.Animate.Disabled = true 
    end
    hum.PlatformStand = true 
    
    MaintainAntiFallState(true)

    local bg = mainPart:FindFirstChild("FlyGuiGyro") or Instance.new("BodyGyro", mainPart)
    bg.Name = "FlyGuiGyro"
    bg.P = 9e4 
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = mainPart.CFrame

    local bv = mainPart:FindFirstChild("FlyGuiVelocity") or Instance.new("BodyVelocity", mainPart)
    bv.Name = "FlyGuiVelocity"
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

    task.spawn(function()
        while AUTO_9_TOTEM_ACTIVE and char do
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end
            end
            task.wait(0.1)
        end
    end)
    
    task.spawn(function()
        while AUTO_9_TOTEM_ACTIVE and hum do
            hum.Health = hum.MaxHealth
            task.wait(1)
        end
    end)
end

local function DisableV3Physics()
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local mainPart = GetFlyPart()

    if mainPart then
        if mainPart:FindFirstChild("FlyGuiGyro") then 
            mainPart.FlyGuiGyro:Destroy() 
        end
        if mainPart:FindFirstChild("FlyGuiVelocity") then 
            mainPart.FlyGuiVelocity:Destroy() 
        end
        
        mainPart.Velocity = Vector3.zero
        mainPart.RotVelocity = Vector3.zero
        mainPart.AssemblyLinearVelocity = Vector3.zero 
        mainPart.AssemblyAngularVelocity = Vector3.zero

        local x, y, z = mainPart.CFrame:ToEulerAnglesYXZ()
        mainPart.CFrame = CFrame.new(mainPart.Position) * CFrame.fromEulerAnglesYXZ(0, y, 0)
        
        local ray = Ray.new(mainPart.Position, Vector3.new(0, -5, 0))
        local hit, pos = workspace:FindPartOnRay(ray, char)
        if hit then
            mainPart.CFrame = mainPart.CFrame + Vector3.new(0, 3, 0)
        end
    end

    if hum then 
        hum.PlatformStand = false 
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    MaintainAntiFallState(false) 
    
    if char and char:FindFirstChild("Animate") then 
        char.Animate.Disabled = false 
    end
    
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.CanCollide = true 
            end
        end
    end
end

local holdConnection = nil

local function HoldPosition(targetCFrame)
    local mainPart = GetFlyPart()
    if not mainPart then return end
    
    if holdConnection then
        holdConnection:Disconnect()
        holdConnection = nil
    end
    
    holdConnection = RunService.Heartbeat:Connect(function()
        if mainPart and mainPart.Parent then
            mainPart.CFrame = targetCFrame
            mainPart.Velocity = Vector3.new(0, 0, 0)
            mainPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function StopHold()
    if holdConnection then
        holdConnection:Disconnect()
        holdConnection = nil
    end
end

local function FlyPhysicsTo(targetPos)
    local mainPart = GetFlyPart()
    if not mainPart then return end
    
    local bv = mainPart:FindFirstChild("FlyGuiVelocity")
    local bg = mainPart:FindFirstChild("FlyGuiGyro")
    
    if not bv or not bg then 
        EnableV3Physics()
        bv = mainPart.FlyGuiVelocity
        bg = mainPart.FlyGuiGyro 
    end

    local SPEED = 80 
    
    while AUTO_9_TOTEM_ACTIVE do
        local currentPos = mainPart.Position
        local diff = targetPos - currentPos
        local dist = diff.Magnitude
        
        bg.CFrame = CFrame.lookAt(currentPos, targetPos)

        if dist < 1.0 then 
            bv.velocity = Vector3.new(0, 0.1, 0)
            break
        else
            bv.velocity = diff.Unit * SPEED
        end
        RunService.Heartbeat:Wait()
    end
end

-- ========================================
-- SPAWN FUNCTIONS
-- ========================================

local function SpawnSingleTotem()
    local totemUUIDs = GetTotemUUIDsByName(selectedTotemName)
    if #totemUUIDs < 1 then return false end

    local uuid = totemUUIDs[1]
    
    pcall(function() 
        SpawnTotemRemote:FireServer(uuid) 
    end)
    
    task.wait(0.5)
    
    for i = 1, 3 do
        pcall(function()
            RE_EquipToolFromHotbar:FireServer(1)
        end)
        task.wait(0.2)
    end
    
    return true
end

local function SpawnTotemCycle()
    local totemUUIDs = GetTotemUUIDsByName(selectedTotemName)
    if #totemUUIDs < 9 then return false end

    local char = Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp then return false end
    
    savedCFrame = hrp.CFrame
    local startPosition = hrp.CFrame
    
    pcall(function() 
        RF_EquipOxygenTank:InvokeServer(105) 
    end)
    task.wait(0.5)
    
    if hum then 
        hum.Health = hum.MaxHealth 
    end

    EnableV3Physics()

    for i, refSpot in ipairs(REF_SPOTS) do
        if not AUTO_9_TOTEM_ACTIVE then break end
        
        local relativePos = refSpot - REF_CENTER
        local targetPos = startPosition.Position + relativePos
        local targetCFrame = CFrame.new(targetPos)
        
        FlyPhysicsTo(targetPos) 
        HoldPosition(targetCFrame)
        task.wait(1.5)

        local uuid = totemUUIDs[i]
        if uuid then
            pcall(function() 
                SpawnTotemRemote:FireServer(uuid) 
            end)
            task.wait(2.5)
        else
            break
        end
        
        StopHold()
        task.wait(0.3)
    end

    if AUTO_9_TOTEM_ACTIVE then
        FlyPhysicsTo(startPosition.Position)
        HoldPosition(startPosition)
        task.wait(1)
    end
    
    StopHold()
    
    pcall(function() 
        RF_UnequipOxygenTank:InvokeServer() 
    end)

    DisableV3Physics()
    
    if hrp and savedCFrame then
        task.wait(0.5)
        hrp.CFrame = savedCFrame
    end
    
    task.wait(0.3)
    
    for i = 1, 3 do
        pcall(function()
            RE_EquipToolFromHotbar:FireServer(1)
        end)
        task.wait(0.2)
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

local function Run9TotemLoop()
    if AUTO_9_TOTEM_THREAD then 
        task.cancel(AUTO_9_TOTEM_THREAD) 
    end
    
    AUTO_9_TOTEM_THREAD = task.spawn(function()
        while AUTO_9_TOTEM_ACTIVE do
            local currentTime = os.time()
            
            if currentTime >= nextSpawnTime then
                local success = SpawnTotemCycle()
                
                if success then
                    local duration = TOTEM_DATA[selectedTotemName].Duration
                    nextSpawnTime = os.time() + duration
                else
                    nextSpawnTime = os.time() + 30
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

local function Enable9Totem()
    if AUTO_9_TOTEM_ACTIVE then return end
    AUTO_9_TOTEM_ACTIVE = true
    nextSpawnTime = 0
    Run9TotemLoop()
    print("✅ Auto 9 Totem AKTIF!")
end

local function Disable9Totem()
    if not AUTO_9_TOTEM_ACTIVE then return end
    AUTO_9_TOTEM_ACTIVE = false
    
    if AUTO_9_TOTEM_THREAD then 
        task.cancel(AUTO_9_TOTEM_THREAD) 
    end
    
    pcall(function() 
        RF_UnequipOxygenTank:InvokeServer() 
    end)
    
    DisableV3Physics()
    StopHold()
    
    print("❌ Auto 9 Totem MATI")
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
    Enable9Totem = Enable9Totem,
    Disable9Totem = Disable9Totem,
    SetTotemType = SetTotemType,
    GetTotemNames = function() 
        return {"Luck Totem", "Mutation Totem", "Shiny Totem"} 
    end
}
