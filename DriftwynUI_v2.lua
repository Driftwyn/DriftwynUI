


--[[
    DRIFTWYN UI LIBRARY v5.1
    Premium red/black cyber rebuild with neon accents, layered cards, and branded icon support.

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
        Background = Color3.fromRGB(5, 6, 8),
        Sidebar = Color3.fromRGB(7, 8, 11),
        Surface = Color3.fromRGB(10, 12, 16),
        Surface2 = Color3.fromRGB(14, 16, 21),
        Surface3 = Color3.fromRGB(20, 22, 29),
        Border = Color3.fromRGB(89, 27, 37),
        BorderSoft = Color3.fromRGB(43, 28, 34),
        Accent = Color3.fromRGB(255, 48, 67),
        AccentDark = Color3.fromRGB(151, 15, 31),
        Text = Color3.fromRGB(248, 248, 250),
        TextMuted = Color3.fromRGB(166, 168, 178),
        TextDim = Color3.fromRGB(100, 103, 115),
        Success = Color3.fromRGB(73, 218, 128),
        Warning = Color3.fromRGB(245, 188, 69),
        Danger = Color3.fromRGB(255, 66, 82),
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

    Crimson = {
        Background = Color3.fromRGB(13, 8, 10),
        Sidebar = Color3.fromRGB(17, 10, 13),
        Surface = Color3.fromRGB(23, 14, 17),
        Surface2 = Color3.fromRGB(29, 17, 21),
        Surface3 = Color3.fromRGB(36, 20, 25),
        Border = Color3.fromRGB(63, 36, 43),
        BorderSoft = Color3.fromRGB(44, 27, 32),
        Accent = Color3.fromRGB(242, 54, 76),
        AccentDark = Color3.fromRGB(164, 24, 44),
        Text = Color3.fromRGB(250, 242, 244),
        TextMuted = Color3.fromRGB(181, 148, 155),
        TextDim = Color3.fromRGB(126, 94, 101),
        Success = Color3.fromRGB(79, 205, 126),
        Warning = Color3.fromRGB(236, 184, 72),
        Danger = Color3.fromRGB(242, 71, 84),
    },

    Purple = {
        Background = Color3.fromRGB(11, 9, 16),
        Sidebar = Color3.fromRGB(15, 12, 21),
        Surface = Color3.fromRGB(21, 17, 29),
        Surface2 = Color3.fromRGB(27, 21, 37),
        Surface3 = Color3.fromRGB(34, 26, 47),
        Border = Color3.fromRGB(57, 46, 73),
        BorderSoft = Color3.fromRGB(39, 32, 51),
        Accent = Color3.fromRGB(157, 98, 255),
        AccentDark = Color3.fromRGB(98, 53, 174),
        Text = Color3.fromRGB(246, 242, 252),
        TextMuted = Color3.fromRGB(169, 157, 187),
        TextDim = Color3.fromRGB(112, 101, 130),
        Success = Color3.fromRGB(82, 210, 132),
        Warning = Color3.fromRGB(238, 188, 76),
        Danger = Color3.fromRGB(232, 78, 101),
    },

    Ocean = {
        Background = Color3.fromRGB(7, 13, 17),
        Sidebar = Color3.fromRGB(9, 17, 22),
        Surface = Color3.fromRGB(13, 23, 29),
        Surface2 = Color3.fromRGB(16, 29, 36),
        Surface3 = Color3.fromRGB(20, 36, 45),
        Border = Color3.fromRGB(37, 61, 73),
        BorderSoft = Color3.fromRGB(26, 44, 54),
        Accent = Color3.fromRGB(48, 181, 222),
        AccentDark = Color3.fromRGB(27, 111, 143),
        Text = Color3.fromRGB(239, 248, 251),
        TextMuted = Color3.fromRGB(145, 174, 184),
        TextDim = Color3.fromRGB(90, 119, 130),
        Success = Color3.fromRGB(72, 210, 142),
        Warning = Color3.fromRGB(239, 188, 77),
        Danger = Color3.fromRGB(231, 80, 92),
    },

    Emerald = {
        Background = Color3.fromRGB(8, 14, 12),
        Sidebar = Color3.fromRGB(10, 18, 15),
        Surface = Color3.fromRGB(14, 25, 21),
        Surface2 = Color3.fromRGB(17, 31, 26),
        Surface3 = Color3.fromRGB(21, 39, 32),
        Border = Color3.fromRGB(38, 67, 56),
        BorderSoft = Color3.fromRGB(27, 48, 40),
        Accent = Color3.fromRGB(63, 207, 139),
        AccentDark = Color3.fromRGB(31, 127, 83),
        Text = Color3.fromRGB(240, 249, 245),
        TextMuted = Color3.fromRGB(149, 181, 166),
        TextDim = Color3.fromRGB(94, 124, 110),
        Success = Color3.fromRGB(63, 207, 139),
        Warning = Color3.fromRGB(237, 188, 72),
        Danger = Color3.fromRGB(230, 80, 92),
    },

    Rose = {
        Background = Color3.fromRGB(16, 10, 14),
        Sidebar = Color3.fromRGB(21, 13, 18),
        Surface = Color3.fromRGB(29, 18, 25),
        Surface2 = Color3.fromRGB(36, 22, 31),
        Surface3 = Color3.fromRGB(45, 27, 38),
        Border = Color3.fromRGB(73, 45, 63),
        BorderSoft = Color3.fromRGB(51, 32, 44),
        Accent = Color3.fromRGB(241, 103, 154),
        AccentDark = Color3.fromRGB(160, 58, 98),
        Text = Color3.fromRGB(252, 243, 247),
        TextMuted = Color3.fromRGB(190, 156, 171),
        TextDim = Color3.fromRGB(132, 103, 116),
        Success = Color3.fromRGB(79, 205, 126),
        Warning = Color3.fromRGB(237, 186, 72),
        Danger = Color3.fromRGB(234, 83, 104),
    },

    Amber = {
        Background = Color3.fromRGB(15, 12, 7),
        Sidebar = Color3.fromRGB(20, 16, 9),
        Surface = Color3.fromRGB(28, 22, 12),
        Surface2 = Color3.fromRGB(35, 27, 14),
        Surface3 = Color3.fromRGB(44, 34, 17),
        Border = Color3.fromRGB(72, 56, 29),
        BorderSoft = Color3.fromRGB(51, 40, 22),
        Accent = Color3.fromRGB(240, 172, 54),
        AccentDark = Color3.fromRGB(157, 104, 23),
        Text = Color3.fromRGB(252, 247, 236),
        TextMuted = Color3.fromRGB(189, 172, 139),
        TextDim = Color3.fromRGB(129, 113, 83),
        Success = Color3.fromRGB(82, 204, 126),
        Warning = Color3.fromRGB(240, 172, 54),
        Danger = Color3.fromRGB(232, 78, 83),
    },

    Cyber = {
        Background = Color3.fromRGB(5, 9, 12),
        Sidebar = Color3.fromRGB(7, 13, 17),
        Surface = Color3.fromRGB(9, 19, 24),
        Surface2 = Color3.fromRGB(11, 25, 31),
        Surface3 = Color3.fromRGB(14, 32, 40),
        Border = Color3.fromRGB(25, 65, 75),
        BorderSoft = Color3.fromRGB(17, 45, 53),
        Accent = Color3.fromRGB(0, 232, 210),
        AccentDark = Color3.fromRGB(0, 132, 123),
        Text = Color3.fromRGB(231, 255, 252),
        TextMuted = Color3.fromRGB(127, 187, 181),
        TextDim = Color3.fromRGB(77, 129, 125),
        Success = Color3.fromRGB(0, 232, 161),
        Warning = Color3.fromRGB(242, 198, 66),
        Danger = Color3.fromRGB(244, 76, 104),
    },

    AMOLED = {
        Background = Color3.fromRGB(0, 0, 0),
        Sidebar = Color3.fromRGB(3, 3, 3),
        Surface = Color3.fromRGB(8, 8, 8),
        Surface2 = Color3.fromRGB(13, 13, 13),
        Surface3 = Color3.fromRGB(19, 19, 19),
        Border = Color3.fromRGB(39, 39, 39),
        BorderSoft = Color3.fromRGB(26, 26, 26),
        Accent = Color3.fromRGB(225, 44, 62),
        AccentDark = Color3.fromRGB(139, 22, 37),
        Text = Color3.fromRGB(248, 248, 248),
        TextMuted = Color3.fromRGB(157, 157, 157),
        TextDim = Color3.fromRGB(98, 98, 98),
        Success = Color3.fromRGB(72, 211, 125),
        Warning = Color3.fromRGB(238, 188, 70),
        Danger = Color3.fromRGB(234, 73, 86),
    },

    Discord = {
        Background = Color3.fromRGB(30, 31, 34),
        Sidebar = Color3.fromRGB(24, 25, 28),
        Surface = Color3.fromRGB(43, 45, 49),
        Surface2 = Color3.fromRGB(49, 51, 56),
        Surface3 = Color3.fromRGB(56, 58, 64),
        Border = Color3.fromRGB(72, 74, 81),
        BorderSoft = Color3.fromRGB(54, 56, 62),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentDark = Color3.fromRGB(65, 76, 187),
        Text = Color3.fromRGB(242, 243, 245),
        TextMuted = Color3.fromRGB(181, 186, 193),
        TextDim = Color3.fromRGB(148, 155, 164),
        Success = Color3.fromRGB(35, 165, 90),
        Warning = Color3.fromRGB(240, 178, 50),
        Danger = Color3.fromRGB(237, 66, 69),
    },

    Light = {
        Background = Color3.fromRGB(242, 244, 248),
        Sidebar = Color3.fromRGB(234, 237, 242),
        Surface = Color3.fromRGB(255, 255, 255),
        Surface2 = Color3.fromRGB(247, 248, 251),
        Surface3 = Color3.fromRGB(235, 238, 244),
        Border = Color3.fromRGB(202, 207, 218),
        BorderSoft = Color3.fromRGB(220, 224, 232),
        Accent = Color3.fromRGB(213, 49, 68),
        AccentDark = Color3.fromRGB(151, 29, 45),
        Text = Color3.fromRGB(31, 34, 42),
        TextMuted = Color3.fromRGB(94, 101, 115),
        TextDim = Color3.fromRGB(130, 137, 150),
        Success = Color3.fromRGB(46, 160, 91),
        Warning = Color3.fromRGB(190, 132, 31),
        Danger = Color3.fromRGB(206, 55, 69),
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
            duration or 0.20,
            style or Enum.EasingStyle.Quint,
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
        Name = options.Name or "DriftwynUI_v5_1",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = options.DisplayOrder or 75,
    }, PlayerGui)

    local overlay = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.42,
        BorderSizePixel = 0,
        ZIndex = 0,
    }, gui)

    local blur
    if options.Blur == true then
        blur = New("BlurEffect", {
            Name = "DriftwynUI_v5_1_Blur",
            Size = options.BlurSize or 8,
            Enabled = true,
        }, Lighting)
    end

    local main = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = options.Size or UDim2.fromOffset(980, 620),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
    }, gui)
    Corner(main, 22)
    local mainStroke = Stroke(main, T.Accent, 1.2, 0.15)
    local outerGlow = New("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.new(1,-2,1,-2),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, main)
    Corner(outerGlow, 22)
    local outerGlowStroke = Stroke(outerGlow, T.Accent, 2, 0.68)

    local techOverlay = New("Frame", {
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, main)

    for i = 1, 7 do
        local line = New("Frame", {
            Position = UDim2.new(0, 210 + (i * 88), 0, 72),
            Size = UDim2.new(0,1,1,-72),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 0.965,
            BorderSizePixel = 0,
            ZIndex = 2,
        }, techOverlay)
    end

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
        Size = UDim2.new(1, 0, 0, 82),
        BackgroundColor3 = T.Background,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, main)

    local headerGradient = New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(205,205,205)),
        }),
        Rotation = 90,
    }, header)

    local divider = New("Frame", {
        AnchorPoint = Vector2.new(0,1),
        Position = UDim2.new(0,0,1,0),
        Size = UDim2.new(1,0,0,1),
        BackgroundColor3 = T.BorderSoft,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, header)

    local iconAsset = tostring(options.Icon or "rbxassetid://102915977367334")
    if not iconAsset:find("rbxassetid://", 1, true) then
        iconAsset = "rbxassetid://" .. iconAsset
    end

    local brandDot = New("ImageLabel", {
        Position = UDim2.fromOffset(22, 12),
        Size = UDim2.fromOffset(58, 58),
        BackgroundColor3 = T.Surface2,
        BorderSizePixel = 0,
        Image = iconAsset,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 6,
    }, header)
    Corner(brandDot, 18)
    local brandStroke = Stroke(brandDot, T.Accent, 1.5, 0.08)

    local brandGlow = New("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.new(1,8,1,8),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, brandDot)
    Corner(brandGlow, 14)

    local title = New("TextLabel", {
        Position = UDim2.fromOffset(94, 17),
        Size = UDim2.fromOffset(360, 27),
        BackgroundTransparency = 1,
        Text = options.Title or "Driftwyn",
        Font = FONT.Bold,
        TextSize = 22,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, header)

    local subtitle = New("TextLabel", {
        Position = UDim2.fromOffset(94, 47),
        Size = UDim2.fromOffset(380, 18),
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
        Position = UDim2.new(1,-18,0,22),
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
        Position = UDim2.fromOffset(0,82),
        Size = UDim2.new(0,238,1,-82),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, main)

    local sideBrandCard = New("Frame", {
        AnchorPoint = Vector2.new(0,1),
        Position = UDim2.new(0,16,1,-72),
        Size = UDim2.fromOffset(202,150),
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, sidebar)
    Corner(sideBrandCard, 18)
    local sideBrandStroke = Stroke(sideBrandCard, T.BorderSoft, 1, 0.55)

    local sideBrandImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.48),
        Size = UDim2.fromOffset(116,116),
        BackgroundTransparency = 1,
        Image = iconAsset,
        ImageTransparency = 0.05,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 4,
    }, sideBrandCard)

    local sideBrandCaption = New("TextLabel", {
        AnchorPoint = Vector2.new(0.5,1),
        Position = UDim2.new(0.5,0,1,-8),
        Size = UDim2.new(1,-20,0,20),
        BackgroundTransparency = 1,
        Text = "DRIFTWYN HUB",
        Font = FONT.Bold,
        TextSize = 11,
        TextColor3 = T.Accent,
        TextTransparency = 0.15,
        ZIndex = 4,
    }, sideBrandCard)

    local sideDivider = New("Frame", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,0,0,0),
        Size = UDim2.new(0,1,1,0),
        BackgroundColor3 = T.BorderSoft,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, sidebar)

    local searchHolder = New("Frame", {
        Position = UDim2.fromOffset(16,16),
        Size = UDim2.new(1,-32,0,44),
        BackgroundColor3 = T.Surface,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, sidebar)
    Corner(searchHolder, 14)
    local searchStroke = Stroke(searchHolder, T.BorderSoft, 1, 0.2)

    local searchIcon = New("TextLabel", {
        Position = UDim2.fromOffset(16,0),
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
        Position = UDim2.fromOffset(12,76),
        Size = UDim2.new(1,-24,1,-146),
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
        Text = options.Version or "v5.1",
        Font = FONT.Medium,
        TextSize = 11,
        TextColor3 = T.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, sidebar)

    local content = New("Frame", {
        Position = UDim2.fromOffset(238,82),
        Size = UDim2.new(1,-238,1,-82),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, main)

    local pageHeader = New("Frame", {
        Position = UDim2.fromOffset(28,20),
        Size = UDim2.new(1,-56,0,64),
        BackgroundTransparency = 1,
        ZIndex = 4,
    }, content)

    local pageTitle = New("TextLabel", {
        Size = UDim2.new(1,0,0,25),
        BackgroundTransparency = 1,
        Text = "Home",
        Font = FONT.Bold,
        TextSize = 25,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
    }, pageHeader)

    local pageSubtitle = New("TextLabel", {
        Position = UDim2.fromOffset(0,32),
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
        Position = UDim2.fromOffset(20,92),
        Size = UDim2.new(1,-40,1,-106),
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
        Text = "",
        Font = FONT.Bold,
        TextSize = 18,
        TextColor3 = T.Text,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 100,
    }, gui)
    Corner(minimizedBubble, 17)
    local bubbleIcon = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.new(1,-8,1,-8),
        BackgroundTransparency = 1,
        Image = iconAsset,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 101,
    }, minimizedBubble)
    Corner(bubbleIcon, 13)
    local bubbleStroke = Stroke(minimizedBubble, T.Accent, 1, 0.15)
    MakeDraggable(minimizedBubble, minimizedBubble)

    local function bindTheme(fn)
        table.insert(Window.ThemeBindings, fn)
        fn(Window.Theme)
    end

    bindTheme(function(theme)
        if not main.Parent then return end
        main.BackgroundColor3 = theme.Background
        mainStroke.Color = theme.Accent
        outerGlowStroke.Color = theme.Accent
        header.BackgroundColor3 = theme.Background
        divider.BackgroundColor3 = theme.BorderSoft
        brandDot.BackgroundColor3 = theme.Surface2
        brandStroke.Color = theme.Accent
        brandGlow.BackgroundColor3 = theme.Accent
        title.TextColor3 = theme.Text
        subtitle.TextColor3 = theme.TextMuted
        sidebar.BackgroundColor3 = theme.Sidebar
        sideBrandCard.BackgroundColor3 = theme.Surface
        sideBrandStroke.Color = theme.BorderSoft
        sideBrandCaption.TextColor3 = theme.Accent
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
        Corner(card, 18)
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
            Size = UDim2.new(1,0,0,52),
            BackgroundColor3 = T.Sidebar,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 5,
        }, tabScroll)
        Corner(tabButton, 14)

        local activeBar = New("Frame", {
            Position = UDim2.fromOffset(0,9),
            Size = UDim2.fromOffset(4,34),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 6,
        }, tabButton)
        Corner(activeBar, 99)

        local iconString = tostring(Tab.Icon or "")
        local iconIsImage =
            iconString:find("rbxassetid://", 1, true) == 1
            or tonumber(iconString) ~= nil

        local tabIcon
        if iconIsImage then
            local asset = iconString
            if not asset:find("rbxassetid://", 1, true) then
                asset = "rbxassetid://" .. asset
            end

            tabIcon = New("ImageLabel", {
                Position = UDim2.fromOffset(16,13),
                Size = UDim2.fromOffset(26,26),
                BackgroundTransparency = 1,
                Image = asset,
                ImageColor3 = T.TextDim,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 6,
            }, tabButton)
        else
            tabIcon = New("TextLabel", {
                Position = UDim2.fromOffset(12,0),
                Size = UDim2.fromOffset(34,52),
                BackgroundTransparency = 1,
                Text = Tab.Icon,
                Font = FONT.Bold,
                TextSize = 16,
                TextColor3 = T.TextDim,
                ZIndex = 6,
            }, tabButton)
        end

        local tabLabel = New("TextLabel", {
            Position = UDim2.fromOffset(54,0),
            Size = UDim2.new(1,-64,1,0),
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
                tabButton.BackgroundTransparency = 0.12
                tabButton.BackgroundColor3 = theme.Surface2
                activeBar.BackgroundTransparency = 0
                if tabIcon:IsA("ImageLabel") then
                    tabIcon.ImageColor3 = theme.Accent
                else
                    tabIcon.TextColor3 = theme.Accent
                end
                tabLabel.TextColor3 = theme.Text
            else
                tabButton.BackgroundTransparency = 1
                activeBar.BackgroundTransparency = 1
                if tabIcon:IsA("ImageLabel") then
                    tabIcon.ImageColor3 = theme.TextDim
                else
                    tabIcon.TextColor3 = theme.TextDim
                end
                tabLabel.TextColor3 = theme.TextMuted
            end
        end)

        function Tab:Select()
            if Window.ActiveTab == Tab then return end
            for _, other in ipairs(Window.Tabs) do
                other.Page.Visible = false
                other.Button.BackgroundTransparency = 1
                other.ActiveBar.BackgroundTransparency = 1
                if other.IconLabel:IsA("ImageLabel") then
                    other.IconLabel.ImageColor3 = T.TextDim
                else
                    other.IconLabel.TextColor3 = T.TextDim
                end
                other.TextLabel.TextColor3 = T.TextMuted
            end

            Window.ActiveTab = Tab
            page.Visible = true
            tabButton.BackgroundTransparency = 0
            activeBar.BackgroundTransparency = 0
            if tabIcon:IsA("ImageLabel") then
                tabIcon.ImageColor3 = T.Accent
            else
                tabIcon.TextColor3 = T.Accent
            end
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
            Corner(card, 15)
            local cardStroke = Stroke(card, T.Border, 1, 0.22)
            local sectionAccent = New("Frame", {
                Position = UDim2.fromOffset(0,12),
                Size = UDim2.fromOffset(3,24),
                BackgroundColor3 = T.Accent,
                BorderSizePixel = 0,
                ZIndex = 8,
            }, card)
            Corner(sectionAccent, 99)

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
            local controlsList = List(controls, 8)
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
                    Size = UDim2.new(1,-20,0,height or 62),
                    BackgroundColor3 = T.Surface2,
                    BackgroundTransparency = 0.18,
                    BorderSizePixel = 0,
                    ZIndex = 8,
                }, controls)
                Corner(row, 14)
                local rowStroke = Stroke(row, T.BorderSoft, 1, 0.35)

                local rowGlow = New("Frame", {
                    Position = UDim2.fromOffset(0,8),
                    Size = UDim2.new(0,2,1,-16),
                    BackgroundColor3 = T.Accent,
                    BackgroundTransparency = 0.72,
                    BorderSizePixel = 0,
                    ZIndex = 9,
                }, row)
                Corner(rowGlow,99)

                bindTheme(function(theme)
                    if row.Parent then
                        row.BackgroundColor3 = theme.Surface2
                        rowStroke.Color = theme.BorderSoft
                        rowGlow.BackgroundColor3 = theme.Accent
                    end
                end)

                return row
            end

            local function addTexts(row, name, description, rightWidth, iconText)
                local iconBubble = New("Frame", {
                    Position = UDim2.fromOffset(10,10),
                    Size = UDim2.fromOffset(28,28),
                    BackgroundColor3 = T.Accent,
                    BackgroundTransparency = 0.86,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, row)
                Corner(iconBubble, 99)
                local iconStroke = Stroke(iconBubble, T.Accent, 1, 0.42)

                local iconDot = New("TextLabel", {
                    AnchorPoint = Vector2.new(0.5,0.5),
                    Position = UDim2.fromScale(0.5,0.5),
                    Size = UDim2.fromScale(1,1),
                    BackgroundTransparency = 1,
                    Text = tostring(iconText or "◆"),
                    Font = FONT.Bold,
                    TextSize = 13,
                    TextColor3 = T.Accent,
                    ZIndex = 11,
                }, iconBubble)

                bindTheme(function(theme)
                    if iconBubble.Parent then
                        iconBubble.BackgroundColor3 = theme.Accent
                        iconStroke.Color = theme.Accent
                        iconDot.TextColor3 = theme.Accent
                    end
                end)

                local titleLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(46,10),
                    Size = UDim2.new(1,-(rightWidth or 120)-38,0,20),
                    BackgroundTransparency = 1,
                    Text = name or "Control",
                    Font = FONT.Medium,
                    TextSize = 13,
                    TextColor3 = T.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 9,
                }, row)

                local descLabel = New("TextLabel", {
                    Position = UDim2.fromOffset(46,31),
                    Size = UDim2.new(1,-(rightWidth or 120)-38,0,17),
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
                addTexts(row, data.Name or "Button", data.Description or "", 145, data.Icon or "⚡")

                local btn = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(112,34),
                    BackgroundColor3 = T.AccentDark,
                    BorderSizePixel = 0,
                    Text = data.Text or "Run",
                    Font = FONT.Medium,
                    TextSize = 12,
                    TextColor3 = T.Text,
                    AutoButtonColor = false,
                    ZIndex = 10,
                }, row)
                Corner(btn, 9)
                local bStroke = Stroke(btn, T.Accent, 1, 0.08)

                bindTheme(function(theme)
                    if btn.Parent then
                        btn.BackgroundColor3 = theme.AccentDark
                        btn.TextColor3 = theme.Text
                        bStroke.Color = theme.Border
                    end
                end)

                btn.MouseEnter:Connect(function()
                    Tween(btn,0.13,{BackgroundColor3 = T.Accent})
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn,0.13,{BackgroundColor3 = T.AccentDark})
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
                addTexts(row, data.Name or "Toggle", data.Description or "", 95, data.Icon or "◎")

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
                local titleLabel = addTexts(row, data.Name or "Slider", data.Description or "", 90, data.Icon or "➤")

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
                    Size = UDim2.new(1,-16,0,7),
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
                    Size = UDim2.fromOffset(16,16),
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
                addTexts(row, data.Name or "Dropdown", data.Description or "", 210, data.Icon or "⌄")

                local selector = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,12),
                    Size = UDim2.fromOffset(210,38),
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
                    Tween(row,0.14,{Size = UDim2.new(1,-20,0,60)})
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
                        Tween(row,0.16,{Size = UDim2.new(1,-20,0,58 + h)})
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
                addTexts(row, data.Name or "Multi Dropdown", data.Description or "", 210, data.Icon or "≡")

                local selector = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,12),
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
                        Tween(row,0.16,{Size = UDim2.new(1,-20,0,58 + h)})
                        Tween(menu,0.16,{Size = UDim2.fromOffset(180,h)})
                        Tween(arrow,0.14,{Rotation = 180})
                    else
                        Tween(menu,0.14,{Size = UDim2.fromOffset(180,0)})
                        Tween(row,0.14,{Size = UDim2.new(1,-20,0,60)})
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
                addTexts(row, data.Name or "Textbox", data.Description or "", 250, data.Icon or "✎")

                local boxHolder = New("Frame", {
                    AnchorPoint = Vector2.new(1,0.5),
                    Position = UDim2.new(1,-8,0.5,0),
                    Size = UDim2.fromOffset(240,38),
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
                addTexts(row,data.Name or "Keybind",data.Description or "",145, data.Icon or "⌨")

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
                addTexts(row,data.Name or "Color",data.Description or "",120, data.Icon or "◉")

                local preview = New("TextButton", {
                    AnchorPoint = Vector2.new(1,0),
                    Position = UDim2.new(1,-8,0,11),
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
                        Tween(row,0.16,{Size = UDim2.new(1,-20,0,188)})
                        Tween(popup,0.16,{Size = UDim2.fromOffset(220,132)})
                    else
                        Tween(popup,0.14,{Size = UDim2.fromOffset(220,0)})
                        Tween(row,0.14,{Size = UDim2.new(1,-20,0,56)})
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
