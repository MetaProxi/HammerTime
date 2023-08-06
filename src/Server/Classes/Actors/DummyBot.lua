
--[[
    DummyBot

    Basic enemy that walks towards the center of the map
]]

--Dependencies
local BaseActor = require(script.Parent.BaseActor)

--Class
local DummyBot = BaseActor:Extend("DummyBot")

function DummyBot:Constructor(...)
    self.super.Constructor(self, ...)
end

function DummyBot:HeartBeat(dt: number)
    self.super.HeartBeat(self, dt)
end

return DummyBot