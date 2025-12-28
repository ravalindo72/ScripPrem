-- ========================================
-- 🔥 FPS BOOST OPTIMIZED (SMOOTH & SAFE)
-- ========================================
-- NO LOOPS - Cuma jalan 1x pas enable
-- NO DESTROY - Cuma disable/hide untuk bisa di-restore
-- MEMORY SAFE - Ga ngeloop, ga bikin memory leak
-- ========================================

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ========================================
-- 💾 BACKUP STORAGE
-- ========================================
local Backup = {
    Active = false,
    
    -- Lighting
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    
    -- Terrain
    WaterWaveSize = nil,
    WaterWaveSpeed = nil,
    WaterReflectance = nil,
    WaterTransparency = nil,
    
    -- Graphics
    QualityLevel = settings().Rendering.QualityLevel,
    
    -- Effects (store references untuk enable/disable)
    LightingEffects = {},
    
    -- Connections
    Connections = {}
}

-- ========================================
-- 🎨 NEUTRAL COLOR (Remove warna)
-- ========================================
local NEUTRAL_COLOR = Color3.new(0.5, 0.5, 0.5)

-- ========================================
-- 🚀 ENABLE FPS BOOST
-- ========================================
local function EnableFPSBoost()
    if Backup.Active then 
        warn("⚠️ FPS Boost already active!")
        return 
    end
    
    Backup.Active = true
    print("🔥 Enabling FPS Boost...")
    
    -- ========================================
    -- 1. LIGHTING OPTIMIZATION
    -- ========================================
    Lighting.Brightness = 1
    Lighting.Ambient = NEUTRAL_COLOR
    Lighting.OutdoorAmbient = NEUTRAL_COLOR
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
    Lighting.GlobalShadows = false
    
    -- Disable post effects (NO DESTROY, just disable)
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or 
           effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or 
           effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") then
            
            if effect.Enabled then
                table.insert(Backup.LightingEffects, effect)
                effect.Enabled = false
            end
        end
    end
    
    -- ========================================
    -- 2. TERRAIN OPTIMIZATION
    -- ========================================
    if Terrain then
        Backup.WaterWaveSize = Terrain.WaterWaveSize
        Backup.WaterWaveSpeed = Terrain.WaterWaveSpeed
        Backup.WaterReflectance = Terrain.WaterReflectance
        Backup.WaterTransparency = Terrain.WaterTransparency
        
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        Terrain.Decoration = false
    end
    
    -- ========================================
    -- 3. GRAPHICS SETTINGS
    -- ========================================
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    pcall(function()
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end)
    
    -- ========================================
    -- 4. WORKSPACE OPTIMIZATION (1x ONLY, NO LOOP!)
    -- ========================================
    local optimizedCount = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        
        -- Particles (Disable, not destroy)
        if obj:IsA("ParticleEmitter") then
            if obj.Enabled then
                obj.Enabled = false
                optimizedCount = optimizedCount + 1
            end
            
        -- Beams & Trails
        elseif obj:IsA("Beam") or obj:IsA("Trail") then
            if obj.Enabled then
                obj.Enabled = false
                optimizedCount = optimizedCount + 1
            end
            
        -- Lights (Disable)
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            if obj.Enabled then
                obj.Enabled = false
                optimizedCount = optimizedCount + 1
            end
            
        -- Parts (Shadow only)
        elseif obj:IsA("BasePart") then
            if obj.CastShadow then
                obj.CastShadow = false
                optimizedCount = optimizedCount + 1
            end
        end
        
        -- Limit checks per frame to avoid freeze
        if optimizedCount % 500 == 0 then
            task.wait()
        end
    end
    
    -- ========================================
    -- 5. PLAYER CHARACTERS (Current only)
    -- ========================================
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CastShadow then
                    part.CastShadow = false
                end
            end
        end
    end
    
    -- ========================================
    -- 6. NEW PLAYER AUTO-OPTIMIZE (Lightweight)
    -- ========================================
    local newPlayerConn = Players.PlayerAdded:Connect(function(plr)
        local charConn = plr.CharacterAdded:Connect(function(char)
            task.wait(1)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CastShadow then
                    part.CastShadow = false
                end
            end
        end)
        table.insert(Backup.Connections, charConn)
    end)
    
    table.insert(Backup.Connections, newPlayerConn)
    
    print(string.format("✅ FPS Boost Active! Optimized %d objects", optimizedCount))
end

-- ========================================
-- ❌ DISABLE FPS BOOST (RESTORE)
-- ========================================
local function DisableFPSBoost()
    if not Backup.Active then 
        warn("⚠️ FPS Boost not active!")
        return 
    end
    
    Backup.Active = false
    print("🔄 Disabling FPS Boost...")
    
    -- ========================================
    -- 1. RESTORE LIGHTING
    -- ========================================
    Lighting.Brightness = Backup.Brightness
    Lighting.Ambient = Backup.Ambient
    Lighting.OutdoorAmbient = Backup.OutdoorAmbient
    Lighting.FogEnd = Backup.FogEnd
    Lighting.FogStart = Backup.FogStart
    Lighting.GlobalShadows = Backup.GlobalShadows
    
    -- Re-enable effects
    for _, effect in pairs(Backup.LightingEffects) do
        if effect and effect.Parent then
            effect.Enabled = true
        end
    end
    Backup.LightingEffects = {}
    
    -- ========================================
    -- 2. RESTORE TERRAIN
    -- ========================================
    if Terrain and Backup.WaterWaveSize then
        Terrain.WaterWaveSize = Backup.WaterWaveSize
        Terrain.WaterWaveSpeed = Backup.WaterWaveSpeed
        Terrain.WaterReflectance = Backup.WaterReflectance
        Terrain.WaterTransparency = Backup.WaterTransparency
        Terrain.Decoration = true
    end
    
    -- ========================================
    -- 3. RESTORE GRAPHICS
    -- ========================================
    settings().Rendering.QualityLevel = Backup.QualityLevel
    
    -- ========================================
    -- 4. DISCONNECT CONNECTIONS
    -- ========================================
    for _, conn in pairs(Backup.Connections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    Backup.Connections = {}
    
    print("❌ FPS Boost Disabled - Settings Restored")
end

-- ========================================
-- 📤 RETURN MODULE
-- ========================================
return {
    Enable = EnableFPSBoost,
    Disable = DisableFPSBoost,
    IsActive = function() return Backup.Active end
}
