local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Elemental Powers Tycoon Script - Changelogs",
    ChangelogText = [[
        Version: 1.1.0
        + Improved Auto Capture Hill
+ Optimized some features
etc.

UI:
+ Added Dividers
+ Organized Features
+ Added More Tooltips
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
        Content = "The changelog has been closed",
        Duration = 3,
        Image = 10723346871
    },
    AltbuttonNotification = {
        Success = {
            Title = "Copied!",
            Content = "Link copied to clipboard",
            Duration = 5,
            Image = 10709798443
        },
        Failure = {
            Title = "Error",
            Content = "Clipboard not supported",
            Duration = 5,
            Image = 10709799124
        }
    }
})
