if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() and Players.LocalPlayer

repeat task.wait() until player and player:FindFirstChild("PlayerGui")

if getgenv().reavscripts then
    local infoGui = Instance.new("ScreenGui")
    infoGui.Name = "ReavAlreadyRunning"
    infoGui.ResetOnSpawn = false
    infoGui.IgnoreGuiInset = true
    infoGui.Parent = player:WaitForChild("PlayerGui")

    local scale = Instance.new("UIScale", infoGui)
    scale.Scale = 1

    local container = Instance.new("Frame", infoGui)
    container.Size = UDim2.new(0.8, 0, 0.2, 0)
    container.Position = UDim2.new(0.5, 0, 0.85, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container.BackgroundTransparency = 0.2

    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0.5, 0, 0.5, 0)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 100, 100)
    label.Font = Enum.Font.GothamBold
    label.Text = "🚫 reav's Scripts already running!"
    label.TextScaled = true
    label.TextWrapped = true
    label.TextStrokeTransparency = 0.4
    label.TextStrokeColor3 = Color3.new(0, 0, 0)

    Instance.new("UITextSizeConstraint", label).MaxTextSize = 60
    Instance.new("UIPadding", label).PaddingBottom = UDim.new(0.02, 0)

    task.delay(3, function()
        infoGui:Destroy()
    end)

    return
end
getgenv().reavscripts = true

local function waitForChildRecursive(parent, childName, timeout)
    local t = 0
    timeout = timeout or 10
    while t < timeout do
        local child = parent:FindFirstChild(childName)
        if child then return child end
        t += task.wait()
    end
    error("❌ Missing child: " .. childName)
end

debugLog = function(msg)
    if getgenv().debug then
        warn("[DEBUG] " .. msg)
    end
end

debugLog("⏳ Waiting for __Main and related world objects...")
waitForChildRecursive(workspace, "__Main", 15)
local main = waitForChildRecursive(workspace, "__Main", 10)
local world = waitForChildRecursive(main, "__World", 10)
local room1 = world:FindFirstChild("Room_1")

local function waitForSetCore(name)
    local success = false
    repeat
        success = pcall(function()
            StarterGui:SetCore(name, nil)
        end)
        if not success then task.wait() end
    until success
end
waitForSetCore("SendNotification")

local function showMessage(message, duration)
    local success, err = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "reavscripts",
            Text = message,
            Duration = duration or 5
        })
    end)
    if not success then
        warn("[ReavScripts] Failed to show notification:", err)
    end
end

local function getScriptUrl()
    local scripts = {
        [7074860883] = {
            [128336380114944] = "https://raw.githubusercontent.com/reavscripts/arise/refs/heads/main/dungeon.lua",
            [116614712661486] = "https://raw.githubusercontent.com/reavscripts/arise/refs/heads/main/afk.lua",
            default = "https://raw.githubusercontent.com/reavscripts/arise/refs/heads/main/main.lua"
        },
        [7513130835] = {
            [game.PlaceId] = "https://raw.githubusercontent.com/reavscripts/untitleddrillgame/main/main.lua",
            default = "https://raw.githubusercontent.com/reavscripts/untitleddrillgame/main/main.lua"
        },
        [7546582051] = {
            [94845773826960] = "https://raw.githubusercontent.com/reavscripts/dungeon-heroes/main/main.lua",
            default = "https://raw.githubusercontent.com/reavscripts/dungeon-heroes/main/main.lua"
        },
        [6944155317] = {
            [72615021017011] = "https://raw.githubusercontent.com/reavscripts/unlimitedworld/refs/heads/main/main.lua",
            default = "https://raw.githubusercontent.com/reavscripts/unlimitedworld/refs/heads/main/main.lua"
        }
    }

    if room1 and room1:FindFirstChild("Portal") then
        showMessage("🎯 Room_1 มี Portal ตรวจพบ – โหลด infernal.lua", 3)
        return "https://raw.githubusercontent.com/reavscripts/arise/refs/heads/main/infernal.lua"
    end

    local gameScripts = scripts[game.GameId]
    if gameScripts then
        return gameScripts[game.PlaceId] or gameScripts.default
    end

    return nil
end

local function executeScript()
    local scriptUrl = getScriptUrl()

    if scriptUrl then
        debugLog("🔗 Loading script from URL: " .. scriptUrl)
        showMessage("🔄 Loading script...", 2)
        local success, err = pcall(function()
            loadstring(game:HttpGet(scriptUrl))()
        end)

        if not success then
            showMessage("❌ โหลดสคริปต์ไม่สำเร็จ!", 5)
            warn("[ReavScripts] Script load error:", err)
        end
    else
        showMessage("❌ ไม่พบสคริปต์สำหรับแมพนี้", 5)
    end
end

executeScript()

