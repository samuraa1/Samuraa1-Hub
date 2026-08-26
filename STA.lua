-- open sourced because this is vibecoded shit


































































































local GAME_ID = 9912025777
local PLACE_ID = 138145699008779
local LOBBY_PLACE = 102054284786904

local function isLobbyPlace()
    if game.PlaceId == LOBBY_PLACE or game.PlaceId == 1020542847869 then
        return true
    end

    local rs = game:GetService("ReplicatedStorage")
    local resources = rs:FindFirstChild("Resources")
    local events = resources and resources:FindFirstChild("Events")
    if events and not events:FindFirstChild("Client") and rs:FindFirstChild("Remotes") then
        return game:GetService("Workspace"):FindFirstChild("Teleporters") ~= nil
    end

    return false
end

if game.GameId ~= GAME_ID and game.PlaceId ~= PLACE_ID and not isLobbyPlace() then
    game.Players.LocalPlayer:Kick("Game Not Supported. Only Secure the Airport Is Supported.")
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Lighting = cloneref(game:GetService("Lighting"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local Stats = cloneref(game:GetService("Stats"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local HttpService = cloneref(game:GetService("HttpService"))

local function httpGetString(url, retries)
    retries = retries or 4
    for attempt = 1, retries do
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and type(result) == "string" and #result > 0 then
            return result
        end
        if ok and typeof(result) == "Instance" and result:IsA("ModuleScript") then
            return result.Source
        end
        if typeof(request) == "function" then
            local okReq, resp = pcall(function()
                return request({ Url = url, Method = "GET" })
            end)
            if okReq and resp and type(resp.Body) == "string" and #resp.Body > 0 then
                return resp.Body
            end
        end
        if attempt < retries then
            task.wait(0.25 * attempt)
        end
    end
    error("Failed to download: " .. url)
end

local function loadRemoteLua(url)
    local source = httpGetString(url)
    if type(source) ~= "string" then
        error("Remote source is not a string: " .. url)
    end
    return loadstring(source)()
end

local plr = Players.LocalPlayer
local startTime = os.clock()

local DISCORD_LINK = "https://discord.gg/DPCKQRJmdF"
local DISCORD_JOIN_URL = "https://pastebin.com/raw/iYvRJrSf"
local BOOSTFPS_URL = "https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/BoostFPS.lua"
local CHANGELOGS_URL = "https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/STA-Changelogs.lua"
local STA_SCRIPT_URL = "https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/STA.lua"

local PASSENGER_NAMES = {
    NPCTemplate = true,
    AgentTemplate = true,
}

local ENEMY_NAMES = {
    BossNPC = true,
    EnemyNPC = true,
    AmbushNPC = true,
    FSEnemyNPC = true,
    FSFiremanNPC = true,
}

local GAME_MARK_NAMES = {
    SearchHighlight = true,
    ArrestHighlight = true,
    SearchBillboard = true,
    ArrestBillboard = true,
    CorrectBillboard = true,
}

local execCount = 1
pcall(function()
    local folder, file = "Samuraa1Hub", "Samuraa1Hub/sta-execs.txt"
    if not isfolder(folder) then makefolder(folder) end
    if isfile(file) then execCount = (tonumber(readfile(file)) or 0) + 1 end
    writefile(file, tostring(execCount))
end)
shared._execs = execCount

local Resources = ReplicatedStorage:WaitForChild("Resources", 20)
local Events = Resources and Resources:WaitForChild("Events", 10)
local ClientEvents
if isLobbyPlace() then
    ClientEvents = Events and Events:FindFirstChild("Client")
else
    ClientEvents = Events and Events:WaitForChild("Client", 15)
end

local RemoteComputers = ClientEvents and ClientEvents:FindFirstChild("Computers")

local NPCItems = Resources and Resources:FindFirstChild("NPCAssets") and Resources.NPCAssets:FindFirstChild("Items")
local RealContrabandNames = {}
local FalseContrabandNames = {}
local LuggageBadModelNames = {
    Bomb = true,
    LotsOfContraband = true,
}

if NPCItems then
    local realFolder = NPCItems:FindFirstChild("RealContraband")
    local falseFolder = NPCItems:FindFirstChild("FalseContraband")
    if realFolder then
        for _, item in realFolder:GetChildren() do
            RealContrabandNames[item.Name] = true
        end
    end
    if falseFolder then
        for _, item in falseFolder:GetChildren() do
            FalseContrabandNames[item.Name] = true
        end
    end
end

local Library
local passengerESP = {}
local luggageESP = {}
local enemyESP = {}
local worldESP = {}
local forEachPassenger
local getEnemiesInRange
local collectLiveEnemies
local isTargetVisible
local getShootOrigin
local updatePassengerESP, updateLuggageESP, updateEnemyESP, updateWorldESP
local runAutomation
local tweenHRPTo
local tryAmmoRefill
local Webhook = {}
local originalLighting = {}
local savedCamera = { captured = false }
local pendingDeny = setmetatable({}, { __mode = "k" })
local pendingHostileCapture = setmetatable({}, { __mode = "k" })
local arrestFocusNpc = nil
local antiAfkConn
local lastTaser = 0
local lastArrest = 0
local lastGun = 0
local lastLuggage = 0
local lastReload = 0
local lastESPUpdate = 0
local lastAmmoRefill = 0
local lastExtinguisher = 0
local lastPowerReboot = 0
local lastWebhookSend = 0
local lastRetreat = 0
local lastFireDodge = 0
local fireDodgeBusy = false
local powerRebootBusy = false
local ammoRefillBusy = false
local fireExtinguishBusy = false
local retreatBusy = false
local defaultFOV = 70
local checkpointBusy = false
local moveBusy = false
local moveBusyStartedAt = 0
local powerOffline = false
local handledCheckpoint = setmetatable({}, { __mode = "k" })
local farmStandMoving = false

local THIRD_PERSON_DISTANCE = 10
local CHECKPOINT_MD_POINT = 14
local CHECKPOINT_ID_MIN = 15
local CHECKPOINT_PODIUM_RANGE = 12
local JAIL_STAND_POS = Vector3.new(-73.202, 3.170, -7.747)
local SAFE_RETREAT_FALLBACK = JAIL_STAND_POS
local HOSTILE_SCAN_RANGE = 150
local BOSS_FIRE_DODGE_PADDING = 2
local BOSS_FIRE_DODGE_STEP = 11
local BOSS_FIRE_DODGE_DURATION = 0.18
local FARM_STAND_POS = Vector3.new(-46.58, 3.44, -13.56)
local FARM_STAND_THRESHOLD = 1.5
local FARM_GOOD_NPC_SPEED = 200
local POWER_REBOOT_STAND = Vector3.new(48.15, 11.05, 5.35)
local AMMO_STAND_GROUND = Vector3.new(-8.1, 3.2, 4.5)
local AMMO_STAND_OFFICE = Vector3.new(28.9, 11.05, 23.25)

local Settings = {
    PassengerESP = true,
    OnlyBadESP = false,
    LuggageESP = true,
    EnemyESP = true,
    WaypointESP = false,
    JailESP = false,
    AmmoESP = false,
    ShowFalseAlarms = true,
    HideGameMarks = false,
    ESPDistance = true,
    ESPMaxDistance = 250,
    AutoTaser = false,
    TaserHostileOnly = false,
    AutoArrest = false,
    AutoShoot = false,
    AutoReload = false,
    AutoLuggage = false,
    AutoEquipTools = true,
    AutoMetalDetector = false,
    AutoIDCheck = false,
    AutoJailEscort = true,
    AutoAmmoRefill = false,
    AutoFireExtinguisher = false,
    AutoPowerReboot = false,
    AutoDoEverything = false,
    CombatRetreat = true,
    CombatDodge = true,
    RetreatHealth = 35,
    TaserRange = 15,
    ArrestRange = 10,
    GunRange = 120,
    ActionCooldown = 0.35,
    WalkSpeed = false,
    WalkSpeedValue = 24,
    RunSpeedValue = 32,
    InfiniteSprint = false,
    JumpPower = false,
    JumpPowerValue = 60,
    Noclip = false,
    ThirdPerson = false,
    TweenTeleportDuration = 0.4,
    Fullbright = false,
    CustomFOV = false,
    FOVValue = 70,
    AntiAFK = true,
    WebhookURL = "",
    WebhookAuto = false,
    WebhookInterval = 300,
    WebhookIncludeDay = true,
    WebhookIncludeCash = true,
    WebhookIncludeBoarded = true,
    WebhookIncludeArrested = true,
    WebhookIncludeEscaped = true,
    WebhookIncludeLuggage = true,
    WebhookIncludeObjective = true,
    WebhookIncludePing = true,
    WebhookIncludeUptime = true,
    WebhookIncludeJobId = true,
    LobbyPartySize = 1,
    LobbySelectedClass = "Rookie",
    LobbyAutoEquipBest = false,
    LobbyAutoBuyBest = false,
    LobbyAutoClaimRewards = false,
    LobbyQuickStart = false,
}

local Lobby = {}

local webhookAutoLoopStarted = false

local function syncSettingsFromUI()
    if not Library or not Library.Flags then
        return
    end
    for key in pairs(Settings) do
        local value = Library.Flags[key]
        if value ~= nil and typeof(value) ~= "table" then
            Settings[key] = value
        end
    end
end

local function getWebhookURL()
    local url = Settings.WebhookURL
    if type(url) == "string" and url ~= "" then
        return url
    end
    if Library and Library.Flags then
        url = Library.Flags.WebhookURL
        if type(url) == "string" and url ~= "" then
            Settings.WebhookURL = url
            return url
        end
    end
    return ""
end

local function notify(title, description, duration)
    if Library then
        Library:Notification({
            Title = title,
            Description = description,
            Duration = duration or 3,
            Icon = "97594400820219",
        })
    end
end

local function autoOn(key)
    if Settings.AutoDoEverything then
        if key == "AutoMetalDetector"
            or key == "AutoIDCheck"
            or key == "AutoTaser"
            or key == "AutoArrest"
            or key == "AutoShoot"
            or key == "AutoReload"
            or key == "AutoLuggage"
            or key == "AutoAmmoRefill"
            or key == "AutoFireExtinguisher"
            or key == "AutoPowerReboot"
            or key == "AutoJailEscort" then
            return true
        end
    end
    return Settings[key]
end

local function shouldUseFarmStand()
    return autoOn("AutoMetalDetector") or autoOn("AutoIDCheck")
end

local function useHostileCaptureChain()
    if Settings.AutoDoEverything then
        return true
    end
    return autoOn("AutoTaser") and autoOn("AutoArrest")
end

local function useHostileOnlyTargeting()
    return Settings.AutoDoEverything or Settings.TaserHostileOnly or useHostileCaptureChain()
end

local function useExtendedHostileScan()
    return Settings.AutoDoEverything or useHostileCaptureChain()
end

local function getAutoShootDelay()
    if Settings.AutoDoEverything or autoOn("AutoShoot") then
        return 0.1
    end
    return Settings.ActionCooldown
end

local function shouldAutoEquipTools()
    return autoOn("AutoEquipTools") or autoOn("AutoShoot") or autoOn("AutoTaser") or autoOn("AutoArrest")
end

local function isAutomationRunning()
    return Settings.AutoDoEverything
        or Settings.AutoTaser
        or Settings.AutoArrest
        or Settings.AutoShoot
        or Settings.AutoLuggage
        or Settings.AutoReload
        or Settings.AutoMetalDetector
        or Settings.AutoIDCheck
        or Settings.AutoAmmoRefill
        or Settings.AutoFireExtinguisher
        or Settings.AutoPowerReboot
        or Settings.CombatRetreat
        or Settings.CombatDodge
end

local function isEndlessMode()
    local gui = plr:FindFirstChild("PlayerGui")
    local core = gui and gui:FindFirstChild("CoreUI")
    local frame = core and core:FindFirstChild("DayCounterFrame")
    local label = frame and frame:FindFirstChild("EndlessLabel")
    return label and label:IsA("GuiObject") and label.Visible
end

local function clearPendingDeny()
    for npc in pairs(pendingDeny) do
        pendingDeny[npc] = nil
    end
end

local function clearPendingHostileCapture()
    for npc in pairs(pendingHostileCapture) do
        pendingHostileCapture[npc] = nil
    end
end

local function resetDayAutomationState()
    handledCheckpoint = setmetatable({}, { __mode = "k" })
    clearPendingDeny()
    clearPendingHostileCapture()
    arrestFocusNpc = nil
    farmStandMoving = false
end

local function getCharacter()
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hum and hrp then
        return char, hum, hrp
    end
end

local function getTool(name)
    local char = plr.Character
    if char and char:FindFirstChild(name) then
        return char:FindFirstChild(name)
    end
    return plr.Backpack:FindFirstChild(name)
end

local function findGun()
    local char = plr.Character
    if char then
        for _, t in char:GetChildren() do
            if t:IsA("Tool") and t:FindFirstChild("Gun_Settings") and t:FindFirstChild("Gun_Variables") then
                return t
            end
        end
    end
    for _, t in plr.Backpack:GetChildren() do
        if t:IsA("Tool") and t:FindFirstChild("Gun_Settings") and t:FindFirstChild("Gun_Variables") then
            return t
        end
    end
end

local function equipTool(name)
    local char, hum = getCharacter()
    local tool = getTool(name)
    if not (char and hum and tool) then
        return
    end
    if tool.Parent ~= char then
        hum:EquipTool(tool)
    end
    return tool
end

local function equipGun()
    local char, hum = getCharacter()
    local gun = findGun()
    if not (char and hum and gun) then
        return
    end
    if gun.Parent ~= char then
        hum:EquipTool(gun)
    end
    return gun
end

local function getGunAmmoValue(gun)
    local vars = gun and gun:FindFirstChild("Gun_Variables")
    local ammo = vars and vars:FindFirstChild("Ammo")
    return ammo, ammo and ammo.Value or 0
end

local function getNPCProps(npc)
    if not (npc and npc:IsA("Model") and PASSENGER_NAMES[npc.Name]) then
        return
    end
    local props = npc:FindFirstChild("Properties")
    if not props then
        return
    end
    local rv = props:FindFirstChild("RandomVariables")
    local sv = props:FindFirstChild("StatusVariables")
    if not (rv and sv) then
        return
    end
    return props, rv, sv
end

local function isPassenger(model)
    return getNPCProps(model) ~= nil
end

local function getXrayItemName(npc)
    local xv = npc:FindFirstChild("XrayVisible")
    if not xv then
        return
    end
    for _, item in xv:GetChildren() do
        if item:IsA("Model") then
            return item.Name
        end
    end
end

local function isLuggageContraband(lug)
    if not (lug and lug.Parent) then
        return false
    end

    local flag = lug:FindFirstChild("Contraband")
    if flag and flag:IsA("BoolValue") and flag.Value then
        return true
    end

    for _, child in lug:GetDescendants() do
        if child:IsA("Model") and LuggageBadModelNames[child.Name] then
            return true
        end
        if child:IsA("Model") and RealContrabandNames[child.Name] then
            return true
        end
        if child:IsA("BasePart") and child.Name == "Contraband" and child.Transparency < 1 then
            return true
        end
    end

    return false
end

local function classifyNPC(npc)
    local _, rv, sv = getNPCProps(npc)
    if not rv then
        return
    end

    if sv.InJail and sv.InJail.Value then
        return "JAILED", Color3.fromRGB(110, 110, 110), false
    end
    if sv.Arrested and sv.Arrested.Value then
        return "ARRESTED", Color3.fromRGB(150, 150, 150), false
    end
    if sv.Tasered and sv.Tasered.Value then
        return "TASED", Color3.fromRGB(170, 170, 220), false
    end
    if sv.Hostile and sv.Hostile.Value then
        return "HOSTILE", Color3.fromRGB(255, 55, 55), true
    end
    if rv.FakePassport and rv.FakePassport.Value then
        return "FAKE ID", Color3.fromRGB(255, 60, 130), true
    end
    if rv.ContrabandReal and rv.ContrabandReal.Value then
        local itemName = getXrayItemName(npc)
        if itemName and RealContrabandNames[itemName] then
            return string.upper(itemName), Color3.fromRGB(255, 120, 40), true
        end
        return "CONTRABAND", Color3.fromRGB(255, 120, 40), true
    end
    if rv.ContrabandFake and rv.ContrabandFake.Value then
        local itemName = getXrayItemName(npc)
        if itemName and FalseContrabandNames[itemName] then
            return "DECOY (" .. itemName .. ")", Color3.fromRGB(255, 215, 70), false
        end
        return "DECOY", Color3.fromRGB(255, 215, 70), false
    end
    if sv.MetalDetector and sv.MetalDetector.Value then
        return "METAL+", Color3.fromRGB(255, 175, 45), false
    end

    return "OK", Color3.fromRGB(210, 215, 225), false
end

local function shouldArrestNPC(npc)
    local label, _, bad = classifyNPC(npc)
    return bad, label
end

local function isNpcLockedUp(sv)
    if not sv then
        return true
    end
    if sv.InJail and sv.InJail.Value then
        return true
    end
    if sv.Arrested and sv.Arrested.Value then
        return true
    end
    return false
end

local function shouldCuffPassenger(npc)
    local _, rv, sv = getNPCProps(npc)
    if not rv or not sv or isNpcLockedUp(sv) then
        return false
    end
    if sv.Hostile and sv.Hostile.Value then
        return true
    end
    if rv.FakePassport and rv.FakePassport.Value then
        return true
    end
    if rv.ContrabandReal and rv.ContrabandReal.Value then
        return true
    end
    return false
end

local function shouldTaserNPC(npc)
    local _, _, sv = getNPCProps(npc)
    if not sv or isNpcLockedUp(sv) then
        return false
    end
    if sv.Tasered and sv.Tasered.Value then
        return false
    end
    -- Full auto + checkpoint flow handle METAL+/contraband at podiums; roam taser = hostile only
    if useHostileOnlyTargeting() then
        return sv.Hostile and sv.Hostile.Value
    end
    return shouldArrestNPC(npc)
end

local function getAdornee(model)
    if model:IsA("BasePart") then
        return model
    end
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        return head
    end
    local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
    if torso and torso:IsA("BasePart") then
        return torso
    end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then
        return hrp
    end
    return model:FindFirstChildWhichIsA("BasePart", true)
end

local function getDistance(fromPos, target)
    local adornee = getAdornee(target)
    if not (fromPos and adornee) then
        return math.huge
    end
    return (fromPos - adornee.Position).Magnitude
end

local function clearEntry(entry)
    if not entry then
        return
    end
    if entry.destroyConn then
        pcall(function() entry.destroyConn:Disconnect() end)
        entry.destroyConn = nil
    end
    if entry.gui then
        pcall(function() entry.gui:Destroy() end)
    end
    if entry.highlight then
        pcall(function() entry.highlight:Destroy() end)
    end
end

local function clearCacheEntry(cache, model)
    clearEntry(cache[model])
    cache[model] = nil
end

local function clearCache(cache)
    for model in pairs(cache) do
        clearCacheEntry(cache, model)
    end
end

local function stripGameMarks(model)
    if not Settings.HideGameMarks then
        return
    end
    for _, d in model:GetDescendants() do
        if GAME_MARK_NAMES[d.Name] and d.Name ~= "esp" then
            pcall(function() d:Destroy() end)
        end
    end
end

;(function()
    local function ensureBillboard(model, text, color, cache, useHighlight)
    local adornee = getAdornee(model)
    if not adornee or not model.Parent then
        return
    end

    local entry = cache[model]
    if not entry then
        entry = {}
        cache[model] = entry

        local gui = Instance.new("BillboardGui")
        gui.Name = "esp"
        gui.Adornee = adornee
        gui.AlwaysOnTop = true
        gui.LightInfluence = 0
        gui.MaxDistance = Settings.ESPMaxDistance
        gui.Size = UDim2.fromOffset(210, 44)
        gui.StudsOffset = Vector3.new(0, 2.4, 0)
        gui.Parent = model

        local bg = Instance.new("Frame")
        bg.Name = "BG"
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        bg.BackgroundTransparency = 0.28
        bg.BorderSizePixel = 0
        bg.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = bg

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.5
        stroke.Color = color
        stroke.Transparency = 0.15
        stroke.Parent = bg

        local label = Instance.new("TextLabel")
        label.Name = "Tag"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -8, 1, 0)
        label.Position = UDim2.fromOffset(4, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = color
        label.TextStrokeTransparency = 0.5
        label.Text = text
        label.Parent = gui

        entry.gui = gui
        entry.label = label
        entry.stroke = stroke

        if useHighlight then
            local highlight = Instance.new("Highlight")
            highlight.Name = "esp"
            highlight.Adornee = model:IsA("Model") and model or adornee
            highlight.FillTransparency = 0.58
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = model:IsA("Model") and model or adornee
            entry.highlight = highlight
        end

        entry.destroyConn = model.Destroying:Connect(function()
            clearCacheEntry(cache, model)
        end)
    end

    if useHighlight and not entry.highlight and model.Parent then
        local highlight = Instance.new("Highlight")
        highlight.Name = "esp"
        highlight.Adornee = model:IsA("Model") and model or adornee
        highlight.FillTransparency = 0.58
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model:IsA("Model") and model or adornee
        entry.highlight = highlight
    end

    if entry.label then
        entry.label.Text = text
        entry.label.TextColor3 = color
    end
    if entry.stroke then
        entry.stroke.Color = color
    end
    if entry.highlight then
        entry.highlight.FillColor = color
        entry.highlight.OutlineColor = color
    end
    if entry.gui and entry.gui.Adornee ~= adornee then
        entry.gui.Adornee = adornee
    end
    end

    forEachPassenger = function(callback)
        local wsScriptable = Workspace:FindFirstChild("WorkspaceScriptable")
        local normalStorage = wsScriptable
            and wsScriptable:FindFirstChild("Storage")
            and wsScriptable.Storage:FindFirstChild("NormalStorage")

        if normalStorage then
            for _, folderName in { "NPCWorkspace", "HostileNPCWorkspace" } do
                local folder = normalStorage:FindFirstChild(folderName)
                if folder then
                    for _, child in folder:GetChildren() do
                        if isPassenger(child) then
                            callback(child)
                        end
                    end
                end
            end
        end

        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, inst in map:GetChildren() do
                if isPassenger(inst) then
                    callback(inst)
                end
            end
        end
    end

    local function shouldShowPassenger(label, bad)
    if label and label:sub(1, 5) == "DECOY" and not Settings.ShowFalseAlarms then
        return false
    end
    if Settings.OnlyBadESP then
        if bad then
            return true
        end
        if label and label:sub(1, 5) == "DECOY" and Settings.ShowFalseAlarms then
            return true
        end
        return false
    end
    return true
    end

    local function buildPassengerTag(inst, label, color)
    local _, _, hrp = getCharacter()
    local dist = hrp and getDistance(hrp.Position, inst) or 0
    local tags = { label }

    local _, rv = getNPCProps(inst)
    if rv then
        local linked = rv:FindFirstChild("LinkedLuggage")
        if linked and linked.Value and linked.Value.Parent and isLuggageContraband(linked.Value) then
            table.insert(tags, "BAG BAD")
            color = Color3.fromRGB(255, 95, 35)
        end
    end

    local text = table.concat(tags, " + ")
    if Settings.ESPDistance then
        text = string.format("%s  %.0fm", text, dist)
    end

    return text, color
    end

    updatePassengerESP = function()
    if not Settings.PassengerESP then
        return
    end

    if not getCharacter() then
        return
    end

    local active = {}

    forEachPassenger(function(inst)
        stripGameMarks(inst)

        local label, color, bad = classifyNPC(inst)
        if not label or not shouldShowPassenger(label, bad) then
            clearCacheEntry(passengerESP, inst)
            return
        end

        active[inst] = true
        local text, finalColor = buildPassengerTag(inst, label, color)
        ensureBillboard(inst, text, finalColor, passengerESP, true)
    end)

    for model in pairs(passengerESP) do
        if not active[model] or not model.Parent then
            clearCacheEntry(passengerESP, model)
        end
    end
end

    updateLuggageESP = function()
    if not Settings.LuggageESP then
        return
    end

    local _, _, hrp = getCharacter()
    if not hrp then
        return
    end

    local active = {}
    local luggageRoots = {}
    local ws = Workspace:FindFirstChild("WorkspaceScriptable")
    local normalStorage = ws
        and ws:FindFirstChild("Storage")
        and ws.Storage:FindFirstChild("NormalStorage")
    if normalStorage then
        table.insert(luggageRoots, normalStorage:FindFirstChild("LuggageOpenWorkspace"))
        table.insert(luggageRoots, normalStorage:FindFirstChild("LuggageWorkspace"))
    end

    for _, folder in luggageRoots do
        if folder then
            for _, inst in folder:GetChildren() do
                if inst.Name == "OpenableLuggage" then
                    active[inst] = true
                    local contraband = isLuggageContraband(inst)
                    local color = contraband and Color3.fromRGB(255, 110, 45) or Color3.fromRGB(150, 210, 255)
                    local label = contraband and "BAD BAG" or "SAFE BAG"
                    local dist = getDistance(hrp.Position, inst)
                    local text = Settings.ESPDistance and string.format("%s  %.0fm", label, dist) or label
                    ensureBillboard(inst, text, color, luggageESP, true)
                end
            end
        end
    end

    for model in pairs(luggageESP) do
        if not active[model] or not model.Parent then
            clearCacheEntry(luggageESP, model)
        end
    end
end

    updateEnemyESP = function()
    if not Settings.EnemyESP then
        return
    end

    local _, _, hrp = getCharacter()
    if not hrp then
        return
    end

    local active = {}
    local enemies = collectLiveEnemies and collectLiveEnemies() or {}

    for _, inst in enemies do
        active[inst] = true
        local color = Color3.fromRGB(255, 45, 120)
        local text = inst.Name
        if Settings.ESPDistance then
            text = string.format("%s  %.0fm", inst.Name, getDistance(hrp.Position, inst))
        end
        ensureBillboard(inst, text, color, enemyESP, true)
    end

    for model in pairs(enemyESP) do
        if not active[model] or not model.Parent then
            clearCacheEntry(enemyESP, model)
        end
    end
end

    updateWorldESP = function()
    local wsScriptable = Workspace:FindFirstChild("WorkspaceScriptable")
    if not wsScriptable then
        return
    end

    local active = {}

    if Settings.WaypointESP then
        local wpFolder = wsScriptable:FindFirstChild("Waypoints")
        if wpFolder then
            for _, wp in wpFolder:GetChildren() do
                if wp.Parent then
                    active[wp] = true
                    ensureBillboard(wp, wp.Name, Color3.fromRGB(90, 180, 255), worldESP, false)
                end
            end
        end
    end

    if Settings.JailESP then
        local jail = wsScriptable:FindFirstChild("JailStructure")
        if jail and jail.Parent then
            active[jail] = true
            ensureBillboard(jail, "JAIL", Color3.fromRGB(180, 120, 255), worldESP, true)
        end
    end

    if Settings.AmmoESP then
        local ammo = wsScriptable:FindFirstChild("AmmoRefill")
        if ammo and ammo.Parent then
            active[ammo] = true
            ensureBillboard(ammo, "AMMO", Color3.fromRGB(120, 255, 160), worldESP, true)
        end
    end

    for model in pairs(worldESP) do
        if not active[model] or not model.Parent then
            clearCacheEntry(worldESP, model)
        end
    end
    end
end)()

local function getNearestPassenger(predicate, maxRange)
    local _, _, hrp = getCharacter()
    if not hrp then
        return
    end

    local best, bestDist, bestLabel
    forEachPassenger(function(inst)
        local ok, label = predicate(inst)
        if ok then
            local dist = getDistance(hrp.Position, inst)
            if dist <= maxRange and (not bestDist or dist < bestDist) then
                best = inst
                bestDist = dist
                bestLabel = label
            end
        end
    end)

    return best, bestDist, bestLabel
end

;(function()
    getShootOrigin = function()
        local camera = Workspace.CurrentCamera
        if camera then
            return camera.CFrame.Position
        end
        local _, _, hrp = getCharacter()
        return hrp and hrp.Position
    end

    isTargetVisible = function(target, origin)
        local targetPart = target:FindFirstChild("HumanoidRootPart") or getAdornee(target)
        if not (targetPart and targetPart:IsA("BasePart")) then
            return false
        end

        origin = origin or getShootOrigin()
        if not origin then
            return false
        end

        local goal = targetPart.Position + Vector3.new(0, 0.5, 0)
        local offset = goal - origin
        local dist = offset.Magnitude
        if dist < 0.25 then
            return true
        end

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local filter = { target }
        local char = plr.Character
        if char then
            table.insert(filter, char)
        end
        params.FilterDescendantsInstances = filter
        params.IgnoreWater = true

        local result = Workspace:Raycast(origin, offset, params)
        if not result then
            return true
        end
        if result.Instance:IsDescendantOf(target) then
            return true
        end
        return (result.Position - goal).Magnitude <= 2.5
    end

    local function isStoredEnemyModel(inst)
    local ws = Workspace:FindFirstChild("WorkspaceScriptable")
    if not ws or not inst:IsDescendantOf(ws) then
        return false
    end

    local hum = inst:FindFirstChildOfClass("Humanoid")
    local body = inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChild("Head")
    local isLive = hum and hum.Health > 0 and hum.MaxHealth < math.huge and body ~= nil

    local storage = ws:FindFirstChild("Storage")
    if storage and inst:IsDescendantOf(storage) then
        local disasterStorage = storage:FindFirstChild("DisasterStorage")
        if disasterStorage and inst:IsDescendantOf(disasterStorage) then
            return not isLive
        end
        return true
    end

    local endingStorage = ws:FindFirstChild("EndingStorage")
    if endingStorage and inst:IsDescendantOf(endingStorage) then
        return true
    end

    local disasterStorage = ws:FindFirstChild("DisasterStorage")
    if disasterStorage and inst:IsDescendantOf(disasterStorage) then
        return not isLive
    end

    return false
end

    local enemyScanCache = { at = 0, models = {} }

    collectLiveEnemies = function()
        local now = tick()
        if now - enemyScanCache.at < 0.2 and enemyScanCache.models then
            local live = {}
            for _, inst in enemyScanCache.models do
                if inst and inst.Parent then
                    local hum = inst:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        table.insert(live, inst)
                    end
                end
            end
            if #live == #enemyScanCache.models then
                return enemyScanCache.models
            end
            enemyScanCache.models = live
            return live
        end

        local models = {}
        for _, inst in Workspace:GetDescendants() do
            if inst:IsA("Model") and ENEMY_NAMES[inst.Name] and not isStoredEnemyModel(inst) then
                local hum = inst:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    table.insert(models, inst)
                end
            end
        end
        enemyScanCache.at = now
        enemyScanCache.models = models
        return models
    end

    getEnemiesInRange = function(maxRange, visibleOnly)
        local _, _, hrp = getCharacter()
        if not hrp then
            return {}
        end

        local origin = getShootOrigin()
        local enemies = {}
        for _, inst in collectLiveEnemies() do
            local dist = getDistance(hrp.Position, inst)
            if dist <= maxRange and (not visibleOnly or isTargetVisible(inst, origin)) then
                table.insert(enemies, { model = inst, dist = dist })
            end
        end

        table.sort(enemies, function(a, b)
            return a.dist < b.dist
        end)

        local models = {}
        for _, entry in ipairs(enemies) do
            table.insert(models, entry.model)
        end
        return models
    end
end)()

local function getNearestEnemy(maxRange)
    local enemies = getEnemiesInRange(maxRange)
    if not enemies[1] then
        return
    end
    local _, _, hrp = getCharacter()
    return enemies[1], hrp and getDistance(hrp.Position, enemies[1])
end

local function hasLiveDisasterEnemies(extraRange)
    if not autoOn("AutoShoot") then
        return false
    end
    return #getEnemiesInRange(Settings.GunRange + (extraRange or 40), false) > 0
end

local function getTweenDuration(override)
    if type(override) == "number" and override > 0 then
        return math.max(0.05, override)
    end
    return math.max(0.05, Settings.TweenTeleportDuration or 0.4)
end

local function hasBlockingThreats()
    for npc in pairs(pendingDeny) do
        if npc and npc.Parent then
            return true
        end
    end

    if useHostileCaptureChain() then
        local _, _, hrp = getCharacter()
        if hrp then
            local engageRange = math.max(Settings.TaserRange, Settings.ArrestRange) + 5
            for npc in pairs(pendingHostileCapture) do
                if npc and npc.Parent then
                    local _, _, sv = getNPCProps(npc)
                    if sv and not (sv.InJail and sv.InJail.Value) then
                        if sv.Arrested and sv.Arrested.Value then
                            -- escort uses checkpointBusy; don't block farming here
                        elseif getDistance(hrp.Position, npc) <= engageRange then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

local function moveNearTarget(target, standOffset, duration)
    local _, _, hrp = getCharacter()
    local targetPart = target:FindFirstChild("HumanoidRootPart") or getAdornee(target)
    if not (hrp and targetPart) then
        return false
    end

    local offset = standOffset or 3.5
    local flat = hrp.Position - targetPart.Position
    flat = Vector3.new(flat.X, 0, flat.Z)
    if flat.Magnitude < 0.1 then
        flat = Vector3.new(0, 0, 1)
    end
    local standPos = targetPart.Position + flat.Unit * offset
    standPos = Vector3.new(standPos.X, hrp.Position.Y, standPos.Z)
    return tweenHRPTo(standPos, duration)
end

local function fireTaserAt(target)
    if not ClientEvents then
        return
    end
    local tool = equipTool("Taser")
    if not tool then
        return
    end

    local camera = Workspace.CurrentCamera
    local targetPart = target:FindFirstChild("HumanoidRootPart") or getAdornee(target)
    if not (camera and targetPart) then
        return
    end

    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit
    ClientEvents.FireTaser:FireServer(tool, origin, direction)
end

local function fireArrestAt(target)
    if not ClientEvents then
        return
    end
    if shouldAutoEquipTools() then
        equipTool("Arrest")
    end
    ClientEvents.NPCArrest:FireServer(target)
end

local function fireGunAt(target)
    if not ClientEvents then
        return
    end

    local gun = shouldAutoEquipTools() and equipGun() or findGun()
    if not gun then
        return
    end

    local camera = Workspace.CurrentCamera
    local targetPart = target:FindFirstChild("HumanoidRootPart") or getAdornee(target)
    if not (camera and targetPart) then
        return
    end

    local origin = camera.CFrame.Position
    if not isTargetVisible(target, origin) then
        return
    end

    local direction = (targetPart.Position - origin).Unit
    ClientEvents.FireGun:FireServer(gun, origin, direction)
end

local function fireGunAtSafe(target)
    if not ClientEvents then
        return false
    end

    local gun = shouldAutoEquipTools() and equipGun() or findGun()
    if not gun then
        return false
    end

    local targetPart = target:FindFirstChild("HumanoidRootPart") or getAdornee(target)
    if not (targetPart and targetPart:IsA("BasePart")) then
        return false
    end

    local origin = targetPart.Position + Vector3.new(0, 3, 0)
    local offset = targetPart.Position - origin
    local direction = offset.Magnitude > 0.05 and offset.Unit or Vector3.new(0, -1, 0)
    ClientEvents.FireGun:FireServer(gun, origin, direction)
    return true
end

;(function()
    local function tryAutoReload()
    if not autoOn("AutoReload") or not ClientEvents then
        return
    end
    local gun = findGun()
    if not gun or not gun:FindFirstChild("Gun_Variables") then
        return
    end
    local ammo = gun.Gun_Variables:FindFirstChild("Ammo")
    if ammo and ammo.Value <= 0 and tick() - lastReload >= 1.5 then
        ClientEvents.ReloadGun:FireServer(gun)
        lastReload = tick()
    end
end

local function shouldDenyPassenger(npc)
    local bad = shouldArrestNPC(npc)
    if bad then
        return true
    end

    local _, rv = getNPCProps(npc)
    if rv then
        local linked = rv:FindFirstChild("LinkedLuggage")
        if linked and linked.Value and linked.Value.Parent and isLuggageContraband(linked.Value) then
            return true
        end
    end

    return false
end

local function shouldDenyAtMD(npc)
    local _, rv, sv = getNPCProps(npc)
    if not rv then
        return false
    end

    if rv.FakePassport and rv.FakePassport.Value then
        return false
    end

    if sv.Hostile and sv.Hostile.Value then
        return true
    end
    if rv.ContrabandReal and rv.ContrabandReal.Value then
        return true
    end
    if sv.MetalDetector and sv.MetalDetector.Value then
        return true
    end

    local linked = rv:FindFirstChild("LinkedLuggage")
    if linked and linked.Value and linked.Value.Parent and isLuggageContraband(linked.Value) then
        return true
    end

    return false
end

local function shouldDenyAtID(npc)
    return shouldDenyPassenger(npc)
end

local function needsTaserBeforeArrest(npc)
    local _, _, sv = getNPCProps(npc)
    if not sv then
        return false
    end
    return sv.Hostile and sv.Hostile.Value and not (sv.Tasered and sv.Tasered.Value)
end

local function getWorkspaceScriptable()
    return Workspace:FindFirstChild("WorkspaceScriptable")
end

local function fireProximityPrompt(prompt)
    if not (prompt and prompt:IsA("ProximityPrompt") and prompt.Parent) then
        return false
    end

    local hold = prompt.HoldDuration
    local dist = prompt.MaxActivationDistance
    if hold ~= 0 then
        prompt.HoldDuration = 0
    end
    if dist < 50 then
        prompt.MaxActivationDistance = 50
    end

    local ok = pcall(function()
        if typeof(fireproximityprompt) == "function" then
            fireproximityprompt(prompt, 1, true)
        else
            prompt:InputHoldBegin()
            task.wait()
            if prompt.Parent then
                prompt:InputHoldEnd()
            end
        end
    end)

    if hold ~= 0 and prompt.Parent then
        prompt.HoldDuration = hold
    end
    if dist < 50 and prompt.Parent then
        prompt.MaxActivationDistance = dist
    end

    return ok
end

local function getPodiumPrompt(podiumName, accept)
    local ws = getWorkspaceScriptable()
    local podiums = ws and ws:FindFirstChild("Objects") and ws.Objects:FindFirstChild("ButtonPodiums")
    local podium = podiums and podiums:FindFirstChild(podiumName)
    local side = accept and "ButtonAccept" or "ButtonArrest"
    local button = podium and podium:FindFirstChild(side)
    local press = button and button:FindFirstChild("ButtonPress")
    return press and press:FindFirstChild("ProximityPrompt")
end

local function getPodiumPosition(podiumName)
    local prompt = getPodiumPrompt(podiumName, true)
    local part = prompt and prompt.Parent
    if part and part:IsA("BasePart") then
        return part.Position
    end
end

local function getStandCFrame(target, offset)
    offset = offset or 2.5
    if not target then
        return
    end

    if target:IsA("ProximityPrompt") then
        target = target.Parent
    end

    if target:IsA("BasePart") then
        return target.CFrame * CFrame.new(0, 0, offset)
    end

    if target:IsA("Attachment") then
        return target.WorldCFrame * CFrame.new(0, 0, offset)
    end

    local part = target:FindFirstAncestorWhichIsA("BasePart")
    if part then
        return part.CFrame * CFrame.new(0, 0, offset)
    end
end

    local function tweenHRPToCFrame(targetCFrame, duration)
        local _, _, hrp = getCharacter()
        if not hrp then
            return false
        end

        duration = getTweenDuration(duration)
        local startCFrame = hrp.CFrame
        local started = tick()

        while tick() - started < duration do
            local _, _, liveHrp = getCharacter()
            if not liveHrp then
                return false
            end
            hrp = liveHrp

            local alpha = math.clamp((tick() - started) / duration, 0, 1)
            alpha = 1 - (1 - alpha) * (1 - alpha)
            hrp.CFrame = startCFrame:Lerp(targetCFrame, alpha)
            RunService.Heartbeat:Wait()
        end

        local _, _, liveHrp = getCharacter()
        if liveHrp then
            liveHrp.CFrame = targetCFrame
        end
        return liveHrp ~= nil
    end

    tweenHRPTo = function(targetPos, duration)
        return tweenHRPToCFrame(CFrame.new(targetPos), duration)
    end

    local function tweenToTarget(target, offset)
    local cf = getStandCFrame(target, offset)
    if not cf then
        return false
    end
    return tweenHRPToCFrame(cf)
end

local function standAtPart(part, offset)
    return tweenToTarget(part, offset)
end

local function getPassengerCurrentPoint(npc)
    local props = getNPCProps(npc)
    if not props then
        return
    end
    local cp = props:FindFirstChild("CurrentPoint")
    return cp and cp.Value
end

local function canHandleCheckpoint(npc, stage)
    if pendingDeny[npc] then
        return false
    end

    local entry = handledCheckpoint[npc]
    if not entry or not entry[stage] then
        return true
    end
    return tick() - entry[stage] > 2
end

local function markCheckpointHandled(npc, stage)
    handledCheckpoint[npc] = handledCheckpoint[npc] or {}
    handledCheckpoint[npc][stage] = tick()
end

local function getPassengerNearPodium(podiumName, maxDist, minPoint, maxPoint)
    local podiumPos = getPodiumPosition(podiumName)
    if not podiumPos then
        return
    end

    local best, bestDist, bestPoint
    forEachPassenger(function(npc)
        local _, _, sv = getNPCProps(npc)
        if not sv then
            return
        end
        if sv.Arrested and sv.Arrested.Value then
            return
        end
        if sv.InJail and sv.InJail.Value then
            return
        end

        local point = getPassengerCurrentPoint(npc)
        if not point or point < minPoint or point > maxPoint then
            return
        end

        local dist = getDistance(podiumPos, npc)
        if dist <= maxDist and (not bestDist or dist < bestDist) then
            best = npc
            bestDist = dist
            bestPoint = point
        end
    end)

    return best, bestDist, bestPoint
end

local function escortToJailAndReturn(savedCFrame)
    if not autoOn("AutoJailEscort") then
        return
    end

    checkpointBusy = true
    moveBusy = true
    moveBusyStartedAt = tick()
    task.spawn(function()
        pcall(function()
            tweenHRPTo(JAIL_STAND_POS)
            task.wait(1.2)
            if savedCFrame then
                tweenHRPToCFrame(savedCFrame)
            end
        end)
        moveBusy = false
        moveBusyStartedAt = 0
        checkpointBusy = false
    end)
end

local ARREST_STAND_OFFSET = 2

local function getArrestEngageRange()
    return math.max(3, (Settings.ArrestRange or 10) - 1)
end

local function isArrestTargetValid(npc)
    if not (npc and npc.Parent) then
        return false
    end
    if not pendingDeny[npc] and not pendingHostileCapture[npc] then
        return false
    end
    local _, _, sv = getNPCProps(npc)
    if sv and sv.InJail and sv.InJail.Value then
        return false
    end
    return true
end

local function clearArrestFocus(npc)
    if not npc or arrestFocusNpc == npc then
        arrestFocusNpc = nil
    end
end

local function getArrestFocus()
    if isArrestTargetValid(arrestFocusNpc) then
        return arrestFocusNpc
    end
    arrestFocusNpc = nil

    local _, _, hrp = getCharacter()
    if not hrp then
        return
    end

    local best, bestDist
    local function consider(npc)
        if not isArrestTargetValid(npc) then
            return
        end
        local dist = getDistance(hrp.Position, npc)
        if not bestDist or dist < bestDist then
            best = npc
            bestDist = dist
        end
    end

    for npc in pairs(pendingDeny) do
        consider(npc)
    end
    for npc in pairs(pendingHostileCapture) do
        consider(npc)
    end

    arrestFocusNpc = best
    return arrestFocusNpc
end

local function freezeNpcForArrest(npc)
    local humanoid = npc and npc:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
    end
end

local function moveNearForArrest(npc, data)
    local _, _, hrp = getCharacter()
    if not (hrp and npc and data) then
        return false
    end

    freezeNpcForArrest(npc)

    if getDistance(hrp.Position, npc) <= getArrestEngageRange() then
        return true
    end

    if data.moving and not moveBusy and tick() - (data.moveStarted or data.at) > 8 then
        data.moving = false
    end

    if not data.moving and not moveBusy then
        data.moving = true
        data.moveStarted = tick()
        task.spawn(function()
            pcall(function()
                moveBusy = true
                moveBusyStartedAt = tick()
                moveNearTarget(npc, ARREST_STAND_OFFSET)
            end)
            moveBusy = false
            moveBusyStartedAt = 0
            data.moving = false
        end)
    end

    return false
end

local function processPendingDeny()
    if not autoOn("AutoArrest") then
        return
    end
    if autoOn("AutoShoot") and hasLiveDisasterEnemies(45) then
        return
    end

    for npc, data in pairs(pendingDeny) do
        if not (npc and npc.Parent) then
            pendingDeny[npc] = nil
            clearArrestFocus(npc)
        elseif tick() - data.at > 25 then
            pendingDeny[npc] = nil
            clearArrestFocus(npc)
        end
    end

    local npc = getArrestFocus()
    if not npc or not pendingDeny[npc] then
        return
    end

    local data = pendingDeny[npc]
    local _, _, sv = getNPCProps(npc)
    if not moveNearForArrest(npc, data) then
        return
    end
    if needsTaserBeforeArrest(npc) then
        if tick() - (data.lastTaser or 0) >= 0.35 then
            fireTaserAt(npc)
            data.lastTaser = tick()
        end
        return
    end
    if tick() - data.at >= 0.15 and tick() - (data.lastArrest or 0) >= 0.35 then
        fireArrestAt(npc)
        data.lastArrest = tick()
        data.cuffAttempts = (data.cuffAttempts or 0) + 1
    end
    if sv and sv.Arrested and sv.Arrested.Value and (data.cuffAttempts or 0) >= 1 then
        escortToJailAndReturn(data.savedCFrame)
        markCheckpointHandled(npc, data.stage)
        pendingDeny[npc] = nil
        clearArrestFocus(npc)
    end
end

local function registerHostileForCapture(npc)
    if pendingHostileCapture[npc] or pendingDeny[npc] then
        return
    end

    local _, _, sv = getNPCProps(npc)
    if not sv or not (sv.Hostile and sv.Hostile.Value) or isNpcLockedUp(sv) then
        return
    end

    local _, _, hrp = getCharacter()
    pendingHostileCapture[npc] = {
        at = tick(),
        savedCFrame = hrp and hrp.CFrame,
    }
end

local function processHostileCapture()
    if autoOn("AutoShoot") and hasLiveDisasterEnemies(45) then
        return
    end

    local _, _, hrp = getCharacter()
    if not hrp then
        return
    end

    for npc, data in pairs(pendingHostileCapture) do
        if not (npc and npc.Parent) then
            pendingHostileCapture[npc] = nil
            clearArrestFocus(npc)
        elseif tick() - data.at > 30 then
            pendingHostileCapture[npc] = nil
            clearArrestFocus(npc)
        else
            local _, _, sv = getNPCProps(npc)
            if not sv or not (sv.Hostile and sv.Hostile.Value) then
                pendingHostileCapture[npc] = nil
                clearArrestFocus(npc)
            elseif sv.InJail and sv.InJail.Value then
                pendingHostileCapture[npc] = nil
                clearArrestFocus(npc)
            end
        end
    end

    local nearestNpc = getArrestFocus()
    if not nearestNpc or not pendingHostileCapture[nearestNpc] or pendingDeny[nearestNpc] then
        return
    end

    local data = pendingHostileCapture[nearestNpc]
    local _, _, sv = getNPCProps(nearestNpc)
    if not sv or (sv.InJail and sv.InJail.Value) then
        return
    end

    if not moveNearForArrest(nearestNpc, data) then
        return
    end

    if needsTaserBeforeArrest(nearestNpc) then
        if tick() - (data.lastTaser or 0) >= 0.25 then
            fireTaserAt(nearestNpc)
            data.lastTaser = tick()
        end
        return
    end

    if tick() - (data.lastArrest or 0) >= 0.3 then
        fireArrestAt(nearestNpc)
        data.lastArrest = tick()
        data.cuffAttempts = (data.cuffAttempts or 0) + 1
    end

    if sv.Arrested and sv.Arrested.Value and (data.cuffAttempts or 0) >= 1 then
        if not data.escorted and autoOn("AutoJailEscort") then
            escortToJailAndReturn(data.savedCFrame)
            data.escorted = true
        end
    end
end

local function scanHostilesForCapture()
    if not useHostileCaptureChain() then
        return
    end

    if autoOn("AutoShoot") and hasLiveDisasterEnemies(45) then
        return
    end

    local _, _, hrp = getCharacter()
    if not hrp then
        return
    end

    local scanRange = useExtendedHostileScan() and HOSTILE_SCAN_RANGE or (math.max(Settings.TaserRange, Settings.ArrestRange) + 5)
    forEachPassenger(function(npc)
        local _, _, sv = getNPCProps(npc)
        if sv and sv.Hostile and sv.Hostile.Value and not isNpcLockedUp(sv) then
            if useExtendedHostileScan() or getDistance(hrp.Position, npc) <= scanRange then
                registerHostileForCapture(npc)
            end
        end
    end)
end

local function processFarmDisasterCombat(now)
    if not autoOn("AutoShoot") then
        return
    end

    local enemies = getEnemiesInRange(Settings.GunRange + 80, false)
    if #enemies == 0 then
        return
    end

    if autoOn("AutoReload") then
        tryAutoReload()
    end

    local gun = findGun()
    local _, ammoValue = getGunAmmoValue(gun)
    if gun and ammoValue <= 0 then
        tryAmmoRefill(now)
        return
    end

    if now - lastGun < getAutoShootDelay() then
        return
    end

    if fireGunAtSafe(enemies[1]) then
        lastGun = now
    end
end

local function processLuggageWorkspace()
    local ws = getWorkspaceScriptable()
    local folder = ws
        and ws:FindFirstChild("Storage")
        and ws.Storage:FindFirstChild("NormalStorage")
        and ws.Storage.NormalStorage:FindFirstChild("LuggageOpenWorkspace")
    if not folder then
        return
    end

    for _, inst in folder:GetChildren() do
        if inst.Name == "OpenableLuggage" and inst:FindFirstChild("Properties") then
            local props = inst.Properties
            local decisionMade = props:FindFirstChild("DecisionMade")
            local decision = props:FindFirstChild("Decision")
            if decisionMade and decision and not decisionMade.Value and decision:IsA("RemoteEvent") then
                local contraband = isLuggageContraband(inst)
                decision:FireServer(not contraband)
            end
        end
    end
end

local cachedBoss = { at = 0, model = false }

local function getActiveBoss()
    local now = tick()
    if now - cachedBoss.at < 0.35 then
        local inst = cachedBoss.model
        if inst then
            local hum = inst.Parent and inst:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum.MaxHealth < math.huge then
                return inst
            end
            cachedBoss.model = nil
        else
            return nil
        end
    end

    cachedBoss.at = now
    cachedBoss.model = nil
    for _, inst in Workspace:GetDescendants() do
        if inst.Name == "BossNPC" and inst:IsA("Model") then
            local hum = inst:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum.MaxHealth < math.huge then
                cachedBoss.model = inst
                return inst
            end
        end
    end
end

local function getPromptWorldPosition(prompt)
    if not (prompt and prompt.Parent) then
        return
    end
    local parent = prompt.Parent
    if parent:IsA("Attachment") then
        return parent.WorldPosition
    end
    if parent:IsA("BasePart") then
        return parent.Position
    end
    local part = prompt:FindFirstAncestorWhichIsA("BasePart")
    return part and part.Position
end

local function getStandNearPrompt(prompt, dist)
    dist = dist or 3
    local pos = getPromptWorldPosition(prompt)
    if not pos then
        return
    end

    local part = prompt:FindFirstAncestorWhichIsA("BasePart")
    local standY = pos.Y
    if part then
        standY = part.Position.Y
        if part.Size.Y > 4 then
            standY = part.Position.Y - part.Size.Y * 0.5 + 3
        end
    end

    local model = prompt:FindFirstAncestorOfClass("Model")
    if model and model.Name == "ComputerPower" then
        return POWER_REBOOT_STAND
    end

    local _, _, hrp = getCharacter()
    local away = Vector3.new(0, 0, 1)
    if hrp then
        local flat = Vector3.new(hrp.Position.X - pos.X, 0, hrp.Position.Z - pos.Z)
        if flat.Magnitude > 0.2 then
            away = flat.Unit
        end
    end

    return Vector3.new(pos.X, standY, pos.Z) + away * dist
end

local function findClosestAmmoPrompt()
    local _, _, hrp = getCharacter()
    local origin = hrp and hrp.Position
    local best, bestDist
    local ws = getWorkspaceScriptable()
    if not ws then
        return
    end

    for _, refill in ws:GetChildren() do
        if refill.Name ~= "AmmoRefill" then
            continue
        end
        for _, inst in refill:GetDescendants() do
            if inst:IsA("ProximityPrompt") then
                local pos = getPromptWorldPosition(inst)
                if not pos then
                    continue
                end
                local dist = origin and (origin - pos).Magnitude or 0
                if not bestDist or dist < bestDist then
                    best = inst
                    bestDist = dist
                end
            end
        end
    end

    return best
end

local function getAmmoStandPosition(prompt)
    local pos = getPromptWorldPosition(prompt)
    if not pos then
        return AMMO_STAND_GROUND
    end
    if pos.Y > 7 then
        return AMMO_STAND_OFFICE
    end
    return AMMO_STAND_GROUND
end

tryAmmoRefill = function(now)
    if not autoOn("AutoAmmoRefill") or ammoRefillBusy or powerRebootBusy or moveBusy then
        return
    end
    if now - lastAmmoRefill < 1.2 then
        return
    end

    local gun = shouldAutoEquipTools() and equipGun() or findGun()
    local ammo, ammoValue = getGunAmmoValue(gun)
    if not gun or not ammo or ammoValue > 0 then
        return
    end

    local prompt = findClosestAmmoPrompt()
    local _, _, hrp = getCharacter()
    local savedCFrame = hrp and hrp.CFrame
    ammoRefillBusy = true
    moveBusy = true
    moveBusyStartedAt = tick()
    task.spawn(function()
        pcall(function()
            equipGun()

            if autoOn("AutoReload") then
                tryAutoReload()
                task.wait(0.4)
                local _, liveAmmo = getGunAmmoValue(findGun())
                if liveAmmo > 0 then
                    lastAmmoRefill = tick()
                    local enemies = getEnemiesInRange(Settings.GunRange + 80, false)
                    for _ = 1, 12 do
                        if #enemies == 0 then
                            break
                        end
                        if autoOn("AutoReload") then
                            tryAutoReload()
                        end
                        fireGunAtSafe(enemies[1])
                        task.wait(getAutoShootDelay())
                        enemies = getEnemiesInRange(Settings.GunRange + 80, false)
                    end
                    return
                end
            end

            if not prompt then
                prompt = findClosestAmmoPrompt()
            end
            if not prompt then
                return
            end

            local standPos = getAmmoStandPosition(prompt)
            tweenHRPTo(standPos, 0.15)
            task.wait(0.2)

            local steps = 0
            while prompt.Parent and steps < 20 do
                local _, _, liveHrp = getCharacter()
                if liveHrp then
                    local flat = Vector3.new(liveHrp.Position.X - standPos.X, 0, liveHrp.Position.Z - standPos.Z)
                    if flat.Magnitude > 8 then
                        tweenHRPTo(standPos, 0.12)
                    end
                end
                local _, liveAmmo = getGunAmmoValue(findGun())
                if liveAmmo > 0 then
                    break
                end
                fireProximityPrompt(prompt)
                task.wait(0.25)
                steps += 1
            end

            lastAmmoRefill = tick()

            local enemies = getEnemiesInRange(Settings.GunRange + 80, false)
            if #enemies > 0 then
                for _ = 1, 12 do
                    enemies = getEnemiesInRange(Settings.GunRange + 80, false)
                    if #enemies == 0 then
                        break
                    end
                    if autoOn("AutoReload") then
                        tryAutoReload()
                    end
                    fireGunAtSafe(enemies[1])
                    task.wait(getAutoShootDelay())
                end
            elseif savedCFrame and not getActiveBoss() then
                tweenHRPToCFrame(savedCFrame, 0.15)
            end
        end)
        moveBusy = false
        moveBusyStartedAt = 0
        ammoRefillBusy = false
    end)
end

local function isFirePartActive(part)
    if not (part and part:IsA("BasePart")) then
        return false
    end
    if part.Transparency < 1 then
        return true
    end
    for _, d in part:GetDescendants() do
        if (d:IsA("ParticleEmitter") or d:IsA("Fire") or d:IsA("Smoke")) and d.Enabled then
            return true
        end
    end
    return false
end

local function getActiveFires()
    local fires = {}
    local ws = getWorkspaceScriptable()
    if not ws then
        return fires
    end

    local function addPart(part)
        if isFirePartActive(part) then
            table.insert(fires, part)
        end
    end

    local bins = ws:FindFirstChild("Objects") and ws.Objects:FindFirstChild("GarbageBins")
    if bins then
        for _, bin in bins:GetChildren() do
            addPart(bin:FindFirstChild("FirePart"))
        end
    end

    local firestarter = ws:FindFirstChild("Waypoints") and ws.Waypoints:FindFirstChild("Firestarter")
    if firestarter then
        for _, child in firestarter:GetChildren() do
            if child:IsA("BasePart") then
                addPart(child)
            end
        end
    end

    return fires
end

local function findEnabledExtinguisherPrompt()
    local ws = getWorkspaceScriptable()
    local points = ws and ws:FindFirstChild("Objects") and ws.Objects:FindFirstChild("FireExtinguisherPoints")
    if not points then
        return
    end

    local bestPrompt, bestDist
    local _, _, hrp = getCharacter()
    if not hrp then
        return
    end

    for _, model in points:GetChildren() do
        if model.Name == "FireExtinguisher" then
            local part = model:FindFirstChild("InteractPart")
            local prompt = part and part:FindFirstChild("ProximityPrompt")
            if prompt and prompt.Enabled and part then
                local dist = (part.Position - hrp.Position).Magnitude
                if not bestDist or dist < bestDist then
                    bestPrompt = prompt
                    bestDist = dist
                end
            end
        end
    end

    return bestPrompt
end

local function setExtinguisherSpray(active)
    local tool = equipTool("Fire Extinguisher")
    if not tool or not ClientEvents then
        return false
    end

    ClientEvents.FireExtinguisher:FireServer(tool, active)
    local toggle = tool:FindFirstChild("Toggle")
    if toggle and toggle:IsA("RemoteEvent") then
        toggle:FireServer(active)
    end
    return true
end

local function getNearestFromList(origin, items)
    local best, bestDist
    for _, item in ipairs(items) do
        local pos = item:IsA("BasePart") and item.Position or (getAdornee(item) and getAdornee(item).Position)
        if pos then
            local dist = (origin - pos).Magnitude
            if not bestDist or dist < bestDist then
                best = item
                bestDist = dist
            end
        end
    end
    return best, bestDist
end

local function getComputerPower()
    local ws = getWorkspaceScriptable()
    local computers = ws and ws:FindFirstChild("Objects") and ws.Objects:FindFirstChild("Computers")
    return computers and computers:FindFirstChild("ComputerPower")
end

local function isComputerPowerOffline()
    local computerPower = getComputerPower()
    local highlight = computerPower and computerPower:FindFirstChild("Highlight")
    if highlight then
        return highlight.Enabled == true
    end
    return powerOffline == true
end

local function findRebootPrompt()
    local computerPower = getComputerPower()
    if not computerPower then
        return
    end

    local fallback
    for _, inst in computerPower:GetDescendants() do
        if inst:IsA("ProximityPrompt") and inst.Parent then
            local action = string.lower(inst.ActionText or "")
            local object = string.lower(inst.ObjectText or "")
            if action:find("reboot", 1, true)
                or object:find("reboot", 1, true)
                or action:find("restore power", 1, true)
                or object:find("restore power", 1, true) then
                if inst.Enabled then
                    return inst
                end
                fallback = inst
            end
        end
    end
    return fallback
end

local function stayAtPowerStand()
    local _, _, hrp = getCharacter()
    if not hrp then
        return
    end
    local flat = Vector3.new(hrp.Position.X - POWER_REBOOT_STAND.X, 0, hrp.Position.Z - POWER_REBOOT_STAND.Z)
    if flat.Magnitude > 6 then
        tweenHRPTo(POWER_REBOOT_STAND, 0.12)
    end
end

local function executePowerReboot(afterSuccess)
    local _, _, hrp = getCharacter()
    local savedCFrame = hrp and hrp.CFrame

    tweenHRPTo(POWER_REBOOT_STAND, 0.15)
    task.wait(0.2)

    local prompt
    for _ = 1, 25 do
        if not isComputerPowerOffline() then
            lastPowerReboot = tick()
            powerOffline = false
            if afterSuccess then
                afterSuccess()
            elseif savedCFrame then
                tweenHRPToCFrame(savedCFrame, 0.15)
            end
            return true
        end
        stayAtPowerStand()
        prompt = findRebootPrompt()
        if prompt then
            break
        end
        task.wait(0.2)
    end

    if not prompt then
        return false
    end

    local steps = 0
    while isComputerPowerOffline() and prompt.Parent and steps < 30 do
        stayAtPowerStand()
        fireProximityPrompt(prompt)
        task.wait(0.25)
        if not prompt.Parent then
            prompt = findRebootPrompt()
            if not prompt then
                break
            end
        end
        steps += 1
    end

    if not isComputerPowerOffline() then
        lastPowerReboot = tick()
        powerOffline = false
        task.wait(0.35)
        if afterSuccess then
            afterSuccess()
        elseif savedCFrame then
            tweenHRPToCFrame(savedCFrame, 0.15)
        end
        return true
    end
    return false
end

local function startPowerReboot(afterSuccess)
    if powerRebootBusy or moveBusy or ammoRefillBusy then
        return
    end

    powerRebootBusy = true
    moveBusy = true
    moveBusyStartedAt = tick()
    task.spawn(function()
        pcall(function()
            executePowerReboot(afterSuccess)
        end)
        moveBusy = false
        moveBusyStartedAt = 0
        powerRebootBusy = false
    end)
end

local function getNormalStorage()
    local ws = getWorkspaceScriptable()
    return ws
        and ws:FindFirstChild("Storage")
        and ws.Storage:FindFirstChild("NormalStorage")
end

local function getPrisonerSpawnCFrame()
    local ws = getWorkspaceScriptable()
    local jail = ws and ws:FindFirstChild("JailEssentials")
    local prisoner = jail and jail:FindFirstChild("Prisoner2")
    local root = prisoner and prisoner:FindFirstChild("HumanoidRootPart")
    return root and root.CFrame
end

local function returnToFarmArea()
    local prisonerCf = getPrisonerSpawnCFrame()
    if prisonerCf then
        tweenHRPToCFrame(prisonerCf)
        task.wait(0.3)
    end
end

local function processFarmSinkNPCs()
    local normalStorage = getNormalStorage()
    if not normalStorage then
        return
    end

    local function speedFolder(folder)
        if not folder then
            return
        end
        for _, npc in folder:GetChildren() do
            if not isPassenger(npc) then
                continue
            end

            local _, _, sv = getNPCProps(npc)
            if sv and isNpcLockedUp(sv) then
                continue
            end

            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                continue
            end

            if arrestFocusNpc == npc then
                humanoid.WalkSpeed = 0
            else
                humanoid.WalkSpeed = FARM_GOOD_NPC_SPEED
            end
        end
    end

    speedFolder(normalStorage:FindFirstChild("NPCWorkspace"))
    speedFolder(normalStorage:FindFirstChild("HostileNPCWorkspace"))
end

local function ensureAtFarmStand()
    local _, _, hrp = getCharacter()
    if not hrp then
        return false
    end

    if (hrp.Position - FARM_STAND_POS).Magnitude <= FARM_STAND_THRESHOLD then
        farmStandMoving = false
        return true
    end

    if not farmStandMoving and not moveBusy and not checkpointBusy then
        farmStandMoving = true
        task.spawn(function()
            pcall(function()
                tweenHRPTo(FARM_STAND_POS)
            end)
            farmStandMoving = false
        end)
    end

    return false
end

local function fireFarmPodiumPrompts()
    local _, _, hrp = getCharacter()
    local savedCFrame = hrp and hrp.CFrame

    local function handlePodium(podiumName, minPoint, maxPoint, shouldDeny, stage)
        local npc = getPassengerNearPodium(podiumName, CHECKPOINT_PODIUM_RANGE, minPoint, maxPoint)
        local deny = npc and canHandleCheckpoint(npc, stage) and shouldDeny(npc)
        local prompt = getPodiumPrompt(podiumName, not deny)
        if prompt then
            fireProximityPrompt(prompt)
        end

        if deny and npc and autoOn("AutoArrest") and shouldCuffPassenger(npc) and not pendingDeny[npc] then
            pendingDeny[npc] = {
                stage = stage,
                savedCFrame = savedCFrame,
                at = tick(),
            }
        elseif npc and not deny and canHandleCheckpoint(npc, stage) then
            markCheckpointHandled(npc, stage)
        end
    end

    if autoOn("AutoMetalDetector") then
        handlePodium("ButtonPodiumMD", CHECKPOINT_MD_POINT, CHECKPOINT_MD_POINT, shouldDenyAtMD, "md")
    end
    if autoOn("AutoIDCheck") then
        handlePodium("ButtonPodiumID", CHECKPOINT_ID_MIN, 99, shouldDenyAtID, "id")
    end
end

local function processFarmCheckpoints()
    if checkpointBusy or moveBusy or farmStandMoving then
        return
    end
    if not ensureAtFarmStand() then
        return
    end
    if isComputerPowerOffline() or #getActiveFires() > 0 then
        return
    end

    fireFarmPodiumPrompts()
end

local function tryFarmPowerReboot(now)
    if not autoOn("AutoPowerReboot") or now - lastPowerReboot < 2 then
        return
    end
    if shouldUseFarmStand() then
        startPowerReboot(returnToFarmArea)
    else
        startPowerReboot(nil)
    end
end

local function tryFarmFireExtinguisher(now, fires)
    if not autoOn("AutoFireExtinguisher") or now - lastExtinguisher < 2 or fireExtinguishBusy or moveBusy then
        return
    end

    local fireTarget = fires[1]
    if not fireTarget then
        return
    end

    fireExtinguishBusy = true
    moveBusy = true
    moveBusyStartedAt = tick()
    task.spawn(function()
        pcall(function()
            if not getTool("Fire Extinguisher") then
                local prompt = findEnabledExtinguisherPrompt()
                if prompt then
                    tweenToTarget(prompt, 2)
                    task.wait(0.4)

                    local attempts = 0
                    while not getTool("Fire Extinguisher") and attempts < 15 do
                        fireProximityPrompt(prompt)
                        task.wait(0.4)
                        attempts += 1
                    end
                end
            end

            if not getTool("Fire Extinguisher") then
                return
            end

            equipTool("Fire Extinguisher")

            local targetPos = fireTarget.Position
            local lookFrom = targetPos + Vector3.new(0, 2, 4)
            tweenHRPToCFrame(CFrame.lookAt(lookFrom, targetPos))
            task.wait(0.3)

            local camera = Workspace.CurrentCamera
            if camera then
                camera.CFrame = CFrame.lookAt(lookFrom + Vector3.new(0, 2, 2), targetPos)
            end

            setExtinguisherSpray(true)

            local waitSteps = 0
            while isFirePartActive(fireTarget) and waitSteps < 35 do
                task.wait(0.2)
                waitSteps += 1
            end

            setExtinguisherSpray(false)
            lastExtinguisher = tick()
            returnToFarmArea()
        end)
        fireExtinguishBusy = false
        moveBusy = false
        moveBusyStartedAt = 0
    end)
end

local function runFarmAutomation(now)
    if moveBusy and moveBusyStartedAt > 0 and tick() - moveBusyStartedAt > 10 then
        moveBusy = false
        moveBusyStartedAt = 0
    end

    processFarmDisasterCombat(now)

    local gun = findGun()
    local _, ammoValue = getGunAmmoValue(gun)
    if gun and ammoValue <= 0 then
        tryAmmoRefill(now)
    end

    if getActiveBoss() then
        if autoOn("AutoReload") then
            tryAutoReload()
        end
        return
    end

    processPendingDeny()
    if useHostileCaptureChain() then
        scanHostilesForCapture()
        processHostileCapture()
    end

    if shouldUseFarmStand() or autoOn("AutoArrest") then
        processFarmSinkNPCs()
    end

    if hasBlockingThreats() or moveBusy or checkpointBusy then
        if autoOn("AutoReload") then
            tryAutoReload()
        end
        return
    end

    if isComputerPowerOffline() then
        tryFarmPowerReboot(now)
        return
    end

    local fires = getActiveFires()
    if autoOn("AutoFireExtinguisher") and #fires > 0 then
        tryFarmFireExtinguisher(now, fires)
        return
    end

    if autoOn("AutoLuggage") and now - lastLuggage >= Settings.ActionCooldown then
        processLuggageWorkspace()
        lastLuggage = now
    end

    if shouldUseFarmStand() then
        processFarmCheckpoints()
    end
end

local function isInsideBossFire(hrp, firePart)
    if not (hrp and firePart and firePart:IsA("BasePart")) then
        return false
    end

    local localPos = firePart.CFrame:PointToObjectSpace(hrp.Position)
    local half = firePart.Size * 0.5
    return math.abs(localPos.X) <= half.X + BOSS_FIRE_DODGE_PADDING
        and math.abs(localPos.Z) <= half.Z + BOSS_FIRE_DODGE_PADDING
end

local function getThreateningBossFire(hrp)
    for _, inst in Workspace:GetDescendants() do
        if inst.Name == "BossFire" and inst:IsA("BasePart") and isInsideBossFire(hrp, inst) then
            return inst
        end
    end
end

local function getBossFireDodgePosition(hrp, firePart)
    local flatAway = Vector3.new(hrp.Position.X - firePart.Position.X, 0, hrp.Position.Z - firePart.Position.Z)
    if flatAway.Magnitude < 1 then
        flatAway = Vector3.new(hrp.CFrame.RightVector.X, 0, hrp.CFrame.RightVector.Z)
    end
    if flatAway.Magnitude < 0.1 then
        flatAway = Vector3.new(1, 0, 0)
    end

    local sidestep = flatAway.Unit
    local boss = getActiveBoss()
    local bossHrp = boss and boss:FindFirstChild("HumanoidRootPart")
    if bossHrp then
        local toBoss = Vector3.new(bossHrp.Position.X - hrp.Position.X, 0, bossHrp.Position.Z - hrp.Position.Z)
        if toBoss.Magnitude > 0.1 then
            local right = toBoss:Cross(Vector3.yAxis).Unit
            sidestep = sidestep:Dot(right) >= 0 and right or -right
        end
    end

    local targetPos = hrp.Position + sidestep * BOSS_FIRE_DODGE_STEP
    return Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
end

local function tryBossFireDodge()
    if not Settings.CombatDodge then
        return
    end
    if fireDodgeBusy or checkpointBusy or retreatBusy or fireExtinguishBusy or powerRebootBusy then
        return
    end

    local _, hum, hrp = getCharacter()
    if not hum or hum.Health <= Settings.RetreatHealth then
        return
    end

    if tick() - lastFireDodge < 0.15 then
        return
    end

    local firePart = getThreateningBossFire(hrp)
    if not firePart then
        return
    end

    local targetPos = getBossFireDodgePosition(hrp, firePart)
    if (hrp.Position - targetPos).Magnitude < 1 then
        return
    end

    lastFireDodge = tick()
    fireDodgeBusy = true
    task.spawn(function()
        pcall(function()
            tweenHRPTo(targetPos, BOSS_FIRE_DODGE_DURATION)
        end)
        fireDodgeBusy = false
    end)
end

local function getSafeRetreatPosition()
    local ws = getWorkspaceScriptable()
    local refill = ws and ws:FindFirstChild("AmmoRefill")
    if refill then
        local attachment = refill:FindFirstChild("PromptAttachment", true)
        local prompt = attachment and attachment:FindFirstChild("ProximityPrompt")
        if prompt then
            local standCFrame = getStandCFrame(prompt, 2.5)
            if standCFrame then
                return standCFrame.Position
            end
        end
        local part = refill.PrimaryPart or refill:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return (part.CFrame * CFrame.new(0, 0, 2.5)).Position
        end
    end
    return SAFE_RETREAT_FALLBACK
end

local function tryCombatRetreat()
    if not Settings.CombatRetreat or retreatBusy or moveBusy or checkpointBusy then
        return
    end
    if getActiveBoss() then
        return
    end

    local _, hum = getCharacter()
    if not hum or hum.Health > Settings.RetreatHealth then
        return
    end

    if tick() - lastRetreat < 4 then
        return
    end

    lastRetreat = tick()
    retreatBusy = true
    moveBusy = true
    moveBusyStartedAt = tick()
    task.spawn(function()
        pcall(function()
            setExtinguisherSpray(false)
            tweenHRPTo(getSafeRetreatPosition())
            task.wait(1.2)
        end)
        retreatBusy = false
        moveBusy = false
        moveBusyStartedAt = 0
    end)
end

    runAutomation = function()
        local now = tick()
    if moveBusy and moveBusyStartedAt > 0 and tick() - moveBusyStartedAt > 10 then
        moveBusy = false
        moveBusyStartedAt = 0
    end

    runFarmAutomation(now)
    tryBossFireDodge()
    tryCombatRetreat()
    end
end)()

;(function()
    local function getDayStat(name)
    local dv = Resources and Resources:FindFirstChild("DayVariables")
    local val = dv and dv:FindFirstChild(name)
    return val and val:IsA("ValueBase") and val.Value or nil
end

local function getDayObjectiveText()
    local gui = plr:FindFirstChild("PlayerGui")
    local core = gui and gui:FindFirstChild("CoreUI")
    local frame = core and core:FindFirstChild("DayObjectiveFrame", true)
    local label = frame and frame:FindFirstChild("DayObjective")
    return label and label.Text or "—"
end

local function getCashText()
    local gui = plr:FindFirstChild("PlayerGui")
    local core = gui and gui:FindFirstChild("CoreUI")
    local cash = core and core:FindFirstChild("CashFrame", true)
    local label = cash and cash:FindFirstChild("CashLabel")
    return label and label.Text:gsub("%s+", " ") or "—"
end

local function getPingText()
    local ok, ping = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return ok and (ping .. " ms") or "—"
end

local function getUptimeText()
    local uptime = math.floor(os.clock() - startTime)
    return string.format("%dm %ds", math.floor(uptime / 60), uptime % 60)
end

local function getWebhookTimestamp()
    local ok, iso = pcall(function()
        return DateTime.now():ToIsoDate()
    end)
    if ok then
        return iso
    end
    return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function postWebhook(payload)
    local url = getWebhookURL()
    if url == "" or not url:find("discord%.com/api/webhooks") then
        return false, "Invalid webhook URL"
    end

    local jsonOk, jsonData = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not jsonOk then
        return false, "JSON encode failed"
    end

    local ok, err = pcall(function()
        if typeof(request) == "function" then
            request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonData,
            })
            return
        end
        if typeof(syn) == "table" and typeof(syn.request) == "function" then
            syn.request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = jsonData,
            })
            return
        end
        HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson)
    end)

    return ok, err
end

local function buildWebhookPayload()
    local cd = Resources and Resources:FindFirstChild("CurrentDay")
    local day = cd and cd.Value or "—"
    local boarded = getDayStat("PassengersBoarded")
    local arrested = getDayStat("CriminalsArrestedOrKilled")
    local luggageOk = getDayStat("LuggageCorrect")
    local luggageBad = getDayStat("LuggageIncorrect")
    local escaped = getDayStat("CriminalsEscaped")
    local objective = getDayObjectiveText()

    if objective == "—" or (type(objective) == "string" and objective:find("^This is today")) then
        objective = "No active objective"
    end

    local fields = {
        { name = "Officer", value = plr.Name, inline = true },
    }

    if Settings.WebhookIncludeCash then
        table.insert(fields, { name = "Cash", value = getCashText(), inline = true })
    end
    if Settings.WebhookIncludeDay then
        local dayText = "Day " .. tostring(day)
        if isEndlessMode() then
            dayText = dayText .. " (Endless)"
        end
        table.insert(fields, { name = "Day", value = dayText, inline = true })
    end
    if Settings.WebhookIncludeBoarded then
        table.insert(fields, { name = "Boarded", value = tostring(boarded or 0), inline = true })
    end
    if Settings.WebhookIncludeArrested then
        table.insert(fields, { name = "Arrested", value = tostring(arrested or 0), inline = true })
    end
    if Settings.WebhookIncludeEscaped then
        table.insert(fields, { name = "Escaped", value = tostring(escaped or 0), inline = true })
    end
    if Settings.WebhookIncludeLuggage then
        table.insert(fields, { name = "Luggage", value = string.format("%s correct / %s wrong", tostring(luggageOk or 0), tostring(luggageBad or 0)), inline = false })
    end
    if Settings.WebhookIncludeObjective then
        table.insert(fields, { name = "Objective", value = tostring(objective):sub(1, 256), inline = false })
    end
    if Settings.WebhookIncludePing then
        table.insert(fields, { name = "Ping", value = getPingText(), inline = true })
    end
    if Settings.WebhookIncludeUptime then
        table.insert(fields, { name = "Uptime", value = getUptimeText(), inline = true })
    end
    if Settings.WebhookIncludeJobId then
        table.insert(fields, { name = "JobId", value = "`" .. game.JobId .. "`", inline = false })
    end

    return {
        username = "Samuraa1 Hub",
        avatar_url = "https://www.roblox.com/asset-thumbnail/image?assetId=97594400820219&width=420&height=420&format=png",
        embeds = {
            {
                title = "Secure the Airport - Session Report",
                description = "Live stats from your security shift",
                color = 5793266,
                thumbnail = {
                    url = "https://www.roblox.com/asset-thumbnail/image?assetId=97594400820219&width=420&height=420&format=png",
                },
                fields = fields,
                footer = {
                    text = "Samuraa1 Hub • Secure the Airport v2.0.0",
                },
                timestamp = getWebhookTimestamp(),
            },
        },
    }
end

    function Webhook.getPingText()
        return getPingText()
    end

    function Webhook.getUptimeText()
        return getUptimeText()
    end

    function Webhook.sendReport(silent)
        local ok, err = postWebhook(buildWebhookPayload())
        if not silent and Library then
            if ok then
                notify("Webhook", "Message sent successfully", 3)
            else
                notify("Webhook", "Failed to send: " .. tostring(err), 4)
            end
        end
        if ok then
            lastWebhookSend = tick()
        end
        return ok
    end

    local function tryAutoWebhook(now)
        if not Settings.WebhookAuto then
            return
        end
        if getWebhookURL() == "" then
            return
        end
        if now - lastWebhookSend >= Settings.WebhookInterval then
            Webhook.sendReport(true)
        end
    end

    function Webhook.startAutoLoop()
        if webhookAutoLoopStarted then
            return
        end
        webhookAutoLoopStarted = true
        task.spawn(function()
            while true do
                task.wait(1)
                pcall(function()
                    tryAutoWebhook(tick())
                end)
            end
        end)
    end
end)()

local setFullbright
local applyThirdPerson
;(function()
    local function applyPlayerMods()
        local char, hum = getCharacter()
        if not hum then
            return
        end

        if Settings.WalkSpeed then
            hum.WalkSpeed = Settings.WalkSpeedValue
        end
        if Settings.JumpPower then
            hum.JumpPower = Settings.JumpPowerValue
        end
    end

    local function applyFOV()
        local camera = Workspace.CurrentCamera
        if not camera then
            return
        end
        if Settings.CustomFOV then
            camera.FieldOfView = Settings.FOVValue
        end
    end

    local function setThirdPersonCharacterVisible(char, visible)
        if not char then
            return
        end

        for _, inst in char:GetDescendants() do
            if inst:IsA("BasePart") or inst:IsA("Decal") then
                inst.LocalTransparencyModifier = 0
            end
        end

        for _, child in char:GetChildren() do
            if child:IsA("Tool") then
                for _, part in child:GetDescendants() do
                    if part:IsA("BasePart") or part:IsA("UnionOperation") then
                        part.Transparency = visible and 0 or 1
                    end
                end
            end
        end
    end

    local function setThirdPersonViewmodelVisible(camera, visible)
        if not camera then
            return
        end

        for _, child in camera:GetChildren() do
            if child:IsA("Model") then
                for _, inst in child:GetDescendants() do
                    if inst:IsA("BasePart") or inst:IsA("Decal") then
                        inst.LocalTransparencyModifier = visible and 0 or 1
                    end
                end
            end
        end
    end

    applyThirdPerson = function()
        local camera = Workspace.CurrentCamera
        if not camera then
            return
        end

        if Settings.ThirdPerson then
            local char, hum = getCharacter()
            if not hum then
                return
            end

            if not savedCamera.captured then
                savedCamera.CameraType = camera.CameraType
                savedCamera.CameraMode = plr.CameraMode
                pcall(function()
                    savedCamera.DevComputerCameraMode = plr.DevComputerCameraMode
                end)
                pcall(function()
                    savedCamera.DevTouchCameraMode = plr.DevTouchCameraMode
                end)
                savedCamera.CameraMinZoomDistance = plr.CameraMinZoomDistance
                savedCamera.CameraMaxZoomDistance = plr.CameraMaxZoomDistance
                savedCamera.captured = true
            end

            plr.CameraMode = Enum.CameraMode.Classic
            pcall(function()
                plr.DevComputerCameraMode = Enum.DevComputerCameraMode.Classic
            end)
            pcall(function()
                plr.DevTouchCameraMode = Enum.DevTouchCameraMode.Classic
            end)
            plr.CameraMinZoomDistance = THIRD_PERSON_DISTANCE
            plr.CameraMaxZoomDistance = THIRD_PERSON_DISTANCE

            if camera.CameraType == Enum.CameraType.Scriptable then
                camera.CameraType = Enum.CameraType.Custom
            end
            camera.CameraSubject = hum

            setThirdPersonCharacterVisible(char, true)
            setThirdPersonViewmodelVisible(camera, false)
            return
        end

        if not savedCamera.captured then
            return
        end

        if camera.CameraType == Enum.CameraType.Scriptable then
            camera.CameraType = savedCamera.CameraType or Enum.CameraType.Custom
        end

        plr.CameraMode = savedCamera.CameraMode or Enum.CameraMode.LockFirstPerson
        if savedCamera.DevComputerCameraMode then
            pcall(function()
                plr.DevComputerCameraMode = savedCamera.DevComputerCameraMode
            end)
        end
        if savedCamera.DevTouchCameraMode then
            pcall(function()
                plr.DevTouchCameraMode = savedCamera.DevTouchCameraMode
            end)
        end
        plr.CameraMinZoomDistance = savedCamera.CameraMinZoomDistance or 0.5
        plr.CameraMaxZoomDistance = savedCamera.CameraMaxZoomDistance or 400

        local char, hum = getCharacter()
        if hum then
            camera.CameraSubject = hum
        end

        setThirdPersonCharacterVisible(char, false)
        setThirdPersonViewmodelVisible(camera, true)

        savedCamera.captured = false
    end

    setFullbright = function(state)
        if state then
            originalLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
            }
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        elseif originalLighting.Brightness then
            for key, value in pairs(originalLighting) do
                Lighting[key] = value
            end
            originalLighting = {}
        end
    end

    local function setupPowerStateHooks()
        if not RemoteComputers then
            return
        end

        local powerOff = RemoteComputers:FindFirstChild("PowerOffline")
        local powerOn = RemoteComputers:FindFirstChild("PowerReboot")
        if powerOff then
            powerOff.OnClientEvent:Connect(function()
                powerOffline = true
            end)
        end
        if powerOn then
            powerOn.OnClientEvent:Connect(function()
                powerOffline = false
            end)
        end
    end

    local function setupDayHooks()
        if not ClientEvents then
            return
        end

        local roundRelated = ClientEvents:FindFirstChild("RoundRelated")
        if not roundRelated then
            return
        end

        local dayStart = roundRelated:FindFirstChild("DayStartVisual")
        if dayStart then
            dayStart.OnClientEvent:Connect(function()
                resetDayAutomationState()
            end)
        end
    end

    pcall(function()
        local camera = Workspace.CurrentCamera
        if camera then
            defaultFOV = camera.FieldOfView
            Settings.FOVValue = defaultFOV
        end
    end)

    RunService.Heartbeat:Connect(function()
        if Settings.InfiniteSprint then
            local _, hum = getCharacter()
            if hum and hum.MoveDirection.Magnitude > 0 then
                hum.WalkSpeed = Settings.RunSpeedValue
            end
        end
        if Settings.WalkSpeed or Settings.JumpPower then
            applyPlayerMods()
        end
        if Settings.CustomFOV then
            applyFOV()
        end

        if Settings.Noclip then
            local char = plr.Character
            if char then
                for _, part in char:GetDescendants() do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    RunService:BindToRenderStep("ThirdPerson", Enum.RenderPriority.Last.Value, function()
        pcall(applyThirdPerson)
    end)

    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastESPUpdate < 0.12 then
            return
        end
        lastESPUpdate = now

        if Settings.PassengerESP then
            updatePassengerESP()
        elseif next(passengerESP) then
            clearCache(passengerESP)
        end

        if Settings.LuggageESP then
            updateLuggageESP()
        elseif next(luggageESP) then
            clearCache(luggageESP)
        end

        if Settings.EnemyESP then
            updateEnemyESP()
        elseif next(enemyESP) then
            clearCache(enemyESP)
        end

        if Settings.WaypointESP or Settings.JailESP or Settings.AmmoESP then
            updateWorldESP()
        elseif next(worldESP) then
            clearCache(worldESP)
        end
    end)

    task.spawn(function()
        while true do
            if isAutomationRunning() then
                pcall(runAutomation)
            end
            task.wait(0.15)
        end
    end)

    if Settings.AntiAFK then
        antiAfkConn = plr.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    plr.CharacterAdded:Connect(function()
        moveBusy = false
        moveBusyStartedAt = 0
        checkpointBusy = false
        fireExtinguishBusy = false
        retreatBusy = false
        fireDodgeBusy = false
        farmStandMoving = false
        task.wait(0.3)
        savedCamera.captured = false
        applyThirdPerson()
    end)

    setupPowerStateHooks()
    setupDayHooks()
end)()

;(function()
    if not isLobbyPlace() then
        return
    end

    local fireUiSignal = firesignal
        or function(signal)
            if not (getconnections and signal) then
                return
            end
            for _, conn in getconnections(signal) do
                pcall(function()
                    if conn.Function then
                        conn:Fire()
                    end
                end)
            end
        end

    local lobbyRemotes = ReplicatedStorage:WaitForChild("Remotes")
    local lobbyEvents = ReplicatedStorage:WaitForChild("Resources"):WaitForChild("Events")
    local lobbyHud = lobbyEvents:WaitForChild("HUD")
    local lobbyOutfits = ReplicatedStorage:WaitForChild("Resources"):WaitForChild("CharAssets"):WaitForChild("Outfits")
    local outfitOwnership = {}
    local ownershipScanned = false
    local lastLobbyAutoAt = 0

    lobbyEvents.OutfitPreview.OnClientEvent:Connect(function(outfit, owned)
        if outfit then
            outfitOwnership[outfit.Name] = owned == true
        end
    end)

    local function formatLobbyCash(amount)
        local text = tostring(math.floor(tonumber(amount) or 0))
        repeat
            local replaced
            text, replaced = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        until replaced == 0
        return "$ " .. text
    end

    function Lobby.getCash()
        local rf = lobbyHud:FindFirstChild("RequestBalance")
        if not rf then
            return 0
        end
        local ok, balance = pcall(function()
            return rf:InvokeServer()
        end)
        if ok and type(balance) == "number" then
            return balance
        end
        return 0
    end

    Lobby.formatCash = formatLobbyCash

    local function getOutfitEntries()
        local entries = {}
        for _, outfit in lobbyOutfits:GetChildren() do
            if outfit:IsA("Configuration") then
                local price = 0
                local purchase = outfit:FindFirstChild("PurchaseVariables")
                local priceVal = purchase and purchase:FindFirstChild("Price")
                if priceVal then
                    price = priceVal.Value
                end
                table.insert(entries, {
                    name = outfit.Name,
                    config = outfit,
                    price = price,
                })
            end
        end
        table.sort(entries, function(a, b)
            return a.price > b.price
        end)
        return entries
    end

    function Lobby.getClassNames()
        local names = {}
        local entries = getOutfitEntries()
        for i = #entries, 1, -1 do
            table.insert(names, entries[i].name)
        end
        return names
    end

    function Lobby.scanOwnership()
        for _, entry in ipairs(getOutfitEntries()) do
            lobbyEvents.OutfitPreview:FireServer(entry.config)
            task.wait(0.1)
        end
        ownershipScanned = true
    end

    function Lobby.equipClass(className)
        local outfit = lobbyOutfits:FindFirstChild(className)
        if not outfit then
            notify("Lobby", "Unknown class: " .. tostring(className), 3)
            return false
        end
        lobbyEvents.OutfitPreview:FireServer(outfit)
        task.wait(0.2)
        lobbyEvents.OutfitBuyEquip:FireServer(outfit)
        Settings.LobbySelectedClass = className
        return true
    end

    local function findOpenTeleporter()
        local teleporters = Workspace:FindFirstChild("Teleporters")
        if not teleporters then
            return
        end

        local best, bestCount
        for _, tp in teleporters:GetChildren() do
            if tp:IsA("Model") and tp:FindFirstChild("PartyStarted") and not tp.PartyStarted.Value then
                local maxPlayers = tp:FindFirstChild("MaxPlayers") and tp.MaxPlayers.Value or 4
                local count = tp:FindFirstChild("Players") and #tp.Players:GetChildren() or 0
                if count < maxPlayers and (not best or count > bestCount) then
                    best = tp
                    bestCount = count
                end
            end
        end
        return best
    end

    local function walkToTeleporter(tp)
        local stand = tp:FindFirstChild("Hitbox") or tp:FindFirstChild("TeleportPart") or tp:FindFirstChild("Ground")
        if not stand then
            return
        end
        tweenHRPTo(stand.Position + Vector3.new(0, 3, 0), getTweenDuration(0.35))
        task.wait(0.4)
    end

    function Lobby.startGame(silent)
        local partySize = math.clamp(math.floor(Settings.LobbyPartySize or 1), 1, 4)
        local tp = findOpenTeleporter()
        if not tp then
            if not silent then
                notify("Lobby", "No open teleporter found", 3)
            end
            return
        end

        walkToTeleporter(tp)

        local tpui = plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("TeleportUI")
        local teleporterValue = tpui and tpui:FindFirstChild("Teleporter")
        if teleporterValue and teleporterValue:IsA("ObjectValue") then
            teleporterValue.Value = tp
        end

        lobbyRemotes.Start:FireServer(tp, partySize, "story")
        if not silent then
            notify("Lobby", ("Starting game (party %d)"):format(partySize), 3)
        end
    end

    function Lobby.isInParty()
        local values = plr:FindFirstChild("Values")
        local isParty = values and values:FindFirstChild("IsParty")
        return isParty and isParty.Value or false
    end

    function Lobby.leaveParty()
        lobbyRemotes.Leave:FireServer()
        local tpui = plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("TeleportUI")
        local teleporterValue = tpui and tpui:FindFirstChild("Teleporter")
        if teleporterValue and teleporterValue:IsA("ObjectValue") then
            teleporterValue.Value = nil
        end
        notify("Lobby", "Left party", 2)
    end

    function Lobby.autoEquipBestOwned()
        if not ownershipScanned then
            Lobby.scanOwnership()
            task.wait(0.35)
        end

        for _, entry in ipairs(getOutfitEntries()) do
            if entry.price <= 0 or outfitOwnership[entry.name] then
                Lobby.equipClass(entry.name)
                return true
            end
        end
        return false
    end

    function Lobby.autoBuyBestAffordable()
        local cash = Lobby.getCash()
        for _, entry in ipairs(getOutfitEntries()) do
            if entry.price > 0 and entry.price <= cash then
                Lobby.equipClass(entry.name)
                return true
            end
        end
        return Lobby.autoEquipBestOwned()
    end

    local function isPlaytimeClaimable(text)
        if type(text) ~= "string" or text == "" then
            return false
        end
        local lower = text:lower()
        if lower:find("claim") or lower:find("ready") or lower:find("collect") then
            return true
        end
        if text == "0:00" then
            return true
        end
        return not text:match("^%d+:%d+$")
    end

    function Lobby.tryClaimPlaytimeRewards()
        local rewardsGui = plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("FreeRewardsUI")
        local list = rewardsGui
            and rewardsGui:FindFirstChild("Rewards")
            and rewardsGui.Rewards:FindFirstChild("Main")
            and rewardsGui.Rewards.Main:FindFirstChild("Playtime")
            and rewardsGui.Rewards.Main.Playtime:FindFirstChild("List")
        if not list then
            return
        end

        for _, frame in list:GetChildren() do
            if frame:IsA("Frame") and frame.Name == "Template" then
                local timeBox = frame:FindFirstChild("TimeBox", true)
                local amount = timeBox and timeBox:FindFirstChild("Amount")
                if amount and isPlaytimeClaimable(amount.Text) then
                    local button = frame:FindFirstChildWhichIsA("GuiButton", true)
                    if button then
                        fireUiSignal(button.MouseButton1Click)
                    else
                        fireUiSignal(frame.MouseButton1Click)
                    end
                end
            end
        end
    end

    task.spawn(function()
        task.wait(1.5)
        pcall(Lobby.scanOwnership)
    end)

    local lastQuickStartTry = 0

    task.spawn(function()
        while isLobbyPlace() do
            task.wait(3)
            if tick() - lastLobbyAutoAt < 2.5 then
                -- cooldown
            else
                local acted = false
                if Settings.LobbyAutoBuyBest then
                    acted = Lobby.autoBuyBestAffordable() or acted
                elseif Settings.LobbyAutoEquipBest then
                    acted = Lobby.autoEquipBestOwned() or acted
                end
                if Settings.LobbyAutoClaimRewards then
                    Lobby.tryClaimPlaytimeRewards()
                    acted = true
                end
                if acted then
                    lastLobbyAutoAt = tick()
                end
            end

            if Settings.LobbyQuickStart and not Lobby.isInParty() and tick() - lastQuickStartTry > 10 then
                lastQuickStartTry = tick()
                task.spawn(function()
                    Lobby.startGame(true)
                end)
            end
        end
    end)
end)()

local libraryOk, libraryErr = pcall(function()
    Library = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/Library.lua")
end)
if not libraryOk then
    warn("[Samuraa1 Hub] Library load failed:", libraryErr)
    pcall(function()
        task.wait(0.5)
        Library = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/Library.lua")
    end)
end
if not Library then
    plr:Kick("Samuraa1 Hub failed to load UI library. Rejoin and execute again.")
    return
end

;(function()
    local fpsShown = 0
    local fpsFrameCount = 0
    local fpsLastTick = tick()
    RunService.RenderStepped:Connect(function()
        fpsFrameCount += 1
        local t = tick()
        if t - fpsLastTick >= 1 then
            fpsShown = fpsFrameCount
            fpsFrameCount = 0
            fpsLastTick = t
        end
    end)

    local KeybindList = (not UserInputService.TouchEnabled) and Library:KeybindList("Keybinds") or nil

    local Window = Library:Window({
    Name = "Samuraa1 Hub",
    SubName = "Secure the Airport | v2.0.0",
    Logo = "97594400820219",
    MobileScale = UserInputService.TouchEnabled and 0.72 or nil,
})

Window:Category("Overview")
Window:TabDivider()

local DashPage = Window:DashboardPage({
    Name = "Dashboard",
    Icon = "layout-dashboard",
    WelcomeText = "WELCOME TO",
    HubName = "SAMURAA1 HUB",
    StatusText = "free forever — for everyone",
    Badge = "PLAYER",
    Links = {
        { Icon = "copy", Tooltip = "Copy Discord link", Callback = function()
            pcall(function() setclipboard(DISCORD_LINK) end)
            notify("Copied", "Discord link copied.", 2)
        end },
        { Icon = "users", Tooltip = "Join Discord server", Callback = function()
            pcall(function() loadRemoteLua(DISCORD_JOIN_URL) end)
        end },
        { Icon = "file-text", Tooltip = "View changelogs", Callback = function()
            pcall(function() loadRemoteLua(CHANGELOGS_URL) end)
        end },
        { Icon = "zap", Tooltip = "Boost FPS", Callback = function()
            pcall(function() loadRemoteLua(BOOSTFPS_URL) end)
        end },
    },
    GameName = "SECURE THE AIRPORT",
    GameDescription = "Welcome to one of the best Secure the Airport scripts!\nEnjoy tons of features waiting for you",
    Stats = {
        { Name = "UPTIME", Icon = "clock", GetValue = Webhook.getUptimeText },
        { Name = "PING", Icon = "wifi", GetValue = Webhook.getPingText },
        { Name = "EXECS", Icon = "terminal", GetValue = function() return tostring(shared._execs or execCount or 1) end },
    },
    Credits = {
        { Name = "Samuraa1", Role = "Script Creator" },
        { Name = "samet", Role = "Mentality UI Creator" },
    },
    QuickAccess = {},
})

local LobbyPage
if isLobbyPlace() then
    Window:Category("Lobby")
    Window:TabDivider()
    LobbyPage = Window:Page({ Name = "Lobby", Icon = "plane" })
end

Window:Category("Game")
Window:TabDivider()

local AutoPage = Window:Page({ Name = "Automation", Icon = "bot" })
local ESPPage = Window:Page({ Name = "ESP", Icon = "eye" })
local WebhookPage = Window:Page({ Name = "Webhook", Icon = "webhook" })
local VisualsPage = Window:Page({ Name = "Visuals", Icon = "sun" })
local LocalPage = Window:Page({ Name = "Player", Icon = "user-round" })
local ServerPage = Window:Page({ Name = "Server", Icon = "globe" })

if LobbyPage then
    DashPage:AddCard({ Name = "LOBBY", Description = "Party, classes, rewards", Icon = "plane", Tab = LobbyPage })
end

DashPage:AddCard({ Name = "AUTOMATION", Description = "Full auto, checkpoints, combat", Icon = "bot", Tab = AutoPage })
DashPage:AddCard({ Name = "ESP", Description = "Passengers, bags, disasters", Icon = "eye", Tab = ESPPage })
DashPage:AddCard({ Name = "WEBHOOK", Description = "Discord reports", Icon = "webhook", Tab = WebhookPage })
DashPage:AddCard({ Name = "VISUALS", Description = "Lighting and camera", Icon = "sun", Tab = VisualsPage })
DashPage:AddCard({ Name = "LOCAL", Description = "Movement and player", Icon = "user-round", Tab = LocalPage })
DashPage:AddCard({ Name = "SERVER", Description = "Hop, rejoin, JobId", Icon = "globe", Tab = ServerPage })

if LobbyPage then
    local LobbyInfo = LobbyPage:Section({ Name = "Info", Icon = "wallet", Side = 1, LayoutOrder = 1 })
    local LobbyParty = LobbyPage:Section({ Name = "Party", Icon = "users", Side = 1, LayoutOrder = 2 })
    local LobbyClasses = LobbyPage:Section({ Name = "Classes", Icon = "shield", Side = 2, LayoutOrder = 1 })
    local LobbyAuto = LobbyPage:Section({ Name = "Auto", Icon = "bot", Side = 2, LayoutOrder = 2 })

    local CashLabel = LobbyInfo:Label("Cash: —")

    task.spawn(function()
        while isLobbyPlace() do
            task.wait(1.5)
            pcall(function()
                CashLabel:SetText("Cash: " .. Lobby.formatCash(Lobby.getCash()))
            end)
        end
    end)

    LobbyParty:Slider({
        Name = "Party Size",
        Flag = "LobbyPartySize",
        Min = 1,
        Max = 4,
        Default = 1,
        Rounding = 0,
        Tooltip = "Players in your party before starting",
        Callback = function(value)
            Settings.LobbyPartySize = math.clamp(math.floor(value), 1, 4)
        end,
    })

    LobbyParty:Toggle({
        Name = "Quick Start",
        Flag = "LobbyQuickStart",
        Default = false,
        Tooltip = "Auto join a teleporter and start the game every 10s",
        Callback = function(value)
            Settings.LobbyQuickStart = value
            if value and not Lobby.isInParty() then
                task.spawn(function()
                    Lobby.startGame(true)
                end)
            end
        end,
    })

    LobbyParty:Button({
        Name = "Leave Party",
        Icon = "log-out",
        Tooltip = "Leave the current party",
        Callback = function()
            Lobby.leaveParty()
        end,
    })

    local classNames = Lobby.getClassNames()
    if #classNames == 0 then
        classNames = { "Rookie" }
    end
    if not table.find(classNames, Settings.LobbySelectedClass) then
        Settings.LobbySelectedClass = classNames[1]
    end

    LobbyClasses:Dropdown({
        Name = "Class",
        Flag = "LobbySelectedClass",
        Items = classNames,
        Default = Settings.LobbySelectedClass,
        Tooltip = "Outfit class to equip in the lobby",
        Callback = function(value)
            Settings.LobbySelectedClass = value
        end,
    })

    LobbyClasses:Button({
        Name = "Equip Class",
        Icon = "check",
        Tooltip = "Equip the selected class",
        Callback = function()
            local className = Settings.LobbySelectedClass
            if Library and Library.Flags and Library.Flags.LobbySelectedClass then
                className = Library.Flags.LobbySelectedClass
            end
            task.spawn(function()
                Lobby.equipClass(className)
            end)
        end,
    })

    LobbyAuto:Toggle({
        Name = "Auto Equip Best Owned",
        Flag = "LobbyAutoEquipBest",
        Default = false,
        Tooltip = "Equip your best owned class automatically",
        Callback = function(value)
            Settings.LobbyAutoEquipBest = value
            if value then
                Settings.LobbyAutoBuyBest = false
            end
        end,
    })

    LobbyAuto:Toggle({
        Name = "Auto Buy Best Affordable",
        Flag = "LobbyAutoBuyBest",
        Default = false,
        Tooltip = "Buy and equip the best class you can afford",
        Callback = function(value)
            Settings.LobbyAutoBuyBest = value
            if value then
                Settings.LobbyAutoEquipBest = false
            end
        end,
    })

    LobbyAuto:Toggle({
        Name = "Auto Claim Playtime Rewards",
        Flag = "LobbyAutoClaimRewards",
        Default = false,
        Tooltip = "Try to claim ready playtime rewards",
        Callback = function(value)
            Settings.LobbyAutoClaimRewards = value
        end,
    })
end

local PassengerSection = ESPPage:Section({ Name = "Passengers", Icon = "users", Side = 1, LayoutOrder = 1 })
local WorldSection = ESPPage:Section({ Name = "World", Icon = "map", Side = 2, LayoutOrder = 1 })

PassengerSection:Toggle({
    Name = "Passenger ESP",
    Flag = "PassengerESP",
    Default = true,
    Tooltip = "Show labels above passengers with their status",
    Callback = function(value)
        Settings.PassengerESP = value
        if not value then clearCache(passengerESP) end
    end,
})

PassengerSection:Toggle({
    Name = "Only Threats",
    Flag = "OnlyBadESP",
    Default = false,
    Tooltip = "Hide safe passengers, show only suspicious ones",
    Callback = function(value) Settings.OnlyBadESP = value end,
})

PassengerSection:Toggle({
    Name = "Show Decoys",
    Flag = "ShowFalseAlarms",
    Default = true,
    Tooltip = "Show fake contraband decoys on the ESP",
    Callback = function(value) Settings.ShowFalseAlarms = value end,
})

PassengerSection:Toggle({
    Name = "Hide Game Marks",
    Flag = "HideGameMarks",
    Default = false,
    Tooltip = "Remove the game's default search and arrest markers",
    Callback = function(value) Settings.HideGameMarks = value end,
})

PassengerSection:Toggle({
    Name = "ESP Distance",
    Flag = "ESPDistance",
    Default = true,
    Tooltip = "Show how far away each ESP target is",
    Callback = function(value) Settings.ESPDistance = value end,
})

PassengerSection:Slider({
    Name = "ESP Max Distance",
    Flag = "ESPMaxDistance",
    Min = 50,
    Max = 500,
    Default = 250,
    Tooltip = "How far away ESP labels stay visible",
    Callback = function(value)
        Settings.ESPMaxDistance = value
        for _, cache in { passengerESP, luggageESP, enemyESP, worldESP } do
            for _, entry in pairs(cache) do
                if entry.gui then entry.gui.MaxDistance = value end
            end
        end
    end,
})

WorldSection:Toggle({
    Name = "Luggage ESP",
    Flag = "LuggageESP",
    Default = true,
    Tooltip = "Highlight luggage bags and contraband status",
    Callback = function(value)
        Settings.LuggageESP = value
        if not value then clearCache(luggageESP) end
    end,
})

WorldSection:Toggle({
    Name = "Disaster Enemy ESP",
    Flag = "EnemyESP",
    Default = true,
    Tooltip = "Show disaster criminals and enemies",
    Callback = function(value)
        Settings.EnemyESP = value
        if not value then clearCache(enemyESP) end
    end,
})

WorldSection:Toggle({
    Name = "Waypoint ESP",
    Flag = "WaypointESP",
    Default = false,
    Tooltip = "Show important map waypoints",
    Callback = function(value) Settings.WaypointESP = value end,
})

WorldSection:Toggle({
    Name = "Jail ESP",
    Flag = "JailESP",
    Default = false,
    Tooltip = "Mark the jail area on your screen",
    Callback = function(value) Settings.JailESP = value end,
})

WorldSection:Toggle({
    Name = "Ammo ESP",
    Flag = "AmmoESP",
    Default = false,
    Tooltip = "Mark the ammo refill station",
    Callback = function(value) Settings.AmmoESP = value end,
})

local FullAutoSection = AutoPage:Section({ Name = "Full Auto", Icon = "sparkles", Side = 1, LayoutOrder = 0 })
local AutoSection = AutoPage:Section({ Name = "Security", Icon = "shield", Side = 1, LayoutOrder = 1 })
local CheckpointSection = AutoPage:Section({ Name = "Checkpoints", Icon = "scan", Side = 1, LayoutOrder = 2 })
local CombatSection = AutoPage:Section({ Name = "Combat Survival", Icon = "heart-pulse", Side = 2, LayoutOrder = 2 })
local RangeSection = AutoPage:Section({ Name = "Ranges", Icon = "ruler", Side = 2, LayoutOrder = 1 })

FullAutoSection:Toggle({
    Name = "Auto Do Everything",
    Flag = "AutoDoEverything",
    Default = false,
    Tooltip = "Farm mode: jail Fake ID/contraband, shoot disaster criminals from stand, MD+ID, fire/power",
    Callback = function(value) Settings.AutoDoEverything = value end,
})

CombatSection:Toggle({
    Name = "Low HP Safe Retreat",
    Flag = "CombatRetreat",
    Default = true,
    Tooltip = "Teleport to staff ammo room when health drops too low",
    Callback = function(value) Settings.CombatRetreat = value end,
})

CombatSection:Slider({
    Name = "Retreat HP Threshold",
    Flag = "RetreatHealth",
    Min = 10,
    Max = 80,
    Default = 35,
    Tooltip = "Retreat when HP falls below this value",
    Callback = function(value) Settings.RetreatHealth = value end,
})

CombatSection:Toggle({
    Name = "Auto Dodge Boss Fire",
    Flag = "CombatDodge",
    Default = false,
    Tooltip = "Sidestep when the end boss puts fire under you. Works with Auto Shoot.",
    Callback = function(value) Settings.CombatDodge = value end,
})

AutoSection:Toggle({
    Name = "Auto Taser",
    Flag = "AutoTaser",
    Default = false,
    Tooltip = "Automatically taser nearby threats",
    Callback = function(value) Settings.AutoTaser = value end,
})

AutoSection:Toggle({
    Name = "Taser Hostile Only",
    Flag = "TaserHostileOnly",
    Default = false,
    Tooltip = "Only taser armed criminals, not checkpoint suspects",
    Callback = function(value) Settings.TaserHostileOnly = value end,
})

AutoSection:Toggle({
    Name = "Auto Arrest",
    Flag = "AutoArrest",
    Default = false,
    Tooltip = "Automatically arrest tasered or bad passengers",
    Callback = function(value) Settings.AutoArrest = value end,
})

AutoSection:Toggle({
    Name = "Auto Shoot Disasters",
    Flag = "AutoShoot",
    Default = false,
    Tooltip = "Automatically shoot disaster enemies in range",
    Callback = function(value) Settings.AutoShoot = value end,
})

AutoSection:Toggle({
    Name = "Auto Reload",
    Flag = "AutoReload",
    Default = false,
    Tooltip = "Reload your gun when the magazine is empty",
    Callback = function(value) Settings.AutoReload = value end,
})

AutoSection:Toggle({
    Name = "Auto Luggage Sort",
    Flag = "AutoLuggage",
    Default = false,
    Tooltip = "Automatically approve or deny luggage scans",
    Callback = function(value) Settings.AutoLuggage = value end,
})

AutoSection:Toggle({
    Name = "Auto Equip Tools",
    Flag = "AutoEquipTools",
    Default = true,
    Tooltip = "Equip taser, arrest tool, or gun before using them",
    Callback = function(value) Settings.AutoEquipTools = value end,
})

CheckpointSection:Toggle({
    Name = "Auto Metal Detector",
    Flag = "AutoMetalDetector",
    Default = false,
    Tooltip = "Press accept or deny at the metal detector for you",
    Callback = function(value) Settings.AutoMetalDetector = value end,
})

CheckpointSection:Toggle({
    Name = "Auto ID Check",
    Flag = "AutoIDCheck",
    Default = false,
    Tooltip = "Press accept or deny at the ID checkpoint for you",
    Callback = function(value) Settings.AutoIDCheck = value end,
})

CheckpointSection:Toggle({
    Name = "Auto Jail Escort",
    Flag = "AutoJailEscort",
    Default = true,
    Tooltip = "Walk to jail after an arrest, then return",
    Callback = function(value) Settings.AutoJailEscort = value end,
})

CheckpointSection:Toggle({
    Name = "Auto Ammo Refill",
    Flag = "AutoAmmoRefill",
    Default = false,
    Tooltip = "Refill ammo when your gun is empty",
    Callback = function(value) Settings.AutoAmmoRefill = value end,
})

CheckpointSection:Toggle({
    Name = "Auto Fire Extinguisher",
    Flag = "AutoFireExtinguisher",
    Default = false,
    Tooltip = "Grab extinguisher and put out fires during disasters",
    Callback = function(value) Settings.AutoFireExtinguisher = value end,
})

CheckpointSection:Toggle({
    Name = "Auto Power Reboot",
    Flag = "AutoPowerReboot",
    Default = false,
    Tooltip = "Reboot power when it goes offline",
    Callback = function(value) Settings.AutoPowerReboot = value end,
})

RangeSection:Slider({ Name = "Taser Range", Flag = "TaserRange", Min = 5, Max = 20, Default = 15, Tooltip = "How close a passenger must be to taser", Callback = function(v) Settings.TaserRange = v end })
RangeSection:Slider({ Name = "Arrest Range", Flag = "ArrestRange", Min = 5, Max = 20, Default = 10, Tooltip = "How close a passenger must be to arrest", Callback = function(v) Settings.ArrestRange = v end })
RangeSection:Slider({ Name = "Gun Range", Flag = "GunRange", Min = 20, Max = 200, Default = 120, Tooltip = "How far you can shoot disaster enemies", Callback = function(v) Settings.GunRange = v end })

local WebhookSection = WebhookPage:Section({ Name = "Link", Icon = "webhook", Side = 1, LayoutOrder = 1 })
local WebhookFieldsSection = WebhookPage:Section({ Name = "What to Include", Icon = "list", Side = 1, LayoutOrder = 2 })
local WebhookAutoSection = WebhookPage:Section({ Name = "Auto Send", Icon = "clock", Side = 2, LayoutOrder = 1 })

WebhookSection:Textbox({
    Name = "Webhook URL",
    Flag = "WebhookURL",
    Default = "",
    Placeholder = "https://discord.com/api/webhooks/...",
    Finished = true,
    Tooltip = "Your Discord webhook link for session reports",
    Callback = function(v) Settings.WebhookURL = v end,
})

WebhookSection:Button({
    Name = "Test Webhook",
    Tooltip = "Send a test message to Discord right now",
    Callback = function()
        Webhook.sendReport(false)
    end,
})

WebhookFieldsSection:Toggle({ Name = "Include Day", Flag = "WebhookIncludeDay", Default = true, Tooltip = "Send current day number", Callback = function(v) Settings.WebhookIncludeDay = v end })
WebhookFieldsSection:Toggle({ Name = "Include Cash", Flag = "WebhookIncludeCash", Default = true, Tooltip = "Send your cash balance", Callback = function(v) Settings.WebhookIncludeCash = v end })
WebhookFieldsSection:Toggle({ Name = "Include Boarded", Flag = "WebhookIncludeBoarded", Default = true, Tooltip = "Send passengers boarded count", Callback = function(v) Settings.WebhookIncludeBoarded = v end })
WebhookFieldsSection:Toggle({ Name = "Include Arrested", Flag = "WebhookIncludeArrested", Default = true, Tooltip = "Send criminals arrested count", Callback = function(v) Settings.WebhookIncludeArrested = v end })
WebhookFieldsSection:Toggle({ Name = "Include Escaped", Flag = "WebhookIncludeEscaped", Default = true, Tooltip = "Send criminals escaped count", Callback = function(v) Settings.WebhookIncludeEscaped = v end })
WebhookFieldsSection:Toggle({ Name = "Include Luggage", Flag = "WebhookIncludeLuggage", Default = true, Tooltip = "Send luggage correct/wrong stats", Callback = function(v) Settings.WebhookIncludeLuggage = v end })
WebhookFieldsSection:Toggle({ Name = "Include Objective", Flag = "WebhookIncludeObjective", Default = true, Tooltip = "Send today's objective text", Callback = function(v) Settings.WebhookIncludeObjective = v end })
WebhookFieldsSection:Toggle({ Name = "Include Ping", Flag = "WebhookIncludePing", Default = true, Tooltip = "Send your ping", Callback = function(v) Settings.WebhookIncludePing = v end })
WebhookFieldsSection:Toggle({ Name = "Include Uptime", Flag = "WebhookIncludeUptime", Default = true, Tooltip = "Send how long the script has been running", Callback = function(v) Settings.WebhookIncludeUptime = v end })
WebhookFieldsSection:Toggle({ Name = "Include JobId", Flag = "WebhookIncludeJobId", Default = true, Tooltip = "Send this server's JobId", Callback = function(v) Settings.WebhookIncludeJobId = v end })

WebhookAutoSection:Toggle({
    Name = "Auto Send",
    Flag = "WebhookAuto",
    Default = false,
    Tooltip = "Send reports automatically on a timer",
    Callback = function(v)
        Settings.WebhookAuto = v
        syncSettingsFromUI()
    end,
})

WebhookAutoSection:Slider({
    Name = "Interval (seconds)",
    Flag = "WebhookInterval",
    Min = 60,
    Max = 1800,
    Default = 300,
    Tooltip = "How often auto reports are sent",
    Callback = function(v) Settings.WebhookInterval = v end,
})

local VisualSection = VisualsPage:Section({ Name = "Visual", Icon = "sun", Side = 1, LayoutOrder = 1 })

VisualSection:Toggle({
    Name = "Fullbright",
    Flag = "Fullbright",
    Default = false,
    Tooltip = "Brighten the map and remove fog",
    Callback = function(value)
        Settings.Fullbright = value
        setFullbright(value)
    end,
})

VisualSection:Toggle({
    Name = "Custom FOV",
    Flag = "CustomFOV",
    Default = false,
    Tooltip = "Use a custom camera field of view",
    Callback = function(value) Settings.CustomFOV = value end,
})

VisualSection:Slider({
    Name = "FOV",
    Flag = "FOVValue",
    Min = 40,
    Max = 120,
    Default = 70,
    Tooltip = "Camera field of view value",
    Callback = function(value) Settings.FOVValue = value end,
})

local SpeedSection = LocalPage:Section({ Name = "Movement", Icon = "gauge", Side = 1, LayoutOrder = 1 })
local LocalMiscSection = LocalPage:Section({ Name = "Player", Icon = "user-round", Side = 2, LayoutOrder = 1 })

SpeedSection:Toggle({ Name = "Walk Speed", Flag = "WalkSpeed", Default = false, Tooltip = "Set a custom walking speed", Callback = function(v) Settings.WalkSpeed = v end })
SpeedSection:Slider({ Name = "Speed Value", Flag = "WalkSpeedValue", Min = 15, Max = 60, Default = 24, Tooltip = "Your walk speed when enabled", Callback = function(v) Settings.WalkSpeedValue = v end })
SpeedSection:Toggle({ Name = "Infinite Sprint", Flag = "InfiniteSprint", Default = false, Tooltip = "Run faster while moving", Callback = function(v) Settings.InfiniteSprint = v end })
SpeedSection:Slider({ Name = "Sprint Speed", Flag = "RunSpeedValue", Min = 20, Max = 70, Default = 32, Tooltip = "Speed used while sprinting", Callback = function(v) Settings.RunSpeedValue = v end })
SpeedSection:Toggle({ Name = "Jump Power", Flag = "JumpPower", Default = false, Tooltip = "Set a custom jump height", Callback = function(v) Settings.JumpPower = v end })
SpeedSection:Slider({ Name = "Jump Value", Flag = "JumpPowerValue", Min = 50, Max = 150, Default = 60, Tooltip = "Jump power when enabled", Callback = function(v) Settings.JumpPowerValue = v end })
SpeedSection:Toggle({ Name = "Noclip", Flag = "Noclip", Default = false, Tooltip = "Walk through walls and objects", Callback = function(v) Settings.Noclip = v end })

LocalMiscSection:Toggle({
    Name = "Third Person",
    Flag = "ThirdPerson",
    Default = false,
    Tooltip = "Play in third person with mouse look",
    Callback = function(v)
        Settings.ThirdPerson = v
        applyThirdPerson()
    end,
})

LocalMiscSection:Toggle({
    Name = "Anti AFK",
    Flag = "AntiAFK",
    Default = true,
    Tooltip = "Prevents idle kick by simulating activity",
    Callback = function(value)
        Settings.AntiAFK = value
        if antiAfkConn then
            antiAfkConn:Disconnect()
            antiAfkConn = nil
        end
        if value then
            antiAfkConn = plr.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end,
})

LocalMiscSection:Button({
    Name = "Back To Lobby",
    Tooltip = "Return to the main lobby",
    Callback = function()
        if ClientEvents and ClientEvents:FindFirstChild("BackToLobby") then
            ClientEvents.BackToLobby:FireServer()
        end
    end,
})

local ServerMain = ServerPage:Section({ Name = "Main", Icon = "terminal", Side = 1 })
local ServerInfo = ServerPage:Section({ Name = "Server Info", Icon = "chart-bar", Side = 2 })

ServerMain:Button({
    Name = "Server Hop",
    Icon = "shuffle",
    Tooltip = "Teleport to another server with an open slot",
    Callback = function()
        local url = "https://games.roblox.com/v1/games/" .. PLACE_ID .. "/servers/Public?sortOrder=Desc&limit=100"
        local nextCursor
        repeat
            local ok, raw = pcall(game.HttpGet, game, url .. (nextCursor and ("&cursor=" .. nextCursor) or ""))
            if not ok then break end
            local data = HttpService:JSONDecode(raw)
            for _, v in next, data.data do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    local s = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, PLACE_ID, v.id, plr)
                    if s then return end
                end
            end
            nextCursor = data.nextPageCursor
        until not nextCursor
    end,
})

ServerMain:Button({
    Name = "Join Smallest Server",
    Icon = "users",
    Tooltip = "Join the least populated public server",
    Callback = function()
        local url = "https://games.roblox.com/v1/games/" .. PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
        local ok, raw = pcall(game.HttpGet, game, url)
        if not ok then return end
        local server = HttpService:JSONDecode(raw).data[1]
        if server then
            TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, plr)
        end
    end,
})

ServerMain:Button({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Tooltip = "Rejoin this same server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
    end,
})

ServerMain:Divider("JobId")
ServerMain:Textbox({ Flag = "JobIdInput", Default = "", Numeric = false, Placeholder = "Enter JobId here...", Finished = false, Tooltip = "Paste a JobId to join that server" })
ServerMain:Button({
    Name = "Join by JobId",
    Icon = "log-in",
    Tooltip = "Teleport using the JobId above",
    Callback = function()
        local val = Library.Flags.JobIdInput
        if not val or val == "" then
            notify("Error", "Please enter a JobId", 3)
            return
        end
        if #val ~= 36 or not val:match("^[a-f0-9%-]+$") then
            notify("Invalid", "Not a valid JobId format", 3)
            return
        end
        TeleportService:TeleportToPlaceInstance(PLACE_ID, val, plr)
    end,
})
ServerMain:Button({
    Name = "Copy JobId",
    Icon = "copy",
    Tooltip = "Copy this server's JobId",
    Callback = function()
        pcall(function() setclipboard(game.JobId) end)
        notify("Copied", "Current JobId copied", 2)
    end,
})

local PlayersLabel = ServerInfo:Label("Players: 0 / 0")
local MemLabel = ServerInfo:Label("Memory: —")
local PlaceLabel = ServerInfo:Label("PlaceId: —")
local FpsLabel = ServerInfo:Label("FPS: —")
task.spawn(function()
    while true do
        task.wait(1)
        PlayersLabel:SetText(("Players: %d / %d"):format(#Players:GetPlayers(), Players.MaxPlayers))
        local okm, mb = pcall(function()
            return Stats:GetTotalMemoryUsageMb()
        end)
        if okm and type(mb) == "number" then
            MemLabel:SetText(("Memory: %.0f MB"):format(mb))
        end
        PlaceLabel:SetText(("PlaceId: %d"):format(game.PlaceId))
        FpsLabel:SetText(("FPS: %d"):format(fpsShown))
    end
end)

Window:TabDivider()
Window:Category("Settings")

local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)

local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport
    or (fluxus and fluxus.queue_on_teleport) or (krnl and krnl.queue_on_teleport)
    or (delta and delta.queue_on_teleport)

local autoexec_script = ("loadstring(game:HttpGet('%s'))()"):format(STA_SCRIPT_URL)

pcall(function()
    local TM = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/ThemeManager.lua")
    TM:SetLibrary(Library)
    TM:SetFolder("Samuraa1Hub")
    TM:BuildThemeSection(SettingsPage)
    TM:LoadDefault()
end)

local ScriptSection = SettingsPage:Section({ Name = "Script", Icon = "file-code-2", Side = 1, LayoutOrder = 10 })
ScriptSection:Toggle({
    Name = "Auto Execute on Teleport",
    Flag = "AutoExec",
    Default = false,
    Tooltip = "Automatically execute the script after teleporting to another server",
    Callback = function(v)
        if v and queueteleport then
            queueteleport(autoexec_script)
        elseif v then
            notify("Auto Execute", "Your executor does not support queue_on_teleport", 4)
        end
    end,
})

pcall(function()
    local SM = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/SaveManager.lua")
    SM:SetLibrary(Library)
    SM:IgnoreThemeSettings()
    SM:SetFolder("Samuraa1Hub/SecureTheAirport")
    SM:BuildConfigSection(Window)
    SM:LoadAutoloadConfig()
    syncSettingsFromUI()
    if Library.Flags.AutoExec and queueteleport then
        pcall(function()
            queueteleport(autoexec_script)
        end)
    end
end)

Webhook.startAutoLoop()
end)()

notify("Loaded", "Samuraa1 Hub successfully loaded!", 8)
