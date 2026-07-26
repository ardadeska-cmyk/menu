--!strict
--[[
    Endware UI Library
    Modern cartoony Roblox GUI library.

    Runtime: Client only (LocalScript)
    Version: 1.3.0
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

assert(RunService:IsClient(), "[Endware] Endware must be required from a LocalScript.")

local LOCAL_PLAYER = Players.LocalPlayer
assert(LOCAL_PLAYER, "[Endware] LocalPlayer is not available.")

local Endware = {}
Endware.__index = Endware
Endware.Version = "1.3.0"

export type Theme = {
    Background: Color3,
    Surface: Color3,
    SurfaceAlt: Color3,
    Sidebar: Color3,
    Text: Color3,
    MutedText: Color3,
    Accent: Color3,
    AccentDark: Color3,
    AccentSoft: Color3,
    Secondary: Color3,
    Positive: Color3,
    Stroke: Color3,
    Shadow: Color3,
    White: Color3,
}

export type WindowOptions = {
    Title: string?,
    Subtitle: string?,
    GuiName: string?,
    ToggleKey: Enum.KeyCode?,
    Size: UDim2?,
    DisplayOrder: number?,
    Theme: {[string]: Color3}?,
}

export type TabOptions = {
    Name: string,
    Icon: string?,
}

export type CheckboxOptions = {
    Name: string,
    Description: string?,
    Default: boolean?,
    Flag: string?,
    FireOnInit: boolean?,
    Callback: ((boolean) -> ())?,
}

export type ButtonOptions = {
    Name: string,
    Description: string?,
    ButtonText: string?,
    Callback: (() -> ())?,
}

local DEFAULT_THEME: Theme = {
    Background = Color3.fromRGB(255, 247, 238),
    Surface = Color3.fromRGB(255, 255, 255),
    SurfaceAlt = Color3.fromRGB(255, 243, 231),
    Sidebar = Color3.fromRGB(255, 230, 205),
    Text = Color3.fromRGB(47, 35, 48),
    MutedText = Color3.fromRGB(104, 84, 100),
    Accent = Color3.fromRGB(255, 105, 133),
    AccentDark = Color3.fromRGB(205, 55, 91),
    AccentSoft = Color3.fromRGB(255, 216, 226),
    Secondary = Color3.fromRGB(255, 190, 78),
    Positive = Color3.fromRGB(69, 190, 137),
    Stroke = Color3.fromRGB(226, 196, 180),
    Shadow = Color3.fromRGB(108, 82, 94),
    White = Color3.fromRGB(255, 255, 255),
}

local FAST_TWEEN = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local NORMAL_TWEEN = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local BOUNCE_TWEEN = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function create(className: string, properties: {[string]: any}?): any
    local object = Instance.new(className) :: any
    local parent: Instance? = nil

    if properties then
        for key, value in pairs(properties) do
            if key == "Parent" then
                parent = value
            else
                object[key] = value
            end
        end
    end

    object.Parent = parent
    return object
end

local function addCorner(parent: Instance, radius: number): UICorner
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = parent,
    })
end

local function addStroke(parent: Instance, color: Color3, thickness: number, transparency: number?): UIStroke
    return create("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Thickness = thickness,
        Transparency = transparency or 0,
        Parent = parent,
    })
end

local function addPadding(parent: Instance, left: number, right: number, top: number, bottom: number): UIPadding
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, left),
        PaddingRight = UDim.new(0, right),
        PaddingTop = UDim.new(0, top),
        PaddingBottom = UDim.new(0, bottom),
        Parent = parent,
    })
end

local function playTween(instance: Instance, tweenInfo: TweenInfo, goal: {[string]: any}): Tween
    local tween = TweenService:Create(instance, tweenInfo, goal)
    tween:Play()
    return tween
end

local function safeCall(callback: ((...any) -> ())?, ...: any)
    if not callback then
        return
    end

    local args = table.pack(...)
    task.spawn(function()
        local ok, err = xpcall(function()
            callback(table.unpack(args, 1, args.n))
        end, debug.traceback)

        if not ok then
            warn("[Endware] Callback error:\n" .. tostring(err))
        end
    end)
end

local function mergeTheme(overrides: {[string]: Color3}?): Theme
    local theme = table.clone(DEFAULT_THEME) :: any

    if overrides then
        for key, value in pairs(overrides) do
            if theme[key] ~= nil and typeof(value) == "Color3" then
                theme[key] = value
            end
        end
    end

    return theme :: Theme
end

local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({
        _tasks = {},
        _cleaned = false,
    }, Maid)
end

function Maid:Give(taskItem: any): any
    if self._cleaned then
        if typeof(taskItem) == "RBXScriptConnection" then
            taskItem:Disconnect()
        elseif typeof(taskItem) == "Instance" then
            taskItem:Destroy()
        elseif type(taskItem) == "function" then
            taskItem()
        end
        return taskItem
    end

    table.insert(self._tasks, taskItem)
    return taskItem
end

function Maid:Clean()
    if self._cleaned then
        return
    end

    self._cleaned = true

    for index = #self._tasks, 1, -1 do
        local taskItem = self._tasks[index]
        self._tasks[index] = nil

        if typeof(taskItem) == "RBXScriptConnection" then
            if taskItem.Connected then
                taskItem:Disconnect()
            end
        elseif typeof(taskItem) == "Instance" then
            taskItem:Destroy()
        elseif type(taskItem) == "function" then
            taskItem()
        elseif type(taskItem) == "table" and type(taskItem.Destroy) == "function" then
            taskItem:Destroy()
        end
    end
end

local function makeShadow(parent: Instance, radius: number, offset: Vector2, color: Color3, transparency: number): Frame
    local shadow = create("Frame", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color,
        BackgroundTransparency = transparency,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, offset.X, 0.5, offset.Y),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 0,
        Parent = parent,
    })
    addCorner(shadow, radius)
    return shadow
end

local function makeTextLabel(properties: {[string]: any}): TextLabel
    local defaults = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamMedium,
        TextColor3 = DEFAULT_THEME.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }

    for key, value in pairs(properties) do
        defaults[key] = value
    end

    return create("TextLabel", defaults)
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods

local TabMethods = {}
TabMethods.__index = TabMethods

local SectionMethods = {}
SectionMethods.__index = SectionMethods

local function setTabVisual(tab: any, selected: boolean)
    tab._selected = selected

    -- Tab text is rendered both by the TextButton itself and the decorative
    -- child label. The button text acts as a guaranteed fallback on clients
    -- where nested GUI ZIndex rendering behaves unexpectedly.
    tab._button.Visible = true
    tab._button.TextTransparency = 0
    tab._label.Visible = true
    tab._label.TextTransparency = 0
    tab._icon.Visible = true
    tab._icon.TextTransparency = 0

    if selected then
        playTween(tab._button, NORMAL_TWEEN, {
            BackgroundColor3 = tab._window.Theme.Accent,
            BackgroundTransparency = 0,
            TextColor3 = tab._window.Theme.White,
            TextTransparency = 0,
        })
        playTween(tab._stroke, NORMAL_TWEEN, {
            Color = tab._window.Theme.AccentDark,
            Transparency = 0.18,
        })
        playTween(tab._indicator, BOUNCE_TWEEN, {
            BackgroundTransparency = 0,
            Size = UDim2.fromOffset(7, 30),
        })
        playTween(tab._iconBubble, NORMAL_TWEEN, {
            BackgroundColor3 = tab._window.Theme.White,
            BackgroundTransparency = 0,
        })
        playTween(tab._label, FAST_TWEEN, {
            TextColor3 = tab._window.Theme.White,
            TextTransparency = 0,
        })
        playTween(tab._icon, FAST_TWEEN, {
            TextColor3 = tab._window.Theme.AccentDark,
            TextTransparency = 0,
        })
        tab._page.Visible = true
    else
        playTween(tab._button, FAST_TWEEN, {
            BackgroundColor3 = tab._window.Theme.Surface,
            BackgroundTransparency = 0,
            TextColor3 = tab._window.Theme.Text,
            TextTransparency = 0,
        })
        playTween(tab._stroke, FAST_TWEEN, {
            Color = tab._window.Theme.Stroke,
            Transparency = 0,
        })
        playTween(tab._indicator, FAST_TWEEN, {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(5, 22),
        })
        playTween(tab._iconBubble, FAST_TWEEN, {
            BackgroundColor3 = tab._window.Theme.AccentSoft,
            BackgroundTransparency = 0,
        })
        playTween(tab._label, FAST_TWEEN, {
            TextColor3 = tab._window.Theme.Text,
            TextTransparency = 0,
        })
        playTween(tab._icon, FAST_TWEEN, {
            TextColor3 = tab._window.Theme.AccentDark,
            TextTransparency = 0,
        })
        tab._page.Visible = false
    end
end

function WindowMethods:_selectTab(tab: any)
    if self._activeTab == tab then
        return
    end

    for _, otherTab in ipairs(self._tabs) do
        setTabVisual(otherTab, otherTab == tab)
    end

    self._activeTab = tab
    self._pageTitle.Text = tab.Name
    self._pageSubtitle.Text = tab.Description or "Endware kontrol merkezi"
end

function WindowMethods:SetVisible(visible: boolean)
    if self._destroyed or self._visible == visible then
        return
    end

    self._visible = visible
    self._animationSerial += 1
    local serial = self._animationSerial

    if visible then
        self._holder.Visible = true
        self._motion.GroupTransparency = 1
        self._motionScale.Scale = 0.92

        playTween(self._motion, NORMAL_TWEEN, {GroupTransparency = 0})
        playTween(self._motionScale, BOUNCE_TWEEN, {Scale = 1})
    else
        playTween(self._motion, FAST_TWEEN, {GroupTransparency = 1})
        playTween(self._motionScale, FAST_TWEEN, {Scale = 0.94})

        task.delay(FAST_TWEEN.Time, function()
            if not self._destroyed and serial == self._animationSerial and not self._visible then
                self._holder.Visible = false
            end
        end)
    end
end

function WindowMethods:Toggle()
    self:SetVisible(not self._visible)
end

function WindowMethods:IsVisible(): boolean
    return self._visible
end

function WindowMethods:GetFlag(flag: string): any
    return self.Flags[flag]
end

function WindowMethods:SetFlag(flag: string, value: any, silent: boolean?)
    local setter = self._flagSetters[flag]
    if setter then
        setter(value, silent == true)
    else
        self.Flags[flag] = value
    end
end

function WindowMethods:Notify(options: {[string]: any})
    if self._destroyed then
        return
    end

    local title = tostring(options.Title or "Endware")
    local content = tostring(options.Content or "İşlem tamamlandı.")
    local duration = tonumber(options.Duration) or 3

    local toastGroup = create("CanvasGroup", {
        Name = "Toast",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        LayoutOrder = self._notificationOrder,
        Size = UDim2.new(1, 0, 0, 86),
        Parent = self._notificationHost,
    })
    self._notificationOrder += 1

    local toastScale = create("UIScale", {
        Scale = 0.9,
        Parent = toastGroup,
    })

    makeShadow(toastGroup, 18, Vector2.new(0, 6), self.Theme.Shadow, 0.82)

    local card = create("Frame", {
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 80),
        ZIndex = 2,
        Parent = toastGroup,
    })
    addCorner(card, 18)
    addStroke(card, self.Theme.Stroke, 1.5)

    local accent = create("Frame", {
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 13),
        Size = UDim2.fromOffset(8, 54),
        ZIndex = 3,
        Parent = card,
    })
    addCorner(accent, 8)

    makeTextLabel({
        Font = Enum.Font.FredokaOne,
        Position = UDim2.fromOffset(30, 10),
        Size = UDim2.new(1, -45, 0, 24),
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 16,
        ZIndex = 3,
        Parent = card,
    })

    makeTextLabel({
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(30, 34),
        Size = UDim2.new(1, -45, 0, 34),
        Text = content,
        TextColor3 = self.Theme.MutedText,
        TextSize = 12,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 3,
        Parent = card,
    })

    playTween(toastGroup, NORMAL_TWEEN, {GroupTransparency = 0})
    playTween(toastScale, BOUNCE_TWEEN, {Scale = 1})

    task.delay(math.max(0.75, duration), function()
        if not toastGroup.Parent then
            return
        end

        playTween(toastGroup, FAST_TWEEN, {GroupTransparency = 1})
        playTween(toastScale, FAST_TWEEN, {Scale = 0.92})
        task.delay(FAST_TWEEN.Time, function()
            if toastGroup.Parent then
                toastGroup:Destroy()
            end
        end)
    end)
end

function WindowMethods:CreateTab(options: TabOptions | string)
    assert(not self._destroyed, "[Endware] Cannot create a tab on a destroyed window.")

    local data: TabOptions
    if type(options) == "string" then
        data = {Name = options}
    else
        data = options
    end

    assert(type(data.Name) == "string" and data.Name ~= "", "[Endware] Tab Name is required.")

    local tab = setmetatable({
        Name = data.Name,
        Description = nil,
        _window = self,
        _maid = Maid.new(),
        _selected = false,
    }, TabMethods)

    -- Explicit positioning avoids Roblox UIListLayout/AutomaticCanvasSize
    -- rendering inconsistencies inside ScrollingFrames.
    local tabIndex = #self._tabs + 1
    local tabStride = 63

    local button = create("TextButton", {
        Name = data.Name .. "Tab",
        Active = true,
        AutoButtonColor = false,
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        LayoutOrder = tabIndex,
        Position = UDim2.fromOffset(0, (tabIndex - 1) * tabStride),
        Selectable = true,
        Size = UDim2.new(1, -6, 0, 54),
        -- Built-in text is a render-safe fallback. The decorative label below
        -- sits over it during normal rendering.
        Text = data.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextTransparency = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = true,
        ZIndex = 50,
        Parent = self._tabList,
    })
    addCorner(button, 16)
    addPadding(button, 57, 10, 0, 0)
    local buttonStroke = addStroke(button, self.Theme.Stroke, 1.5, 0)

    local indicator = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Theme.Secondary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 5, 0.5, 0),
        Size = UDim2.fromOffset(4, 20),
        Visible = true,
        ZIndex = 54,
        Parent = button,
    })
    addCorner(indicator, 6)

    local iconBubble = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Theme.AccentSoft,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 13, 0.5, 0),
        Size = UDim2.fromOffset(34, 34),
        Visible = true,
        ZIndex = 52,
        Parent = button,
    })
    addCorner(iconBubble, 12)

    local icon = makeTextLabel({
        Font = Enum.Font.FredokaOne,
        Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 1),
        Text = data.Icon or "•",
        TextColor3 = self.Theme.AccentDark,
        TextSize = 18,
        TextTransparency = 0,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = true,
        ZIndex = 53,
        Parent = iconBubble,
    })

    local label = makeTextLabel({
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(57, 0),
        Size = UDim2.new(1, -69, 1, 0),
        Text = data.Name,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextTransparency = 0,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Visible = true,
        ZIndex = 53,
        Parent = button,
    })

    local page = create("ScrollingFrame", {
        Name = data.Name .. "Page",
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ClipsDescendants = false,
        ScrollBarImageColor3 = self.Theme.Accent,
        ScrollBarThickness = 5,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        Parent = self._pageHost,
    })
    addPadding(page, 4, 10, 4, 18)

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    tab._button = button
    tab._stroke = buttonStroke
    tab._indicator = indicator
    tab._iconBubble = iconBubble
    tab._icon = icon
    tab._label = label
    tab._page = page

    tab._maid:Give(button.Activated:Connect(function()
        self:_selectTab(tab)
    end))

    tab._maid:Give(button.MouseEnter:Connect(function()
        if not tab._selected then
            playTween(button, FAST_TWEEN, {
                BackgroundColor3 = self.Theme.AccentSoft,
                BackgroundTransparency = 0,
                TextColor3 = self.Theme.Text,
                TextTransparency = 0,
            })
            playTween(buttonStroke, FAST_TWEEN, {
                Color = self.Theme.Accent,
                Transparency = 0.5,
            })
        end
    end))

    tab._maid:Give(button.MouseLeave:Connect(function()
        if not tab._selected then
            playTween(button, FAST_TWEEN, {
                BackgroundColor3 = self.Theme.Surface,
                BackgroundTransparency = 0,
                TextColor3 = self.Theme.Text,
                TextTransparency = 0,
            })
            playTween(buttonStroke, FAST_TWEEN, {
                Color = self.Theme.Stroke,
                Transparency = 0,
            })
        end
    end))

    table.insert(self._tabs, tab)

    local requiredCanvasHeight = math.max(0, (#self._tabs * tabStride) - 9)
    self._tabList.CanvasSize = UDim2.fromOffset(0, requiredCanvasHeight)
    button.Visible = true

    if #self._tabs == 1 then
        self:_selectTab(tab)
    end

    return tab
end

function WindowMethods:Destroy()
    if self._destroyed then
        return
    end

    self._destroyed = true

    for _, tab in ipairs(self._tabs) do
        tab:Destroy()
    end

    self._maid:Clean()
end

function TabMethods:SetDescription(description: string)
    self.Description = description
    if self._window._activeTab == self then
        self._window._pageSubtitle.Text = description
    end
    return self
end

function TabMethods:CreateSection(title: string)
    assert(type(title) == "string" and title ~= "", "[Endware] Section title is required.")

    local window = self._window
    local section = setmetatable({
        Title = title,
        _window = window,
        _tab = self,
        _maid = Maid.new(),
    }, SectionMethods)

    local container = create("Frame", {
        Name = title .. "Section",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = #self._page:GetChildren() + 1,
        Size = UDim2.new(1, -2, 0, 0),
        ZIndex = 2,
        Parent = self._page,
    })

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = container,
    })

    local header = create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 2,
        Parent = container,
    })

    local dot = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = window.Theme.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        ZIndex = 3,
        Parent = header,
    })
    addCorner(dot, 6)

    makeTextLabel({
        Font = Enum.Font.FredokaOne,
        Position = UDim2.fromOffset(22, 0),
        Size = UDim2.new(1, -22, 1, 0),
        Text = title,
        TextColor3 = window.Theme.Text,
        TextSize = 18,
        ZIndex = 3,
        Parent = header,
    })

    local body = create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 2,
        Parent = container,
    })
    addCorner(body, 20)
    addStroke(body, window.Theme.Stroke, 1.5)
    addPadding(body, 10, 10, 10, 10)

    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = body,
    })

    section._container = container
    section._body = body

    return section
end

function TabMethods:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    self._maid:Clean()
    if self._button then
        self._button:Destroy()
    end
    if self._page then
        self._page:Destroy()
    end
end

function SectionMethods:AddCheckbox(options: CheckboxOptions)
    assert(type(options) == "table", "[Endware] AddCheckbox expects an options table.")
    assert(type(options.Name) == "string" and options.Name ~= "", "[Endware] Checkbox Name is required.")

    local window = self._window
    local flag = options.Flag or options.Name
    local state = options.Default == true
    local callback = options.Callback
    local controlMaid = Maid.new()

    local row = create("Frame", {
        Name = options.Name .. "Checkbox",
        BackgroundColor3 = window.Theme.SurfaceAlt,
        BorderSizePixel = 0,
        LayoutOrder = #self._body:GetChildren() + 1,
        Size = UDim2.new(1, 0, 0, 78),
        ZIndex = 2,
        Parent = self._body,
    })
    addCorner(row, 16)
    local rowStroke = addStroke(row, window.Theme.Stroke, 1.15, 0.28)

    local clickArea = create("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        ZIndex = 8,
        Parent = row,
    })

    makeTextLabel({
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(16, 11),
        Size = UDim2.new(1, -184, 0, 24),
        Text = options.Name,
        TextColor3 = window.Theme.Text,
        TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
        Parent = row,
    })

    makeTextLabel({
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(16, 38),
        Size = UDim2.new(1, -184, 0, 29),
        Text = options.Description or "Bu seçeneği aç veya kapat.",
        TextColor3 = window.Theme.MutedText,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 4,
        Parent = row,
    })

    local statePill = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -61, 0.5, 0),
        Size = UDim2.fromOffset(58, 28),
        ZIndex = 4,
        Parent = row,
    })
    addCorner(statePill, 13)

    local stateText = makeTextLabel({
        Font = Enum.Font.GothamBold,
        Size = UDim2.fromScale(1, 1),
        Text = "KAPALI",
        TextColor3 = window.Theme.MutedText,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5,
        Parent = statePill,
    })

    local box = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(38, 38),
        ZIndex = 4,
        Parent = row,
    })
    addCorner(box, 11)
    local boxStroke = addStroke(box, window.Theme.Stroke, 1.5)

    local checkScale = create("UIScale", {
        Scale = 0,
        Parent = box,
    })

    local check = makeTextLabel({
        Font = Enum.Font.FredokaOne,
        Size = UDim2.fromScale(1, 1),
        Text = "✓",
        TextColor3 = window.Theme.White,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5,
        Parent = box,
    })

    local checkbox = {}

    local function render(animated: boolean)
        local info = if animated then NORMAL_TWEEN else TweenInfo.new(0)

        playTween(box, info, {
            BackgroundColor3 = if state then window.Theme.Accent else window.Theme.Surface,
        })
        playTween(boxStroke, info, {
            Color = if state then window.Theme.AccentDark else window.Theme.Stroke,
            Transparency = if state then 0.25 else 0,
        })
        playTween(checkScale, if animated then BOUNCE_TWEEN else TweenInfo.new(0), {
            Scale = if state then 1 else 0,
        })
        playTween(statePill, info, {
            BackgroundColor3 = if state then window.Theme.AccentSoft else window.Theme.Surface,
        })
        playTween(stateText, info, {
            TextColor3 = if state then window.Theme.AccentDark else window.Theme.MutedText,
        })
        stateText.Text = if state then "AÇIK" else "KAPALI"
    end

    function checkbox:Set(value: boolean, silent: boolean?)
        local nextState = value == true
        if state == nextState then
            window.Flags[flag] = state
            return
        end

        state = nextState
        window.Flags[flag] = state
        render(true)

        if not silent then
            safeCall(callback, state)
        end
    end

    function checkbox:Get(): boolean
        return state
    end

    function checkbox:Destroy()
        window._flagSetters[flag] = nil
        window.Flags[flag] = nil
        controlMaid:Clean()
        if row.Parent then
            row:Destroy()
        end
    end

    window.Flags[flag] = state
    window._flagSetters[flag] = function(value: any, silent: boolean)
        checkbox:Set(value == true, silent)
    end

    render(false)

    controlMaid:Give(clickArea.Activated:Connect(function()
        checkbox:Set(not state)
    end))

    controlMaid:Give(clickArea.MouseEnter:Connect(function()
        playTween(row, FAST_TWEEN, {
            BackgroundColor3 = window.Theme.AccentSoft:Lerp(window.Theme.SurfaceAlt, 0.38),
        })
        playTween(rowStroke, FAST_TWEEN, {
            Color = window.Theme.Accent,
            Transparency = 0.45,
        })
    end))

    controlMaid:Give(clickArea.MouseLeave:Connect(function()
        playTween(row, FAST_TWEEN, {BackgroundColor3 = window.Theme.SurfaceAlt})
        playTween(rowStroke, FAST_TWEEN, {
            Color = window.Theme.Stroke,
            Transparency = 0.28,
        })
    end))

    if options.FireOnInit then
        safeCall(callback, state)
    end

    return checkbox
end

SectionMethods.AddToggle = SectionMethods.AddCheckbox

function SectionMethods:AddButton(options: ButtonOptions)
    assert(type(options) == "table", "[Endware] AddButton expects an options table.")
    assert(type(options.Name) == "string" and options.Name ~= "", "[Endware] Button Name is required.")

    local window = self._window
    local controlMaid = Maid.new()

    local row = create("Frame", {
        Name = options.Name .. "Button",
        BackgroundColor3 = window.Theme.SurfaceAlt,
        BorderSizePixel = 0,
        LayoutOrder = #self._body:GetChildren() + 1,
        Size = UDim2.new(1, 0, 0, 78),
        ZIndex = 2,
        Parent = self._body,
    })
    addCorner(row, 16)
    addStroke(row, window.Theme.Stroke, 1.15, 0.28)

    makeTextLabel({
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(16, 11),
        Size = UDim2.new(1, -166, 0, 24),
        Text = options.Name,
        TextColor3 = window.Theme.Text,
        TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
        Parent = row,
    })

    makeTextLabel({
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(16, 38),
        Size = UDim2.new(1, -166, 0, 29),
        Text = options.Description or "Bu işlemi çalıştır.",
        TextColor3 = window.Theme.MutedText,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 4,
        Parent = row,
    })

    local action = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = window.Theme.Secondary,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(128, 42),
        Text = options.ButtonText or "ÇALIŞTIR",
        TextColor3 = window.Theme.Text,
        TextSize = 12,
        ZIndex = 5,
        Parent = row,
    })
    addCorner(action, 13)
    addStroke(action, window.Theme.Stroke, 1.2, 0.35)

    local actionScale = create("UIScale", {
        Scale = 1,
        Parent = action,
    })

    controlMaid:Give(action.MouseEnter:Connect(function()
        playTween(actionScale, FAST_TWEEN, {Scale = 1.04})
        playTween(action, FAST_TWEEN, {BackgroundColor3 = window.Theme.Secondary:Lerp(window.Theme.White, 0.18)})
    end))

    controlMaid:Give(action.MouseLeave:Connect(function()
        playTween(actionScale, FAST_TWEEN, {Scale = 1})
        playTween(action, FAST_TWEEN, {BackgroundColor3 = window.Theme.Secondary})
    end))

    controlMaid:Give(action.MouseButton1Down:Connect(function()
        playTween(actionScale, FAST_TWEEN, {Scale = 0.96})
    end))

    controlMaid:Give(action.Activated:Connect(function()
        playTween(actionScale, BOUNCE_TWEEN, {Scale = 1})
        safeCall(options.Callback)
    end))

    local buttonObject = {}
    function buttonObject:Destroy()
        controlMaid:Clean()
        if row.Parent then
            row:Destroy()
        end
    end

    return buttonObject
end

function SectionMethods:AddParagraph(title: string, content: string)
    local window = self._window

    local row = create("Frame", {
        Name = title .. "Paragraph",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = window.Theme.AccentSoft,
        BorderSizePixel = 0,
        LayoutOrder = #self._body:GetChildren() + 1,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 2,
        Parent = self._body,
    })
    addCorner(row, 16)
    addStroke(row, window.Theme.Accent, 1.1, 0.68)
    addPadding(row, 16, 16, 12, 14)

    local layout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = row,
    })
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    makeTextLabel({
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.FredokaOne,
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Text = title,
        TextColor3 = window.Theme.AccentDark,
        TextSize = 15,
        TextWrapped = true,
        Parent = row,
    })

    makeTextLabel({
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Gotham,
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 0),
        Text = content,
        TextColor3 = window.Theme.Text,
        TextSize = 12,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = row,
    })

    return row
end

function Endware:CreateWindow(options: WindowOptions?)
    options = options or {}

    local theme = mergeTheme(options.Theme)
    local playerGui = LOCAL_PLAYER:WaitForChild("PlayerGui") :: PlayerGui
    local guiName = options.GuiName or "EndwareUI"

    local oldGui = playerGui:FindFirstChild(guiName)
    if oldGui then
        oldGui:Destroy()
    end

    local window = setmetatable({
        Theme = theme,
        Flags = {},
        _flagSetters = {},
        _tabs = {},
        _activeTab = nil,
        _visible = true,
        _destroyed = false,
        _animationSerial = 0,
        _notificationOrder = 1,
        _maid = Maid.new(),
        ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift,
    }, WindowMethods)

    local screenGui = create("ScreenGui", {
        Name = guiName,
        DisplayOrder = options.DisplayOrder or 50,
        IgnoreGuiInset = false,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Parent = playerGui,
    })

    local holder = create("Frame", {
        Name = "WindowHolder",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = options.Size or UDim2.fromOffset(780, 510),
        Parent = screenGui,
    })

    local responsiveScale = create("UIScale", {
        Scale = 1,
        Parent = holder,
    })

    local motion = create("CanvasGroup", {
        Name = "Motion",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = holder,
    })

    local motionScale = create("UIScale", {
        Scale = 1,
        Parent = motion,
    })

    makeShadow(motion, 28, Vector2.new(0, 12), theme.Shadow, 0.72)

    local main = create("Frame", {
        Name = "Main",
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 2,
        Parent = motion,
    })
    addCorner(main, 28)
    addStroke(main, theme.Stroke, 2)

    local topbar = create("Frame", {
        Name = "Topbar",
        Active = true,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 76),
        ZIndex = 3,
        Parent = main,
    })

    local topbarLine = create("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = theme.Stroke,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 4,
        Parent = topbar,
    })

    local logoShadow = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.AccentDark,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 22, 0.5, 4),
        Size = UDim2.fromOffset(48, 48),
        ZIndex = 4,
        Parent = topbar,
    })
    addCorner(logoShadow, 17)

    local logo = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 22, 0.5, 0),
        Size = UDim2.fromOffset(48, 48),
        ZIndex = 5,
        Parent = topbar,
    })
    addCorner(logo, 17)
    addStroke(logo, theme.AccentDark, 1.5, 0.35)

    makeTextLabel({
        Font = Enum.Font.FredokaOne,
        Size = UDim2.fromScale(1, 1),
        Text = "E",
        TextColor3 = theme.White,
        TextSize = 27,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 6,
        Parent = logo,
    })

    makeTextLabel({
        Font = Enum.Font.FredokaOne,
        Position = UDim2.fromOffset(84, 10),
        Size = UDim2.new(1, -320, 0, 31),
        Text = options.Title or "ENDWARE",
        TextColor3 = theme.Text,
        TextSize = 24,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 5,
        Parent = topbar,
    })

    makeTextLabel({
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(85, 40),
        Size = UDim2.new(1, -320, 0, 22),
        Text = options.Subtitle or "Modern cartoony interface library",
        TextColor3 = theme.MutedText,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 5,
        Parent = topbar,
    })

    local keyPill = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = theme.AccentSoft,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -74, 0.5, 0),
        Size = UDim2.fromOffset(112, 34),
        ZIndex = 5,
        Parent = topbar,
    })
    addCorner(keyPill, 13)

    makeTextLabel({
        Font = Enum.Font.GothamBold,
        Size = UDim2.fromScale(1, 1),
        Text = string.upper(string.gsub(window.ToggleKey.Name, "(%l)(%u)", "%1 %2")) .. "  •  TOGGLE",
        TextColor3 = theme.AccentDark,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 6,
        Parent = keyPill,
    })

    local hideButton = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel = 0,
        Font = Enum.Font.FredokaOne,
        Position = UDim2.new(1, -22, 0.5, 0),
        Size = UDim2.fromOffset(38, 38),
        Text = "×",
        TextColor3 = theme.MutedText,
        TextSize = 22,
        ZIndex = 5,
        Parent = topbar,
    })
    addCorner(hideButton, 13)

    local sidebar = create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 76),
        Size = UDim2.new(0, 216, 1, -76),
        ZIndex = 5,
        Parent = main,
    })

    makeTextLabel({
        Font = Enum.Font.GothamBold,
        Position = UDim2.fromOffset(20, 15),
        Size = UDim2.new(1, -40, 0, 23),
        Text = "MENÜLER",
        TextColor3 = theme.MutedText,
        TextSize = 10,
        TextTransparency = 0,
        ZIndex = 11,
        Parent = sidebar,
    })

    local tabList = create("ScrollingFrame", {
        Name = "TabList",
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasPosition = Vector2.zero,
        CanvasSize = UDim2.fromOffset(0, 0),
        ClipsDescendants = true,
        Position = UDim2.fromOffset(14, 45),
        ScrollBarImageColor3 = theme.Accent,
        ScrollBarImageTransparency = 0.25,
        ScrollBarThickness = 4,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Size = UDim2.new(1, -28, 1, -105),
        Visible = true,
        ZIndex = 40,
        Parent = sidebar,
    })

    local versionCard = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.32,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 1, -14),
        Size = UDim2.new(1, -28, 0, 46),
        ZIndex = 10,
        Parent = sidebar,
    })
    addCorner(versionCard, 14)

    makeTextLabel({
        Font = Enum.Font.FredokaOne,
        Position = UDim2.fromOffset(12, 4),
        Size = UDim2.new(1, -24, 0, 21),
        Text = "ENDWARE UI",
        TextColor3 = theme.Text,
        TextSize = 12,
        TextTransparency = 0,
        ZIndex = 11,
        Parent = versionCard,
    })

    makeTextLabel({
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(12, 23),
        Size = UDim2.new(1, -24, 0, 16),
        Text = "v" .. Endware.Version .. "  •  Cartoony",
        TextColor3 = theme.MutedText,
        TextSize = 9,
        TextTransparency = 0,
        ZIndex = 11,
        Parent = versionCard,
    })

    local content = create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(216, 76),
        Size = UDim2.new(1, -216, 1, -76),
        ZIndex = 2,
        Parent = main,
    })

    local pageTitle = makeTextLabel({
        Font = Enum.Font.FredokaOne,
        Position = UDim2.fromOffset(26, 15),
        Size = UDim2.new(1, -52, 0, 29),
        Text = "Ana Sayfa",
        TextColor3 = theme.Text,
        TextSize = 22,
        ZIndex = 3,
        Parent = content,
    })

    local pageSubtitle = makeTextLabel({
        Font = Enum.Font.Gotham,
        Position = UDim2.fromOffset(27, 44),
        Size = UDim2.new(1, -54, 0, 20),
        Text = "Endware kontrol merkezi",
        TextColor3 = theme.MutedText,
        TextSize = 11,
        ZIndex = 3,
        Parent = content,
    })

    local pageHost = create("Frame", {
        Name = "PageHost",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(22, 76),
        Size = UDim2.new(1, -44, 1, -92),
        ZIndex = 3,
        Parent = content,
    })

    local notificationHost = create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.fromOffset(310, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 100,
        Parent = screenGui,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = notificationHost,
    })

    window._screenGui = screenGui
    window._holder = holder
    window._motion = motion
    window._motionScale = motionScale
    window._responsiveScale = responsiveScale
    window._main = main
    window._tabList = tabList
    window._pageHost = pageHost
    window._pageTitle = pageTitle
    window._pageSubtitle = pageSubtitle
    window._notificationHost = notificationHost

    local function updateResponsiveScale()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        local viewport = camera.ViewportSize
        local targetScale = math.clamp(math.min(viewport.X / 940, viewport.Y / 650), 0.68, 1)
        responsiveScale.Scale = targetScale
    end

    updateResponsiveScale()

    local cameraConnection: RBXScriptConnection? = nil
    local function bindCamera()
        if cameraConnection then
            cameraConnection:Disconnect()
            cameraConnection = nil
        end

        local camera = workspace.CurrentCamera
        if camera then
            cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
        end
        updateResponsiveScale()
    end

    bindCamera()
    window._maid:Give(function()
        if cameraConnection then
            cameraConnection:Disconnect()
        end
    end)
    window._maid:Give(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera))

    local dragging = false
    local dragInput: InputObject? = nil
    local dragStart = Vector2.zero
    local startPosition = holder.Position

    window._maid:Give(topbar.InputBegan:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = holder.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end))

    window._maid:Give(topbar.InputChanged:Connect(function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))

    window._maid:Give(UserInputService.InputChanged:Connect(function(input: InputObject)
        if dragging and input == dragInput then
            local rawDelta = input.Position - dragStart
            local scale = math.max(responsiveScale.Scale, 0.01)
            local delta = rawDelta / scale
            holder.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end))

    window._maid:Give(UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
        if gameProcessed or UserInputService:GetFocusedTextBox() then
            return
        end

        if input.KeyCode == window.ToggleKey then
            window:Toggle()
        end
    end))

    window._maid:Give(hideButton.Activated:Connect(function()
        window:SetVisible(false)
    end))

    window._maid:Give(hideButton.MouseEnter:Connect(function()
        playTween(hideButton, FAST_TWEEN, {
            BackgroundColor3 = theme.AccentSoft,
            TextColor3 = theme.AccentDark,
        })
    end))

    window._maid:Give(hideButton.MouseLeave:Connect(function()
        playTween(hideButton, FAST_TWEEN, {
            BackgroundColor3 = theme.SurfaceAlt,
            TextColor3 = theme.MutedText,
        })
    end))

    window._maid:Give(screenGui)

    return window
end

return setmetatable({}, Endware)
