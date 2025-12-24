-- ========================================
-- 🎄 CHRISTMAS CAVE AUTO EVENT
-- ========================================
-- SAFE: Client-side only, no server manipulation
-- LOGIC: Monitor UI notification → Auto teleport → Auto exit
-- ========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- ========================================
-- 📦 STATE MANAGEMENT
-- ========================================
local AutoEvent = {
    Enabled = false,
    SavedCFrame = nil,
    InEvent = false,
    Connections = {},
    LastCheck = 0,
    EventReallyActive = false  -- NEW: Track if event is actually open
}

-- ========================================
-- 📍 CAVE LOCATION (Updated from actual position)
-- ========================================
local CAVE_CFRAME = CFrame.new(
    545.998047, -579.297607, 8903.3457,
    0.0665921867, 0.0738025084, -0.995046973,
    -0.0106721297, 0.997256219, 0.0732521564,
    0.997723222, 0.00574125163, 0.0671970546
)

-- ========================================
-- 🛠️ UTILITY FUNCTIONS
-- ========================================

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Check if event is active via multiple methods
local function IsEventActive()
    -- Only return true if we confirmed event opened via [Server] message
    return AutoEvent.EventReallyActive
end

-- ========================================
-- 🚀 CORE FUNCTIONS
-- ========================================

local function EnterEvent()
    if AutoEvent.InEvent then return end
    
    local root = GetRootPart()
    if not root then 
        warn("⚠️ [ChristmasCave] No HumanoidRootPart found")
        return 
    end
    
    AutoEvent.InEvent = true
    print("🎄 [ChristmasCave] Event detected! Entering...")
    
    -- Teleport to cave
    task.wait(0.5) -- Delay untuk stability
    local char = GetCharacter()
    if char then
        char:PivotTo(CAVE_CFRAME)
        print("✅ [ChristmasCave] Teleported to cave!")
        
        -- Send notification
        StarterGui:SetCore("SendNotification", {
            Title = "🎄 Christmas Cave",
            Text = "Auto teleported to event!",
            Duration = 3
        })
    end
end

local function ExitEvent()
    if not AutoEvent.InEvent then return end
    
    AutoEvent.InEvent = false
    print("🚪 [ChristmasCave] Event ended, exiting...")
    
    if AutoEvent.SavedCFrame then
        local char = GetCharacter()
        if char then
            task.wait(0.5)
            char:PivotTo(AutoEvent.SavedCFrame)
            print("✅ [ChristmasCave] Returned to original position")
            
            StarterGui:SetCore("SendNotification", {
                Title = "🎄 Christmas Cave",
                Text = "Returned to saved location",
                Duration = 3
            })
        end
    end
end

-- ========================================
-- 🔄 MONITORING SYSTEM
-- ========================================

local function StartEventMonitor()
    local connection = task.spawn(function()
        while AutoEvent.Enabled do
            local currentTime = tick()
            
            -- Check every 2 seconds
            if currentTime - AutoEvent.LastCheck >= 2 then
                AutoEvent.LastCheck = currentTime
                
                local eventActive = IsEventActive()
                
                if eventActive and not AutoEvent.InEvent then
                    print("🔔 [ChristmasCave] Event started!")
                    EnterEvent()
                elseif not eventActive and AutoEvent.InEvent then
                    print("⏰ [ChristmasCave] Event ended detected!")
                    task.wait(1) -- Wait a bit before teleporting back
                    ExitEvent()
                end
            end
            
            task.wait(0.5) -- Check loop delay
        end
    end)
    
    table.insert(AutoEvent.Connections, connection)
    print("🔍 [ChristmasCave] Monitor started")
end

local function StartLocationMonitor()
    local connection = LocalPlayer:GetAttributeChangedSignal("LocationName"):Connect(function()
        if not AutoEvent.Enabled then return end
        
        local location = LocalPlayer:GetAttribute("LocationName")
        print("📍 [ChristmasCave] Location changed to:", location)
        
        -- If we're in event but event is no longer active, exit immediately
        if AutoEvent.InEvent and not IsEventActive() then
            print("⏰ [ChristmasCave] Event ended, returning home")
            task.wait(0.5)
            ExitEvent()
        end
        
        -- If location changed away from Christmas area
        if AutoEvent.InEvent and location then
            local locStr = tostring(location):lower()
            if not string.find(locStr, "christmas") and not string.find(locStr, "natal") then
                print("⚠️ [ChristmasCave] Kicked from event area")
                ExitEvent()
            end
        end
    end)
    
    table.insert(AutoEvent.Connections, connection)
end

local function StartRespawnMonitor()
    local connection = LocalPlayer.CharacterAdded:Connect(function(char)
        if not AutoEvent.Enabled then return end
        
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(1.5)
        
        if IsEventActive() then
            print("♻️ [ChristmasCave] Respawned, re-entering event")
            AutoEvent.InEvent = false
            EnterEvent()
        end
    end)
    
    table.insert(AutoEvent.Connections, connection)
end

-- Monitor for [Server] messages in chat
local function StartChatMonitor()
    local success, textChatService = pcall(function()
        return game:GetService("TextChatService")
    end)
    
    if success and textChatService then
        local connection = textChatService.MessageReceived:Connect(function(message)
            if not AutoEvent.Enabled then return end
            
            local text = message.Text or ""
            
            -- Event OPENED - Detect "[Server]: The Christmas Cave at Christmas Island has opened!"
            if string.find(text, "[Server]") then
                if (string.find(text, "Christmas Cave") or string.find(text, "Christmas Island")) and
                   (string.find(text:lower(), "opened") or 
                    string.find(text:lower(), "has opened") or
                    string.find(text:lower(), "is now open")) then
                    
                    print("💬 [ChristmasCave] Server: Event OPENED!")
                    AutoEvent.EventReallyActive = true
                    
                    task.wait(1)
                    if not AutoEvent.InEvent then
                        EnterEvent()
                    end
                end
            end
        end)
        
        table.insert(AutoEvent.Connections, connection)
        print("💬 [ChristmasCave] Chat monitor started")
    end
end

-- ========================================
-- 🎮 ENABLE/DISABLE FUNCTIONS
-- ========================================

function EnableChristmasCaveAuto()
    if AutoEvent.Enabled then return end
    
    AutoEvent.Enabled = true
    AutoEvent.EventReallyActive = false  -- Reset event state
    print("🎄 [ChristmasCave] Auto enabled!")
    
    -- Save current position
    local root = GetRootPart()
    if root then
        AutoEvent.SavedCFrame = GetCharacter():GetPivot()
        print("💾 [ChristmasCave] Saved position:", AutoEvent.SavedCFrame)
    end
    
    -- Start all monitors
    StartEventMonitor()
    StartLocationMonitor()
    StartRespawnMonitor()
    StartChatMonitor()
    
    print("⏳ [ChristmasCave] Waiting for [Server] announcement...")
    print("📢 [ChristmasCave] Will only teleport after server confirms event is open!")
    
    StarterGui:SetCore("SendNotification", {
        Title = "🎄 Auto Christmas Cave",
        Text = "Waiting for server announcement...",
        Duration = 3
    })
end

function DisableChristmasCaveAuto()
    if not AutoEvent.Enabled then return end
    
    AutoEvent.Enabled = false
    AutoEvent.EventReallyActive = false  -- Reset event state
    print("🛑 [ChristmasCave] Auto disabled")
    
    -- Disconnect all connections
    for _, conn in pairs(AutoEvent.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        else
            task.cancel(conn)
        end
    end
    AutoEvent.Connections = {}
    
    -- Exit event if in it
    if AutoEvent.InEvent then
        ExitEvent()
    end
    
    AutoEvent.SavedCFrame = nil
    
    StarterGui:SetCore("SendNotification", {
        Title = "🎄 Auto Christmas Cave",
        Text = "Disabled",
        Duration = 2
    })
end

return {
    Enable = EnableChristmasCaveAuto,
    Disable = DisableChristmasCaveAuto
}
