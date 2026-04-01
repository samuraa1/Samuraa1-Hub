--[[ Game Check ]]--
if game.PlaceId ~= 119048529960596 and game.PlaceId ~= 99889627739043 then
    game.Players.LocalPlayer:Kick("Game Not Supported. Only Restaurant Tycoon 3 Is Supported")
return end

loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/80e1871d0af22e930ff9ae154d4587480687ca9ec81eac1a307868ff6e2c0c4b/download"))()
