-- Illusion Game Stealer v2.3.4
 -- Made by @ flex_spooky on discord

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptContext = game:GetService("ScriptContext")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local SoundService = game:GetService("SoundService")
local AnimationService = game:GetService("AnimationService")
local PlayersService = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
-- KEY SYSTEM
-- ============================================================================

local VALID_KEY = "CSRPBRP982+_k"
local OWNER_KEY = "0000nopainOWNERILLUSIONYAOHALOCCEXECUTORS5692BLOXfRUITSAMERICAEAGLE88294792849294937497837287857045029,m,JQKA,EAGLECSRPHACKS"
local isOwner = false
local keyEntered = false

-- ============================================================================
-- ANTI-CHEAT BYPASS SYSTEM
-- ============================================================================

local AntiCheatBypass = {
    enabled = true,
    hooks = {},
    originalFunctions = {}
}

local function bypassFiltering()
    local success, result = pcall(function()
        if game:GetService("RunService"):IsClient() then
            local oldGet = getrawmetatable and getrawmetatable(game).__index
            if oldGet then
                local mt = getrawmetatable(game)
                local oldIndex = mt.__index
                mt.__index = function(t, k)
                    if k == "FilteringEnabled" then
                        return false
                    end
                    return oldIndex(t, k)
                end
            end
        end
        
        local workspace = game:GetService("Workspace")
        local oldGetChildren = workspace.GetChildren
        workspace.GetChildren = function(self)
            local results = oldGetChildren(self)
            for _, obj in pairs(results) do
                if obj:IsA("BasePart") then
                    pcall(function()
                        obj:SetNetworkOwner(nil)
                    end)
                end
            end
            return results
        end
    end)
    return success
end

local function bypassRemoteEvents()
    local success, result = pcall(function()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                if not AntiCheatBypass.hooks[obj] then
                    AntiCheatBypass.hooks[obj] = true
                    local oldFire = obj.FireServer
                    obj.FireServer = function(self, ...)
                        local args = {...}
                        for i, arg in pairs(args) do
                            if type(arg) == "string" and arg:lower():find("anticheat") then
                                args[i] = nil
                            end
                            if type(arg) == "number" and arg > 9999999999 then
                                args[i] = 0
                            end
                        end
                        return oldFire(self, table.unpack(args))
                    end
                end
            end
        end
    end)
    return success
end

local function bypassScriptContext()
    local success, result = pcall(function()
        local oldLoad = ScriptContext.Load
        ScriptContext.Load = function(self, script)
            if script and script:IsA("LocalScript") then
                local content = script.Source or ""
                local bypassedContent = content:gsub("(.-)anticheat(.-)\n", "")
                script.Source = bypassedContent
            end
            return oldLoad(self, script)
        end
    end)
    return success
end

local function bypassMemoryScan()
    local success, result = pcall(function()
        if getgc then
            local gc = getgc()
            for _, v in pairs(gc) do
                if type(v) == "table" then
                    local mt = getrawmetatable(v)
                    if mt and mt.__index then
                        local oldIndex = mt.__index
                        mt.__index = function(t, k)
                            if k == "PlayerGui" or k == "CoreGui" then
                                return nil
                            end
                            return oldIndex(t, k)
                        end
                    end
                end
            end
        end
    end)
    return success
end

local function bypassHTTP()
    local success, result = pcall(function()
        local oldGet = HttpService.Get
        HttpService.Get = function(self, ...)
            local args = {...}
            for i, arg in pairs(args) do
                if type(arg) == "string" then
                    arg = arg:gsub("&tracking=[^&]*", "")
                end
                args[i] = arg
            end
            return oldGet(self, table.unpack(args))
        end
    end)
    return success
end

local function initializeAntiCheatBypass()
    local bypassFunctions = {
        bypassFiltering,
        bypassRemoteEvents,
        bypassScriptContext,
        bypassMemoryScan,
        bypassHTTP
    }
    
    for _, func in pairs(bypassFunctions) do
        local success, err = pcall(func)
        if not success then
            warn("Bypass failed: " .. tostring(err))
        end
    end
    
    return true
end

-- ============================================================================
-- ANTI-STEALING DETECTION
-- ============================================================================

local function detectSpyTools()
    local threats = {}
    
    local spyNames = {"rspy", "RemoteSpy", "Spy", "Injector", "Executor", "Dex", "DarkDex", "InfiniteYield"}
    for _, v in pairs(getgc and getgc() or {}) do
        if type(v) == "table" then
            for _, spyName in pairs(spyNames) do
                if tostring(v):lower():find(spyName:lower()) then
                    table.insert(threats, spyName)
                end
            end
        end
    end
    
    local modules = getrenv and getrenv() or {}
    for k, v in pairs(modules) do
        if type(v) == "table" and type(k) == "string" then
            if k:lower():find("spy") or k:lower():find("remote") and type(v) == "table" then
                table.insert(threats, k)
            end
        end
    end
    
    return threats
end

local function handleAntiStealing()
    local threats = detectSpyTools()
    if #threats > 0 then
        local kickReason = "Anti-Stealing: " .. table.concat(threats, ", ")
        local success, err = pcall(function()
            player:Kick(kickReason)
        end)
        if not success then
            pcall(function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
        return true
    end
    return false
end

-- ============================================================================
-- FULL GAME EXTRACTION SYSTEM
-- ============================================================================

local function serializeInstance(instance, depth)
    depth = depth or 0
    local indent = string.rep("  ", depth)
    local output = {}
    
    -- Get instance properties
    local props = {}
    local success, result = pcall(function()
        for _, prop in pairs(instance:GetProperties()) do
            local success2, val = pcall(function()
                return instance[prop]
            end)
            if success2 then
                local typeVal = typeof(val)
                if typeVal == "string" then
                    props[prop] = string.format('<string name="%s">%s</string>', prop, val:gsub("&", "&amp;"))
                elseif typeVal == "number" or typeVal == "int" or typeVal == "float" or typeVal == "double" then
                    props[prop] = string.format('<float name="%s">%s</float>', prop, tostring(val))
                elseif typeVal == "boolean" then
                    props[prop] = string.format('<bool name="%s">%s</bool>', prop, tostring(val))
                elseif typeVal == "Color3" then
                    props[prop] = string.format('<Color3 name="%s">%f,%f,%f</Color3>', prop, val.R, val.G, val.B)
                elseif typeVal == "Vector3" then
                    props[prop] = string.format('<Vector3 name="%s">%f,%f,%f</Vector3>', prop, val.X, val.Y, val.Z)
                elseif typeVal == "CFrame" then
                    local p = val.Position
                    props[prop] = string.format('<CFrame name="%s">%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f</CFrame>', 
                        prop, val:GetComponents())
                elseif typeVal == "NumberRange" then
                    props[prop] = string.format('<NumberRange name="%s">%f,%f</NumberRange>', prop, val.Min, val.Max)
                elseif typeVal == "Color3uint8" then
                    props[prop] = string.format('<Color3uint8 name="%s">%d,%d,%d</Color3uint8>', prop, val.R, val.G, val.B)
                elseif typeVal == "BrickColor" then
                    props[prop] = string.format('<BrickColor name="%s">%s</BrickColor>', prop, val.Name)
                end
            end
        end
    end)
    
    -- Build XML for this instance
    local class = instance.ClassName
    local name = instance.Name or ""
    table.insert(output, string.format('%s<Item class="%s">', indent, class))
    table.insert(output, string.format('%s  <Properties>', indent))
    for _, propXml in pairs(props) do
        table.insert(output, indent .. "    " .. propXml)
    end
    table.insert(output, string.format('%s  </Properties>', indent))
    
    -- Recurse into children
    for _, child in pairs(instance:GetChildren()) do
        local childXml = serializeInstance(child, depth + 1)
        for _, line in pairs(childXml) do
            table.insert(output, line)
        end
    end
    
    table.insert(output, string.format('%s</Item>', indent))
    return output
end

local function extractCompleteGame()
    local allXml = {}
    table.insert(allXml, '<?xml version="1.0" encoding="UTF-8"?>')
    table.insert(allXml, '<roblox>')
    table.insert(allXml, '  <Item class="DataModel">')
    
    -- Extract all major services
    local services = {
        Workspace,
        ReplicatedStorage,
        ServerScriptService,
        StarterGui,
        StarterPack,
        SoundService,
        game:GetService("Players"),
        game:GetService("ReplicatedFirst"),
        game:GetService("ServerStorage"),
        game:GetService("Lighting"),
        game:GetService("Debris"),
        game:GetService("HttpService"),
        game:GetService("MarketplaceService"),
        game:GetService("TeleportService"),
        game:GetService("ContentProvider")
    }
    
    for _, service in pairs(services) do
        if service and service:IsA("Instance") then
            local serviceXml = serializeInstance(service, 2)
            for _, line in pairs(serviceXml) do
                table.insert(allXml, line)
            end
        end
    end
    
    -- Extract all scripts from every service
    local function collectScripts(container, depth)
        depth = depth or 0
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                local scriptXml = serializeInstance(child, depth + 1)
                for _, line in pairs(scriptXml) do
                    table.insert(allXml, line)
                end
            elseif child:IsA("Model") or child:IsA("Folder") or child:IsA("Tool") then
                collectScripts(child, depth + 1)
            end
        end
    end
    
    collectScripts(Workspace, 2)
    collectScripts(ReplicatedStorage, 2)
    collectScripts(ServerScriptService, 2)
    collectScripts(StarterGui, 2)
    collectScripts(StarterPack, 2)
    
    table.insert(allXml, '  </Item>')
    table.insert(allXml, '</roblox>')
    
    return table.concat(allXml, "\n")
end

-- ============================================================================
-- KEY ENTRY SYSTEM
-- ============================================================================

local function showKeyEntryPopup()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "KeyEntryGui"
    keyGui.ResetOnSpawn = false
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyGui.Parent = playerGui
    
    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.7
    backdrop.Parent = keyGui
    
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 450, 0, 250)
    keyFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
    keyFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    keyFrame.BackgroundTransparency = 0.1
    keyFrame.BorderSizePixel = 3
    keyFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    keyFrame.Parent = backdrop
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "ILLUSION GAME STEALER"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = keyFrame
    
    local subTitle = Instance.new("TextLabel")
    subTitle.Size = UDim2.new(1, 0, 0, 30)
    subTitle.Position = UDim2.new(0, 0, 0, 50)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = "Enter your license key to continue"
    subTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subTitle.TextSize = 14
    subTitle.Font = Enum.Font.Gotham
    subTitle.Parent = keyFrame
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0, 300, 0, 35)
    keyBox.Position = UDim2.new(0.5, -150, 0, 90)
    keyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    keyBox.BackgroundTransparency = 0.3
    keyBox.Text = ""
    keyBox.PlaceholderText = "Enter key here..."
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.TextSize = 14
    keyBox.Font = Enum.Font.Gotham
    keyBox.ClearTextOnFocus = true
    keyBox.Parent = keyFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0, 130)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = keyFrame
    
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0, 120, 0, 35)
    submitBtn.Position = UDim2.new(0.5, -60, 0, 160)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    submitBtn.Text = "UNLOCK"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextSize = 16
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.BorderSizePixel = 0
    submitBtn.Parent = keyFrame
    
    submitBtn.MouseButton1Click:Connect(function()
        local enteredKey = keyBox.Text
        if enteredKey == VALID_KEY then
            keyEntered = true
            isOwner = false
            keyGui:Destroy()
            showWelcomePopup()
        elseif enteredKey == OWNER_KEY then
            keyEntered = true
            isOwner = true
            keyGui:Destroy()
            showWelcomePopup()
        else
            statusLabel.Text = "✗ Invalid key! Try again."
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            keyBox.Text = ""
            for i = 1, 3 do
                keyFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
                task.wait(0.1)
                keyFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
                task.wait(0.1)
            end
        end
    end)
    
    keyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            submitBtn.MouseButton1Click:Fire()
        end
    end)
end

-- ============================================================================
-- OWNER PANEL - 777 RAINBOW GUI
-- ============================================================================

local function createOwnerPanel()
    local ownerGui = Instance.new("ScreenGui")
    ownerGui.Name = "OwnerPanel777"
    ownerGui.ResetOnSpawn = false
    ownerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ownerGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 700, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 3
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = ownerGui
    
    -- Rainbow border effect
    local borderFrame = Instance.new("Frame")
    borderFrame.Size = UDim2.new(1, 0, 1, 0)
    borderFrame.BackgroundTransparency = 1
    borderFrame.Parent = mainFrame
    
    local function updateRainbowBorder()
        local hue = 0
        while ownerGui and ownerGui.Parent do
            hue = (hue + 0.005) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            mainFrame.BorderColor3 = color
            task.wait(0.02)
        end
    end
    coroutine.wrap(updateRainbowBorder)()
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "777 OWNER PANEL"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 1, 0)
    closeBtn.Position = UDim2.new(1, -35, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        ownerGui:Destroy()
    end)
    
    -- Tab container for owner panel
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -20, 0, 35)
    tabContainer.Position = UDim2.new(0, 10, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -95)
    contentFrame.Position = UDim2.new(0, 10, 0, 85)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    local currentOwnerContent = nil
    
    local function createOwnerTab(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 120, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(100, 0, 100)
        btn.BackgroundTransparency = 0.4
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = tabContainer
        
        local spacing = 0
        for _, child in pairs(tabContainer:GetChildren()) do
            if child:IsA("TextButton") and child ~= btn then
                spacing = spacing + 130
            end
        end
        btn.Position = UDim2.new(0, spacing, 0, 0)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Owner Tab: Ban Features
    local function buildOwnerBanTab()
        if currentOwnerContent then currentOwnerContent:Destroy() end
        currentOwnerContent = Instance.new("Frame")
        currentOwnerContent.Size = UDim2.new(1, 0, 1, 0)
        currentOwnerContent.BackgroundTransparency = 1
        currentOwnerContent.Parent = contentFrame
        
        local yPos = 0
        
        local banLabel = Instance.new("TextLabel")
        banLabel.Size = UDim2.new(1, 0, 0, 30)
        banLabel.Position = UDim2.new(0, 0, 0, yPos)
        banLabel.BackgroundTransparency = 1
        banLabel.Text = "BAN FEATURES"
        banLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        banLabel.TextSize = 18
        banLabel.Font = Enum.Font.GothamBold
        banLabel.Parent = currentOwnerContent
        
        yPos = yPos + 35
        
        local banAllBtn = Instance.new("TextButton")
        banAllBtn.Size = UDim2.new(0, 200, 0, 35)
        banAllBtn.Position = UDim2.new(0.05, 0, 0, yPos)
        banAllBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        banAllBtn.Text = "BAN ALL PLAYERS"
        banAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        banAllBtn.TextSize = 14
        banAllBtn.Font = Enum.Font.GothamBold
        banAllBtn.BorderSizePixel = 0
        banAllBtn.Parent = currentOwnerContent
        
        banAllBtn.MouseButton1Click:Connect(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    pcall(function()
                        plr:Kick("PERMANENT BAN: Violation of Illusion Terms")
                    end)
                end
            end
        end)
        
        yPos = yPos + 45
        
        local banSelfBtn = Instance.new("TextButton")
        banSelfBtn.Size = UDim2.new(0, 200, 0, 35)
        banSelfBtn.Position = UDim2.new(0.05, 0, 0, yPos)
        banSelfBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        banSelfBtn.Text = "BAN YOURSELF"
        banSelfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        banSelfBtn.TextSize = 14
        banSelfBtn.Font = Enum.Font.GothamBold
        banSelfBtn.BorderSizePixel = 0
        banSelfBtn.Parent = currentOwnerContent
        
        banSelfBtn.MouseButton1Click:Connect(function()
            pcall(function()
                player:Kick("You banned yourself from Illusion")
            end)
        end)
        
        yPos = yPos + 45
        
        -- Ban specific player dropdown
        local banLabel2 = Instance.new("TextLabel")
        banLabel2.Size = UDim2.new(1, 0, 0, 20)
        banLabel2.Position = UDim2.new(0, 0, 0, yPos)
        banLabel2.BackgroundTransparency = 1
        banLabel2.Text = "BAN SPECIFIC PLAYER:"
        banLabel2.TextColor3 = Color3.fromRGB(255, 200, 200)
        banLabel2.TextSize = 14
        banLabel2.Font = Enum.Font.GothamBold
        banLabel2.Parent = currentOwnerContent
        
        yPos = yPos + 25
        
        local banDropdown = Instance.new("Frame")
        banDropdown.Size = UDim2.new(0, 200, 0, 30)
        banDropdown.Position = UDim2.new(0.05, 0, 0, yPos)
        banDropdown.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
        banDropdown.BackgroundTransparency = 0.3
        banDropdown.BorderSizePixel = 1
        banDropdown.BorderColor3 = Color3.fromRGB(255, 0, 0)
        banDropdown.Parent = currentOwnerContent
        
        local banDropdownLabel = Instance.new("TextLabel")
        banDropdownLabel.Size = UDim2.new(1, -30, 1, 0)
        banDropdownLabel.BackgroundTransparency = 1
        banDropdownLabel.Text = "Select Player..."
        banDropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        banDropdownLabel.TextSize = 12
        banDropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        banDropdownLabel.Font = Enum.Font.Gotham
        banDropdownLabel.Parent = banDropdown
        
        local banDropdownArrow = Instance.new("TextLabel")
        banDropdownArrow.Size = UDim2.new(0, 30, 1, 0)
        banDropdownArrow.Position = UDim2.new(1, -30, 0, 0)
        banDropdownArrow.BackgroundTransparency = 1
        banDropdownArrow.Text = "▼"
        banDropdownArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
        banDropdownArrow.TextSize = 12
        banDropdownArrow.Font = Enum.Font.GothamBold
        banDropdownArrow.Parent = banDropdown
        
        local banDropdownList = Instance.new("ScrollingFrame")
        banDropdownList.Size = UDim2.new(0, 200, 0, 100)
        banDropdownList.Position = UDim2.new(0.05, 0, 0, yPos + 35)
        banDropdownList.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        banDropdownList.BackgroundTransparency = 0.2
        banDropdownList.BorderSizePixel = 1
        banDropdownList.BorderColor3 = Color3.fromRGB(255, 0, 0)
        banDropdownList.Visible = false
        banDropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
        banDropdownList.ScrollBarThickness = 6
        banDropdownList.Parent = currentOwnerContent
        
        local function updateBanDropdown()
            for _, child in pairs(banDropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            local y = 0
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 25)
                    btn.Position = UDim2.new(0, 0, 0, y)
                    btn.BackgroundTransparency = 0.8
                    btn.Text = plr.Name
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.TextSize = 12
                    btn.Font = Enum.Font.Gotham
                    btn.BorderSizePixel = 0
                    btn.Parent = banDropdownList
                    btn.MouseButton1Click:Connect(function()
                        banDropdownLabel.Text = plr.Name
                        banDropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        banDropdownList.Visible = false
                        
                        -- Create ban reason popup
                        local banReasonGui = Instance.new("ScreenGui")
                        banReasonGui.Name = "BanReasonGui"
                        banReasonGui.Parent = playerGui
                        
                        local banBackdrop = Instance.new("Frame")
                        banBackdrop.Size = UDim2.new(1, 0, 1, 0)
                        banBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        banBackdrop.BackgroundTransparency = 0.5
                        banBackdrop.Parent = banReasonGui
                        
                        local banFrame = Instance.new("Frame")
                        banFrame.Size = UDim2.new(0, 400, 0, 180)
                        banFrame.Position = UDim2.new(0.5, -200, 0.5, -90)
                        banFrame.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
                        banFrame.BorderSizePixel = 2
                        banFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
                        banFrame.Parent = banBackdrop
                        
                        local banTitle = Instance.new("TextLabel")
                        banTitle.Size = UDim2.new(1, 0, 0, 30)
                        banTitle.BackgroundTransparency = 1
                        banTitle.Text = "BAN REASON"
                        banTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
                        banTitle.TextSize = 18
                        banTitle.Font = Enum.Font.GothamBold
                        banTitle.Parent = banFrame
                        
                        local banReasonBox = Instance.new("TextBox")
                        banReasonBox.Size = UDim2.new(0, 300, 0, 35)
                        banReasonBox.Position = UDim2.new(0.5, -150, 0, 40)
                        banReasonBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        banReasonBox.Text = "Enter ban reason..."
                        banReasonBox.TextColor3 = Color3.fromRGB(200, 200, 200)
                        banReasonBox.TextSize = 12
                        banReasonBox.Font = Enum.Font.Gotham
                        banReasonBox.ClearTextOnFocus = true
                        banReasonBox.Parent = banFrame
                        
                        local banConfirmBtn = Instance.new("TextButton")
                        banConfirmBtn.Size = UDim2.new(0, 100, 0, 35)
                        banConfirmBtn.Position = UDim2.new(0.5, -50, 0, 85)
                        banConfirmBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                        banConfirmBtn.Text = "BAN"
                        banConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        banConfirmBtn.TextSize = 16
                        banConfirmBtn.Font = Enum.Font.GothamBold
                        banConfirmBtn.BorderSizePixel = 0
                        banConfirmBtn.Parent = banFrame
                        
                        banConfirmBtn.MouseButton1Click:Connect(function()
                            local reason = banReasonBox.Text
                            if reason == "" or reason == "Enter ban reason..." then
                                reason = "Banned by Illusion Owner"
                            end
                            pcall(function()
                                plr:Kick("BANNED: " .. reason)
                            end)
                            banReasonGui:Destroy()
                        end)
                        
                        local cancelBanBtn = Instance.new("TextButton")
                        cancelBanBtn.Size = UDim2.new(0, 80, 0, 35)
                        cancelBanBtn.Position = UDim2.new(0.5, -130, 0, 85)
                        cancelBanBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        cancelBanBtn.Text = "CANCEL"
                        cancelBanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        cancelBanBtn.TextSize = 14
                        cancelBanBtn.Font = Enum.Font.GothamBold
                        cancelBanBtn.BorderSizePixel = 0
                        cancelBanBtn.Parent = banFrame
                        
                        cancelBanBtn.MouseButton1Click:Connect(function()
                            banReasonGui:Destroy()
                        end)
                    end)
                    y = y + 25
                end
            end
            banDropdownList.CanvasSize = UDim2.new(0, 0, 0, y)
        end
        
        banDropdown.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                banDropdownList.Visible = not banDropdownList.Visible
                if banDropdownList.Visible then
                    updateBanDropdown()
                end
            end
        end)
        
        banDropdownArrow.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                banDropdownList.Visible = not banDropdownList.Visible
                if banDropdownList.Visible then
                    updateBanDropdown()
                end
            end
        end)
    end
    
    -- Owner Tab: Explorer
    local function buildOwnerExplorerTab()
        if currentOwnerContent then currentOwnerContent:Destroy() end
        currentOwnerContent = Instance.new("Frame")
        currentOwnerContent.Size = UDim2.new(1, 0, 1, 0)
        currentOwnerContent.BackgroundTransparency = 1
        currentOwnerContent.Parent = contentFrame
        
        local explorerLabel = Instance.new("TextLabel")
        explorerLabel.Size = UDim2.new(1, 0, 0, 30)
        explorerLabel.BackgroundTransparency = 1
        explorerLabel.Text = "GAME EXPLORER"
        explorerLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        explorerLabel.TextSize = 18
        explorerLabel.Font = Enum.Font.GothamBold
        explorerLabel.Parent = currentOwnerContent
        
        local explorerFrame = Instance.new("ScrollingFrame")
        explorerFrame.Size = UDim2.new(1, 0, 1, -40)
        explorerFrame.Position = UDim2.new(0, 0, 0, 35)
        explorerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        explorerFrame.BackgroundTransparency = 0.5
        explorerFrame.BorderSizePixel = 1
        explorerFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        explorerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        explorerFrame.ScrollBarThickness = 8
        explorerFrame.Parent = currentOwnerContent
        
        local function buildExplorerTree(container, depth, parentUI)
            depth = depth or 0
            local indent = string.rep("  ", depth)
            
            for _, child in pairs(container:GetChildren()) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 22)
                btn.BackgroundTransparency = 0.9
                btn.Text = indent .. child.Name .. " (" .. child.ClassName .. ")"
                btn.TextColor3 = Color3.fromRGB(200, 200, 255)
                btn.TextSize = 11
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Font = Enum.Font.Gotham
                btn.BorderSizePixel = 0
                btn.Parent = explorerFrame
                
                -- Click to view properties/scripts
                btn.MouseButton1Click:Connect(function()
                    local propGui = Instance.new("ScreenGui")
                    propGui.Name = "PropViewer"
                    propGui.Parent = playerGui
                    
                    local propBackdrop = Instance.new("Frame")
                    propBackdrop.Size = UDim2.new(1, 0, 1, 0)
                    propBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    propBackdrop.BackgroundTransparency = 0.6
                    propBackdrop.Parent = propGui
                    
                    local propFrame = Instance.new("Frame")
                    propFrame.Size = UDim2.new(0, 500, 0, 400)
                    propFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
                    propFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    propFrame.BorderSizePixel = 2
                    propFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
                    propFrame.Parent = propBackdrop
                    
                    local propTitle = Instance.new("TextLabel")
                    propTitle.Size = UDim2.new(1, 0, 0, 30)
                    propTitle.BackgroundTransparency = 1
                    propTitle.Text = "Properties: " .. child.Name
                    propTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
                    propTitle.TextSize = 16
                    propTitle.Font = Enum.Font.GothamBold
                    propTitle.Parent = propFrame
                    
                    local propScroll = Instance.new("ScrollingFrame")
                    propScroll.Size = UDim2.new(1, -20, 1, -50)
                    propScroll.Position = UDim2.new(0, 10, 0, 40)
                    propScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    propScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    propScroll.ScrollBarThickness = 6
                    propScroll.Parent = propFrame
                    
                    local yPos = 0
                    local success, props = pcall(function()
                        return child:GetProperties()
                    end)
                    
                    if success and props then
                        for _, prop in pairs(props) do
                            local success2, val = pcall(function()
                                return child[prop]
                            end)
                            if success2 then
                                local propLabel = Instance.new("TextLabel")
                                propLabel.Size = UDim2.new(1, 0, 0, 20)
                                propLabel.Position = UDim2.new(0, 0, 0, yPos)
                                propLabel.BackgroundTransparency = 1
                                propLabel.Text = prop .. ": " .. tostring(val)
                                propLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                                propLabel.TextSize = 11
                                propLabel.TextXAlignment = Enum.TextXAlignment.Left
                                propLabel.Font = Enum.Font.Gotham
                                propLabel.Parent = propScroll
                                yPos = yPos + 22
                            end
                        end
                    end
                    
                    -- If script, show source
                    if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                        local sourceLabel = Instance.new("TextLabel")
                        sourceLabel.Size = UDim2.new(1, 0, 0, 20)
                        sourceLabel.Position = UDim2.new(0, 0, 0, yPos)
                        sourceLabel.BackgroundTransparency = 1
                        sourceLabel.Text = "--- SCRIPT SOURCE ---"
                        sourceLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                        sourceLabel.TextSize = 12
                        sourceLabel.TextXAlignment = Enum.TextXAlignment.Left
                        sourceLabel.Font = Enum.Font.GothamBold
                        sourceLabel.Parent = propScroll
                        yPos = yPos + 25
                        
                        local sourceText = Instance.new("TextLabel")
                        sourceText.Size = UDim2.new(1, 0, 0, 0)
                        sourceText.Position = UDim2.new(0, 0, 0, yPos)
                        sourceText.BackgroundTransparency = 1
                        sourceText.Text = child.Source or "No source available"
                        sourceText.TextColor3 = Color3.fromRGB(150, 255, 150)
                        sourceText.TextSize = 10
                        sourceText.TextXAlignment = Enum.TextXAlignment.Left
                        sourceText.Font = Enum.Font.Code
                        sourceText.TextWrapped = true
                        sourceText.TextScaled = false
                        sourceText.Size = UDim2.new(1, 0, 0, (#sourceText.Text:split("\n") + 1) * 15)
                        sourceText.Parent = propScroll
                        yPos = yPos + (#sourceText.Text:split("\n") + 1) * 15 + 10
                    end
                    
                    propScroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
                    
                    local closePropBtn = Instance.new("TextButton")
                    closePropBtn.Size = UDim2.new(0, 80, 0, 30)
                    closePropBtn.Position = UDim2.new(0.5, -40, 1, -40)
                    closePropBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    closePropBtn.Text = "CLOSE"
                    closePropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    closePropBtn.TextSize = 14
                    closePropBtn.Font = Enum.Font.GothamBold
                    closePropBtn.BorderSizePixel = 0
                    closePropBtn.Parent = propFrame
                    
                    closePropBtn.MouseButton1Click:Connect(function()
                        propGui:Destroy()
                    end)
                end)
                
                -- Build children recursively
                if #child:GetChildren() > 0 then
                    buildExplorerTree(child, depth + 1)
                end
            end
        end
        
        -- Build tree from root services
        local function buildAllExplorers()
            local services = {
                Workspace,
                ReplicatedStorage,
                ServerScriptService,
                StarterGui,
                StarterPack,
                SoundService,
                game:GetService("Players"),
                game:GetService("ReplicatedFirst"),
                game:GetService("ServerStorage"),
                game:GetService("Lighting")
            }
            
            for _, service in pairs(services) do
                if service then
                    local header = Instance.new("TextLabel")
                    header.Size = UDim2.new(1, 0, 0, 25)
                    header.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
                    header.Text = "▼ " .. service.Name
                    header.TextColor3 = Color3.fromRGB(0, 255, 0)
                    header.TextSize = 13
                    header.TextXAlignment = Enum.TextXAlignment.Left
                    header.Font = Enum.Font.GothamBold
                    header.Parent = explorerFrame
                    
                    buildExplorerTree(service, 1)
                end
            end
        end
        
        buildAllExplorers()
        explorerFrame.CanvasSize = UDim2.new(0, 0, 0, explorerFrame:GetChildren().Count * 25)
    end
    
    -- Create tabs for owner panel
    local ownerBanTab = createOwnerTab("BAN", buildOwnerBanTab)
    local ownerExplorerTab = createOwnerTab("EXPLORER", buildOwnerExplorerTab)
    local ownerKickTab = createOwnerTab("KICK", buildOwnerBanTab) -- Reuse ban tab for kick features
    
    -- Default tab
    buildOwnerBanTab()
end

-- ============================================================================
-- MAIN HUB - Illusion Game Stealer
-- ============================================================================

local function createMainHub()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "IllusionGameStealer"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 200)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local blur = Instance.new("BlurEffect")
    blur.Size = 12
    blur.Parent = mainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    titleBar.BackgroundTransparency = 0.3
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Illusion Game Stealer"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 22
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    local dragging = false
    local dragStartPos = Vector2.new()
    local startPos = UDim2.new()
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 30)
    tabContainer.Position = UDim2.new(0, 10, 0, 40)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local function createTab(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
        btn.BackgroundTransparency = 0.6
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = tabContainer
        
        local spacing = 0
        for _, child in pairs(tabContainer:GetChildren()) do
            if child:IsA("TextButton") and child ~= btn then
                spacing = spacing + 110
            end
        end
        btn.Position = UDim2.new(0, spacing, 0, 0)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -80)
    contentFrame.Position = UDim2.new(0, 10, 0, 75)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    local currentContent = nil
    
    local function buildStealerTab()
        if currentContent then currentContent:Destroy() end
        currentContent = Instance.new("Frame")
        currentContent.Size = UDim2.new(1, 0, 1, 0)
        currentContent.BackgroundTransparency = 1
        currentContent.Parent = contentFrame
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, 0, 0, 30)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "Full Game Extraction"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.TextSize = 16
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = currentContent
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 0, 20)
        infoLabel.Position = UDim2.new(0, 0, 0, 35)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "Extracts ALL: Scripts, Models, Sounds, Animations, Properties"
        infoLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
        infoLabel.TextSize = 12
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.Parent = currentContent
        
        local bypassToggle = Instance.new("TextButton")
        bypassToggle.Size = UDim2.new(0, 200, 0, 30)
        bypassToggle.Position = UDim2.new(0.5, -100, 0, 65)
        bypassToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        bypassToggle.Text = "Anti-Cheat Bypass: ON"
        bypassToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        bypassToggle.TextSize = 14
        bypassToggle.Font = Enum.Font.GothamBold
        bypassToggle.BorderSizePixel = 0
        bypassToggle.Parent = currentContent
        
        local bypassActive = true
        bypassToggle.MouseButton1Click:Connect(function()
            bypassActive = not bypassActive
            if bypassActive then
                initializeAntiCheatBypass()
                bypassToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                bypassToggle.Text = "Anti-Cheat Bypass: ON"
            else
                bypassToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
                bypassToggle.Text = "Anti-Cheat Bypass: OFF"
            end
        end)
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 220, 0, 40)
        copyBtn.Position = UDim2.new(0.5, -110, 0, 110)
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
        copyBtn.Text = "Extract Full Game to .rbxl"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.TextSize = 15
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.BorderSizePixel = 0
        copyBtn.Parent = currentContent
        
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(0.8, 0, 0, 20)
        progressBar.Position = UDim2.new(0.1, 0, 0, 165)
        progressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        progressBar.BackgroundTransparency = 0.5
        progressBar.BorderSizePixel = 0
        progressBar.Parent = currentContent
        
        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        progressFill.BorderSizePixel = 0
        progressFill.Parent = progressBar
        
        local extractionLog = Instance.new("ScrollingFrame")
        extractionLog.Size = UDim2.new(0.9, 0, 0, 100)
        extractionLog.Position = UDim2.new(0.05, 0, 0, 200)
        extractionLog.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        extractionLog.BackgroundTransparency = 0.5
        extractionLog.BorderSizePixel = 1
        extractionLog.BorderColor3 = Color3.fromRGB(0, 200, 200)
        extractionLog.CanvasSize = UDim2.new(0, 0, 0, 0)
        extractionLog.ScrollBarThickness = 6
        extractionLog.Parent = currentContent
        
        local function logMessage(msg, color)
            color = color or Color3.fromRGB(200, 255, 200)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 18)
            label.BackgroundTransparency = 1
            label.Text = msg
            label.TextColor3 = color
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.Parent = extractionLog
            extractionLog.CanvasSize = UDim2.new(0, 0, 0, extractionLog:GetChildren().Count * 20)
            extractionLog.CanvasPosition = Vector2.new(0, extractionLog.CanvasSize.Y.Offset)
        end
        
        copyBtn.MouseButton1Click:Connect(function()
            coroutine.wrap(function()
                copyBtn.Text = "Extracting..."
                copyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                copyBtn.Active = false
                
                -- Clear log
                for _, child in pairs(extractionLog:GetChildren()) do
                    child:Destroy()
                end
                extractionLog.CanvasSize = UDim2.new(0, 0, 0, 0)
                
                if handleAntiStealing() then return end
                
                if bypassActive then
                    initializeAntiCheatBypass()
                end
                
                logMessage("Starting full game extraction...", Color3.fromRGB(0, 255, 255))
                logMessage("Collecting all instances...", Color3.fromRGB(255, 255, 0))
                
                local success, result = pcall(function()
                    local xml = extractCompleteGame()
                    
                    logMessage("Building XML structure...", Color3.fromRGB(255, 255, 0))
                    
                    local fileName = string.format("%s_FULL_EXTRACT_%d.rbxl", game.Name:gsub("%s+", "_"), os.time())
                    local file = io.open(fileName, "w")
                    if file then
                        file:write(xml)
                        file:close()
                        progressFill.Size = UDim2.new(1, 0, 1, 0)
                        logMessage("✓ Extraction complete!", Color3.fromRGB(0, 255, 0))
                        logMessage("File saved: " .. fileName, Color3.fromRGB(0, 255, 200))
                        logMessage("Total size: " .. tostring(#xml) .. " bytes", Color3.fromRGB(200, 255, 200))
                        statusLabel.Text = "✓ Game extracted to: " .. fileName
                        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    else
                        error("Failed to write file")
                    end
                    
                    return true
                end)
                
                if not success then
                    statusLabel.Text = "✗ Error: " .. tostring(result)
                    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    logMessage("✗ Extraction failed: " .. tostring(result), Color3.fromRGB(255, 0, 0))
                end
                
                copyBtn.Text = "Extract Full Game to .rbxl"
                copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 180)
                copyBtn.Active = true
            end)()
        end)
    end
    
    local function buildTrollTab()
        if currentContent then currentContent:Destroy() end
        currentContent = Instance.new("Frame")
        currentContent.Size = UDim2.new(1, 0, 1, 0)
        currentContent.BackgroundTransparency = 1
        currentContent.Parent = contentFrame
        
        local yPos = 0
        
        local kickAllBtn = Instance.new("TextButton")
        kickAllBtn.Size = UDim2.new(0, 180, 0, 35)
        kickAllBtn.Position = UDim2.new(0.1, 0, 0, yPos)
        kickAllBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        kickAllBtn.Text = "Kick All Players"
        kickAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        kickAllBtn.TextSize = 14
        kickAllBtn.Font = Enum.Font.GothamBold
        kickAllBtn.BorderSizePixel = 0
        kickAllBtn.Parent = currentContent
        
        kickAllBtn.MouseButton1Click:Connect(function()
            if handleAntiStealing() then return end
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    pcall(function()
                        plr:Kick("Kicked by Illusion Game Stealer")
                    end)
                end
            end
        end)
        
        yPos = yPos + 45
        
        local kickSelfBtn = Instance.new("TextButton")
        kickSelfBtn.Size = UDim2.new(0, 180, 0, 35)
        kickSelfBtn.Position = UDim2.new(0.1, 0, 0, yPos)
        kickSelfBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        kickSelfBtn.Text = "Kick Yourself"
        kickSelfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        kickSelfBtn.TextSize = 14
        kickSelfBtn.Font = Enum.Font.GothamBold
        kickSelfBtn.BorderSizePixel = 0
        kickSelfBtn.Parent = currentContent
        
        kickSelfBtn.MouseButton1Click:Connect(function()
            if handleAntiStealing() then return end
            pcall(function()
                player:Kick("You kicked yourself")
            end)
        end)
        
        yPos = yPos + 45
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = "Kick Specific Player:"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.Parent = currentContent
        
        yPos = yPos + 25
        
        local dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(0, 200, 0, 30)
        dropdown.Position = UDim2.new(0.1, 0, 0, yPos)
        dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropdown.BackgroundTransparency = 0.3
        dropdown.BorderSizePixel = 1
        dropdown.BorderColor3 = Color3.fromRGB(0, 200, 200)
        dropdown.Parent = currentContent
        
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Size = UDim2.new(1, -30, 1, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.Text = "Select Player..."
        dropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        dropdownLabel.TextSize = 12
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Font = Enum.Font.Gotham
        dropdownLabel.Parent = dropdown
        
        local dropdownArrow = Instance.new("TextLabel")
        dropdownArrow.Size = UDim2.new(0, 30, 1, 0)
        dropdownArrow.Position = UDim2.new(1, -30, 0, 0)
        dropdownArrow.BackgroundTransparency = 1
        dropdownArrow.Text = "▼"
        dropdownArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
        dropdownArrow.TextSize = 12
        dropdownArrow.Font = Enum.Font.GothamBold
        dropdownArrow.Parent = dropdown
        
        local dropdownList = Instance.new("ScrollingFrame")
        dropdownList.Size = UDim2.new(0, 200, 0, 100)
        dropdownList.Position = UDim2.new(0.1, 0, 0, yPos + 35)
        dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        dropdownList.BackgroundTransparency = 0.2
        dropdownList.BorderSizePixel = 1
        dropdownList.BorderColor3 = Color3.fromRGB(0, 200, 200)
        dropdownList.Visible = false
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
        dropdownList.ScrollBarThickness = 6
        dropdownList.Parent = currentContent
        
        local selectedPlayer = nil
        
        local function updateDropdown()
            for _, child in pairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            local y = 0
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 25)
                    btn.Position = UDim2.new(0, 0, 0, y)
                    btn.BackgroundTransparency = 0.8
                    btn.Text = plr.Name
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.TextSize = 12
                    btn.Font = Enum.Font.Gotham
                    btn.BorderSizePixel = 0
                    btn.Parent = dropdownList
                    btn.MouseButton1Click:Connect(function()
                        selectedPlayer = plr
                        dropdownLabel.Text = plr.Name
                        dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        dropdownList.Visible = false
                        buildKickUI(plr)
                    end)
                    y = y + 25
                end
            end
            dropdownList.CanvasSize = UDim2.new(0, 0, 0, y)
        end
        
        local function buildKickUI(plr)
            for _, child in pairs(currentContent:GetChildren()) do
                if child.Name == "KickUIFrame" then
                    child:Destroy()
                end
            end
            
            local kickFrame = Instance.new("Frame")
            kickFrame.Name = "KickUIFrame"
            kickFrame.Size = UDim2.new(1, 0, 0, 150)
            kickFrame.Position = UDim2.new(0, 0, 0, yPos + 80)
            kickFrame.BackgroundTransparency = 1
            kickFrame.Parent = currentContent
            
            local reasonLabel = Instance.new("TextLabel")
            reasonLabel.Size = UDim2.new(0, 150, 0, 20)
            reasonLabel.Position = UDim2.new(0.1, 0, 0, 0)
            reasonLabel.BackgroundTransparency = 1
            reasonLabel.Text = "Reason:"
            reasonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            reasonLabel.TextSize = 14
            reasonLabel.Font = Enum.Font.GothamBold
            reasonLabel.Parent = kickFrame
            
            local reasonBox = Instance.new("TextBox")
            reasonBox.Size = UDim2.new(0, 250, 0, 30)
            reasonBox.Position = UDim2.new(0.1, 0, 0, 25)
            reasonBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            reasonBox.BackgroundTransparency = 0.3
            reasonBox.Text = "Enter kick reason..."
            reasonBox.TextColor3 = Color3.fromRGB(200, 200, 200)
            reasonBox.TextSize = 12
            reasonBox.Font = Enum.Font.Gotham
            reasonBox.ClearTextOnFocus = true
            reasonBox.Parent = kickFrame
            
            local kickBtn = Instance.new("TextButton")
            kickBtn.Size = UDim2.new(0, 100, 0, 30)
            kickBtn.Position = UDim2.new(0.1, 0, 0, 65)
            kickBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            kickBtn.Text = "KICK"
            kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            kickBtn.TextSize = 16
            kickBtn.Font = Enum.Font.GothamBold
            kickBtn.BorderSizePixel = 0
            kickBtn.Parent = kickFrame
            
            kickBtn.MouseButton1Click:Connect(function()
                if handleAntiStealing() then return end
                local reason = reasonBox.Text
                if reason == "" or reason == "Enter kick reason..." then
                    reason = "Kicked by Illusion Game Stealer"
                end
                
                pcall(function()
                    local kickGui = Instance.new("ScreenGui")
                    kickGui.Name = "KickNotification"
                    kickGui.Parent = plr.PlayerGui
                    
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(0, 400, 0, 150)
                    frame.Position = UDim2.new(0.5, -200, 0.5, -75)
                    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    frame.BackgroundTransparency = 0.2
                    frame.BorderSizePixel = 2
                    frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
                    frame.Parent = kickGui
                    
                    local title = Instance.new("TextLabel")
                    title.Size = UDim2.new(1, 0, 0, 30)
                    title.BackgroundTransparency = 1
                    title.Text = "You have been kicked"
                    title.TextColor3 = Color3.fromRGB(255, 50, 50)
                    title.TextSize = 20
                    title.Font = Enum.Font.GothamBold
                    title.Parent = frame
                    
                    local reasonText = Instance.new("TextLabel")
                    reasonText.Size = UDim2.new(1, -20, 0, 40)
                    reasonText.Position = UDim2.new(0, 10, 0, 35)
                    reasonText.BackgroundTransparency = 1
                    reasonText.Text = "Reason: " .. reason
                    reasonText.TextColor3 = Color3.fromRGB(255, 255, 255)
                    reasonText.TextSize = 14
                    reasonText.Font = Enum.Font.Gotham
                    reasonText.TextWrapped = true
                    reasonText.Parent = frame
                    
                    local okBtn = Instance.new("TextButton")
                    okBtn.Size = UDim2.new(0, 80, 0, 30)
                    okBtn.Position = UDim2.new(0.5, -40, 0, 85)
                    okBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    okBtn.Text = "OK"
                    okBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    okBtn.TextSize = 14
                    okBtn.Font = Enum.Font.GothamBold
                    okBtn.BorderSizePixel = 0
                    okBtn.Parent = frame
                    
                    okBtn.MouseButton1Click:Connect(function()
                        kickGui:Destroy()
                    end)
                    
                    task.wait(0.5)
                    plr:Kick(reason)
                end)
            end)
        end
        
        dropdown.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dropdownList.Visible = not dropdownList.Visible
                if dropdownList.Visible then
                    updateDropdown()
                end
            end
        end)
        
        dropdownArrow.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dropdownList.Visible = not dropdownList.Visible
                if dropdownList.Visible then
                    updateDropdown()
                end
            end
        end)
    end
    
    local stealerTab = createTab("Stealer", buildStealerTab)
    local trollTab = createTab("Troll", buildTrollTab)
    
    buildStealerTab()
    
    return screenGui
end

-- ============================================================================
-- WELCOME POPUP
-- ============================================================================

local function showWelcomePopup()
    local popupGui = Instance.new("ScreenGui")
    popupGui.Name = "WelcomePopup"
    popupGui.ResetOnSpawn = false
    popupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    popupGui.Parent = playerGui
    
    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.6
    backdrop.Parent = popupGui
    
    local popupFrame = Instance.new("Frame")
    popupFrame.Size = UDim2.new(0, 450, 0, 220)
    popupFrame.Position = UDim2.new(0.5, -225, 0.5, -110)
    popupFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    popupFrame.BackgroundTransparency = 0.1
    popupFrame.BorderSizePixel = 2
    popupFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    popupFrame.Parent = backdrop
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    
    if isOwner then
        title.Text = "777 OWNER ILLUSION"
        title.TextColor3 = Color3.fromRGB(255, 215, 0)
    else
        title.Text = "Illusion Game Stealer"
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
    end
    
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = popupFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -40, 0, 40)
    subtitle.Position = UDim2.new(0, 20, 0, 50)
    subtitle.BackgroundTransparency = 1
    
    if isOwner then
        subtitle.Text = "OWNER ACCESS GRANTED\nFull control & explorer unlocked"
        subtitle.TextColor3 = Color3.fromRGB(255, 200, 0)
    else
        subtitle.Text = "Anti-Cheat Bypass Active\nFull game extraction ready"
        subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextWrapped = true
    subtitle.Parent = popupFrame
    
    local closePopupBtn = Instance.new("TextButton")
    closePopupBtn.Size = UDim2.new(0, 120, 0, 35)
    closePopupBtn.Position = UDim2.new(0.5, -60, 0, 110)
    closePopupBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    closePopupBtn.BackgroundTransparency = 0.3
    closePopupBtn.Text = "ENTER"
    closePopupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closePopupBtn.TextSize = 18
    closePopupBtn.Font = Enum.Font.GothamBold
    closePopupBtn.BorderSizePixel = 0
    closePopupBtn.Parent = popupFrame
    
    closePopupBtn.MouseButton1Click:Connect(function()
        popupGui:Destroy()
        createMainHub()
        
        -- If owner, spawn owner panel after main hub
        if isOwner then
            task.wait(0.3)
            createOwnerPanel()
        end
    end)
    
    backdrop.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            popupGui:Destroy()
            createMainHub()
            if isOwner then
                task.wait(0.3)
                createOwnerPanel()
            end
        end
    end)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

coroutine.wrap(function()
    task.wait(0.5)
    
    initializeAntiCheatBypass()
    
    if not handleAntiStealing() then
        showKeyEntryPopup()
    end
end)()

-- Anti-spy continuous monitor
coroutine.wrap(function()
    while task.wait(5) do
        local threats = detectSpyTools()
        if #threats > 0 then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr == player then
                    pcall(function()
                        player:Kick("Anti-Stealing: Spy tools detected")
                    end)
                end
            end
            break
        end
    end
end)()

game:BindToClose(function()
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:find("Illusion") or gui.Name:find("OwnerPanel") or gui.Name == "KeyEntryGui") then
            gui:Destroy()
        end
    end
end)

warn("Illusion Game Stealer loaded successfully.")
```
