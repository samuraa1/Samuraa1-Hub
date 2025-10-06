local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Restaurant Tycoon 3 Script - Changelogs",
    ChangelogText = [[
        Version: 1.5.0
        + Added Boost FPS In Home Tab

+ Added Auto Collect Drop Money/Food Critic
+ Change Restaurant Name
+ Updated Redeem All Valid Codes
+ Added Info Label For Restaurant Upgrades
+ Added Franchise Restaurant Upgrade

+ Added Features In Farm Tab:
- Select Crops to Plant
- Auto Plant Crops
- Auto Harvest Crops
- Destroy All Crops

- Teleport to Farm In This Tab Now

+ Added Visuals Tab, Features:
- Infinite Cash
- Infinite Cash On Leaderstats
- Infinite Diamonds

- Change Ambient
- Fullbright
- Auto Change Night To Day
- Auto Change Day To Night

- Players Chams
- No Fog

+ Added Teleport To Private Server

+ Another UI Default Size
+ Disabled The Custom Cursor
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
