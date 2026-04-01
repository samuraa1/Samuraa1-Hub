--[[
  Samuraa1 Hub — Boost FPS (max preset)
  Override: set _G.Settings before this file runs, or edit the table below.
  Loader: https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/FPSBooster.lua
]]

local UserInputService = game:GetService("UserInputService")
local touch = UserInputService.TouchEnabled
local gamepad = UserInputService.GamepadEnabled

-- Slightly softer text-mesh work on pure touch to reduce hitching on low-end phones
local softTouch = touch and not UserInputService.KeyboardEnabled

_G.Settings = {
	Players = {
		["Ignore Me"] = true,
		["Ignore Others"] = true,
		["Ignore Tools"] = true,
	},
	Meshes = {
		NoMesh = false,
		NoTexture = false,
		Destroy = false,
	},
	Images = {
		Invisible = true,
		Destroy = false,
	},
	Explosions = {
		Smaller = true,
		Invisible = false,
		Destroy = false,
	},
	Particles = {
		Invisible = true,
		Destroy = false,
	},
	TextLabels = {
		LowerQuality = true,
		Invisible = false,
		Destroy = false,
	},
	MeshParts = {
		LowerQuality = true,
		Invisible = false,
		NoTexture = false,
		NoMesh = false,
		Destroy = false,
	},
	Other = {
		["FPS Cap"] = touch and 144 or true,
		["No Camera Effects"] = true,
		["No Clothes"] = not softTouch,
		["Low Water Graphics"] = true,
		["No Shadows"] = true,
		["Low Rendering"] = true,
		["Low Quality Parts"] = true,
		["Low Quality Models"] = true,
		["Reset Materials"] = true,
		["Lower Quality MeshParts"] = true,
		ClearNilInstances = not touch,
	},
}

_G.LoadedWait = softTouch and 0.18 or 0.1
_G.UseFPSCustomToasts = true
_G.SendNotifications = true

if gamepad and touch then
	_G.Settings.Other["No Clothes"] = false
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/FPSBooster.lua"))()
