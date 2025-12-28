-- ========================================
-- 💀 FPS BOOST ULTRA GACOR (NO MERCY)
-- ========================================

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

local IsActive = false
local Connections = {}

local function EnableFPSBoost()
    if IsActive then return end
    IsActive = true
    
    -- ===================================
    -- 1. LIGHTING ULTIMATE DESTROY
    -- ===================================
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    Lighting.Brightness = 0
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    -- DESTROY semua efek lighting
    for _, v in pairs(Lighting:GetChildren()) do
        if not v:IsA("Sky") then
            v:Destroy()
        end
    end

    -- ===================================
    -- 2. TERRAIN TOTAL DISABLE
    -- ===================================
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        Terrain.Decoration = false
        
        -- EXTREME: Matikan terrain rendering
        pcall(function()
            sethiddenproperty(Terrain, "Decoration", false)
        end)
    end

    -- ===================================
    -- 3. WORKSPACE MASS DESTRUCTION
    -- ===================================
    local function OptimizeObject(obj)
        local objType = obj.ClassName
        
        -- DESTROY HEAVY OBJECTS
        if objType == "ParticleEmitter" or objType == "Beam" or objType == "Trail" or
           objType == "Fire" or objType == "Smoke" or objType == "Sparkles" or
           objType == "Explosion" or objType == "PointLight" or objType == "SpotLight" or
           objType == "SurfaceLight" or objType == "Sky" or objType == "Atmosphere" or
           objType == "Clouds" or objType == "BloomEffect" or objType == "BlurEffect" or
           objType == "ColorCorrectionEffect" or objType == "SunRaysEffect" or
           objType == "DepthOfFieldEffect" then
            obj:Destroy()
            return
        end
        
        -- DESTROY VISUAL STUFF
        if objType == "Decal" or objType == "Texture" or objType == "SurfaceGui" then
            obj:Destroy()
            return
        end
        
        -- SOUNDS
        if objType == "Sound" then
            if not obj:FindFirstAncestorOfClass("PlayerGui") then
                obj.Volume = 0
                obj:Destroy()
            end
            return
        end
        
        -- BASEPART EXTREME OPTIMIZATION
        if obj:IsA("BasePart") then
            obj.CastShadow = false
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            
            -- Matikan collision untuk dekorasi
            local name = obj.Name:lower()
            if name:match("leaf") or name:match("grass") or name:match("tree") or 
               name:match("bush") or name:match("plant") or name:match("flower") or
               name:match("rock") or name:match("stone") or name:match("decoration") or
               name:match("detail") or name:match("fence") or name:match("prop") then
                obj.Transparency = 1
                obj.CanCollide = false
                obj.CanTouch = false
                obj.CanQuery = false
            end
        end
        
        -- MESH OPTIMIZATION
        if objType == "SpecialMesh" then
            obj.TextureId = ""
        elseif objType == "MeshPart" then
            obj.TextureID = ""
        end
    end

    -- PROCESS SEMUA OBJECT (FAST)
    for _, obj in pairs(workspace:GetDescendants()) do
        OptimizeObject(obj)
    end

    -- ===================================
    -- 4. GRAPHICS NUCLEAR OPTION
    -- ===================================
    local rendering = settings().Rendering

    rendering.QualityLevel = Enum.QualityLevel.Level01
    rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    rendering.EagerBulkExecution = false

    pcall(function()
        rendering.EditQualityLevel = Enum.QualityLevel.Level01
        rendering.FrameRateManager = Enum.FramerateManagerMode.Off
    end)

    -- Matikan V-Sync (unlock FPS)
    pcall(function()
        setfpscap(9999)
    end)

    -- ===================================
    -- 5. PLAYER OPTIMIZATION EXTREME
    -- ===================================
    local function OptimizeCharacter(char, isLocalPlayer)
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj:Destroy()
            end
            
            -- DESTROY accessories player lain
            if not isLocalPlayer and (obj:IsA("Accessory") or obj:IsA("Hat")) then
                obj:Destroy()
            end
        end
        
        -- EXTREME: Simplify humanoid
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and not isLocalPlayer then
            for _, desc in pairs(humanoid:GetDescendants()) do
                if desc:IsA("NumberValue") or desc:IsA("StringValue") then
                    desc:Destroy()
                end
            end
        end
    end

    -- Optimize semua player sekarang
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            OptimizeCharacter(plr.Character, plr == Player)
        end
    end

    -- ===================================
    -- 6. AUTO-OPTIMIZE (LIGHTWEIGHT)
    -- ===================================

    -- Player baru
    local conn1 = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            OptimizeCharacter(char, false)
        end)
    end)
    table.insert(Connections, conn1)

    -- Object baru (EFFICIENT)
    local lastCheck = tick()
    local conn2 = workspace.DescendantAdded:Connect(function(obj)
        local now = tick()
        if now - lastCheck < 0.1 then return end
        lastCheck = now
        
        task.spawn(OptimizeObject, obj)
    end)
    table.insert(Connections, conn2)

    -- ===================================
    -- 7. MEMORY CLEANUP (ANTI LAG)
    -- ===================================
    local conn3 = task.spawn(function()
        while IsActive and task.wait(30) do
            -- Cleanup unused instances
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and #obj:GetChildren() == 0 then
                        obj:Destroy()
                    end
                end
            end)
            
            -- Garbage collection hint
            pcall(function()
                game:GetService("ContentProvider"):PreloadAsync({})
            end)
        end
    end)
    table.insert(Connections, conn3)

    -- ===================================
    -- 8. RENDER DISTANCE REDUCTION
    -- ===================================
    pcall(function()
        settings().Rendering.ViewDistanceScale = 0.3
    end)

    -- Camera optimization
    if Player.Character then
        local camera = workspace.CurrentCamera
        camera.FieldOfView = 70
    end

    print("💀 FPS BOOST ULTRA GACOR AKTIF!")
    print("⚡ FPS Target: UNLIMITED")
    print("🔥 Memory Usage: MINIMAL")
end

local function DisableFPSBoost()
    if not IsActive then return end
    IsActive = false
    
    -- Disconnect all connections
    for _, conn in pairs(Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        else
            task.cancel(conn)
        end
    end
    Connections = {}
    
    print("❌ FPS Boost Disabled")
end

return {
    Enable = EnableFPSBoost,
    Disable = DisableFPSBoost
}
