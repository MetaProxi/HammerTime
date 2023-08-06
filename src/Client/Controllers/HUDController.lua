
--Knit
local Knit = _G.Knit

--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--Dependencies

--Variables
local LocalPlayer = Players.LocalPlayer

--Controller
local HUDController = Knit.CreateController {
    Name = "HUDController";
}

function HUDController:KnitStart()

    --RoundInfo is a folder in ReplicatedStorage that contains information about the current round, this is the one source of truth for both client and server
    local roundInfo: Folder = ReplicatedStorage:WaitForChild("RoundInfo")
    print("Got RoundInfo")
    local coreHealth: IntValue = roundInfo:WaitForChild("CoreLife")
    local currentWave: IntValue = roundInfo:WaitForChild("CurrentWave")

    --Get the player's PlayerGui
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    --Get various HUD elements and store them in variables
    local HUD:ScreenGui = playerGui:WaitForChild("HUD")
    local WaveInfo:Frame = HUD:WaitForChild("WaveInfo")
    local WaveUI:TextLabel = WaveInfo:WaitForChild("Wave")

    local CoreHealth:Frame = HUD:WaitForChild("CoreHealth")
    local HealthBar:Frame = CoreHealth:WaitForChild("HealthBar")
    local BarFill:Frame = HealthBar:WaitForChild("Fill")
    local HealthAmount:TextLabel = HealthBar:WaitForChild("Amount")
    local Warning: TextLabel = CoreHealth:WaitForChild("Warning")

    --Setup the HUD to respond to changes in the roundInfo
    local baseBarColor = BarFill.BackgroundColor3
    coreHealth.Changed:Connect(function()
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
        BarFill.BackgroundTransparency = 0.2
        BarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        local tween = TweenService:Create(BarFill, tweenInfo, {Size = UDim2.new(coreHealth.Value / 1000, 0, 1, 0), BackgroundTransparency = 0, BackgroundColor3 = baseBarColor})
        tween:Play()
        HealthAmount.Text = coreHealth.Value .. " HP"

        if coreHealth.Value <= 250 then
            Warning.Visible = true
        else
            Warning.Visible = false
        end
    end)

    currentWave.Changed:Connect(function()
        WaveUI.Text = "Wave: " .. currentWave.Value
    end)
end

return HUDController
