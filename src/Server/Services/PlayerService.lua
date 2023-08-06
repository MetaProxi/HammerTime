--Knit
local Knit = _G.Knit

--API Services
local Players = game:GetService("Players")

--Dependencies

--Service
local PlayerService = Knit.CreateService {
    Name = "PlayerService";
    DeathHandler = nil; --Callback function to handle player death. Plug and play.
    Client = {};
}

function PlayerService:SetDeathHandler(callback)
    self.DeathHandler = callback
end

function PlayerService:KnitStart()
    local function SetupPlayer(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                if self.DeathHandler then
                    self.DeathHandler(player, character)
                end
            end)
        end)
    end

    Players.PlayerAdded:Connect(SetupPlayer)

    for _, player in pairs(Players:GetPlayers()) do
        SetupPlayer(player)
    end

end

return PlayerService