-- ========================================
-- 🧑‍💻 HACKER EVENT SEEK & LOCK (CLEAN V3)
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
    SEEK_INTERVAL = 15,           -- Interval cycling kalau belum nemu
    FOLDER_CHECK_INTERVAL = 0.5,  -- Interval ngecek folder (cepet biar responsive)
    TELEPORT_OFFSET = 3,          -- Offset Y pas teleport
    RANDOM_OFFSET_RANGE = 15      -- Range random offset biar ga nabrak orang
}

-- ========================================
-- 📦 STATE
-- ========================================
local State = {
    Enabled = false,
    IsAtEvent = false,
    CurrentPointIndex = 1,
    MainThread = nil,
    MonitorThread = nil
}

-- ========================================
-- 🛠️ UTILITIES
-- ========================================
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRandomOffset()
    local range = SETTINGS.RANDOM_OFFSET_RANGE
    return CFrame.new(
        math.random(-range, range),
        0,
        math.random(-range, range)
    )
end

local function SafeTeleport(cf)
    local char = GetCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local offsetCF = cf * GetRandomOffset() * CFrame.new(0, SETTINGS.TELEPORT_OFFSET, 0)
        hrp.CFrame = offsetCF
        return true
    end
    return false
end

local function FindHackerEventInFolder()
    -- CUMA ngecek di folder Locations (ga teleport)
    local locations = workspace:FindFirstChild("Locations")
    if not locations then return nil end
    
    local event = locations:FindFirstChild("Hacker Event")
    if not event then return nil end
    
    -- Return part-nya kalau ketemu
    if event:IsA("BasePart") then
        return event
    elseif event:IsA("Model") then
        return event.PrimaryPart or event:FindFirstChildWhichIsA("BasePart")
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
-- 👀 FOLDER MONITOR (Background)
-- ========================================
local function StartFolderMonitor()
    State.MonitorThread = task.spawn(function()
        while State.Enabled do
            local eventPart = FindHackerEventInFolder()
            
            if eventPart then
                -- Event ada di folder!
                if not State.IsAtEvent then
                    State.IsAtEvent = true
                    print("🔒 [HackerEvent] Event DETECTED in folder!")
                    
                    -- Teleport SEKALI aja pas pertama detect
                    SafeTeleport(eventPart.CFrame)
                end
                -- Kalau udah di event, CUMA monitor aja, ga teleport lagi
                
            else
                -- Event hilang dari folder!
                if State.IsAtEvent then
                    print("❌ [HackerEvent] Event DISAPPEARED from folder!")
                    State.IsAtEvent = false
                    -- Balik ke seeking mode
                end
            end
            
            task.wait(SETTINGS.FOLDER_CHECK_INTERVAL)
        end
    end)
end

-- ========================================
-- 🔄 MAIN LOOP (Seeking Only)
-- ========================================
local function MainLoop()
    State.MainThread = task.spawn(function()
        while State.Enabled do
            -- Kalau belum di event, terus seeking
            if not State.IsAtEvent then
                SeekEvent()
                task.wait(SETTINGS.SEEK_INTERVAL)
            else
                -- Kalau udah di event, cuma idle aja (monitor jalan di background)
                task.wait(1)
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
    State.IsAtEvent = false
    State.CurrentPointIndex = 1
    
    print("🟢 [HackerEvent] Auto Seek ENABLED")
    
    -- Start both threads
    StartFolderMonitor()  -- Background monitor
    MainLoop()            -- Seeking loop
end

local function Disable()
    if not State.Enabled then 
        warn("⚠️ [HackerEvent] Already disabled!")
        return 
    end
    
    State.Enabled = false
    
    -- Cancel both threads
    if State.MainThread then
        task.cancel(State.MainThread)
        State.MainThread = nil
    end
    
    if State.MonitorThread then
        task.cancel(State.MonitorThread)
        State.MonitorThread = nil
    end
    
    State.IsAtEvent = false
    State.CurrentPointIndex = 1
    
    print("🔴 [HackerEvent] Auto Seek DISABLED")
end

-- ========================================
-- 📤 EXPORT
-- ========================================
return {
    Enable = Enable,
    Disable = Disable,
    
    -- Optional: buat debugging
    GetState = function()
        return {
            Enabled = State.Enabled,
            IsAtEvent = State.IsAtEvent,
            CurrentPoint = State.CurrentPointIndex
        }
    end,
    
    SetSettings = function(newSettings)
        for k, v in pairs(newSettings) do
            if SETTINGS[k] then
                SETTINGS[k] = v
                print(string.format("⚙️ [HackerEvent] Setting %s = %s", k, tostring(v)))
            end
        end
    end
}
