--[[
    PlayerService.lua

    Handles player logic like spawning and death
]]

--Knit
local Knit = _G.Knit

--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local SpawnUtil = require(ReplicatedStorage.Common.Modules.SpawnUtil)

--Service
local PlayerService = Knit.CreateService {
    Name = "PlayerService";
    DeathHandler = nil; --Callback function to handle player death. Plug and play.
    Client = {};
}

function PlayerService:SpawnPlayer(player: Player)
    player:LoadCharacter()
    local playerSpawnFolder = workspace:FindFirstChild("PlayerSpawns")
    assert(playerSpawnFolder, "No player spawn folder found in workspace")
    local playerSpawnParts = playerSpawnFolder:GetChildren()
    assert(#playerSpawnParts > 0, "No player spawn parts found in workspace")
    local playerSpawnPart = playerSpawnParts[math.random(1, #playerSpawnParts)]
    local playerSpawnCFrame = playerSpawnPart.CFrame
    local randomOffset = SpawnUtil:GetRandomOffset(playerSpawnPart)
    playerSpawnCFrame = playerSpawnCFrame * CFrame.new(randomOffset)

    player.Character:PivotTo(playerSpawnCFrame)
end

function PlayerService:SpawnAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        self:SpawnPlayer(player)
    end
end

function PlayerService:SetDeathHandler(callback)
    self.DeathHandler = callback
end

function PlayerService:KnitStart()
    local function setupPlayer(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                if self.DeathHandler then
                    self.DeathHandler(player, character)
                end
            end)
        end)
    end

    Players.PlayerAdded:Connect(setupPlayer)

    for _, player in pairs(Players:GetPlayers()) do
        setupPlayer(player)
    end

end

return PlayerService