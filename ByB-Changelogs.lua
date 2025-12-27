local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Break your Bones Script - Changelogs",
    ChangelogText = [[
        Version: 1.3.5
        + Added Compact Mode For Sidebar
+ Removed Custom Cursor

+ Added Visuals Tab, Features:
- Infinite Money

- Enable Ambient
- Fullbright
- Auto Change Night To Day
- Auto Change Day To Night

- Box ESP
- Tracers
- Names
- Distance
- Players Chams

- No Shadows

- X-Ray

+ Added Server Info GroupBox In Server Tab, Features:
- Players: Players On The Server / Maximum Players
- PlaceId Label
- Ping Label
- Session Time Label
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
