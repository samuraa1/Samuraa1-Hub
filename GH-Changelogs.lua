local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnesXVC/librarys/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Garden Horizons Script - Changelogs",
    ChangelogText = [[
        Version: 2.0.0
+ Changed Footer

- Main Tab:
+ Fully Rewrited Auto Harvest and Added:
- Filter Mode
- Harvest Stage
- Minimum Multiplier
- Plants
- Mutations
- Variants

+ Added Auto Plant
+ Dropdown Seeds to Plant: Amberpine, Apple, Banana, Beetroot, Bellpepper, Birch, Cabbage, Carrot, Cherry, Corn, Dandelion, Dawnblossom, Dawnfruit, Emberwood, Goldenberry, Mushroom, Olive, Onion, Orange, Plum, Pomaganit, Potato, Rose, Strawberry, Sunpetal, Tomato, Wheat etc.

+ Added Search For Dropdowns

+ Fully Rewrited Auto Sell and Added:
- Dropdown Mode: Sell All, Specific

If Sell All Mode Enabled:
- Auto Sell
- Auto Sell All When Backpack Full
- Enable Sell Cooldown
- Sell Cooldown Input

If Specific Mode Enabled:
- Auto Sell
- Plants
- Mutations
- Variants

+ Added Tab 'Shops' For Auto Buy Seeds and Auto Buy Gears Features

+ Optimized Auto Buy Seeds (Also Now To Buy Seeds You Will Be Teleported To Bill's Seed Shop)
+ Organized Seeds In 'Select Seeds to Buy' Dropdown
+ Added Select All Seeds In Dropdown
+ Added Select Nothing Seeds In Dropdown
+ Added Delay Between Buys
+ Added Info Groupbox

+ Added Auto Open Seed Packs
+ Dropdown Packs to Open: Dawn Seed Pack, Gardener Seed Pack, IGMA Seed Pack, Premium Dawn Seed Pack, Premium Gardener Seed Pack, Premium IGMA Seed Pack
+ Delay Between Opens

+ Optimized Auto Buy Gears (Also Now To Buy Gears You Will Be Teleported To Molly's Gear Shop)
+ Organized Gears In 'Select Gears to Buy' Dropdown
+ Added Select All Gears In Dropdown
+ Added Select Nothing Gears In Dropdown
+ Added Delay Between Buys
+ Added Info Groupbox

+ Added More Codes In 'Redeem All Valid Codes'
+ Added Info Label About One Code

        + Added Tab 'Miscellaneous Features', Features:

- Disable Gameplay Paused
- DS Server Of The Game With Stocks & More Button

- Redeem All Valid Codes (now in this tab)

- Teleport To Quest Board
- Teleport To Gear Shop

- Auto Claim Plot
- Always Render Plot
- Info Label About Always Render Plot

- Auto Claim Daily Quests
- Auto Claim Weekly Quests

- Local Player Tab:
+ Rewrited Anti AFK

+ Fly Speed Maximum 500 → 1000
+ Camera Zoom Minimum 40 → 128
+ WalkSpeed Minimum 16 → 24

- Visuals Tab:
+ Rewrited Fullbright
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
