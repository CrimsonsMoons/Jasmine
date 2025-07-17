-- Full merged script with Island Teleport, Travel, Train, Auto Catch, Auto Sell, Sell Specials

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local islandsFolder = Workspace:WaitForChild("Islands")

-- GUI Setup
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("All Islands Teleport", "DarkTheme")

-- Tabs and Sections
local TeleportTab = Window:NewTab("Main")
local TeleportSection = TeleportTab:NewSection("Teleport Controls")

local TravelTab = Window:NewTab("Island Travel")
local TravelSection = TravelTab:NewSection("Quick TP Buttons")

local TrainTab = Window:NewTab("Train")
local TrainSection = TrainTab:NewSection("Training Features")

local AutoTab = Window:NewTab("Auto")
local AutoSection = AutoTab:NewSection("Automation")

-- Island teleport configuration with exclusions
local islandConfigs = {
    ["Mainland"] = {},
    ["Forest Island"] = {},
    ["Mountain Island"] = {},
    ["Lunar Islands"] = {},
    ["Royal Island"] = {},
    ["Blizzard Island"] = {},
    ["Jungle Island"] = {},
    ["Volcano Island"] = {},
    ["Desert Island"] = {},
}

-- Exclude certain models from teleporting
for _, config in pairs(islandConfigs) do
    config["{84b93b68-b932-4db8-b765-d1bd9ef8aae9}"] = true
    config["{c5769905-aecf-4d7a-ada9-064802b0cae9}"] = true
    config["{d2227f02-c482-4911-b201-7e842b31c47c}"] = true
    config["{6b019e60-21c6-4536-9a06-4cbfee80d88f}"] = true
    config["{12916ad6-7fd9-46d5-8bc1-e69671249721}"] = true
    config["Horse"] = true
    config["Travel Boat"] = true
end

-- Teleport toggles for each island
local teleportToggles = {}

for islandName, excludedIds in pairs(islandConfigs) do
    teleportToggles[islandName] = false

    TeleportSection:NewToggle("Teleport " .. islandName, "Teleport to " .. islandName .. " (excluding specific parts)", function(state)
        teleportToggles[islandName] = state
    end)

    task.spawn(function()
        local folder = islandsFolder:FindFirstChild(islandName)
        if not folder then
            warn("Island not found: " .. islandName)
            return
        end

        while true do
            if teleportToggles[islandName] then
                for _, model in ipairs(folder:GetChildren()) do
                    if not teleportToggles[islandName] then break end
                    if excludedIds[model.Name] then continue end

                    local body = model:FindFirstChild("Body")
                    if body and body:IsA("BasePart") then
                        while teleportToggles[islandName] and body:IsDescendantOf(workspace) do
                            hrp.CFrame = CFrame.new(body.Position + Vector3.new(0, 5, 0))
                            task.wait(0.05)
                        end
                    end

                    task.wait(0.1)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

-- Island Travel buttons (instant travel)
local function createTravelButton(islandName)
    TravelSection:NewButton("Travel to " .. islandName, "Uses remote to travel instantly", function()
        local args = {
            [1] = "\1",
            [2] = "Travel",
            [3] = islandName,
            [4] = 1
        }
        local comm = ReplicatedStorage:WaitForChild("Communication", 9e9)
        local funcFolder = comm:WaitForChild("Functions", 9e9)
        local remote = funcFolder:GetChildren()[2]
        remote:FireServer(unpack(args))
    end)
end

for islandName, _ in pairs(islandConfigs) do
    createTravelButton(islandName)
end

-- Hurry Scurry Tween toggle
local hurryScurryEnabled = false
TrainSection:NewToggle("Hurry Scurry", "Auto-tween through Outdoor Arena checkpoints", function(state)
    hurryScurryEnabled = state
    if state then
        coroutine.wrap(function()
            local checkpointsFolder = Workspace.Islands["Training Island"]["Outdoor Arena"].DynamicArena._LAYOUT.CheckpointActivity.Routes["1"]
            local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local currentTween = nil

            local function tweenTo(part)
                if currentTween then currentTween:Cancel() end
                local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(part.Position)})
                currentTween = tween
                tween:Play()
                return tween
            end

            while hurryScurryEnabled do
                for i = 1, 6 do
                    if not hurryScurryEnabled then break end
                    local checkpoint = checkpointsFolder:FindFirstChild(tostring(i))
                    if checkpoint and checkpoint:IsA("BasePart") then
                        local tween = tweenTo(checkpoint)
                        tween.Completed:Wait()
                        task.wait(0.1)
                    end
                end
            end
        end)()
    end
end)

-- Single checkpoint route toggle
local singleEnabled = false
TrainSection:NewToggle("Single", "Loop 1–4 checkpoints with tween", function(state)
    singleEnabled = state
    if singleEnabled then
        task.spawn(function()
            local checkpoints = Workspace.Islands["Training Island"]["Outdoor Arena"].DynamicArena._LAYOUT.CheckpointActivity.Routes.Checkpoints
            local checkpointOrder = {"1", "2", "3", "4"}
            local moveTime = 1
            local waitTime = 0.6

            while singleEnabled do
                for _, checkpointName in ipairs(checkpointOrder) do
                    if not singleEnabled then break end
                    local checkpoint = checkpoints:FindFirstChild(checkpointName)
                    if checkpoint and checkpoint:IsA("BasePart") then
                        local goalCFrame = checkpoint.CFrame * CFrame.new(0, 5, 0)
                        local tweenInfo = TweenInfo.new(moveTime, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = goalCFrame})
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(waitTime)
                    end
                end
            end
        end)
    end
end)

-- Trap Character button
TrainSection:NewButton("Trap Character", "Creates a red box around your character", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/WHI/refs/heads/main/box"))()
end)

-- Auto Catch toggle (fires remote on nearby animals)
local autoCatchEnabled = false
AutoSection:NewToggle("Auto Catch", "Fires remote on nearby animals in all islands", function(state)
    autoCatchEnabled = state
    if state then
        coroutine.wrap(function()
            local remote = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("Events"):GetChildren()[13]

            local function isUUIDName(name)
                return typeof(name) == "string" and name:match("^%b{}$") ~= nil
            end

            local function getPlayerPosition()
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then return root.Position end
            end

            while autoCatchEnabled do
                local playerPos = getPlayerPosition()
                if playerPos then
                    for _, island in ipairs(Workspace.Islands:GetChildren()) do
                        for _, descendant in ipairs(island:GetDescendants()) do
                            if isUUIDName(descendant.Name) and descendant:FindFirstChild("Body") and not exclusions[descendant.Name] then
                                local targetPart = descendant.Body
                                local distance = (targetPart.Position - playerPos).Magnitude
                                if distance <= 15 then
                                    for _, toolId in ipairs(TOOL_UUIDS) do
                                        remote:FireServer(toolId, "Activate", descendant)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.01)
            end
        end)()
    end
end)

-- Auto Sell toggle (sell unlocked, non-special items)
local autoSellEnabled = false
AutoSection:NewToggle("Auto Sell", "Sells all unlocked non-special items every 5 seconds", function(state)
    autoSellEnabled = state
    if state then
        coroutine.wrap(function()
            local remote = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("Events"):GetChildren()[18]
            local listFolder = PlayerGui:WaitForChild("Menus"):WaitForChild("Backpack"):WaitForChild("Main"):WaitForChild("Inventory"):WaitForChild("Content"):WaitForChild("List"):GetChildren()[9]:WaitForChild("List")

            local function isUUID(name)
                return typeof(name) == "string" and name:match("^%b{}$") ~= nil
            end

            while autoSellEnabled do
                local sellTable = {}
                for _, item in ipairs(listFolder:GetChildren()) do
                    if isUUID(item.Name) and not item:FindFirstChild("Locked") and not item:FindFirstChild("SpecialIndicator") then
                        sellTable[item.Name] = 1
                    end
                end
                if next(sellTable) then
                    remote:FireServer("SellItems", sellTable)
                    print("✅ Sold items (non-special, unlocked):", sellTable)
                else
                    warn("⚠️ No sellable items found (all locked or special)")
                end
                task.wait(5)
            end
        end)()
    end
end)

-- Sell Specials toggle (sell special but unlocked items)
local sellSpecialsEnabled = false
AutoSection:NewToggle("Sell Specials", "Sells special unlocked items every 5 seconds", function(state)
    sellSpecialsEnabled = state
    if state then
        coroutine.wrap(function()
            local remote = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("Events"):GetChildren()[18]
            local listFolder = PlayerGui:WaitForChild("Menus"):WaitForChild("Backpack"):WaitForChild("Main"):WaitForChild("Inventory"):WaitForChild("Content"):WaitForChild("List"):GetChildren()[9]:WaitForChild("List")

            local function isUUID(name)
                return typeof(name) == "string" and name:match("^%b{}$") ~= nil
            end

            while sellSpecialsEnabled do
                local sellTable = {}
                for _, item in ipairs(listFolder:GetChildren()) do
                    if isUUID(item.Name) and not item:FindFirstChild("Locked") and item:FindFirstChild("SpecialIndicator") then
                        sellTable[item.Name] = 1
                    end
                end
                if next(sellTable) then
                    remote:FireServer("SellItems", sellTable)
                    print("✨ Sold specials:", sellTable)
                end
                task.wait(5)
            end
        end)()
    end
end)
