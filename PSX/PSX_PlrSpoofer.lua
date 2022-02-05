local UI_Lib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()
local Psx_Lib = require(game:GetService('ReplicatedStorage').Framework.Library)

local Main_Window = UI_Lib:CreateWindow('Player Spoofer')
local Main_Folder = Main_Window:CreateFolder('ydnac#2110')

_G.Players = {}
local Selected
table.foreach(game.Players:GetChildren(), function(i, v)
    if v ~= game.Players.LocalPlayer then
        table.insert(_G.Players,  v)
    end
end)
game.Players.PlayerAdded:Connect(function(v)
    table.insert(_G.Players,  v)
end)
game.Players.PlayerRemoving:Connect(function(v)
    _G.Players[table.find(_G.Players, v)] = nil
end)
Main_Folder:Dropdown('Players', _G.Players, true, function(v)
    Selected = v
end)
Main_Folder:Button('Spoof Player', function()
    game:GetService("ReplicatedStorage").Framework.Modules["2 | Network"]["new stats"]:Fire(Psx_Lib.Save.Get(game.Players[Selected]), game.Players.LocalPlayer)
end)
Main_Folder:Button('Un-Spoof Player', function()
    game:GetService("ReplicatedStorage").Framework.Modules["2 | Network"]["new stats"]:Fire(Psx_Lib.Network.Invoke('Get Stats', game.Players.LocalPlayer), game.Players.LocalPlayer)
end)
