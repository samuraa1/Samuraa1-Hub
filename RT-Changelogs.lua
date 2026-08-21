local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Raft Tycoon Script - Changelogs",
    ChangelogText = [[
        Version: 2.0.0
        + Renamed 'Miscellaneous' GroupBox to 'QoL / Safety'

+ Optimized Auto Collect Money - Now Auto Detects New ATMs / Collect Parts (No Need To Re-Enable)

+ Rewrited Auto Buy - Now Smart Auto Buy + Buy Priority (Cheapest First / Most Expensive First / Base First / Droppers First) + Select Zones To Buy (If Zone Disabled - Buttons From This Zone Will Not Be Bought) + Skips Owned & Robux Buttons

+ Rewrited Auto Rebirth - Now Smart Auto Rebirth (Rebirths Only If U Have Enough Money)

+ Added Auto Claim Group Reward
+ Added Auto Open Crate

+ Working Codes: Winter, Shark, Freemoney, 2025, Volcano

+ Added QoL / Safety Features:
- Remove Ads / Popups
- Disable Weather FX
- Instant Interact

+ Added Teleports:
- Teleport to My Tycoon
- TP to Farm
- TP to Hotel
- TP to Military Island
- TP to Tropical Island
- TP to Underwater
- Portal: Base → Map
- Portal: Map → Base

+ Added Info Tab, Features:
- Cash
- Rebirth
- Cash/sec
- Lootbox Timer
- Upgrades Progress
- Remaining Buttons
- Rebirth Threshold
- Friend Bonus
- Players Online

+ Added Visuals:
- Custom Sky
- Shark ESP
- Lootbox ESP
- Infinite Cash (Visual) Toggle
- Infinite Cash On Leaderstats Toggle

+ Added Dividers In Main
+ Rewrote Tooltips
+ Fixed Teleports
+ Replaced Broken Info / Tycoon Icons
+ Fixed Enable Ambient And Fullbright Warns

+ Server Tab:
- Removed Streaming Status
- Added FPS
- Added Session Earned
- Added Cash/Hour

+ Updated Feedback
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
