-- ========================================
-- 🧑‍💻 HACKER EVENT SEEK & LOCK (OPTIMIZED)
-- ========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
-- ⚙️ SETTINGS
-- ========================================
local SETTINGS = {
    SEEK_INTERVAL = 15,      -- Interval cycling kalau belum nemu
    CHECK_INTERVAL = 2,      -- Interval ngecek kalau udah lock
    TELEPORT_OFFSET = 3      -- Offset Y pas teleport
}

-- ========================================
-- 📦 STATE
-- ========================================
local State = {
    Enabled = false,
    IsLocked = false,
    CurrentPointIndex = 1,
    MainThread = nil,
    LastEventCheck = 0
}

-- ========================================
-- 🛠️ UTILITIES
-- ========================================
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function SafeTeleport(cf)
    local char = GetCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cf * CFrame.new(0, SETTINGS.TELEPORT_OFFSET, 0)
        return true
    end
    return false
end

local function FindHackerEvent()
    -- Cek di Locations dulu (lebih spesifik)
    local locations = workspace:FindFirstChild("Locations")
    if locations then
        local event = locations:FindFirstChild("Hacker Event")
        if event then
            if event:IsA("BasePart") then
                return event
            elseif event:IsA("Model") then
                return event.PrimaryPart or event:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
    
    -- Fallback: cek di workspace
    local event = workspace:FindFirstChild("Hacker Event", true)
    if event then
        if event:IsA("BasePart") then
            return event
        elseif event:IsA("Model") then
            return event.PrimaryPart or event:FindFirstChildWhichIsA("BasePart")
        end
    end
    
    return nil
end

-- ========================================
-- 🔍 SEEKING MODE
-- ========================================
local function SeekEvent()
    local targetCF = SEARCH_POINTS[State.CurrentPointIndex]
    print(string.format("🔍 [HackerEvent] Seeking point %d/%d", State.CurrentPointIndex, #SEARCH_POINTS))
    
    SafeTeleport(targetCF)
    
    -- Next point
    State.CurrentPointIndex = State.CurrentPointIndex + 1
    if State.CurrentPointIndex > #SEARCH_POINTS then
        State.CurrentPointIndex = 1
    end
end

-- ========================================
-- 🔒 LOCKED MODE
-- ========================================
local function StayAtEvent(eventPart)
    local cf = eventPart.CFrame
    SafeTeleport(cf)
end

-- ========================================
-- 🔄 MAIN LOOP
-- ========================================
local function MainLoop()
    State.MainThread = task.spawn(function()
        while State.Enabled do
            local eventPart = FindHackerEvent()
            
            if eventPart then
                -- Event ditemukan!
                if not State.IsLocked then
                    State.IsLocked = true
                    print("🔒 [HackerEvent] Event FOUND & LOCKED!")
                end
                
                StayAtEvent(eventPart)
                task.wait(SETTINGS.CHECK_INTERVAL) -- Check lebih sering kalau udah lock
                
            else
                -- Event hilang atau belum ketemu
                if State.IsLocked then
                    print("🔄 [HackerEvent] Event LOST - Re-seeking...")
                    State.IsLocked = false
                    State.CurrentPointIndex = 1 -- Reset ke point pertama
                end
                
                SeekEvent()
                task.wait(SETTINGS.SEEK_INTERVAL) -- Wait lebih lama kalau masih seeking
            end
        end
    end)
end

-- ========================================
-- 🎮 PUBLIC API
-- ========================================
local function Enable()
    if State.Enabled then 
        warn("⚠️ [HackerEvent] Already enabled!")
        return 
    end
    
    State.Enabled = true
    State.IsLocked = false
    State.CurrentPointIndex = 1
    
    print("🟢 [HackerEvent] Auto Seek ENABLED")
    MainLoop()
end

local function Disable()
    if not State.Enabled then 
        warn("⚠️ [HackerEvent] Already disabled!")
        return 
    end
    
    State.Enabled = false
    
    if State.MainThread then
        task.cancel(State.MainThread)
        State.MainThread = nil
    end
    
    State.IsLocked = false
    State.CurrentPointIndex = 1
    
    print("🔴 [HackerEvent] Auto Seek DISABLED")
end

-- ========================================
-- 📤 EXPORT
-- ========================================
return {
    Enable = Enable,
    Disable = Disable,
    
    -- Optional: buat debugging atau custom config
    GetState = function()
        return {
            Enabled = State.Enabled,
            IsLocked = State.IsLocked,
            CurrentPoint = State.CurrentPointIndex
        }
    end,
    
    SetSettings = function(newSettings)
        for k, v in pairs(newSettings) do
            if SETTINGS[k] then
                SETTINGS[k] = v
            end
        end
    end
}
