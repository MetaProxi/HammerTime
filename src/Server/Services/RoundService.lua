
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
local Promise = require(ReplicatedStorage.Packages.Promise)

--Service
local RoundService = Knit.CreateService {
    Name = "RoundService";
    Client = {};
}

function RoundService:DamageCore(damage)
    local RoundInfo = ReplicatedStorage:WaitForChild("RoundInfo")
    local CoreLife = RoundInfo:WaitForChild("CoreLife")
    CoreLife.Value = CoreLife.Value - damage
end

function RoundService:KnitStart()

    AIService = Knit.GetService("AIService")

    --One source of truth for both client and server
    local RoundInfo = Instance.new("Folder")
    RoundInfo.Name = "RoundInfo"
    RoundInfo.Parent = ReplicatedStorage

    local CurrentWave = Instance.new("IntValue")
    CurrentWave.Name = "CurrentWave"
    CurrentWave.Parent = RoundInfo

    local CoreLife = Instance.new("IntValue")
    CoreLife.Name = "CoreLife"
    CoreLife.Parent = RoundInfo
   

    local function RoundLoop()
        CoreLife.Value = 1000
        CurrentWave.Value = 0
        while CoreLife.Value > 0 and task.wait(1) do
            --Increment wave
            CurrentWave.Value = CurrentWave.Value + 1

            --Spawn wave
            for _ = 1, CurrentWave.Value do
                AIService:SpawnActor("DummyBot")
            end
            
            --Wait for wave to end
            repeat task.wait() until AIService:GetNumberOfActors() == 0 or CoreLife.Value <= 0
            print("Wave ended")
        end

    end

    --Round loop
    Promise.new(function()

        --Wait for players to join
        Players.PlayerAdded:Wait()

        --Start round loop
        while task.wait() do
            Promise.new(function(resolve, reject) --Critical errors in the round code will be caught and a new game will start
                RoundLoop()
                resolve()
            end):catch(warn):finally(function()
                task.wait(5)
                print("Game restarting")
            end):await()
        end

    end):catch(warn)
end

return RoundService