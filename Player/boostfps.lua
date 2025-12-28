-- ========================================
-- 🔥 FPS BOOST EXTREME (MAKSIMAL PERFORMA)
-- ========================================

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local IsBoostActive = false
local OriginalFog = Lighting.FogEnd
local OriginalShadows = Lighting.GlobalShadows

-- FUNGSI BOOST FPS EXTREME
local function EnableFPSBoost()
    if IsBoostActive then return end
    IsBoostActive = true
    
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
        
        -- Particles & Effects (paling berat)
        if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
            obj:Destroy()
        elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj:Destroy()
        elseif obj:IsA("Explosion") then
            obj:Destroy()
            
        -- Lights (bikin shadow & reflection)
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj:Destroy()
            
        -- Sounds yang ga penting
        elseif obj:IsA("Sound") then
            if not obj:FindFirstAncestorOfClass("PlayerGui") then
                obj:Destroy()
            end
            
        -- BasePart optimizations
        elseif obj:IsA("BasePart") then
            obj.CastShadow = false
            obj.Material = Enum.Material.SmoothPlastic
            
            -- Hilangin dekorasi (daun, rumput, pohon, dll)
            local name = obj.Name:lower()
            if name:match("leaf") or name:match("grass") or name:match("tree") or 
               name:match("bush") or name:match("plant") or name:match("flower") or
               name:match("decoration") or name:match("detail") then
                obj.Transparency = 1
                obj.CanCollide = false
            end
            
        -- Textures & Decals (bikin lag render)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
            
        -- Mesh textures
        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = ""
            
        -- Sky & Atmosphere
        elseif obj:IsA("Sky") then
            obj:Destroy()
        elseif obj:IsA("Atmosphere") then
            obj:Destroy()
            
        -- Clouds
        elseif obj:IsA("Clouds") then
            obj:Destroy()
        end
    end
    
    -- 4. GRAPHICS SETTINGS (paling extreme)
    local rendering = settings().Rendering
    rendering.QualityLevel = Enum.QualityLevel.Level01
    rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    
    -- Extra optimizations
    pcall(function()
        rendering.EditQualityLevel = Enum.QualityLevel.Level01
    end)
    
    -- 5. PLAYER CHARACTERS (hapus accessories & shadows)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CastShadow = false
                    part.Material = Enum.Material.SmoothPlastic
                elseif part:IsA("Accessory") or part:IsA("Hat") then
                    if plr ~= Player then -- Hapus accessories player lain
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
                elseif part:IsA("Accessory") and plr ~= Player then
                    part:Destroy()
                end
            end
        end)
    end)
    
    print("✅ FPS Boost EXTREME Aktif! 🔥")
end

-- FUNGSI DISABLE (restore minimal)
local function DisableFPSBoost()
    if not IsBoostActive then return end
    IsBoostActive = false
    
    -- Restore lighting
    Lighting.GlobalShadows = OriginalShadows
    Lighting.FogEnd = OriginalFog
    Lighting.Brightness = 1
    
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

-- UI TOGGLE
VyperUI:CreateToggle(PlayerTab, {
    Title = "🔥 FPS Boost EXTREME",
    Subtitle = "Performa maksimal • Hilangin semua yang ga penting",
    Default = false,
    Callback = function(state)
        if state then
            EnableFPSBoost()
        else
            DisableFPSBoost()
        end
    end
})
