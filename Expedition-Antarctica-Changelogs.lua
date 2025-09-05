local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Expedition Antarctica Script - Changelogs",
    ChangelogText = [[
        Version: 3.0.0
[+] Added Tabs
- Home Tab
- Vulnerabilities Tab
- Missions Tab
- Boats Tab
- Server Tab

[+] Home Tab Features
- Welcome Label
- Copy Discord Server Link
- Join Discord Server
- View Changelogs
- Set FPS
- Credits

[+] Local Player Tab (Rewritten All Features)
- Anti AFK
- Infinite Jump (with Keybind)
- Fly
- Noclip (with Keybind)
- WalkSpeed Toggle (with Keybind, Normal & CFrame Methods)
- JumpPower
- Camera Zoom

Also Added Camera GroupBox, Features:
- No Camera Shake
- FOV Changer
- Camera Zoom (Now In This GroupBox)
- Inf Camera Zoom

[+] Visuals Tab
- Rewritten Fullbright

[+] Teleports Tab
- Anti Gameplay Paused

[+] Get Items Tab
- Finally Fixed Get Energy Bar

[+] Vulnerabilities Tab
- Coin Farm (35K+ Coins Per Hour, very OP)
- Spawn Boats For Free (Kayak, Double Kayak, Zodiac)
- Freeze Boosts (Speed, Jump, Tightrope, Fall Resistance, Avalanche, Invincibility)
- Freeze All Selected Boosts
- Change Boosts Time
- Infinite Boosts

[+] Missions Tab
- Auto Unlock Missions
- Teleport To Missions Center
- Missions Autofarm

[+] Boats Tab
- Buy Kayak
- Buy Double Kayak
- Buy Zodiac
- Teleport To Boats Spawn
- Spawn Label

[+] Server Tab
- Server Hop
- Join Small Server
- Rejoin Server
- Join by JobId
- Copy JobId
    ]],
    Search = false,
    NotifyLibrary = "Luna",
    Notifications = true,
    Altbutton = {
        Name = "Join Discord",
        Clipboard = "discord.gg/DPCKQRJmdF"
    },
    Notification = {
        Title = "Changelog",
        Content = "The changelog has been closed.",
        Duration = 3,
        Image = 10723346871
    },
    AltbuttonNotification = {
        Success = {
            Title = "Copied!",
            Content = "Link copied to clipboard.",
            Duration = 5,
            Image = 10709798443
        },
        Failure = {
            Title = "Error",
            Content = "Clipboard not supported.",
            Duration = 5,
            Image = 10709799124
        }
    }
})
