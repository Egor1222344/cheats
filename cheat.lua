--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer

local LOC = {
	home = CFrame.new(-34.18, 9.54, -47.09),
	living = CFrame.new(-30.45, 9.54, -48.73),
	bedroom = CFrame.new(-26.48, 25.29, -70.10),
	bathroom = CFrame.new(-30.76, 25.26, -52.87),
	floor2 = CFrame.new(-3.90, 25.29, -71.19),
	ladder = CFrame.new(-0.17, 9.29, -81.32),
	power = CFrame.new(-1.48, 6.19, -95.05),
	oxygen = CFrame.new(-79.69, 6.29, -127.54),
	elec = CFrame.new(-79.09, 6.17, -132.72),
	safe1 = CFrame.new(-79.71, 21.27, -124.94),
	safe2 = CFrame.new(-15.41, 25.29, -53.18),
	n2gen = CFrame.new(-79.09, 6.17, -132.72),
	n2storage = CFrame.new(-73.50, 6.17, -125.30),
	n2tower = CFrame.new(-95.80, 6.17, -100.50),
	n2office = CFrame.new(-60.30, 6.17, -110.40),
	sn2 = CFrame.new(-78.81, 19.27, -134.28),
}

local function tp(cf)
	local c = lp.Character
	if not c then return end
	local hr = c:FindFirstChild("HumanoidRootPart")
	if hr then hr.CFrame = cf end
end

local function tpObj(names, offset)
	offset = offset or Vector3.new(0, 5, 4)
	for _, name in ipairs(names) do
		local o = Workspace:FindFirstChild(name)
		if o then
			local p
			if o:IsA("Model") and o.PrimaryPart then p = o.PrimaryPart.Position
			elseif o:IsA("BasePart") then p = o.Position
			else
				local h = o:FindFirstChild("Handle")
				if h then p = h.Position end
			end
			if p then tp(CFrame.new(p + offset)) return end
		end
	end
	warn("[TP] Not found: " .. names[1])
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RMH"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 580, 0, 420)
main.Position = UDim2.new(0.5, -290, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 0, 24)
title.Position = UDim2.new(0, 16, 0, 8)
title.BackgroundTransparency = 1
title.Text = "RM Helper"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(120, 190, 255)
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 6)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(140, 140, 155)
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local pages = {}
local tabs = {}

local function createTab(name, idx)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, -20, 1, -90)
	page.Position = UDim2.new(0, 10, 0, 80)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = main

	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 6)
	lay.Parent = page

	pages[idx] = page

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 68, 1, -4)
	btn.Position = UDim2.new(0, 4 + (idx - 1) * 71, 0, 2)
	btn.Text = name
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.TextColor3 = Color3.fromRGB(140, 140, 155)
	btn.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
	btn.BorderSizePixel = 0
	btn.Parent = tabBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		for i, p in ipairs(pages) do p.Visible = (i == idx) end
		for i, t in ipairs(tabs) do
			if i == idx then
				t.BackgroundColor3 = Color3.fromRGB(48, 48, 68)
				t.TextColor3 = Color3.fromRGB(120, 190, 255)
			else
				t.BackgroundColor3 = Color3.fromRGB(26, 26, 38)
				t.TextColor3 = Color3.fromRGB(140, 140, 155)
			end
		end
	end)

	tabs[idx] = btn
	return page
end

local function section(page, text)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 26)
	f.BackgroundTransparency = 1
	f.Parent = page

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 3, 0, 14)
	bar.Position = UDim2.new(0, 0, 0.5, -7)
	bar.BackgroundColor3 = Color3.fromRGB(120, 190, 255)
	bar.BorderSizePixel = 0
	bar.Parent = f

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -10, 1, 0)
	l.Position = UDim2.new(0, 12, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(120, 190, 255)
	l.Parent = f
end

local function makeBtn(page, text, color, action)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 34)
	b.Text = ""
	b.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
	b.BorderSizePixel = 0
	b.Parent = page
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 8, 0, 8)
	dot.Position = UDim2.new(0, 12, 0.5, -4)
	dot.BackgroundColor3 = color
	dot.BorderSizePixel = 0
	dot.Parent = b
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -40, 1, 0)
	lbl.Position = UDim2.new(0, 30, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 13
	lbl.TextColor3 = Color3.fromRGB(225, 225, 235)
	lbl.Parent = b

	b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(46, 46, 62) end)
	b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(36, 36, 48) end)
	b.MouseButton1Click:Connect(action)
end

-- === NIGHT 1 ===
local n1 = createTab("Night 1", 1)
section(n1, "HOUSE ROOMS")
makeBtn(n1, "Home (Spawn)", Color3.fromRGB(70,210,120), function() tp(LOC.home) end)
makeBtn(n1, "Living Room", Color3.fromRGB(80,170,255), function() tp(LOC.living) end)
makeBtn(n1, "Bedroom", Color3.fromRGB(70,210,120), function() tp(LOC.bedroom) end)
makeBtn(n1, "Bathroom", Color3.fromRGB(80,220,200), function() tp(LOC.bathroom) end)
makeBtn(n1, "Floor 2", Color3.fromRGB(170,100,240), function() tp(LOC.floor2) end)
makeBtn(n1, "Ladder", Color3.fromRGB(250,200,60), function() tp(LOC.ladder) end)

section(n1, "OBJECTIVES")
makeBtn(n1, "Power Console", Color3.fromRGB(80,170,255), function() tp(LOC.power) end)
makeBtn(n1, "Oxygen Generator", Color3.fromRGB(80,220,200), function() tp(LOC.oxygen) end)
makeBtn(n1, "Electrical Generator", Color3.fromRGB(250,200,60), function() tp(LOC.elec) end)

section(n1, "SAFE SPOTS")
makeBtn(n1, "Safe Spot 1 (Roof)", Color3.fromRGB(70,210,120), function() tp(LOC.safe1) end)
makeBtn(n1, "Safe Spot 2 (Bedroom)", Color3.fromRGB(70,210,120), function() tp(LOC.safe2) end)

-- === NIGHT 2 ===
local n2 = createTab("Night 2", 2)
section(n2, "FACTORY OBJECTIVES")
makeBtn(n2, "Power Generator", Color3.fromRGB(250,200,60), function() tp(LOC.n2gen) end)
makeBtn(n2, "Power Storage", Color3.fromRGB(80,220,200), function() tp(LOC.n2storage) end)
makeBtn(n2, "Radio Tower", Color3.fromRGB(80,170,255), function() tp(LOC.n2tower) end)
makeBtn(n2, "Office", Color3.fromRGB(120,190,255), function() tp(LOC.n2office) end)

section(n2, "SAFE SPOTS")
makeBtn(n2, "Safe Spot (N2)", Color3.fromRGB(70,210,120), function() tp(LOC.sn2) end)

-- === NIGHT 3 ===
local n3 = createTab("Night 3", 3)
section(n3, "CAMP LOCATIONS")
makeBtn(n3, "Lodge", Color3.fromRGB(255,150,50), function() tpObj({"Lodge","MainLodge"}, Vector3.new(0,5,10)) end)
makeBtn(n3, "Cabin 1", Color3.fromRGB(100,200,100), function() tpObj({"Cabin1","Cabin_1"}, Vector3.new(0,5,5)) end)
makeBtn(n3, "Cabin 2", Color3.fromRGB(100,200,100), function() tpObj({"Cabin2","Cabin_2"}, Vector3.new(0,5,5)) end)
makeBtn(n3, "Cabin 3", Color3.fromRGB(100,200,100), function() tpObj({"Cabin3","Cabin_3"}, Vector3.new(0,5,5)) end)
makeBtn(n3, "Cabin 4", Color3.fromRGB(100,200,100), function() tpObj({"Cabin4","Cabin_4"}, Vector3.new(0,5,5)) end)
makeBtn(n3, "Bunker", Color3.fromRGB(150,150,180), function() tpObj({"Bunker","BunkerDoor"}, Vector3.new(0,5,10)) end)
makeBtn(n3, "Campfire", Color3.fromRGB(255,100,50), function() tpObj({"Campfire","Fireplace"}, Vector3.new(0,5,5)) end)

section(n3, "CAMP ITEMS")
makeBtn(n3, "Gas Can", Color3.fromRGB(255,80,80), function() tpObj({"JerryCan","GasCan"}, Vector3.new(0,3,3)) end)
makeBtn(n3, "Shotgun", Color3.fromRGB(255,200,50), function() tpObj({"Shotgun"}, Vector3.new(0,3,3)) end)
makeBtn(n3, "Shells", Color3.fromRGB(255,180,50), function() tpObj({"Shell","ShotgunShell"}, Vector3.new(0,3,3)) end)
makeBtn(n3, "Bloxy Cola", Color3.fromRGB(100,200,255), function() tpObj({"BloxyCola"}, Vector3.new(0,3,3)) end)
makeBtn(n3, "Marshmallow", Color3.fromRGB(255,200,150), function() tpObj({"Marshmallow"}, Vector3.new(0,3,3)) end)
makeBtn(n3, "Trail Camera", Color3.fromRGB(150,200,100), function() tpObj({"TrailCamera"}, Vector3.new(0,3,3)) end)
makeBtn(n3, "Battery", Color3.fromRGB(255,255,80), function() tpObj({"Battery"}, Vector3.new(0,3,3)) end)

section(n3, "SAFE SPOTS")
makeBtn(n3, "Safe Spot (N3)", Color3.fromRGB(70,210,120), function() tp(LOC.safe1) end)

-- === SPIRIT ===
local t4 = createTab("Spirit", 4)
section(t4, "BEDROOM")
makeBtn(t4, "Bed (hide)", Color3.fromRGB(70,210,120), function() tpObj({"Bed","PlayerBed"}, Vector3.new(0,5,-6)) end)
makeBtn(t4, "Lamp", Color3.fromRGB(250,200,60), function() tpObj({"Lamp","LightSwitch"}, Vector3.new(0,5,3)) end)
makeBtn(t4, "Closet", Color3.fromRGB(170,100,240), function() tpObj({"Closet","Wardrobe"}, Vector3.new(0,5,3)) end)
makeBtn(t4, "Teddy Bear", Color3.fromRGB(255,100,200), function() tpObj({"Bear","TeddyBear","Teddy"}, Vector3.new(0,5,3)) end)
makeBtn(t4, "Desk / Clock", Color3.fromRGB(80,170,255), function() tpObj({"Desk","Clock","AlarmClock"}, Vector3.new(0,5,3)) end)
makeBtn(t4, "Vent", Color3.fromRGB(80,220,200), function() tpObj({"Vent","AirVent"}, Vector3.new(0,5,3)) end)
makeBtn(t4, "Game Console", Color3.fromRGB(120,190,255), function() tpObj({"Console","GameConsole"}, Vector3.new(0,5,3)) end)

-- === MANSION ===
local t5 = createTab("Mansion", 5)
section(t5, "ROOMS")
makeBtn(t5, "Candy Bowl", Color3.fromRGB(255,100,200), function() tpObj({"CandyBowl","Bowl"}, Vector3.new(0,5,3)) end)
makeBtn(t5, "Grandfather Clock", Color3.fromRGB(250,200,60), function() tpObj({"GrandfatherClock","Clock"}, Vector3.new(0,5,3)) end)
makeBtn(t5, "Fireplace", Color3.fromRGB(255,150,50), function() tpObj({"Fireplace"}, Vector3.new(0,5,5)) end)
makeBtn(t5, "Basement", Color3.fromRGB(240,80,80), function() tpObj({"Basement","BasementDoor"}, Vector3.new(0,5,5)) end)
makeBtn(t5, "Kitchen", Color3.fromRGB(170,100,240), function() tpObj({"Kitchen"}, Vector3.new(0,5,5)) end)
makeBtn(t5, "Dining Room", Color3.fromRGB(80,170,255), function() tpObj({"DiningRoom","Dining"}, Vector3.new(0,5,5)) end)
makeBtn(t5, "Guest Bedroom", Color3.fromRGB(80,220,200), function() tpObj({"GuestBedroom","GuestRoom"}, Vector3.new(0,5,5)) end)
makeBtn(t5, "Grey Bedroom", Color3.fromRGB(180,180,190), function() tpObj({"GreyBedroom","GreyRoom"}, Vector3.new(0,5,5)) end)
makeBtn(t5, "Yellow Room", Color3.fromRGB(250,200,60), function() tpObj({"YellowRoom","Catwalk"}, Vector3.new(0,5,5)) end)

-- === BUNKER ===
local t6 = createTab("Bunker", 6)
section(t6, "BUNKER")
makeBtn(t6, "Entrance", Color3.fromRGB(150,150,180), function() tpObj({"Bunker","BunkerDoor"}, Vector3.new(0,5,10)) end)
makeBtn(t6, "Interior", Color3.fromRGB(130,130,160), function() tpObj({"BunkerInside","BunkerRoom"}, Vector3.new(0,5,5)) end)

-- === UTILS ===
local t7 = createTab("Utils", 7)
section(t7, "PLAYER")

local function makeToggle(page, text, onColor, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 36)
	b.Text = ""
	b.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
	b.BorderSizePixel = 0
	b.Parent = page
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new(0, 10, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(120, 120, 135)
	knob.BorderSizePixel = 0
	knob.Parent = b
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -50, 1, 0)
	lbl.Position = UDim2.new(0, 36, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 13
	lbl.TextColor3 = Color3.fromRGB(225, 225, 235)
	lbl.Parent = b

	local state = false
	b.MouseButton1Click:Connect(function()
		state = not state
		if state then
			knob.BackgroundColor3 = onColor
			lbl.TextColor3 = onColor
			b.BackgroundColor3 = Color3.fromRGB(46, 46, 62)
		else
			knob.BackgroundColor3 = Color3.fromRGB(120, 120, 135)
			lbl.TextColor3 = Color3.fromRGB(225, 225, 235)
			b.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
		end
		callback(state)
	end)
end

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local threads = {}
local function killT(n) if threads[n] then task.cancel(threads[n]) threads[n] = nil end end

makeToggle(t7, "Infinite Stamina", Color3.fromRGB(70,210,120), function(s)
	if s then
		threads.stam = task.spawn(function()
			while task.wait(0.1) do
				local c = lp.Character
				if c and c:FindFirstChild("Sprint") then
					local st = c.Sprint:FindFirstChild("Stam")
					if st then st.Value = 5 end
				end
			end
		end)
	else killT("stam") end
end)

makeToggle(t7, "Speed Boost", Color3.fromRGB(120,190,255), function(s)
	if s then
		threads.spd = task.spawn(function()
			while task.wait(0.1) do
				local c = lp.Character
				if c then
					local h = c:FindFirstChild("Humanoid")
					if h then h.WalkSpeed = 32 end
				end
			end
		end)
	else
		killT("spd")
		local c = lp.Character
		if c then
			local h = c:FindFirstChild("Humanoid")
			if h then h.WalkSpeed = 16 end
		end
	end
end)

makeToggle(t7, "FullBright", Color3.fromRGB(250,200,60), function(s)
	if s then
		threads.fb = task.spawn(function()
			while task.wait() do
				Lighting.Brightness = 2
				Lighting.ClockTime = 14
				Lighting.FogEnd = 100000
				Lighting.GlobalShadows = false
			end
		end)
	else killT("fb") end
end)

local ncConn
makeToggle(t7, "Noclip", Color3.fromRGB(170,100,240), function(s)
	if s then
		ncConn = RunService.Stepped:Connect(function()
			local c = lp.Character
			if c then
				for _, p in ipairs(c:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	else
		if ncConn then ncConn:Disconnect() ncConn = nil end
	end
end)

makeToggle(t7, "Anti-Freeze", Color3.fromRGB(80,170,255), function(s)
	if s then
		threads.af = task.spawn(function()
			while task.wait(1) do
				local c = lp.Character
				if c then
					local t = c:FindFirstChild("Temperature")
					if t then t.Value = 20 end
					local fr = c:FindFirstChild("Freeze")
					if fr then fr.Value = 0 end
				end
			end
		end)
	else killT("af") end
end)

-- Активируем первую вкладку
pages[1].Visible = true
tabs[1].BackgroundColor3 = Color3.fromRGB(48, 48, 68)
tabs[1].TextColor3 = Color3.fromRGB(120, 190, 255)

-- Перетаскивание
local dragging = false
local dragStart, frameStart
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		frameStart = main.Position
	end
end)
header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
	end
end)

print("[RMH] Loaded OK!")
