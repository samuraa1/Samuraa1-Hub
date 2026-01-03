local args = {
    [1] = 10000000000
}
game:GetService("ReplicatedStorage"):WaitForChild("Honeypot"):WaitForChild("Internal"):WaitForChild("RemoteStorage"):WaitForChild("GiveLuckyBlockReward - RemoteEvent"):FireServer(unpack(args))
