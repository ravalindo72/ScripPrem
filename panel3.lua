-- =========================================================
-- VYPER PERFORMANCE MONITOR (SPLIT INTO 2 SEPARATE PANELS)
-- =========================================================
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local Monitor = {}

-- Separate instances for each panel
local perfPanel = nil
local notifPanel = nil

-- Separate connections
local renderConnection = nil
local heartbeatConnection = nil
local notifConnection = nil

-- Configuration & Theme
local Theme = {
    BgColor = Color3.fromRGB(15, 15, 20),
    StrokeColor = Color3.fromRGB(150, 0, 255),
    NotifStrokeColor = Color3.fromRGB(0, 255, 128), -- HIJAU!
    TextColor = Color3.fromRGB(255, 255, 255),
    SubTextColor = Color3.fromRGB(180, 180, 180),
    Good = Color3.fromRGB(0, 255, 128),
    Warn = Color3.fromRGB(255, 200, 0),
    Bad = Color3.fromRGB(255, 50, 80),
    NotifColor = Color3.fromRGB(0, 255, 128), -- HIJAU!
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

-- Helper: Make Draggable
local function MakeDraggable(frame, stroke)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
            TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play()
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0.3}):Play()
            TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- =========================================================
-- PERFORMANCE PANEL (FPS, Ping, CPU)
-- =========================================================
local function CreatePerformancePanel()
    if perfPanel then return perfPanel end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VyperPerformance"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 45)
    MainFrame.Position = UDim2.new(0.5, -140, 0, 10)
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
    
    MakeDraggable(MainFrame, Stroke)
    
    return {
        Gui = ScreenGui,
        FPS = FPSVal,
        Ping = PingVal,
        CPU = CPUVal,
        Frame = MainFrame,
        Stroke = Stroke
    }
end

-- =========================================================
-- NOTIFICATION PANEL (HIJAU!)
-- =========================================================
local function CreateNotificationPanel()
    if notifPanel then return notifPanel end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VyperNotifications"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 100, 0, 45)
    MainFrame.Position = UDim2.new(0.5, -50, 0, 65) -- Bawah dikit dari performance panel
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
    Stroke.Color = Theme.NotifStrokeColor -- HIJAU!
    Stroke.Thickness = 1.2
    Stroke.Transparency = 0.3
    Stroke.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = MainFrame
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 12)
    
    local Container = Instance.new("Frame")
    Container.Name = "Notif"
    Container.BackgroundTransparency = 1
    Container.Size = UDim2.new(1, -20, 1, 0)
    Container.Parent = MainFrame
    
    local Val = Instance.new("TextLabel")
    Val.Name = "Value"
    Val.Parent = Container
    Val.BackgroundTransparency = 1
    Val.Size = UDim2.new(1, 0, 0, 20)
    Val.Position = UDim2.new(0, 0, 0.5, -10)
    Val.Font = Theme.Font
    Val.Text = "--"
    Val.TextColor3 = Theme.NotifColor -- HIJAU!
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
    Lab.Text = "NOTIFS"
    Lab.TextColor3 = Theme.SubTextColor
    Lab.TextSize = 9
    Lab.TextXAlignment = Enum.TextXAlignment.Center
    
    MakeDraggable(MainFrame, Stroke)
    
    return {
        Gui = ScreenGui,
        Notif = Val,
        Frame = MainFrame,
        Stroke = Stroke
    }
end

-- =========================================================
-- CLEANUP FUNCTIONS
-- =========================================================
local function CleanupPerformance()
    if renderConnection then renderConnection:Disconnect() renderConnection = nil end
    if heartbeatConnection then heartbeatConnection:Disconnect() heartbeatConnection = nil end
    
    if perfPanel and perfPanel.Gui then 
        perfPanel.Gui:Destroy() 
    end
    perfPanel = nil
    
    if PlayerGui then
        for _, c in ipairs(PlayerGui:GetChildren()) do
            if c.Name == "VyperPerformance" then
                c:Destroy()
            end
        end
    end
end

local function CleanupNotifications()
    if notifConnection then notifConnection:Disconnect() notifConnection = nil end
    
    if notifPanel and notifPanel.Gui then 
        notifPanel.Gui:Destroy() 
    end
    notifPanel = nil
    
    if PlayerGui then
        for _, c in ipairs(PlayerGui:GetChildren()) do
            if c.Name == "VyperNotifications" then
                c:Destroy()
            end
        end
    end
end

-- =========================================================
-- PUBLIC FUNCTIONS: PERFORMANCE PANEL
-- =========================================================
function Monitor:StartPerformance()
    CleanupPerformance()
    
    local ui = CreatePerformancePanel()
    if not ui then return end
    ui.Gui.Enabled = true
    
    local fpsAccumulator = 0
    
    -- FPS Update
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
    
    -- Ping & CPU Update
    local lastUpdate = tick()
    local cpuSmooth = 0
    
    heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
        if not ui.Gui or not ui.Gui.Parent then 
            CleanupPerformance()
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
            
            lastUpdate = now
        end
    end)
    
    print("✅ Vyper Performance Panel Started!")
end

function Monitor:StopPerformance()
    CleanupPerformance()
    print("🛑 Performance Panel Stopped")
end

-- =========================================================
-- PUBLIC FUNCTIONS: NOTIFICATION PANEL
-- =========================================================
function Monitor:StartNotifications()
    CleanupNotifications()
    
    local ui = CreateNotificationPanel()
    if not ui then return end
    ui.Gui.Enabled = true
    
    local lastNotifCount = 0
    local updateConnection
    
    -- Update notification count
    updateConnection = RunService.Heartbeat:Connect(function()
        if not ui.Gui or not ui.Gui.Parent then 
            if updateConnection then updateConnection:Disconnect() end
            CleanupNotifications()
            return 
        end
        
        local totalNotifs, activeNotifs = getNotificationCount()
        if ui.Notif then
            ui.Notif.Text = tostring(totalNotifs) .. "<font size='10'>/" .. tostring(activeNotifs) .. "</font>"
            ui.Notif.TextColor3 = Theme.NotifColor
            
            -- Flash effect on new notification (HIJAU!)
            if totalNotifs > lastNotifCount then
                TweenService:Create(ui.Frame, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
                TweenService:Create(ui.Stroke, TweenInfo.new(0.15), {Transparency = 0, Color = Theme.NotifColor}):Play()
                
                task.delay(0.15, function()
                    TweenService:Create(ui.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
                    TweenService:Create(ui.Stroke, TweenInfo.new(0.3), {Transparency = 0.3, Color = Theme.NotifStrokeColor}):Play()
                end)
                
                lastNotifCount = totalNotifs
            end
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
                            -- Instant flash on new notification detected (HIJAU!)
                            TweenService:Create(ui.Stroke, TweenInfo.new(0.1), {Transparency = 0, Color = Theme.NotifColor, Thickness = 2}):Play()
                            task.delay(0.2, function()
                                TweenService:Create(ui.Stroke, TweenInfo.new(0.3), {Transparency = 0.3, Color = Theme.NotifStrokeColor, Thickness = 1.2}):Play()
                            end)
                        end
                    end)
                end
            end
        end
    end)
    
    print("✅ Vyper Notification Tracker Started! (HIJAU!)")
end

function Monitor:StopNotifications()
    CleanupNotifications()
    print("🛑 Notification Tracker Stopped")
end

-- Legacy compatibility
function Monitor:Start()
    self:StartPerformance()
    self:StartNotifications()
end

function Monitor:Stop()
    self:StopPerformance()
    self:StopNotifications()
end

return Monitor
