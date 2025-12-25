-- ========================================
-- 🧑‍💻 HACKER EVENT SEEK & LOCK (STREAM SAFE)
-- ========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========================================
-- 📍 EVENT SPAWN POINTS
-- ========================================
local SEARCH_POINTS = {
    CFrame.new(-1741.52502, 5.2249999, 1453.5),
    CFrame.new(-326.524994, 5.2249999, 2385.30005),
    CFrame.new(1141.67505, 5.2249999, 3230.5)
}

-- ========================================
-- 📦 STATE
-- ========================================
local HackerEvent = {
    Enabled = false,
    Locked = false,
    LastCFrame = nil,
    Thread = nil
}

-- ========================================
-- 🛠️ UTIL
-- ========================================
local function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function Teleport(cf)
    local char = GetChar()
    if char then
        char:PivotTo(cf * CFrame.new(0, 3, 0))
    end
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

-- ========================================
-- 🔄 MAIN LOOP (15s)
-- ========================================
local function StartLoop()
    HackerEvent.Thread = task.spawn(function()
        local index = 1

        while HackerEvent.Enabled do
            local eventPart = GetHackerEventPart()

            if eventPart then
                local cf = eventPart.CFrame

                if not HackerEvent.Locked then
                    HackerEvent.Locked = true
                    HackerEvent.LastCFrame = cf
                    print("🔒 [HackerEvent] FOUND & LOCKED")
                    Teleport(cf)

                elseif (cf.Position - HackerEvent.LastCFrame.Position).Magnitude > 1 then
                    print("🔄 [HackerEvent] Event moved → re-seeking")
                    HackerEvent.Locked = false
                    HackerEvent.LastCFrame = nil
                    index = 1
                end
            else
                -- Event not loaded → seek via teleport
                HackerEvent.Locked = false
                local targetCF = SEARCH_POINTS[index]
                print("🔍 [HackerEvent] Seeking event at point", index)
                Teleport(targetCF)

                index += 1
                if index > #SEARCH_POINTS then
                    index = 1
                end
            end

            task.wait(15) -- ⏰ FIXED INTERVAL
        end
    end)
end

-- ========================================
-- 🎮 ENABLE / DISABLE
-- ========================================
local function Enable()
    if HackerEvent.Enabled then return end
    HackerEvent.Enabled = true
    HackerEvent.Locked = false
    HackerEvent.LastCFrame = nil

    print("🟢 [HackerEvent] Auto Seek ENABLED")
    StartLoop()
end

local function Disable()
    if not HackerEvent.Enabled then return end
    HackerEvent.Enabled = false

    if HackerEvent.Thread then
        task.cancel(HackerEvent.Thread)
        HackerEvent.Thread = nil
    end

    HackerEvent.Locked = false
    HackerEvent.LastCFrame = nil
    print("🔴 [HackerEvent] Auto Seek DISABLED")
end

-- ========================================
-- 📤 EXPORT
-- ========================================
return {
    Enable = Enable,
    Disable = Disable
}
