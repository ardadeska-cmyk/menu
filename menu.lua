--!strict
--[[
	Endware UI Library
	A self-contained, cartoony Roblox UI library built for LocalScripts.
	Version: 1.0.0
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LOCAL_PLAYER = Players.LocalPlayer
assert(LOCAL_PLAYER, "Endware must be required from a client context.")

export type Theme = {
	Background: Color3,
	Backdrop: Color3,
	Panel: Color3,
	PanelRaised: Color3,
	Surface: Color3,
	SurfaceHover: Color3,
	Accent: Color3,
	AccentDark: Color3,
	AccentSecondary: Color3,
	Success: Color3,
	Danger: Color3,
	Text: Color3,
	TextMuted: Color3,
	Outline: Color3,
	Shadow: Color3,
}

export type WindowOptions = {
	Title: string?,
	Subtitle: string?,
	GuiName: string?,
	ToggleKey: Enum.KeyCode?,
	Theme: Theme?,
	StartVisible: boolean?,
}

export type TabOptions = {
	Name: string,
	Badge: string?,
	Description: string?,
}

export type SectionOptions = {
	Name: string,
	Description: string?,
}

export type ToggleOptions = {
	Name: string,
	Description: string?,
	Default: boolean?,
	Callback: ((boolean) -> ())?,
}

export type CheckboxGroupOptions = {
	Name: string,
	Description: string?,
	Items: {string},
	Defaults: {[string]: boolean}?,
	Callback: ((string, boolean, {[string]: boolean}) -> ())?,
}

export type ButtonOptions = {
	Name: string,
	Description: string?,
	Text: string?,
	Callback: (() -> ())?,
}

export type ParagraphOptions = {
	Title: string,
	Content: string,
}

export type NotificationOptions = {
	Title: string?,
	Content: string,
	Duration: number?,
}

local Endware = {}
Endware.Version = "1.0.0"

Endware.Themes = {
	Cartoony = {
		Background = Color3.fromRGB(27, 23, 43),
		Backdrop = Color3.fromRGB(13, 11, 24),
		Panel = Color3.fromRGB(44, 37, 67),
		PanelRaised = Color3.fromRGB(57, 48, 84),
		Surface = Color3.fromRGB(68, 57, 98),
		SurfaceHover = Color3.fromRGB(78, 66, 112),
		Accent = Color3.fromRGB(255, 174, 66),
		AccentDark = Color3.fromRGB(227, 132, 42),
		AccentSecondary = Color3.fromRGB(255, 91, 139),
		Success = Color3.fromRGB(91, 219, 143),
		Danger = Color3.fromRGB(255, 105, 105),
		Text = Color3.fromRGB(255, 249, 238),
		TextMuted = Color3.fromRGB(192, 181, 207),
		Outline = Color3.fromRGB(93, 78, 126),
		Shadow = Color3.fromRGB(10, 8, 18),
	} :: Theme,
}

local Window = {} :: any
Window.__index = Window

local Tab = {} :: any
Tab.__index = Tab

local Section = {} :: any
Section.__index = Section

local function create(className: string, properties: {[string]: any}?, children: {Instance}?): any
	local instance = Instance.new(className)
	local parent = nil

	if properties then
		for property, value in pairs(properties) do
			if property == "Parent" then
				parent = value
			else
				(instance :: any)[property] = value
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end

	if parent then
		instance.Parent = parent
	end

	return instance
end

local function corner(parent: Instance, radius: number): UICorner
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius),
		Parent = parent,
	}) :: UICorner
end

local function stroke(parent: Instance, color: Color3, thickness: number, transparency: number?): UIStroke
	return create("UIStroke", {
		Color = color,
		Thickness = thickness,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	}) :: UIStroke
end

local function padding(parent: Instance, top: number, right: number, bottom: number, left: number): UIPadding
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
		Parent = parent,
	}) :: UIPadding
end

local function tween(instance: Instance, info: TweenInfo, goal: {[string]: any}): Tween
	local animation = TweenService:Create(instance, info, goal)
	animation:Play()
	return animation
end

local function safeCall(callback: ((...any) -> ())?, ...: any)
	if callback == nil then
		return
	end

	task.spawn(function(...)
		local ok, message = pcall(callback :: any, ...)
		if not ok then
			warn("[Endware callback error]", message)
		end
	end, ...)
end

local function copyTheme(source: Theme): Theme
	local result = {} :: any
	for key, value in pairs(source :: any) do
		result[key] = value
	end
	return result :: Theme
end

local function textLabel(parent: Instance, text: string, size: number, font: Enum.Font, color: Color3): TextLabel
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = color,
		TextSize = size,
		Font = font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = parent,
	}) :: TextLabel
end

local function makeInteractive(window: any, button: GuiButton, normalColor: Color3, hoverColor: Color3, pressedColor: Color3?)
	window:_connect(button.MouseEnter, function()
		tween(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverColor,
		})
	end)

	window:_connect(button.MouseLeave, function()
		tween(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = normalColor,
		})
	end)

	window:_connect(button.MouseButton1Down, function()
		tween(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = pressedColor or normalColor:Lerp(Color3.new(0, 0, 0), 0.12),
		})
	end)

	window:_connect(button.MouseButton1Up, function()
		tween(button, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverColor,
		})
	end)
end

function Window:_connect(signal: RBXScriptSignal, callback: any): RBXScriptConnection
	local connection = signal:Connect(callback)
	table.insert(self._connections, connection)
	return connection
end

function Window:_refreshScale()
	if self._destroyed then
		return
	end

	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local viewport = camera.ViewportSize
	local scale = math.clamp(math.min(viewport.X / 920, viewport.Y / 650), 0.68, 1)
	self._uiScale.Scale = scale
	self._shadowScale.Scale = scale
end

function Window:_setActiveTab(tab: any)
	if self._activeTab == tab then
		return
	end

	for _, otherTab in ipairs(self._tabs) do
		local isActive = otherTab == tab
		otherTab._page.Visible = isActive
		otherTab._indicator.Visible = isActive

		tween(otherTab._button, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = if isActive then self._theme.Surface else self._theme.Panel,
			TextColor3 = if isActive then self._theme.Text else self._theme.TextMuted,
		})
	end

	self._activeTab = tab
	self._pageTitle.Text = tab._name
	self._pageDescription.Text = tab._description
end

function Window:SetVisible(visible: boolean)
	if self._destroyed or self._visible == visible or self._animating then
		return
	end

	self._visible = visible
	self._animating = true

	local openPosition = self._openPosition
	local hiddenPosition = openPosition + UDim2.fromOffset(0, 18)
	local openShadowPosition = openPosition + UDim2.fromOffset(10, 13)
	local hiddenShadowPosition = hiddenPosition + UDim2.fromOffset(10, 13)

	if visible then
		self._mobileToggle.Visible = false
		self._root.Visible = true
		self._root.GroupTransparency = 1
		self._main.Position = hiddenPosition
		self._shadow.Position = hiddenShadowPosition
		self._main.Rotation = -1.2

		tween(self._root, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			GroupTransparency = 0,
		})
		tween(self._shadow, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = openShadowPosition,
		})
		local movement = tween(self._main, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = openPosition,
			Rotation = 0,
		})
		movement.Completed:Once(function()
			self._animating = false
		end)
	else
		tween(self._root, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			GroupTransparency = 1,
		})
		tween(self._shadow, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = hiddenShadowPosition,
		})
		local movement = tween(self._main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = hiddenPosition,
			Rotation = 0.8,
		})
		movement.Completed:Once(function()
			if not self._destroyed then
				self._root.Visible = false
				self._main.Position = openPosition
				self._shadow.Position = openShadowPosition
				self._main.Rotation = 0
				self._mobileToggle.Visible = UserInputService.TouchEnabled
				self._animating = false
			end
		end)
	end
end

function Window:Toggle()
	self:SetVisible(not self._visible)
end

function Window:IsVisible(): boolean
	return self._visible
end

function Window:Notify(options: NotificationOptions)
	if self._destroyed then
		return
	end

	local theme = self._theme
	local duration = math.max(options.Duration or 3.5, 0.8)

	local holder = create("Frame", {
		Name = "ToastHolder",
		Size = UDim2.fromOffset(330, 88),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = self._toastHost,
	}) :: Frame

	local toast = create("Frame", {
		Name = "Toast",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.PanelRaised,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(365, 0),
		Parent = holder,
	}) :: Frame
	corner(toast, 18)
	stroke(toast, theme.Outline, 2)

	local accent = create("Frame", {
		Size = UDim2.new(0, 7, 1, -16),
		Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Parent = toast,
	}) :: Frame
	corner(accent, 8)

	local title = textLabel(toast, options.Title or "ENDWARE", 16, Enum.Font.FredokaOne, theme.Text)
	title.Position = UDim2.fromOffset(28, 13)
	title.Size = UDim2.new(1, -46, 0, 23)

	local content = textLabel(toast, options.Content, 13, Enum.Font.GothamMedium, theme.TextMuted)
	content.Position = UDim2.fromOffset(28, 37)
	content.Size = UDim2.new(1, -46, 0, 38)
	content.TextWrapped = true
	content.TextYAlignment = Enum.TextYAlignment.Top

	local barTrack = create("Frame", {
		Size = UDim2.new(1, -36, 0, 4),
		Position = UDim2.new(0, 28, 1, -10),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = toast,
	}) :: Frame
	corner(barTrack, 4)

	local bar = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Parent = barTrack,
	}) :: Frame
	corner(bar, 4)

	tween(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(0, 0),
	})
	tween(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 0, 1, 0),
	})

	task.delay(duration, function()
		if not toast.Parent then
			return
		end

		local exit = tween(toast, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.fromOffset(365, 0),
		})
		exit.Completed:Once(function()
			holder:Destroy()
		end)
	end)
end

function Window:AddTab(options: TabOptions): any
	assert(type(options) == "table", "Endware:AddTab expects an options table.")
	assert(type(options.Name) == "string" and options.Name ~= "", "Tab Name must be a non-empty string.")

	local theme = self._theme
	local tab = setmetatable({
		_window = self,
		_name = options.Name,
		_description = options.Description or "Customize this page with Endware components.",
		_sections = {},
		_nextSectionOrder = 1,
	}, Tab)

	local button = create("TextButton", {
		Name = options.Name .. "Tab",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "   " .. options.Name,
		TextColor3 = theme.TextMuted,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self._tabList,
	}) :: TextButton
	corner(button, 14)

	local indicator = create("Frame", {
		Name = "Indicator",
		Size = UDim2.fromOffset(6, 26),
		Position = UDim2.new(0, 7, 0.5, -13),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Visible = false,
		Parent = button,
	}) :: Frame
	corner(indicator, 6)

	if options.Badge then
		local badge = textLabel(button, options.Badge, 11, Enum.Font.GothamBold, theme.Background)
		badge.AnchorPoint = Vector2.new(1, 0.5)
		badge.Position = UDim2.new(1, -10, 0.5, 0)
		badge.Size = UDim2.fromOffset(34, 21)
		badge.BackgroundTransparency = 0
		badge.BackgroundColor3 = theme.Accent
		badge.TextXAlignment = Enum.TextXAlignment.Center
		corner(badge, 10)
	end

	local page = create("ScrollingFrame", {
		Name = options.Name .. "Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.25,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Visible = false,
		Parent = self._pages,
	}) :: ScrollingFrame
	padding(page, 2, 12, 18, 2)
	create("UIListLayout", {
		Padding = UDim.new(0, 14),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = page,
	})

	tab._button = button
	tab._indicator = indicator
	tab._page = page

	self:_connect(button.Activated, function()
		self:_setActiveTab(tab)
	end)
	makeInteractive(self, button, theme.Panel, theme.Surface, theme.PanelRaised)

	table.insert(self._tabs, tab)
	if #self._tabs == 1 then
		self:_setActiveTab(tab)
	end

	return tab
end

function Window:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	table.clear(self._connections)
	self._screenGui:Destroy()
end

function Tab:Select()
	self._window:_setActiveTab(self)
end

function Tab:AddSection(options: SectionOptions | string): any
	local normalized: SectionOptions
	if type(options) == "string" then
		normalized = { Name = options }
	else
		normalized = options
	end

	assert(type(normalized.Name) == "string" and normalized.Name ~= "", "Section Name must be a non-empty string.")

	local window = self._window
	local theme = window._theme
	local section = setmetatable({
		_window = window,
		_tab = self,
	}, Section)

	local card = create("Frame", {
		Name = normalized.Name .. "Section",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.PanelRaised,
		BorderSizePixel = 0,
		LayoutOrder = self._nextSectionOrder,
		Parent = self._page,
	}) :: Frame
	corner(card, 20)
	stroke(card, theme.Outline, 2, 0.1)
	padding(card, 17, 17, 17, 17)

	local list = create("UIListLayout", {
		Padding = UDim.new(0, 11),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = card,
	}) :: UIListLayout

	local heading = create("Frame", {
		Name = "Heading",
		Size = UDim2.new(1, 0, 0, if normalized.Description then 48 else 25),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Parent = card,
	}) :: Frame

	local title = textLabel(heading, normalized.Name, 18, Enum.Font.FredokaOne, theme.Text)
	title.Size = UDim2.new(1, 0, 0, 25)

	if normalized.Description then
		local description = textLabel(heading, normalized.Description, 12, Enum.Font.GothamMedium, theme.TextMuted)
		description.Position = UDim2.fromOffset(0, 26)
		description.Size = UDim2.new(1, 0, 0, 20)
		description.TextWrapped = true
	end

	self._nextSectionOrder += 1

	section._card = card
	section._list = list
	section._nextOrder = 1
	table.insert(self._sections, section)

	return section
end

function Section:_nextLayoutOrder(): number
	local order = self._nextOrder
	self._nextOrder += 1
	return order
end

function Section:AddParagraph(options: ParagraphOptions): TextLabel
	assert(type(options.Title) == "string", "Paragraph Title must be a string.")
	assert(type(options.Content) == "string", "Paragraph Content must be a string.")

	local theme = self._window._theme
	local container = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		LayoutOrder = self:_nextLayoutOrder(),
		Parent = self._card,
	}) :: Frame
	corner(container, 15)
	padding(container, 13, 14, 13, 14)
	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = container,
	})

	local title = textLabel(container, options.Title, 14, Enum.Font.GothamBold, theme.Text)
	title.Size = UDim2.new(1, 0, 0, 20)
	title.LayoutOrder = 1

	local content = textLabel(container, options.Content, 12, Enum.Font.GothamMedium, theme.TextMuted)
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.TextWrapped = true
	content.TextYAlignment = Enum.TextYAlignment.Top
	content.LayoutOrder = 2

	return content
end

local function createCheckbox(window: any, parent: Instance, defaultValue: boolean): (TextButton, TextLabel, (boolean) -> ())
	local theme = window._theme
	local box = create("TextButton", {
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = if defaultValue then theme.Accent else theme.Surface,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = parent,
	}) :: TextButton
	corner(box, 9)
	local boxStroke = stroke(box, if defaultValue then theme.AccentDark else theme.Outline, 2)

	local check = textLabel(box, "✓", 20, Enum.Font.GothamBold, theme.Background)
	check.Size = UDim2.fromScale(1, 1)
	check.TextXAlignment = Enum.TextXAlignment.Center
	check.Visible = defaultValue
	check.Rotation = if defaultValue then 0 else -25

	local function render(value: boolean)
		check.Visible = true
		if value then
			check.TextTransparency = 1
			check.Rotation = -25
			tween(box, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				BackgroundColor3 = theme.Accent,
				Size = UDim2.fromOffset(32, 32),
			})
			tween(boxStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = theme.AccentDark,
			})
			tween(check, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				TextTransparency = 0,
				Rotation = 0,
			})
			task.delay(0.18, function()
				if box.Parent then
					tween(box, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.fromOffset(30, 30),
					})
				end
			end)
		else
			tween(box, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = theme.Surface,
			})
			tween(boxStroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = theme.Outline,
			})
			local hide = tween(check, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1,
				Rotation = 25,
			})
			hide.Completed:Once(function()
				if not value then
					check.Visible = false
				end
			end)
		end
	end

	makeInteractive(window, box, box.BackgroundColor3, theme.SurfaceHover, theme.AccentDark)
	return box, check, render
end

function Section:AddToggle(options: ToggleOptions): any
	assert(type(options.Name) == "string" and options.Name ~= "", "Toggle Name must be a non-empty string.")

	local window = self._window
	local theme = window._theme
	local state = options.Default == true

	local row = create("TextButton", {
		Name = options.Name .. "Toggle",
		Size = UDim2.new(1, 0, 0, if options.Description then 66 else 54),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = self:_nextLayoutOrder(),
		Parent = self._card,
	}) :: TextButton
	corner(row, 15)
	stroke(row, theme.Outline, 1, 0.35)

	local title = textLabel(row, options.Name, 14, Enum.Font.GothamBold, theme.Text)
	title.Position = UDim2.fromOffset(14, 8)
	title.Size = UDim2.new(1, -68, 0, 23)

	if options.Description then
		local description = textLabel(row, options.Description, 11, Enum.Font.GothamMedium, theme.TextMuted)
		description.Position = UDim2.fromOffset(14, 31)
		description.Size = UDim2.new(1, -68, 0, 25)
		description.TextWrapped = true
	end

	local box, _, render = createCheckbox(window, row, state)
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, -13, 0.5, 0)
	box.Active = false

	local controller = {} :: any

	function controller:Get(): boolean
		return state
	end

	function controller:Set(value: boolean, silent: boolean?)
		value = value == true
		if state == value then
			return
		end
		state = value
		render(state)
		if not silent then
			safeCall(options.Callback, state)
		end
	end

	window:_connect(row.Activated, function()
		controller:Set(not state)
	end)
	makeInteractive(window, row, theme.Panel, theme.Surface, theme.PanelRaised)

	return controller
end

function Section:AddCheckboxGroup(options: CheckboxGroupOptions): any
	assert(type(options.Name) == "string" and options.Name ~= "", "Checkbox group Name must be a non-empty string.")
	assert(type(options.Items) == "table" and #options.Items > 0, "Checkbox group Items must contain at least one string.")

	local window = self._window
	local theme = window._theme
	local states: {[string]: boolean} = {}
	local renderers: {[string]: (boolean) -> ()} = {}

	local container = create("Frame", {
		Name = options.Name .. "CheckboxGroup",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		LayoutOrder = self:_nextLayoutOrder(),
		Parent = self._card,
	}) :: Frame
	corner(container, 15)
	stroke(container, theme.Outline, 1, 0.35)
	padding(container, 12, 12, 12, 12)
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = container,
	})

	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, if options.Description then 43 else 24),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Parent = container,
	}) :: Frame

	local title = textLabel(header, options.Name, 14, Enum.Font.GothamBold, theme.Text)
	title.Size = UDim2.new(1, 0, 0, 22)

	if options.Description then
		local description = textLabel(header, options.Description, 11, Enum.Font.GothamMedium, theme.TextMuted)
		description.Position = UDim2.fromOffset(0, 22)
		description.Size = UDim2.new(1, 0, 0, 19)
	end

	for index, itemName in ipairs(options.Items) do
		assert(type(itemName) == "string" and itemName ~= "", "Every checkbox item must be a non-empty string.")
		assert(states[itemName] == nil, "Duplicate checkbox item: " .. itemName)
		states[itemName] = options.Defaults ~= nil and options.Defaults[itemName] == true

		local item = create("TextButton", {
			Name = itemName,
			Size = UDim2.new(1, 0, 0, 42),
			BackgroundColor3 = theme.PanelRaised,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			LayoutOrder = index,
			Parent = container,
		}) :: TextButton
		corner(item, 12)

		local label = textLabel(item, itemName, 13, Enum.Font.GothamMedium, theme.Text)
		label.Position = UDim2.fromOffset(12, 0)
		label.Size = UDim2.new(1, -60, 1, 0)

		local box, _, render = createCheckbox(window, item, states[itemName])
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, -7, 0.5, 0)
		box.Size = UDim2.fromOffset(27, 27)
		box.Active = false
		renderers[itemName] = render

		window:_connect(item.Activated, function()
			states[itemName] = not states[itemName]
			render(states[itemName])
			safeCall(options.Callback, itemName, states[itemName], table.clone(states))
		end)
		makeInteractive(window, item, theme.PanelRaised, theme.Surface, theme.Panel)
	end

	local controller = {} :: any

	function controller:Get(itemName: string): boolean?
		return states[itemName]
	end

	function controller:GetAll(): {[string]: boolean}
		return table.clone(states)
	end

	function controller:Set(itemName: string, value: boolean, silent: boolean?)
		assert(states[itemName] ~= nil, "Unknown checkbox item: " .. itemName)
		value = value == true
		if states[itemName] == value then
			return
		end
		states[itemName] = value
		renderers[itemName](value)
		if not silent then
			safeCall(options.Callback, itemName, value, table.clone(states))
		end
	end

	return controller
end

function Section:AddButton(options: ButtonOptions): TextButton
	assert(type(options.Name) == "string" and options.Name ~= "", "Button Name must be a non-empty string.")

	local window = self._window
	local theme = window._theme
	local button = create("TextButton", {
		Name = options.Name .. "Button",
		Size = UDim2.new(1, 0, 0, if options.Description then 64 else 52),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = self:_nextLayoutOrder(),
		Parent = self._card,
	}) :: TextButton
	corner(button, 15)
	stroke(button, theme.AccentDark, 2)

	local title = textLabel(button, options.Name, 14, Enum.Font.FredokaOne, theme.Background)
	title.Position = UDim2.fromOffset(14, if options.Description then 7 else 0)
	title.Size = UDim2.new(1, -120, 0, if options.Description then 23 else 52)

	if options.Description then
		local description = textLabel(button, options.Description, 11, Enum.Font.GothamMedium, theme.Background)
		description.Position = UDim2.fromOffset(14, 31)
		description.Size = UDim2.new(1, -120, 0, 22)
		description.TextTransparency = 0.2
	end

	local action = textLabel(button, options.Text or "RUN", 11, Enum.Font.GothamBold, theme.Background)
	action.AnchorPoint = Vector2.new(1, 0.5)
	action.Position = UDim2.new(1, -12, 0.5, 0)
	action.Size = UDim2.fromOffset(78, 28)
	action.BackgroundTransparency = 0
	action.BackgroundColor3 = theme.Text
	action.TextXAlignment = Enum.TextXAlignment.Center
	corner(action, 10)

	window:_connect(button.Activated, function()
		safeCall(options.Callback)
	end)
	makeInteractive(window, button, theme.Accent, theme.Accent:Lerp(Color3.new(1, 1, 1), 0.1), theme.AccentDark)

	return button
end

function Endware:CreateWindow(options: WindowOptions?): any
	local config: WindowOptions = options or {}
	local theme = copyTheme(config.Theme or Endware.Themes.Cartoony)
	local titleText = config.Title or "ENDWARE"
	local subtitleText = config.Subtitle or "CARTOON CONTROL CENTER"
	local guiName = config.GuiName or "EndwareUI"
	local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
	local playerGui = LOCAL_PLAYER:WaitForChild("PlayerGui") :: PlayerGui

	local existing = playerGui:FindFirstChild(guiName)
	if existing then
		existing:Destroy()
	end

	local self = setmetatable({
		_theme = theme,
		_toggleKey = toggleKey,
		_connections = {},
		_tabs = {},
		_activeTab = nil,
		_visible = config.StartVisible ~= false,
		_openPosition = UDim2.fromScale(0.5, 0.5),
		_animating = false,
		_destroyed = false,
	}, Window)

	local screenGui = create("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 50,
		Parent = playerGui,
	}) :: ScreenGui

	local root = create("CanvasGroup", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 0,
		Visible = true,
		Parent = screenGui,
	}) :: CanvasGroup

	local backdrop = create("TextButton", {
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Backdrop,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = root,
	}) :: TextButton

	local shadow = create("Frame", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(10, 13),
		Size = UDim2.fromOffset(760, 500),
		BackgroundColor3 = theme.Shadow,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Parent = root,
	}) :: Frame
	corner(shadow, 28)

	local main = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(760, 500),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = root,
	}) :: Frame
	corner(main, 26)
	stroke(main, theme.Outline, 3)

	local shadowScale = create("UIScale", {
		Scale = 1,
		Parent = shadow,
	}) :: UIScale

	local uiScale = create("UIScale", {
		Scale = 1,
		Parent = main,
	}) :: UIScale

	local topbar = create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 76),
		BackgroundColor3 = theme.PanelRaised,
		BorderSizePixel = 0,
		Active = true,
		Parent = main,
	}) :: Frame

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.PanelRaised),
			ColorSequenceKeypoint.new(1, theme.Panel),
		}),
		Rotation = 8,
		Parent = topbar,
	})

	local logoShadow = create("Frame", {
		Size = UDim2.fromOffset(48, 48),
		Position = UDim2.fromOffset(22, 17),
		BackgroundColor3 = theme.AccentDark,
		BorderSizePixel = 0,
		Rotation = 6,
		Parent = topbar,
	}) :: Frame
	corner(logoShadow, 15)

	local logo = textLabel(topbar, "E", 28, Enum.Font.FredokaOne, theme.Background)
	logo.Size = UDim2.fromOffset(48, 48)
	logo.Position = UDim2.fromOffset(19, 13)
	logo.BackgroundTransparency = 0
	logo.BackgroundColor3 = theme.Accent
	logo.TextXAlignment = Enum.TextXAlignment.Center
	logo.Rotation = -3
	corner(logo, 15)
	stroke(logo, theme.AccentDark, 2)

	local title = textLabel(topbar, titleText, 24, Enum.Font.FredokaOne, theme.Text)
	title.Position = UDim2.fromOffset(82, 11)
	title.Size = UDim2.new(1, -290, 0, 34)

	local subtitle = textLabel(topbar, subtitleText, 11, Enum.Font.GothamBold, theme.TextMuted)
	subtitle.Position = UDim2.fromOffset(83, 42)
	subtitle.Size = UDim2.new(1, -290, 0, 20)

	local keyHint = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -66, 0.5, 0),
		Size = UDim2.fromOffset(132, 36),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = topbar,
	}) :: Frame
	corner(keyHint, 12)
	stroke(keyHint, theme.Outline, 1)

	local hint = textLabel(keyHint, toggleKey.Name:upper(), 11, Enum.Font.GothamBold, theme.Text)
	hint.Size = UDim2.fromScale(1, 1)
	hint.TextXAlignment = Enum.TextXAlignment.Center

	local close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = theme.Danger,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "×",
		TextColor3 = theme.Background,
		TextSize = 24,
		Font = Enum.Font.GothamBold,
		Parent = topbar,
	}) :: TextButton
	corner(close, 12)
	stroke(close, theme.Danger:Lerp(Color3.new(0, 0, 0), 0.22), 2)

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(0, 76),
		Size = UDim2.new(0, 194, 1, -76),
		BackgroundColor3 = theme.Panel,
		BorderSizePixel = 0,
		Parent = main,
	}) :: Frame
	padding(sidebar, 17, 15, 16, 15)

	local navLabel = textLabel(sidebar, "NAVIGATION", 10, Enum.Font.GothamBold, theme.TextMuted)
	navLabel.Size = UDim2.new(1, 0, 0, 18)
	navLabel.LayoutOrder = 0

	local tabList = create("Frame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 1, -96),
		BackgroundTransparency = 1,
		Parent = sidebar,
	}) :: Frame
	create("UIListLayout", {
		Padding = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabList,
	})

	local footer = create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 57),
		BackgroundColor3 = theme.PanelRaised,
		BorderSizePixel = 0,
		Parent = sidebar,
	}) :: Frame
	corner(footer, 14)

	local statusDot = create("Frame", {
		Size = UDim2.fromOffset(10, 10),
		Position = UDim2.fromOffset(12, 14),
		BackgroundColor3 = theme.Success,
		BorderSizePixel = 0,
		Parent = footer,
	}) :: Frame
	corner(statusDot, 10)

	local status = textLabel(footer, "ENDWARE READY", 11, Enum.Font.GothamBold, theme.Text)
	status.Position = UDim2.fromOffset(29, 5)
	status.Size = UDim2.new(1, -36, 0, 25)

	local version = textLabel(footer, "v" .. Endware.Version, 10, Enum.Font.GothamMedium, theme.TextMuted)
	version.Position = UDim2.fromOffset(12, 29)
	version.Size = UDim2.new(1, -24, 0, 18)

	local contentArea = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(194, 76),
		Size = UDim2.new(1, -194, 1, -76),
		BackgroundTransparency = 1,
		Parent = main,
	}) :: Frame
	padding(contentArea, 18, 20, 18, 20)

	local pageHeader = create("Frame", {
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		Parent = contentArea,
	}) :: Frame

	local pageTitle = textLabel(pageHeader, "Dashboard", 22, Enum.Font.FredokaOne, theme.Text)
	pageTitle.Size = UDim2.new(1, 0, 0, 30)

	local pageDescription = textLabel(pageHeader, "Select a tab to begin.", 12, Enum.Font.GothamMedium, theme.TextMuted)
	pageDescription.Position = UDim2.fromOffset(0, 30)
	pageDescription.Size = UDim2.new(1, 0, 0, 20)

	local pages = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(0, 58),
		Size = UDim2.new(1, 0, 1, -58),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = contentArea,
	}) :: Frame

	local toastHost = create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(330, 460),
		BackgroundTransparency = 1,
		Parent = screenGui,
	}) :: Frame
	create("UIListLayout", {
		Padding = UDim.new(0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = toastHost,
	})

	local mobileToggle = create("TextButton", {
		Name = "MobileToggle",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.fromOffset(56, 56),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "E",
		TextColor3 = theme.Background,
		TextSize = 27,
		Font = Enum.Font.FredokaOne,
		Visible = UserInputService.TouchEnabled and not self._visible,
		Parent = screenGui,
	}) :: TextButton
	corner(mobileToggle, 18)
	stroke(mobileToggle, theme.AccentDark, 3)

	self._screenGui = screenGui
	self._root = root
	self._backdrop = backdrop
	self._shadow = shadow
	self._main = main
	self._uiScale = uiScale
	self._shadowScale = shadowScale
	self._topbar = topbar
	self._tabList = tabList
	self._pages = pages
	self._pageTitle = pageTitle
	self._pageDescription = pageDescription
	self._toastHost = toastHost
	self._mobileToggle = mobileToggle

	self:_connect(mobileToggle.Activated, function()
		self:SetVisible(true)
	end)
	makeInteractive(self, mobileToggle, theme.Accent, theme.Accent:Lerp(Color3.new(1, 1, 1), 0.1), theme.AccentDark)

	self:_connect(close.Activated, function()
		self:SetVisible(false)
	end)
	makeInteractive(self, close, theme.Danger, theme.Danger:Lerp(Color3.new(1, 1, 1), 0.12), theme.Danger:Lerp(Color3.new(0, 0, 0), 0.18))

	self:_connect(backdrop.Activated, function()
		-- Intentionally does not close the window; avoids accidental dismissals.
	end)

	self:_connect(UserInputService.InputBegan, function(input: InputObject, gameProcessed: boolean)
		if gameProcessed or UserInputService:GetFocusedTextBox() ~= nil then
			return
		end
		if input.KeyCode == toggleKey then
			self:Toggle()
		end
	end)

	local dragging = false
	local dragInput: InputObject? = nil
	local dragStart = Vector3.zero
	local startPosition = main.Position

	self:_connect(topbar.InputBegan, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = main.Position

			local endedConnection: RBXScriptConnection? = nil
			endedConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if endedConnection then
						endedConnection:Disconnect()
					end
				end
			end)
		end
	end)

	self:_connect(topbar.InputChanged, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	self:_connect(UserInputService.InputChanged, function(input: InputObject)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
			self._openPosition = main.Position
			shadow.Position = main.Position + UDim2.fromOffset(10, 13)
		end
	end)

	local camera = Workspace.CurrentCamera
	if camera then
		self:_connect(camera:GetPropertyChangedSignal("ViewportSize"), function()
			self:_refreshScale()
		end)
	end
	self:_refreshScale()

	if not self._visible then
		root.Visible = false
	end

	return self
end

return Endware
