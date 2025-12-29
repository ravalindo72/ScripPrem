-- ========================================
-- 🚀 ULTRA BOOST FPS MODULE
-- FIRE & FORGET (CLIENT SIDE)
-- ========================================

local UltraBoostFPS = {}

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local player = Players.LocalPlayer

-- State guard (biar ga kepanggil 2x)
local Activated = false

function UltraBoostFPS.Enable()
    if Activated then
        warn("⚠️ Ultra Boost FPS already activated")
        return
    end
    Activated = true

    print("🚀 ULTRA BOOST FPS ACTIVATED")

    -- 1️⃣ Lighting
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        Lighting.Brightness = 0
        Lighting.ClockTime = 12

        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect")
            or effect:IsA("BloomEffect")
            or effect:IsA("SunRaysEffect")
            or effect:IsA("ColorCorrectionEffect")
            or effect:IsA("BlurEffect")
            or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end
    end)

    -- 2️⃣ Terrain
    if Terrain then
        pcall(function()
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            Terrain.Decoration = false
        end)
    end

    -- 3️⃣ Graphics
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end)

    -- 4️⃣ Workspace objects
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.SmoothPlastic

                local n = obj.Name:lower()
                if n:match("leaf") or n:match("grass") or n:match("bush")
                or n:match("decoration") or n:match("cloud")
                or n:match("particle") then
                    obj.Transparency = 1
                    obj.CanCollide = false
                end
            end

            if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Fire")
            or obj:IsA("Smoke")
            or obj:IsA("Sparkles") then
                obj.Enabled = false
            end

            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end

            if obj:IsA("SpecialMesh") then
                obj.TextureId = ""
            end

            if obj:IsA("Sound") and not obj:FindFirstAncestorOfClass("PlayerGui") then
                obj.Volume = 0
            end
        end)
    end

    -- 5️⃣ Player character
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            pcall(function()
                if part:IsA("BasePart")
                and part.Name ~= "HumanoidRootPart"
                and part.Name ~= "Head" then
                    part.CastShadow = false
                    part.Material = Enum.Material.SmoothPlastic
                end

                if part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 1
                end
            end)
        end
    end

    print("✅ ULTRA BOOST FPS DONE (Relog to restore)")
end

function UltraBoostFPS.Disable()
    warn("ℹ️ Ultra Boost FPS tidak bisa direstore. Relog untuk reset.")
end

return UltraBoostFPS
