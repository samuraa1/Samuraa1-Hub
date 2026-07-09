-- open sourced , because this script is fully vibecoded
-- u can paste this shit ofc


































































































local GAME_ID = 3754482795
local PLACE_ID = 10253248401

if game.GameId ~= GAME_ID and game.PlaceId ~= PLACE_ID then
    game.Players.LocalPlayer:Kick("Game Not Supported. Only Elemental Powers Tycoon Is Supported.")
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
local TweenService = cloneref(game:GetService("TweenService"))

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
local mouse = plr:GetMouse()

local DISCORD_LINK = "https://discord.gg/DPCKQRJmdF"
local DISCORD_JOIN_URL = "https://pastebin.com/raw/iYvRJrSf"
local BOOSTFPS_URL = "https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/BoostFPS.lua"
local CHANGELOGS_URL = "https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/EPT-Changelogs.lua"
local SCRIPT_URL = "https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/EPT.lua"
local FEEDBACK_WEBHOOK = ""

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local DoMagic = Remotes and Remotes:FindFirstChild("DoMagic")
local RequestRebirth = Remotes and Remotes:FindFirstChild("RequestRebirth")
local MainRemote = ReplicatedStorage:FindFirstChild("RemoteEvent")

local execCount = 1
pcall(function()
    local folder, file = "Samuraa1Hub", "Samuraa1Hub/ept-execs.txt"
    if not isfolder(folder) then makefolder(folder) end
    if isfile(file) then execCount = (tonumber(readfile(file)) or 0) + 1 end
    writefile(file, tostring(execCount))
end)
shared._execs = execCount

local Library
local Webhook = {}
local antiAfkConn
local autoLoopRunning = false
local autoPhase = "Idle"
local lastWebhookSend = 0
local lastCollect = 0
local lastBuy = 0
local lastAttack = 0
local lastRebirth = 0
local lastChest = 0
local lastBalloon = 0
local lastHill = 0
local lastHeal = 0
local lastStat = 0
local lastEquipSpell = 0
local webhookAutoLoopStarted = false
local moveBusy = false
local hillBusy = false
local hillReturnCFrame = nil
local originalCollisions = {}
local originalLighting = {}
local flying = false
local flyConnection
local flyBodyGyro
local flyBodyVelocity
local flyInput = { W = false, A = false, S = false, D = false, Up = false, Down = false }
local playerESP = {}
local enemyESP = {}
local worldESP = {}
local defaultFOV = 70
local ToggleRefs = {}

local REBIRTH_SPELLS = {
    { Name = "Dark Flames", Rebirth = 1 },
    { Name = "Draedon's Tech", Rebirth = 5 },
    { Name = "Yoru", Rebirth = 10 },
    { Name = "Plasma Orbs", Rebirth = 15 },
    { Name = "Red Saucer", Rebirth = 30 },
    { Name = "Undead Staff", Rebirth = 99 },
    { Name = "Elysian Beam", Rebirth = 120 },
    { Name = "Bubble Flail", Rebirth = 160 },
    { Name = "Poison Serpent", Rebirth = 220 },
    { Name = "Sonar", Rebirth = 300 },
}

local MYSTERY_POWERS = {
    Fire = { "Fire Sword", "Fire Ball", "Fire Fly", "Fire Bomb", "Comet", "Combust", "Fire Shower" },
    Ice = { "Frost Staff", "Frost Fire Ball", "Ice Disk", "Frost Fire Bomb", "Snow Ball", "Ultracold Aura", "Ice Spikes" },
    Lava = { "Lava Katana", "Lava Ball", "Magma Fists", "Lava Dash", "Volcano Sentry", "Magma Spikes", "Nibiru" },
    Bone = { "Bone Scythe", "Blaster", "Bones Barrage", "Flying Bone", "Bone Surge", "Twin Blasters", "Judgement Blast" },
    Darkness = { "Shadow Sword", "Unseen Hands", "Unseen Barrage", "Dark Duo", "Abyss", "Dark Hold", "Dark Arc" },
    Light = { "Light Saber", "Light Ball", "Light Orbs", "Blinding Light", "Shooting Star", "Light Speed", "Light Beam" },
    Nature = { "Christmas Tree Sword", "Plantoid", "Spore Bombs", "Nature's Blessing", "Nuclear Spore", "Pine Burst", "Nature's Wrath" },
    Thunder = { "Thunder Staff", "Bolt", "Barrage", "Discharge", "Flying Nimbus", "Lightning Strike", "Storm" },
    Earth = { "Tectonic Hammer", "Stone Throw", "Rocks Barrage", "Large Boulder", "Burrow", "Stone Henge", "Earth Spikes" },
    Technology = { "Hyper Sword", "Photon Blast", "Twin-Photon Blast", "Tesla Turret", "Orbital", "Tesseract", "Hyper Slash" },
    Gravity = { "Gravity Katana", "Heavy Infliction", "Tectonic Barrage", "Gravity Orb", "Tectonic Burst", "Zero Gravity", "Gravity Globe" },
    Time = { "Time Scepter", "Temporal Gate", "Warp Barrage", "Tempo Beam", "Time Trap", "Warp Bomb", "Grand Clock" },
    Crystal = { "Crystal Cleaver", "Crystal Mine", "Energy Crash", "Energy Crown", "Crystal Eruption", "Energy Crystal", "Crystal Surge" },
    Venom = { "Venom Blade", "Poison Bullet", "Acid Rain", "Venom Stream", "Hardened Venom", "Poison Demon", "Bubbling Venom" },
    Devil = { "Devil Sword", "Evil Bullet", "Fangs Barrage", "Evil Flash", "Demon Orb", "Demon Lock", "Dark Tsunami" },
    Space = { "Space Gun", "Blackhole Orb", "Moon Splitter", "Asteroid Belt", "Meteor Jam", "Cosmic Remote", "Space Saucer" },
    Water = { "Aqua Trident", "Bubbles", "Jellyfish", "Big Tsunami", "Water Beam", "Bubble Dash" },
    ["Super Sonic"] = { "Sonic Barrage", "Super Sonic Wave", "Sonic Boom", "Sonic Twister", "Rebound Blast", "Rebound Teleport", "Sonic Blaster" },
    Ability = { "Speed Potion", "Portal Potion", "Air Strike", "Jump", "Crate Rain", "Meteor Shower", "Health Potion", "Dash", "Size Toggle", "Rocket Launcher", "Cruel Sun", "Robux Beam" },
    Rebirth = { "Dark Flames", "Draedon's Tech", "Yoru", "Plasma Orbs", "Red Saucer", "Undead Staff", "Elysian Beam", "Bubble Flail", "Poison Serpent", "Sonar" },
}

local MYSTERY_ELEMENTS = {}
for name in pairs(MYSTERY_POWERS) do
    table.insert(MYSTERY_ELEMENTS, name)
end
table.sort(MYSTERY_ELEMENTS)

local Settings = {
    FullAuto = false,
    AutoCollect = false,
    AutoBuy = false,
    AutoHill = false,
    AutoRebirth = false,
    AutoStats = false,
    AutoEquipRebirthSpell = false,
    AutoAttack = false,
    AutoBoss = false,
    AutoChests = false,
    AutoBalloons = false,
    AutoHeal = false,
    AttackPlayers = false,
    SelectedRebirthSpell = "Dark Flames",
    SelectedPowerElement = "Fire",
    SelectedPowerSpell = "Fire Ball",
    StatPriority = "1",
    PlayerESP = true,
    EnemyESP = true,
    ChestESP = true,
    HillESP = true,
    CollectorESP = false,
    ESPDistance = true,
    ESPMaxDistance = 400,
    WalkSpeed = false,
    WalkSpeedValue = 32,
    JumpPower = false,
    JumpPowerValue = 60,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    Fullbright = false,
    CustomFOV = false,
    FOVValue = 70,
    AntiAFK = true,
    WebhookURL = "",
    WebhookAuto = false,
    WebhookInterval = 300,
    WebhookIncludeMoney = true,
    WebhookIncludeRebirth = true,
    WebhookIncludeKills = true,
    WebhookIncludePvPWins = true,
    WebhookIncludeGems = true,
    WebhookIncludePhase = true,
    WebhookIncludePing = true,
    WebhookIncludeUptime = true,
    WebhookIncludeJobId = true,
}

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

local function getExecutorName()
    local ok, a = pcall(function()
        if typeof(identifyexecutor) == "function" then return identifyexecutor() end
    end)
    if ok and type(a) == "string" and a ~= "" then return a end
    local ok2, b = pcall(function()
        if typeof(getexecutorname) == "function" then return getexecutorname() end
    end)
    if ok2 and type(b) == "string" and b ~= "" then return b end
    return "Unknown"
end

local function sendFeedback(message)
    if type(FEEDBACK_WEBHOOK) ~= "string" or FEEDBACK_WEBHOOK == "" then
        return false, "Webhook not configured"
    end
    local payload = HttpService:JSONEncode({
        embeds = {{
            title = "Elemental Powers Tycoon Feedback",
            description = message,
            color = 5814783,
            fields = {
                { name = "User", value = plr.Name, inline = true },
                { name = "User ID", value = tostring(plr.UserId), inline = true },
                { name = "Executor", value = getExecutorName(), inline = true },
            },
            footer = { text = "Samuraa1 Hub Feedback" },
        }},
        username = "Feedback",
    })
    local ok = pcall(function()
        if typeof(request) == "function" then
            request({ Url = FEEDBACK_WEBHOOK, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
        elseif typeof(syn) == "table" and typeof(syn.request) == "function" then
            syn.request({ Url = FEEDBACK_WEBHOOK, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = payload })
        else
            HttpService:PostAsync(FEEDBACK_WEBHOOK, payload, Enum.HttpContentType.ApplicationJson)
        end
    end)
    return ok
end

local function autoOn(key)
    if Settings.FullAuto then
        if key == "AutoCollect"
            or key == "AutoBuy"
            or key == "AutoHill"
            or key == "AutoRebirth"
            or key == "AutoChests"
            or key == "AutoBalloons"
            or key == "AutoHeal" then
            return true
        end
    end
    return Settings[key]
end

local function getCharacter()
    local char = plr.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, hum, hrp
end

local function getMoney()
    local ls = plr:FindFirstChild("leaderstats")
    local money = ls and ls:FindFirstChild("Money")
    return money and money.Value or 0
end

local function getRebirth()
    local ls = plr:FindFirstChild("leaderstats")
    local rebirth = ls and ls:FindFirstChild("Rebirth")
    return rebirth and rebirth.Value or 0
end

local function getKills()
    local ls = plr:FindFirstChild("leaderstats")
    local kills = ls and ls:FindFirstChild("Kills")
    return kills and kills.Value or 0
end

local function getPvPWins()
    local ls = plr:FindFirstChild("leaderstats")
    local wins = ls and ls:FindFirstChild("PvPWins")
    return wins and wins.Value or 0
end

local function getGems()
    local gems = plr:FindFirstChild("Gems")
    return gems and gems.Value or 0
end

local function formatMoney(n)
    n = tonumber(n) or 0
    if n >= 1e12 then return string.format("%.2fT", n / 1e12) end
    if n >= 1e9 then return string.format("%.2fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.2fK", n / 1e3) end
    return tostring(math.floor(n))
end

local function getUptimeText()
    local uptime = math.floor(os.clock() - startTime)
    return string.format("%dm %ds", math.floor(uptime / 60), uptime % 60)
end

local function getPingText()
    local ok, ping = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return ok and (ping .. " ms") or "—"
end

local function getMyTycoon()
    local folder = Workspace:FindFirstChild("Tycoons")
    if not folder then return nil end
    return folder:FindFirstChild(plr.Name)
end

local function getCollectorPart(tycoon)
    tycoon = tycoon or getMyTycoon()
    if not tycoon then return nil end
    local aux = tycoon:FindFirstChild("Auxiliary")
    local collector = aux and aux:FindFirstChild("Collector")
    return collector and collector:FindFirstChild("Collect")
end

local function getSpawnPart(tycoon)
    tycoon = tycoon or getMyTycoon()
    if not tycoon then return nil end
    local aux = tycoon:FindFirstChild("Auxiliary")
    local spawn = aux and aux:FindFirstChild("Spawn")
    if not spawn then return nil end
    if spawn:IsA("BasePart") then return spawn end
    return spawn:FindFirstChildWhichIsA("BasePart", true)
end

local function getHillPart()
    local cp = Workspace:FindFirstChild("Control_Point")
    if not cp then return nil end
    return cp:FindFirstChild("Radius") or cp:FindFirstChild("Point")
end

local function getHillOwner()
    local cp = Workspace:FindFirstChild("Control_Point")
    if not cp then return nil end
    local owner = cp:GetAttribute("Owner")
    if type(owner) == "string" and owner ~= "" then
        return owner
    end
    return nil
end

local function isHillOwnedByMe()
    return getHillOwner() == plr.Name
end

local function getCursorPos()
    if type(_G.GetCursor) == "function" then
        local ok, pos = pcall(_G.GetCursor)
        if ok and typeof(pos) == "Vector3" then
            return pos
        end
    end
    if mouse and mouse.Hit then
        return mouse.Hit.Position
    end
    local cam = Workspace.CurrentCamera
    if cam then
        return cam.CFrame.Position + cam.CFrame.LookVector * 50
    end
    local _, _, hrp = getCharacter()
    return hrp and hrp.Position or Vector3.zero
end

local function touchPart(part)
    local _, _, hrp = getCharacter()
    if not hrp or not part or not part:IsA("BasePart") then
        return false
    end
    local ft = firetouchinterest or (getgenv and getgenv().firetouchinterest)
    if typeof(ft) == "function" then
        local ok = pcall(function()
            ft(hrp, part, 0)
            task.wait()
            ft(hrp, part, 1)
        end)
        return ok
    end
    local old = hrp.CFrame
    hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.05)
    hrp.CFrame = old
    return true
end

local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then
        return false
    end
    local triggered = false
    pcall(function()
        if typeof(fireproximityprompt) == "function" then
            fireproximityprompt(prompt, 1, true)
            triggered = true
        end
    end)
    if not triggered then
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(math.max(prompt.HoldDuration, 0.05))
            prompt:InputHoldEnd()
            triggered = true
        end)
    end
    return triggered
end

local function findPrompt(root, actionFilter)
    if not root then return nil end
    for _, d in root:GetDescendants() do
        if d:IsA("ProximityPrompt") and d.Enabled then
            if not actionFilter or (d.ActionText and d.ActionText:lower():find(actionFilter, 1, true)) then
                return d
            end
        end
    end
    return nil
end

local TWEEN_SPEED = 200

local function tweenTo(pos)
    local _, _, hrp = getCharacter()
    if not hrp or typeof(pos) ~= "Vector3" then return false end
    if moveBusy then return false end
    moveBusy = true
    local ok = pcall(function()
        local goal = CFrame.new(pos + Vector3.new(0, 3, 0))
        local dist = (hrp.Position - pos).Magnitude
        if dist <= 7 then
            hrp.CFrame = goal
            return
        end
        local duration = math.clamp(dist / TWEEN_SPEED, 0.4, 5)
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = goal })
        tween:Play()
        tween.Completed:Wait()
    end)
    moveBusy = false
    return ok
end

local function tpToPart(part)
    if not part then return false end
    local target = part
    if not target:IsA("BasePart") then
        target = part:FindFirstChildWhichIsA("BasePart", true)
    end
    if not target then return false end
    return tweenTo(target.Position)
end

local function getRebirthPercent()
    local gui = plr:FindFirstChild("PlayerGui")
    local hud = gui and gui:FindFirstChild("HUD")
    local upper = hud and hud:FindFirstChild("MiddleUpper")
    local frame = upper and upper:FindFirstChild("1")
    local label = frame and frame:FindFirstChild("TextLabel")
    if label and type(label.Text) == "string" then
        local pct = label.Text:match("(%d+)%s*%%")
        return tonumber(pct) or 0
    end
    return 0
end

local function getRebirthPrompt()
    local tycoon = getMyTycoon()
    local rebirth = tycoon and tycoon:FindFirstChild("Auxiliary") and tycoon.Auxiliary:FindFirstChild("Rebirth")
    if not rebirth then return nil end
    local button = rebirth:FindFirstChild("Button")
    local prompt = button and button:FindFirstChildOfClass("ProximityPrompt")
    if prompt and prompt.Enabled then
        return prompt, button
    end
    return findPrompt(rebirth, "rebirth"), button
end

local function canRebirth()
    local prompt = getRebirthPrompt()
    if prompt then
        return true
    end
    -- fallback: tycoon finished (no buy buttons left)
    return #getOwnedButtons() == 0 and getMyTycoon() ~= nil
end

local function getOwnedButtons()
    local tycoon = getMyTycoon()
    local buttons = {}
    if not tycoon then return buttons end
    local folder = tycoon:FindFirstChild("Buttons")
    if not folder then return buttons end
    for _, model in folder:GetChildren() do
        local btn = model:FindFirstChild("Button")
        if btn and btn:IsA("BasePart") then
            local price = tonumber(model:GetAttribute("Price")) or 0
            table.insert(buttons, {
                model = model,
                button = btn,
                price = price,
                name = model.Name,
            })
        end
    end
    table.sort(buttons, function(a, b)
        return a.price < b.price
    end)
    return buttons
end

local function equipMysterySpell(spellName)
    if not MainRemote or type(spellName) ~= "string" or spellName == "" then
        return false
    end
    local ok = pcall(function()
        MainRemote:FireServer("equip_mystery_spell", spellName)
    end)
    return ok
end

local function getSpellInfo(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local magic = ReplicatedStorage:FindFirstChild("Magic")
    if not magic then return nil end
    local spell = magic:FindFirstChild(tool.Name, true)
    if not spell then return nil end
    local category = spell.Parent
    if not category or category == magic then return nil end
    return category.Name, tool.Name
end

local function getEquippedSpell()
    local char = plr.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local cat, name = getSpellInfo(tool)
        if cat then return cat, name, tool end
    end
    return nil
end

local function ensureSpellEquipped()
    local cat, name = getEquippedSpell()
    if cat then return cat, name end
    local backpack = plr:FindFirstChild("Backpack")
    if not backpack then return nil end
    for _, tool in backpack:GetChildren() do
        if tool:IsA("Tool") then
            local c, n = getSpellInfo(tool)
            if c then
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function()
                        hum:EquipTool(tool)
                    end)
                    task.wait(0.1)
                    return c, n
                end
            end
        end
    end
    return nil
end

local function fireMagicAt(position)
    if not DoMagic then return false end
    local category, spell = ensureSpellEquipped()
    if not category then return false end
    local cam = Workspace.CurrentCamera
    local ok = pcall(function()
        DoMagic:FireServer(category, spell, {
            Mouse = position or getCursorPos(),
            Camera = cam and cam.CFrame or CFrame.new(),
        })
    end)
    return ok
end

local function getEnemyModels()
    local list = {}
    local chars = Workspace:FindFirstChild("Characters")
    local enemies = chars and chars:FindFirstChild("Enemies")
    if enemies then
        for _, model in enemies:GetDescendants() do
            if model:IsA("Model") then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                if hum and hrp and hum.Health > 0 then
                    table.insert(list, { model = model, hum = hum, hrp = hrp, isBoss = model.Name:lower():find("boss") ~= nil or model.Name == "Boss" })
                end
            end
        end
    end
    return list
end

local function getPlayerTargets()
    local list = {}
    local chars = Workspace:FindFirstChild("Characters")
    local playersFolder = chars and chars:FindFirstChild("Players")
    local source = playersFolder or Workspace
    for _, other in Players:GetPlayers() do
        if other ~= plr then
            local model = (playersFolder and playersFolder:FindFirstChild(other.Name)) or other.Character
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                if hum and hrp and hum.Health > 0 then
                    table.insert(list, { model = model, hum = hum, hrp = hrp, player = other })
                end
            end
        end
    end
    return list
end

local function nearestTarget(preferBoss)
    local _, _, hrp = getCharacter()
    if not hrp then return nil end
    local best, bestDist
    local range = 1e9

    local function consider(entry)
        local dist = (entry.hrp.Position - hrp.Position).Magnitude
        if dist <= range and (not bestDist or dist < bestDist) then
            if preferBoss and not entry.isBoss and best and best.isBoss then
                return
            end
            best = entry
            bestDist = dist
        end
    end

    for _, e in getEnemyModels() do
        if preferBoss then
            if e.isBoss then consider(e) end
        else
            consider(e)
        end
    end
    if preferBoss and not best then
        for _, e in getEnemyModels() do
            consider(e)
        end
    end
    if Settings.AttackPlayers then
        for _, p in getPlayerTargets() do
            consider(p)
        end
    end
    return best, bestDist
end

-- ===================== AUTOMATION =====================

local function doAutoCollect()
    if not autoOn("AutoCollect") then return end
    if os.clock() - lastCollect < 1.25 then return end
    local part = getCollectorPart()
    local _, _, hrp = getCharacter()
    if not part or not hrp then return end
    lastCollect = os.clock()
    autoPhase = "Collecting"
    local dist = (hrp.Position - part.Position).Magnitude
    if dist > 8 then
        tweenTo(part.Position)
        task.wait(0.2)
    end
    touchPart(part)
end

local function doAutoBuy()
    if not autoOn("AutoBuy") then return end
    if os.clock() - lastBuy < 0.85 then return end
    local money = getMoney()
    local buttons = getOwnedButtons()
    for _, entry in buttons do
        if entry.price <= money then
            lastBuy = os.clock()
            autoPhase = "Buying " .. entry.name
            local _, _, hrp = getCharacter()
            local dist = hrp and (hrp.Position - entry.button.Position).Magnitude or 999
            if dist > 8 then
                tweenTo(entry.button.Position)
                task.wait(0.2)
            end
            touchPart(entry.button)
            return
        end
    end
end

local function doAutoHill()
    if not autoOn("AutoHill") then return end
    if hillBusy then return end
    if os.clock() - lastHill < 1.5 then return end

    if isHillOwnedByMe() then
        autoPhase = "Hill Secured"
        return
    end

    local hill = getHillPart()
    local _, _, hrp = getCharacter()
    if not hill or not hrp then return end

    lastHill = os.clock()
    hillBusy = true
    autoPhase = "Capturing Hill"
    hillReturnCFrame = hrp.CFrame

    task.spawn(function()
        local ok, err = pcall(function()
            tweenTo(hill.Position)
            local deadline = os.clock() + 8
            while os.clock() < deadline do
                if isHillOwnedByMe() then
                    break
                end
                local _, _, hrp2 = getCharacter()
                if hrp2 and (hrp2.Position - hill.Position).Magnitude > 10 then
                    tweenTo(hill.Position)
                else
                    touchPart(hill)
                end
                task.wait(0.35)
            end

            if isHillOwnedByMe() and hillReturnCFrame then
                autoPhase = "Returning From Hill"
                local _, _, hrp3 = getCharacter()
                if hrp3 then
                    local returnPos = hillReturnCFrame.Position
                    tweenTo(returnPos)
                end
                autoPhase = "Hill Secured"
            else
                autoPhase = "Hill Contest"
            end
        end)
        if not ok then
            warn("[EPT] AutoHill:", err)
        end
        hillBusy = false
        hillReturnCFrame = nil
        lastHill = os.clock()
    end)
end

local function doAutoRebirth()
    if not autoOn("AutoRebirth") then return end
    if os.clock() - lastRebirth < 2 then return end
    local prompt, button = getRebirthPrompt()
    if not prompt and not canRebirth() then return end
    if not prompt then
        prompt, button = getRebirthPrompt()
    end
    if not prompt then return end
    lastRebirth = os.clock()
    autoPhase = "Rebirthing"
    if RequestRebirth then
        pcall(function()
            RequestRebirth:FireServer()
        end)
    end
    if button and button:IsA("BasePart") then
        tweenTo(button.Position)
        task.wait(0.15)
    elseif prompt.Parent and prompt.Parent:IsA("BasePart") then
        tweenTo(prompt.Parent.Position)
        task.wait(0.15)
    end
    triggerPrompt(prompt)
end

local function doAutoStats()
    if not Settings.AutoStats or not MainRemote then return end
    if os.clock() - lastStat < 0.5 then return end
    local idx = tonumber(Settings.StatPriority) or 1
    idx = math.clamp(idx, 1, 4)
    lastStat = os.clock()
    pcall(function()
        MainRemote:FireServer("add_point", idx)
    end)
end

local function doAutoEquipRebirthSpell()
    if not Settings.AutoEquipRebirthSpell or not MainRemote then return end
    if os.clock() - lastEquipSpell < 3 then return end
    local rebirths = getRebirth()
    local chosen = Settings.SelectedRebirthSpell
    local best
    for _, spell in REBIRTH_SPELLS do
        if spell.Rebirth <= rebirths then
            if spell.Name == chosen or not best or spell.Rebirth > best.Rebirth then
                if spell.Name == chosen and spell.Rebirth <= rebirths then
                    best = spell
                    break
                end
                best = spell
            end
        end
    end
    if chosen then
        for _, spell in REBIRTH_SPELLS do
            if spell.Name == chosen and spell.Rebirth <= rebirths then
                best = spell
                break
            end
        end
    end
    if not best then return end
    lastEquipSpell = os.clock()
    pcall(function()
        MainRemote:FireServer("equip_rebirth_spell", best.Name)
    end)
end

local function doAutoAttack(preferBoss)
    if preferBoss then
        if not Settings.AutoBoss then return end
    elseif not Settings.AutoAttack then
        return
    end
    if os.clock() - lastAttack < 0.15 then return end
    local target = nearestTarget(preferBoss)
    if not target then return end
    lastAttack = os.clock()
    autoPhase = preferBoss and "Boss Farm" or "Attacking"
    fireMagicAt(target.hrp.Position)
end

local function doAutoChests()
    if not autoOn("AutoChests") then return end
    if os.clock() - lastChest < 1.2 then return end
    local treasure = Workspace:FindFirstChild("Treasure")
    local chests = treasure and treasure:FindFirstChild("Chests")
    if not chests then return end
    local _, _, hrp = getCharacter()
    if not hrp then return end
    local best, bestDist
    for _, chest in chests:GetChildren() do
        local prompt = findPrompt(chest)
        local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart", true)
        if prompt and part then
            local dist = (part.Position - hrp.Position).Magnitude
            if not bestDist or dist < bestDist then
                best, bestDist = chest, dist
            end
        end
    end
    if not best then return end
    lastChest = os.clock()
    autoPhase = "Looting Chest"
    local part = best:IsA("BasePart") and best or best:FindFirstChildWhichIsA("BasePart", true)
    local prompt = findPrompt(best)
    if part then tweenTo(part.Position) end
    task.wait(0.1)
    if prompt then triggerPrompt(prompt) end
end

local function doAutoBalloons()
    if not autoOn("AutoBalloons") then return end
    if os.clock() - lastBalloon < 1.5 then return end
    local _, _, hrp = getCharacter()
    if not hrp then return end
    local best, bestDist, bestPrompt, bestPart
    for _, model in Workspace:GetChildren() do
        if model.Name == "BalloonCrate" then
            local prompt = findPrompt(model)
            local part = model:FindFirstChildWhichIsA("BasePart", true)
            if prompt and part then
                local dist = (part.Position - hrp.Position).Magnitude
                if not bestDist or dist < bestDist then
                    best, bestDist, bestPrompt, bestPart = model, dist, prompt, part
                end
            end
        end
    end
    if not best then return end
    lastBalloon = os.clock()
    autoPhase = "Balloon Crate"
    tweenTo(bestPart.Position)
    task.wait(0.1)
    triggerPrompt(bestPrompt)
end

local function doAutoHeal()
    if not autoOn("AutoHeal") then return end
    if os.clock() - lastHeal < 3 then return end
    local _, hum = getCharacter()
    if not hum or hum.Health >= hum.MaxHealth * 0.7 then return end
    local tycoon = getMyTycoon()
    local heal = tycoon and tycoon:FindFirstChild("Assets") and tycoon.Assets:FindFirstChild("Heal")
    local prompt = findPrompt(heal, "heal")
    if not prompt then return end
    lastHeal = os.clock()
    autoPhase = "Healing"
    local part = prompt.Parent
    if part and part:IsA("BasePart") then
        tweenTo(part.Position)
        task.wait(0.1)
    end
    triggerPrompt(prompt)
end

local function runAutoTick()
    syncSettingsFromUI()
    doAutoCollect()
    doAutoBuy()
    doAutoHill()
    doAutoRebirth()
    doAutoStats()
    doAutoEquipRebirthSpell()
    doAutoHeal()
    doAutoChests()
    doAutoBalloons()
    if Settings.AutoBoss then
        doAutoAttack(true)
    end
    if Settings.AutoAttack then
        doAutoAttack(false)
    end
end

local function startAutoLoop()
    if autoLoopRunning then return end
    autoLoopRunning = true
    task.spawn(function()
        while autoLoopRunning do
            syncSettingsFromUI()
            local active = Settings.FullAuto
                or Settings.AutoCollect
                or Settings.AutoBuy
                or Settings.AutoHill
                or Settings.AutoRebirth
                or Settings.AutoStats
                or Settings.AutoEquipRebirthSpell
                or Settings.AutoAttack
                or Settings.AutoBoss
                or Settings.AutoChests
                or Settings.AutoBalloons
                or Settings.AutoHeal
            if active then
                pcall(runAutoTick)
            else
                autoPhase = "Idle"
            end
            task.wait(0.45)
        end
    end)
end

-- ===================== LOCAL / VISUALS =====================

local function setupAntiAfk()
    if antiAfkConn then
        antiAfkConn:Disconnect()
        antiAfkConn = nil
    end
    if not Settings.AntiAFK then return end
    antiAfkConn = plr.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

local function setNoclip(enabled)
    if not enabled then
        for part, value in pairs(originalCollisions) do
            if part and part.Parent then part.CanCollide = value end
        end
        table.clear(originalCollisions)
        return
    end
    local char = plr.Character
    if not char then return end
    for _, part in char:GetDescendants() do
        if part:IsA("BasePart") and originalCollisions[part] == nil then
            originalCollisions[part] = part.CanCollide
            part.CanCollide = false
        end
    end
end

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    local _, hum = getCharacter()
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local _, hum, hrp = getCharacter()
    if not hum or not hrp then return end
    stopFly()
    flying = true
    hum.PlatformStand = true
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9000
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = hrp
    flyConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Fly or not flying then return end
        local _, hum2, hrp2 = getCharacter()
        if not hum2 or not hrp2 then stopFly() return end
        local cam = Workspace.CurrentCamera
        local move = Vector3.zero
        if flyInput.W then move += cam.CFrame.LookVector end
        if flyInput.S then move -= cam.CFrame.LookVector end
        if flyInput.A then move -= cam.CFrame.RightVector end
        if flyInput.D then move += cam.CFrame.RightVector end
        if flyInput.Up then move += Vector3.yAxis end
        if flyInput.Down then move -= Vector3.yAxis end
        if move.Magnitude > 0 then move = move.Unit * Settings.FlySpeed end
        flyBodyGyro.CFrame = cam.CFrame
        flyBodyVelocity.Velocity = move
    end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then flyInput.W = true end
    if input.KeyCode == Enum.KeyCode.A then flyInput.A = true end
    if input.KeyCode == Enum.KeyCode.S then flyInput.S = true end
    if input.KeyCode == Enum.KeyCode.D then flyInput.D = true end
    if input.KeyCode == Enum.KeyCode.Space then flyInput.Up = true end
    if input.KeyCode == Enum.KeyCode.LeftControl then flyInput.Down = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then flyInput.W = false end
    if input.KeyCode == Enum.KeyCode.A then flyInput.A = false end
    if input.KeyCode == Enum.KeyCode.S then flyInput.S = false end
    if input.KeyCode == Enum.KeyCode.D then flyInput.D = false end
    if input.KeyCode == Enum.KeyCode.Space then flyInput.Up = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then flyInput.Down = false end
end)

local function setFullbright(enabled)
    if enabled then
        if not originalLighting.saved then
            originalLighting.Brightness = Lighting.Brightness
            originalLighting.ClockTime = Lighting.ClockTime
            originalLighting.FogEnd = Lighting.FogEnd
            originalLighting.GlobalShadows = Lighting.GlobalShadows
            originalLighting.Ambient = Lighting.Ambient
            originalLighting.saved = true
        end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    elseif originalLighting.saved then
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.Ambient = originalLighting.Ambient
        originalLighting.saved = false
    end
end

RunService.Heartbeat:Connect(function()
    local _, hum = getCharacter()
    if hum then
        if Settings.WalkSpeed then
            hum.WalkSpeed = Settings.WalkSpeedValue
        end
        if Settings.JumpPower then
            pcall(function()
                hum.UseJumpPower = true
                hum.JumpPower = Settings.JumpPowerValue
            end)
            pcall(function()
                hum.JumpHeight = Settings.JumpPowerValue / 3
            end)
        end
    end
    if Settings.Noclip then
        setNoclip(true)
    end
    if Settings.CustomFOV and Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = Settings.FOVValue
    end
end)

plr.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Settings.Fly then startFly() end
    if Settings.Noclip then setNoclip(true) end
end)

-- ===================== ESP =====================

local function clearCacheEntry(cache, key)
    local entry = cache[key]
    if not entry then return end
    if entry.gui then pcall(function() entry.gui:Destroy() end) end
    if entry.highlight then pcall(function() entry.highlight:Destroy() end) end
    if entry.destroyConn then pcall(function() entry.destroyConn:Disconnect() end) end
    cache[key] = nil
end

local function clearCache(cache)
    for key in pairs(cache) do
        clearCacheEntry(cache, key)
    end
end

local function ensureBillboard(model, text, color, cache, useHighlight)
    local adornee
    if model:IsA("BasePart") then
        adornee = model
    elseif model:IsA("Model") then
        adornee = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart", true)
    end
    if not adornee or not model.Parent then return end

    local entry = cache[model]
    if not entry then
        entry = {}
        cache[model] = entry

        local gui = Instance.new("BillboardGui")
        gui.Name = "Samuraa1ESP"
        gui.Adornee = adornee
        gui.AlwaysOnTop = true
        gui.LightInfluence = 0
        gui.MaxDistance = Settings.ESPMaxDistance
        gui.Size = UDim2.fromOffset(200, 40)
        gui.StudsOffset = Vector3.new(0, 2.6, 0)
        gui.Parent = model

        local bg = Instance.new("Frame")
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
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -8, 1, 0)
        label.Position = UDim2.fromOffset(4, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
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
            highlight.Name = "Samuraa1ESP"
            highlight.Adornee = model:IsA("Model") and model or adornee
            highlight.FillTransparency = 0.65
            highlight.OutlineTransparency = 0
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = model:IsA("Model") and model or adornee
            entry.highlight = highlight
        end

        entry.destroyConn = model.Destroying:Connect(function()
            clearCacheEntry(cache, model)
        end)
    end

    if entry.label then
        entry.label.Text = text
        entry.label.TextColor3 = color
    end
    if entry.stroke then entry.stroke.Color = color end
    if entry.gui then entry.gui.MaxDistance = Settings.ESPMaxDistance end
    if entry.highlight then
        entry.highlight.FillColor = color
        entry.highlight.OutlineColor = color
    end
end

local function updateESP()
    local _, _, hrp = getCharacter()
    local origin = hrp and hrp.Position or Vector3.zero

    local function distText(pos)
        if not Settings.ESPDistance then return "" end
        return string.format(" [%dm]", math.floor((pos - origin).Magnitude))
    end

    local seenPlayers = {}
    if Settings.PlayerESP then
        for _, entry in getPlayerTargets() do
            seenPlayers[entry.model] = true
            local name = entry.player and entry.player.Name or entry.model.Name
            ensureBillboard(entry.model, name .. distText(entry.hrp.Position), Color3.fromRGB(80, 180, 255), playerESP, true)
        end
    end
    for model in pairs(playerESP) do
        if not seenPlayers[model] or not Settings.PlayerESP then
            clearCacheEntry(playerESP, model)
        end
    end

    local seenEnemies = {}
    if Settings.EnemyESP then
        for _, entry in getEnemyModels() do
            seenEnemies[entry.model] = true
            local label = string.format("%s %.0f/%.0f%s", entry.model.Name, entry.hum.Health, entry.hum.MaxHealth, distText(entry.hrp.Position))
            local color = entry.isBoss and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 160, 60)
            ensureBillboard(entry.model, label, color, enemyESP, true)
        end
    end
    for model in pairs(enemyESP) do
        if not seenEnemies[model] or not Settings.EnemyESP then
            clearCacheEntry(enemyESP, model)
        end
    end

    local seenWorld = {}
    if Settings.ChestESP then
        local treasure = Workspace:FindFirstChild("Treasure")
        local chests = treasure and treasure:FindFirstChild("Chests")
        if chests then
            for _, chest in chests:GetChildren() do
                local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    seenWorld[chest] = true
                    ensureBillboard(chest, "Chest" .. distText(part.Position), Color3.fromRGB(255, 215, 80), worldESP, false)
                end
            end
        end
    end
    if Settings.HillESP then
        local hill = getHillPart()
        if hill then
            local cp = Workspace:FindFirstChild("Control_Point")
            if cp then
                seenWorld[cp] = true
                ensureBillboard(cp, "Hill +50%" .. distText(hill.Position), Color3.fromRGB(120, 255, 120), worldESP, true)
            end
        end
    end
    if Settings.CollectorESP then
        local collect = getCollectorPart()
        if collect then
            seenWorld[collect] = true
            ensureBillboard(collect, "Collector" .. distText(collect.Position), Color3.fromRGB(100, 255, 180), worldESP, false)
        end
    end
    for model in pairs(worldESP) do
        if not seenWorld[model] then
            clearCacheEntry(worldESP, model)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(updateESP)
    end
end)

-- ===================== WEBHOOK =====================

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
    local fields = {
        { name = "Player", value = plr.Name, inline = true },
    }

    if Settings.WebhookIncludeMoney then
        table.insert(fields, { name = "Money", value = formatMoney(getMoney()), inline = true })
    end
    if Settings.WebhookIncludeRebirth then
        table.insert(fields, { name = "Rebirth", value = tostring(getRebirth()) .. " (" .. tostring(getRebirthPercent()) .. "%)", inline = true })
    end
    if Settings.WebhookIncludeKills then
        table.insert(fields, { name = "Kills", value = tostring(getKills()), inline = true })
    end
    if Settings.WebhookIncludePvPWins then
        table.insert(fields, { name = "PvP Wins", value = tostring(getPvPWins()), inline = true })
    end
    if Settings.WebhookIncludeGems then
        table.insert(fields, { name = "Gems", value = tostring(getGems()), inline = true })
    end
    if Settings.WebhookIncludePhase then
        table.insert(fields, { name = "Phase", value = autoPhase, inline = true })
    end
    if Settings.WebhookIncludePing then
        table.insert(fields, { name = "Ping", value = getPingText(), inline = true })
    end
    if Settings.WebhookIncludeUptime then
        table.insert(fields, { name = "Uptime", value = getUptimeText(), inline = true })
    end
    if Settings.WebhookIncludeJobId then
        table.insert(fields, { name = "JobId", value = game.JobId, inline = false })
    end

    return {
        embeds = {{
            title = "Elemental Powers Tycoon — Report",
            color = 5814783,
            fields = fields,
            timestamp = getWebhookTimestamp(),
            footer = { text = "Samuraa1 Hub — Elemental Powers Tycoon" },
        }},
        username = "EPT Hub",
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
    if not silent then
        if ok then
            notify("Webhook", "Message sent successfully", 3)
        else
            notify("Webhook", "Failed to send: " .. tostring(err), 4)
        end
    end
    if ok then
        lastWebhookSend = tick()
    end
    return ok, err
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
            syncSettingsFromUI()
            pcall(function()
                tryAutoWebhook(tick())
            end)
        end
    end)
end

-- ===================== UI =====================

local libraryOk, libraryErr = pcall(function()
    Library = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/Library.lua")
end)
if not libraryOk then
    warn("[EPT Hub] Library load failed:", libraryErr)
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
        SubName = "Elemental Powers Tycoon | v1.0.0",
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
        GameName = "ELEMENTAL POWERS TYCOON",
        GameDescription = "Welcome to one of the best Elemental Powers Tycoon scripts!\nEnjoy tons of features waiting for you",
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

    Window:Category("Game")
    Window:TabDivider()

    local AutoPage = Window:Page({ Name = "Automation", Icon = "bot" })
    local CombatPage = Window:Page({ Name = "Combat", Icon = "swords" })
    local PowersPage = Window:Page({ Name = "Powers", Icon = "wand" })
    local ESPPage = Window:Page({ Name = "ESP", Icon = "eye" })
    local TeleportPage = Window:Page({ Name = "Teleports", Icon = "map-pin" })
    local LocalPage = Window:Page({ Name = "Local Player", Icon = "user-round" })
    local WebhookPage = Window:Page({ Name = "Webhook", Icon = "webhook" })
    local ServerPage = Window:Page({ Name = "Server", Icon = "globe" })

    DashPage:AddCard({ Name = "AUTOMATION", Description = "Collect, buy, hill, rebirth", Icon = "bot", Tab = AutoPage })
    DashPage:AddCard({ Name = "COMBAT", Description = "Auto attack and boss farm", Icon = "swords", Tab = CombatPage })
    DashPage:AddCard({ Name = "POWERS", Description = "Equip any elemental power", Icon = "wand", Tab = PowersPage })
    DashPage:AddCard({ Name = "ESP", Description = "Players, enemies, chests", Icon = "eye", Tab = ESPPage })
    DashPage:AddCard({ Name = "TELEPORTS", Description = "Tycoon, hill, arena", Icon = "map-pin", Tab = TeleportPage })
    DashPage:AddCard({ Name = "LOCAL", Description = "Movement and player", Icon = "user-round", Tab = LocalPage })
    DashPage:AddCard({ Name = "WEBHOOK", Description = "Discord reports", Icon = "webhook", Tab = WebhookPage })
    DashPage:AddCard({ Name = "SERVER", Description = "Hop, rejoin, JobId", Icon = "globe", Tab = ServerPage })

    -- Automation
    local FullAutoSection = AutoPage:Section({ Name = "Full Auto", Icon = "sparkles", Side = 1, LayoutOrder = 0 })
    local StatusSection = AutoPage:Section({ Name = "Status", Icon = "chart-bar", Side = 2, LayoutOrder = 0 })
    local TycoonSection = AutoPage:Section({ Name = "Tycoon", Icon = "building-2", Side = 1, LayoutOrder = 1 })
    local ProgressSection = AutoPage:Section({ Name = "Progression", Icon = "trending-up", Side = 2, LayoutOrder = 1 })
    local WorldFarmSection = AutoPage:Section({ Name = "World Farm", Icon = "globe", Side = 1, LayoutOrder = 2 })

    local PhaseLabel = StatusSection:Label("Phase: Idle")
    local MoneyLabel = StatusSection:Label("Money: —")
    local RebirthLabel = StatusSection:Label("Rebirth: —")
    local RebirthPctLabel = StatusSection:Label("Rebirth %: —")
    local ButtonsLabel = StatusSection:Label("Buttons left: —")

    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                PhaseLabel:SetText("Phase: " .. autoPhase)
                MoneyLabel:SetText("Money: " .. formatMoney(getMoney()))
                RebirthLabel:SetText("Rebirth: " .. tostring(getRebirth()))
                RebirthPctLabel:SetText("Rebirth %: " .. tostring(getRebirthPercent()) .. "%")
                ButtonsLabel:SetText("Buttons left: " .. tostring(#getOwnedButtons()))
            end)
        end
    end)

    ToggleRefs.FullAuto = FullAutoSection:Toggle({
        Name = "Full Auto",
        Flag = "FullAuto",
        Default = false,
        Tooltip = "Collect + buy + hill + rebirth + chests + balloons + heal",
        Callback = function(v)
            Settings.FullAuto = v
            autoPhase = v and "Starting" or "Idle"
            if v then notify("Full Auto", "Enabled — sit back.", 3) end
        end,
    })
    FullAutoSection:Keybind({
        Name = "Full Auto Key",
        Flag = "FullAutoKey",
        Default = Enum.KeyCode.F,
        SyncFlag = "FullAuto",
        Callback = function()
            if ToggleRefs.FullAuto then
                ToggleRefs.FullAuto:Set(not Library.Flags.FullAuto)
            end
        end,
    })

    ToggleRefs.AutoCollect = TycoonSection:Toggle({ Name = "Auto Collect", Flag = "AutoCollect", Default = false, Tooltip = "Tween to collector and pick up cash", Callback = function(v) Settings.AutoCollect = v end })
    TycoonSection:Keybind({
        Name = "Auto Collect Key",
        Flag = "AutoCollectKey",
        Default = Enum.KeyCode.C,
        SyncFlag = "AutoCollect",
        Callback = function()
            if ToggleRefs.AutoCollect then
                ToggleRefs.AutoCollect:Set(not Library.Flags.AutoCollect)
            end
        end,
    })
    ToggleRefs.AutoBuy = TycoonSection:Toggle({ Name = "Auto Buy", Flag = "AutoBuy", Default = false, Tooltip = "Buy cheapest affordable buttons", Callback = function(v) Settings.AutoBuy = v end })
    TycoonSection:Keybind({
        Name = "Auto Buy Key",
        Flag = "AutoBuyKey",
        Default = Enum.KeyCode.B,
        SyncFlag = "AutoBuy",
        Callback = function()
            if ToggleRefs.AutoBuy then
                ToggleRefs.AutoBuy:Set(not Library.Flags.AutoBuy)
            end
        end,
    })
    ToggleRefs.AutoHill = TycoonSection:Toggle({ Name = "Auto Capture Hill", Flag = "AutoHill", Default = false, Tooltip = "Capture hill if not yours, then return. Skips while you already own it", Callback = function(v) Settings.AutoHill = v end })
    TycoonSection:Keybind({
        Name = "Auto Hill Key",
        Flag = "AutoHillKey",
        Default = Enum.KeyCode.H,
        SyncFlag = "AutoHill",
        Callback = function()
            if ToggleRefs.AutoHill then
                ToggleRefs.AutoHill:Set(not Library.Flags.AutoHill)
            end
        end,
    })

    ProgressSection:Toggle({ Name = "Auto Rebirth", Flag = "AutoRebirth", Default = false, Tooltip = "Rebirth when the Rebirth prompt appears (HUD % can be wrong)", Callback = function(v) Settings.AutoRebirth = v end })
    ProgressSection:Toggle({ Name = "Auto Spend Skill Points", Flag = "AutoStats", Default = false, Tooltip = "Spend rebirth skill points", Callback = function(v) Settings.AutoStats = v end })
    ProgressSection:Dropdown({
        Name = "Stat Slot",
        Flag = "StatPriority",
        Items = { "1", "2", "3", "4" },
        Default = "1",
        Tooltip = "Which skill point index to upgrade",
        Callback = function(v) Settings.StatPriority = tostring(v) end,
    })
    ProgressSection:Toggle({ Name = "Auto Equip Rebirth Spell", Flag = "AutoEquipRebirthSpell", Default = false, Callback = function(v) Settings.AutoEquipRebirthSpell = v end })

    local spellNames = {}
    for _, s in REBIRTH_SPELLS do
        table.insert(spellNames, s.Name)
    end
    ProgressSection:Dropdown({
        Name = "Rebirth Spell",
        Flag = "SelectedRebirthSpell",
        Items = spellNames,
        Default = "Dark Flames",
        Callback = function(v) Settings.SelectedRebirthSpell = v end,
    })
    ProgressSection:Button({
        Name = "Equip Selected Spell",
        Icon = "wand",
        Callback = function()
            if not MainRemote then return end
            pcall(function()
                MainRemote:FireServer("equip_rebirth_spell", Settings.SelectedRebirthSpell)
            end)
            notify("Spell", "Tried to equip " .. tostring(Settings.SelectedRebirthSpell), 2)
        end,
    })

    WorldFarmSection:Toggle({ Name = "Auto Chests", Flag = "AutoChests", Default = false, Callback = function(v) Settings.AutoChests = v end })
    WorldFarmSection:Toggle({ Name = "Auto Balloon Crates", Flag = "AutoBalloons", Default = false, Callback = function(v) Settings.AutoBalloons = v end })
    WorldFarmSection:Toggle({ Name = "Auto Heal Pad", Flag = "AutoHeal", Default = false, Callback = function(v) Settings.AutoHeal = v end })

    -- Combat
    local CombatSection = CombatPage:Section({ Name = "Combat", Icon = "swords", Side = 1, LayoutOrder = 0 })

    CombatSection:Toggle({ Name = "Auto Attack", Flag = "AutoAttack", Default = false, Tooltip = "Cast equipped magic at nearest target", Callback = function(v) Settings.AutoAttack = v end })
    CombatSection:Toggle({ Name = "Auto Boss Farm", Flag = "AutoBoss", Default = false, Tooltip = "Prefer boss enemies", Callback = function(v) Settings.AutoBoss = v end })
    CombatSection:Toggle({ Name = "Attack Players", Flag = "AttackPlayers", Default = false, Callback = function(v) Settings.AttackPlayers = v end })
    CombatSection:Button({
        Name = "Cast Once (cursor)",
        Icon = "crosshair",
        Callback = function()
            if fireMagicAt(getCursorPos()) then
                notify("Combat", "Spell fired.", 2)
            else
                notify("Combat", "Equip an elemental tool first.", 3)
            end
        end,
    })

    -- Powers
    local PowerEquipSection = PowersPage:Section({ Name = "Equip Any Power", Icon = "wand", Side = 1, LayoutOrder = 0 })
    local PowerQuickSection = PowersPage:Section({ Name = "Quick", Icon = "zap", Side = 2, LayoutOrder = 0 })

    if not MYSTERY_POWERS[Settings.SelectedPowerElement] then
        Settings.SelectedPowerElement = MYSTERY_ELEMENTS[1] or "Fire"
    end
    local initialSpells = MYSTERY_POWERS[Settings.SelectedPowerElement] or { "Fire Ball" }
    if not table.find(initialSpells, Settings.SelectedPowerSpell) then
        Settings.SelectedPowerSpell = initialSpells[1]
    end

    local SpellDropdown
    PowerEquipSection:Dropdown({
        Name = "Element",
        Flag = "SelectedPowerElement",
        Items = MYSTERY_ELEMENTS,
        Default = Settings.SelectedPowerElement,
        Tooltip = "Element category for mystery spell equip",
        Callback = function(v)
            Settings.SelectedPowerElement = v
            local spells = MYSTERY_POWERS[v] or {}
            if SpellDropdown and SpellDropdown.Refresh then
                SpellDropdown:Refresh(spells)
            end
            if #spells > 0 then
                Settings.SelectedPowerSpell = spells[1]
                if SpellDropdown and SpellDropdown.Set then
                    SpellDropdown:Set(spells[1], true)
                end
            end
        end,
    })

    SpellDropdown = PowerEquipSection:Dropdown({
        Name = "Power",
        Flag = "SelectedPowerSpell",
        Items = initialSpells,
        Default = Settings.SelectedPowerSpell,
        Tooltip = "Spell to equip via equip_mystery_spell",
        Callback = function(v)
            Settings.SelectedPowerSpell = v
        end,
    })

    PowerEquipSection:Button({
        Name = "Equip Selected Power",
        Icon = "check",
        Tooltip = "FireServer equip_mystery_spell",
        Callback = function()
            local spell = Settings.SelectedPowerSpell
            if Library and Library.Flags and Library.Flags.SelectedPowerSpell then
                spell = Library.Flags.SelectedPowerSpell
                Settings.SelectedPowerSpell = spell
            end
            if equipMysterySpell(spell) then
                notify("Powers", "Equipped " .. tostring(spell), 2)
            else
                notify("Powers", "Failed to equip", 3)
            end
        end,
    })

    PowerQuickSection:Button({
        Name = "Equip All From Element",
        Icon = "layers",
        Tooltip = "Equip every power listed under the selected element",
        Callback = function()
            local element = Settings.SelectedPowerElement
            local spells = MYSTERY_POWERS[element]
            if not spells then
                notify("Powers", "No spells for element", 3)
                return
            end
            task.spawn(function()
                for _, spell in ipairs(spells) do
                    equipMysterySpell(spell)
                    task.wait(0.15)
                end
                notify("Powers", "Equipped " .. element .. " set", 3)
            end)
        end,
    })

    -- ESP
    local ESPPlayers = ESPPage:Section({ Name = "Targets", Icon = "users", Side = 1, LayoutOrder = 0 })
    local ESPWorld = ESPPage:Section({ Name = "World", Icon = "map", Side = 2, LayoutOrder = 0 })

    ESPPlayers:Toggle({ Name = "Player ESP", Flag = "PlayerESP", Default = true, Callback = function(v)
        Settings.PlayerESP = v
        if not v then clearCache(playerESP) end
    end })
    ESPPlayers:Toggle({ Name = "Enemy / Boss ESP", Flag = "EnemyESP", Default = true, Callback = function(v)
        Settings.EnemyESP = v
        if not v then clearCache(enemyESP) end
    end })
    ESPPlayers:Toggle({ Name = "ESP Distance", Flag = "ESPDistance", Default = true, Callback = function(v) Settings.ESPDistance = v end })
    ESPPlayers:Slider({ Name = "ESP Max Distance", Flag = "ESPMaxDistance", Min = 50, Max = 1000, Default = 400, Callback = function(v)
        Settings.ESPMaxDistance = v
    end })

    ESPWorld:Toggle({ Name = "Chest ESP", Flag = "ChestESP", Default = true, Callback = function(v) Settings.ChestESP = v end })
    ESPWorld:Toggle({ Name = "Hill ESP", Flag = "HillESP", Default = true, Callback = function(v) Settings.HillESP = v end })
    ESPWorld:Toggle({ Name = "Collector ESP", Flag = "CollectorESP", Default = false, Callback = function(v) Settings.CollectorESP = v end })

    -- Teleports
    local TPMain = TeleportPage:Section({ Name = "Quick TP", Icon = "map-pin", Side = 1, LayoutOrder = 0 })
    local TPExtra = TeleportPage:Section({ Name = "Extras", Icon = "compass", Side = 2, LayoutOrder = 0 })

    TPMain:Button({ Name = "TP Tycoon Spawn", Icon = "home", Callback = function()
        if tpToPart(getSpawnPart()) then notify("TP", "Tycoon spawn", 2) else notify("TP", "No tycoon found", 3) end
    end })
    TPMain:Keybind({
        Name = "TP Spawn Key",
        Flag = "TPSpawnKey",
        Default = Enum.KeyCode.T,
        Callback = function()
            if tpToPart(getSpawnPart()) then notify("TP", "Tycoon spawn", 2) end
        end,
    })
    TPMain:Button({ Name = "TP Collector", Icon = "coins", Callback = function()
        if tpToPart(getCollectorPart()) then notify("TP", "Collector", 2) else notify("TP", "No collector", 3) end
    end })
    TPMain:Button({ Name = "TP Hill", Icon = "flag", Callback = function()
        if tpToPart(getHillPart()) then notify("TP", "Control Point", 2) else notify("TP", "Hill missing", 3) end
    end })
    TPMain:Keybind({
        Name = "TP Hill Key",
        Flag = "TPHillKey",
        Default = Enum.KeyCode.Y,
        Callback = function()
            if tpToPart(getHillPart()) then notify("TP", "Control Point", 2) end
        end,
    })
    TPMain:Button({ Name = "TP Ability Room", Icon = "sparkles", Callback = function()
        local room = Workspace:FindFirstChild("AbilityRoom")
        local arrive = room and room:FindFirstChild("Arrive")
        if tpToPart(arrive) then notify("TP", "Ability Room", 2) end
    end })

    TPExtra:Button({ Name = "TP Battle Arena", Icon = "swords", Callback = function()
        local arena = Workspace:FindFirstChild("BattleArena")
        if tpToPart(arena) then notify("TP", "Arena", 2) end
    end })
    TPExtra:Button({ Name = "TP PvP Queue", Icon = "users", Callback = function()
        local q = Workspace:FindFirstChild("PvpQueue")
        if tpToPart(q) then notify("TP", "PvP Queue", 2) end
    end })
    TPExtra:Button({ Name = "TP Nearest Chest", Icon = "box", Callback = function()
        local treasure = Workspace:FindFirstChild("Treasure")
        local chests = treasure and treasure:FindFirstChild("Chests")
        local _, _, hrp = getCharacter()
        if not chests or not hrp then return end
        local best, bestDist
        for _, chest in chests:GetChildren() do
            local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local d = (part.Position - hrp.Position).Magnitude
                if not bestDist or d < bestDist then best, bestDist = part, d end
            end
        end
        if best then tpToPart(best) end
    end })

    -- Local
    local SpeedSection = LocalPage:Section({ Name = "Movement", Icon = "gauge", Side = 1, LayoutOrder = 0 })
    local VisualSection = LocalPage:Section({ Name = "Visuals", Icon = "sun", Side = 2, LayoutOrder = 0 })
    local MiscLocalSection = LocalPage:Section({ Name = "Misc", Icon = "settings", Side = 2, LayoutOrder = 1 })

    SpeedSection:Toggle({ Name = "WalkSpeed", Flag = "WalkSpeed", Default = false, Callback = function(v) Settings.WalkSpeed = v end })
    SpeedSection:Slider({ Name = "Speed Value", Flag = "WalkSpeedValue", Min = 16, Max = 200, Default = 32, Callback = function(v) Settings.WalkSpeedValue = v end })
    SpeedSection:Toggle({ Name = "JumpPower", Flag = "JumpPower", Default = false, Callback = function(v) Settings.JumpPower = v end })
    SpeedSection:Slider({ Name = "Jump Value", Flag = "JumpPowerValue", Min = 50, Max = 300, Default = 60, Callback = function(v) Settings.JumpPowerValue = v end })
    ToggleRefs.Noclip = SpeedSection:Toggle({
        Name = "Noclip",
        Flag = "Noclip",
        Default = false,
        Callback = function(v)
            Settings.Noclip = v
            if not v then setNoclip(false) end
        end,
    })
    SpeedSection:Keybind({
        Name = "Noclip Key",
        Flag = "NoclipKey",
        Default = Enum.KeyCode.N,
        SyncFlag = "Noclip",
        Callback = function()
            if ToggleRefs.Noclip then
                ToggleRefs.Noclip:Set(not Library.Flags.Noclip)
            end
        end,
    })
    ToggleRefs.Fly = SpeedSection:Toggle({
        Name = "Fly",
        Flag = "Fly",
        Default = false,
        Tooltip = "WASD + Space / Ctrl",
        Callback = function(v)
            Settings.Fly = v
            if v then startFly() else stopFly() end
        end,
    })
    SpeedSection:Keybind({
        Name = "Fly Key",
        Flag = "FlyKey",
        Default = Enum.KeyCode.G,
        SyncFlag = "Fly",
        Callback = function()
            if ToggleRefs.Fly then
                ToggleRefs.Fly:Set(not Library.Flags.Fly)
            end
        end,
    })
    SpeedSection:Slider({ Name = "Fly Speed", Flag = "FlySpeed", Min = 20, Max = 200, Default = 50, Callback = function(v) Settings.FlySpeed = v end })

    VisualSection:Toggle({
        Name = "Fullbright",
        Flag = "Fullbright",
        Default = false,
        Callback = function(v)
            Settings.Fullbright = v
            setFullbright(v)
        end,
    })
    VisualSection:Toggle({
        Name = "Custom FOV",
        Flag = "CustomFOV",
        Default = false,
        Callback = function(v)
            Settings.CustomFOV = v
            if not v and Workspace.CurrentCamera then
                Workspace.CurrentCamera.FieldOfView = defaultFOV
            end
        end,
    })
    VisualSection:Slider({ Name = "FOV", Flag = "FOVValue", Min = 50, Max = 120, Default = 70, Callback = function(v) Settings.FOVValue = v end })

    MiscLocalSection:Toggle({
        Name = "Anti-AFK",
        Flag = "AntiAFK",
        Default = true,
        Callback = function(v)
            Settings.AntiAFK = v
            setupAntiAfk()
        end,
    })

    -- Webhook
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

    WebhookFieldsSection:Toggle({ Name = "Include Money", Flag = "WebhookIncludeMoney", Default = true, Tooltip = "Send your money balance", Callback = function(v) Settings.WebhookIncludeMoney = v end })
    WebhookFieldsSection:Toggle({ Name = "Include Rebirth", Flag = "WebhookIncludeRebirth", Default = true, Tooltip = "Send rebirth count and percent", Callback = function(v) Settings.WebhookIncludeRebirth = v end })
    WebhookFieldsSection:Toggle({ Name = "Include Kills", Flag = "WebhookIncludeKills", Default = true, Tooltip = "Send kill count", Callback = function(v) Settings.WebhookIncludeKills = v end })
    WebhookFieldsSection:Toggle({ Name = "Include PvP Wins", Flag = "WebhookIncludePvPWins", Default = true, Tooltip = "Send PvP wins", Callback = function(v) Settings.WebhookIncludePvPWins = v end })
    WebhookFieldsSection:Toggle({ Name = "Include Gems", Flag = "WebhookIncludeGems", Default = true, Tooltip = "Send gem count", Callback = function(v) Settings.WebhookIncludeGems = v end })
    WebhookFieldsSection:Toggle({ Name = "Include Phase", Flag = "WebhookIncludePhase", Default = true, Tooltip = "Send current auto phase", Callback = function(v) Settings.WebhookIncludePhase = v end })
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

    -- Server
    local ServerMain = ServerPage:Section({ Name = "Server", Icon = "globe", Side = 1, LayoutOrder = 0 })
    local ServerInfo = ServerPage:Section({ Name = "Info", Icon = "info", Side = 2, LayoutOrder = 0 })

    ServerMain:Button({
        Name = "Rejoin Server",
        Icon = "refresh-cw",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
        end,
    })
    ServerMain:Button({
        Name = "Server Hop",
        Icon = "shuffle",
        Callback = function()
            local ok, servers = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(
                    ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PLACE_ID)
                ))
            end)
            if not ok or not servers or not servers.data then
                notify("Hop", "Failed to fetch servers", 3)
                return
            end
            for _, server in servers.data do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, server.id, plr)
                    return
                end
            end
            notify("Hop", "No other servers found", 3)
        end,
    })
    ServerMain:Divider("JobId")
    ServerMain:Textbox({ Flag = "JobIdInput", Default = "", Numeric = false, Placeholder = "Enter JobId here...", Finished = false })
    ServerMain:Button({
        Name = "Join by JobId",
        Icon = "log-in",
        Callback = function()
            local val = Library.Flags.JobIdInput
            if not val or val == "" then
                notify("Error", "Please enter a JobId", 3)
                return
            end
            TeleportService:TeleportToPlaceInstance(PLACE_ID, val, plr)
        end,
    })
    ServerMain:Button({
        Name = "Copy JobId",
        Icon = "copy",
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

    local autoexec_script = ("loadstring(game:HttpGet('%s'))()"):format(SCRIPT_URL)

    pcall(function()
        local TM = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/ThemeManager.lua")
        TM:SetLibrary(Library)
        TM:SetFolder("Samuraa1Hub")
        TM:BuildThemeSection(SettingsPage)
        TM:LoadDefault()
    end)

    local FeedbackSection = SettingsPage:Section({ Name = "Feedback", Icon = "messages-square", Side = 1, LayoutOrder = -100 })
    local FeedbackInput = FeedbackSection:Textbox({
        Flag = "FeedbackText",
        Default = "",
        Numeric = false,
        Placeholder = "Your message…",
        Finished = false,
    })
    FeedbackSection:Button({
        Name = "Send message",
        Icon = "send",
        Callback = function()
            local msg = Library.Flags.FeedbackText
            if not msg or #msg == 0 then
                notify("Empty", "Type something first", 3)
                return
            end
            local ok = sendFeedback(msg)
            if ok then
                notify("Sent", "Thanks for the feedback", 3)
                FeedbackInput:Set("")
            else
                notify("Not sent", "Could not send feedback", 3)
            end
        end,
    })

    local ScriptSection = SettingsPage:Section({ Name = "Script", Icon = "file-code-2", Side = 1, LayoutOrder = 10 })
    ScriptSection:Toggle({
        Name = "Auto Execute on Teleport",
        Flag = "AutoExec",
        Default = false,
        Callback = function(v)
            if v and queueteleport then
                queueteleport(autoexec_script)
            elseif v then
                notify("Auto Execute", "Executor does not support queue_on_teleport", 4)
            end
        end,
    })

    pcall(function()
        local SM = loadRemoteLua("https://raw.githubusercontent.com/samuraa1/MentalityUI/main/SaveManager.lua")
        SM:SetLibrary(Library)
        SM:IgnoreThemeSettings()
        SM:SetFolder("Samuraa1Hub/ElementalPowersTycoon")
        SM:BuildConfigSection(Window)
        SM:LoadAutoloadConfig()
        syncSettingsFromUI()
        if Library.Flags.AutoExec and queueteleport then
            pcall(function()
                queueteleport(autoexec_script)
            end)
        end
    end)

    setupAntiAfk()
    startAutoLoop()
    Webhook.startAutoLoop()
    notify("Loaded", "Samuraa1 Hub Loaded!", 6)
end)()
