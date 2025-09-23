local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Break your Bones Script - Changelogs",
    ChangelogText = [[
        Version: 1.2.0
        + Added Auto Spin Character + Spin Speed
+ Added Bypass Gates
+ Removed Tooltips (Useless)

+ task.wait For All Upgrades Is 1 Now, For Auto Purchase Next Ragdoll And Auto Refine Ragdoll Is 2

+ Slam Duration Maximum 60 → 180
+ Added Info Label For Slam Velocity And Slam Duration
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
