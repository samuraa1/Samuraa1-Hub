local maximumiq = 200
local currentiq = 1

for i = currentiq, maximumiq do
    local args = {
        [1] = i
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ChangeIQ"):FireServer(unpack(args))
end
