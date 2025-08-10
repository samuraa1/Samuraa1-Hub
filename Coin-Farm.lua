local RS = game:GetService('ReplicatedStorage')
local JobId = game.JobId
local PlaceId = game.PlaceId
local Remote = RS:WaitForChild("ClaimReward")
local TeleportService = game:GetService("TeleportService")
local function Fire(obj)
    obj:FireServer()
end

Fire(Remote)

queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/samuraa1/Samuraa1-Hub/refs/heads/main/Coin-Farm.lua"))()]])

task.wait(3)
TeleportService:TeleportToPlaceInstance(PlaceId, JobId)
