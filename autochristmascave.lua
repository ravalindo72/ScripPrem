-- ========================================
-- 🎄 CHRISTMAS CAVE AUTO EVENT
-- ========================================
-- SAFE: Client-side only, no server manipulation
-- LOGIC: Auto detect event every 2 hours → Auto teleport → Auto exit after 30 min
-- 🔥 FPS BOOST EXTREME (MAKSIMAL PERFORMA)
-- ========================================

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ========================================
-- 📦 STATE MANAGEMENT
-- ========================================
local AutoEvent = {
    Enabled = false,
    SavedCFrame = nil,
    InEvent = false,
    Connections = {},
    LastCheck = 0
}

local FPSBoost = {
    Enabled = false,
    OriginalFog = nil,
    OriginalShadows = nil,
    OriginalBrightness = nil
}

-- ========================================
-- 📍 CAVE LOCATION
-- ========================================
local CAVE_CFRAME = CFrame.new(
    545.998047, -579.297607, 8903.3457,
    0.0665921867, 0.0738025084, -0.995046973,
    -0.0106721297, 0.997256219, 0.0732521564,
    0.997723222, 0.00574125163, 0.0671970546
)

-- ========================================
-- ⏰ TIME CONSTANTS
-- ========================================
local EVENT_CYCLE = 7200 -- 2 hours in seconds
local EVENT_DURATION = 1800 -- 30 minutes in seconds

-- ========================================
-- 🛠️ UTILITY FUNCTIONS
-- ========================================

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsEventActive()
    local currentTime = os.time()
    local timeInCycle = currentTime % EVENT_CYCLE
    return timeInCycle < EVENT_DURATION
end

local function GetEventTimeInfo()
    local currentTime = os.time()
    local timeInCycle = currentTime % EVENT_CYCLE
    
    if timeInCycle < EVENT_DURATION then
        local timeLeft = EVENT_DURATION - timeInCycle
        return true, timeLeft
    else
        local timeUntilNext = EVENT_CYCLE - timeInCycle
        return false, timeUntilNext
    end
end

-- ========================================
-- 🔥 FPS BOOST FUNCTIONS
-- ========================================

local function EnableFPSBoost()
    if FPSBoost.Enabled then return end
    FPSBoost.Enabled = true
    
    -- Save original settings
    FPSBoost.OriginalFog = Lighting.FogEnd
    FPSBoost.OriginalShadows = Lighting.GlobalShadows
    FPSBoost.OriginalBrightness = Lighting.Brightness
    
    -- 1. LIGHTING (matikan semua efek)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    Lighting.Brightness = 0
    Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or 
           v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") then
            v.Enabled = false
        end
    end
    
    -- 2. TERRAIN (hilangin air & dekorasi)
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        Terrain.Decoration = false
    end
    
    -- 3. WORKSPACE - DESTROY YANG GA PENTING
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            obj:Destroy()
        elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj:Destroy()
        elseif obj:IsA("Explosion") then
            obj:Destroy()
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj:Destroy()
        elseif obj:IsA("Sound") then
            if not obj:FindFirstAncestorOfClass("PlayerGui") then
                obj:Destroy()
            end
        elseif obj:IsA("BasePart") then
            obj.CastShadow = false
            obj.Material = Enum.Material.SmoothPlastic
            
            local name = obj.Name:lower()
            if name:match("leaf") or name:match("grass") or name:match("tree") or 
               name:match("bush") or name:match("plant") or name:match("flower") or
               name:match("decoration") or name:match("detail") then
                obj.Transparency = 1
                obj.CanCollide = false
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = ""
        elseif obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then
            obj:Destroy()
        end
    end
    
    -- 4. GRAPHICS SETTINGS
    local rendering = settings().Rendering
    rendering.QualityLevel = Enum.QualityLevel.Level01
    rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    
    pcall(function()
        rendering.EditQualityLevel = Enum.QualityLevel.Level01
    end)
    
    -- 5. PLAYER CHARACTERS
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CastShadow = false
                    part.Material = Enum.Material.SmoothPlastic
                elseif part:IsA("Accessory") or part:IsA("Hat") then
                    if plr ~= LocalPlayer then
                        part:Destroy()
                    end
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part:Destroy()
                end
            end
        end
    end
    
    -- 6. AUTO-OPTIMIZE NEW PLAYERS
    Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CastShadow = false
                    part.Material = Enum.Material.SmoothPlastic
                elseif part:IsA("Accessory") and plr ~= LocalPlayer then
                    part:Destroy()
                end
            end
        end)
    end)
    
    print("✅ FPS Boost EXTREME Aktif! 🔥")
end

local function DisableFPSBoost()
    if not FPSBoost.Enabled then return end
    FPSBoost.Enabled = false
    
    -- Restore lighting
    Lighting.GlobalShadows = FPSBoost.OriginalShadows
    Lighting.FogEnd = FPSBoost.OriginalFog
    Lighting.Brightness = FPSBoost.OriginalBrightness
    
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            v.Enabled = true
        end
    end
    
    -- Restore terrain
    if Terrain then
        Terrain.WaterWaveSize = 0.15
        Terrain.WaterReflectance = 1
        Terrain.WaterTransparency = 0.3
        Terrain.Decoration = true
    end
    
    -- Restore graphics
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    
    print("❌ FPS Boost Nonaktif")
end

-- ========================================
-- 🚀 CORE EVENT FUNCTIONS
-- ========================================

local function EnterEvent()
    if AutoEvent.InEvent then return end

    local root = GetRootPart()
    if not root then 
        warn("⚠️ [ChristmasCave] No HumanoidRootPart found")
        return 
    end

    AutoEvent.InEvent = true
    print("🎄 [ChristmasCave] Event detected! Entering...")
    
    -- Enable FPS boost
    EnableFPSBoost()
    
    -- Teleport to cave
    task.wait(0.5)
    local char = GetCharacter()
    if char then
        char:PivotTo(CAVE_CFRAME)
        print("✅ [ChristmasCave] Teleported to cave!")
        
        local _, timeLeft = GetEventTimeInfo()
        local minutesLeft = math.floor(timeLeft / 60)
        
        StarterGui:SetCore("SendNotification", {
            Title = "🎄 Christmas Cave",
            Text = string.format("Auto teleported! %d min left", minutesLeft),
            Duration = 3
        })
    end
end

local function ExitEvent()
    if not AutoEvent.InEvent then return end
    
    AutoEvent.InEvent = false
    print("🚪 [ChristmasCave] Event ended, exiting...")
    
    -- Disable FPS boost
    DisableFPSBoost()
    
    if AutoEvent.SavedCFrame then
        local char = GetCharacter()
        if char then
            task.wait(0.5)
            char:PivotTo(AutoEvent.SavedCFrame)
            print("✅ [ChristmasCave] Returned to original position")

            local _, timeUntilNext = GetEventTimeInfo()
            local minutesUntil = math.floor(timeUntilNext / 60)

            StarterGui:SetCore("SendNotification", {
                Title = "🎄 Christmas Cave",
                Text = string.format("Returned! Next event in %d min", minutesUntil),
                Duration = 3
            })
        end
    end
end

-- ========================================
-- 🔄 MONITORING SYSTEM
-- ========================================

local function StartEventMonitor()
    local connection = task.spawn(function()
        while AutoEvent.Enabled do
            local currentTime = tick()

            if currentTime - AutoEvent.LastCheck >= 2 then
                AutoEvent.LastCheck = currentTime
                
                local eventActive = IsEventActive()
                
                if eventActive and not AutoEvent.InEvent then
                    print("🔔 [ChristmasCave] Event started!")
                    EnterEvent()
                elseif not eventActive and AutoEvent.InEvent then
                    print("⏰ [ChristmasCave] Event ended!")
                    task.wait(1)
                    ExitEvent()
                end
            end

            task.wait(0.5)
        end
    end)

    table.insert(AutoEvent.Connections, connection)
    print("🔍 [ChristmasCave] Time-based monitor started")
end

local function StartLocationMonitor()
    local connection = LocalPlayer:GetAttributeChangedSignal("LocationName"):Connect(function()
        if not AutoEvent.Enabled then return end
        
        local location = LocalPlayer:GetAttribute("LocationName")
        
        if AutoEvent.InEvent and location then
            local locStr = tostring(location):lower()
            if not string.find(locStr, "christmas cave") then
                print("⚠️ [ChristmasCave] Left event area, returning home")
                ExitEvent()
            end
        end
    end)

    table.insert(AutoEvent.Connections, connection)
end

local function StartRespawnMonitor()
    local connection = LocalPlayer.CharacterAdded:Connect(function(char)
        if not AutoEvent.Enabled then return end
        
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(1.5)
        
        if IsEventActive() then
            print("♻️ [ChristmasCave] Respawned during event, re-entering")
            AutoEvent.InEvent = false
            EnterEvent()
        end
    end)

    table.insert(AutoEvent.Connections, connection)
end

-- ========================================
-- 🎮 MAIN ENABLE/DISABLE
-- ========================================

local function EnableChristmasCaveAuto()
    if AutoEvent.Enabled then return end
    
    AutoEvent.Enabled = true
    print("🎄 [ChristmasCave] Auto enabled!")
    
    -- Save current position
    local root = GetRootPart()
    if root then
        AutoEvent.SavedCFrame = GetCharacter():GetPivot()
        print("💾 [ChristmasCave] Saved position")
    end

    -- Start all monitors
    StartEventMonitor()
    StartLocationMonitor()
    StartRespawnMonitor()

    -- Check if event is currently active
    local isActive, timeInfo = GetEventTimeInfo()
    if isActive then
        local minutesLeft = math.floor(timeInfo / 60)
        print(string.format("🎄 [ChristmasCave] Event is active! %d min left", minutesLeft))
        StarterGui:SetCore("SendNotification", {
            Title = "🎄 Auto Christmas Cave",
            Text = string.format("Event active! %d min left", minutesLeft),
            Duration = 3
        })
        task.wait(1)
        EnterEvent()
    else
        local minutesUntil = math.floor(timeInfo / 60)
        print(string.format("⏳ [ChristmasCave] Next event in %d min", minutesUntil))
        StarterGui:SetCore("SendNotification", {
            Title = "🎄 Auto Christmas Cave",
            Text = string.format("Next event in %d min", minutesUntil),
            Duration = 3
        })
    end
end

local function DisableChristmasCaveAuto()
    if not AutoEvent.Enabled then return end

    AutoEvent.Enabled = false
    print("🛑 [ChristmasCave] Auto disabled")

    -- Disconnect all connections
    for _, conn in pairs(AutoEvent.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        else
            task.cancel(conn)
        end
    end
    AutoEvent.Connections = {}

    -- Exit event if in it
    if AutoEvent.InEvent then
        ExitEvent()
    end

    AutoEvent.SavedCFrame = nil

    StarterGui:SetCore("SendNotification", {
        Title = "🎄 Auto Christmas Cave",
        Text = "Disabled",
        Duration = 2
    })
end

-- ========================================
-- 📤 RETURN MODULE
-- ========================================

return {
    Enable = EnableChristmasCaveAuto,
    Disable = DisableChristmasCaveAuto
}
