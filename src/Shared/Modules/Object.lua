--[[

    Object

        OOP class to help create and extend objects.




    USAGE

        -- Create a new class:
        local Enemy = Object:Extend()

        -- Use static variables:
        Enemy.MAX_HEALTH = 100

        -- Constructor:
        function Enemy:Constructor(name, health)
            self.Name = name
            self.Health = math.min(Enemy.MAX_HEALTH, health)
        end

        -- Custom Metamethods:
        function Enemy:__tostring()
            return string.format("%s (%i/%i)", self.Name, self.Health, Enemy.MAX_HEALTH)
        end

        -- Extend a class:
        local Dragon = Enemy:Extend()

        function Dragon:Constructor(color)
            local name = "Dragon"
            local health = Enemy.MAX_HEALTH
            Dragon.super:Constructor(name, health)

            self.Color = color
        end

        -- Create objects:
        local myEnemy = Enemy.new("Skeleton", 15)
        print(myEnemy) -- Skeleton (15/100)

        local myDragon = Dragon.new("Red")
        print(myDragon) -- Dragon (100/100)
        print(myDragon.Color) -- Red

        -- Check an object's type:
        print(myEnemy:InstanceOf(Object)) -- true
        print(myEnemy:InstanceOf(Enemy)) -- true
        print(myEnemy:InstanceOf(Dragon)) -- false

        -- Check if an object is assignable from a certain class:
        print(Object:AssignableFrom(myEnemy)) -- true
        print(Enemy:AssignableFrom(myEnemy)) -- true
        print(Dragon:AssignableFrom(myEnemy)) -- false




    LICENSE

        Copyright (c) 2014, rxi

        Permission is hereby granted, free of charge, to any person obtaining a copy of
        this software and associated documentation files (the "Software"), to deal in
        the Software without restriction, including without limitation the rights to
        use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
        of the Software, and to permit persons to whom the Software is furnished to do
        so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.

]]--

--- @class Object ---
local Object = {}
Object.__index = Object

local function newInstance(self, ...)
    local object = setmetatable({}, self)
    object:Constructor(...)
    return object
end

function Object.new(...)
    return newInstance(Object, ...)
end

function Object:Constructor()
end

function Object:Extend(ClassName)
    local class = {}
    for key, value in pairs(self) do
        if key:find("__") == 1 then
            class[key] = value
        end
    end
	class.__index = class
	class.ClassName = ClassName
    class.super = self
    class.new = function(...)
        return newInstance(class, ...)
    end
    setmetatable(class, self)
    return class
end

function Object:InstanceOf(T)
    local metatable = getmetatable(self)
    while metatable do
        if metatable == T then
            return true
        end
        metatable = getmetatable(metatable)
    end
    return false
end

function Object:AssignableFrom(obj)
    if obj then
        if type(obj) == "table" then
            if (obj.Constructor) ~= nil then
                if obj:InstanceOf(self) then
                    return true
                end
            end
        end
    end
    return false
end

-- function Object:__tostring()
--     return "Object"
-- end

return Object
