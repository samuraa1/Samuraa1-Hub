if not _G.Ignore then
	_G.Ignore = {}
end
if _G.SendNotifications == nil then
	_G.SendNotifications = true
end
if _G.ConsoleLogs == nil then
	_G.ConsoleLogs = false
end
if _G.UseFPSCustomToasts == nil then
	_G.UseFPSCustomToasts = true
end

if not game:IsLoaded() then
	repeat
		task.wait()
	until game:IsLoaded()
end

if not _G.Settings then
	_G.Settings = {
		Players = {
			["Ignore Me"] = true,
			["Ignore Others"] = true,
			["Ignore Tools"] = true,
		},
		Meshes = { NoMesh = false, NoTexture = false, Destroy = false },
		Images = { Invisible = true, Destroy = false },
		Explosions = { Smaller = true, Invisible = false, Destroy = false },
		Particles = { Invisible = true, Destroy = false },
		TextLabels = { LowerQuality = false, Invisible = false, Destroy = false },
		MeshParts = {
			LowerQuality = true,
			Invisible = false,
			NoTexture = false,
			NoMesh = false,
			Destroy = false,
		},
		Other = {
			["FPS Cap"] = true,
			["No Camera Effects"] = true,
			["No Clothes"] = true,
			["Low Water Graphics"] = true,
			["No Shadows"] = true,
			["Low Rendering"] = true,
			["Low Quality Parts"] = true,
			["Low Quality Models"] = true,
			["Reset Materials"] = true,
			["Lower Quality MeshParts"] = true,
			ClearNilInstances = false,
		},
	}
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local MaterialService = game:GetService("MaterialService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ME = Players.LocalPlayer
local CanBeEnabled = { "ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles" }

local isTouch = UserInputService.TouchEnabled
local descendantDebounce = math.clamp(tonumber(_G.LoadedWait) or 0.12, 0.05, 0.5)

-- ——— Custom toasts (bottom-right, Mentality-like) ———
local FPSNotify = {}
do
	local gui, holder, seq = nil, nil, 0

	local function resolveParent()
		local ok, h = pcall(function()
			local gh = (getgenv and getgenv().gethui) or gethui
			if type(gh) == "function" then
				return gh()
			end
			return nil
		end)
		if ok and h then
			return h
		end
		return ME:WaitForChild("PlayerGui")
	end

	function FPSNotify.ensure()
		if gui and gui.Parent then
			return
		end
		local sg = Instance.new("ScreenGui")
		sg.Name = "Samuraa1_FPS_Toasts"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 2147483646
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		sg.Parent = resolveParent()

		local holderFrame = Instance.new("Frame")
		holderFrame.Name = "Holder"
		holderFrame.AnchorPoint = Vector2.new(1, 1)
		holderFrame.Position = UDim2.new(1, -12 + (isTouch and -4 or 0), 1, -12 + (isTouch and -8 or 0))
		local vw = 1920
		local cam = workspace.CurrentCamera
		if cam and cam.ViewportSize.X > 0 then
			vw = cam.ViewportSize.X
		end
		holderFrame.Size = UDim2.new(0, math.min(340, vw * 0.92), 0, 0)
		holderFrame.AutomaticSize = Enum.AutomaticSize.Y
		holderFrame.BackgroundTransparency = 1
		holderFrame.Parent = sg

		local list = Instance.new("UIListLayout")
		list.FillDirection = Enum.FillDirection.Vertical
		list.HorizontalAlignment = Enum.HorizontalAlignment.Right
		list.VerticalAlignment = Enum.VerticalAlignment.Bottom
		list.Padding = UDim.new(0, 8)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = holderFrame

		gui = sg
		holder = holderFrame
	end

	function FPSNotify.show(title, text, duration)
		if not _G.SendNotifications or not _G.UseFPSCustomToasts then
			return
		end
		duration = duration or 3.5
		pcall(FPSNotify.ensure)
		if not holder then
			return
		end
		seq += 1
		local order = seq

		local card = Instance.new("Frame")
		card.Name = "Toast"
		card.Size = UDim2.new(1, 0, 0, 0)
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.BackgroundColor3 = Color3.fromRGB(22, 21, 28)
		card.BackgroundTransparency = 0.08
		card.BorderSizePixel = 0
		card.LayoutOrder = -order
		card.Parent = holder

		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(90, 165, 255)
		stroke.Thickness = 1
		stroke.Transparency = 0.35
		stroke.Parent = card

		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 165, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 120, 220)),
		})
		grad.Transparency = NumberSequence.new(0.92)
		grad.Rotation = -90
		grad.Parent = card

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 10)
		pad.PaddingBottom = UDim.new(0, 10)
		pad.PaddingLeft = UDim.new(0, 12)
		pad.PaddingRight = UDim.new(0, 12)
		pad.Parent = card

		local titleLbl = Instance.new("TextLabel")
		titleLbl.BackgroundTransparency = 1
		titleLbl.Font = Enum.Font.GothamMedium
		titleLbl.TextSize = isTouch and 13 or 14
		titleLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.Text = title ~= "" and title or "FPS Booster"
		titleLbl.AutomaticSize = Enum.AutomaticSize.Y
		titleLbl.Size = UDim2.new(1, 0, 0, 0)
		titleLbl.Parent = card

		local body = Instance.new("TextLabel")
		body.BackgroundTransparency = 1
		body.Font = Enum.Font.Gotham
		body.TextSize = isTouch and 12 or 13
		body.TextColor3 = Color3.fromRGB(160, 158, 185)
		body.TextXAlignment = Enum.TextXAlignment.Left
		body.TextWrapped = true
		body.Text = text or ""
		body.AutomaticSize = Enum.AutomaticSize.Y
		body.Size = UDim2.new(1, 0, 0, 0)
		body.Parent = card

		card.BackgroundTransparency = 1
		stroke.Transparency = 1
		titleLbl.TextTransparency = 1
		body.TextTransparency = 1

		local tIn = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		TweenService:Create(card, tIn, { BackgroundTransparency = 0.08 }):Play()
		TweenService:Create(stroke, tIn, { Transparency = 0.35 }):Play()
		TweenService:Create(titleLbl, tIn, { TextTransparency = 0 }):Play()
		TweenService:Create(body, tIn, { TextTransparency = 0 }):Play()

		task.delay(duration, function()
			if not card.Parent then
				return
			end
			local tOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(card, tOut, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(stroke, tOut, { Transparency = 1 }):Play()
			TweenService:Create(titleLbl, tOut, { TextTransparency = 1 }):Play()
			TweenService:Create(body, tOut, { TextTransparency = 1 }):Play()
			task.wait(0.22)
			pcall(function()
				card:Destroy()
			end)
		end)
	end
end

local function notify(title, text, duration)
	if _G.SendNotifications and _G.UseFPSCustomToasts then
		pcall(FPSNotify.show, title, text, duration)
	elseif _G.SendNotifications then
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = title or "FPS",
				Text = text or "",
				Duration = duration or 4,
			})
		end)
	end
end

local function otherSetting(key)
	local o = _G.Settings.Other
	return o and o[key]
end

local function PartOfCharacter(Inst)
	for _, v in Players:GetPlayers() do
		if v ~= ME and v.Character and Inst:IsDescendantOf(v.Character) then
			return true
		end
	end
	return false
end

local function DescendantOfIgnore(Inst)
	for _, v in _G.Ignore do
		if Inst:IsDescendantOf(v) then
			return true
		end
	end
	return false
end

local function shouldProcess(Inst)
	if Inst:IsDescendantOf(Players) then
		return false
	end
	local P = _G.Settings.Players
	local condOthers = (P["Ignore Others"] and not PartOfCharacter(Inst)) or (not P["Ignore Others"])
	local condMe = (P["Ignore Me"] and ME.Character and not Inst:IsDescendantOf(ME.Character)) or (not P["Ignore Me"])
	local condTools = (P["Ignore Tools"] and not Inst:IsA("BackpackItem") and not Inst:FindFirstAncestorWhichIsA("BackpackItem"))
		or (not P["Ignore Tools"])
	local condIgnore = true
	if _G.Ignore and type(_G.Ignore) == "table" and #_G.Ignore > 0 then
		condIgnore = (not table.find(_G.Ignore, Inst)) and (not DescendantOfIgnore(Inst))
	end
	return condOthers and condMe and condTools and condIgnore
end

local function CheckIfBad(Inst)
	if not shouldProcess(Inst) then
		return
	end
	local S = _G.Settings

	if Inst:IsA("DataModelMesh") then
		pcall(function()
			if Inst:IsA("SpecialMesh") then
				if S.Meshes.NoMesh then
					Inst.MeshId = ""
				end
				if S.Meshes.NoTexture then
					Inst.TextureId = ""
				end
			end
			if S.Meshes.Destroy or _G.Settings["No Meshes"] then
				Inst:Destroy()
			end
		end)
		return
	end

	if Inst:IsA("FaceInstance") then
		pcall(function()
			if S.Images.Invisible then
				Inst.Transparency = 1
				pcall(function()
					Inst.Shiny = 1
				end)
			end
			if S.Images.LowDetail then
				pcall(function()
					Inst.Shiny = 1
				end)
			end
			if S.Images.Destroy then
				Inst:Destroy()
			end
		end)
		return
	end

	if Inst:IsA("ShirtGraphic") then
		pcall(function()
			if S.Images.Invisible then
				Inst.Graphic = ""
			end
			if S.Images.Destroy then
				Inst:Destroy()
			end
		end)
		return
	end

	if table.find(CanBeEnabled, Inst.ClassName) then
		pcall(function()
			if S.Particles and S.Particles.Invisible then
				Inst.Enabled = false
			end
			if S.Particles and S.Particles.Destroy then
				Inst:Destroy()
			end
		end)
		return
	end

	if Inst:IsA("PostEffect") and otherSetting("No Camera Effects") then
		pcall(function()
			Inst.Enabled = false
		end)
		return
	end

	if Inst:IsA("Explosion") then
		pcall(function()
			if S.Explosions.Smaller then
				Inst.BlastPressure = 1
				Inst.BlastRadius = 1
			end
			if S.Explosions.Invisible then
				Inst.BlastPressure = 1
				Inst.BlastRadius = 1
				Inst.Visible = false
			end
			if S.Explosions.Destroy then
				Inst:Destroy()
			end
		end)
		return
	end

	if Inst:IsA("Clothing") or Inst:IsA("SurfaceAppearance") or Inst:IsA("BaseWrap") then
		if otherSetting("No Clothes") then
			pcall(Inst.Destroy, Inst)
		end
		return
	end

	if Inst:IsA("BasePart") and not Inst:IsA("MeshPart") then
		if otherSetting("Low Quality Parts") then
			pcall(function()
				Inst.Material = Enum.Material.Plastic
				Inst.Reflectance = 0
			end)
		end
		return
	end

	if Inst:IsA("TextLabel") and Inst:IsDescendantOf(workspace) then
		pcall(function()
			if S.TextLabels.LowerQuality then
				Inst.Font = Enum.Font.SourceSans
				Inst.TextScaled = false
				Inst.RichText = false
				Inst.TextSize = 14
			end
			if S.TextLabels.Invisible then
				Inst.Visible = false
			end
			if S.TextLabels.Destroy then
				Inst:Destroy()
			end
		end)
		return
	end

	if Inst:IsA("Model") then
		if otherSetting("Low Quality Models") then
			pcall(function()
				Inst.LevelOfDetail = 1
			end)
		end
		return
	end

	if Inst:IsA("MeshPart") then
		pcall(function()
			if S.MeshParts.LowerQuality then
				Inst.RenderFidelity = 2
				Inst.Reflectance = 0
				Inst.Material = Enum.Material.Plastic
			end
			if S.MeshParts.Invisible then
				Inst.Transparency = 1
				Inst.RenderFidelity = 2
				Inst.Reflectance = 0
				Inst.Material = Enum.Material.Plastic
			end
			if S.MeshParts.NoTexture then
				pcall(function()
					Inst.TextureID = ""
				end)
			end
			if S.MeshParts.NoMesh then
				pcall(function()
					Inst.MeshId = ""
				end)
			end
			if S.MeshParts.Destroy then
				Inst:Destroy()
			end
		end)
		return
	end
end

-- ——— Environment passes (water, shadows, rendering, materials, fps cap, nil instances) ———
notify("FPS Booster", "Loading…", 2.5)

task.defer(function()
	pcall(function()
		if otherSetting("Low Water Graphics") then
			local terrain = workspace:FindFirstChildOfClass("Terrain")
			if not terrain then
				local t0 = os.clock()
				repeat
					task.wait(0.1)
					terrain = workspace:FindFirstChildOfClass("Terrain")
				until terrain or os.clock() - t0 > 5
			end
			if terrain then
				terrain.WaterWaveSize = 0
				terrain.WaterWaveSpeed = 0
				terrain.WaterReflectance = 0
				terrain.WaterTransparency = 0
				if sethiddenproperty then
					pcall(sethiddenproperty, terrain, "Decoration", false)
				else
					notify("FPS Booster", "sethiddenproperty not available — water tweak skipped.", 4)
				end
				if _G.ConsoleLogs then
					warn("[FPS] Low water graphics")
				end
			end
		end
	end)
end)

task.defer(function()
	pcall(function()
		if otherSetting("No Shadows") then
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 9e9
			Lighting.ShadowSoftness = 0
			if sethiddenproperty then
				pcall(sethiddenproperty, Lighting, "Technology", 2)
			else
				notify("FPS Booster", "sethiddenproperty not available — lighting tech skipped.", 4)
			end
			if _G.ConsoleLogs then
				warn("[FPS] No shadows")
			end
		end
	end)
end)

task.defer(function()
	pcall(function()
		if otherSetting("Low Rendering") then
			pcall(function()
				settings().Rendering.QualityLevel = 1
			end)
			pcall(function()
				settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
			end)
			if _G.ConsoleLogs then
				warn("[FPS] Low rendering")
			end
		end
	end)
end)

task.defer(function()
	pcall(function()
		if otherSetting("Reset Materials") then
			for _, v in MaterialService:GetChildren() do
				pcall(v.Destroy, v)
			end
			pcall(function()
				MaterialService.Use2022Materials = false
			end)
			if _G.ConsoleLogs then
				warn("[FPS] Reset materials")
			end
		end
	end)
end)

task.defer(function()
	pcall(function()
		local cap = otherSetting("FPS Cap")
		if not cap then
			return
		end
		if not setfpscap then
			notify("FPS Booster", "setfpscap not available on this client.", 5)
			return
		end
		if type(cap) == "string" or type(cap) == "number" then
			setfpscap(tonumber(cap) or 240)
			notify("FPS Booster", "FPS cap: " .. tostring(cap), 3)
		elseif cap == true then
			setfpscap(1e6)
			notify("FPS Booster", "FPS uncapped", 3)
		end
		if _G.ConsoleLogs then
			warn("[FPS] FPS cap applied")
		end
	end)
end)

task.defer(function()
	pcall(function()
		if otherSetting("ClearNilInstances") and getnilinstances then
			local n = 0
			for _, v in getnilinstances() do
				if pcall(v.Destroy, v) then
					n += 1
				end
			end
			notify("FPS Booster", "Cleared nil instances: " .. tostring(n), 3)
		elseif otherSetting("ClearNilInstances") then
			notify("FPS Booster", "getnilinstances not available.", 4)
		end
	end)
end)

local desc = game:GetDescendants()
notify("FPS Booster", "Scanning " .. #desc .. " instances…", isTouch and 2.5 or 3)
if _G.ConsoleLogs then
	warn("[FPS] Scanning " .. #desc .. " instances")
end

for i = 1, #desc do
	if i % 4000 == 0 then
		RunService.Heartbeat:Wait()
	end
	CheckIfBad(desc[i])
end

notify("FPS Booster", "Done — optimizations active.", 4)
if _G.ConsoleLogs then
	warn("[FPS] Loaded")
end

game.DescendantAdded:Connect(function(value)
	task.defer(function()
		task.wait(descendantDebounce)
		pcall(CheckIfBad, value)
	end)
end)
