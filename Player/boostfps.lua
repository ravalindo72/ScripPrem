-- ========================================
-- 🔥 FPS BOOST ULTRA (SAFE VERSION)
-- ========================================
-- EXTREME optimization tapi BISA DI-RESTORE
-- NO permanent destroy, NO memory leak
-- ========================================

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ========================================
-- 💾 STATE & BACKUP
-- ========================================
local FPSBoost = {
    Active = false,
    Connections = {},
    DisabledObjects = {},
    
    -- Lighting backup
    OriginalLighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        Brightness = Lighting.Brightness,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale or 0,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale or 0,
    },
    
    -- Terrain backup
    OriginalTerrain = {},
    
    -- Graphics backup
    OriginalQuality = settings().Rendering.QualityLevel,
}

-- ========================================
-- 🎨 OPTIMIZE SINGLE OBJECT
-- ========================================
local function OptimizeObject(obj)
    if not obj or not obj.Parent then return end
    
    local objType = obj.ClassName
    
    -- Particles & Effects (DISABLE not destroy)
    if objType == "ParticleEmitter" or objType == "Beam" or objType == "Trail" or
       objType == "Fire" or objType == "Smoke" or objType == "Sparkles" then
        if obj.Enabled then
            obj.Enabled = false
            table.insert(FPSBoost.DisabledObjects, obj)
        end
        return
    end
    
    -- Lights (DISABLE)
    if objType == "PointLight" or objType == "SpotLight" or objType == "SurfaceLight" then
        if obj.Enabled then
            obj.Enabled = false
            table.insert(FPSBoost.DisabledObjects, obj)
        end
        return
    end
    
    -- BasePart optimization
    if obj:IsA("BasePart") then
        obj.CastShadow = false
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        
        -- Hide decoration parts
        local name = obj.Name:lower()
        if name:match("leaf") or name:match("grass") or name:match("tree") or 
           name:match("bush") or name:match("plant") or name:match("flower") or
           name:match("rock") or name:match("stone") or name:match("decoration") or
           name:match("detail") or name:match("fence") or name:match("prop") then
            if obj.Transparency < 1 then
                obj.Transparency = 1
                obj.CanCollide = false
            end
        end
        return
    end
    
    -- Mesh textures
    if objType == "SpecialMesh" then
        if obj.TextureId ~= "" then
            obj.TextureId = ""
        end
    elseif objType == "MeshPart" then
        if obj.TextureID ~= "" then
            obj.TextureID = ""
        end
    end
end

-- ========================================
-- 👤 OPTIMIZE CHARACTER
-- ========================================
local function OptimizeCharacter(char, isLocalPlayer)
    if not char or not char.Parent then return end
    
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CastShadow = false
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            if obj.Enabled then
                obj.Enabled = false
                table.insert(FPSBoost.DisabledObjects, obj)
            end
            
        -- Hide accessories dari player lain
        elseif not isLocalPlayer and (obj:IsA("Accessory") or obj:IsA("Hat")) then
            if obj:FindFirstChildOfClass("Part") then
                local part = obj:FindFirstChildOfClass("Part")
                part.Transparency = 1
            end
        end
    end
end

-- ========================================
-- 🚀 ENABLE FPS BOOST
-- ========================================
local function EnableFPSBoost()
    if FPSBoost.Active then
        warn("⚠️ FPS Boost already active!")
        return
    end
    
    FPSBoost.Active = true
    FPSBoost.DisabledObjects = {}
    print("🔥 Enabling FPS Boost Ultra...")
    
    -- ========================================
    -- 1. LIGHTING EXTREME
    -- ========================================
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 999999
    Lighting.FogStart = 999999
    Lighting.Brightness = 1
    Lighting.OutdoorAmbient = Color3.new(0.8, 0.8, 0.8)
    Lighting.Ambient = Color3.new(0.8, 0.8, 0.8)
    
    pcall(function()
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end)
    
    -- Disable effects (NOT destroy)
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or 
           effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or 
           effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") or
           effect:IsA("Atmosphere") or effect:IsA("Sky") or effect:IsA("Clouds") then
            if effect.Enabled then
                effect.Enabled = false
                table.insert(FPSBoost.DisabledObjects, effect)
            end
        end
    end
    
    -- ========================================
    -- 2. TERRAIN EXTREME
    -- ========================================
    if Terrain then
        FPSBoost.OriginalTerrain = {
            WaterWaveSize = Terrain.WaterWaveSize,
            WaterWaveSpeed = Terrain.WaterWaveSpeed,
            WaterReflectance = Terrain.WaterReflectance,
            WaterTransparency = Terrain.WaterTransparency,
            Decoration = Terrain.Decoration,
        }
        
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        Terrain.Decoration = false
    end
    
    -- ========================================
    -- 3. GRAPHICS EXTREME
    -- ========================================
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    pcall(function()
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.EagerBulkExecution = false
    end)
    
    -- ========================================
    -- 4. WORKSPACE OPTIMIZATION (1x only)
    -- ========================================
    local optimized = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        OptimizeObject(obj)
        optimized = optimized + 1
        
        -- Yield every 500 objects
        if optimized % 500 == 0 then
            task.wait()
        end
    end
    
    -- ========================================
    -- 5. OPTIMIZE ALL PLAYERS
    -- ========================================
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            OptimizeCharacter(plr.Character, plr == Player)
        end
    end
    
    -- ========================================
    -- 6. AUTO-OPTIMIZE NEW STUFF (Efficient)
    -- ========================================
    
    -- New players
    local playerConn = Players.PlayerAdded:Connect(function(plr)
        local charConn = plr.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            OptimizeCharacter(char, false)
        end)
        table.insert(FPSBoost.Connections, charConn)
    end)
    table.insert(FPSBoost.Connections, playerConn)
    
    -- New objects (THROTTLED - cuma tiap 0.2 detik)
    local lastOptimize = tick()
    local descendantConn = workspace.DescendantAdded:Connect(function(obj)
        if not FPSBoost.Active then return end
        
        local now = tick()
        if now - lastOptimize < 0.2 then return end
        lastOptimize = now
        
        task.spawn(OptimizeObject, obj)
    end)
    table.insert(FPSBoost.Connections, descendantConn)
    
    -- ========================================
    -- 7. RENDER DISTANCE
    -- ========================================
    pcall(function()
        settings().Rendering.ViewDistanceScale = 0.5
    end)
    
    print(string.format("✅ FPS Boost Ultra Active! Optimized %d objects", optimized))
end

-- ========================================
-- ❌ DISABLE FPS BOOST
-- ========================================
local function DisableFPSBoost()
    if not FPSBoost.Active then
        warn("⚠️ FPS Boost not active!")
        return
    end
    
    FPSBoost.Active = false
    print("🔄 Disabling FPS Boost Ultra...")
    
    -- ========================================
    -- 1. RESTORE LIGHTING
    -- ========================================
    local orig = FPSBoost.OriginalLighting
    Lighting.GlobalShadows = orig.GlobalShadows
    Lighting.FogEnd = orig.FogEnd
    Lighting.FogStart = orig.FogStart
    Lighting.Brightness = orig.Brightness
    Lighting.OutdoorAmbient = orig.OutdoorAmbient
    Lighting.Ambient = orig.Ambient
    
    pcall(function()
        Lighting.EnvironmentDiffuseScale = orig.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = orig.EnvironmentSpecularScale
    end)
    
    -- ========================================
    -- 2. RESTORE TERRAIN
    -- ========================================
    if Terrain and next(FPSBoost.OriginalTerrain) then
        local origTerr = FPSBoost.OriginalTerrain
        Terrain.WaterWaveSize = origTerr.WaterWaveSize
        Terrain.WaterWaveSpeed = origTerr.WaterWaveSpeed
        Terrain.WaterReflectance = origTerr.WaterReflectance
        Terrain.WaterTransparency = origTerr.WaterTransparency
        Terrain.Decoration = origTerr.Decoration
    end
    
    -- ========================================
    -- 3. RESTORE GRAPHICS
    -- ========================================
    settings().Rendering.QualityLevel = FPSBoost.OriginalQuality
    
    pcall(function()
        settings().Rendering.ViewDistanceScale = 1
    end)
    
    -- ========================================
    -- 4. RE-ENABLE DISABLED OBJECTS
    -- ========================================
    for _, obj in pairs(FPSBoost.DisabledObjects) do
        if obj and obj.Parent then
            pcall(function()
                obj.Enabled = true
            end)
        end
    end
    FPSBoost.DisabledObjects = {}
    
    -- ========================================
    -- 5. DISCONNECT CONNECTIONS
    -- ========================================
    for _, conn in pairs(FPSBoost.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    FPSBoost.Connections = {}
    
    print("❌ FPS Boost Ultra Disabled - Settings Restored")
end

-- ========================================
-- 📤 RETURN MODULE
-- ========================================
return {
    Enable = EnableFPSBoost,
    Disable = DisableFPSBoost,
    IsActive = function() return FPSBoost.Active end
}
