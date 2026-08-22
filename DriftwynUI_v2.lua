--[[
    DRIFTWYN UI LIBRARY v3
    Modern rebuild with a cleaner, softer visual system.

    Preserved core API:
      DriftwynUI:GetThemes()
      DriftwynUI:CreateWindow()
      Window:SetTheme()
      Window:GetTheme()
      Window:GetThemes()
      Window:SetTitle()
      Window:SetVisible()
      Window:Toggle()
      Window:Notify()
      Window:RegisterFlag()
      Window:GetValue()
      Window:SetValue()
      Window:ExportConfig()
      Window:ImportConfig()
      Window:SaveConfig()
      Window:LoadConfig()
      Window:Destroy()
      Window:AddTab()
      Tab:Select()
      Tab:AddSection()
      Section:AddButton()
      Section:AddToggle()
      Section:AddSlider()
      Section:AddDropdown()
      Section:AddMultiDropdown()
      Section:AddTextbox()
      Section:AddKeybind()
      Section:AddColorPicker()
      Section:AddLabel()
      Section:AddParagraph()
      Section:AddDivider()
]]

local DriftwynUI = {}
DriftwynUI.__index = DriftwynUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui"))

local FONT = {
    Regular = Enum.Font.Gotham,
    Medium = Enum.Font.GothamMedium,
    Bold = Enum.Font.GothamBold,
}

local THEMES = {
    Driftwyn = {
        Background = Color3.fromRGB(10, 11, 14),
        Sidebar = Color3.fromRGB(13, 14, 18),
        Surface = Color3.fromRGB(17, 18, 23),
        Surface2 = Color3.fromRGB(21, 22, 28),
        Surface3 = Color3.fromRGB(25, 26, 33),
        Border = Color3.fromRGB(43, 45, 55),
        BorderSoft = Color3.fromRGB(31, 33, 41),
        Accent = Color3.fromRGB(225, 44, 62),
        AccentDark = Color3.fromRGB(148, 24, 39),
        Text = Color3.fromRGB(242, 243, 247),
        TextMuted = Color3.fromRGB(154, 158, 171),
        TextDim = Color3.fromRGB(103, 107, 120),
        Success = Color3.fromRGB(79, 205, 126),
        Warning = Color3.fromRGB(236, 184, 72),
        Danger = Color3.fromRGB(230, 73, 84),
    },

    Midnight = {
        Background = Color3.fromRGB(9, 12, 18),
        Sidebar = Color3.fromRGB(12, 15, 22),
        Surface = Color3.fromRGB(17, 20, 28),
        Surface2 = Color3.fromRGB(21, 25, 34),
        Surface3 = Color3.fromRGB(26, 30, 40),
        Border = Color3.fromRGB(45, 51, 65),
        BorderSoft = Color3.fromRGB(31, 36, 47),
        Accent = Color3.fromRGB(90, 137, 255),
        AccentDark = Color3.fromRGB(51, 86, 180),
        Text = Color3.fromRGB(242, 245, 250),
        TextMuted = Color3.fromRGB(153, 161, 177),
        TextDim = Color3.fromRGB(99, 106, 120),
        Success = Color3.fromRGB(79, 205, 126),
        Warning = Color3.fromRGB(236, 184, 72),
        Danger = Color3.fromRGB(230, 73, 84),
    },

    Carbon = {
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(15, 15, 15),
        Surface = Color3.fromRGB(20, 20, 20),
        Surface2 = Color3.fromRGB(25, 25, 25),
        Surface3 = Color3.fromRGB(30, 30, 30),
        Border = Color3.fromRGB(48, 48, 48),
        BorderSoft = Color3.fromRGB(36, 36, 36),
        Accent = Color3.fromRGB(190, 190, 190),
        AccentDark = Color3.fromRGB(125, 125, 125),
        Text = Color3.fromRGB(245, 245, 245),
        TextMuted = Color3.fromRGB(160, 160, 160),
        TextDim = Color3.fromRGB(105, 105, 105),
        Success = Color3.fromRGB(79, 205, 126),
        Warning = Color3.fromRGB(236, 184, 72),
        Danger = Color3.fromRGB(230, 73, 84),
    },
}

local function cloneTable(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        out[k] = v
    end
    return out
end

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
    return New("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, parent)
end

local function Pad(parent, l, r, t, b)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    }, parent)
end

local function List(parent, spacing, direction)
    return New("UIListLayout", {
        Padding = UDim.new(0, spacing or 0),
        FillDirection = direction or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, parent)
end

local function Tween(obj, duration, goal, style, direction)
    local tw = TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.18,
            style or Enum.EasingStyle.Quart,
            direction or Enum.EasingDirection.Out
        ),
        goal
    )
    tw:Play()
    return tw
end

local function SafeCallback(fn, ...)
    if type(fn) ~= "function" then
        return
    end
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[DriftwynUI] Callback error:", err)
    end
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

local function SetAutoCanvas(scroller, layout, extra)
    local function update()
        scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + (extra or 0))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    task.defer(update)
end

function DriftwynUI:GetThemes()
    local names = {}
    for name in pairs(THEMES) do
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
        Theme = cloneTable(THEMES[options.Theme or "Driftwyn"] or THEMES.Driftwyn),
        SearchEntries = {},
        ThemeBindings = {},
    }

    local T = Window.Theme

    local gui = New("ScreenGui", {
        Name = options.Name or "DriftwynUI_v3",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = options.DisplayOrder or 75,
    }, PlayerGui)

    local overlay = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 0,
    }, gui)

    local blur
    if options.Blur == true then
        blur = New("BlurEffect", {
            Name = "DriftwynUI_v3_Blur",
            Size = options.BlurSize or 8,
            Enabled = true,
        }, Lighting)
    end

    local main = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = options.Size or UDim2.fromOffset(860, 560),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    }, gui)
    Corner(main, 16)
    local mainStroke = Stroke(main, T.Border, 1, 0.15)

    local shadow = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 50, 1, 50),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.52,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        ZIndex = 1,
    }, main)

    local header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, main)

    local divider = New("Frame", {
        AnchorPoint = Vector2.new(0,1),
        Position = UDim2.new(0,0,1,0),
        Size = UDim2.new(1,0,0,1),
        BackgroundColor3 = T.BorderSoft,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, header)

    local brandDot = New("Frame", {
        Position = UDim2.fromOffset(20, 22),
        Size = UDim2.fromOffset(22, 22),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 6,
    }, header)
    Corner(brandDot, 7)

    local brandInner = New("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.fromOffset(8,8),
        BackgroundColor3 = T.Text,
        BorderSizePixel = 0,
        ZIndex = 7,
    }, brandDot)
    Corner(brandInner, 99)

    local title = New("TextLabel", {
        Position = UDim2.fromOffset(54, 13),
        Size = UDim2.fromOffset(270, 24),
        BackgroundTransparency = 1,
        Text = options.Title or "Driftwyn",
        Font = FONT.Bold,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, header)

    local subtitle = New("TextLabel", {
        Position = UDim2.fromOffset(54, 36),
        Size = UDim2.fromOffset(300, 18),
        BackgroundTransparency = 1,
        Text = options.Subtitle or "Modern interface",
        Font = FONT.Regular,
        TextSize = 12,
        TextColor3 = T.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, header)

    local windowButtons = New("Frame", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,-14,0,14),
        Size = UDim2.fromOffset(86, 36),
        BackgroundTransparency = 1,
        ZIndex = 6,
    }, header)

    local wbList = List(windowButtons, 8, Enum.FillDirection.Horizontal)
    wbList.HorizontalAlignment = Enum.HorizontalAlignment.Right

    local minimize = New("TextButton", {
        Size = UDim2.fromOffset(36,36),
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        Text = "–",
        Font = FONT.Bold,
        TextSize = 18,
        TextColor3 = T.TextMuted,
        AutoButtonColor = false,
        ZIndex = 7,
    }, windowButtons)
    Corner(minimize, 10)
    local minStroke = Stroke(minimize, T.BorderSoft, 1, 0.15)

    local close = New("TextButton", {
        Size = UDim2.fromOffset(36,36),
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        Text = "×",
        Font = FONT.Bold,
        TextSize = 18,
        TextColor3 = T.TextMuted,
        AutoButtonColor = false,
        ZIndex = 7,
    }, windowButtons)
    Corner(close, 10)
    local closeStroke = Stroke(close, T.BorderSoft, 1, 0.15)

    local sidebar = New("Frame", {
        Position = UDim2.fromOffset(0,66),
        Size = UDim2.new(0,196,1,-66),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, main)

    local sideDivider = New("Frame", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,0,0,0),
        Size = UDim2.new(0,1,1,0),
        BackgroundColor3 = T.BorderSoft,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, sidebar)

    local searchHolder = New("Frame", {
        Position = UDim2.fromOffset(14,14),
        Size = UDim2.new(1,-28,0,38),
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, sidebar)
    Corner(searchHolder, 10)
    local searchStroke = Stroke(searchHolder, T.BorderSoft, 1, 0.2)

    local searchIcon = New("TextLabel", {
        Position = UDim2.fromOffset(12,0),
        Size = UDim2.fromOffset(24,38),
        BackgroundTransparency = 1,
        Text = "⌕",
        Font = FONT.Bold,
        TextSize = 17,
        TextColor3 = T.TextDim,
        ZIndex = 6,
    }, searchHolder)

    local searchBox = New("TextBox", {
        Position = UDim2.fromOffset(38,0),
        Size = UDim2.new(1,-48,1,0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search",
        PlaceholderColor3 = T.TextDim,
        TextColor3 = T.Text,
        Font = FONT.Regular,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 6,
    }, searchHolder)

    local tabScroll = New("ScrollingFrame", {
        Position = UDim2.fromOffset(10,64),
        Size = UDim2.new(1,-20,1,-108),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Border,
        ZIndex = 4,
    }, sidebar)
    local tabList = List(tabScroll, 6)

    local versionLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(0,1),
        Position = UDim2.new(0,16,1,-14),
        Size = UDim2.new(1,-32,0,20),
        BackgroundTransparency = 1,
        Text = options.Version or "v3.0",
        Font = FONT.Medium,
        TextSize = 11,
        TextColor3 = T.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, sidebar)

    local content = New("Frame", {
        Position = UDim2.fromOffset(196,66),
        Size = UDim2.new(1,-196,1,-66),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, main)

    local pageHeader = New("Frame", {
        Position = UDim2.fromOffset(22,16),
        Size = UDim2.new(1,-44,0,48),
        BackgroundTransparency = 1,
        ZIndex = 4,
    }, content)

    local pageTitle = New("TextLabel", {
        Size = UDim2.new(1,0,0,25),
        BackgroundTransparency = 1,
        Text = "Home",
        Font = FONT.Bold,
        TextSize = 20,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, pageHeader)

    local pageSubtitle = New("TextLabel", {
        Position = UDim2.fromOffset(0,27),
        Size = UDim2.new(1,0,0,18),
        BackgroundTransparency = 1,
        Text = "Choose a section from the sidebar",
        Font = FONT.Regular,
        TextSize = 12,
        TextColor3 = T.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, pageHeader)

    local pageHost = New("Frame", {
        Position = UDim2.fromOffset(16,72),
        Size = UDim2.new(1,-32,1,-84),
        BackgroundTransparency = 1,
        ZIndex = 4,
    }, content)

    local notifHost = New("Frame", {
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1,-18,1,-18),
        Size = UDim2.fromOffset(320, 420),
        BackgroundTransparency = 1,
        ZIndex = 50,
    }, gui)
    local notifList = List(notifHost, 10)
    notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom

    local minimizedBubble = New("TextButton", {
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1,-20,1,-20),
        Size = UDim2.fromOffset(54,54),
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        Text = "D",
        Font = FONT.Bold,
        TextSize = 18,
        TextColor3 = T.Text,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 100,
    }, gui)
    Corner(minimizedBubble, 17)
    local bubbleStroke = Stroke(minimizedBubble, T.Accent, 1, 0.15)
    MakeDraggable(minimizedBubble, minimizedBubble)

    local function bindTheme(fn)
        table.insert(Window.ThemeBindings, fn)
        fn(Window.Theme)
    end

    bindTheme(function(theme)
        if not main.Parent then return end
        main.BackgroundColor3 = theme.Background
        mainStroke.Color = theme.Border
        header.BackgroundColor3 = theme.Background
        divider.BackgroundColor3 = theme.BorderSoft
        brandDot.BackgroundColor3 = theme.Accent
        brandInner.BackgroundColor3 = theme.Text
        title.TextColor3 = theme.Text
        subtitle.TextColor3 = theme.TextMuted
        sidebar.BackgroundColor3 = theme.Sidebar
        sideDivider.BackgroundColor3 = theme.BorderSoft
        searchHolder.BackgroundColor3 = theme.Surface
        searchStroke.Color = theme.BorderSoft
        searchIcon.TextColor3 = theme.TextDim
        searchBox.PlaceholderColor3 = theme.TextDim
        searchBox.TextColor3 = theme.Text
        tabScroll.ScrollBarImageColor3 = theme.Border
        versionLabel.TextColor3 = theme.TextDim
        pageTitle.TextColor3 = theme.Text
        pageSubtitle.TextColor3 = theme.TextMuted
        minimize.BackgroundColor3 = theme.Surface
        minimize.TextColor3 = theme.TextMuted
        minStroke.Color = theme.BorderSoft
        close.BackgroundColor3 = theme.Surface
        close.TextColor3 = theme.TextMuted
        closeStroke.Color = theme.BorderSoft
        minimizedBubble.BackgroundColor3 = theme.Surface
        minimizedBubble.TextColor3 = theme.Text
        bubbleStroke.Color = theme.Accent
    end)

    function Window:SetTheme(name)
        local preset = THEMES[name]
        if not preset then
            return false, "Unknown theme"
        end
        Window.ThemeName = name
        Window.Theme = cloneTable(preset)
        T = Window.Theme
        for _, fn in ipairs(Window.ThemeBindings) do
            pcall(fn, Window.Theme)
        end
        return true
    end

    function Window:GetTheme()
        return Window.ThemeName
    end

    function Window:GetThemes()
        return DriftwynUI:GetThemes()
    end

    function Window:SetTitle(newTitle, newSubtitle)
        if newTitle ~= nil then
            title.Text = tostring(newTitle)
        end
        if newSubtitle ~= nil then
            subtitle.Text = tostring(newSubtitle)
        end
    end

    function Window:SetVisible(state)
        main.Visible = state == true
        overlay.Visible = state == true
    end

    function Window:Toggle()
        local state = not main.Visible
        main.Visible = state
        overlay.Visible = state
    end

    function Window:Notify(data)
        data = type(data) == "table" and data or {Title = "Driftwyn", Content = tostring(data)}
        local duration = tonumber(data.Duration) or 4

        local card = New("Frame", {
            Size = UDim2.new(1,0,0,82),
            BackgroundColor3 = T.Surface,
            BorderSizePixel = 0,
            ZIndex = 51,
        }, notifHost)
        Corner(card, 13)
        local cStroke = Stroke(card, T.Border, 1, 0.15)

        local accent = New("Frame", {
            Size = UDim2.new(0,3,1,-20),
            Position = UDim2.fromOffset(0,10),
            BackgroundColor3 = data.Color or T.Accent,
            BorderSizePixel = 0,
            ZIndex = 52,
        }, card)
        Corner(accent, 99)

        local nTitle = New("TextLabel", {
            Position = UDim2.fromOffset(16,12),
            Size = UDim2.new(1,-28,0,22),
            BackgroundTransparency = 1,
            Text = data.Title or "Notification",
            Font = FONT.Bold,
            TextSize = 14,
            TextColor3 = T.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
        }, card)

        local nBody = New("TextLabel", {
            Position = UDim2.fromOffset(16,36),
            Size = UDim2.new(1,-28,0,34),
            BackgroundTransparency = 1,
            Text = data.Content or data.Description or "",
            Font = FONT.Regular,
            TextSize = 12,
            TextWrapped = true,
            TextColor3 = T.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 52,
        }, card)

        bindTheme(function(theme)
            if not card.Parent then return end
            card.BackgroundColor3 = theme.Surface
            cStroke.Color = theme.Border
            if not data.Color then accent.BackgroundColor3 = theme.Accent end
            nTitle.TextColor3 = theme.Text
            nBody.TextColor3 = theme.TextMuted
        end)

        card.Position = UDim2.fromOffset(340,0)
        Tween(card,0.22,{Position = UDim2.fromOffset(0,0)},Enum.EasingStyle.Quint)

        task.delay(duration,function()
            if card.Parent then
                Tween(card,0.18,{BackgroundTransparency = 1})
                Tween(nTitle,0.18,{TextTransparency = 1})
                Tween(nBody,0.18,{TextTransparency = 1})
                task.wait(0.19)
                if card.Parent then card:Destroy() end
            end
        end)

        return card
    end

    function Window:RegisterFlag(flag, object)
        if flag and flag ~= "" then
            Window.Registry[flag] = object
        end
    end

    function Window:GetValue(flag)
        local obj = Window.Registry[flag]
        if obj and obj.Get then
            return obj:Get()
        end
        return nil
    end

    function Window:SetValue(flag, value)
        local obj = Window.Registry[flag]
        if obj and obj.Set then
            obj:Set(value)
            return true
        end
        return false
    end

    function Window:ExportConfig()
        local payload = {}
        for flag, obj in pairs(Window.Registry) do
            if obj and obj.Get then
                local ok, value = pcall(obj.Get, obj)
                if ok then
                    if typeof(value) == "Color3" then
                        payload[flag] = {__type = "Color3", R = value.R, G = value.G, B = value.B}
                    elseif typeof(value) == "EnumItem" then
                        payload[flag] = {__type = "EnumItem", EnumType = tostring(value.EnumType), Name = value.Name}
                    else
                        payload[flag] = value
                    end
                end
            end
        end
        return HttpService:JSONEncode(payload)
    end

    function Window:ImportConfig(json)
        local ok, payload = pcall(function()
            return HttpService:JSONDecode(json)
        end)
        if not ok or type(payload) ~= "table" then
            return false, "Invalid config"
        end

        for flag, value in pairs(payload) do
            local obj = Window.Registry[flag]
            if obj and obj.Set then
                if type(value) == "table" and value.__type == "Color3" then
                    value = Color3.new(value.R or 1, value.G or 1, value.B or 1)
                elseif type(value) == "table" and value.__type == "EnumItem" then
                    local enumName = tostring(value.EnumType or ""):match("Enum%.(.+)")
                    if enumName and Enum[enumName] and Enum[enumName][value.Name] then
                        value = Enum[enumName][value.Name]
                    end
                end
                pcall(obj.Set, obj, value)
            end
        end
        return true
    end

    function Window:SaveConfig(name)
        local write = rawget(getgenv and getgenv() or _G, "writefile") or rawget(_G, "writefile")
        if type(write) ~= "function" then
            return false, "writefile unavailable"
        end
        local filename = tostring(name or "driftwyn_config")
        if not filename:match("%.json$") then
            filename = filename .. ".json"
        end
        local ok, err = pcall(write, filename, Window:ExportConfig())
        return ok, err
    end

    function Window:LoadConfig(name)
        local read = rawget(getgenv and getgenv() or _G, "readfile") or rawget(_G, "readfile")
        if type(read) ~= "function" then
            return false, "readfile unavailable"
        end
        local filename = tostring(name or "driftwyn_config")
        if not filename:match("%.json$") then
            filename = filename .. ".json"
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
        if blur and blur.Parent then blur:Destroy() end
        if gui then gui:Destroy() end
    end

    local function applySearch()
        local q = searchBox.Text
        for _, entry in ipairs(Window.SearchEntries) do
            local visible = q == ""
                or Contains(entry.Name, q)
                or Contains(entry.Description, q)
                or Contains(entry.Section, q)
            if entry.Object and entry.Object.Parent then
                entry.Object.Visible = visible
            end
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

    function Window:AddTab(data)
        data = data or {}

        local Tab = {
            Name = data.Name or "Tab",
            Description = data.Description or "",
            Icon = data.Icon or "•",
        }

        local tabButton = New("TextButton", {
            Size = UDim2.new(1,0,0,42),
            BackgroundColor3 = T.Sidebar,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 5,
        }, tabScroll)
        Corner(tabButton, 10)

        local activeBar = New("Frame", {
            Position = UDim2.fromOffset(0,8),
            Size = UDim2.fromOffset(3,26),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 6,
        }, tabButton)
        Corner(activeBar, 99)

        local tabIcon = New("TextLabel", {
            Position = UDim2.fromOffset(12,0),
            Size = UDim2.fromOffset(30,42),
            BackgroundTransparency = 1,
            Text = Tab.Icon,
            Font = FONT.Bold,
            TextSize = 16,
            TextColor3 = T.TextDim,
            ZIndex = 6,
        }, tabButton)

        local tabLabel = New("TextLabel", {
            Position = UDim2.fromOffset(44,0),
            Size = UDim2.new(1,-54,1,0),
            BackgroundTransparency = 1,
            Text = Tab.Name,
            Font = FONT.Medium,
            TextSize = 13,
            TextColor3 = T.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
        }, tabButton)

        local page = New("ScrollingFrame", {
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Border,
            Visible = false,
            ZIndex = 5,
        }, pageHost)

        Pad(page, 6, 8, 2, 14)
        local pageList = List(page, 12)
        SetAutoCanvas(page, pageList, 14)

        bindTheme(function(theme)
            if not tabButton.Parent then return end
            tabButton.BackgroundColor3 = theme.Surface
            activeBar.BackgroundColor3 = theme.Accent
            page.ScrollBarImageColor3 = theme.Border
            if Window.ActiveTab == Tab then
                tabButton.BackgroundTransparency = 0
                activeBar.BackgroundTransparency = 0
                tabIcon.TextColor3 = theme.Text
                tabLabel.TextColor3 = theme.Text
            else
                tabButton.BackgroundTransparency = 1
                activeBar.BackgroundTransparency = 1
                tabIcon.TextColor3 = theme.TextDim
                tabLabel.TextColor3 = theme.TextMuted
            end
        end)

        function Tab:Select()
            if Window.ActiveTab == Tab then return end
            for _, other in ipairs(Window.Tabs) do
                other.Page.Visible = false
                other.Button.BackgroundTransparency = 1
                other.ActiveBar.BackgroundTransparency = 1
                other.IconLabel.TextColor3 = T.TextDim
                other.TextLabel.TextColor3 = T.TextMuted
            end

            Window.ActiveTab = Tab
            page.Visible = true
            tabButton.BackgroundTransparency = 0
            activeBar.BackgroundTransparency = 0
            tabIcon.TextColor3 = T.Text
            tabLabel.TextColor3 = T.Text

            pageTitle.Text = Tab.Name
            pageSubtitle.Text = Tab.Description ~= "" and Tab.Description or "Configure " .. Tab.Name
        end

        tabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        tabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabButton,0.14,{BackgroundTransparency = 0.5})
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(tabButton,0.14,{BackgroundTransparency = 1})
            end
        end)

        Tab.Page = page
        Tab.Button = tabButton
        Tab.ActiveBar = activeBar
        Tab.IconLabel = tabIcon
        Tab.TextLabel = tabLabel
        table.insert(Window.Tabs, Tab)

        function Tab:AddSection(sectionData)
            sectionData = sectionData or {}

            local Section = {
                Name = sectionData.Name or "Section",
            }

            local card = New("Frame", {
                Size = UDim2.new(1,-4,0,56),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.Surface,
                BorderSizePixel = 0,
                ZIndex = 6,
            }, page)
            Corner(card, 13)
            local cardStroke = Stroke(card, T.BorderSoft, 1, 0.15)

            local sectionHeader = New("Frame", {
                Size = UDim2.new(1,0,0,48),
                BackgroundTransparency = 1,
                ZIndex = 7,
            }, card)

            local sectionTitle = New("TextLabel", {
                Position = UDim2.fromOffset(16,9),
                Size = UDim2.new(1,-32,0,20),
                BackgroundTransparency = 1,
                Text = Section.Name,
                Font = FONT.Bold,
                TextSize = 14,
                TextColor3 = T.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            }, sectionHeader)

            local sectionDesc = New("TextLabel", {
                Position = UDim2.fromOffset(16,28),
                Size = UDim2.new(1,-32,0,16),
                BackgroundTransparency = 1,
                Text = sectionData.Description or "",
                Font = FONT.Regular,
                TextSize = 11,
                TextColor3 = T.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = sectionData.Description ~= nil and sectionData.Description ~= "",
                ZIndex = 8,
            }, sectionHeader)

            local controls = New("Frame", {
                Position = UDim2.fromOffset(0,48),
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex = 7,
            }, card)
            local controlsList = List(controls, 0)
            controlsList.HorizontalAlignment = Enum.HorizontalAlignment.Center

            bindTheme(function(theme)
                if not card.Parent then return end
                card.BackgroundColor3 = theme.Surface
                cardStroke.Color = theme.BorderSoft
                sectionTitle.TextColor3 = theme.Text
                sectionDesc.TextColor3 = theme.TextDim
            end)

            local function registerSearch(obj, name, description)
                table.insert(Window.SearchEntries, {
                    Object = obj,
                    Name = name or "",
                    Description = description or "",
                    Section = Section.Name,
                })
            end

            local function makeRow(height)
                local row = New("Frame", {
                    Size = UDim2.new(1,-20,0,height or 54),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, controls)

                local separator = New("Frame", {
                    AnchorPoint = Vector2.new(0,1),
                    Position = UDim2.new(0,6,1,0),
                    Size = UDim2.new(1,-12,0,1),
                    BackgroundColor3 = T.BorderSoft,
                    BackgroundTransparency = 0.3,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, row)

                bindTheme(function(theme)
                    if separator.Parent then
                        separator.BackgroundColor3 = theme.BorderSoft
                    end
                end)

                return row
            end

            local function addTexts(row, name, description, rightWidth)
                local titleLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(8,8),
                    Size = UDim2.new(1,-(rightWidth or 120),0,20),
                    BackgroundTransparency = 1,
                    Text = name or "Control",
                    Font = FONT.Medium,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local descLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(8,29),
                    Size = UDim2.new(1,-(rightWidth or 120),0,17),
                    BackgroundTransparency = 1,
                    Text = description or "",
                    Font = FONT.Regular,
                    TextSize = 11,
                    TextColor3 = T.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = description ~= nil and description ~= "",
                    ZIndex = 9,
                }, row)

                bindTheme(function(theme)
                    if titleLabel.Parent then
                        titleLabel.TextColor3 = theme.Text
                        descLabel.TextColor3 = theme.TextDim
                    end
                end)

                return titleLabel, descLabel
            end

            function Section:AddButton(data)
                data = data or {}
                local row = makeRow(56)
                addTexts(row, data.Name or "Button", data.Description or "", 145)

                local btn = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(112,34),
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    Text = data.Text or "Run",
                    Font = FONT.Medium,
                    TextSize = 12,
                    TextColor3 = T.Text,
                    AutoButtonColor = false,
                    ZIndex = 10,
                }, row)
                Corner(btn, 9)
                local bStroke = Stroke(btn, T.Border, 1, 0.15)

                bindTheme(function(theme)
                    if btn.Parent then
                        btn.BackgroundColor3 = theme.Surface2
                        btn.TextColor3 = theme.Text
                        bStroke.Color = theme.Border
                    end
                end)

                btn.MouseEnter:Connect(function()
                    Tween(btn,0.13,{BackgroundColor3 = T.Surface3})
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn,0.13,{BackgroundColor3 = T.Surface2})
                end)
                btn.MouseButton1Click:Connect(function()
                    SafeCallback(data.Callback)
                end)

                registerSearch(row, data.Name, data.Description)
                return {
                    Object = row,
                    Fire = function() SafeCallback(data.Callback) end
                }
            end

            function Section:AddToggle(data)
                data = data or {}
                local value = data.Default == true
                local row = makeRow(56)
                addTexts(row, data.Name or "Toggle", data.Description or "", 95)

                local toggle = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(48,26),
                    BackgroundColor3 = value and T.Accent or T.Surface3,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 10,
                }, row)
                Corner(toggle, 99)

                local knob = New("Frame", {
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = value and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0),
                    Size = UDim2.fromOffset(20,20),
                    BackgroundColor3 = T.Text,
                    BorderSizePixel = 0,
                    ZIndex = 11,
                }, toggle)
                Corner(knob, 99)

                local Control = {}

                function Control:Set(v)
                    value = v == true
                    Tween(toggle,0.16,{BackgroundColor3 = value and T.Accent or T.Surface3})
                    Tween(knob,0.16,{Position = value and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0)})
                    SafeCallback(data.Callback, value)
                end

                function Control:Get()
                    return value
                end

                toggle.MouseButton1Click:Connect(function()
                    Control:Set(not value)
                end)

                bindTheme(function(theme)
                    if toggle.Parent then
                        toggle.BackgroundColor3 = value and theme.Accent or theme.Surface3
                        knob.BackgroundColor3 = theme.Text
                    end
                end)

                Window:RegisterFlag(data.Flag, Control)
                registerSearch(row, data.Name, data.Description)
                return Control
            end

            function Section:AddSlider(data)
                data = data or {}
                local min = tonumber(data.Min) or 0
                local max = tonumber(data.Max) or 100
                local step = tonumber(data.Step) or 1
                local value = tonumber(data.Default) or min
                value = math.clamp(value,min,max)

                local row = makeRow(70)
                local titleLabel = addTexts(row, data.Name or "Slider", data.Description or "", 90)

                local valueLabel = New("TextLabel", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,8),
                    Size = UDim2.fromOffset(72,20),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    Font = FONT.Medium,
                    TextSize = 12,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 10,
                }, row)

                local bar = New("TextButton", {
                    Position = UDim2.fromOffset(8,52),
                    Size = UDim2.new(1,-16,0,5),
                    BackgroundColor3 = T.Surface3,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 10,
                }, row)
                Corner(bar, 99)

                local fill = New("Frame", {
                    Size = UDim2.fromScale((value-min)/(max-min),1),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 11,
                }, bar)
                Corner(fill, 99)

                local knob = New("Frame", {
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.new((value-min)/(max-min),0,0.5,0),
                    Size = UDim2.fromOffset(14,14),
                    BackgroundColor3 = T.Text,
                    BorderSizePixel = 0,
                    ZIndex = 12,
                }, bar)
                Corner(knob, 99)
                Stroke(knob, T.Border, 1, 0.2)

                local dragging = false
                local Control = {}

                local function applyFromX(x, fire)
                    local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X,1), 0, 1)
                    local raw = min + (max-min)*rel
                    local snapped = math.floor((raw-min)/step + 0.5)*step + min
                    value = math.clamp(snapped,min,max)
                    local pct = (value-min)/(max-min)
                    fill.Size = UDim2.fromScale(pct,1)
                    knob.Position = UDim2.new(pct,0,0.5,0)
                    valueLabel.Text = tostring(value)
                    if fire then SafeCallback(data.Callback, value) end
                end

                function Control:Set(v)
                    v = tonumber(v)
                    if not v then return end
                    value = math.clamp(v,min,max)
                    local pct = (value-min)/(max-min)
                    fill.Size = UDim2.fromScale(pct,1)
                    knob.Position = UDim2.new(pct,0,0.5,0)
                    valueLabel.Text = tostring(value)
                    SafeCallback(data.Callback, value)
                end

                function Control:Get()
                    return value
                end

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        applyFromX(input.Position.X,true)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    ) then
                        applyFromX(input.Position.X,true)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                bindTheme(function(theme)
                    if bar.Parent then
                        bar.BackgroundColor3 = theme.Surface3
                        fill.BackgroundColor3 = theme.Accent
                        knob.BackgroundColor3 = theme.Text
                        valueLabel.TextColor3 = theme.TextMuted
                    end
                end)

                Window:RegisterFlag(data.Flag, Control)
                registerSearch(row, data.Name, data.Description)
                return Control
            end

            function Section:AddDropdown(data)
                data = data or {}
                local values = data.Values or data.Options or {}
                local value = data.Default or values[1]
                local open = false

                local row = makeRow(60)
                addTexts(row, data.Name or "Dropdown", data.Description or "", 210)

                local selector = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(180,36),
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 10,
                }, row)
                Corner(selector, 9)
                local sStroke = Stroke(selector, T.Border, 1, 0.15)

                local selectedLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(10,0),
                    Size = UDim2.new(1,-34,1,0),
                    BackgroundTransparency = 1,
                    Text = tostring(value or "Select"),
                    Font = FONT.Regular,
                    TextSize = 12,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 11,
                }, selector)

                local arrow = New("TextLabel", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,0),
                    Size = UDim2.fromOffset(20,36),
                    BackgroundTransparency = 1,
                    Text = "⌄",
                    Font = FONT.Bold,
                    TextSize = 14,
                    TextColor3 = T.TextDim,
                    ZIndex = 11,
                }, selector)

                local menu = New("Frame", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,50),
                    Size = UDim2.fromOffset(180,0),
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 30,
                }, row)
                Corner(menu, 9)
                local mStroke = Stroke(menu, T.Border, 1, 0.1)
                local menuList = List(menu, 2)
                Pad(menu,4,4,4,4)

                local Control = {}

                local function closeMenu()
                    open = false
                    Tween(menu,0.14,{Size = UDim2.fromOffset(180,0)})
                    task.delay(0.14,function()
                        if not open and menu.Parent then menu.Visible = false end
                    end)
                    Tween(arrow,0.14,{Rotation = 0})
                end

                local function rebuild()
                    for _, c in ipairs(menu:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end

                    for _, option in ipairs(values) do
                        local optionBtn = New("TextButton", {
                            Size = UDim2.new(1,0,0,30),
                            BackgroundColor3 = T.Surface2,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Text = tostring(option),
                            Font = FONT.Regular,
                            TextSize = 12,
                            TextColor3 = T.TextMuted,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            ZIndex = 31,
                        }, menu)
                        Pad(optionBtn,8,4,0,0)
                        Corner(optionBtn,7)

                        optionBtn.MouseEnter:Connect(function()
                            Tween(optionBtn,0.12,{BackgroundTransparency = 0, BackgroundColor3 = T.Surface3})
                        end)
                        optionBtn.MouseLeave:Connect(function()
                            Tween(optionBtn,0.12,{BackgroundTransparency = 1})
                        end)
                        optionBtn.MouseButton1Click:Connect(function()
                            Control:Set(option)
                            closeMenu()
                        end)
                    end
                end

                function Control:Set(v)
                    value = v
                    selectedLabel.Text = tostring(v or "Select")
                    SafeCallback(data.Callback, value)
                end

                function Control:Get()
                    return value
                end

                function Control:SetValues(newValues)
                    values = newValues or {}
                    rebuild()
                end

                selector.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        rebuild()
                        local h = math.min(#values*32 + 8, 168)
                        menu.Visible = true
                        Tween(menu,0.16,{Size = UDim2.fromOffset(180,h)})
                        Tween(arrow,0.14,{Rotation = 180})
                    else
                        closeMenu()
                    end
                end)

                bindTheme(function(theme)
                    if selector.Parent then
                        selector.BackgroundColor3 = theme.Surface2
                        sStroke.Color = theme.Border
                        selectedLabel.TextColor3 = theme.Text
                        arrow.TextColor3 = theme.TextDim
                        menu.BackgroundColor3 = theme.Surface2
                        mStroke.Color = theme.Border
                    end
                end)

                Window:RegisterFlag(data.Flag, Control)
                registerSearch(row, data.Name, data.Description)
                return Control
            end

            function Section:AddMultiDropdown(data)
                data = data or {}
                local values = data.Values or data.Options or {}
                local selected = {}
                for _, v in ipairs(data.Default or {}) do
                    selected[v] = true
                end

                local row = makeRow(60)
                addTexts(row, data.Name or "Multi Dropdown", data.Description or "", 210)

                local selector = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(180,36),
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 10,
                }, row)
                Corner(selector, 9)
                local sStroke = Stroke(selector, T.Border, 1, 0.15)

                local selectedLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(10,0),
                    Size = UDim2.new(1,-34,1,0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Font = FONT.Regular,
                    TextSize = 12,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 11,
                }, selector)

                local arrow = New("TextLabel", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,0),
                    Size = UDim2.fromOffset(20,36),
                    BackgroundTransparency = 1,
                    Text = "⌄",
                    Font = FONT.Bold,
                    TextSize = 14,
                    TextColor3 = T.TextDim,
                    ZIndex = 11,
                }, selector)

                local menu = New("Frame", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,50),
                    Size = UDim2.fromOffset(180,0),
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 30,
                }, row)
                Corner(menu, 9)
                local mStroke = Stroke(menu, T.Border, 1, 0.1)
                local menuList = List(menu, 2)
                Pad(menu,4,4,4,4)

                local open = false
                local Control = {}

                local function asArray()
                    local out = {}
                    for _, option in ipairs(values) do
                        if selected[option] then
                            table.insert(out,option)
                        end
                    end
                    return out
                end

                local function refreshLabel()
                    local arr = asArray()
                    selectedLabel.Text = #arr > 0 and table.concat(arr,", ") or "Select"
                end

                local function rebuild()
                    for _, c in ipairs(menu:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end

                    for _, option in ipairs(values) do
                        local optionBtn = New("TextButton", {
                            Size = UDim2.new(1,0,0,30),
                            BackgroundColor3 = selected[option] and T.Surface3 or T.Surface2,
                            BackgroundTransparency = selected[option] and 0 or 1,
                            BorderSizePixel = 0,
                            Text = (selected[option] and "✓  " or "") .. tostring(option),
                            Font = FONT.Regular,
                            TextSize = 12,
                            TextColor3 = selected[option] and T.Text or T.TextMuted,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false,
                            ZIndex = 31,
                        }, menu)
                        Pad(optionBtn,8,4,0,0)
                        Corner(optionBtn,7)
                        optionBtn.MouseButton1Click:Connect(function()
                            selected[option] = not selected[option]
                            refreshLabel()
                            rebuild()
                            SafeCallback(data.Callback, asArray())
                        end)
                    end
                end

                function Control:Set(v)
                    selected = {}
                    if type(v) == "table" then
                        for _, item in ipairs(v) do
                            selected[item] = true
                        end
                    end
                    refreshLabel()
                    rebuild()
                    SafeCallback(data.Callback, asArray())
                end

                function Control:Get()
                    return asArray()
                end

                selector.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        rebuild()
                        local h = math.min(#values*32 + 8, 168)
                        menu.Visible = true
                        Tween(menu,0.16,{Size = UDim2.fromOffset(180,h)})
                        Tween(arrow,0.14,{Rotation = 180})
                    else
                        Tween(menu,0.14,{Size = UDim2.fromOffset(180,0)})
                        Tween(arrow,0.14,{Rotation = 0})
                        task.delay(0.14,function()
                            if not open and menu.Parent then menu.Visible = false end
                        end)
                    end
                end)

                bindTheme(function(theme)
                    if selector.Parent then
                        selector.BackgroundColor3 = theme.Surface2
                        sStroke.Color = theme.Border
                        selectedLabel.TextColor3 = theme.Text
                        arrow.TextColor3 = theme.TextDim
                        menu.BackgroundColor3 = theme.Surface2
                        mStroke.Color = theme.Border
                    end
                end)

                refreshLabel()
                Window:RegisterFlag(data.Flag, Control)
                registerSearch(row, data.Name, data.Description)
                return Control
            end

            function Section:AddTextbox(data)
                data = data or {}
                local value = tostring(data.Default or "")

                local row = makeRow(62)
                addTexts(row, data.Name or "Textbox", data.Description or "", 250)

                local boxHolder = New("Frame", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(220,36),
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, row)
                Corner(boxHolder,9)
                local bStroke = Stroke(boxHolder,T.Border,1,0.15)

                local box = New("TextBox", {
                    Position = UDim2.fromOffset(10,0),
                    Size = UDim2.new(1,-20,1,0),
                    BackgroundTransparency = 1,
                    Text = value,
                    PlaceholderText = data.Placeholder or "Type here...",
                    PlaceholderColor3 = T.TextDim,
                    TextColor3 = T.Text,
                    Font = FONT.Regular,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    ZIndex = 11,
                }, boxHolder)

                local Control = {}

                function Control:Set(v)
                    value = tostring(v or "")
                    box.Text = value
                    SafeCallback(data.Callback, value)
                end

                function Control:Get()
                    return value
                end

                box.FocusLost:Connect(function(enterPressed)
                    value = box.Text
                    if data.FinishedOnly == false or enterPressed or data.FinishedOnly == nil then
                        SafeCallback(data.Callback, value, enterPressed)
                    end
                end)

                bindTheme(function(theme)
                    if boxHolder.Parent then
                        boxHolder.BackgroundColor3 = theme.Surface2
                        bStroke.Color = theme.Border
                        box.TextColor3 = theme.Text
                        box.PlaceholderColor3 = theme.TextDim
                    end
                end)

                Window:RegisterFlag(data.Flag, Control)
                registerSearch(row, data.Name, data.Description)
                return Control
            end

            function Section:AddKeybind(data)
                data = data or {}
                local value = data.Default or Enum.KeyCode.RightControl
                local listening = false

                local row = makeRow(56)
                addTexts(row,data.Name or "Keybind",data.Description or "",145)

                local bindBtn = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(112,34),
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    Text = value.Name,
                    Font = FONT.Medium,
                    TextSize = 12,
                    TextColor3 = T.Text,
                    AutoButtonColor = false,
                    ZIndex = 10,
                }, row)
                Corner(bindBtn,9)
                local bStroke = Stroke(bindBtn,T.Border,1,0.15)

                local Control = {}

                function Control:Set(v)
                    if typeof(v) == "EnumItem" then
                        value = v
                        bindBtn.Text = v.Name
                    end
                end

                function Control:Get()
                    return value
                end

                bindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    bindBtn.Text = "Press a key"
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            listening = false
                            Control:Set(input.KeyCode)
                            SafeCallback(data.Changed, value)
                        end
                        return
                    end
                    if not processed and input.KeyCode == value then
                        SafeCallback(data.Callback, value)
                    end
                end)

                bindTheme(function(theme)
                    if bindBtn.Parent then
                        bindBtn.BackgroundColor3 = theme.Surface2
                        bStroke.Color = theme.Border
                        bindBtn.TextColor3 = theme.Text
                    end
                end)

                Window:RegisterFlag(data.Flag, Control)
                registerSearch(row,data.Name,data.Description)
                return Control
            end

            function Section:AddColorPicker(data)
                data = data or {}
                local value = data.Default or Color3.fromRGB(225,44,62)

                local row = makeRow(56)
                addTexts(row,data.Name or "Color",data.Description or "",120)

                local preview = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(76,34),
                    BackgroundColor3 = value,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 10,
                }, row)
                Corner(preview,9)
                local pStroke = Stroke(preview,T.Border,1,0.1)

                local popup = New("Frame", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,48),
                    Size = UDim2.fromOffset(220,0),
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 30,
                }, row)
                Corner(popup,10)
                local popStroke = Stroke(popup,T.Border,1,0.1)

                local hue, sat, val = Color3.toHSV(value)
                local open = false
                local Control = {}

                local sv = New("TextButton", {
                    Position = UDim2.fromOffset(10,10),
                    Size = UDim2.fromOffset(150,110),
                    BackgroundColor3 = Color3.fromHSV(hue,1,1),
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 31,
                }, popup)
                Corner(sv,8)

                local whiteGrad = New("UIGradient", {
                    Color = ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1)),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0,0),
                        NumberSequenceKeypoint.new(1,1),
                    }),
                    Rotation = 0,
                }, sv)

                local blackOverlay = New("Frame", {
                    Size = UDim2.fromScale(1,1),
                    BackgroundColor3 = Color3.new(0,0,0),
                    BackgroundTransparency = 1-val,
                    BorderSizePixel = 0,
                    ZIndex = 32,
                }, sv)
                Corner(blackOverlay,8)

                local hueBar = New("TextButton", {
                    Position = UDim2.fromOffset(170,10),
                    Size = UDim2.fromOffset(38,110),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 31,
                }, popup)
                Corner(hueBar,8)
                New("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00,Color3.fromHSV(0.00,1,1)),
                        ColorSequenceKeypoint.new(0.17,Color3.fromHSV(0.17,1,1)),
                        ColorSequenceKeypoint.new(0.33,Color3.fromHSV(0.33,1,1)),
                        ColorSequenceKeypoint.new(0.50,Color3.fromHSV(0.50,1,1)),
                        ColorSequenceKeypoint.new(0.67,Color3.fromHSV(0.67,1,1)),
                        ColorSequenceKeypoint.new(0.83,Color3.fromHSV(0.83,1,1)),
                        ColorSequenceKeypoint.new(1.00,Color3.fromHSV(1.00,1,1)),
                    }),
                    Rotation = 90,
                }, hueBar)

                local function refresh(fire)
                    value = Color3.fromHSV(hue,sat,val)
                    preview.BackgroundColor3 = value
                    sv.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                    blackOverlay.BackgroundTransparency = 1-val
                    if fire then SafeCallback(data.Callback,value) end
                end

                local svDrag, hueDrag = false,false

                sv.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        svDrag = true
                    end
                end)

                hueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        hueDrag = true
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch then
                        if svDrag then
                            local x = math.clamp((input.Position.X-sv.AbsolutePosition.X)/sv.AbsoluteSize.X,0,1)
                            local y = math.clamp((input.Position.Y-sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y,0,1)
                            sat = x
                            val = 1-y
                            refresh(true)
                        elseif hueDrag then
                            hue = math.clamp((input.Position.Y-hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y,0,1)
                            refresh(true)
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        svDrag = false
                        hueDrag = false
                    end
                end)

                function Control:Set(v)
                    if typeof(v) == "Color3" then
                        value = v
                        hue,sat,val = Color3.toHSV(v)
                        refresh(true)
                    end
                end

                function Control:Get()
                    return value
                end

                preview.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        popup.Visible = true
                        Tween(popup,0.16,{Size = UDim2.fromOffset(220,132)})
                    else
                        Tween(popup,0.14,{Size = UDim2.fromOffset(220,0)})
                        task.delay(0.14,function()
                            if not open and popup.Parent then popup.Visible = false end
                        end)
                    end
                end)

                bindTheme(function(theme)
                    if popup.Parent then
                        pStroke.Color = theme.Border
                        popup.BackgroundColor3 = theme.Surface2
                        popStroke.Color = theme.Border
                    end
                end)

                Window:RegisterFlag(data.Flag,Control)
                registerSearch(row,data.Name,data.Description)
                return Control
            end

            function Section:AddLabel(text)
                local row = makeRow(42)
                local label = New("TextLabel", {
                    Position = UDim2.fromOffset(8,0),
                    Size = UDim2.new(1,-16,1,0),
                    BackgroundTransparency = 1,
                    Text = tostring(text or ""),
                    Font = FONT.Medium,
                    TextSize = 12,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                bindTheme(function(theme)
                    if label.Parent then label.TextColor3 = theme.TextMuted end
                end)

                return {
                    Set = function(_,v) label.Text = tostring(v or "") end,
                    Get = function() return label.Text end,
                    Object = row,
                }
            end

            function Section:AddParagraph(data)
                data = type(data) == "table" and data or {Title = "Info", Content = tostring(data or "")}

                local row = New("Frame", {
                    Size = UDim2.new(1,-20,0,76),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = T.Surface2,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, controls)
                Corner(row,10)
                local rStroke = Stroke(row,T.BorderSoft,1,0.2)
                Pad(row,12,12,10,10)

                local pTitle = New("TextLabel", {
                    Size = UDim2.new(1,0,0,20),
                    BackgroundTransparency = 1,
                    Text = data.Title or data.Name or "Info",
                    Font = FONT.Bold,
                    TextSize = 12,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local pBody = New("TextLabel", {
                    Position = UDim2.fromOffset(0,24),
                    Size = UDim2.new(1,0,0,42),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = data.Content or data.Description or "",
                    Font = FONT.Regular,
                    TextSize = 11,
                    TextWrapped = true,
                    TextColor3 = T.TextMuted,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    ZIndex = 9,
                }, row)

                bindTheme(function(theme)
                    if row.Parent then
                        row.BackgroundColor3 = theme.Surface2
                        rStroke.Color = theme.BorderSoft
                        pTitle.TextColor3 = theme.Text
                        pBody.TextColor3 = theme.TextMuted
                    end
                end)

                registerSearch(row,pTitle.Text,pBody.Text)
                return row
            end

            function Section:AddDivider(text)
                local row = makeRow(34)

                if text and tostring(text) ~= "" then
                    local label = New("TextLabel", {
                        Position = UDim2.fromOffset(8,0),
                        Size = UDim2.new(1,-16,1,0),
                        BackgroundTransparency = 1,
                        Text = tostring(text),
                        Font = FONT.Bold,
                        TextSize = 10,
                        TextColor3 = T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 9,
                    }, row)
                    bindTheme(function(theme)
                        if label.Parent then label.TextColor3 = theme.TextDim end
                    end)
                end

                return row
            end

            return Section
        end

        if not Window.ActiveTab then
            Tab:Select()
        end

        return Tab
    end

    SetAutoCanvas(tabScroll, tabList, 8)

    local minimized = false

    minimize.MouseButton1Click:Connect(function()
        minimized = true
        main.Visible = false
        overlay.Visible = false
        minimizedBubble.Visible = true
        minimizedBubble.Size = UDim2.fromOffset(42,42)
        Tween(minimizedBubble,0.18,{Size = UDim2.fromOffset(54,54)},Enum.EasingStyle.Back)
    end)

    minimizedBubble.MouseButton1Click:Connect(function()
        minimized = false
        minimizedBubble.Visible = false
        main.Visible = true
        overlay.Visible = true
        local finalSize = main.Size
        main.Size = UDim2.new(finalSize.X.Scale,finalSize.X.Offset-20,finalSize.Y.Scale,finalSize.Y.Offset-20)
        Tween(main,0.2,{Size = finalSize},Enum.EasingStyle.Back)
    end)

    close.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)

    MakeDraggable(main,header)

    local toggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    UserInputService.InputBegan:Connect(function(input,processed)
        if processed or Window.Destroyed then return end
        if input.KeyCode == toggleKey then
            if minimizedBubble.Visible then
                minimizedBubble.Visible = false
                main.Visible = true
                overlay.Visible = true
            else
                Window:Toggle()
            end
        end
    end)

    minimize.MouseEnter:Connect(function()
        Tween(minimize,0.12,{BackgroundColor3 = T.Surface2, TextColor3 = T.Text})
    end)
    minimize.MouseLeave:Connect(function()
        Tween(minimize,0.12,{BackgroundColor3 = T.Surface, TextColor3 = T.TextMuted})
    end)

    close.MouseEnter:Connect(function()
        Tween(close,0.12,{BackgroundColor3 = T.Danger, TextColor3 = Color3.new(1,1,1)})
    end)
    close.MouseLeave:Connect(function()
        Tween(close,0.12,{BackgroundColor3 = T.Surface, TextColor3 = T.TextMuted})
    end)

    searchBox.Focused:Connect(function()
        Tween(searchHolder,0.14,{BackgroundColor3 = T.Surface2})
        searchStroke.Color = T.Accent
    end)
    searchBox.FocusLost:Connect(function()
        Tween(searchHolder,0.14,{BackgroundColor3 = T.Surface})
        searchStroke.Color = T.BorderSoft
    end)

    local finalSize = main.Size
    main.Size = UDim2.new(finalSize.X.Scale,finalSize.X.Offset-20,finalSize.Y.Scale,finalSize.Y.Offset-20)
    main.BackgroundTransparency = 1
    overlay.BackgroundTransparency = 1

    Tween(overlay,0.18,{BackgroundTransparency = 0.55})
    Tween(main,0.22,{Size = finalSize, BackgroundTransparency = 0},Enum.EasingStyle.Back)

    Window.Gui = gui
    Window.Main = main
    Window.SearchBox = searchBox
    Window.MinimizedBubble = minimizedBubble

    return Window
end

return DriftwynUI
