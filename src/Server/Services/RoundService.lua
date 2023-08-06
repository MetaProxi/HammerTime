
--[[
    RoundService.lua

    Handles the round loop and wave progression
]]


--Knit
local Knit = _G.Knit

--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Dependencies
local AIService
local HammerService
local PlayerService
local Promise = require(ReplicatedStorage.Packages.Promise)

--Service
local RoundService = Knit.CreateService {
    Name = "RoundService";
    Client = {
        GameOver = Knit.CreateSignal();
        WaveOver = Knit.CreateSignal();
    };
}

function RoundService:DamageCore(damage)
    local roundInfo = ReplicatedStorage:WaitForChild("RoundInfo")
    local coreLife = roundInfo:WaitForChild("CoreLife")
    coreLife.Value = coreLife.Value - damage
end

function RoundService:KnitStart()

    AIService = Knit.GetService("AIService")
    HammerService = Knit.GetService("HammerService")
    PlayerService = Knit.GetService("PlayerService")
    --One source of truth for both client and server
    local roundInfo = Instance.new("Folder")
    roundInfo.Name = "RoundInfo"
    roundInfo.Parent = ReplicatedStorage

    local currentWave = Instance.new("IntValue")
    currentWave.Name = "CurrentWave"
    currentWave.Parent = roundInfo

    local coreLife = Instance.new("IntValue")
    coreLife.Name = "CoreLife"
    coreLife.Parent = roundInfo
   

    local function roundLoop()
        coreLife.Value = 1000
        currentWave.Value = 0
        PlayerService:SpawnAllPlayers()
        HammerService:ResetUpgrades()
        while coreLife.Value > 0 and task.wait(1) do
            --Increment wave

            HammerService:PromptUpgrades()
            task.wait(5)
            
            coreLife.Value = coreLife.Value + 50
            currentWave.Value = currentWave.Value + 1

            --Spawn wave
            for _ = 1, currentWave.Value do
                task.wait(1) -- Don't spawn all at once or it will make the game too hard
                AIService:SpawnActor("DummyBot")
            end
            
            --Wait for wave to end
            repeat task.wait() until AIService:GetNumberOfActors() == 0 or coreLife.Value <= 0
            

        end

    end

    PlayerService:SetDeathHandler(function(player)
        task.wait(5)
        PlayerService:SpawnPlayer(player)
    end)

    --Round loop
    Promise.new(function()

        --Wait for players to join
        Players.PlayerAdded:Wait()

        --Start round loop
        while task.wait() do
            Promise.new(function(resolve, reject) --Critical errors in the round code will be caught and a new game will start
                roundLoop()
                resolve()
            end):catch(warn):finally(function()
                self.Client.GameOver:FireAll()
                task.wait(5)
                print("Game restarting")
            end):await()
        end

    end):catch(warn)
end

return RoundService