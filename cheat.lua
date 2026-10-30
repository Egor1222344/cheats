--========================================================
--  ADMIN PANEL  •  один LocalScript  •  доступна ВСЕМ
--  Куда: StarterPlayer → StarterPlayerScripts → LocalScript
--  Клавиши: F — полёт | N — ноуклип | P — панель вкл/выкл
--========================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local camera       = workspace.CurrentCamera

--------------------------- НАСТРОЙКИ -----------------------------
local FLY_SPEED   = 60   -- скорость полёта
local SPEED_STEP  = 4    -- шаг скорости бега
local SPEED_MAX   = 200
local JUMP_STEP   = 10   -- шаг силы прыжка
local JUMP_MAX    = 500

--------------------------- СОСТОЯНИЕ ------------------------------
local state = {
	fly = false, noclip = false, infJump = false, god = false,
	esp = false, day = true, walkSpeed = 16, jumpPower = 50,
}
local setters = {} -- key -> функция визуального обновления переключателя

--------------------------- УТИЛИТЫ --------------------------------
local BG      = Color3.fromRGB(17, 19, 28)
local PANEL   = Color3.fromRGB(26, 29, 41)
local ROW     = Color3.fromRGB(34, 38, 54)
local ACCENT  = Color3.fromRGB(108, 92, 231)
local GREEN   = Color3.fromRGB(46, 204, 113)
local RED     = Color3.fromRGB(231, 76, 60)
local TEXT    = Color3.fromRGB(235, 238, 245)
local SUBTLE  = Color3.fromRGB(140, 148, 166)

local function create(class, props)
	local inst = Instance.new(class)
	local parent = props.Parent
	props.Parent = nil
	for k, v in pairs(props) do inst[k] = v end
	inst.Parent = parent
	return inst
end

local function getChar()
	local char = LocalPlayer.Character
	if not char then return nil, nil, nil end
	return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

--------------------------- GUI -------------------------------------
local gui = create("ScreenGui", {
	Name = "AdminPanel", ResetOnSpawn = false,
	IgnoreGuiInset = true, Parent = LocalPlayer:WaitForChild("PlayerGui"),
})

-- Счётчик FPS (виден всегда)
local fpsLabel = create("TextLabel", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12),
	Size = UDim2.fromOffset(90, 30), BackgroundColor3 = PANEL,
	Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = GREEN,
	Text = "FPS: 60", Parent = gui,
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = fpsLabel })
create("UIStroke", { Color = BG, Thickness = 2, Parent = fpsLabel })

-- Плавающая кнопка открытия панели
local openButton = create("TextButton", {
	AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, -12),
	Size = UDim2.fromOffset(44, 44), BackgroundColor3 = ACCENT,
	Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = TEXT,
	Text = "⚡", Parent = gui,
})
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = openButton })

-- Главное окно
local panel = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(330, 470), BackgroundColor3 = PANEL, Active = true,
	Parent = gui,
})
create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = panel })
create("UIStroke", { Color = BG, Thickness = 3, Parent = panel })

local titleBar = create("Frame", {
	Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = BG,
	BorderSizePixel = 0, Parent = panel,
})
create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = titleBar })
create("TextLabel", {
	BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0),
	Size = UDim2.new(1, -60, 1, 0), Font = Enum.Font.GothamBold,
	TextSize = 16, TextColor3 = TEXT, TextXAlignment = Enum.TextXAlignment.Left,
	Text = "ADMIN PANEL", Parent = titleBar,
})
local closeButton = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
	Size = UDim2.fromOffset(28, 28), BackgroundColor3 = RED,
	Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = TEXT,
	Text = "✕", Parent = titleBar,
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = closeButton })

local content = create("ScrollingFrame", {
	Position = UDim2.fromOffset(10, 50), Size = UDim2.new(1, -20, 1, -96),
	BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 4, ScrollBarImageColor3 = ACCENT,
	CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y, Parent = panel,
})
create("UIListLayout", {
	Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content,
})
create("UIPadding", { PaddingRight = UDim.new(0, 8), Parent = content })

create("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8),
	Size = UDim2.new(1, -24, 0, 34), BackgroundTransparency = 1,
	Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SUBTLE,
	TextWrapped = true, Text = "Клавиши:  F — полёт  •  N — ноуклип  •  P — панель  •  Space/Shift — вверх/вниз в полёте",
	Parent = panel,
})

-- Перетаскивание окна
do
	local dragging, dragStart, startPos = false, nil, nil
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = panel.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			panel.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

------------------------ СТРОКИ GUI ---------------------------------
local nextOrder = 0
local function addRow()
	nextOrder += 1
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = ROW,
		BorderSizePixel = 0, LayoutOrder = nextOrder, Parent = content,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
	return row
end

local function makeToggleRow(key, title, hotkey, onToggle)
	local row = addRow()
	create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -96, 1, 0), Font = Enum.Font.GothamBold,
		TextSize = 14, TextColor3 = TEXT, TextXAlignment = Enum.TextXAlignment.Left,
		Text = hotkey and (title .. "  [" .. hotkey .. "]") or title, Parent = row,
	})
	local btn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(64, 24), BackgroundColor3 = ROW,
		Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = RED,
		Text = "OFF", Parent = row,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	create("UIStroke", { Color = RED, Thickness = 1.5, Parent = btn })

	local on = false
	local function refresh()
		btn.Text = on and "ON" or "OFF"
		btn.TextColor3 = on and BG or RED
		btn.BackgroundColor3 = on and GREEN or ROW
		btn:FindFirstChildOfClass("UIStroke").Color = on and GREEN or RED
	end
	setters[key] = function(v, silent)
		on = v
		refresh()
		if not silent then onToggle(on) end
	end
	btn.MouseButton1Click:Connect(function()
		on = not on
		refresh()
		onToggle(on)
	end)
end

local function makeValueRow(title, initial, step, maxValue, onApply)
	local row = addRow()
	local value = initial
	local label = title
	local valueLabel = create("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -120, 1, 0), Font = Enum.Font.GothamBold,
		TextSize = 14, TextColor3 = TEXT, TextXAlignment = Enum.TextXAlignment.Left,
		Text = label .. ": " .. value, Parent = row,
	})

	local function setVal(newVal)
		value = math.clamp(newVal, 0, maxValue)
		valueLabel.Text = label .. ": " .. value
		onApply(value)
	end
	for _, def in ipairs({ { text = "−", off = -100 }, { text = "+", off = -40 } }) do
		local b = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, def.off, 0.5, 0),
			Size = UDim2.fromOffset(26, 26), BackgroundColor3 = ACCENT,
			Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = TEXT,
			Text = def.text, Parent = row,
		})
		create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = b })
		b.MouseButton1Click:Connect(function()
			setVal(value + (def.text == "+" and step or -step))
		end)
	end
	return setVal
end

local function makeActionRow(title, onFire)
	local row = addRow()
	local btn = create("TextButton", {
		Position = UDim2.fromOffset(6, 5), Size = UDim2.new(1, -12, 1, -10),
		BackgroundColor3 = BG, Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = TEXT, Text = title, AutoButtonColor = true, Parent = row,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
	btn.MouseButton1Click:Connect(onFire)
	return btn
end

------------------------ ЧИТ-ФУНКЦИИ ---------------------------------

-- ПОЛЁТ
local bodyVel, bodyGyro, flyConn = nil, nil, nil
local keys = {}

local function stopFly()
	if flyConn then flyConn:Disconnect() flyConn = nil end
	if bodyVel then bodyVel:Destroy() bodyVel = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	state.fly = false
end

local function startFly()
	local _, _, hrp = getChar()
	if not hrp then return false end
	bodyVel = create("BodyVelocity", {
		MaxForce = Vector3.new(4e5, 4e5, 4e5), Velocity = Vector3.zero, Parent = hrp,
	})
	bodyGyro = create("BodyGyro", {
		MaxTorque = Vector3.new(4e6, 4e6, 4e6), P = 3000, D = 500, Parent = hrp,
	})
	flyConn = RunService.RenderStepped:Connect(function()
		if not bodyVel or not bodyGyro then return end
		local camCF = camera.CFrame
		local dir = Vector3.zero
		if keys.W then dir += camCF.LookVector end
		if keys.S then dir -= camCF.LookVector end
		if keys.D then dir += camCF.RightVector end
		if keys.A then dir -= camCF.RightVector end
		if keys.Space then dir += Vector3.new(0, 1, 0) end
		if keys.Shift then dir -= Vector3.new(0, 1, 0) end
		bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * FLY_SPEED or Vector3.zero
		bodyGyro.CFrame = CFrame.new(camCF.Position, camCF.Position + camCF.LookVector)
	end)
	state.fly = true
	return true
end

-- НОУКЛИП
local noclipConn, savedCollisions = nil, {}

local function stopNoclip()
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	for part, canCollide in pairs(savedCollisions) do
		if part.Parent then part.CanCollide = canCollide end
	end
	table.clear(savedCollisions)
	state.noclip = false
end

local function startNoclip()
	local char = getChar()
	if not char then return false end
	savedCollisions = {}
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			savedCollisions[part] = part.CanCollide
		end
	end
	noclipConn = RunService.Stepped:Connect(function()
		local c = LocalPlayer.Character
		if not c then return end
		for _, part in ipairs(c:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end)
	state.noclip = true
	return true
end

-- БОГ-РЕЖИМ
local function applyGod(hum)
	if state.god then
		hum.MaxHealth = math.huge
		hum.Health = math.huge
	else
		hum.MaxHealth = 100
		if hum.Health == math.huge then hum.Health = 100 end
	end
end

-- ESP
local espHighlights = {}

local function applyEspToPlayer(plr)
	if not state.esp then return end
	if plr == LocalPlayer then return end
	local char = plr.Character
	if not char or espHighlights[plr] then return end
	espHighlights[plr] = create("Highlight", {
		FillColor = ACCENT, OutlineColor = GREEN,
		FillTransparency = 0.6, OutlineTransparency = 0, Parent = char,
	})
end

local function removeEsp()
	for plr, hl in pairs(espHighlights) do
		if hl then hl:Destroy() end
		espHighlights[plr] = nil
	end
end

-- СКОРОСТЬ / ПРЫЖОК
local function applySpeed(v)
	state.walkSpeed = v
	local _, hum = getChar()
	if hum then hum.WalkSpeed = v end
end

local function applyJump(v)
	state.jumpPower = v
	local _, hum = getChar()
	if hum then
		pcall(function()
			hum.UseJumpPower = true
			hum.JumpPower = v
		end)
	end
end

------------------------ РЯДЫ ПАНЕЛИ ----------------------------------
makeToggleRow("fly", "Полёт", "F", function(on)
	if on then
		if not startFly() then
			local s = setters.fly
			if s then s(false, true) end
		end
	else
		stopFly()
	end
end)

makeToggleRow("noclip", "Ноуклип", "N", function(on)
	if on then
		if not startNoclip() then
			local s = setters.noclip
			if s then s(false, true) end
		end
	else
		stopNoclip()
	end
end)

makeValueRow("Скорость бега", 16, SPEED_STEP, SPEED_MAX, applySpeed)
makeValueRow("Сила прыжка", 50, JUMP_STEP, JUMP_MAX, applyJump)

makeToggleRow("infJump", "Бесконечный прыжок", nil, function(on)
	state.infJump = on
end)

makeToggleRow("god", "Бог-режим", nil, function(on)
	state.god = on
	local _, hum = getChar()
	if hum then applyGod(hum) end
end)

makeToggleRow("esp", "ESP игроков", nil, function(on)
	state.esp = on
	if on then
		for _, plr in ipairs(Players:GetPlayers()) do applyEspToPlayer(plr) end
	else
		removeEsp()
	end
end)

makeToggleRow("day", "День / Ночь", nil, function(on)
	state.day = on
	if on then
		Lighting.ClockTime = 14
		Lighting.Brightness = 2
	else
		Lighting.ClockTime = 0
		Lighting.Brightness = 1
	end
end)

makeActionRow("Телепорт на спавн", function()
	local _, _, hrp = getChar()
	if not hrp then return end
	local spawnLoc = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	local pos = spawnLoc and spawnLoc.Position or Vector3.new(0, 50, 0)
	hrp.CFrame = CFrame.new(pos + Vector3.new(0, 6, 0))
end)

makeActionRow("Респавн персонажа", function()
	LocalPlayer:LoadCharacter()
end)

makeActionRow("Убить персонажа", function()
	local _, hum = getChar()
	if hum then hum.Health = 0 end
end)

makeActionRow("Сбросить все читы", function()
	for _, key in ipairs({ "fly", "noclip", "infJump", "god", "esp" }) do
		local s = setters[key]
		if s then s(false, false) end
	end
	stopFly()
	stopNoclip()
	removeEsp()
	applySpeed(16)
	applyJump(50)
	if not state.day then
		local s = setters.day
		if s then s(true, false) end
	end
end)

------------------------ СОБЫТИЯ ---------------------------------------

-- Бесконечный прыжок
UserInputService.JumpRequest:Connect(function()
	if state.infJump then
		local _, hum = getChar()
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- Клавиши движения и хоткеи
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	local key = input.KeyCode
	if key == Enum.KeyCode.W then keys.W = true end
	if key == Enum.KeyCode.A then keys.A = true end
	if key == Enum.KeyCode.S then keys.S = true end
	if key == Enum.KeyCode.D then keys.D = true end
	if key == Enum.KeyCode.Space then keys.Space = true end
	if key == Enum.KeyCode.LeftShift then keys.Shift = true end

	if key == Enum.KeyCode.F then
		local s = setters.fly
		if s then s(not state.fly, false) end
	elseif key == Enum.KeyCode.N then
		local s = setters.noclip
		if s then s(not state.noclip, false) end
	elseif key == Enum.KeyCode.P then
		panel.Visible = not panel.Visible
	end
end)

UserInputService.InputEnded:Connect(function(input)
	local key = input.KeyCode
	if key == Enum.KeyCode.W then keys.W = false end
	if key == Enum.KeyCode.A then keys.A = false end
	if key == Enum.KeyCode.S then keys.S = false end
	if key == Enum.KeyCode.D then keys.D = false end
	if key == Enum.KeyCode.Space then keys.Space = false end
	if key == Enum.KeyCode.LeftShift then keys.Shift = false end
end)

closeButton.MouseButton1Click:Connect(function() panel.Visible = false end)
openButton.MouseButton1Click:Connect(function() panel.Visible = true end)

-- Новые игроки (для ESP)
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function() applyEspToPlayer(plr) end)
end)
Players.PlayerRemoving:Connect(function(plr)
	if espHighlights[plr] then
		espHighlights[plr]:Destroy()
		espHighlights[plr] = nil
	end
end)

-- Новый персонаж: пере-применяем активные режимы, сбрасываем зависящие от тела
LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end

	stopFly()
	stopNoclip()
	local s = setters.fly
	if s then s(false, true) end
	s = setters.noclip
	if s then s(false, true) end

	hum.WalkSpeed = state.walkSpeed
	pcall(function()
		hum.UseJumpPower = true
		hum.JumpPower = state.jumpPower
	end)
	if state.god then applyGod(hum) end

	hum.Died:Connect(function()
		stopFly()
		stopNoclip()
		local sf = setters.fly
		if sf then sf(false, true) end
		local sn = setters.noclip
		if sn then sn(false, true) end
	end)
end)

------------------------ СЧЁТЧИК FPS -----------------------------------
do
	local frames, lastTime = 0, os.clock()
	RunService.RenderStepped:Connect(function()
		frames += 1
		local now = os.clock()
		local dt = now - lastTime
		if dt >= 0.5 then
			local fps = math.floor(frames / dt + 0.5)
			fpsLabel.Text = "FPS: " .. fps
			if fps >= 50 then
				fpsLabel.TextColor3 = GREEN
			elseif fps >= 30 then
				fpsLabel.TextColor3 = Color3.fromRGB(241, 196, 15)
			else
				fpsLabel.TextColor3 = RED
			end
			frames = 0
			lastTime = now
		end
	end)
end
