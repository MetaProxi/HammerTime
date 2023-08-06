--Knit
local Knit = _G.Knit

--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--Dependencies
local RoundService

--Service
local AIService = Knit.CreateService {
    Name = "AIService";
    Actors = {};
    Client = {};
}

function AIService:SpawnActor(actorClassName)
    local spawnFolder: Folder? = workspace:FindFirstChild("Spawns")
    assert(spawnFolder, "No spawns found in workspace")
    local spawns: {BasePart} = spawnFolder:GetChildren()
    assert(#spawns > 0, "No spawns found in workspace")
    local spawnPart = spawns[math.random(1, #spawns)]
    local spawnSize = spawnPart.Size
    local randomOffset = Vector3.new(
        math.random(-spawnSize.X / 2, spawnSize.X / 2),
        4,
        math.random(-spawnSize.Z / 2, spawnSize.Z / 2)
    )

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

function AIService:GetNumberOfActors()
    local count = 0
    for _ in self.Actors do
        count = count + 1
    end
    return count
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