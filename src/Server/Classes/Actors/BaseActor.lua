--[[
    BaseActor.lua

    Abstract class for all actors
]]

--API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--Dependencies
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Object = require(ReplicatedStorage.Common.Modules.Object)
local Signal = require(ReplicatedStorage.Packages.Signal)

--Variables
local AssetsFolder = ReplicatedStorage.Assets
local ActorModels = AssetsFolder.ActorModels

--Class
local BaseActor = Object:Extend("BaseActor")

function BaseActor:Constructor(spawnLocation: CFrame)
    
    local spawnModel: Model? = ActorModels:FindFirstChild(self.ClassName)
    assert(spawnModel, "No model for actor found with name: " .. self.ClassName)
    self.Model = spawnModel:Clone()
    self.Model:PivotTo(spawnLocation)
    self.Model.Parent = workspace

    self.Humanoid = self.Model:FindFirstChildOfClass("Humanoid")
    assert(self.Humanoid, "No humanoid found in actor model with name"..self.ClassName)

    self.HitCore = Signal.new()
    self.Destroyed = Signal.new()
    self.Died = Signal.new()

    self.Humanoid.Died:Connect(function()
        self.Died:Fire()
        task.delay(5,function()
            self:Destroy()
        end)
    end)

    self.Janitor = Janitor.new()

    
end

function BaseActor:HeartBeat(dt: number)
    --Override this method with actor specific logic that runs every frame
    local defensePoint = workspace:FindFirstChild("DefensePoint")
    if not defensePoint then return end
    local defensePointPosition = defensePoint.Position
    self.Humanoid:MoveTo(defensePointPosition)
    
    local dist = (self.Model:GetPivot().Position - defensePointPosition).Magnitude
    if dist <= 4 then
        print("Hit center!")
        self.HitCore:Fire()
        self:Destroy()
    end
end

function BaseActor:Destroy()
    self.Janitor:Destroy()
    self.Destroyed:Fire()
    self.Model:Destroy()

    
end

return BaseActor