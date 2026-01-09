local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()
Library:CreateChangelogDialog({
    Title = "The Dropper Script - Changelogs",
    ChangelogText = [[
        Version: 1.0.5
        + Added Logo
+ Updated Footer
+ Updated UI Size

+ Rewrited Auto Complete Levels
+ Added Auto Complete Difficulty Chart Levels + Teleport to End
+ Added Auto Rebirth (For Difficulty Chart Levels)

+ Added Teleport To VIP Room
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
