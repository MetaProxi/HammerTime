--Knit
local Knit = _G.Knit

--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--Dependencies
local RoundService
local SpawnUtil = require(ReplicatedStorage.Common.Modules.SpawnUtil)

--Service
local AIService = Knit.CreateService {
    Name = "AIService";
    Actors = {};
    Client = {};
}

function AIService:SpawnActor(actorClassName)
    local spawnFolder: Folder? = workspace:FindFirstChild("EnemySpawns")
    assert(spawnFolder, "No spawns found in workspace")
    local spawns: {BasePart} = spawnFolder:GetChildren()
    assert(#spawns > 0, "No spawns found in workspace")
    local spawnPart = spawns[math.random(1, #spawns)]
    local randomOffset = SpawnUtil:GetRandomOffset(spawnPart)

    local spawnCFrame = spawnPart.CFrame * CFrame.new(randomOffset)

    local actorClass = Knit.Classes[actorClassName]
    assert(actorClass, "No actor class found with name: " .. actorClassName)
    local actor = actorClass.new(spawnCFrame)
    self.Actors[actor.Model] = actor
    actor.Destroyed:Connect(function()
        self.Actors[actor.Model] = nil
    end)

    actor.HitCore:Connect(function()
        RoundService:DamageCore(100)
    end)
end

function AIService:GetNumberOfActors(): number
    local count = 0
    for _ in self.Actors do
        count = count + 1
    end
    return count
end

function AIService:GetActorsNearPosition(position: Vector3, radius: number): {BasePart}
    local actors = {}
    for _, actor in pairs(self.Actors) do
        if (actor.Model:GetPivot().Position - position).Magnitude <= radius then
            table.insert(actors, actor)
        end
    end
    return actors
end

function AIService:GetActors()
    return self.Actors
end

function AIService:KnitStart()

    RoundService = Knit.GetService("RoundService")

    RunService.Heartbeat:Connect(function()
        for _actorModel, actor in self.Actors do
            actor:HeartBeat()
        end
    end)
end

return AIService