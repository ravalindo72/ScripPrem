-- =========================================================
-- VYPER PERFORMANCE MONITOR PRO + NOTIFICATION TRACKER
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

-- Configuration & Design System
local Theme = {
    Background = Color3.fromRGB(10, 10, 14), -- Deep modern dark
    Accent = Color3.fromRGB(138, 43, 226),   -- Electric Purple
    SecondaryAccent = Color3.fromRGB(0, 255, 200), -- Cyan for highlights
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 170),
    Good = Color3.fromRGB(46, 204, 113),
    Warn = Color3.fromRGB(241, 196, 15),
    Bad = Color3.fromRGB(231, 76, 60),
    CornerRadius = UDim.new(0, 10),
    FontMain = Enum.Font.GothamBold,
    FontSub = Enum.Font.GothamMedium
}

-- Icons (Text-based for compatibility)
local Icons = {
    FPS = "⚡",
    Ping = "📶",
    CPU = "🖥️",
    Notif = "🔔"
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

-- Helper: Create UI
local function CreatePanel()
    if guiInstance then return guiInstance end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VyperStatsPro"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 420, 0, 55) -- Slightly larger for "Professional" feel
    MainFrame.Position = UDim2.new(0.5, -210, 0, 15)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Aesthetic: Glassy Gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Background),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 28))
    }
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    -- Aesthetic: Rounded Corners
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Theme.CornerRadius
    Corner.Parent = MainFrame
    
    -- Aesthetic: Glowing Border
    local Stroke = Instance.new("UIStroke")
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Color = Theme.Accent
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.4
    Stroke.Parent = MainFrame
    
    -- Aesthetic: Soft Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015897843" -- Soft shadow asset
    Shadow.ImageColor3 = Color3.new(0,0,0)
    Shadow.ImageTransparency = 0.4
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    
    -- Layout
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = MainFrame
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 15) -- Spacious padding
    
    -- Helper to create stat modules
    local function CreateStatModule(id, icon, labelText)
        local Container = Instance.new("Frame")
        Container.Name = id
        Container.Size = UDim2.new(0, 90, 0, 40)
        Container.BackgroundTransparency = 1
        Container.Parent = MainFrame
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = Container
        ContentLayout.FillDirection = Enum.FillDirection.Vertical
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        ContentLayout.Padding = UDim.new(0, 2)
        
        local Value = Instance.new("TextLabel")
        Value.Name = "Value"
        Value.Parent = Container
        Value.BackgroundTransparency = 1
        Value.Size = UDim2.new(1, 0, 0, 22)
        Value.Font = Theme.FontMain
        Value.Text = "--"
        Value.TextColor3 = Theme.TextPrimary
        Value.TextSize = 18
        Value.RichText = true
        
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Parent = Container
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 14)
        Label.Font = Theme.FontSub
        Label.Text = icon .. " " .. labelText
        Label.TextColor3 = Theme.TextSecondary
        Label.TextSize = 11
        Label.RichText = true
        
        return Value
    end
    
    local Separator = function()
        local S = Instance.new("Frame")
        S.Size = UDim2.new(0, 1, 0, 25)
        S.BackgroundColor3 = Theme.TextSecondary
        S.BackgroundTransparency = 0.8
        S.Parent = MainFrame
        return S
    end

    local FPSVal = CreateStatModule("FPS", Icons.FPS, "FPS")
    Separator()
    local PingVal = CreateStatModule("Ping", Icons.Ping, "PING")
    Separator()
    local CPUVal = CreateStatModule("CPU", Icons.CPU, "CPU")
    Separator()
    local NotifVal = CreateStatModule("Notif", Icons.Notif, "ALERTS")
    
    -- =========================================================
    -- INTERACTIVITY (Responsive Feel)
    -- =========================================================
    
    -- 1. Hover Glow Effect
    MainFrame.MouseEnter:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0, Color = Theme.SecondaryAccent}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.05}):Play()
    end)
    
    MainFrame.MouseLeave:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0.4, Color = Theme.Accent}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    end)
    
    -- 2. Draggable Logic
    local dragging, dragInput, dragStart, startPos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            -- Pick up effect
            TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 430, 0, 60)}):Play()
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            -- Drop effect
            TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 420, 0, 55)}):Play()
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
            -- Smooth drag with Lerp (simulated via rapid direct updates, but Back stylistic easing on pick up makes it feel smooth)
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
    
    -- Deep cleanup
    if PlayerGui then
        for _, c in ipairs(PlayerGui:GetChildren()) do
            if c.Name == "VyperStatsPro" or c.Name == "VyperStatsX" then
                c:Destroy()
            end
        end
    end
end

-- =========================================================
-- LOGIC
-- =========================================================

function Monitor:Start()
    CleanupExisting()
    
    local ui = CreatePanel()
    if not ui then return end
    ui.Gui.Enabled = true
    
    local fpsAccumulator = 0
    local lastNotifCount = 0
    
    -- FPS Loop (Responsive Update)
    renderConnection = RunService.RenderStepped:Connect(function(dt)
        fpsAccumulator = fpsAccumulator + dt
        if fpsAccumulator >= 0.25 then -- Faster update rate (0.25s) for responsiveness
            local fps = math.floor(1 / dt)
            local fpsColor = (fps >= 55 and Theme.Good) or (fps >= 30 and Theme.Warn) or Theme.Bad
            
            if ui.FPS then 
                ui.FPS.Text = tostring(fps)
                ui.FPS.TextColor3 = fpsColor
            end
            fpsAccumulator = 0
        end
    end)
    
    -- Stats Loop (CPU, Ping, Notifs)
    local lastUpdate = tick()
    local cpuSmooth = 0
    
    heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
        if not ui.Gui or not ui.Gui.Parent then 
            CleanupExisting()
            return 
        end
        
        local rawLoad = math.clamp((dt / 0.01667) * 35, 0, 100)
        cpuSmooth = (cpuSmooth * 0.9) + (rawLoad * 0.1) -- Smoother lerp
        
        local now = tick()
        if now - lastUpdate >= 0.5 then
            -- CPU
            local displayLoad = math.floor(cpuSmooth)
            local cpuColor = (displayLoad < 50 and Theme.Good) or (displayLoad < 80 and Theme.Warn) or Theme.Bad
            if ui.CPU then
                ui.CPU.Text = tostring(displayLoad) .. "<font size='12'>%</font>"
                ui.CPU.TextColor3 = cpuColor
            end
            
            -- Ping
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            if ping <= 0 then ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end
            local pingColor = (ping < 100 and Theme.Good) or (ping < 200 and Theme.Warn) or Theme.Bad
            if ui.Ping then
                ui.Ping.Text = tostring(ping) .. "<font size='12'>ms</font>"
                ui.Ping.TextColor3 = pingColor
            end
            
            -- Notifications
            local totalNotifs, activeNotifs = getNotificationCount()
            if ui.Notif then
                ui.Notif.Text = tostring(totalNotifs) .. "<font size='12' color='#AAAAAA'> / " .. tostring(activeNotifs) .. "</font>"
                ui.Notif.TextColor3 = (activeNotifs > 0 and Theme.Accent) or Theme.TextPrimary
                
                -- Check for new notifs
                if totalNotifs > lastNotifCount then
                    -- Pulse Effect
                    local pulse = TweenService:Create(ui.Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Color = Theme.SecondaryAccent, Thickness = 2.5})
                    pulse:Play()
                    pulse.Completed:Connect(function()
                        TweenService:Create(ui.Stroke, TweenInfo.new(0.5), {Color = Theme.Accent, Thickness = 1.5}):Play()
                    end)
                    lastNotifCount = totalNotifs
                end
            end
            
            lastUpdate = now
        end
    end)
    
    -- Instant Notification Watcher
    pcall(function()
        local playerGui = LocalPlayer.PlayerGui
        local textNotifications = playerGui:WaitForChild("Text Notifications", 3)
        if textNotifications then
            local frame = textNotifications:WaitForChild("Frame", 3)
            if frame then
                notifConnection = frame.ChildAdded:Connect(function(child)
                    if child.Name == "Tile" then
                        -- Immediate Visual Feedback
                        if ui.Stroke then
                            TweenService:Create(ui.Stroke, TweenInfo.new(0.1), {Color = Theme.SecondaryAccent, Transparency = 0}):Play()
                        end
                    end
                end)
            end
        end
    end)
    
    print("✨ Vyper Pro Panel: Started")
end

function Monitor:Stop()
    CleanupExisting()
    print("� Vyper Pro Panel: Stopped")
end

return Monitor
