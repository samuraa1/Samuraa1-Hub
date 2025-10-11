for i = 1, 200 do
    local args = {
        [1] = i
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("ChangeIQ"):FireServer(unpack(args))
end
