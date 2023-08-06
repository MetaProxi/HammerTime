
--[[
    HUDController.lua

    Handles the HUD. It's not bad practice to use a UI Framework, but for the sake of simplicity we're not using one here.
]]

--Knit
local Knit = _G.Knit

--API Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--Dependencies
local HammerService
local UpgradeData = require(ReplicatedStorage.Common.Data.UpgradeData)

--Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HUD:ScreenGui = PlayerGui:WaitForChild("HUD")


--Controller
local HUDController = Knit.CreateController {
    Name = "HUDController";
}

function HUDController:PromptUpgrades(upgradeList)
    --UpgradeList returns a list of keys that correspond to the UpgradeData table

    --Get the upgrade frame and the upgrade button prefab
    local upgradeFrame:Frame = HUD:WaitForChild("Upgrades")
    local upgradeButton = ReplicatedStorage.Assets.UIPrefabs:WaitForChild("UpgradeButton")

    --Get upgrade content
    local upgradeContent:Frame = upgradeFrame:WaitForChild("Content")

    
    --Create new content
    for _,upgrade in pairs(upgradeList) do
        local upgradeData = UpgradeData[upgrade]
        local newButton:ImageButton = upgradeButton:Clone()
        
        newButton.Title.Text = upgradeData.Title or "<PH> Title"
        newButton.Icon.Image = upgradeData.Icon or "rbxassetid://0"

        newButton.Parent = upgradeContent

        local baseSize = newButton.Size
        local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        newButton.MouseEnter:Connect(function()
            local tween = TweenService:Create(newButton, tInfo, {Size = UDim2.new(baseSize.X.Scale * 1.1, baseSize.X.Offset, baseSize.Y.Scale * 1.1, baseSize.Y.Offset)})
            tween:Play()
        end)

        newButton.MouseLeave:Connect(function()
            local tween = TweenService:Create(newButton, tInfo, {Size = baseSize})
            tween:Play()
        end)

        newButton.MouseButton1Click:Connect(function()
            if not upgradeFrame.Visible then return end -- Prevent any general weirdness with clicking too quickly, etc.
            upgradeFrame.Visible = false
            HammerService.RequestUpgrade:Fire(upgradeData.UpgradeName)

            --Clear the content so we don't have a bunch of buttons hanging around
            for _,child in pairs(upgradeContent:GetChildren()) do
                if child:IsA("UIListLayout") then continue end
                child:Destroy()
            end
        end)
    end

    --Show the upgrade frame
    upgradeFrame.Visible = true
end 

function HUDController:KnitStart()

    HammerService = Knit.GetService("HammerService")

    --RoundInfo is a folder in ReplicatedStorage that contains information about the current round, this is the one source of truth for both client and server
    local roundInfo: Folder = ReplicatedStorage:WaitForChild("RoundInfo")
    print("Got RoundInfo")
    local coreHealth: IntValue = roundInfo:WaitForChild("CoreLife")
    local currentWave: IntValue = roundInfo:WaitForChild("CurrentWave")
    

    --Get various HUD elements and store them in variables
    
    local WaveInfo:Frame = HUD:WaitForChild("WaveInfo")
    local WaveUI:TextLabel = WaveInfo:WaitForChild("Wave")

    local coreHealthFrame:Frame = HUD:WaitForChild("CoreHealth")
    local healthBar:Frame = coreHealthFrame:WaitForChild("HealthBar")
    local barFill:Frame = healthBar:WaitForChild("Fill")
    local healthAmount:TextLabel = healthBar:WaitForChild("Amount")
    local warning: TextLabel = coreHealthFrame:WaitForChild("Warning")

    --Setup the HUD to respond to changes in the roundInfo
    local baseBarColor = barFill.BackgroundColor3
    coreHealth.Changed:Connect(function()
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
        barFill.BackgroundTransparency = 0.2
        barFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        local tween = TweenService:Create(barFill, tweenInfo, {Size = UDim2.new(coreHealth.Value / 1000, 0, 1, 0), BackgroundTransparency = 0, BackgroundColor3 = baseBarColor})
        tween:Play()
        healthAmount.Text = coreHealth.Value .. " HP"

        if coreHealth.Value <= 250 then
            warning.Visible = true
        else
            warning.Visible = false
        end
    end)

    HammerService.PromptUpgrades:Connect(function(upgradeList)
        self:PromptUpgrades(upgradeList)
    end)

    currentWave.Changed:Connect(function()
        WaveUI.Text = "Wave: " .. currentWave.Value
    end)
end

return HUDController
