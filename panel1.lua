-- =========================================================
-- VYPER PERFORMANCE MONITOR + NOTIFICATION TRACKER
-- =========================================================
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local Monitor = {}
local guiInstance = nil
local renderConnection = nil
local heartbeatConnection = nil
local notifConnection = nil

-- Configuration & Theme
local Theme = {
    BgColor = Color3.fromRGB(15, 15, 20),
    StrokeColor = Color3.fromRGB(150, 0, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(180, 180, 180),
    Good = Color3.fromRGB(0, 255, 128),
    Warn = Color3.fromRGB(255, 200, 0),
    Bad = Color3.fromRGB(255, 50, 80),
    NotifColor = Color3.fromRGB(255, 140, 50),
    CornerRadius = UDim.new(0, 8),
    Font = Enum.Font.GothamBold
}

-- Helper: Get Notification Count
local function getNotificationCount()
    local count = 0
    local activeCount = 0
    
    pcall(function()
        local playerGui = LocalPlayer.PlayerGui
        if playerGui then
            local textNotifications = playerGui:FindFirstChild("Text Notifications")
            if textNotifications then
                local frame = textNotifications:FindFirstChild("Frame")
                if frame then
                    for _, child in ipairs(frame:GetChildren()) do
                        if child.Name == "Tile" and child:IsA("Frame") then
                            count = count + 1
                            if child.Visible then
                                activeCount = activeCount + 1
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return count, activeCount
end

-- Helper: Create Rounded Shadow Frame
local function CreatePanel()
    if guiInstance then return guiInstance end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VyperStatsX"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 360, 0, 45)  -- Increased width for notif display
    MainFrame.Position = UDim2.new(0.5, -180, 0, 10)
    MainFrame.BackgroundColor3 = Theme.BgColor
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.BgColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    }
    Gradient.Rotation = 90
    Gradient.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Theme.CornerRadius
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Color = Theme.StrokeColor
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.3
    Stroke.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = MainFrame
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 12)
    
    local function MakeSep()
        local S = Instance.new("Frame")
        S.Size = UDim2.new(0, 1, 0, 18)
        S.BackgroundColor3 = Color3.fromRGB(255,255,255)
        S.BackgroundTransparency = 0.8
        S.BorderSizePixel = 0
        S.Parent = MainFrame
    end

    local function MakeStatInfo(name, labelText)
        local Container = Instance.new("Frame")
        Container.Name = name
        Container.BackgroundTransparency = 1
        Container.Size = UDim2.new(0, 75, 1, 0)
        Container.Parent = MainFrame
        
        local Val = Instance.new("TextLabel")
        Val.Name = "Value"
        Val.Parent = Container
        Val.BackgroundTransparency = 1
        Val.Size = UDim2.new(1, 0, 0, 20)
        Val.Position = UDim2.new(0, 0, 0.5, -10)
        Val.Font = Theme.Font
        Val.Text = "--"
        Val.TextColor3 = Theme.TextColor
        Val.TextSize = 16
        Val.TextXAlignment = Enum.TextXAlignment.Center
        Val.RichText = true
        
        local Lab = Instance.new("TextLabel")
        Lab.Name = "Label"
        Lab.Parent = Container
        Lab.BackgroundTransparency = 1
        Lab.Size = UDim2.new(1, 0, 0, 12)
        Lab.Position = UDim2.new(0, 0, 1, -14)
        Lab.Font = Enum.Font.GothamMedium
        Lab.Text = labelText
        Lab.TextColor3 = Theme.SubTextColor
        Lab.TextSize = 9
        Lab.TextXAlignment = Enum.TextXAlignment.Center
        
        return Val
    end
    
    local FPSVal = MakeStatInfo("FPS", "FPS")
    MakeSep()
    local PingVal = MakeStatInfo("Ping", "PING ms")
    MakeSep()
    local CPUVal = MakeStatInfo("CPU", "CPU %")
    MakeSep()
    local NotifVal = MakeStatInfo("Notif", "NOTIFS")
    
    -- DRAGGABLE LOGIC
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0, Color = Theme.StrokeColor}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play()
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0.3}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return {
        Gui = ScreenGui,
        FPS = FPSVal,
        Ping = PingVal,
        CPU = CPUVal,
        Notif = NotifVal,
        Frame = MainFrame,
        Stroke = Stroke
    }
end

local function CleanupExisting()
    if renderConnection then renderConnection:Disconnect() renderConnection = nil end
    if heartbeatConnection then heartbeatConnection:Disconnect() heartbeatConnection = nil end
    if notifConnection then notifConnection:Disconnect() notifConnection = nil end
    
    if guiInstance and guiInstance.Gui then 
        guiInstance.Gui:Destroy() 
    end
    guiInstance = nil
    
    if PlayerGui then
        for _, c in ipairs(PlayerGui:GetChildren()) do
            if c.Name == "VyperStatsX" then
                c:Destroy()
            end
        end
    end
end

function Monitor:Start()
    CleanupExisting()
    
    local ui = CreatePanel()
    if not ui then return end
    ui.Gui.Enabled = true
    
    local fpsAccumulator = 0
    local lastNotifCount = 0
    
    renderConnection = RunService.RenderStepped:Connect(function(dt)
        fpsAccumulator = fpsAccumulator + dt
        if fpsAccumulator >= 0.5 then
            local fps = math.floor(1 / dt)
            local fpsColor = (fps >= 50 and Theme.Good) or (fps >= 30 and Theme.Warn) or Theme.Bad
            if ui.FPS then 
                ui.FPS.Text = tostring(fps)
                ui.FPS.TextColor3 = fpsColor
            end
            fpsAccumulator = 0
        end
    end)
    
    local lastUpdate = tick()
    local cpuSmooth = 0
    
    heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
        if not ui.Gui or not ui.Gui.Parent then 
            CleanupExisting()
            return 
        end

        local rawLoad = math.clamp((dt / 0.01667) * 35, 0, 100) 
        cpuSmooth = (cpuSmooth * 0.9) + (rawLoad * 0.1)
        
        local now = tick()
        if now - lastUpdate >= 0.35 then
            local displayLoad = math.floor(cpuSmooth)
            local cpuColor = (displayLoad < 50 and Theme.Good) or (displayLoad < 80 and Theme.Warn) or Theme.Bad
            
            if ui.CPU then
                ui.CPU.Text = tostring(displayLoad) .. "<font size='10'>%</font>"
                ui.CPU.TextColor3 = cpuColor
            end
            
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            if ping <= 0 then ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end
            
            local pingColor = (ping < 100 and Theme.Good) or (ping < 200 and Theme.Warn) or Theme.Bad
            if ui.Ping then
                ui.Ping.Text = tostring(ping)
                ui.Ping.TextColor3 = pingColor
            end
            
            -- UPDATE NOTIFICATION COUNT
            local totalNotifs, activeNotifs = getNotificationCount()
            if ui.Notif then
                ui.Notif.Text = tostring(totalNotifs) .. "<font size='10'>/" .. tostring(activeNotifs) .. "</font>"
                ui.Notif.TextColor3 = Theme.NotifColor
                
                -- Flash effect on new notification
                if totalNotifs > lastNotifCount then
                    TweenService:Create(ui.Frame, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
                    TweenService:Create(ui.Stroke, TweenInfo.new(0.15), {Transparency = 0, Color = Theme.NotifColor}):Play()
                    
                    task.delay(0.15, function()
                        TweenService:Create(ui.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
                        TweenService:Create(ui.Stroke, TweenInfo.new(0.3), {Transparency = 0.3, Color = Theme.StrokeColor}):Play()
                    end)
                    
                    lastNotifCount = totalNotifs
                end
            end
            
            lastUpdate = now
        end
    end)
    
    -- Monitor for new notifications using ChildAdded
    pcall(function()
        local playerGui = LocalPlayer.PlayerGui
        if playerGui then
            local textNotifications = playerGui:WaitForChild("Text Notifications", 5)
            if textNotifications then
                local frame = textNotifications:WaitForChild("Frame", 5)
                if frame then
                    notifConnection = frame.ChildAdded:Connect(function(child)
                        if child.Name == "Tile" and ui.Notif then
                            -- Instant flash on new notification detected
                            TweenService:Create(ui.Stroke, TweenInfo.new(0.1), {Transparency = 0, Color = Theme.NotifColor, Thickness = 2}):Play()
                            task.delay(0.2, function()
                                TweenService:Create(ui.Stroke, TweenInfo.new(0.3), {Transparency = 0.3, Color = Theme.StrokeColor, Thickness = 1.2}):Play()
                            end)
                        end
                    end)
                end
            end
        end
    end)
    
    print("✅ Vyper Monitor + Notification Tracker Started!")
end

function Monitor:Stop()
    CleanupExisting()
    print("🛑 Performance Monitor Stopped")
end

return Monitor
