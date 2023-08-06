
--Get API Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Setup Knit
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)

--Assign to _G (Generally _G is not recommended because people misuse it for mutable data. However, Knit is a good use case for it)
_G.Knit = Knit

--Load Services
Knit.AddControllersDeep(script.Controllers)

--Add Classes
local Classes = {}
for _,classModule: ModuleScript? in pairs(script.Classes:GetDescendants()) do
    if not classModule:IsA("ModuleScript") then continue end
    Classes[classModule.Name] = require(classModule)
end

--Add a reference to the classes to Knit
Knit.Classes = Classes

--Start Knit
Knit.Start():catch(warn)