-- ========================================
-- 🧑‍💻 HACKER EVENT AUTO TELEPORT (FIXED PATH)
-- ========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========================================
-- ⚙️ SETTINGS
-- ========================================
local SETTINGS = {
    CHECK_INTERVAL = 2,      -- Interval ngecek posisi Black Hole
    TELEPORT_OFFSET = 5      -- Offset Y pas teleport (biar ga kejebak)
}

-- ========================================
-- 📦 STATE
-- ========================================
local State = {
    Enabled = false,
    MainThread = nil,
    LastPosition = nil       -- Nyimpen posisi terakhir buat detect perubahan
}

-- ========================================
-- 🛠️ UTILITIES
-- ========================================
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function SafeTeleport(position)
    local char = GetCharacter()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(position + Vector3.new(0, SETTINGS.TELEPORT_OFFSET, 0))
        return true
    end
    return false
end

local function FindBlackHole()
    -- Cari Props folder dulu
    local props = workspace:FindFirstChild("Props")
    if not props then
        return nil
    end
    
    -- Cari Black Hole di dalem Props
    local blackHole = props:FindFirstChild("Black Hole")
    if not blackHole then
        return nil
    end
    
    -- Kalau Black Hole adalah BasePart
    if blackHole:IsA("BasePart") then
        return blackHole
    end
    
    -- Kalau Black Hole adalah Model/Folder
    if blackHole:IsA("Model") or blackHole:IsA("Folder") then
        -- Cari PrimaryPart atau BasePart pertama
        return blackHole.PrimaryPart or blackHole:FindFirstChildWhichIsA("BasePart", true)
    end
    
    return nil
end

-- ========================================
-- 🔄 MAIN LOOP
-- ========================================
local function MainLoop()
    State.MainThread = task.spawn(function()
        while State.Enabled do
            local blackHolePart = FindBlackHole()
            
            if blackHolePart then
                local currentPos = blackHolePart.Position
                
                -- Cek apakah posisi berubah ATAU ini pertama kali ketemu
                if not State.LastPosition or (currentPos - State.LastPosition).Magnitude > 5 then
                    State.LastPosition = currentPos
                    SafeTeleport(currentPos)
                end
                
            else
                -- Black Hole ga ketemu
                if State.LastPosition then
                    warn("⚠️ [HackerEvent] Black Hole disappeared!")
                    State.LastPosition = nil
                end
            end
            
            task.wait(SETTINGS.CHECK_INTERVAL)
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
    State.LastPosition = nil
    
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
    
    State.LastPosition = nil
    

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
            LastPosition = State.LastPosition
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
