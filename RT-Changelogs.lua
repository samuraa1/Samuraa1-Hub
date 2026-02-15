local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Raft Tycoon Script - Changelogs",
    ChangelogText = [[
        Version: 1.1.0
        + Updated Feedback

+ Renamed 'Auto Farm' GroupBox to 'Automation'

+ Optimized Auto Collect Money
+ Rewrited Auto Buy - Optimized + Added Check How Many Money U Have (If U Doesnt Have Money To Buy Button - Button Will Not Be Teleported To U) + Button Now Teleporting Near Head

+ Rewrited Walk On Water - No More Bugs
+ Added Auto Complete Parkour

+ All Codes In 'Redeem All Valid Codes' Are Working

+ Added Teleports GroupBox, Features:
- Teleport to Spawn
- Teleport to Leaderstats
- Teleport to Parkour
- Teleport to PVP + Mob

+ Rewrited Fly - Added Mobile Support + Fly Keybind Is F Now + Another Method + Way Better Now

+ Added Visuals Tab, Features:
- Infinite Money

- Enable Ambient
- Fullbright

- Box ESP
- Tracers
- Names
- Distance
- Players Chams

- No Shadows

- X-Ray

+ Added Auto Execute
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
