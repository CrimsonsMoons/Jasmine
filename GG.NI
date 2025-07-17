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

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local islandsFolder = workspace:WaitForChild("Islands")

-- === Island Teleport Configuration ===
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

-- === Exclusions for all islands ===
for _, config in pairs(islandConfigs) do
    config["{84b93b68-b932-4db8-b765-d1bd9ef8aae9}"] = true
    config["{c5769905-aecf-4d7a-ada9-064802b0cae9}"] = true
    config["{d2227f02-c482-4911-b201-7e842b31c47c}"] = true
    config["{6b019e60-21c6-4536-9a06-4cbfee80d88f}"] = true
    config["{12916ad6-7fd9-46d5-8bc1-e69671249721}"] = true
    config["Horse"] = true
    config["Travel Boat"] = true
end

-- === Teleport Toggles ===
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

-- === Island Travel Buttons ===
local function createTravelButton(islandName)
    TravelSection:NewButton("Travel to " .. islandName, "Uses remote to travel instantly", function()
        local args = {
            [1] = "\1",
            [2] = "Travel",
            [3] = islandName,
            [4] = 1
        }

        local comm = game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9)
        local funcFolder = comm:WaitForChild("Functions", 9e9)
        local remote = funcFolder:GetChildren()[2]

        remote:FireServer(unpack(args))
    end)
end

for islandName, _ in pairs(islandConfigs) do
    createTravelButton(islandName)
end

-- === Single Button Executes Script ===
TrainSection:NewButton("Single", "Runs Single Route Script", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/WHI/refs/heads/main/Tab%3ATrain%3ASingle"))()
end)

-- === Trap Character Button ===
TrainSection:NewButton("Trap Character", "Creates a red box around your character", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CrimsonsMoons/WHI/refs/heads/main/box"))()
end)

-- === Auto Catch Toggle (All Islands with Recursion) ===
local autoCatchEnabled = false

AutoSection:NewToggle("Auto Catch", "Fires remote on nearby animals in all islands", function(state)
    autoCatchEnabled = state
    if state then
        coroutine.wrap(function()
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Workspace = game:GetService("Workspace")

            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local TOOL_UUIDS = {
                "{4ba69e17-8de2-43a2-ac9a-f1d1e425be9b}",
                "{634dc3c2-1694-4273-92d2-adf8f7ade91f}",
                "{51ba4466-f758-4d1c-970d-aad27326dbaf}",
                "{06905d54-7826-417e-bfc7-82d326a30885}",
                "{7138d7c4-9482-4257-868c-4bd1fd99f529}",
                "{5dab28e4-4bfb-430b-86fe-530bafa237b5}"
            }
            local remote = ReplicatedStorage:WaitForChild("Communication"):WaitForChild("Events"):GetChildren()[13]

            local exclusions = {
                ["{84b93b68-b932-4db8-b765-d1bd9ef8aae9}"] = true,
                ["{c5769905-aecf-4d7a-ada9-064802b0cae9}"] = true,
                ["{d2227f02-c482-4911-b201-7e842b31c47c}"] = true,
                ["{6b019e60-21c6-4536-9a06-4cbfee80d88f}"] = true,
                ["{12916ad6-7fd9-46d5-8bc1-e69671249721}"] = true,
                ["{c91d0e3a-e8c6-4e70-b274-9b7304ffbb28}"] = true,
                ["Horse"] = true,
                ["Travel Boat"] = true,
            }

            local function isUUIDName(name)
                return typeof(name) == "string" and name:match("^%b{}$") ~= nil
            end

            local function getPlayerPosition()
                local root = Character:FindFirstChild("HumanoidRootPart")
                if root then
                    return root.Position
                end
            end

            local function scanForAnimals(folder)
                for _, descendant in ipairs(folder:GetDescendants()) do
                    if isUUIDName(descendant.Name) and descendant:FindFirstChild("Body") and not exclusions[descendant.Name] then
                        local targetPart = descendant:FindFirstChild("Body")
                        local distance = (targetPart.Position - getPlayerPosition()).Magnitude
                        if distance <= 15 then
                            for _, toolId in ipairs(TOOL_UUIDS) do
                                remote:FireServer(toolId, "Activate", descendant)
                            end
                        end
                    end
                end
            end

            while autoCatchEnabled do
                scanForAnimals(Workspace.Islands)
                scanForAnimals(Workspace)
                task.wait(0.01)
            end
        end)()
    end
end)

-- === Sell Specials Toggle ===
local sellSpecials = false
AutoSection:NewToggle("Sell Specials", "Sells special (not locked) items every 5s", function(toggle)
    sellSpecials = toggle
    task.spawn(function()
        local listFolder = player:WaitForChild("PlayerGui")
            :WaitForChild("Menus")
            :WaitForChild("Backpack")
            :WaitForChild("Main")
            :WaitForChild("Inventory")
            :WaitForChild("Content")
            :WaitForChild("List"):GetChildren()[9]
            :WaitForChild("List")

        local remote = game:GetService("ReplicatedStorage")
            :WaitForChild("Communication")
            :WaitForChild("Events"):GetChildren()[18]

        local function isUUID(name)
            return typeof(name) == "string" and name:match("^%b{}$") ~= nil
        end

        while sellSpecials do
            local sellTable = {}
            for _, item in ipairs(listFolder:GetChildren()) do
                if isUUID(item.Name) and not item:FindFirstChild("Locked") and item:FindFirstChild("SpecialIndicator") then
                    sellTable[item.Name] = 1
                end
            end

            if next(sellTable) then
                local args = {
                    [1] = "SellItems",
                    [2] = sellTable
                }
                remote:FireServer(unpack(args))
            end
            task.wait(5)
        end
    end)
end)

-- === Auto Sell All Toggle ===
local autoSellAll = false
AutoSection:NewToggle("Auto Sell", "Auto sells unlocked & non-special items every 5s", function(toggle)
    autoSellAll = toggle
    task.spawn(function()
        local sellRemote = game:GetService("ReplicatedStorage")
            :WaitForChild("Communication")
            :WaitForChild("Events"):GetChildren()[18]

        local listFolder = player:WaitForChild("PlayerGui")
            :WaitForChild("Menus")
            :WaitForChild("Backpack")
            :WaitForChild("Main")
            :WaitForChild("Inventory")
            :WaitForChild("Content")
            :WaitForChild("List"):GetChildren()[9]
            :WaitForChild("List")

        local function isUUID(name)
            return typeof(name) == "string" and name:match("^%b{}$") ~= nil
        end

        while autoSellAll do
            local sellTable = {}
            for _, item in ipairs(listFolder:GetChildren()) do
                local isLocked = item:FindFirstChild("Locked")
                local isSpecial = item:FindFirstChild("SpecialIndicator")

                if isUUID(item.Name) and not isLocked and not isSpecial then
                    sellTable[item.Name] = 1
                end
            end

            if next(sellTable) then
                local args = {
                    [1] = "SellItems",
                    [2] = sellTable
                }
                sellRemote:FireServer(unpack(args))
            end
            task.wait(5)
        end
    end)
end)

-- === New Auto Sell 3 Toggle ===
local autoSell3Enabled = false
AutoSection:NewToggle("Auto Sell 3", "Runs auto sell 3 script every 0.5 seconds", function(state)
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

-- === Shop Buttons ===
ShopSection:NewButton("Rope", "Buys Rope from Mainland Shop", function()
    local args = {
        [1] = "BuyShopItem";
        [2] = "Mainland Shop";
        [3] = 1;
        [4] = 1000;
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9)
        :WaitForChild("Events", 9e9):GetChildren()[18]:FireServer(unpack(args))
end)

ShopSection:NewButton("Tin", "Buys Tin from Mainland Shop", function()
    local args = {
        [1] = "BuyShopItem";
        [2] = "Mainland Shop";
        [3] = 10;
        [4] = 1000;
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9)
        :WaitForChild("Events", 9e9):GetChildren()[18]:FireServer(unpack(args))
end)

ShopSection:NewButton("Craft Tin Lassos", "Crafts 1000 Tin Lassos", function()
    local args = {
        [1] = "Craft";
        [2] = {
            ["id"] = 18;
            ["variants"] = {};
            ["amt"] = 1000;
        };
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Communication", 9e9)
        :WaitForChild("Events", 9e9):GetChildren()[9]:FireServer(unpack(args))
end)
