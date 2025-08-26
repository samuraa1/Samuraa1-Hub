local player = game.Players.LocalPlayer
local config = player:FindFirstChild("Config")
if not config then return end
local currentTycoon = config:FindFirstChild("CurrentTycoon")
if not currentTycoon or not currentTycoon.Value then return end
local tycoon = currentTycoon.Value
if not tycoon then return end

local function interactWithButtons()
    local allButtons = tycoon:FindFirstChild("AllButtons")
    if allButtons then
        for _, button in pairs(allButtons:GetChildren()) do
            local mainPart = button:FindFirstChild("MainPart")
            if mainPart and mainPart:FindFirstChild("TouchInterest") then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = mainPart.CFrame + Vector3.new(0, 3, 0)
                wait(0.1)
            end
        end
    end
end

local function teleportToCollector()
    local otherFolder = tycoon:FindFirstChild("Other")
    if otherFolder then
        local collector = otherFolder:FindFirstChild("CollectorCash")
        if collector then
            local mainPart = collector:FindFirstChild("MainPart")
            if mainPart then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = mainPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end

while true do
    teleportToCollector()
    wait(2)
    interactWithButtons()
    wait(4)
end
