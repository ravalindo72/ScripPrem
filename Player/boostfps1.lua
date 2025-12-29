-- ========================================
-- 🚀 ULTRA BOOST FPS (FIRE & FORGET)
-- ========================================

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local player = Players.LocalPlayer

-- Fungsi boost FPS (SEKALI JALAN, NO LOOP)
local function EnableUltraBoost()
    print("🚀 ULTRA BOOST FPS ACTIVATED")
    
    -- 1️⃣ Optimasi Lighting
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.Brightness = 0
        Lighting.ClockTime = 12
        
        -- Hapus semua efek lighting
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or 
               effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or
               effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end
    end)
    
    -- 2️⃣ Optimasi Terrain
    if Terrain then
        pcall(function()
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            Terrain.Decoration = false
        end)
    end
    
    -- 3️⃣ Set graphics ke MINIMUM
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end)
    
    -- 4️⃣ Optimasi SEMUA object di workspace (SEKALI aja)
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            -- BasePart optimization
            if obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.SmoothPlastic
                
                -- Hapus dekorasi
                if obj.Name:lower():match("leaf") or 
                   obj.Name:lower():match("grass") or
                   obj.Name:lower():match("decoration") or
                   obj.Name:lower():match("particle") or
                   obj.Name:lower():match("cloud") or
                   obj.Name:lower():match("bush") then
                    obj.Transparency = 1
                    obj.CanCollide = false
                end
            end
            
            -- Disable particles & effects
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = false
            end
            
            if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
            
            -- Disable GUI yang bukan player
            if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
                if not obj:FindFirstAncestorOfClass("PlayerGui") then
                    obj.Enabled = false
                end
            end
            
            -- Hapus texture
            if obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            end
            
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
            
            -- Mute sound yang bukan UI
            if obj:IsA("Sound") then
                if not obj:FindFirstAncestorOfClass("PlayerGui") then
                    obj.Volume = 0
                end
            end
        end)
    end
    
    -- 5️⃣ Optimasi karakter player (kecuali HRP & Head)
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            pcall(function()
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" then
                    part.CastShadow = false
                    part.Material = Enum.Material.SmoothPlastic
                end
                
                if part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 1
                end
            end)
        end
    end
    
    -- 6️⃣ Optimasi player lain
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            pcall(function()
                for _, part in pairs(otherPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CastShadow = false
                        part.Material = Enum.Material.SmoothPlastic
                    end
                    
                    if part:IsA("Decal") or part:IsA("Texture") then
                        part.Transparency = 1
                    end
                    
                    if part:IsA("ParticleEmitter") or part:IsA("Trail") then
                        part.Enabled = false
                    end
                end
            end)
        end
    end
    
    print("✅ BOOST FPS DONE (No loop, no restore)")
end

return {
    Enable = EnableUltraBoost
}
