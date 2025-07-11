local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("All Islands Teleport", "DarkTheme")
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Teleport Controls")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local islandsFolder = workspace:WaitForChild("Islands")

local islandConfigs = {
    ["Mainland"] = {},
    ["Forest Island"] = {},
    ["Mountain Island"] = {},
    ["Lunar Islands"] = { ["{d2227f02-c482-4911-b201-7e842b31c47c}"] = true },
    ["Royal Island"] = {
        ["{6b019e60-21c6-4536-9a06-4cbfee80d88f}"] = true,
        ["Horse"] = true,
    },
    ["Blizzard Island"] = {
        ["{6b019e60-21c6-4536-9a06-4cbfee80d88f}"] = true,
        ["Horse"] = true,
    }
}

-- Add global exclusions to all
for name, config in pairs(islandConfigs) do
    config["{84b93b68-b932-4db8-b765-d1bd9ef8aae9}"] = true
    config["{c5769905-aecf-4d7a-ada9-064802b0cae9}"] = true
end

-- Active toggle state for each island
local teleportToggles = {}

-- Create teleport loop for each island
for islandName, excludedIds in pairs(islandConfigs) do
    teleportToggles[islandName] = false

    Section:NewToggle("Teleport " .. islandName, "Teleport to " .. islandName .. " (with exclusions)", function(state)
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
                for _, child in ipairs(folder:GetChildren()) do
                    if not teleportToggles[islandName] then break end
                    if excludedIds[child.Name] then continue end

                    local body = child:FindFirstChild("Body")
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
