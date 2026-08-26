local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/SearchAndChangeLogLibrary/Source'))()

Library:CreateChangelogDialog({
    Title = "Secure the Airport Script - Changelogs",
    ChangelogText = [[
        Version: 2.0.0
        + Rewrited Auto Do Everything - No More Breaking The Game On Disasters

+ Disaster Criminals Now Get Shot From Stand (No Walking Into Them) + Day 7 Boss Kill Works (No Tween Away Mid Fight)

+ Fake ID / Contraband / Hostile:
- Tween To NPC → Taser → Cuff → Jail
- Cuffs Actually Land Now (Walks Up Close)
- One Target At A Time (No Ping-Pong Between 2 NPCs)
- WalkSpeed 200 For Fake ID + Contraband Too
- METAL+ Is Search Only (No More Arresting Innocents)

+ Fixed Auto Power Reboot - Now Goes To The Generator (Not Your Office) + Fires Prompt Until Power Is Back

+ Auto Ammo Refill - If Gun Is Empty Tweens To Closest Crate, Keeps Shooting If Enemy Alive / Tweens Back If Not

+ Individual Auto Toggles Now Work The Same As Auto Do Everything

+ UI:
- Automation Tab Now Above ESP
- Removed Tween Teleport Slider
- Removed Action Cooldown Slider

+ Small Optimizations
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
