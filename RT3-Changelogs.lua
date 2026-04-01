local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Restaurant Tycoon 3 Script - Changelogs",
    ChangelogText = [[
        Version: 2.0.0
        Main Tab:
+ Removed Home & Info Sections
+ New Codes: easter2026 + UltrawEats
+ New Tab Below Main: Events (Easter Eggs + Ghost Hunt Moved There)
+ Teleport To Campsite Still Here
+ Auto Calm Rude Customer Toggle

Events Tab:
+ Collect All Easter Eggs (16 Eggs) One Button
+ Scavenger Hunt Ghosts Here Now

Misc Tab:
+ Only FPS Cap Slider (Changelogs & Boost FPS — Use Dashboard)
+ More Functions Soon Label

Local Player Tab:
+ Rewrited Anti AFK & Fly

Visuals Tab:
+ Added In Brackets / Notes For Infinite Cash, Rebirth, Diamonds & Leaderstats Stuff
+ Rewrited Fullbright + Ambient
+ Added World Stuff (Day / Night, X-Ray)
+ Added Full ESP (Box, Tracers, Names, Distance) + Chams + No Shadows
+ Removed Old Button Spam — Now Mostly Toggles Like Raft

Server Tab:
+ Added Divider
+ Server Info Shows FPS + Cleaner Labels
+ Optimized All Features

UI Changes:
+ Whole Script On Mentality UI (New Look)
+ Updated Feedback Send Flow
+ Fixed Random Spam / Duplicate Stuff In Settings
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
