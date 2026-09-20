-- Services  
local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local UserInputService = game:GetService("UserInputService")  
local Lighting = game:GetService("Lighting")  
local HttpService = game:GetService("HttpService")  
local VirtualUser = game:GetService("VirtualUser")  
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")  
local LocalPlayer = Players.LocalPlayer

-- Settings  
local settings = {  
    flySpeed = 50,  
    walkSpeed = 16,  
    espEnabled = false,  
    espColor = Color3.fromRGB(255, 0, 0),  
    fullbrightEnabled = false,  
    antiAFKEnabled = true,  
    noclipEnabled = false,
    flingEnabled = false,
    aimbotEnabled = false,
    aimbotFOV = 90
}

-- State  
local flying = false  
local espObjects = {}
local guiVisible = true

-- ============================================  
-- FUNCTION DEFINITIONS  
-- ============================================

-- GUI Setup  
local ScreenGui = Instance.new("ScreenGui")  
ScreenGui.Name = "SurfaceHubGUI"  
ScreenGui.ResetOnSpawn = false  
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main container
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0, 450, 0, 600)
MainContainer.Position = UDim2.new(0.5, -225, 0.5, -300)
MainContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainContainer.Active = true
MainContainer.Draggable = true
MainContainer.Parent = ScreenGui

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.Parent = MainContainer

local Title = Instance.new("TextLabel")  
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Surface Hub v1.0"  
Title.TextColor3 = Color3.fromRGB(255, 255, 255)  
Title.Font = Enum.Font.SourceSansBold  
Title.TextSize = 20  
Title.Parent = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    MainContainer.Visible = not MainContainer.Visible
    guiVisible = MainContainer.Visible
end)

-- Side tab bar (LEFT side)
local SideTabBar = Instance.new("Frame")
SideTabBar.Size = UDim2.new(0, 120, 1, -30)
SideTabBar.Position = UDim2.new(0, 0, 0, 30)
SideTabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SideTabBar.Parent = MainContainer

-- Content area (RIGHT side)
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(0, 330, 1, -30)
ContentArea.Position = UDim2.new(0, 120, 0, 30)
ContentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentArea.Parent = MainContainer

-- Create tabs  
local tabNames = {"Main", "Movement", "Combat", "Visual", "Utility", "Teleport", "GameHub", "Info"}  
local frames = {}
local tabButtons = {}

-- Create frames in content area
for _, name in ipairs(tabNames) do  
    local frame = Instance.new("ScrollingFrame")  
    frame.Size = UDim2.new(1, 0, 1, 0)  
    frame.BackgroundTransparency = 1  
    frame.ScrollBarThickness = 5  
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)  
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y  
    frame.Visible = (name == "Main")  
    frame.Parent = ContentArea  
    frames[name] = frame  
end

-- Create side tab buttons
for i, name in ipairs(tabNames) do  
    local btn = Instance.new("TextButton")  
    btn.Size = UDim2.new(1, -10, 0, 35)  
    btn.Position = UDim2.new(0, 5, 0, 5 + (i - 1) * 40)  
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
    btn.Text = name  
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)  
    btn.Font = Enum.Font.SourceSans  
    btn.TextSize = 13  
    btn.Parent = SideTabBar  
    tabButtons[name] = btn  
end

-- Tab switching  
local function switchTab(tabName)  
    for name, frame in pairs(frames) do  
        frame.Visible = (name == tabName)  
    end  
    for name, btn in pairs(tabButtons) do  
        btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)  
        btn.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 255, 255)
    end  
end

for name, btn in pairs(tabButtons) do  
    btn.MouseButton1Click:Connect(function()  
        switchTab(name)  
    end)  
end

-- Keybind to toggle GUI (RightShift by default)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainContainer.Visible = not MainContainer.Visible
        guiVisible = MainContainer.Visible
    end
end)

-- Helper functions  
local function createButton(parent, text, callback)  
    local button = Instance.new("TextButton")  
    button.Size = UDim2.new(0.9, 0, 0, 30)  
    button.Position = UDim2.new(0.05, 0, 0, #parent:GetChildren() * 35)  
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)  
    button.Text = text  
    button.TextColor3 = Color3.fromRGB(255, 255, 255)  
    button.Font = Enum.Font.SourceSans  
    button.TextSize = 14  
    button.Parent = parent  
    button.MouseButton1Click:Connect(callback)  
    return button  
end

local function createToggle(parent, text, initial, callback)  
    local value = initial  
    local button = Instance.new("TextButton")  
    button.Size = UDim2.new(0.9, 0, 0, 30)  
    button.Position = UDim2.new(0.05, 0, 0, #parent:GetChildren() * 35)  
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)  
    button.Text = text .. ": " .. (value and "ON" or "OFF")  
    button.TextColor3 = Color3.fromRGB(255, 255, 255)  
    button.Font = Enum.Font.SourceSans  
    button.TextSize = 14  
    button.Parent = parent  
    button.MouseButton1Click:Connect(function()  
        value = not value  
        button.Text = text .. ": " .. (value and "ON" or "OFF")  
        callback(value)  
    end)  
    return button  
end

local function createSlider(parent, text, min, max, default, callback)  
    local frame = Instance.new("Frame")  
    frame.Size = UDim2.new(0.9, 0, 0, 50)  
    frame.Position = UDim2.new(0.05, 0, 0, #parent:GetChildren() * 55)  
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  
    frame.Parent = parent

    local label = Instance.new("TextLabel")  
    label.Size = UDim2.new(1, 0, 0, 20)  
    label.BackgroundTransparency = 1  
    label.Text = text .. ": " .. default  
    label.TextColor3 = Color3.fromRGB(255, 255, 255)  
    label.Font = Enum.Font.SourceSans  
    label.TextSize = 14  
    label.Parent = frame

    local value = default  
    local sliderBtn = Instance.new("TextButton")  
    sliderBtn.Size = UDim2.new(1, -20, 0, 20)  
    sliderBtn.Position = UDim2.new(0, 10, 0, 25)  
    sliderBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)  
    sliderBtn.Text = "← " .. value .. " →"  
    sliderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)  
    sliderBtn.Font = Enum.Font.SourceSans  
    sliderBtn.TextSize = 12  
    sliderBtn.Parent = frame

    sliderBtn.MouseButton1Click:Connect(function()  
        value = value + 1  
        if value > max then value = min end  
        sliderBtn.Text = "← " .. value .. " →"  
        label.Text = text .. ": " .. value  
        callback(value)  
    end)

    sliderBtn.MouseButton2Click:Connect(function()  
        value = value - 1  
        if value < min then value = max end  
        sliderBtn.Text = "← " .. value .. " →"  
        label.Text = text .. ": " .. value  
        callback(value)  
    end)  
end

-- FLY SYSTEM  
local function startFly()  
    local character = LocalPlayer.Character  
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")  
    local rootPart = character:FindFirstChild("HumanoidRootPart")  
    if not humanoid or not rootPart then return end

    humanoid:ChangeState(Enum.HumanoidStateType.Flying)

    local bv = Instance.new("BodyVelocity")  
    bv.Name = "SurfaceFlyBV"  
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)  
    bv.P = 10000  
    bv.Velocity = Vector3.new()  
    bv.Parent = rootPart

    local bg = Instance.new("BodyGyro")  
    bg.Name = "SurfaceFlyBG"  
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)  
    bg.P = 10000  
    bg.D = 100  
    bg.CFrame = rootPart.CFrame  
    bg.Parent = rootPart  
end

local function stopFly()  
    local character = LocalPlayer.Character  
    if character then  
        local humanoid = character:FindFirstChildOfClass("Humanoid")  
        local rootPart = character:FindFirstChild("HumanoidRootPart")

        if humanoid then  
            humanoid:ChangeState(Enum.HumanoidStateType.Running)  
        end

        if rootPart then  
            local bv = rootPart:FindFirstChild("SurfaceFlyBV")  
            local bg = rootPart:FindFirstChild("SurfaceFlyBG")  
            if bv then bv:Destroy() end  
            if bg then bg:Destroy() end  
        end  
    end  
end

local flyConnection = nil  
local function enableFly()  
    startFly()

    if flyConnection then flyConnection:Disconnect() end

    flyConnection = RunService.RenderStepped:Connect(function()  
        if not flying then return end

        local character = LocalPlayer.Character  
        if not character then return end

        local rootPart = character:FindFirstChild("HumanoidRootPart")  
        if not rootPart then return end

        local bv = rootPart:FindFirstChild("SurfaceFlyBV")  
        local bg = rootPart:FindFirstChild("SurfaceFlyBG")

        if not bv or not bg then  
            startFly()  
            return  
        end

        local cf = Camera.CFrame  
        local moveDirection = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cf.LookVector end  
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cf.LookVector end  
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cf.RightVector end  
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cf.RightVector end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end  
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

        if moveDirection.Magnitude > 0 then  
            moveDirection = moveDirection.Unit * settings.flySpeed  
        end

        bv.Velocity = moveDirection  
        bg.CFrame = cf  
    end)  
end

local function disableFly()  
    flying = false  
    if flyConnection then  
        flyConnection:Disconnect()  
        flyConnection = nil  
    end  
    stopFly()  
end

-- NOCLIP SYSTEM  
local noclipConnection = nil

local function enableNoclip()  
    if noclipConnection then noclipConnection:Disconnect() end
    
    noclipConnection = RunService.Stepped:Connect(function()  
        if not settings.noclipEnabled then return end
        
        local character = LocalPlayer.Character  
        if not character then return end
        
        for _, part in ipairs(character:GetDescendants()) do  
            if part:IsA("BasePart") and part.CanCollide then  
                part.CanCollide = false  
            end  
        end  
    end)  
end

local function disableNoclip()  
    if noclipConnection then  
        noclipConnection:Disconnect()  
        noclipConnection = nil  
    end
    
    local character = LocalPlayer.Character  
    if character then  
        for _, part in ipairs(character:GetDescendants()) do  
            if part:IsA("BasePart") then  
                part.CanCollide = true  
            end  
        end  
    end  
end

-- FLING SYSTEM (FIXED - uses TouchInterest and proper force application)
local flingConnection = nil

local function enableFling()  
    if flingConnection then flingConnection:Disconnect() end
    
    flingConnection = RunService.Heartbeat:Connect(function()  
        if not settings.flingEnabled then return end
        
        local character = LocalPlayer.Character  
        if not character then return end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")  
        if not rootPart then return end
        
        -- Check for nearby players
        for _, player in ipairs(Players:GetPlayers()) do  
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then  
                local targetRoot = player.Character.HumanoidRootPart
                local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                if targetRoot and targetHumanoid then
                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                    
                    -- If touching (within 6 studs)
                    if distance < 6 then
                        -- Get direction away from player
                        local direction = (targetRoot.Position - rootPart.Position).Unit
                        
                        -- Apply force to TARGET ONLY using BodyVelocity
                        local flingVel = Instance.new("BodyVelocity")
                        flingVel.Name = "SurfaceFling"
                        flingVel.MaxForce = Vector3.new(100000, 100000, 100000)
                        flingVel.P = 100000
                        flingVel.Velocity = direction * 300 + Vector3.new(0, 150, 0)
                        flingVel.Parent = targetRoot
                        
                        -- Also apply angular velocity for spin
                        targetRoot.AssemblyAngularVelocity = Vector3.new(50, 50, 50)
                        
                        -- Remove after a short time
                        task.delay(0.3, function()
                            if flingVel and flingVel.Parent then
                                flingVel:Destroy()
                            end
                        end)
                    end
                end
            end  
        end  
    end)  
end

local function disableFling()  
    if flingConnection then  
        flingConnection:Disconnect()  
        flingConnection = nil  
    end
end

-- AIMBOT SYSTEM  
local function getClosestPlayerToCursor()  
    local closest = nil  
    local closestDist = math.huge
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do  
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then  
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist and dist < settings.aimbotFOV then
                    closestDist = dist
                    closest = player
                end
            end
        end  
    end
    
    return closest
end

local aimbotConnection = nil

local function enableAimbot()  
    if aimbotConnection then aimbotConnection:Disconnect() end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()  
        if not settings.aimbotEnabled then return end
        
        local character = LocalPlayer.Character  
        if not character then return end
        
        local target = getClosestPlayerToCursor()
        
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPos = target.Character.Head.Position
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                -- Look at target
                rootPart.CFrame = CFrame.new(rootPart.Position, targetPos)
                
                -- Also rotate camera toward target
                local camCF = Camera.CFrame
                local newCamCF = CFrame.lookAt(camCF.Position, targetPos)
                Camera.CFrame = newCamCF
            end
        end
    end)  
end

local function disableAimbot()  
    if aimbotConnection then  
        aimbotConnection:Disconnect()  
        aimbotConnection = nil  
    end
end

-- ESP functions  
local function createESP(player)  
    if player == LocalPlayer then return end  
    if espObjects[player] then return end

    local function setupESP(char)  
        local head = char:FindFirstChild("Head")  
        if not head then return end

        local esp = Instance.new("BillboardGui")  
        esp.Name = "ESP_" .. player.Name  
        esp.Size = UDim2.new(0, 200, 0, 50)  
        esp.AlwaysOnTop = true  
        esp.Adornee = head  
        esp.Parent = char

        local textLabel = Instance.new("TextLabel")  
        textLabel.Size = UDim2.new(1, 0, 1, 0)  
        textLabel.BackgroundTransparency = 1  
        textLabel.Text = player.Name  
        textLabel.TextColor3 = settings.espColor  
        textLabel.TextStrokeTransparency = 0  
        textLabel.Font = Enum.Font.SourceSansBold  
        textLabel.TextSize = 16  
        textLabel.Parent = esp

        espObjects[player] = esp  
    end

    if player.Character then  
        setupESP(player.Character)  
    end

    player.CharacterAdded:Connect(function(char)  
        task.wait(0.5)  
        if espObjects[player] then  
            espObjects[player]:Destroy()  
            espObjects[player] = nil  
        end  
        setupESP(char)  
    end)  
end

local function updateESP()  
    for player, esp in pairs(espObjects) do  
        if not player.Parent or not player.Character or not player.Character:FindFirstChild("Head") then  
            esp:Destroy()  
            espObjects[player] = nil  
        else  
            esp.Adornee = player.Character.Head  
            local distance = math.huge  
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then  
                distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.Head.Position).Magnitude  
            end  
            local textLabel = esp:FindFirstChild("TextLabel")  
            if textLabel then  
                textLabel.Text = player.Name .. " [" .. math.floor(distance) .. "m]"  
            end  
        end  
    end  
end

local function removeAllESP()  
    for player, esp in pairs(espObjects) do  
        esp:Destroy()  
        espObjects[player] = nil  
    end  
end

-- TELEPORT SYSTEM  
local function teleportToPlayer(targetPlayer)  
    if not targetPlayer then return end

    local character = LocalPlayer.Character  
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")  
    if not rootPart then return end

    local targetChar = targetPlayer.Character  
    if not targetChar then return end

    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")  
    if not targetRoot then return end

    rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)

    local notification = Instance.new("TextLabel")  
    notification.Size = UDim2.new(0, 200, 0, 30)  
    notification.Position = UDim2.new(0.5, -100, 0.8, 0)  
    notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)  
    notification.Text = "Teleported to " .. targetPlayer.Name  
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)  
    notification.Font = Enum.Font.SourceSansBold  
    notification.TextSize = 14  
    notification.Parent = ScreenGui

    task.delay(2, function()  
        notification:Destroy()  
    end)  
end

-- Player list for teleport tab  
local function refreshPlayerList()  
    for _, child in ipairs(frames["Teleport"]:GetChildren()) do  
        if child:IsA("TextButton") then  
            child:Destroy()  
        end  
    end

    local yPos = 0  
    for _, player in ipairs(Players:GetPlayers()) do  
        if player ~= LocalPlayer then  
            local button = Instance.new("TextButton")  
            button.Size = UDim2.new(0.9, 0, 0, 35)  
            button.Position = UDim2.new(0.05, 0, 0, yPos)  
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)  
            button.Text = player.Name .. " (Click to TP)"  
            button.TextColor3 = Color3.fromRGB(255, 255, 255)  
            button.Font = Enum.Font.SourceSans  
            button.TextSize = 14  
            button.Parent = frames["Teleport"]

            button:SetAttribute("TargetPlayer", player.Name)

            button.MouseButton1Click:Connect(function()  
                local targetName = button:GetAttribute("TargetPlayer")  
                local target = Players:FindFirstChild(targetName)  
                if target then  
                    teleportToPlayer(target)  
                end  
            end)

            yPos = yPos + 40  
        end  
    end

    frames["Teleport"].CanvasSize = UDim2.new(0, 0, 0, yPos + 10)  
end

-- Player added/removed connections  
Players.PlayerAdded:Connect(function(player)  
    if settings.espEnabled then  
        createESP(player)  
    end  
    refreshPlayerList()  
end)

Players.PlayerRemoving:Connect(function(player)  
    if espObjects[player] then  
        espObjects[player]:Destroy()  
        espObjects[player] = nil  
    end  
    refreshPlayerList()  
end)

-- Main loop  
RunService.RenderStepped:Connect(function()  
    if settings.espEnabled then  
        updateESP()  
    end  
end)

-- ============================================  
-- GAME HUB SYSTEM  
-- ============================================

local gameHubScripts = {
    ["Murder Mystery 2"] = {
        id = 142823291,
        script = [[
            -- MM2 Script
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            LocalPlayer.Character.Humanoid.WalkSpeed = 100

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local esp = Instance.new("BillboardGui")
                    esp.Size = UDim2.new(0, 100, 0, 30)
                    esp.Adornee = player.Character:FindFirstChild("Head")
                    esp.AlwaysOnTop = true
                    esp.Parent = player.Character
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = player.Name
                    label.TextColor3 = Color3.fromRGB(255, 0, 0)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 14
                    label.Parent = esp
                end
            end

            print("MM2 Script Loaded!")
        ]]
    },
    
    ["Piggy"] = {
        id = 4623386862,
        script = [[
            -- Piggy Script
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            LocalPlayer.Character.Humanoid.WalkSpeed = 150

            game:GetService("RunService").Stepped:Connect(function()
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)

            print("Piggy Script Loaded!")
        ]]
    },
    
    ["Animal Hospital"] = {
        id = 2436558316,
        script = [[
            -- Animal Hospital Script
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            LocalPlayer.Character.Humanoid.WalkSpeed = 100

            game:GetService("UserInputService").JumpRequest:Connect(function()
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)

            print("Animal Hospital Script Loaded!")
        ]]
    },
    
    ["Dandy's World"] = {
        id = 18378383072,
        script = [[
            -- Dandy's World Script
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local LocalPlayer = Players.LocalPlayer

            getgenv().DWSettings = {
                Speed = 50,
                Noclip = false,
                InfiniteJump = false
            }

            local function setSpeed(speed)
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = speed
                    end
                end
            end

            RunService.Stepped:Connect(function()
                if getgenv().DWSettings.Noclip then
                    local character = LocalPlayer.Character
                    if character then
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)

            RunService.Heartbeat:Connect(function()
                if getgenv().DWSettings.InfiniteJump then
                    local character = LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end
            end)

            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

            local MainFrame = Instance.new("Frame")
            MainFrame.Size = UDim2.new(0, 200, 0, 150)
            MainFrame.Position = UDim2.new(0.7, 0, 0.1, 0)
            MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            MainFrame.Active = true
            MainFrame.Draggable = true
            MainFrame.Parent = ScreenGui

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, 0, 0, 30)
            Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Title.Text = "Dandy's World"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.Font = Enum.Font.SourceSansBold
            Title.TextSize = 14
            Title.Parent = MainFrame

            local speedBtn = Instance.new("TextButton")
            speedBtn.Size = UDim2.new(0.9, 0, 0, 25)
            speedBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
            speedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            speedBtn.Text = "Speed: 50"
            speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            speedBtn.Font = Enum.Font.SourceSans
            speedBtn.TextSize = 12
            speedBtn.Parent = MainFrame

            speedBtn.MouseButton1Click:Connect(function()
                getgenv().DWSettings.Speed = getgenv().DWSettings.Speed + 10
                if getgenv().DWSettings.Speed > 200 then getgenv().DWSettings.Speed = 10 end
                speedBtn.Text = "Speed: " .. getgenv().DWSettings.Speed
                setSpeed(getgenv().DWSettings.Speed)
            end)

            local noclipBtn = Instance.new("TextButton")
            noclipBtn.Size = UDim2.new(0.9, 0, 0, 25)
            noclipBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
            noclipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            noclipBtn.Text = "Noclip: OFF"
            noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            noclipBtn.Font = Enum.Font.SourceSans
            noclipBtn.TextSize = 12
            noclipBtn.Parent = MainFrame

            noclipBtn.MouseButton1Click:Connect(function()
                getgenv().DWSettings.Noclip = not getgenv().DWSettings.Noclip
                noclipBtn.Text = "Noclip: " .. (getgenv().DWSettings.Noclip and "ON" or "OFF")
            end)

            local jumpBtn = Instance.new("TextButton")
            jumpBtn.Size = UDim2.new(0.9, 0, 0, 25)
            jumpBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
            jumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            jumpBtn.Text = "Infinite Jump: OFF"
            jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            jumpBtn.Font = Enum.Font.SourceSans
            jumpBtn.TextSize = 12
            jumpBtn.Parent = MainFrame

            jumpBtn.MouseButton1Click:Connect(function()
                getgenv().DWSettings.InfiniteJump = not getgenv().DWSettings.InfiniteJump
                jumpBtn.Text = "Infinite Jump: " .. (getgenv().DWSettings.InfiniteJump and "ON" or "OFF")
            end)

            print("Dandy's World Script Loaded!")
        ]]
    },
    
    ["Demonology"] = {
        id = 3466936693,
        script = [[
            -- Demonology Script
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            LocalPlayer.Character.Humanoid.WalkSpeed = 100

            game:GetService("RunService").Stepped:Connect(function()
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)

            game:GetService("UserInputService").JumpRequest:Connect(function()
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)

            print("Demonology Script Loaded!")
        ]]
    },
    
    ["Jailbreak"] = {
        id = 606849621,
        script = [[
            -- Jailbreak Script
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            LocalPlayer.Character.Humanoid.WalkSpeed = 100

            game:GetService("RunService").Stepped:Connect(function()
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)

            game:GetService("UserInputService").JumpRequest:Connect(function()
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end)

            print("Jailbreak Script Loaded!")
        ]]
    }
}

-- Create Game Hub buttons
local yPos = 35
for gameName, gameData in pairs(gameHubScripts) do
    local gameBtn = Instance.new("TextButton")
    gameBtn.Size = UDim2.new(0.9, 0, 0, 35)
    gameBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    gameBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    gameBtn.Text = gameName .. " Script"
    gameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    gameBtn.Font = Enum.Font.SourceSans
    gameBtn.TextSize = 14
    gameBtn.Parent = frames["GameHub"]
    
    gameBtn.MouseButton1Click:Connect(function()
        if game.PlaceId == gameData.id then
            local success, err = pcall(function()
                loadstring(gameData.script)()
            end)
            
            local notification = Instance.new("TextLabel")
            notification.Size = UDim2.new(0, 200, 0, 30)
            notification.Position = UDim2.new(0.5, -100, 0.8, 0)
            notification.BackgroundColor3 = success and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(200, 0, 0)
            notification.Text = success and (gameName .. " script loaded!") or ("Error: " .. tostring(err))
            notification.TextColor3 = Color3.fromRGB(255, 255, 255)
            notification.Font = Enum.Font.SourceSansBold
            notification.TextSize = 14
            notification.Parent = ScreenGui
            
            task.delay(2, function()
                notification:Destroy()
            end)
        else
            local notification = Instance.new("TextLabel")
            notification.Size = UDim2.new(0, 200, 0, 30)
            notification.Position = UDim2.new(0.5, -100, 0.8, 0)
            notification.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            notification.Text = "Teleporting to " .. gameName .. "..."
            notification.TextColor3 = Color3.fromRGB(255, 255, 255)
            notification.Font = Enum.Font.SourceSansBold
            notification.TextSize = 14
            notification.Parent = ScreenGui
            
            task.delay(2, function()
                notification:Destroy()
            end)
            
            game:GetService("TeleportService"):Teleport(gameData.id)
        end
    end)
    
    yPos = yPos + 40
end

-- ============================================  
-- UI ELEMENTS CREATION  
-- ============================================

-- MAIN TAB  
createToggle(frames["Main"], "ESP", settings.espEnabled, function(value)  
    settings.espEnabled = value  
    if value then  
        for _, player in ipairs(Players:GetPlayers()) do  
            createESP(player)  
        end  
    else  
        removeAllESP()  
    end  
end)

createButton(frames["Main"], "Refresh ESP", function()  
    removeAllESP()  
    for _, player in ipairs(Players:GetPlayers()) do  
        createESP(player)  
    end  
end)

-- MOVEMENT TAB  
createToggle(frames["Movement"], "Fly", false, function(value)  
    if value then  
        flying = true  
        enableFly()  
    else  
        flying = false  
        disableFly()  
    end  
end)

-- FLY SPEED SLIDER
createSlider(frames["Movement"], "Fly Speed", 10, 200, settings.flySpeed, function(value)  
    settings.flySpeed = value  
end)

-- WALK SPEED SLIDER
createSlider(frames["Movement"], "Walk Speed", 10, 200, settings.walkSpeed, function(value)  
    settings.walkSpeed = value  
    local character = LocalPlayer.Character  
    if character then  
        local humanoid = character:FindFirstChildOfClass("Humanoid")  
        if humanoid then  
            humanoid.WalkSpeed = value  
        end  
    end  
end)

-- NOCLIP TOGGLE (separated with extra space)
local noclipToggle = createToggle(frames["Movement"], "Noclip", settings.noclipEnabled, function(value)  
    settings.noclipEnabled = value  
    if value then  
        enableNoclip()  
    else  
        disableNoclip()  
    end  
end)

-- COMBAT TAB  
-- FLING TOGGLE
createToggle(frames["Combat"], "Fling", settings.flingEnabled, function(value)  
    settings.flingEnabled = value  
    if value then  
        enableFling()  
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 200, 0, 30)
        notification.Position = UDim2.new(0.5, -100, 0.8, 0)
        notification.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        notification.Text = "Fling Enabled - Touch players to fling them!"
        notification.TextColor3 = Color3.fromRGB(255, 255, 255)
        notification.Font = Enum.Font.SourceSansBold
        notification.TextSize = 12
        notification.Parent = ScreenGui
        
        task.delay(3, function()
            notification:Destroy()
        end)
    else  
        disableFling()  
    end  
end)

-- AIMBOT TOGGLE
createToggle(frames["Combat"], "Aimbot", settings.aimbotEnabled, function(value)  
    settings.aimbotEnabled = value  
    if value then  
        enableAimbot()  
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 200, 0, 30)
        notification.Position = UDim2.new(0.5, -100, 0.8, 0)
        notification.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        notification.Text = "Aimbot Enabled - Locks onto nearest target"
        notification.TextColor3 = Color3.fromRGB(255, 255, 255)
        notification.Font = Enum.Font.SourceSansBold
        notification.TextSize = 12
        notification.Parent = ScreenGui
        
        task.delay(3, function()
            notification:Destroy()
        end)
    else  
        disableAimbot()  
    end  
end)

-- AIMBOT FOV SLIDER
createSlider(frames["Combat"], "Aimbot FOV", 30, 180, settings.aimbotFOV, function(value)  
    settings.aimbotFOV = value  
end)

-- VISUAL TAB  
createToggle(frames["Visual"], "Fullbright", settings.fullbrightEnabled, function(value)  
    settings.fullbrightEnabled = value  
    if value then  
        Lighting.Brightness = 2  
        Lighting.ClockTime = 12  
        Lighting.FogEnd = 100000  
        Lighting.FogStart = 0  
    else  
        Lighting.Brightness = 1  
        Lighting.ClockTime = 14  
        Lighting.FogEnd = 500  
        Lighting.FogStart = 0  
    end  
end)

-- UTILITY TAB  
createToggle(frames["Utility"], "Anti-AFK", settings.antiAFKEnabled, function(value)  
    settings.antiAFKEnabled = value  
    if value then  
        VirtualUser:CaptureController()  
        VirtualUser:Button1Down(Vector2.new(0, 0))  
    end  
end)

createButton(frames["Utility"], "Teleport to Nearest", function()  
    local nearest = nil  
    local nearestDist = math.huge  
    for _, player in ipairs(Players:GetPlayers()) do  
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then  
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude  
            if dist < nearestDist then  
                nearestDist = dist  
                nearest = player  
            end  
        end  
    end  
    if nearest then  
        teleportToPlayer(nearest)  
    end  
end)

-- TELEPORT TAB  
createButton(frames["Teleport"], "Refresh Player List", function()  
    refreshPlayerList()  
end)

-- Initial player list  
refreshPlayerList()

-- GAME HUB TAB  
local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(0.9, 0, 0, 30)
hubTitle.Position = UDim2.new(0.05, 0, 0, 0)
hubTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
hubTitle.Text = "Select a Game Script:"
hubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
hubTitle.Font = Enum.Font.SourceSansBold
hubTitle.TextSize = 14
hubTitle.Parent = frames["GameHub"]

-- INFO TAB  
local function createInfoLabel(parent, text)  
    local label = Instance.new("TextLabel")  
    label.Size = UDim2.new(0.9, 0, 0, 25)  
    label.Position = UDim2.new(0.05, 0, 0, #parent:GetChildren() * 30)  
    label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  
    label.Text = text  
    label.TextColor3 = Color3.fromRGB(255, 255, 255)  
    label.Font = Enum.Font.SourceSans  
    label.TextSize = 14  
    label.Parent = parent  
    return label  
end

-- Get user info  
local userId = LocalPlayer.UserId  
local userName = LocalPlayer.Name  
local displayName = LocalPlayer.DisplayName  
local accountAge = LocalPlayer.AccountAge  
local dateCreated = os.date("%Y-%m-%d", os.time() - (accountAge * 86400))

createInfoLabel(frames["Info"], "Script: Surface Hub v1.0")  
createInfoLabel(frames["Info"], "Version: 1.0")  
createInfoLabel(frames["Info"], "Username: " .. userName)  
createInfoLabel(frames["Info"], "Display Name: " .. displayName)  
createInfoLabel(frames["Info"], "User ID: " .. userId)  
createInfoLabel(frames["Info"], "Account Age: " .. accountAge .. " days")  
createInfoLabel(frames["Info"], "Account Created: " .. dateCreated)  
createInfoLabel(frames["Info"], "Game: " .. game.Name)  
createInfoLabel(frames["Info"], "Place ID: " .. game.PlaceId)  
createInfoLabel(frames["Info"], "Game ID: " .. game.GameId)  
createInfoLabel(frames["Info"], "Job ID: " .. game.JobId)  
createInfoLabel(frames["Info"], "Creator: OYB")  
createInfoLabel(frames["Info"], "Created: 2024")  
createInfoLabel(frames["Info"], "Status: Loaded Successfully")

print("Surface Hub v1.0 loaded successfully!")  
print("Welcome, " .. userName .. "!")
print("Press RightShift to toggle GUI")
