--Knit
local Knit = _G.Knit

--API Services
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

--Dependencies
local HammerService

--Controller
local HammerController = Knit.CreateController {
    Name = "HammerController";
    Upgrades = {};
}

function HammerController:KnitStart()
    HammerService = Knit.GetService("HammerService")

    ContextActionService.LocalToolEquipped:Connect(function(tool)
        if tool.Name == "Hammer" then
            local lastSwing = os.clock()
            ContextActionService:BindAction("HammerSwing", function(_, inputState, inputObject)
                
                if inputState == Enum.UserInputState.Begin then
                    local cooldownUpgrade = self.Upgrades["Cooldown"] or 0
                    local now = os.clock()
                    local cooldown = 1.4 - (cooldownUpgrade * 0.1)
                    
                    if now - lastSwing < cooldown then return end --Note this only applies on client, exploits can still bypass this
                    lastSwing = now
                    HammerService.HammerSwung:Fire() 
                end
                
            end, false, Enum.UserInputType.MouseButton1,Enum.UserInputType.Touch)
        end
    end)

    ContextActionService.LocalToolUnequipped:Connect(function(tool)
        if tool.Name == "Hammer" then
            ContextActionService:UnbindAction("HammerSwing")
        end
    end)
end

return HammerController