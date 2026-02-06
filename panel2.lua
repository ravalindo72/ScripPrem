-- =========================================================
-- VYPER PERFORMANCE MONITOR - PROFESSIONAL EDITION
-- =========================================================
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local Monitor = {}
local guiInstance = nil
local renderConnection = nil
local heartbeatConnection = nil

-- =========================================================
-- THEME & RESPONSIVE SYSTEM
-- =========================================================

local Theme = {
    Colors = {
        Background = Color3.fromRGB(10, 10, 15),
        Stroke = Color3.fromRGB(170, 0, 255), -- Neon Purple
        TextPrimary = Color3.fromRGB(240, 240, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        Accent = Color3.fromRGB(140, 80, 255),
        
        Good = Color3.fromRGB(0, 255, 128),  -- Green
        Warn = Color3.fromRGB(255, 200, 0),  -- Yellow
        Bad = Color3.fromRGB(255, 50, 80),   -- Red
    },
    Sizes = {
        BaseHeight = 46,
        BaseWidth = 320,
        CornerRadius = 10,
        FontSizeBig = 18,
        FontSizeSmall = 10,
        Padding = 12
    }
}

-- Responsive Helper
local function GetResponsiveScale()
    if not Camera then Camera = Workspace.CurrentCamera end
    local viewport = Camera.ViewportSize
    
    -- Base scale on 1920x1080, but adapt significantly for mobile
    if viewport.X < 800 then -- Mobile
        return math.clamp(viewport.X / 500, 0.7, 1.1) 
    elseif viewport.X < 1200 then -- Tablet
        return 0.9
    else -- Desktop
        return 1.0
    end
end

-- =========================================================
-- UI CONSTRUCTION
-- =========================================================

local function CreatePanel()
    if guiInstance then return guiInstance end
    
    local scale = GetResponsiveScale()
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VyperStatsX_Pro"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 100
    ScreenGui.Parent = PlayerGui
    
    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, Theme.Sizes.BaseWidth * scale, 0, Theme.Sizes.BaseHeight * scale)
    MainFrame.Position = UDim2.new(0.5, -(Theme.Sizes.BaseWidth * scale)/2, 0.05, 0) -- Top Center
    MainFrame.BackgroundColor3 = Theme.Colors.Background
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Aesthetic: Gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Colors.Background),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 30))
    }
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    -- Aesthetic: Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Theme.Sizes.CornerRadius * scale)
    Corner.Parent = MainFrame
    
    -- Aesthetic: Stroke (Neon Glow Effect)
    local Stroke = Instance.new("UIStroke")
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Color = Theme.Colors.Stroke
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.4
    Stroke.Parent = MainFrame
    
    -- Layout
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = MainFrame
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5 * scale)
    
    -- Helper: Create Stat Item
    local function MakeStat(id, label, icon)
        local Item = Instance.new("Frame")
        Item.Name = id
        Item.BackgroundTransparency = 1
        Item.Size = UDim2.new(0.3, 0, 1, 0) -- Divide into 3 distinct sections
        Item.Parent = MainFrame
        
        local Val = Instance.new("TextLabel")
        Val.Name = "Value"
        Val.Parent = Item
        Val.BackgroundTransparency = 1
        Val.Size = UDim2.new(1, 0, 0.6, 0)
        Val.Position = UDim2.new(0, 0, 0.15, 0)
        Val.Font = Enum.Font.GothamBold
        Val.Text = "--"
        Val.TextColor3 = Theme.Colors.TextPrimary
        Val.TextSize = Theme.Sizes.FontSizeBig * scale
        Val.RichText = true
        Val.TextXAlignment = Enum.TextXAlignment.Center
        
        local Title = Instance.new("TextLabel")
        Title.Name = "Label"
        Title.Parent = Item
        Title.BackgroundTransparency = 1
        Title.Size = UDim2.new(1, 0, 0.3, 0)
        Title.Position = UDim2.new(0, 0, 0.7, 0)
        Title.Font = Enum.Font.GothamMedium
        Title.Text = label
        Title.TextColor3 = Theme.Colors.TextSecondary
        Title.TextSize = Theme.Sizes.FontSizeSmall * scale
        Title.TextTransparency = 0.4
        Title.TextXAlignment = Enum.TextXAlignment.Center
        
        return Val
    end
    
    -- Vertical Separator
    local function MakeSep()
        local Sep = Instance.new("Frame")
        Sep.Size = UDim2.new(0, 1, 0.5, 0)
        Sep.BackgroundColor3 = Theme.Colors.TextSecondary
        Sep.BackgroundTransparency = 0.8
        Sep.BorderSizePixel = 0
        Sep.Parent = MainFrame
    end
    
    local FPSVal = MakeStat("FPS", "FPS")
    MakeSep()
    local PingVal = MakeStat("Ping", "LATENCY")
    MakeSep()
    local CPUVal = MakeStat("CPU", "CPU LOAD")
    
    -- =========================================================
    -- DRAGGABLE LOGIC V2 (Smoother)
    -- =========================================================
    local dragging = false
    local dragInput, dragStart, startPos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            -- Active Animation
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.2), {Transparency = 0, Thickness = 2}):Play()
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            -- Reset Animation
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0.4, Thickness = 1.5}):Play()
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
            
            -- Responsive clamping
            local viewport = Camera.ViewportSize
            local guiSize = MainFrame.AbsoluteSize
            
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            
            -- We just handle ScreenGui.IgnoreGuiInset by clamping safely
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                math.clamp(newX, -viewport.X/2 + guiSize.X/2, viewport.X/2 - guiSize.X/2), -- Simple clamping can be tricky with anchors. 
                -- Simplified Draggable:
                startPos.Y.Scale, 
                newY
            )
            -- A cleaner absolute position approach:
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return {
        Gui = ScreenGui,
        FPS = FPSVal,
        Ping = PingVal,
        CPU = CPUVal
    }
end

local function CleanupExisting()
    if renderConnection then renderConnection:Disconnect() renderConnection = nil end
    if heartbeatConnection then heartbeatConnection:Disconnect() heartbeatConnection = nil end
    
    if guiInstance and guiInstance.Gui then 
        guiInstance.Gui:Destroy() 
    end
    guiInstance = nil
    
    -- Cleanup potential leftovers
    if PlayerGui then
        for _, c in ipairs(PlayerGui:GetChildren()) do
            if c.Name == "VyperStatsX_Pro" or c.Name == "VyperStatsX" then
                c:Destroy()
            end
        end
    end
end

function Monitor:Start()
    CleanupExisting()
    
    local ui = CreatePanel()
    if not ui then return end
    
    -- =========================================================
    -- STATS UPDATER (Optimized)
    -- =========================================================
    local fpsAccumulator = 0
    local fpsCount = 0
    local fpsTimer = 0
    
    renderConnection = RunService.RenderStepped:Connect(function(dt)
        fpsAccumulator = fpsAccumulator + dt
        fpsCount = fpsCount + 1
        
        if fpsAccumulator >= 0.5 then
            local fps = math.floor(fpsCount / fpsAccumulator)
            local fpsColor = (fps >= 50 and Theme.Colors.Good) or (fps >= 30 and Theme.Colors.Warn) or Theme.Colors.Bad
            
            if ui.FPS then
                ui.FPS.Text = tostring(fps)
                ui.FPS.TextColor3 = fpsColor
            end
            
            fpsAccumulator = 0
            fpsCount = 0
        end
    end)
    
    local cpuSmooth = 0
    local lastUpdate = tick()
    
    heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
        if not ui.Gui or not ui.Gui.Parent then 
            CleanupExisting() 
            return 
        end
        
        -- Smooth CPU approximation
        local rawLoad = math.clamp((dt * 60 - 1) * 100, 0, 100) -- Rough load estimate based on frame lag
        -- Better method: 
        local s = Stats:GetValue()
        -- Roblox doesn't give direct total CPU, so we use frame time heuristics or script performance if available
        -- We'll stick to the simpler frame-time load used in V1 but smoothed
        local frameTimeLoad = math.clamp((dt / 0.01667) * 40, 0, 100)
        cpuSmooth = (cpuSmooth * 0.9) + (frameTimeLoad * 0.1)
        
        local now = tick()
        if now - lastUpdate >= 0.5 then
             -- Update CPU
            local displayLoad = math.floor(cpuSmooth)
            local cpuColor = (displayLoad < 60 and Theme.Colors.Good) or (displayLoad < 85 and Theme.Colors.Warn) or Theme.Colors.Bad
            
            if ui.CPU then
                ui.CPU.Text = tostring(displayLoad) .. "<font size='10'>%</font>"
                ui.CPU.TextColor3 = cpuColor
            end
            
            -- Update Ping
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            if ping <= 0 then 
                ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) 
            end
            
            local pingColor = (ping < 100 and Theme.Colors.Good) or (ping < 250 and Theme.Colors.Warn) or Theme.Colors.Bad
            
            if ui.Ping then
                ui.Ping.Text = tostring(ping) .. "<font size='10'>ms</font>"
                ui.Ping.TextColor3 = pingColor
            end
            
            lastUpdate = now
        end
    end)
end

function Monitor:Stop()
    CleanupExisting()
end

return Monitor
