local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Expedition Antarctica Script - Changelogs",
    ChangelogText = [[
        Version: 3.1.0
+ Some Optimizations

+ Added Logo
+ Added Compact Mode For Sidebar
+ Removed Custom Cursor
+ Updated Footer
+ Updated UI Size
+ Added Another Default Theme

+ Changed Icon For Welcome GroupBox
+ Added Feedback In Home Tab
+ Added Boost FPS In Home Tab

+ Removed Inf Camera Zoom
+ Added Reset Camera Zoom

+ Fully Rewrited Auto Farm Expeditions:
+ Added Loop Count
+ Added Jump Pause Before Teleport
+ Added Jump Resume After Teleport
+ Added Waiting Time At Spawn

+ Added Infinite Coins
+ Added Auto Change Day To Night

+ Added Info Label About Coin Farm In Vulnerabilities Tab
+ Added Dividers In Boosts GroupBox

+ Added Server Info GroupBox In Server Tab, Features:
- Players: Players On The Server / Maximum Players
- PlaceId Label
- Ping Label
- Session Time Label

+ Updated Executions Tracker
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
