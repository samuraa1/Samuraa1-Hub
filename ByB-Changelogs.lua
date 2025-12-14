local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Break your Bones Script - Changelogs",
    ChangelogText = [[
        Version: 1.3.0
        + Added Boost FPS In Home Tab

+ Rewrited Auto Farm Money Again (Now No Bugs With This Feature)
+ Removed Auto Rebirth, Because Devs Removed Rebirths And Replaced Them With Prestige

+ Slam Velocity Minimum Value Now - 250
+ Label In Settings GroupBox Is Remaded

+ Added Teleport To Store
+ Added Teleport To Pals
+ Added Teleport To Spells
+ Added Teleport To Charm
+ Added Teleport To Prestige

+ Fixed Auto Start Quest
+ Fixed Auto Claim Quest

+ Added Pals GroupBox:
- Auto Unlock Pal
- Auto Claim Daily Cookies

+ Added Spells GroupBox:
- Auto Buy Saving Hand I
- Auto Buy Saving Hand II
- Auto Buy Saving Hand III

- Auto Buy Earthquake I
- Auto Buy Earthquake II
- Auto Buy Earthquake III

- Auto Buy Crazy Spin I
- Auto Buy Crazy Spin II
- Auto Buy Crazy Spin III

- Auto Buy Shift I
- Auto Buy Shift II
- Auto Buy Shift III

+ Added Charm GroupBox:
- Auto Start Geko Quest
- Auto Claim Geko Quest

+ Added Prestige GroupBox:
- Auto Prestige
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
