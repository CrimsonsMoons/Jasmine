-- === GUI Library Setup ===
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("All Islands Teleport", "DarkTheme")

-- === Tabs ===
local TeleportTab = Window:NewTab("Main")
local TeleportSection = TeleportTab:NewSection("Teleport Controls")

local TravelTab = Window:NewTab("Island Travel")
local TravelSection = TravelTab:NewSection("Quick TP Buttons")

local TrainTab = Window:NewTab("Train")
local TrainSection = TrainTab:NewSection("Training Features")

local AutoTab = Window:NewTab("Auto")
local AutoSection = AutoTab:NewSection("Automation")

local ShopTab = Window:NewTab("Shop")
local ShopSection = ShopTab:NewSection("Shop Items")

-- === Initialization ===
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local islandsFolder = workspace:WaitForChild("Islands")
local explorerFolder = workspace:FindFirstChild("Explorer")

-- === Island Configuration ===
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

-- === Universal Exclusions ===
for _, config in pairs(islandConfigs) do
    config["{84b93b68-b932-4db8-b765-d1bd9ef8aae9}"] = true
    config["{c5769905-aecf-4d7a-ada9-064802b0cae9}"] = true
    config["{d2227f02-c482-4911-b201-7e842b31c47c}"] = true
    config["{6b019e60-21c6-4536-9a06-4cbfee80d88f}"] = true
    config["{12916ad6-7fd9-46d5-8bc1-e69671249721}"] = true
    config["{2c0549c7-f2d0-4828-bc2a-6d484e792cdd}"] = true
    config["{de31ac95-029b-4c26-b9f8-4b61faed7335}"] = true
    config["Horse"] = true
    config["Travel Boat"] = true
end

-- === Teleport Toggles ===
local teleportToggles = {}

for islandName, excludedIds in pairs(islandConfigs) do
    teleportToggles[islandName] = false

    TeleportSection:NewToggle("Teleport " .. islandName, "Teleport to " .. islandName, function(state)
        teleportToggles[islandName] = state
    end)

    task.spawn(function()
        local folder = islandsFolder:FindFirstChild(islandName) or (explorerFolder and explorerFolder:FindFirstChild(islandName))
        if not folder then warn("Island not found: " .. islandName) return end
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

-- === Travel Buttons ===
for islandName in pairs(islandConfigs) do
    TravelSection:NewButton("Travel to " .. islandName, "Use teleport remote", function()
        local args = {"\1", "Travel", islandName, 1}
        game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9)
            :WaitForChild("Functions", 9e9):GetChildren()[2]:FireServer(unpack(args))
    end)
end

-- === Training Buttons ===
TrainSection:NewButton("Single", "Runs Single Route Script", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/WHI/refs/heads/main/Tab%3ATrain%3ASingle"))()
end)

TrainSection:NewButton("Trap Character", "Creates a red box around your character", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/WHI/refs/heads/main/box"))()
end)

-- === Auto Catch Toggles ===
local autoCatchEnabled1 = false
AutoSection:NewToggle("Islands 1,2,3", "Auto Catch Script", function(state)
    autoCatchEnabled1 = state
    if state then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/Jasmine/refs/heads/main/Auto%20Catch%201"))()
    end
end)

local autoCatchEnabled2 = false
AutoSection:NewToggle("Islands 4,5,6", "Auto Catch Script", function(state)
    autoCatchEnabled2 = state
    if state then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/Jasmine/refs/heads/main/Auto%20Catch%202", true))()
    end
end)

-- === Sell Toggles ===
local sellSpecials = false
AutoSection:NewToggle("Sell Specials", "Sell all special (unlocked) items every 5s", function(toggle)
    sellSpecials = toggle
    if toggle then
        task.spawn(function()
            while sellSpecials do
                loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/Jasmine/refs/heads/main/auto%20sell3", true))()
                task.wait(5)
            end
        end)
    end
end)

local autoSellAll = false
AutoSection:NewToggle("Auto Sell", "Sells all unlocked, non-special items every 5s", function(toggle)
    autoSellAll = toggle
    if toggle then
        task.spawn(function()
            while autoSellAll do
                loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/Jasmine/refs/heads/main/auto%20sell2", true))()
                task.wait(5)
            end
        end)
    end
end)

-- === Sell 3 Fast Loop ===
local autoSell3Enabled = false
AutoSection:NewToggle("Auto Sell 3", "Loop auto sell3 every 0.5 seconds", function(state)
    autoSell3Enabled = state
    if state then
        task.spawn(function()
            while autoSell3Enabled do
                loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/Jasmine/refs/heads/main/auto%20sell3", true))()
                task.wait(0.5)
            end
        end)
    end
end)

-- === Auto Sell 4 ===
local autoSell4Enabled = false
AutoSection:NewToggle("Auto Sell 4", "Loop auto sell4 every 0.5 seconds", function(state)
    autoSell4Enabled = state
    if state then
        task.spawn(function()
            while autoSell4Enabled do
                loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/Jasmine/refs/heads/main/auto%20sell4", true))()
                task.wait(0.5)
            end
        end)
    end
end)

-- === Shop Buttons ===
ShopSection:NewButton("Rope", "Buys Rope from Mainland Shop", function()
    local args = {"BuyShopItem", "Mainland Shop", 1, 1000}
    game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9)
        :WaitForChild("Events", 9e9):GetChildren()[18]:FireServer(unpack(args))
end)

ShopSection:NewButton("Tin", "Buys Tin from Mainland Shop", function()
    local args = {"BuyShopItem", "Mainland Shop", 10, 1000}
    game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9)
        :WaitForChild("Events", 9e9):GetChildren()[18]:FireServer(unpack(args))
end)

ShopSection:NewButton("Craft Tin Lassos", "Crafts 1000 Tin Lassos", function()
    local args = {"Craft", {id = 18, variants = {}, amt = 1000}}
    game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9)
        :WaitForChild("Events", 9e9):GetChildren()[9]:FireServer(unpack(args))
end)
