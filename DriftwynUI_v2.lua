--[[
    DRIFTWYN UI LIBRARY v2.1 - ROUND MINIMIZE FIX
    Red / Black / Metallic Roblox UI library

    ADDED IN V2:
      • Two-column sections
      • Color picker
      • Search bar
      • Config save/load/export/import
      • Theme presets + runtime theme switching
      • Tab icon image assets
      • Blur/acrylic-like background
      • Better mobile/touch support
      • Notification center with history
      • Existing: buttons, toggles, sliders, dropdowns, multidropdowns,
                  labels, paragraphs, textboxes, keybinds, dividers, tabs, sections

    This module returns DriftwynUI.
]]

local DriftwynUI = {}
DriftwynUI.__index = DriftwynUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui"))

--==================================================
-- THEME PRESETS
--==================================================

local THEME_PRESETS = {
    Driftwyn = {
        Background = Color3.fromRGB(5, 5, 6),
        Background2 = Color3.fromRGB(10, 10, 12),
        Panel = Color3.fromRGB(12, 12, 14),
        Panel2 = Color3.fromRGB(17, 17, 20),
        Panel3 = Color3.fromRGB(22, 22, 25),
        Accent = Color3.fromRGB(220, 18, 32),
        Accent2 = Color3.fromRGB(145, 6, 14),
        Accent3 = Color3.fromRGB(85, 2, 7),
        Text = Color3.fromRGB(238, 238, 242),
        TextMuted = Color3.fromRGB(155, 155, 165),
        TextDark = Color3.fromRGB(105, 105, 115),
        Stroke = Color3.fromRGB(75, 75, 82),
        StrokeDark = Color3.fromRGB(40, 40, 45),
        Success = Color3.fromRGB(72, 210, 105),
        Warning = Color3.fromRGB(235, 190, 55),
    },

    Blood = {
        Background = Color3.fromRGB(4, 3, 4),
        Background2 = Color3.fromRGB(12, 6, 7),
        Panel = Color3.fromRGB(15, 8, 9),
        Panel2 = Color3.fromRGB(22, 10, 12),
        Panel3 = Color3.fromRGB(30, 12, 15),
        Accent = Color3.fromRGB(245, 25, 35),
        Accent2 = Color3.fromRGB(175, 5, 14),
        Accent3 = Color3.fromRGB(95, 0, 6),
        Text = Color3.fromRGB(245, 241, 242),
        TextMuted = Color3.fromRGB(176, 145, 150),
        TextDark = Color3.fromRGB(118, 90, 95),
        Stroke = Color3.fromRGB(95, 52, 58),
        StrokeDark = Color3.fromRGB(52, 25, 30),
        Success = Color3.fromRGB(78, 220, 110),
        Warning = Color3.fromRGB(245, 192, 70),
    },

    Carbon = {
        Background = Color3.fromRGB(4, 4, 5),
        Background2 = Color3.fromRGB(9, 9, 10),
        Panel = Color3.fromRGB(14, 14, 15),
        Panel2 = Color3.fromRGB(20, 20, 22),
        Panel3 = Color3.fromRGB(28, 28, 31),
        Accent = Color3.fromRGB(205, 25, 38),
        Accent2 = Color3.fromRGB(125, 16, 25),
        Accent3 = Color3.fromRGB(68, 8, 13),
        Text = Color3.fromRGB(232, 232, 235),
        TextMuted = Color3.fromRGB(145, 145, 152),
        TextDark = Color3.fromRGB(95, 95, 104),
        Stroke = Color3.fromRGB(68, 68, 75),
        StrokeDark = Color3.fromRGB(38, 38, 43),
        Success = Color3.fromRGB(70, 205, 105),
        Warning = Color3.fromRGB(230, 180, 60),
    },
}

local FONT = {
    Regular = Enum.Font.Gotham,
    Medium = Enum.Font.GothamMedium,
    Bold = Enum.Font.GothamBold,
    Black = Enum.Font.GothamBlack,
}

--==================================================
-- HELPERS
--==================================================

local function New(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local function Corner(parent, radius)
    return New("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, parent)
end

local function Gradient(parent, c1, c2, rotation)
    return New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2)
        }),
        Rotation = rotation or 90
    }, parent)
end

local function Tween(obj, duration, props, style, direction)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.16,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out
        ),
        props
    )
    tw:Play()
    return tw
end

local function SafeCall(callback, ...)
    if typeof(callback) ~= "function" then return end
    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[DriftwynUI] Callback error:", err)
    end
end

local function Clamp(n, min, max)
    return math.max(min, math.min(max, n))
end

local function Round(n, decimals)
    decimals = decimals or 0
    local p = 10 ^ decimals
    return math.floor(n * p + 0.5) / p
end

local function CloneTable(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            out[k] = CloneTable(v)
        else
            out[k] = v
        end
    end
    return out
end

local function ColorToTable(c)
    return {
        R = math.floor(c.R * 255 + 0.5),
        G = math.floor(c.G * 255 + 0.5),
        B = math.floor(c.B * 255 + 0.5)
    }
end

local function TableToColor(t)
    if type(t) ~= "table" then return nil end
    return Color3.fromRGB(
        tonumber(t.R) or 255,
        tonumber(t.G) or 255,
        tonumber(t.B) or 255
    )
end

local function SetCanvas(scroll, layout, extra)
    local function update()
        scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + (extra or 16))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragStart
    local startPos
    local activeInput

    handle.Active = true

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            activeInput = input
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            activeInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == activeInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == activeInput then
            dragging = false
        end
    end)
end

local function Contains(haystack, needle)
    haystack = string.lower(tostring(haystack or ""))
    needle = string.lower(tostring(needle or ""))
    return string.find(haystack, needle, 1, true) ~= nil
end

--==================================================
-- LIBRARY
--==================================================

function DriftwynUI:GetThemes()
    local names = {}
    for name in pairs(THEME_PRESETS) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function DriftwynUI:CreateWindow(options)
    options = options or {}

    local Window = {
        Destroyed = false,
        Tabs = {},
        ActiveTab = nil,
        Registry = {},
        Notifications = {},
        ThemeName = options.Theme or "Driftwyn",
        Theme = CloneTable(THEME_PRESETS[options.Theme or "Driftwyn"] or THEME_PRESETS.Driftwyn),
        SearchEntries = {},
    }

    local T = Window.Theme

    local gui = New("ScreenGui", {
        Name = options.Name or "DriftwynUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = options.DisplayOrder or 50,
    }, PlayerGui)

    local overlay = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.38,
        BorderSizePixel = 0,
        ZIndex = 0,
    }, gui)

    -- Blur / acrylic-like effect
    local blur
    if options.Blur ~= false then
        blur = Lighting:FindFirstChild("DriftwynUI_Blur")
        if blur then
            blur:Destroy()
        end

        blur = New("BlurEffect", {
            Name = "DriftwynUI_Blur",
            Size = options.BlurSize or 14,
            Enabled = true
        }, Lighting)
    end

    local main = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = options.Size or UDim2.fromOffset(980, 640),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    }, gui)

    Corner(main, 14)
    local mainStroke = Stroke(main, T.Accent, 1.5, 0.05)
    local mainGradient = Gradient(main, T.Background2, T.Background, 90)

    local scale = New("UIScale", {Scale = 1}, main)

    local function updateScale()
        local camera = workspace.CurrentCamera
        if not camera then return end

        local vp = camera.ViewportSize
        local sx = vp.X / 1120
        local sy = vp.Y / 780
        local result = math.min(sx, sy)

        if UserInputService.TouchEnabled then
            result = result * 0.96
        end

        scale.Scale = Clamp(result, 0.52, 1)
    end

    updateScale()

    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
    end

    --==================================================
    -- HEADER
    --==================================================

    local header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 76),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, main)

    local headerGradient = Gradient(header, Color3.fromRGB(28, 5, 8), T.Panel, 0)

    local topLine = New("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, header)

    local brandIcon = New("Frame", {
        Position = UDim2.fromOffset(18, 15),
        Size = UDim2.fromOffset(46, 46),
        BackgroundColor3 = T.Accent3,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, header)
    Corner(brandIcon, 8)
    local brandStroke = Stroke(brandIcon, T.Accent, 1, 0.1)

    local brandIconText = New("TextLabel", {
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Text = options.IconText or "DH",
        Font = FONT.Black,
        TextSize = 18,
        TextColor3 = T.Text,
        ZIndex = 6,
    }, brandIcon)

    local title = New("TextLabel", {
        Position = UDim2.fromOffset(78, 11),
        Size = UDim2.new(1, -310, 0, 29),
        BackgroundTransparency = 1,
        Text = options.Title or "DRIFTWYN HUB",
        Font = FONT.Black,
        TextSize = 21,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, header)

    local subtitle = New("TextLabel", {
        Position = UDim2.fromOffset(78, 40),
        Size = UDim2.new(1, -310, 0, 20),
        BackgroundTransparency = 1,
        Text = options.Subtitle or "RED / BLACK INTERFACE",
        Font = FONT.Regular,
        TextSize = 12,
        TextColor3 = T.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, header)

    -- Search
    local searchHolder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -146, 0, 18),
        Size = UDim2.fromOffset(205, 38),
        BackgroundColor3 = T.Background2,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, header)
    Corner(searchHolder, 8)
    local searchStroke = Stroke(searchHolder, T.Stroke, 1, 0.35)

    local searchIcon = New("TextLabel", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.fromOffset(25, 38),
        BackgroundTransparency = 1,
        Text = "⌕",
        Font = FONT.Bold,
        TextSize = 17,
        TextColor3 = T.TextMuted,
        ZIndex = 7,
    }, searchHolder)

    local searchBox = New("TextBox", {
        Position = UDim2.fromOffset(35, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search controls...",
        PlaceholderColor3 = T.TextDark,
        ClearTextOnFocus = false,
        Font = FONT.Regular,
        TextSize = 12,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
    }, searchHolder)

    -- Notification center
    local bell = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -100, 0, 18),
        Size = UDim2.fromOffset(38, 38),
        BackgroundColor3 = T.Panel2,
        BorderSizePixel = 0,
        Text = "●",
        Font = FONT.Bold,
        TextSize = 13,
        TextColor3 = T.Accent,
        AutoButtonColor = false,
        ZIndex = 7,
    }, header)
    Corner(bell, 8)
    local bellStroke = Stroke(bell, T.Stroke, 1, 0.4)

    local notificationBadge = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 5, 0, -5),
        Size = UDim2.fromOffset(19, 19),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Text = "0",
        Font = FONT.Bold,
        TextSize = 10,
        TextColor3 = Color3.new(1,1,1),
        Visible = false,
        ZIndex = 9,
    }, bell)
    Corner(notificationBadge, 999)

    local minimize = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -56, 0, 18),
        Size = UDim2.fromOffset(34, 38),
        BackgroundColor3 = T.Panel2,
        BorderSizePixel = 0,
        Text = "–",
        Font = FONT.Bold,
        TextSize = 20,
        TextColor3 = T.TextMuted,
        AutoButtonColor = false,
        ZIndex = 7,
    }, header)
    Corner(minimize, 8)
    local minStroke = Stroke(minimize, T.Stroke, 1, 0.4)

    local close = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 18),
        Size = UDim2.fromOffset(34, 38),
        BackgroundColor3 = T.Accent3,
        BorderSizePixel = 0,
        Text = "×",
        Font = FONT.Bold,
        TextSize = 22,
        TextColor3 = T.Accent,
        AutoButtonColor = false,
        ZIndex = 7,
    }, header)
    Corner(close, 8)
    local closeStroke = Stroke(close, T.Accent, 1, 0.25)

    --==================================================
    -- BODY / SIDEBAR
    --==================================================

    local sidebar = New("Frame", {
        Position = UDim2.fromOffset(0, 76),
        Size = UDim2.new(0, 210, 1, -76),
        BackgroundColor3 = T.Background2,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, main)

    local sidebarSeparator = New("Frame", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,0,0,0),
        Size = UDim2.new(0,1,1,0),
        BackgroundColor3 = T.Accent3,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, sidebar)

    local tabScroll = New("ScrollingFrame", {
        Position = UDim2.fromOffset(12, 14),
        Size = UDim2.new(1, -24, 1, -28),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.fromOffset(0,0),
        ZIndex = 4,
    }, sidebar)

    local tabLayout = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabScroll)

    SetCanvas(tabScroll, tabLayout, 12)

    local content = New("Frame", {
        Position = UDim2.fromOffset(210, 76),
        Size = UDim2.new(1, -210, 1, -76),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, main)

    local pageTitle = New("TextLabel", {
        Position = UDim2.fromOffset(20, 12),
        Size = UDim2.new(1, -40, 0, 28),
        BackgroundTransparency = 1,
        Text = "Home",
        Font = FONT.Black,
        TextSize = 21,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, content)

    local pageSubtitle = New("TextLabel", {
        Position = UDim2.fromOffset(20, 40),
        Size = UDim2.new(1, -40, 0, 20),
        BackgroundTransparency = 1,
        Text = "Choose a tab.",
        Font = FONT.Regular,
        TextSize = 12,
        TextColor3 = T.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, content)

    local pages = New("Frame", {
        Position = UDim2.fromOffset(16, 70),
        Size = UDim2.new(1, -32, 1, -86),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 4,
    }, content)

    --==================================================
    -- NOTIFICATION CENTER PANEL
    --==================================================

    local notificationPanel = New("Frame", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1, -100, 0, 62),
        Size = UDim2.fromOffset(340, 390),
        BackgroundColor3 = T.Panel,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 30,
    }, main)
    Corner(notificationPanel, 10)
    local notificationPanelStroke = Stroke(notificationPanel, T.Stroke, 1, 0.25)

    local npTitle = New("TextLabel", {
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -80, 0, 28),
        BackgroundTransparency = 1,
        Text = "NOTIFICATIONS",
        Font = FONT.Bold,
        TextSize = 14,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 31,
    }, notificationPanel)

    local clearNotifications = New("TextButton", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1, -10, 0, 8),
        Size = UDim2.fromOffset(58, 26),
        BackgroundColor3 = T.Accent3,
        BorderSizePixel = 0,
        Text = "CLEAR",
        Font = FONT.Bold,
        TextSize = 10,
        TextColor3 = T.Accent,
        AutoButtonColor = false,
        ZIndex = 31,
    }, notificationPanel)
    Corner(clearNotifications, 6)

    local notificationScroll = New("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 44),
        Size = UDim2.new(1, -20, 1, -54),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.fromOffset(0,0),
        ZIndex = 31,
    }, notificationPanel)

    local notificationLayout = New("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, notificationScroll)

    SetCanvas(notificationScroll, notificationLayout, 12)

    local panelOpen = false
    local unread = 0

    local function updateBadge()
        notificationBadge.Visible = unread > 0
        notificationBadge.Text = tostring(math.min(unread, 99))
    end

    bell.MouseButton1Click:Connect(function()
        panelOpen = not panelOpen
        notificationPanel.Visible = panelOpen
        if panelOpen then
            unread = 0
            updateBadge()
        end
    end)

    clearNotifications.MouseButton1Click:Connect(function()
        Window.Notifications = {}
        for _, child in ipairs(notificationScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        unread = 0
        updateBadge()
    end)

    --==================================================
    -- WINDOW METHODS
    --==================================================

    local themeBindings = {}

    local function BindTheme(callback)
        table.insert(themeBindings, callback)
    end

    function Window:SetTheme(name)
        if not THEME_PRESETS[name] then
            return false, "Unknown theme: " .. tostring(name)
        end

        Window.ThemeName = name
        Window.Theme = CloneTable(THEME_PRESETS[name])
        T = Window.Theme

        for _, callback in ipairs(themeBindings) do
            SafeCall(callback, T)
        end

        return true
    end

    function Window:GetTheme()
        return Window.ThemeName, CloneTable(Window.Theme)
    end

    function Window:GetThemes()
        return DriftwynUI:GetThemes()
    end

    BindTheme(function(theme)
        main.BackgroundColor3 = theme.Background
        mainStroke.Color = theme.Accent
        mainGradient.Color = ColorSequence.new(theme.Background2, theme.Background)

        header.BackgroundColor3 = theme.Panel
        headerGradient.Color = ColorSequence.new(Color3.fromRGB(28,5,8), theme.Panel)
        topLine.BackgroundColor3 = theme.Accent

        brandIcon.BackgroundColor3 = theme.Accent3
        brandStroke.Color = theme.Accent
        brandIconText.TextColor3 = theme.Text
        title.TextColor3 = theme.Text
        subtitle.TextColor3 = theme.TextMuted

        searchHolder.BackgroundColor3 = theme.Background2
        searchStroke.Color = theme.Stroke
        searchIcon.TextColor3 = theme.TextMuted
        searchBox.TextColor3 = theme.Text
        searchBox.PlaceholderColor3 = theme.TextDark

        bell.BackgroundColor3 = theme.Panel2
        bell.TextColor3 = theme.Accent
        bellStroke.Color = theme.Stroke
        notificationBadge.BackgroundColor3 = theme.Accent

        minimize.BackgroundColor3 = theme.Panel2
        minimize.TextColor3 = theme.TextMuted
        minStroke.Color = theme.Stroke

        close.BackgroundColor3 = theme.Accent3
        close.TextColor3 = theme.Accent
        closeStroke.Color = theme.Accent

        sidebar.BackgroundColor3 = theme.Background2
        sidebarSeparator.BackgroundColor3 = theme.Accent3
        tabScroll.ScrollBarImageColor3 = theme.Accent

        pageTitle.TextColor3 = theme.Text
        pageSubtitle.TextColor3 = theme.TextMuted

        notificationPanel.BackgroundColor3 = theme.Panel
        notificationPanelStroke.Color = theme.Stroke
        npTitle.TextColor3 = theme.Text
        clearNotifications.BackgroundColor3 = theme.Accent3
        clearNotifications.TextColor3 = theme.Accent
        notificationScroll.ScrollBarImageColor3 = theme.Accent
    end)

    function Window:SetTitle(newTitle, newSubtitle)
        title.Text = tostring(newTitle or "")
        if newSubtitle ~= nil then
            subtitle.Text = tostring(newSubtitle)
        end
    end

    function Window:SetVisible(state)
        gui.Enabled = state == true
    end

    function Window:Toggle()
        gui.Enabled = not gui.Enabled
    end

    function Window:Notify(data)
        data = data or {}

        local entry = {
            Title = data.Title or "Notification",
            Content = data.Content or "",
            Success = data.Success == true,
            Time = os.time(),
        }

        table.insert(Window.Notifications, 1, entry)
        unread += 1
        updateBadge()

        -- Notification history entry
        local history = New("Frame", {
            Size = UDim2.new(1, 0, 0, 72),
            BackgroundColor3 = T.Panel2,
            BorderSizePixel = 0,
            ZIndex = 32,
        }, notificationScroll)
        Corner(history, 7)
        Stroke(history, entry.Success and T.Success or T.Accent, 1, 0.2)

        local hTitle = New("TextLabel", {
            Position = UDim2.fromOffset(11, 6),
            Size = UDim2.new(1, -22, 0, 21),
            BackgroundTransparency = 1,
            Text = entry.Title,
            Font = FONT.Bold,
            TextSize = 12,
            TextColor3 = T.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 33,
        }, history)

        local hContent = New("TextLabel", {
            Position = UDim2.fromOffset(11, 28),
            Size = UDim2.new(1, -22, 0, 34),
            BackgroundTransparency = 1,
            Text = entry.Content,
            Font = FONT.Regular,
            TextSize = 11,
            TextColor3 = T.TextMuted,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 33,
        }, history)

        BindTheme(function(theme)
            if not history.Parent then return end
            history.BackgroundColor3 = theme.Panel2
            hTitle.TextColor3 = theme.Text
            hContent.TextColor3 = theme.TextMuted
        end)

        -- Toast
        local toast = New("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 355, 1, -18),
            Size = UDim2.fromOffset(330, 88),
            BackgroundColor3 = T.Panel2,
            BorderSizePixel = 0,
            ZIndex = 50,
        }, gui)
        Corner(toast, 9)
        Stroke(toast, entry.Success and T.Success or T.Accent, 1.2, 0.08)
        Gradient(toast, T.Panel2, T.Background2, 90)

        local accent = New("Frame", {
            Size = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = entry.Success and T.Success or T.Accent,
            BorderSizePixel = 0,
            ZIndex = 51,
        }, toast)

        local toastTitle = New("TextLabel", {
            Position = UDim2.fromOffset(16, 10),
            Size = UDim2.new(1, -28, 0, 22),
            BackgroundTransparency = 1,
            Text = entry.Title,
            Font = FONT.Bold,
            TextSize = 14,
            TextColor3 = T.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 51,
        }, toast)

        local toastContent = New("TextLabel", {
            Position = UDim2.fromOffset(16, 34),
            Size = UDim2.new(1, -28, 0, 40),
            BackgroundTransparency = 1,
            Text = entry.Content,
            Font = FONT.Regular,
            TextSize = 12,
            TextColor3 = T.TextMuted,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 51,
        }, toast)

        Tween(toast, 0.23, {
            Position = UDim2.new(1, -18, 1, -18)
        }, Enum.EasingStyle.Back)

        task.delay(data.Duration or 3, function()
            if toast and toast.Parent then
                Tween(toast, 0.18, {
                    Position = UDim2.new(1, 355, 1, -18),
                    BackgroundTransparency = 1
                })
                task.delay(0.2, function()
                    if toast then toast:Destroy() end
                end)
            end
        end)
    end

    function Window:RegisterFlag(flag, object)
        if not flag or flag == "" then return end
        Window.Registry[flag] = object
    end

    function Window:GetValue(flag)
        local object = Window.Registry[flag]
        if object and object.Get then
            return object:Get()
        end
        return nil
    end

    function Window:SetValue(flag, value)
        local object = Window.Registry[flag]
        if object and object.Set then
            object:Set(value)
            return true
        end
        return false
    end

    function Window:ExportConfig()
        local data = {
            Theme = Window.ThemeName,
            Values = {}
        }

        for flag, object in pairs(Window.Registry) do
            if object.Get then
                local ok, value = pcall(object.Get, object)
                if ok then
                    if typeof(value) == "Color3" then
                        value = {
                            __type = "Color3",
                            value = ColorToTable(value)
                        }
                    end
                    data.Values[flag] = value
                end
            end
        end

        return HttpService:JSONEncode(data)
    end

    function Window:ImportConfig(json)
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(json)
        end)

        if not ok or type(decoded) ~= "table" then
            return false, "Invalid config JSON"
        end

        if decoded.Theme and THEME_PRESETS[decoded.Theme] then
            Window:SetTheme(decoded.Theme)
        end

        for flag, value in pairs(decoded.Values or {}) do
            if type(value) == "table" and value.__type == "Color3" then
                value = TableToColor(value.value)
            end

            local object = Window.Registry[flag]
            if object and object.Set then
                pcall(function()
                    object:Set(value)
                end)
            end
        end

        return true
    end

    function Window:SaveConfig(name)
        name = tostring(name or "DriftwynConfig")
        local json = Window:ExportConfig()

        local write = rawget(_G, "writefile")
        if getgenv then
            local env = getgenv()
            write = rawget(env, "writefile") or write
        end

        if type(write) ~= "function" then
            return false, "writefile is unavailable. Use ExportConfig() instead."
        end

        local filename = name
        if not string.match(filename, "%.json$") then
            filename = filename .. ".json"
        end

        local ok, err = pcall(write, filename, json)
        return ok, err or filename
    end

    function Window:LoadConfig(name)
        name = tostring(name or "DriftwynConfig")

        local read = rawget(_G, "readfile")
        local isfileFn = rawget(_G, "isfile")

        if getgenv then
            local env = getgenv()
            read = rawget(env, "readfile") or read
            isfileFn = rawget(env, "isfile") or isfileFn
        end

        if type(read) ~= "function" then
            return false, "readfile is unavailable. Use ImportConfig(json) instead."
        end

        local filename = name
        if not string.match(filename, "%.json$") then
            filename = filename .. ".json"
        end

        if type(isfileFn) == "function" and not isfileFn(filename) then
            return false, "Config does not exist"
        end

        local ok, json = pcall(read, filename)
        if not ok then
            return false, json
        end

        return Window:ImportConfig(json)
    end

    function Window:Destroy()
        if Window.Destroyed then return end
        Window.Destroyed = true

        if blur and blur.Parent then
            blur:Destroy()
        end

        Tween(main, 0.16, {BackgroundTransparency = 1})
        Tween(overlay, 0.16, {BackgroundTransparency = 1})

        task.delay(0.18, function()
            if gui then gui:Destroy() end
        end)
    end

    --==================================================
    -- SEARCH
    --==================================================

    local function applySearch()
        local query = searchBox.Text

        for _, entry in ipairs(Window.SearchEntries) do
            local visible = query == ""
                or Contains(entry.Name, query)
                or Contains(entry.Description, query)
                or Contains(entry.Section, query)

            if entry.Object and entry.Object.Parent then
                entry.Object.Visible = visible
            end
        end
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

    --==================================================
    -- TAB
    --==================================================

    function Window:AddTab(data)
        data = data or {}

        local Tab = {
            Name = data.Name or "Tab",
            Description = data.Description or "",
            SearchEntries = {},
        }

        local tabButton = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundColor3 = T.Panel,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 5,
        }, tabScroll)
        Corner(tabButton, 8)
        local tabStroke = Stroke(tabButton, T.StrokeDark, 1, 0.2)

        local tabAccent = New("Frame", {
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.new(0,0,0.5,0),
            Size = UDim2.new(0,3,0.56,0),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 6,
        }, tabButton)

        local iconImage
        local iconText

        if data.IconImage and data.IconImage ~= "" then
            iconImage = New("ImageLabel", {
                Position = UDim2.fromOffset(13, 12),
                Size = UDim2.fromOffset(26, 26),
                BackgroundTransparency = 1,
                Image = data.IconImage,
                ImageColor3 = T.TextMuted,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 6,
            }, tabButton)
        else
            iconText = New("TextLabel", {
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.fromOffset(30, 50),
                BackgroundTransparency = 1,
                Text = data.Icon or "◆",
                Font = FONT.Bold,
                TextSize = 14,
                TextColor3 = T.TextMuted,
                ZIndex = 6,
            }, tabButton)
        end

        local tabName = New("TextLabel", {
            Position = UDim2.fromOffset(48, 0),
            Size = UDim2.new(1, -58, 1, 0),
            BackgroundTransparency = 1,
            Text = Tab.Name,
            Font = FONT.Medium,
            TextSize = 14,
            TextColor3 = T.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
        }, tabButton)

        -- Two-column page
        local page = New("Frame", {
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 5,
        }, pages)

        local left = New("ScrollingFrame", {
            Position = UDim2.fromOffset(0,0),
            Size = UDim2.new(0.5, -6, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.fromOffset(0,0),
            ZIndex = 5,
        }, page)

        local right = New("ScrollingFrame", {
            Position = UDim2.new(0.5, 6, 0, 0),
            Size = UDim2.new(0.5, -6, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.fromOffset(0,0),
            ZIndex = 5,
        }, page)

        local leftLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, left)

        local rightLayout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, right)

        local leftPadding = New("UIPadding", {
            PaddingLeft = UDim.new(0,2),
            PaddingRight = UDim.new(0,5),
            PaddingBottom = UDim.new(0,10)
        }, left)

        local rightPadding = New("UIPadding", {
            PaddingLeft = UDim.new(0,5),
            PaddingRight = UDim.new(0,2),
            PaddingBottom = UDim.new(0,10)
        }, right)

        SetCanvas(left, leftLayout, 14)
        SetCanvas(right, rightLayout, 14)

        -- Mobile: one column
        local function updateColumns()
            local camera = workspace.CurrentCamera
            if not camera then return end

            local narrow = camera.ViewportSize.X < 720 or UserInputService.TouchEnabled and camera.ViewportSize.X < 900

            if narrow then
                left.Size = UDim2.new(1, 0, 1, 0)
                right.Position = UDim2.new(0,0,0,0)
                right.Size = UDim2.new(1,0,1,0)

                -- Sections decide visibility via their parent; right is still stacked separately.
                -- To keep mobile usable, right is placed after left vertically by copying section parents
                -- is avoided; users can choose Column="Left" for mobile-critical controls.
            else
                left.Size = UDim2.new(0.5, -6, 1, 0)
                right.Position = UDim2.new(0.5, 6, 0, 0)
                right.Size = UDim2.new(0.5, -6, 1, 0)
            end
        end

        updateColumns()
        if workspace.CurrentCamera then
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateColumns)
        end

        function Tab:Select()
            for _, other in ipairs(Window.Tabs) do
                other.Page.Visible = false
                Tween(other.Button, 0.12, {BackgroundColor3 = T.Panel})
                Tween(other.Accent, 0.12, {BackgroundTransparency = 1})
                other.Label.TextColor3 = T.TextMuted

                if other.IconImage then
                    other.IconImage.ImageColor3 = T.TextMuted
                end
                if other.IconText then
                    other.IconText.TextColor3 = T.TextMuted
                end
            end

            Window.ActiveTab = Tab
            page.Visible = true
            pageTitle.Text = Tab.Name
            pageSubtitle.Text = Tab.Description

            Tween(tabButton, 0.12, {BackgroundColor3 = Color3.fromRGB(30,8,11)})
            Tween(tabAccent, 0.12, {BackgroundTransparency = 0})
            tabName.TextColor3 = T.Text

            if iconImage then iconImage.ImageColor3 = T.Accent end
            if iconText then iconText.TextColor3 = T.Accent end
        end

        tabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        BindTheme(function(theme)
            if not tabButton.Parent then return end
            tabButton.BackgroundColor3 = theme.Panel
            tabStroke.Color = theme.StrokeDark
            tabAccent.BackgroundColor3 = theme.Accent
            tabName.TextColor3 = theme.TextMuted
            left.ScrollBarImageColor3 = theme.Accent
            right.ScrollBarImageColor3 = theme.Accent
            if iconImage then iconImage.ImageColor3 = theme.TextMuted end
            if iconText then iconText.TextColor3 = theme.TextMuted end
        end)

        Tab.Button = tabButton
        Tab.Page = page
        Tab.Left = left
        Tab.Right = right
        Tab.Accent = tabAccent
        Tab.Label = tabName
        Tab.IconImage = iconImage
        Tab.IconText = iconText

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            task.defer(function()
                Tab:Select()
            end)
        end

        --==================================================
        -- SECTION
        --==================================================

        function Tab:AddSection(sectionData)
            sectionData = sectionData or {}

            local Section = {
                Name = sectionData.Name or "Section",
                Column = sectionData.Column or sectionData.Side or "Left",
            }

            local parentColumn = string.lower(Section.Column) == "right" and right or left

            local container = New("Frame", {
                Size = UDim2.new(1, 0, 0, 54),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.Panel,
                BorderSizePixel = 0,
                ZIndex = 6,
            }, parentColumn)
            Corner(container, 10)
            local containerStroke = Stroke(container, T.StrokeDark, 1, 0.15)

            local sectionHeader = New("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = T.Panel2,
                BorderSizePixel = 0,
                ZIndex = 7,
            }, container)
            Corner(sectionHeader, 10)

            local sectionAccent = New("Frame", {
                Position = UDim2.fromOffset(0, 10),
                Size = UDim2.fromOffset(3, 24),
                BackgroundColor3 = T.Accent,
                BorderSizePixel = 0,
                ZIndex = 8,
            }, sectionHeader)

            local sectionTitle = New("TextLabel", {
                Position = UDim2.fromOffset(13, 0),
                Size = UDim2.new(1, -26, 1, 0),
                BackgroundTransparency = 1,
                Text = Section.Name,
                Font = FONT.Bold,
                TextSize = 14,
                TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            }, sectionHeader)

            local holder = New("Frame", {
                Position = UDim2.fromOffset(0, 44),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex = 7,
            }, container)

            local holderPadding = New("UIPadding", {
                PaddingLeft = UDim.new(0, 9),
                PaddingRight = UDim.new(0, 9),
                PaddingTop = UDim.new(0, 9),
                PaddingBottom = UDim.new(0, 9),
            }, holder)

            local holderLayout = New("UIListLayout", {
                Padding = UDim.new(0, 7),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, holder)

            BindTheme(function(theme)
                if not container.Parent then return end
                container.BackgroundColor3 = theme.Panel
                containerStroke.Color = theme.StrokeDark
                sectionHeader.BackgroundColor3 = theme.Panel2
                sectionAccent.BackgroundColor3 = theme.Accent
                sectionTitle.TextColor3 = theme.Text
            end)

            local function RegisterSearch(object, name, description)
                table.insert(Window.SearchEntries, {
                    Object = object,
                    Name = name or "",
                    Description = description or "",
                    Section = Section.Name,
                })
            end

            local function BaseRow(height)
                local row = New("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 54),
                    BackgroundColor3 = T.Panel2,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, holder)
                Corner(row, 8)
                local s = Stroke(row, T.StrokeDark, 1, 0.25)

                BindTheme(function(theme)
                    if not row.Parent then return end
                    row.BackgroundColor3 = theme.Panel2
                    s.Color = theme.StrokeDark
                end)

                return row
            end

            function Section:AddButton(data)
                data = data or {}

                local row = New("TextButton", {
                    Size = UDim2.new(1,0,0,52),
                    BackgroundColor3 = T.Accent3,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 8,
                }, holder)
                Corner(row, 8)
                local s = Stroke(row, T.Accent2, 1, 0.05)

                local nameLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13, 4),
                    Size = UDim2.new(1, -42, 0, 23),
                    BackgroundTransparency = 1,
                    Text = data.Name or "Button",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local desc = New("TextLabel", {
                    Position = UDim2.fromOffset(13, 27),
                    Size = UDim2.new(1, -42, 0, 17),
                    BackgroundTransparency = 1,
                    Text = data.Description or "",
                    Font = FONT.Regular,
                    TextSize = 10,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local arrow = New("TextLabel", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1, -9, 0, 0),
                    Size = UDim2.fromOffset(24,52),
                    BackgroundTransparency = 1,
                    Text = "›",
                    Font = FONT.Bold,
                    TextSize = 22,
                    TextColor3 = T.Accent,
                    ZIndex = 9,
                }, row)

                row.MouseButton1Click:Connect(function()
                    SafeCall(data.Callback)
                end)

                RegisterSearch(row, data.Name, data.Description)

                BindTheme(function(theme)
                    if not row.Parent then return end
                    row.BackgroundColor3 = theme.Accent3
                    s.Color = theme.Accent2
                    nameLabel.TextColor3 = theme.Text
                    desc.TextColor3 = theme.TextMuted
                    arrow.TextColor3 = theme.Accent
                end)

                return {
                    SetText = function(_, text)
                        nameLabel.Text = tostring(text)
                    end
                }
            end

            function Section:AddToggle(data)
                data = data or {}
                local value = data.Default == true

                local row = BaseRow(56)

                local nameLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13, 4),
                    Size = UDim2.new(1, -76, 0, 23),
                    BackgroundTransparency = 1,
                    Text = data.Name or "Toggle",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local desc = New("TextLabel", {
                    Position = UDim2.fromOffset(13, 27),
                    Size = UDim2.new(1, -84, 0, 17),
                    BackgroundTransparency = 1,
                    Text = data.Description or "",
                    Font = FONT.Regular,
                    TextSize = 10,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local switch = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-12,0.5,0),
                    Size = UDim2.fromOffset(48,26),
                    BackgroundColor3 = T.Panel3,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 9,
                }, row)
                Corner(switch, 999)
                local swStroke = Stroke(switch, T.Stroke, 1, 0.3)

                local dot = New("Frame", {
                    AnchorPoint = Vector2.new(0,0.5),
                    Position = UDim2.new(0,3,0.5,0),
                    Size = UDim2.fromOffset(20,20),
                    BackgroundColor3 = T.TextMuted,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, switch)
                Corner(dot, 999)

                local function render(call)
                    if value then
                        Tween(switch, 0.14, {BackgroundColor3 = T.Accent3})
                        Tween(dot, 0.14, {
                            Position = UDim2.new(1,-23,0.5,0),
                            BackgroundColor3 = T.Accent
                        })
                    else
                        Tween(switch, 0.14, {BackgroundColor3 = T.Panel3})
                        Tween(dot, 0.14, {
                            Position = UDim2.new(0,3,0.5,0),
                            BackgroundColor3 = T.TextMuted
                        })
                    end

                    if call then
                        SafeCall(data.Callback, value)
                    end
                end

                switch.MouseButton1Click:Connect(function()
                    value = not value
                    render(true)
                end)

                local handle = {}

                function handle:Set(v)
                    value = v == true
                    render(true)
                end

                function handle:Get()
                    return value
                end

                render(false)
                RegisterSearch(row, data.Name, data.Description)
                Window:RegisterFlag(data.Flag, handle)

                BindTheme(function(theme)
                    if not row.Parent then return end
                    nameLabel.TextColor3 = theme.Text
                    desc.TextColor3 = theme.TextMuted
                    swStroke.Color = theme.Stroke
                    render(false)
                end)

                return handle
            end

            function Section:AddSlider(data)
                data = data or {}

                local min = tonumber(data.Min) or 0
                local max = tonumber(data.Max) or 100
                local decimals = tonumber(data.Decimals) or 0
                local value = Clamp(tonumber(data.Default) or min, min, max)

                local row = BaseRow(72)

                local nameLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13,5),
                    Size = UDim2.new(1,-90,0,22),
                    BackgroundTransparency = 1,
                    Text = data.Name or "Slider",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local valueLabel = New("TextLabel", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-13,0,5),
                    Size = UDim2.fromOffset(70,22),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    Font = FONT.Bold,
                    TextSize = 12,
                    TextColor3 = T.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 9,
                }, row)

                local bar = New("Frame", {
                    Position = UDim2.fromOffset(13,43),
                    Size = UDim2.new(1,-26,0,8),
                    BackgroundColor3 = T.Panel3,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, row)
                Corner(bar, 999)

                local fill = New("Frame", {
                    Size = UDim2.new(0,0,1,0),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, bar)
                Corner(fill, 999)

                local knob = New("Frame", {
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new(0,0,0.5,0),
                    Size = UDim2.fromOffset(15,15),
                    BackgroundColor3 = T.Text,
                    BorderSizePixel = 0,
                    ZIndex = 11,
                }, bar)
                Corner(knob, 999)
                local knobStroke = Stroke(knob, T.Accent, 2, 0)

                local dragging = false

                local function setValue(v, call)
                    value = Clamp(Round(tonumber(v) or min, decimals), min, max)
                    local alpha = (value - min) / math.max(max - min, 0.00001)

                    fill.Size = UDim2.new(alpha,0,1,0)
                    knob.Position = UDim2.new(alpha,0,0.5,0)
                    valueLabel.Text = tostring(value)

                    if call then
                        SafeCall(data.Callback, value)
                    end
                end

                local function update(input)
                    local alpha = (input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X,1)
                    setValue(min + ((max-min) * Clamp(alpha,0,1)), true)
                end

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    ) then
                        update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                local handle = {}

                function handle:Set(v)
                    setValue(v, true)
                end

                function handle:Get()
                    return value
                end

                setValue(value, false)
                RegisterSearch(row, data.Name, data.Description)
                Window:RegisterFlag(data.Flag, handle)

                BindTheme(function(theme)
                    if not row.Parent then return end
                    nameLabel.TextColor3 = theme.Text
                    valueLabel.TextColor3 = theme.Accent
                    bar.BackgroundColor3 = theme.Panel3
                    fill.BackgroundColor3 = theme.Accent
                    knob.BackgroundColor3 = theme.Text
                    knobStroke.Color = theme.Accent
                end)

                return handle
            end

            function Section:AddDropdown(data)
                data = data or {}

                local optionsList = data.Options or {}
                local selected = data.Default
                local open = false

                local outer = New("Frame", {
                    Size = UDim2.new(1,0,0,56),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    ZIndex = 8,
                }, holder)

                local row = New("TextButton", {
                    Size = UDim2.new(1,0,0,56),
                    BackgroundColor3 = T.Panel2,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 9,
                }, outer)
                Corner(row, 8)
                local rowStroke = Stroke(row, T.StrokeDark, 1, 0.25)

                local nameLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13,4),
                    Size = UDim2.new(1,-48,0,23),
                    BackgroundTransparency = 1,
                    Text = data.Name or "Dropdown",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                }, row)

                local selectedLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13,27),
                    Size = UDim2.new(1,-52,0,18),
                    BackgroundTransparency = 1,
                    Text = selected and tostring(selected) or "Select...",
                    Font = FONT.Regular,
                    TextSize = 10,
                    TextColor3 = selected and T.Accent or T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10,
                }, row)

                local arrow = New("TextLabel", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-10,0,0),
                    Size = UDim2.fromOffset(24,56),
                    BackgroundTransparency = 1,
                    Text = "⌄",
                    Font = FONT.Bold,
                    TextSize = 16,
                    TextColor3 = T.Accent,
                    ZIndex = 10,
                }, row)

                local list = New("Frame", {
                    Position = UDim2.fromOffset(0,62),
                    Size = UDim2.new(1,0,0,0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = T.Panel,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 9,
                }, outer)
                Corner(list, 8)
                local listStroke = Stroke(list, T.StrokeDark, 1, 0.2)

                New("UIPadding", {
                    PaddingLeft = UDim.new(0,6),
                    PaddingRight = UDim.new(0,6),
                    PaddingTop = UDim.new(0,6),
                    PaddingBottom = UDim.new(0,6),
                }, list)

                local listLayout = New("UIListLayout", {
                    Padding = UDim.new(0,5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, list)

                local optionButtons = {}

                local function closeList()
                    open = false
                    arrow.Text = "⌄"
                    Tween(outer, 0.16, {Size = UDim2.new(1,0,0,56)})
                    task.delay(0.17, function()
                        if not open then list.Visible = false end
                    end)
                end

                local function openList()
                    open = true
                    list.Visible = true
                    arrow.Text = "⌃"
                    task.wait()
                    Tween(outer, 0.16, {
                        Size = UDim2.new(1,0,0,62 + listLayout.AbsoluteContentSize.Y + 12)
                    })
                end

                local function setSelected(v, call)
                    selected = v
                    selectedLabel.Text = tostring(v)
                    selectedLabel.TextColor3 = T.Accent
                    closeList()
                    if call then SafeCall(data.Callback, selected) end
                end

                local function rebuild(newOptions)
                    for _, b in ipairs(optionButtons) do
                        b:Destroy()
                    end
                    optionButtons = {}
                    optionsList = newOptions or {}

                    for _, option in ipairs(optionsList) do
                        local b = New("TextButton", {
                            Size = UDim2.new(1,0,0,34),
                            BackgroundColor3 = T.Panel2,
                            BorderSizePixel = 0,
                            Text = tostring(option),
                            Font = FONT.Medium,
                            TextSize = 11,
                            TextColor3 = T.TextMuted,
                            AutoButtonColor = false,
                            ZIndex = 11,
                        }, list)
                        Corner(b, 6)

                        b.MouseButton1Click:Connect(function()
                            setSelected(option, true)
                        end)

                        table.insert(optionButtons, b)

                        BindTheme(function(theme)
                            if b.Parent then
                                b.BackgroundColor3 = theme.Panel2
                                b.TextColor3 = theme.TextMuted
                            end
                        end)
                    end
                end

                row.MouseButton1Click:Connect(function()
                    if open then closeList() else openList() end
                end)

                rebuild(optionsList)

                local handle = {}

                function handle:Set(v)
                    setSelected(v, true)
                end

                function handle:Get()
                    return selected
                end

                function handle:Refresh(newOptions)
                    rebuild(newOptions)
                end

                RegisterSearch(outer, data.Name, data.Description)
                Window:RegisterFlag(data.Flag, handle)

                BindTheme(function(theme)
                    if not outer.Parent then return end
                    row.BackgroundColor3 = theme.Panel2
                    rowStroke.Color = theme.StrokeDark
                    nameLabel.TextColor3 = theme.Text
                    selectedLabel.TextColor3 = selected and theme.Accent or theme.TextMuted
                    arrow.TextColor3 = theme.Accent
                    list.BackgroundColor3 = theme.Panel
                    listStroke.Color = theme.StrokeDark
                end)

                return handle
            end

            function Section:AddMultiDropdown(data)
                data = data or {}

                local optionsList = data.Options or {}
                local selected = {}
                local open = false

                for _, v in ipairs(data.Default or {}) do
                    selected[v] = true
                end

                local outer = New("Frame", {
                    Size = UDim2.new(1,0,0,56),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    ZIndex = 8,
                }, holder)

                local row = New("TextButton", {
                    Size = UDim2.new(1,0,0,56),
                    BackgroundColor3 = T.Panel2,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 9,
                }, outer)
                Corner(row, 8)
                local rowStroke = Stroke(row, T.StrokeDark, 1, 0.25)

                local nameLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13,4),
                    Size = UDim2.new(1,-48,0,23),
                    BackgroundTransparency = 1,
                    Text = data.Name or "MultiDropdown",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                }, row)

                local selectedLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13,27),
                    Size = UDim2.new(1,-52,0,18),
                    BackgroundTransparency = 1,
                    Text = "Nothing selected",
                    Font = FONT.Regular,
                    TextSize = 10,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10,
                }, row)

                local arrow = New("TextLabel", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-10,0,0),
                    Size = UDim2.fromOffset(24,56),
                    BackgroundTransparency = 1,
                    Text = "⌄",
                    Font = FONT.Bold,
                    TextSize = 16,
                    TextColor3 = T.Accent,
                    ZIndex = 10,
                }, row)

                local list = New("Frame", {
                    Position = UDim2.fromOffset(0,62),
                    Size = UDim2.new(1,0,0,0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = T.Panel,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 9,
                }, outer)
                Corner(list, 8)
                local listStroke = Stroke(list, T.StrokeDark, 1, 0.2)

                New("UIPadding", {
                    PaddingLeft = UDim.new(0,6),
                    PaddingRight = UDim.new(0,6),
                    PaddingTop = UDim.new(0,6),
                    PaddingBottom = UDim.new(0,6),
                }, list)

                local listLayout = New("UIListLayout", {
                    Padding = UDim.new(0,5),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, list)

                local optionButtons = {}

                local function getArray()
                    local array = {}
                    for _, option in ipairs(optionsList) do
                        if selected[option] then
                            table.insert(array, option)
                        end
                    end
                    return array
                end

                local function renderSummary()
                    local array = getArray()
                    if #array == 0 then
                        selectedLabel.Text = "Nothing selected"
                        selectedLabel.TextColor3 = T.TextMuted
                    else
                        selectedLabel.Text = table.concat(array, ", ")
                        selectedLabel.TextColor3 = T.Accent
                    end
                end

                local function closeList()
                    open = false
                    arrow.Text = "⌄"
                    Tween(outer,0.16,{Size = UDim2.new(1,0,0,56)})
                    task.delay(0.17,function()
                        if not open then list.Visible = false end
                    end)
                end

                local function openList()
                    open = true
                    list.Visible = true
                    arrow.Text = "⌃"
                    task.wait()
                    Tween(outer,0.16,{
                        Size = UDim2.new(1,0,0,62 + listLayout.AbsoluteContentSize.Y + 12)
                    })
                end

                local function rebuild(newOptions)
                    for _, b in ipairs(optionButtons) do
                        b:Destroy()
                    end
                    optionButtons = {}
                    optionsList = newOptions or {}

                    for _, option in ipairs(optionsList) do
                        local b = New("TextButton", {
                            Size = UDim2.new(1,0,0,36),
                            BackgroundColor3 = T.Panel2,
                            BorderSizePixel = 0,
                            Text = "",
                            AutoButtonColor = false,
                            ZIndex = 11,
                        }, list)
                        Corner(b,6)

                        local check = New("Frame", {
                            Position = UDim2.fromOffset(8,9),
                            Size = UDim2.fromOffset(18,18),
                            BackgroundColor3 = T.Panel3,
                            BorderSizePixel = 0,
                            ZIndex = 12,
                        }, b)
                        Corner(check,5)

                        local mark = New("TextLabel", {
                            Size = UDim2.fromScale(1,1),
                            BackgroundTransparency = 1,
                            Text = "✓",
                            Font = FONT.Bold,
                            TextSize = 11,
                            TextColor3 = T.Text,
                            Visible = false,
                            ZIndex = 13,
                        }, check)

                        local txt = New("TextLabel", {
                            Position = UDim2.fromOffset(36,0),
                            Size = UDim2.new(1,-44,1,0),
                            BackgroundTransparency = 1,
                            Text = tostring(option),
                            Font = FONT.Medium,
                            TextSize = 11,
                            TextColor3 = T.TextMuted,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 12,
                        }, b)

                        local function renderOption()
                            local on = selected[option] == true
                            check.BackgroundColor3 = on and T.Accent3 or T.Panel3
                            mark.Visible = on
                            txt.TextColor3 = on and T.Text or T.TextMuted
                        end

                        b.MouseButton1Click:Connect(function()
                            selected[option] = not selected[option]
                            renderOption()
                            renderSummary()
                            SafeCall(data.Callback, getArray())
                        end)

                        renderOption()
                        table.insert(optionButtons,b)

                        BindTheme(function(theme)
                            if not b.Parent then return end
                            b.BackgroundColor3 = theme.Panel2
                            renderOption()
                        end)
                    end
                end

                row.MouseButton1Click:Connect(function()
                    if open then closeList() else openList() end
                end)

                rebuild(optionsList)
                renderSummary()

                local handle = {}

                function handle:Get()
                    return getArray()
                end

                function handle:Set(values)
                    selected = {}
                    for _, v in ipairs(values or {}) do
                        selected[v] = true
                    end
                    rebuild(optionsList)
                    renderSummary()
                    SafeCall(data.Callback, getArray())
                end

                function handle:Refresh(newOptions)
                    rebuild(newOptions)
                    renderSummary()
                end

                RegisterSearch(outer, data.Name, data.Description)
                Window:RegisterFlag(data.Flag, handle)

                BindTheme(function(theme)
                    if not outer.Parent then return end
                    row.BackgroundColor3 = theme.Panel2
                    rowStroke.Color = theme.StrokeDark
                    nameLabel.TextColor3 = theme.Text
                    arrow.TextColor3 = theme.Accent
                    list.BackgroundColor3 = theme.Panel
                    listStroke.Color = theme.StrokeDark
                    renderSummary()
                end)

                return handle
            end

            function Section:AddTextbox(data)
                data = data or {}
                local value = tostring(data.Default or "")

                local row = BaseRow(60)

                local nameLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13,0),
                    Size = UDim2.new(0.38,0,1,0),
                    BackgroundTransparency = 1,
                    Text = data.Name or "Textbox",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local inputHolder = New("Frame", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-12,0.5,0),
                    Size = UDim2.new(0.57,0,0,36),
                    BackgroundColor3 = T.Background2,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, row)
                Corner(inputHolder,7)
                local inputStroke = Stroke(inputHolder,T.Stroke,1,0.35)

                local box = New("TextBox", {
                    Position = UDim2.fromOffset(10,0),
                    Size = UDim2.new(1,-20,1,0),
                    BackgroundTransparency = 1,
                    Text = value,
                    PlaceholderText = data.Placeholder or "Enter text...",
                    PlaceholderColor3 = T.TextDark,
                    ClearTextOnFocus = data.ClearOnFocus == true,
                    Font = FONT.Regular,
                    TextSize = 11,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                }, inputHolder)

                box.FocusLost:Connect(function(enterPressed)
                    value = box.Text
                    SafeCall(data.Callback, value, enterPressed)
                end)

                local handle = {}

                function handle:Get()
                    return box.Text
                end

                function handle:Set(v)
                    value = tostring(v or "")
                    box.Text = value
                    SafeCall(data.Callback, value, false)
                end

                RegisterSearch(row, data.Name, data.Description)
                Window:RegisterFlag(data.Flag, handle)

                BindTheme(function(theme)
                    if not row.Parent then return end
                    nameLabel.TextColor3 = theme.Text
                    inputHolder.BackgroundColor3 = theme.Background2
                    inputStroke.Color = theme.Stroke
                    box.TextColor3 = theme.Text
                    box.PlaceholderColor3 = theme.TextDark
                end)

                return handle
            end

            function Section:AddKeybind(data)
                data = data or {}

                local current = data.Default or Enum.KeyCode.RightControl
                local listening = false

                local row = BaseRow(56)

                local nameLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13,4),
                    Size = UDim2.new(1,-120,0,23),
                    BackgroundTransparency = 1,
                    Text = data.Name or "Keybind",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local desc = New("TextLabel", {
                    Position = UDim2.fromOffset(13,27),
                    Size = UDim2.new(1,-120,0,17),
                    BackgroundTransparency = 1,
                    Text = data.Description or "",
                    Font = FONT.Regular,
                    TextSize = 10,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local bindButton = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-12,0.5,0),
                    Size = UDim2.fromOffset(86,32),
                    BackgroundColor3 = T.Background2,
                    BorderSizePixel = 0,
                    Text = current.Name,
                    Font = FONT.Bold,
                    TextSize = 10,
                    TextColor3 = T.Accent,
                    AutoButtonColor = false,
                    ZIndex = 9,
                }, row)
                Corner(bindButton,7)
                local bindStroke = Stroke(bindButton,T.Stroke,1,0.35)

                bindButton.MouseButton1Click:Connect(function()
                    listening = true
                    bindButton.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        current = input.KeyCode
                        bindButton.Text = current.Name
                        listening = false
                        SafeCall(data.Changed, current)
                        return
                    end

                    if not processed
                    and input.UserInputType == Enum.UserInputType.Keyboard
                    and input.KeyCode == current then
                        SafeCall(data.Callback, current)
                    end
                end)

                local handle = {}

                function handle:Get()
                    return current.Name
                end

                function handle:Set(v)
                    if typeof(v) == "EnumItem" then
                        current = v
                    elseif type(v) == "string" and Enum.KeyCode[v] then
                        current = Enum.KeyCode[v]
                    end
                    bindButton.Text = current.Name
                    SafeCall(data.Changed, current)
                end

                RegisterSearch(row, data.Name, data.Description)
                Window:RegisterFlag(data.Flag, handle)

                BindTheme(function(theme)
                    if not row.Parent then return end
                    nameLabel.TextColor3 = theme.Text
                    desc.TextColor3 = theme.TextMuted
                    bindButton.BackgroundColor3 = theme.Background2
                    bindButton.TextColor3 = theme.Accent
                    bindStroke.Color = theme.Stroke
                end)

                return handle
            end

            function Section:AddColorPicker(data)
                data = data or {}

                local value = data.Default or Color3.fromRGB(255,0,0)
                local expanded = false

                local outer = New("Frame", {
                    Size = UDim2.new(1,0,0,56),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    ZIndex = 8,
                }, holder)

                local row = New("TextButton", {
                    Size = UDim2.new(1,0,0,56),
                    BackgroundColor3 = T.Panel2,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 9,
                }, outer)
                Corner(row,8)
                local rowStroke = Stroke(row,T.StrokeDark,1,0.25)

                local nameLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(13,4),
                    Size = UDim2.new(1,-88,0,23),
                    BackgroundTransparency = 1,
                    Text = data.Name or "Color Picker",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                }, row)

                local desc = New("TextLabel", {
                    Position = UDim2.fromOffset(13,27),
                    Size = UDim2.new(1,-88,0,17),
                    BackgroundTransparency = 1,
                    Text = data.Description or "Choose RGB color",
                    Font = FONT.Regular,
                    TextSize = 10,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                }, row)

                local preview = New("Frame", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-13,0.5,0),
                    Size = UDim2.fromOffset(42,28),
                    BackgroundColor3 = value,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, row)
                Corner(preview,6)
                Stroke(preview,T.Stroke,1,0.25)

                local panel = New("Frame", {
                    Position = UDim2.fromOffset(0,62),
                    Size = UDim2.new(1,0,0,118),
                    BackgroundColor3 = T.Panel,
                    BorderSizePixel = 0,
                    Visible = false,
                    ZIndex = 9,
                }, outer)
                Corner(panel,8)
                local panelStroke = Stroke(panel,T.StrokeDark,1,0.25)

                local channels = {
                    {Name="R", Get=function(c) return math.floor(c.R*255+0.5) end},
                    {Name="G", Get=function(c) return math.floor(c.G*255+0.5) end},
                    {Name="B", Get=function(c) return math.floor(c.B*255+0.5) end},
                }

                local boxes = {}

                for i, channel in ipairs(channels) do
                    local y = 10 + ((i-1)*34)

                    local label = New("TextLabel", {
                        Position = UDim2.fromOffset(12,y),
                        Size = UDim2.fromOffset(20,28),
                        BackgroundTransparency = 1,
                        Text = channel.Name,
                        Font = FONT.Bold,
                        TextSize = 11,
                        TextColor3 = T.TextMuted,
                        ZIndex = 10,
                    }, panel)

                    local holderBox = New("Frame", {
                        Position = UDim2.fromOffset(36,y),
                        Size = UDim2.new(1,-48,0,28),
                        BackgroundColor3 = T.Background2,
                        BorderSizePixel = 0,
                        ZIndex = 10,
                    }, panel)
                    Corner(holderBox,6)
                    Stroke(holderBox,T.Stroke,1,0.4)

                    local box = New("TextBox", {
                        Size = UDim2.fromScale(1,1),
                        BackgroundTransparency = 1,
                        Text = tostring(channel.Get(value)),
                        ClearTextOnFocus = false,
                        Font = FONT.Medium,
                        TextSize = 11,
                        TextColor3 = T.Text,
                        ZIndex = 11,
                    }, holderBox)

                    boxes[channel.Name] = box
                end

                local function setColor(c, call)
                    value = c
                    preview.BackgroundColor3 = value
                    boxes.R.Text = tostring(math.floor(value.R*255+0.5))
                    boxes.G.Text = tostring(math.floor(value.G*255+0.5))
                    boxes.B.Text = tostring(math.floor(value.B*255+0.5))

                    if call then
                        SafeCall(data.Callback, value)
                    end
                end

                local function updateFromBoxes()
                    local r = Clamp(tonumber(boxes.R.Text) or 0,0,255)
                    local g = Clamp(tonumber(boxes.G.Text) or 0,0,255)
                    local b = Clamp(tonumber(boxes.B.Text) or 0,0,255)
                    setColor(Color3.fromRGB(r,g,b), true)
                end

                for _, box in pairs(boxes) do
                    box.FocusLost:Connect(updateFromBoxes)
                end

                row.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    panel.Visible = expanded

                    Tween(outer,0.16,{
                        Size = expanded and UDim2.new(1,0,0,186) or UDim2.new(1,0,0,56)
                    })
                end)

                local handle = {}

                function handle:Get()
                    return value
                end

                function handle:Set(c)
                    if typeof(c) == "Color3" then
                        setColor(c,true)
                    elseif type(c) == "table" then
                        local converted = TableToColor(c)
                        if converted then setColor(converted,true) end
                    end
                end

                RegisterSearch(outer, data.Name, data.Description)
                Window:RegisterFlag(data.Flag, handle)

                BindTheme(function(theme)
                    if not outer.Parent then return end
                    row.BackgroundColor3 = theme.Panel2
                    rowStroke.Color = theme.StrokeDark
                    nameLabel.TextColor3 = theme.Text
                    desc.TextColor3 = theme.TextMuted
                    panel.BackgroundColor3 = theme.Panel
                    panelStroke.Color = theme.StrokeDark
                end)

                return handle
            end

            function Section:AddLabel(text)
                local row = New("Frame", {
                    Size = UDim2.new(1,0,0,34),
                    BackgroundColor3 = T.Panel2,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, holder)
                Corner(row,7)

                local label = New("TextLabel", {
                    Position = UDim2.fromOffset(11,0),
                    Size = UDim2.new(1,-22,1,0),
                    BackgroundTransparency = 1,
                    Text = tostring(text or "Label"),
                    Font = FONT.Medium,
                    TextSize = 11,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                RegisterSearch(row, text, "")

                BindTheme(function(theme)
                    if row.Parent then
                        row.BackgroundColor3 = theme.Panel2
                        label.TextColor3 = theme.TextMuted
                    end
                end)

                return {
                    Set = function(_, value)
                        label.Text = tostring(value or "")
                    end
                }
            end

            function Section:AddParagraph(data)
                data = data or {}

                local row = New("Frame", {
                    Size = UDim2.new(1,0,0,72),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = T.Panel2,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, holder)
                Corner(row,8)
                local rowStroke = Stroke(row,T.StrokeDark,1,0.25)

                New("UIPadding", {
                    PaddingLeft = UDim.new(0,13),
                    PaddingRight = UDim.new(0,13),
                    PaddingTop = UDim.new(0,10),
                    PaddingBottom = UDim.new(0,11),
                }, row)

                New("UIListLayout", {
                    Padding = UDim.new(0,4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                }, row)

                local pTitle = New("TextLabel", {
                    Size = UDim2.new(1,0,0,21),
                    BackgroundTransparency = 1,
                    Text = data.Title or "Paragraph",
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local pContent = New("TextLabel", {
                    Size = UDim2.new(1,0,0,0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = data.Content or "",
                    Font = FONT.Regular,
                    TextSize = 11,
                    TextColor3 = T.TextMuted,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    ZIndex = 9,
                }, row)

                RegisterSearch(row, data.Title, data.Content)

                BindTheme(function(theme)
                    if not row.Parent then return end
                    row.BackgroundColor3 = theme.Panel2
                    rowStroke.Color = theme.StrokeDark
                    pTitle.TextColor3 = theme.Text
                    pContent.TextColor3 = theme.TextMuted
                end)

                return {
                    SetTitle = function(_, v) pTitle.Text = tostring(v or "") end,
                    SetContent = function(_, v) pContent.Text = tostring(v or "") end,
                }
            end

            function Section:AddDivider(text)
                local row = New("Frame", {
                    Size = UDim2.new(1,0,0,24),
                    BackgroundTransparency = 1,
                    ZIndex = 8,
                }, holder)

                local leftLine = New("Frame", {
                    AnchorPoint = Vector2.new(0,0.5),
                    Position = UDim2.new(0,0,0.5,0),
                    Size = UDim2.new(0.3,0,0,1),
                    BackgroundColor3 = T.Accent3,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, row)

                local rightLine = New("Frame", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,0,0.5,0),
                    Size = UDim2.new(0.3,0,0,1),
                    BackgroundColor3 = T.Accent3,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, row)

                local middle = New("TextLabel", {
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new(0.5,0,0.5,0),
                    Size = UDim2.new(0.36,0,1,0),
                    BackgroundTransparency = 1,
                    Text = text or "◆",
                    Font = FONT.Bold,
                    TextSize = 10,
                    TextColor3 = T.Accent,
                    ZIndex = 9,
                }, row)

                BindTheme(function(theme)
                    if row.Parent then
                        leftLine.BackgroundColor3 = theme.Accent3
                        rightLine.BackgroundColor3 = theme.Accent3
                        middle.TextColor3 = theme.Accent
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    --==================================================
    -- HEADER BUTTONS / DRAG / MINIMIZE
    --==================================================

    MakeDraggable(main, header)

    local minimized = false

    -- v2.1: The main window is NEVER resized when minimized.
    -- It is hidden completely and replaced by this independent circular button.
    local miniButton = New("TextButton", {
        Name = "DriftwynMiniButton",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -22, 1, -22),
        Size = UDim2.fromOffset(60, 60),
        BackgroundColor3 = T.Accent3,
        BorderSizePixel = 0,
        Text = options.IconText or "DH",
        Font = FONT.Black,
        TextSize = 16,
        TextColor3 = T.Text,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 1000,
    }, gui)

    Corner(miniButton, 999)
    local miniStroke = Stroke(miniButton, T.Accent, 2, 0)

    -- Extra inner circle to make it visibly different from the old minimized header.
    local miniInner = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(46, 46),
        BackgroundColor3 = T.Background2,
        BorderSizePixel = 0,
        ZIndex = 999,
    }, miniButton)
    Corner(miniInner, 999)
    Stroke(miniInner, T.Accent2, 1, 0.15)

    -- Keep the button text above the inner circle.
    miniButton.TextTransparency = 1

    local miniText = New("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = options.IconText or "DH",
        Font = FONT.Black,
        TextSize = 15,
        TextColor3 = T.Text,
        ZIndex = 1001,
    }, miniButton)

    BindTheme(function(theme)
        if miniButton.Parent then
            miniButton.BackgroundColor3 = theme.Accent3
            miniStroke.Color = theme.Accent
            miniInner.BackgroundColor3 = theme.Background2
            miniText.TextColor3 = theme.Text
        end
    end)

    local function removeBlur()
        if blur and blur.Parent then
            blur.Enabled = false
        end
    end

    local function restoreBlur()
        if blur and blur.Parent and options.Blur ~= false then
            blur.Enabled = true
        end
    end

    local function minimizeWindow()
        if minimized or Window.Destroyed then return end
        minimized = true

        -- Important: remove the blur BEFORE hiding the window.
        removeBlur()

        notificationPanel.Visible = false
        panelOpen = false

        -- Completely hide the old/full UI.
        main.Visible = false
        overlay.Visible = false

        -- Show only the circular restore button.
        miniButton.Visible = true
        miniButton.Size = UDim2.fromOffset(42, 42)
        Tween(
            miniButton,
            0.18,
            {Size = UDim2.fromOffset(60, 60)},
            Enum.EasingStyle.Back
        )
    end

    local function restoreWindow()
        if not minimized or Window.Destroyed then return end
        minimized = false

        miniButton.Visible = false
        main.Visible = true
        overlay.Visible = true
        restoreBlur()

        -- Restore animation without changing the window's saved dimensions.
        local normalPosition = main.Position
        main.BackgroundTransparency = 1
        overlay.BackgroundTransparency = 1

        Tween(overlay, 0.15, {
            BackgroundTransparency = 0.38
        })

        Tween(main, 0.18, {
            BackgroundTransparency = 0
        }, Enum.EasingStyle.Quad)
    end

    minimize.MouseButton1Click:Connect(minimizeWindow)
    miniButton.MouseButton1Click:Connect(restoreWindow)

    close.MouseButton1Click:Connect(function()
        miniButton.Visible = false
        removeBlur()
        Window:Destroy()
    end)

    local toggleKey = options.ToggleKey or Enum.KeyCode.RightControl

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or Window.Destroyed then return end
        if input.KeyCode == toggleKey then
            Window:Toggle()
        end
    end)

    -- Opening animation
    local finalSize = main.Size
    main.Size = UDim2.new(
        finalSize.X.Scale,
        finalSize.X.Offset - 28,
        finalSize.Y.Scale,
        finalSize.Y.Offset - 28
    )
    main.BackgroundTransparency = 1
    overlay.BackgroundTransparency = 1

    Tween(overlay,0.2,{BackgroundTransparency = 0.38})
    Tween(main,0.24,{
        Size = finalSize,
        BackgroundTransparency = 0
    },Enum.EasingStyle.Back)

    Window.Gui = gui
    Window.Main = main
    Window.SearchBox = searchBox

    return Window
end

return DriftwynUI
