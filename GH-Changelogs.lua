local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Garden Horizons Script - Changelogs",
    ChangelogText = [[
        Version: 2.0.3
+ Rewrited Again Auto Harvest: Some Optimization, Added For All Harvest Features Tooltips, Now If Nothing Selected In Dropdown (In Plants For Example, Then All Plants Will Be Harvested Or If No Mutations Will Be Selected - Then They Will Be Ignored, Same For Variants Dropdown), In Minimum Multiplier Now If You Type 1 - Any Multiplier Will Be Accepted. So Now Auto Harvest Works Perfectly Fine!

+ Added Tooltips For Sell Features
+ Fixed Auto Sell All When Backpack Full
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
