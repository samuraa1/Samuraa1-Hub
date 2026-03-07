local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Garden Horizons Script - Changelogs",
    ChangelogText = [[
        Version: 2.5.0
Main Tab:
+ Rewrited Auto Plant - Some Optimization, Added Check If You Have New Seed In Inventory (To Not Restart Auto Plant Toggle), Bug Fixes. So Now Auto Plant Works Perfectly Fine!
+ Added Plant Position Method: Randomized and Custom Set Position
If Custom Set Position Enabled U Will See:
- Get Current Position and Custom Position Input
+ Removed Info About Auto Plant Because Now Its Planting Instanly

+ Added Auto Water + Many Settings For This Feature
+ Added Auto Sprinkler + Many Settings For This Feature

+ Added Tree/Plant Shovel + Many Settings For This Feature
+ Added Fruit Shovel + Many Settings For This Feature


+ Added 'Backpack' Tab, Features:
+ Sell Feature Now In This Tab + Added Skip Favorited In Specific Mode

- Auto Favorite (auto favorite only plants that in backpack, not that on ur garden)
- Plants to Favorite
- Mutations

- Unfavorite Divider
- Plants to Unfavorite
- Refresh Lish
- Unfavorite Selected Plants


Shops Tab:
+ Added Tooltips
+ Now Delay Between Buys For 'Auto Buy Seeds' and 'Auto Buy Gears' Default Is 50 ms
+ Rewrited 'Auto Buy Seeds' and 'Auto Buy Gears'

Miscellaneous Features Tab:
+ Added Set AFK Status (FE)

+ Redeem All Valid Codes: Removed Expired Codes + Removed Info Label + Added Code - CONSOLE

+ Added More Teleports

+ Rewrited Always Render Plot - No More Bugs

+ Added Auto Refresh Daily Quests
+ Added Auto Refresh Weekly Quests

Server Tab:
+ Added Divider

+ Added Info Tab About Visuals and Server Tabs

UI Changes:
+ Fixed Warns In Console About Theme
+ Updated UI Size
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
