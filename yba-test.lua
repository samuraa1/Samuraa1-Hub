local PLACE_ID = 2809202155
local GAME_NAME = "Your Bizarre Adventure"

if game.PlaceId ~= PLACE_ID then
    local earlyPlayer = game:GetService("Players").LocalPlayer
    if earlyPlayer then
        earlyPlayer:Kick("Game Not Supported. Only Your Bizarre Adventure Is Supported.")
    end
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))
local Stats = cloneref(game:GetService("Stats"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local HttpService = cloneref(game:GetService("HttpService"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))

local LocalPlayer = Players.LocalPlayer

local HOSTILE = {
    ["Security Guard"] = true,
    ["Thug"] = true,
    ["Alpha Thug"] = true,
    ["Vampire"] = true,
    ["Zombie Henchman"] = true,
    ["Corrupt Police"] = true,
}

local DEFAULT_WALK_SPEED = 16
local DEFAULT_JUMP_HEIGHT = 7.2
local DEFAULT_FOV = 70

local function httpGetString(url, retries)
    retries = retries or 4
    for attempt = 1, retries do
        local ok, result = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and type(result) == "string" and #result > 0 then
            return result
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

local execCount = 1
pcall(function()
    if typeof(isfolder) ~= "function" then return end
    local folder, file = "Samuraa1Hub", "Samuraa1Hub/yba-execs.txt"
    if not isfolder(folder) then makefolder(folder) end
    if isfile(file) then
        execCount = (tonumber(readfile(file)) or 0) + 1
    end
    writefile(file, tostring(execCount))
end)
shared._execs = execCount

local DISCORD_LINK = "https://discord.gg/DPCKQRJmdF"
local DISCORD_JOIN_URL = "https://pastebin.com/raw/iYvRJrSf"

getgenv().AutoFarm = false
getgenv().AutoPickup = false
getgenv().MobHighlights = false
getgenv().ItemHighlights = false
getgenv().WalkSpeedEnabled = false
getgenv().WalkSpeedValue = 24
getgenv().JumpHeightValue = 7
getgenv().InfiniteJump = false
getgenv().FOVValue = DEFAULT_FOV
getgenv().AttackRange = 7
getgenv().SwingDelay = 0.45
getgenv().ChaseDistance = 600
getgenv().PreferLowHP = false
getgenv().SameLocation = true
getgenv().ItemFilter = ""
getgenv().FarmMobs = {
    ["Security Guard"] = true,
    Thug = true,
    ["Alpha Thug"] = true,
    Vampire = true,
    ["Zombie Henchman"] = true,
    ["Corrupt Police"] = true,
}

local Library
local function notify(title, description, duration)
    if not Library then return end
    pcall(function()
        Library:Notification({
            Title = title,
            Description = description,
            Duration = duration or 3,
            Icon = "97594400820219",
        })
    end)
end

local lastNotice = {}
local function note(key, title, text)
    local now = os.clock()
    if lastNotice[key] and now - lastNotice[key] < 8 then return end
    lastNotice[key] = now
    notify(title, text, 3)
end

local farmStatusText = "Target: —"
local pickupStatusText = "Item: —"
local function setFarmStatus(text)
    farmStatusText = text
end
local function setPickupStatus(text)
    pickupStatusText = text
end

local function getCharacter()
    local character = LocalPlayer.Character
    if not character then return nil, nil, nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
        return character, humanoid, root
    end
    return nil, nil, nil
end

local function statValue(name)
    local folder = LocalPlayer:FindFirstChild("PlayerStats")
    local value = folder and folder:FindFirstChild(name)
    if value and value:IsA("ValueBase") then
        return value.Value
    end
    return nil
end

local function statText(name)
    local value = statValue(name)
    if value == nil then return "—" end
    return tostring(value)
end

local function playerLocation(character)
    local location = character:FindFirstChild("Location")
    if location and location:IsA("ObjectValue") then
        return location.Value
    end
    return nil
end

local function clampNumber(value, fallback, minValue, maxValue)
    local number = tonumber(value)
    if not number then number = fallback end
    return math.clamp(number, minValue, maxValue)
end

local function attackRange()
    return clampNumber(getgenv().AttackRange, 7, 4, 16)
end

local function swingDelay()
    return clampNumber(getgenv().SwingDelay, 0.45, 0.25, 1.2)
end

local function chaseDistance()
    return clampNumber(getgenv().ChaseDistance, 600, 40, 600)
end

local function mobAllowed(name)
    if not HOSTILE[name] then return false end
    local flags = getgenv().FarmMobs
    if type(flags) ~= "table" or flags[name] == nil then
        return true
    end
    return flags[name] == true
end

local function itemFilterText()
    if Library and Library.Flags and type(Library.Flags.ItemFilter) == "string" then
        return Library.Flags.ItemFilter
    end
    return tostring(getgenv().ItemFilter or "")
end

local function itemMatches(prompt)
    local filter = itemFilterText()
    if filter == "" then return true end
    local object = string.lower(prompt.ObjectText or "")
    return string.find(object, string.lower(filter), 1, true) ~= nil
end

local function nearestMob(character, origin)
    local living = Workspace:FindFirstChild("Living")
    if not living then return nil, nil end
    local here = playerLocation(character)
    local limit = chaseDistance()
    local preferLow = getgenv().PreferLowHP == true
    local best, bestDist, bestHp
    for _, model in ipairs(living:GetChildren()) do
        if model:IsA("Model") and mobAllowed(model.Name) and not Players:GetPlayerFromCharacter(model) then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            local location = model:FindFirstChild("Location")
            local samePlace = true
            if getgenv().SameLocation ~= false and here and location and location:IsA("ObjectValue") and location.Value then
                samePlace = location.Value == here
            end
            if samePlace and humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
                local dist = (root.Position - origin).Magnitude
                if dist <= limit then
                    local better = false
                    if not best then
                        better = true
                    elseif preferLow then
                        better = humanoid.Health < bestHp - 0.1 or (math.abs(humanoid.Health - bestHp) < 0.1 and dist < bestDist)
                    else
                        better = dist < bestDist
                    end
                    if better then
                        best = model
                        bestDist = dist
                        bestHp = humanoid.Health
                    end
                end
            end
        end
    end
    return best, bestDist
end

local function itemFolder()
    local spawns = Workspace:FindFirstChild("Item_Spawns")
    return spawns and spawns:FindFirstChild("Items")
end

local function promptAccepted(prompt, mustBeEnabled, ignoreFilter)
    if not (prompt and prompt:IsA("ProximityPrompt") and prompt.ActionText == "Pick Up") then
        return false
    end
    if prompt.Parent == Workspace then
        return false
    end
    if mustBeEnabled and not prompt.Enabled then
        return false
    end
    if not ignoreFilter and not itemMatches(prompt) then
        return false
    end
    return true
end

local function findPickupPrompt(model, mustBeEnabled, ignoreFilter)
    if not model then return nil end
    if model:IsA("ProximityPrompt") and promptAccepted(model, mustBeEnabled, ignoreFilter) then
        return model
    end
    for _, child in ipairs(model:GetChildren()) do
        if promptAccepted(child, mustBeEnabled, ignoreFilter) then
            return child
        end
        if child:IsA("BasePart") or child:IsA("Attachment") or child:IsA("Model") then
            local prompt = child:FindFirstChildOfClass("ProximityPrompt")
            if promptAccepted(prompt, mustBeEnabled, ignoreFilter) then
                return prompt
            end
        end
    end
    return nil
end

local function promptPosition(prompt, model)
    local parent = prompt.Parent
    if parent and parent:IsA("BasePart") then
        return parent.Position
    end
    if parent and parent:IsA("Attachment") and parent.Parent and parent.Parent:IsA("BasePart") then
        return parent.Parent.Position
    end
    local part = model:FindFirstChildWhichIsA("BasePart")
    return part and part.Position or nil
end

local function nearestPickup(origin)
    local folder = itemFolder()
    if not (folder and origin) then return nil, nil, nil, nil end
    local best, bestDist, bestPrompt, bestPos
    for _, model in ipairs(folder:GetChildren()) do
        local prompt = findPickupPrompt(model, false)
        local position = prompt and promptPosition(prompt, model)
        if prompt and position then
            local dist = (position - origin).Magnitude
            if not bestDist or dist < bestDist then
                best = model
                bestDist = dist
                bestPrompt = prompt
                bestPos = position
            end
        end
    end
    return best, bestDist, bestPrompt, bestPos
end

local function face(root, point)
    local flat = Vector3.new(point.X, root.Position.Y, point.Z)
    if (flat - root.Position).Magnitude < 0.05 then return end
    root.CFrame = CFrame.lookAt(root.Position, flat)
end

local function stopWalking()
    local _, humanoid, root = getCharacter()
    if humanoid and root then
        humanoid:MoveTo(root.Position)
    end
end

local function swing(character)
    local remote = character:FindFirstChild("RemoteEvent")
    if not (remote and remote:IsA("RemoteEvent")) then
        return false
    end
    local downOk = pcall(function()
        remote:FireServer("HoldAttack", { Bool = true, Type = "m1" })
    end)
    task.wait(0.06)
    if not remote.Parent then return false end
    local upOk = pcall(function()
        remote:FireServer("HoldAttack", { Bool = false, Type = "m1" })
    end)
    return downOk and upOk
end

local function firePrompt(prompt)
    if not (prompt and prompt.Parent and prompt:IsA("ProximityPrompt") and prompt.Enabled) then
        return false
    end
    if typeof(fireproximityprompt) == "function" then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then return true end
    end
    local hold = prompt.HoldDuration
    pcall(function()
        if hold ~= 0 then prompt.HoldDuration = 0 end
        prompt:InputHoldBegin()
    end)
    task.wait()
    pcall(function()
        if prompt.Parent then prompt:InputHoldEnd() end
        if hold ~= 0 and prompt.Parent then prompt.HoldDuration = hold end
    end)
    return prompt.Parent ~= nil
end

local farmRunning = false
local function setAutoFarm(enabled)
    getgenv().AutoFarm = enabled
    if not enabled then
        stopWalking()
        setFarmStatus("Target: —")
    end
    if farmRunning then return end
    farmRunning = true
    task.spawn(function()
        local stuck = 0
        local lastDist = math.huge
        while getgenv().AutoFarm do
            local character, humanoid, root = getCharacter()
            if not character then
                setFarmStatus("Target: waiting for character")
                task.wait(0.4)
            else
                local _, pickupDist = nearestPickup(root.Position)
                local mob, dist = nearestMob(character, root.Position)
                local leaveIt = getgenv().AutoPickup and pickupDist and pickupDist < 25 and (not dist or pickupDist < dist)
                if not mob then
                    setFarmStatus("Target: no street mob in range")
                    note("farm", "Auto Farm", "No street mob matches the filters.")
                    stuck = 0
                    lastDist = math.huge
                    task.wait(0.5)
                else
                    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                    local mobHum = mob:FindFirstChildOfClass("Humanoid")
                    if not (mobRoot and mobHum and mobHum.Health > 0) then
                        task.wait(0.25)
                    else
                        dist = (mobRoot.Position - root.Position).Magnitude
                        setFarmStatus(string.format("Target: %s  %d HP  %d studs", mob.Name, math.floor(mobHum.Health), math.floor(dist)))
                        if dist > attackRange() then
                            if not leaveIt then
                                humanoid:MoveTo(mobRoot.Position)
                                if dist > lastDist - 1 then
                                    stuck = stuck + 1
                                    if stuck >= 4 then
                                        humanoid.Jump = true
                                        stuck = 0
                                    end
                                else
                                    stuck = 0
                                end
                            end
                            lastDist = dist
                            task.wait(0.25)
                        else
                            stuck = 0
                            lastDist = dist
                            face(root, mobRoot.Position)
                            local ok = swing(character)
                            if not ok then
                                note("swing", "Auto Farm", "The attack remote is not on the character.")
                            end
                            task.wait(swingDelay())
                        end
                    end
                end
            end
        end
        farmRunning = false
    end)
end

local pickupRunning = false
local function setAutoPickup(enabled)
    getgenv().AutoPickup = enabled
    if not enabled then
        stopWalking()
        setPickupStatus("Item: —")
    end
    if pickupRunning then return end
    pickupRunning = true
    task.spawn(function()
        while getgenv().AutoPickup do
            local _, humanoid, root = getCharacter()
            local folder = itemFolder()
            if not humanoid then
                setPickupStatus("Item: waiting for character")
                task.wait(0.4)
            elseif not folder then
                setPickupStatus("Item: spawn folder missing")
                note("pickup", "Auto Pickup", "Item spawns are not loaded.")
                task.wait(0.5)
            else
                local model, dist, prompt, position = nearestPickup(root.Position)
                if not (model and prompt and position) then
                    local filter = itemFilterText()
                    if filter ~= "" then
                        setPickupStatus("Item: none matching \"" .. filter .. "\"")
                    else
                        setPickupStatus("Item: none on the map")
                    end
                    note("pickup", "Auto Pickup", "No matching Pick Up prompt this cycle.")
                    task.wait(0.5)
                else
                    local reach = math.max(3, (prompt.MaxActivationDistance or 8) - 1)
                    local label = prompt.ObjectText ~= "" and prompt.ObjectText or "item"
                    setPickupStatus(string.format("Item: %s  %d studs", label, math.floor(dist)))
                    if dist > reach then
                        humanoid:MoveTo(position)
                        task.wait(0.25)
                    else
                        face(root, position)
                        if not prompt.Enabled then
                            note("prompt", "Auto Pickup", label .. " is in range, but the prompt is disabled.")
                            task.wait(0.35)
                        elseif not firePrompt(prompt) then
                            note("prompt", "Auto Pickup", "The prompt was gone before the hold finished.")
                            task.wait(0.35)
                        else
                            task.wait(0.45)
                        end
                    end
                end
            end
        end
        pickupRunning = false
    end)
end

local mobHighlights = {}
local itemHighlights = {}

local function clearHighlights(list)
    for host, highlight in pairs(list) do
        if highlight then
            pcall(function()
                highlight:Destroy()
            end)
        end
        if typeof(host) == "Instance" then
            local board = host:FindFirstChild("Samuraa1ItemName")
            if board then
                board:Destroy()
            end
        end
        list[host] = nil
    end
end

local function ensureHighlight(list, host, color, name, alwaysOnTop)
    local existing = list[host]
    if existing and existing.Parent then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = name
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.45
    highlight.OutlineTransparency = 0
    highlight.Adornee = host
    if alwaysOnTop then
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    highlight.Parent = host
    list[host] = highlight
end

local function ensureItemBillboard(host, text)
    local adornee = host:IsA("BasePart") and host or host:FindFirstChildWhichIsA("BasePart")
    if not adornee then return end
    local board = host:FindFirstChild("Samuraa1ItemName")
    if not board then
        board = Instance.new("BillboardGui")
        board.Name = "Samuraa1ItemName"
        board.Size = UDim2.fromOffset(150, 28)
        board.StudsOffset = Vector3.new(0, 3, 0)
        board.AlwaysOnTop = true
        board.MaxDistance = 450
        board.Parent = host
        local label = Instance.new("TextLabel")
        label.Name = "NameLabel"
        label.BackgroundColor3 = Color3.fromRGB(24, 18, 8)
        label.BackgroundTransparency = 0.25
        label.TextColor3 = Color3.fromRGB(255, 214, 120)
        label.TextStrokeTransparency = 0.4
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.Size = UDim2.fromScale(1, 1)
        label.Parent = board
    end
    board.Adornee = adornee
    local label = board:FindFirstChild("NameLabel")
    if label and label:IsA("TextLabel") then
        label.Text = text ~= "" and text or "Item"
    end
end

local mobHighlightRunning = false
local function setMobHighlights(enabled)
    getgenv().MobHighlights = enabled
    if mobHighlightRunning then return end
    if not enabled then
        clearHighlights(mobHighlights)
        return
    end
    mobHighlightRunning = true
    task.spawn(function()
        while getgenv().MobHighlights do
            local living = Workspace:FindFirstChild("Living")
            local seen = {}
            if living then
                for _, model in ipairs(living:GetChildren()) do
                    if model:IsA("Model") and mobAllowed(model.Name) and not Players:GetPlayerFromCharacter(model) then
                        local humanoid = model:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            seen[model] = true
                            ensureHighlight(mobHighlights, model, Color3.fromRGB(255, 90, 90), "Samuraa1MobHL")
                        end
                    end
                end
            end
            for model, highlight in pairs(mobHighlights) do
                if not seen[model] then
                    if highlight then highlight:Destroy() end
                    mobHighlights[model] = nil
                end
            end
            task.wait(0.5)
        end
        clearHighlights(mobHighlights)
        mobHighlightRunning = false
    end)
end

local itemHighlightRunning = false
local function setItemHighlights(enabled)
    getgenv().ItemHighlights = enabled
    if itemHighlightRunning then return end
    if not enabled then
        clearHighlights(itemHighlights)
        return
    end
    itemHighlightRunning = true
    task.spawn(function()
        while getgenv().ItemHighlights do
            local folder = itemFolder()
            local seen = {}
            if folder then
                for _, model in ipairs(folder:GetChildren()) do
                    local prompt = findPickupPrompt(model, false, true)
                    if prompt then
                        seen[model] = true
                        ensureHighlight(itemHighlights, model, Color3.fromRGB(255, 196, 64), "Samuraa1ItemHL", true)
                        ensureItemBillboard(model, prompt.ObjectText)
                    end
                end
            end
            for model, highlight in pairs(itemHighlights) do
                if not seen[model] then
                    if highlight then highlight:Destroy() end
                    itemHighlights[model] = nil
                end
            end
            task.wait(0.5)
        end
        clearHighlights(itemHighlights)
        itemHighlightRunning = false
    end)
end

local movementRunning = false
local function applyMovement()
    local _, humanoid = getCharacter()
    if not humanoid then return end
    if getgenv().WalkSpeedEnabled then
        humanoid.WalkSpeed = tonumber(getgenv().WalkSpeedValue) or DEFAULT_WALK_SPEED
    end
    local jump = tonumber(getgenv().JumpHeightValue) or 7
    if jump > 7 then
        humanoid.JumpHeight = jump
    end
end

local function setWalkSpeed(enabled)
    getgenv().WalkSpeedEnabled = enabled
    if not enabled then
        local _, humanoid = getCharacter()
        if humanoid then
            humanoid.WalkSpeed = DEFAULT_WALK_SPEED
        end
    end
    applyMovement()
    if movementRunning then return end
    movementRunning = true
    task.spawn(function()
        while getgenv().WalkSpeedEnabled or (tonumber(getgenv().JumpHeightValue) or 7) > 7 do
            applyMovement()
            task.wait(0.3)
        end
        movementRunning = false
    end)
end

local afkConn
local function setAntiAfk(enabled)
    if afkConn then
        afkConn:Disconnect()
        afkConn = nil
    end
    if not enabled then return end
    afkConn = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local jumpConn
local function setInfiniteJump(enabled)
    getgenv().InfiniteJump = enabled
    if jumpConn then
        jumpConn:Disconnect()
        jumpConn = nil
    end
    if not enabled then return end
    jumpConn = UserInputService.JumpRequest:Connect(function()
        if not getgenv().InfiniteJump then return end
        local _, humanoid = getCharacter()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function serverHop()
    local url = "https://games.roblox.com/v1/games/" .. tostring(PLACE_ID) .. "/servers/Public?sortOrder=Desc&limit=100"
    local cursor
    repeat
        local ok, raw = pcall(function()
            return game:HttpGet(url .. (cursor and ("&cursor=" .. cursor) or ""))
        end)
        if not ok or type(raw) ~= "string" then
            notify("Server", "Could not load the server list.", 3)
            return
        end
        local okDecode, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if not okDecode or type(decoded) ~= "table" then
            notify("Server", "Could not read the server list.", 3)
            return
        end
        for _, server in ipairs(decoded.data or {}) do
            if type(server) == "table" and server.playing and server.maxPlayers and server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, LocalPlayer)
                return
            end
        end
        cursor = decoded.nextPageCursor
    until not cursor
    notify("Server", "No other public server was open.", 3)
end

Library = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/Library.lua")

local Window = Library:Window({
    Name = "Samuraa1 Hub",
    SubName = GAME_NAME .. " | v1.1.0",
    Logo = "97594400820219",
    MobileScale = UserInputService.TouchEnabled and 0.72 or nil,
})

local KeybindList = (not UserInputService.TouchEnabled) and Library:KeybindList("Keybinds") or nil

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
        {
            Icon = "copy",
            Tooltip = "Copy Discord link",
            Callback = function()
                pcall(function() setclipboard(DISCORD_LINK) end)
                notify("Copied", "Discord link copied.", 2)
            end,
        },
        {
            Icon = "users",
            Tooltip = "Join Discord server",
            Callback = function()
                pcall(function() loadRemoteLua(DISCORD_JOIN_URL) end)
            end,
        },
    },
    GameName = string.upper(GAME_NAME),
    GameDescription = "Welcome to Your Bizarre Adventure.\nThe farm walks to street mobs in your location and swings, then holds item prompts while you are away.\n\nCredits: Samuraa1 (Script Creator), samet (UI Library Creator).",
    Stats = {
        {
            Name = "UPTIME",
            Icon = "clock",
            GetValue = function()
                local ok, t = pcall(function()
                    return math.floor(Workspace.DistributedGameTime)
                end)
                if not ok or not t then return "—" end
                local h = math.floor(t / 3600)
                local m = math.floor((t % 3600) / 60)
                local s = t % 60
                return h > 0 and ("%dh %dm"):format(h, m) or ("%dm %ds"):format(m, s)
            end,
        },
        {
            Name = "PING",
            Icon = "wifi",
            GetValue = function()
                local ok, v = pcall(function()
                    return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                return ok and (v .. " ms") or "—"
            end,
        },
        {
            Name = "EXECS",
            Icon = "terminal",
            GetValue = function()
                return tostring(shared._execs or execCount or 1)
            end,
        },
    },
    Credits = {
        { Name = "Samuraa1", Role = "Script Creator" },
        { Name = "samet", Role = "UI Library Creator" },
    },
    QuickAccess = {},
})

Window:Category("Game")
Window:TabDivider()

local CombatPage = Window:Page({ Name = "Combat", Icon = "swords" })
local ItemsPage = Window:Page({ Name = "Items", Icon = "package" })
local VisualsPage = Window:Page({ Name = "Visuals", Icon = "eye" })
local LocalPage = Window:Page({ Name = "Local Player", Icon = "user-round" })
local ServerPage = Window:Page({ Name = "Server", Icon = "globe" })

local FarmSection = CombatPage:Section({ Name = "Street Mobs", Icon = "swords", Side = 1 })
local CombatStatus = CombatPage:Section({ Name = "You", Icon = "trophy", Side = 2 })

local farmToggle = FarmSection:Toggle({
    Name = "Auto Farm Mobs",
    Flag = "AutoFarm",
    Default = false,
    Tooltip = "Walk to a filtered street mob and use the same M1 the client sends",
    Callback = function(v)
        setAutoFarm(v)
    end,
})
FarmSection:Keybind({
    Name = "Auto Farm Keybind",
    Flag = "AutoFarmBind",
    Default = Enum.KeyCode.V,
    SyncFlag = "AutoFarm",
    Tooltip = "Toggle street mob farm",
    Callback = function()
        if farmToggle then
            farmToggle:Set(not Library.Flags.AutoFarm)
        end
    end,
})
FarmSection:Label("Bosses and story NPCs are left alone. The character walks to the target.")

local FilterSection = CombatPage:Section({ Name = "Filters", Icon = "filter", Side = 1 })
local TimingSection = CombatPage:Section({ Name = "Timing", Icon = "timer", Side = 1 })

FilterSection:Toggle({
    Name = "Same Location Only",
    Flag = "SameLocation",
    Default = true,
    Tooltip = "Only mobs whose Location matches yours",
    Callback = function(v)
        getgenv().SameLocation = v
    end,
})
FilterSection:Toggle({
    Name = "Prefer Lowest HP",
    Flag = "PreferLowHP",
    Default = false,
    Tooltip = "Off keeps the nearest mob. On picks the weakest one in range",
    Callback = function(v)
        getgenv().PreferLowHP = v
    end,
})
for _, mobName in ipairs({ "Security Guard", "Thug", "Alpha Thug", "Vampire", "Zombie Henchman", "Corrupt Police" }) do
    FilterSection:Toggle({
        Name = mobName,
        Flag = "FarmMob_" .. mobName,
        Default = true,
        Tooltip = "Include " .. mobName .. " in the farm",
        Callback = function(v)
            getgenv().FarmMobs[mobName] = v
        end,
    })
end

TimingSection:Slider({
    Name = "Attack Range",
    Flag = "AttackRange",
    Min = 4,
    Max = 16,
    Default = 7,
    Decimals = 1,
    Suffix = " studs",
    Tooltip = "Swing once you are this close",
    Callback = function(v)
        getgenv().AttackRange = v
    end,
})
TimingSection:Slider({
    Name = "Swing Delay",
    Flag = "SwingDelay",
    Min = 0.25,
    Max = 1.2,
    Default = 0.45,
    Decimals = 0.05,
    Suffix = "s",
    Tooltip = "Pause between M1s",
    Callback = function(v)
        getgenv().SwingDelay = v
    end,
})
TimingSection:Slider({
    Name = "Chase Distance",
    Flag = "ChaseDistance",
    Min = 40,
    Max = 600,
    Default = 600,
    Decimals = 10,
    Suffix = " studs",
    Tooltip = "Ignore street mobs farther than this",
    Callback = function(v)
        getgenv().ChaseDistance = v
    end,
})

local levelLabel = CombatStatus:Label("Level: —")
local moneyLabel = CombatStatus:Label("Money: —")
local xpLabel = CombatStatus:Label("Experience: —")
local standLabel = CombatStatus:Label("Stand: —")
local targetLabel = CombatStatus:Label("Target: —")

task.spawn(function()
    while task.wait(0.5) do
        levelLabel:SetText("Level: " .. statText("Level"))
        local money = statValue("Money")
        moneyLabel:SetText("Money: " .. (money == nil and "—" or ("$" .. tostring(money))))
        xpLabel:SetText("Experience: " .. statText("Experience"))
        standLabel:SetText("Stand: " .. statText("Stand"))
        targetLabel:SetText(farmStatusText)
    end
end)

local PickupSection = ItemsPage:Section({ Name = "Pickups", Icon = "package", Side = 1 })
local pickupToggle = PickupSection:Toggle({
    Name = "Auto Pickup",
    Flag = "AutoPickup",
    Default = false,
    Tooltip = "Walk to a spawned Pick Up prompt and hold it",
    Callback = function(v)
        setAutoPickup(v)
    end,
})
PickupSection:Keybind({
    Name = "Auto Pickup Keybind",
    Flag = "AutoPickupBind",
    Default = Enum.KeyCode.B,
    SyncFlag = "AutoPickup",
    Tooltip = "Toggle item pickup",
    Callback = function()
        if pickupToggle then
            pickupToggle:Set(not Library.Flags.AutoPickup)
        end
    end,
})
PickupSection:Label("Uses the item's own prompt. Empty filter means every spawned item. Workspace template prompts are ignored.")
PickupSection:Textbox({
    Name = "Item Name",
    Flag = "ItemFilter",
    Default = "",
    Numeric = false,
    Placeholder = "Arrow, Rokakaka, mask...",
    Finished = true,
    Tooltip = "Only pick up items whose name contains this. Leave empty for all",
    Callback = function(v)
        getgenv().ItemFilter = tostring(v or "")
    end,
})
local itemLabel = PickupSection:Label("Item: —")
task.spawn(function()
    while task.wait(0.5) do
        itemLabel:SetText(pickupStatusText)
    end
end)

local VisualSection = VisualsPage:Section({ Name = "Highlights", Icon = "eye", Side = 1 })
VisualSection:Toggle({
    Name = "Mob Highlights",
    Flag = "MobHighlights",
    Default = false,
    Tooltip = "Outline the street mobs this farm will swing at",
    Callback = function(v)
        setMobHighlights(v)
    end,
})
VisualSection:Toggle({
    Name = "Item Highlights",
    Flag = "ItemHighlights",
    Default = false,
    Tooltip = "Outline spawned items and show their name, even if the prompt is still disabled",
    Callback = function(v)
        setItemHighlights(v)
    end,
})

local GeneralSection = LocalPage:Section({ Name = "General", Icon = "circle-user-round", Side = 1 })
local MovementSection = LocalPage:Section({ Name = "Movement", Icon = "footprints", Side = 2 })
local CameraSection = LocalPage:Section({ Name = "Camera", Icon = "aperture", Side = 1 })

GeneralSection:Toggle({
    Name = "Anti AFK",
    Flag = "AntiAFK",
    Default = true,
    Tooltip = "Presses a click when Roblox marks you idle",
    Callback = setAntiAfk,
})
task.defer(function()
    if Library.Flags.AntiAFK then
        setAntiAfk(true)
    end
end)

local jumpToggle = GeneralSection:Toggle({
    Name = "Infinite Jump",
    Flag = "InfiniteJump",
    Default = false,
    Tooltip = "Jump again in midair",
    Callback = setInfiniteJump,
})
GeneralSection:Keybind({
    Name = "Infinite Jump Keybind",
    Flag = "InfJumpBind",
    Default = Enum.KeyCode.N,
    SyncFlag = "InfiniteJump",
    Tooltip = "Toggle infinite jump",
    Callback = function()
        if jumpToggle then
            jumpToggle:Set(not Library.Flags.InfiniteJump)
        end
    end,
})

MovementSection:Toggle({
    Name = "Walk Speed",
    Flag = "WalkSpeedEnabled",
    Default = false,
    Tooltip = "Keep a custom walk speed. 16 is this game's idle speed",
    Callback = function(v)
        setWalkSpeed(v)
    end,
})
MovementSection:Slider({
    Name = "Walk Speed",
    Flag = "WalkSpeedValue",
    Min = 16,
    Max = 80,
    Default = 24,
    Tooltip = "Speed used while walk speed is on",
    Callback = function(v)
        getgenv().WalkSpeedValue = v
        if getgenv().WalkSpeedEnabled then
            setWalkSpeed(true)
        end
    end,
})
MovementSection:Slider({
    Name = "Jump Height",
    Flag = "JumpHeightValue",
    Min = 7,
    Max = 40,
    Default = 7,
    Tooltip = "7 restores the normal jump. Higher values are kept on",
    Callback = function(v)
        getgenv().JumpHeightValue = v
        local _, humanoid = getCharacter()
        if humanoid then
            humanoid.JumpHeight = v <= 7 and DEFAULT_JUMP_HEIGHT or v
        end
        if v > 7 then
            setWalkSpeed(getgenv().WalkSpeedEnabled)
        end
    end,
})

CameraSection:Slider({
    Name = "Field Of View",
    Flag = "FOVValue",
    Min = 50,
    Max = 120,
    Default = DEFAULT_FOV,
    Suffix = "°",
    Tooltip = "Camera field of view",
    Callback = function(v)
        getgenv().FOVValue = v
        local camera = Workspace.CurrentCamera
        if camera then
            camera.FieldOfView = v
        end
    end,
})

local ServerMain = ServerPage:Section({ Name = "Main", Icon = "terminal", Side = 1 })
local ServerInfo = ServerPage:Section({ Name = "Server Info", Icon = "chart-bar", Side = 2 })

ServerMain:Button({
    Name = "Server Hop",
    Icon = "shuffle",
    Tooltip = "Teleport to another public server with an open slot",
    Callback = serverHop,
})
ServerMain:Button({
    Name = "Rejoin Server",
    Icon = "refresh-cw",
    Tooltip = "Rejoin this server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, game.JobId, LocalPlayer)
    end,
})
ServerMain:Button({
    Name = "Copy JobId",
    Icon = "copy",
    Tooltip = "Copy this server's JobId",
    Callback = function()
        local ok = pcall(setclipboard, game.JobId)
        notify(ok and "Copied" or "Server", ok and "Current JobId copied." or "Clipboard is not available.", 2)
    end,
})

local playersLabel = ServerInfo:Label("Players: 0 / 0")
local jobLabel = ServerInfo:Label("JobId: —")
task.spawn(function()
    while task.wait(1) do
        playersLabel:SetText(("Players: %d / %d"):format(#Players:GetPlayers(), Players.MaxPlayers))
        jobLabel:SetText("JobId: " .. tostring(game.JobId))
    end
end)

Window:TabDivider()
Window:Category("Settings")

DashPage:AddCard({ Name = "COMBAT", Description = "Walk to street mobs and swing", Icon = "swords", Tab = CombatPage })
DashPage:AddCard({ Name = "ITEMS", Description = "Walk to Pick Up prompts", Icon = "package", Tab = ItemsPage })
DashPage:AddCard({ Name = "VISUALS", Description = "Mob and item outlines", Icon = "eye", Tab = VisualsPage })
DashPage:AddCard({ Name = "LOCAL", Description = "Movement and camera", Icon = "user-round", Tab = LocalPage })
DashPage:AddCard({ Name = "SERVER", Description = "Hop, rejoin, JobId", Icon = "globe", Tab = ServerPage })

local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)

pcall(function()
    local ThemeManager = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/ThemeManager.lua")
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("Samuraa1Hub")
    ThemeManager:BuildThemeSection(SettingsPage)
    if type(ThemeManager.LoadDefault) == "function" then
        ThemeManager:LoadDefault()
    elseif type(ThemeManager.ApplySavedDefault) == "function" then
        ThemeManager:ApplySavedDefault()
    end
end)

pcall(function()
    local SaveManager = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/SaveManager.lua")
    SaveManager:SetLibrary(Library)
    if type(SaveManager.IgnoreThemeSettings) == "function" then
        SaveManager:IgnoreThemeSettings()
    end
    SaveManager:SetFolder("Samuraa1Hub/YourBizarreAdventure")
    if type(SaveManager.BuildConfigSection) == "function" then
        SaveManager:BuildConfigSection(Window)
    end
    if type(SaveManager.LoadAutoloadConfig) == "function" then
        SaveManager:LoadAutoloadConfig()
    end
end)

if type(Window.Init) == "function" then
    Window:Init()
end

notify("Loaded", "Samuraa1 Hub — Your Bizarre Adventure", 4)
