-- ========================================
-- 🧑‍💻 HACKER EVENT AUTO TELEPORT
-- ========================================
-- SAFE: Client-side only
-- LOGIC: Scan Workspace.Hacker Event setiap 15 detik
-- ACTION: Jika lokasi berubah → Auto Teleport
-- ========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========================================
-- 📦 STATE
-- ========================================
local HackerEvent = {
    Enabled = false,
    LastCFrame = nil,
    Connections = {}
}

-- ========================================
-- 🛠️ UTILITIES
-- ========================================

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRoot()
    local char = GetCharacter()
    return char:WaitForChild("HumanoidRootPart")
end

local function GetHackerEventPart()
    local obj = workspace:FindFirstChild("Hacker Event", true)
    if not obj then return nil end

    if obj:IsA("BasePart") then
        return obj
    elseif obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
end

local function TeleportTo(cf)
    local char = GetCharacter()
    if char then
        char:PivotTo(cf * CFrame.new(0, 3, 0))
    end
end

-- ========================================
-- 🔄 MONITOR (15s SCAN)
-- ========================================

local function StartMonitor()
    local thread = task.spawn(function()
        while HackerEvent.Enabled do
            local eventPart = GetHackerEventPart()

            if eventPart then
                local currentCF = eventPart.CFrame

                if not HackerEvent.LastCFrame then
                    -- First detection
                    HackerEvent.LastCFrame = currentCF
                    print("🧑‍💻 [HackerEvent] Initial position detected")
                    TeleportTo(currentCF)

                elseif (currentCF.Position - HackerEvent.LastCFrame.Position).Magnitude > 1 then
                    -- Location changed
                    HackerEvent.LastCFrame = currentCF
                    print("🚀 [HackerEvent] Location changed → Teleporting")
                    TeleportTo(currentCF)
                end
            else
                warn("⚠️ [HackerEvent] Workspace.Hacker Event not found")
            end

            task.wait(15) -- ⏰ FIXED 15 SECONDS
        end
    end)

    table.insert(HackerEvent.Connections, thread)
end

-- ========================================
-- 🎮 ENABLE / DISABLE
-- ========================================

local function Enable()
    if HackerEvent.Enabled then return end
    HackerEvent.Enabled = true
    HackerEvent.LastCFrame = nil

    print("🟢 [HackerEvent] Auto Teleport ENABLED")
    StartMonitor()
end

local function Disable()
    if not HackerEvent.Enabled then return end
    HackerEvent.Enabled = false

    for _, c in pairs(HackerEvent.Connections) do
        task.cancel(c)
    end
    HackerEvent.Connections = {}
    HackerEvent.LastCFrame = nil

    print("🔴 [HackerEvent] Auto Teleport DISABLED")
end

-- ========================================
-- 📤 EXPORT (FOR UI TOGGLE)
-- ========================================

return {
    Enable = Enable,
    Disable = Disable
}
