--Knit
local Knit = _G.Knit

--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local AIService
local UpgradeData = require(ReplicatedStorage.Common.Data.UpgradeData)

--Service
local HammerService = Knit.CreateService {
    Name = "HammerService";
    Upgrades = {};
    Client = {
        HammerSwung = Knit.CreateSignal();
        PromptUpgrades = Knit.CreateSignal();
        RequestUpgrade = Knit.CreateSignal();
        UpgradesUpdated = Knit.CreateSignal();
    };
}

function HammerService:ResetUpgrades()
    for _,player in Players:GetPlayers() do
        self.Upgrades[player] = {}
        self.Client.UpgradesUpdated:Fire(player, self.Upgrades[player])
    end
end

function HammerService:AddUpgrade(player, upgrade)
    if not self.Upgrades[player][upgrade] then
        self.Upgrades[player][upgrade] = 0
    end
    self.Upgrades[player][upgrade] += 1
    print("Upgrades: ", self.Upgrades[player])
    self.Client.UpgradesUpdated:Fire(player, self.Upgrades[player])
end

function HammerService:PromptUpgrades()

    for _, player in Players:GetPlayers() do
        local upgradeDataTable = {}
        for key in pairs(UpgradeData) do -- Simplify using an array instead of a dictionary. Allows us to index randomly
            table.insert(upgradeDataTable, key)
        end
        local chosenUpgrades = {}
        for _ = 1, 3 do
            local randomUpgrade = upgradeDataTable[math.random(1, #upgradeDataTable)]
            table.insert(chosenUpgrades, randomUpgrade)
        end

        self.Client.PromptUpgrades:Fire(player, chosenUpgrades)
    end
end

function HammerService:KnitStart()

    AIService = Knit.GetService("AIService")
    self.Client.HammerSwung:Connect(function(player)
        print("HammerSwung")
        local character = player.Character
        if not character then return end
        local shockPosition = character:GetPivot().Position

        local upgradeMultipliers = self.Upgrades[player]

        if not upgradeMultipliers then -- If the player has no upgrades, create a blank table
            self.Upgrades[player] = {}
            upgradeMultipliers = self.Upgrades[player]
        end

        for _,actor in AIService:GetActorsNearPosition(shockPosition, 10 + 1* (upgradeMultipliers["Range"] or 0)) do
            local model: Model = actor.Model
            local humanoid: Humanoid = actor.Humanoid

            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
                humanoid:TakeDamage(25 + 10*(upgradeMultipliers["Damage"] or 0))
            end

            local primaryPart = model.PrimaryPart
            local shockDirection = (primaryPart.Position - shockPosition).Unit + Vector3.new(0, 0.2, 0) -- Add upward momentum to lift the actor
            if primaryPart then
                primaryPart:ApplyImpulseAtPosition(shockDirection * (1000 + 1000 * (upgradeMultipliers["ShockForce"] or 0)), shockPosition)
                local hitSound = primaryPart:FindFirstChild("HammerHit")
                if hitSound then
                    hitSound.PlaybackSpeed = math.random(90, 110)/100
                    hitSound:Play()
                end
            end

            
        end

        --Play little shockwave effect, hardcoded for now.
        local effectPart = Instance.new("Part")
        effectPart.Anchored = true
        effectPart.CanCollide = false
        effectPart.Size = Vector3.new(1, 1, 1)
        effectPart.Position = shockPosition - Vector3.new(0, 2, 0)
        effectPart.Transparency = 0.5
        effectPart.Parent = workspace
        local effect = ReplicatedStorage.Assets.Effects.Shockwave:Clone()
        effect.Parent = effectPart

        task.delay(0.1, function()
            effect:Emit(5)
        end)

        game:GetService("Debris"):AddItem(effectPart, 3) -- Destroy the effect after 1 second
    end)

    self.Client.RequestUpgrade:Connect(function(player, upgrade)
        self:AddUpgrade(player, upgrade)
    end)

    Players.PlayerAdded:Connect(function(player)
        self.Upgrades[player] = {}
    end)

    Players.PlayerRemoving:Connect(function(player)
        self.Upgrades[player] = nil
    end)

end

return HammerService