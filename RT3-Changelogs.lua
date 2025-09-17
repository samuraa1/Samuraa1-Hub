local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Restaurant Tycoon 3 Script - Changelogs",
    ChangelogText = [[
        Version: 1.1.0
        + Added Feedback In Home Tab
+ Set FPS Default FPS Is 120 Now

+ Autofarms Is Very Fast Now!
+ Added 'Select Everything' and 'Select Nothing' Buttons For Auto Farm And Restaurant Upgrades GroupBoxes
+ Added Toggle For 'Claim Daily Reward' And Renamed To 'Auto Claim Daily Reward' + Added Auto Collect Objectives
+ Fixed Collect All Scavenger Hunt Items

+ Added Farm Tab (Nothing In It Right Now)

+ Removed 'Inf Camera Zoom' Button In Local Player Tab, Added 'Reset Camera Zoom' Button + Changed Keybind For Fly
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
