-- Blackhawk Rescue Mission 5 | PvE Hack Menu (NPCs)
-- Executor: Delta / Fluxus / Wave / Synapse

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BRM5_PvE"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 420)
frame.Position = UDim2.new(0, 20, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "BRM5 PvE Hack"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local function makeButton(text, y, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 28)
    b.Position = UDim2.new(0, 5, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.Parent = frame
    b.MouseButton1Click:Connect(cb)
    return b
end

-- =========================================
-- 🎯 NPC FINDER (für Aimbot, Killaura, ESP)
-- =========================================
-- BRM5 NPCs liegen meist in Workspace unter "Enemies", "AI", "NPCs" oder direkt.
-- Wir scannen alle Models mit Humanoid + Head, die NICHT Spieler sind.

local function isNPC(model)
    if not model:IsA("Model") then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("Head") then return false end
    -- Spieler-Charakter ausschließen
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end
    return true
end

local function getNPCs()
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if isNPC(v) then table.insert(list, v) end
    end
    return list
end

local function getNearestNPC(maxDist)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    local nearest, dist = nil, maxDist or math.huge
    for _, npc in ipairs(getNPCs()) do
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
        if hrp then
            local d = (hrp.Position - myPos).Magnitude
            if d < dist then dist = d; nearest = npc end
        end
    end
    return nearest
end

-- =========================================
-- 💀 KILLAURA (NPCs töten im Umkreis)
-- =========================================
local killauraEnabled = false
local killauraRange = 60

local killauraBtn = makeButton("Killaura NPCs: OFF", 40, function()
    killauraEnabled = not killauraEnabled
    killauraBtn.Text = "Killaura NPCs: " .. (killauraEnabled and "ON" or "OFF")
    killauraBtn.BackgroundColor3 = killauraEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(50, 50, 50)
end)

RunService.Heartbeat:Connect(function()
    if not killauraEnabled then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos = char.HumanoidRootPart.Position
    for _, npc in ipairs(getNPCs()) do
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
        if hrp and (hrp.Position - myPos).Magnitude <= killauraRange then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum then
                -- Direkt killen (funktioniert bei fast allen BRM5-NPCs)
                pcall(function() hum.Health = 0 end)
                -- Zusätzlicher Fallback: Humanoid:TakeDamage
                pcall(function() hum:TakeDamage(1000) end)
            end
        end
    end
end)

-- =========================================
-- 🛡️ GODMODE / UNSTERBLICH
-- =========================================
local godmodeEnabled = false

local function applyGodmode()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
    -- BodyForce gegen Fallschaden / Ragdoll
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bp = hrp:FindFirstChild("GodBP")
        if not bp then
            bp = Instance.new("BodyPosition", hrp)
            bp.Name = "GodBP"
            bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bp.Position = hrp.Position
        end
    end
end

local godBtn = makeButton("Godmode: OFF", 80, function()
    godmodeEnabled = not godmodeEnabled
    godBtn.Text = "Godmode: " .. (godmodeEnabled and "ON" or "OFF")
    godBtn.BackgroundColor3 = godmodeEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(50, 50, 50)
end)

RunService.Heartbeat:Connect(function()
    if godmodeEnabled then applyGodmode() end
end)

-- Auf Respawn erneut anwenden
player.CharacterAdded:Connect(function()
    task.wait(1)
    if godmodeEnabled then applyGodmode() end
end)

-- =========================================
-- 🎯 AIMBOT auf NPCs (mit Auto-Shoot optional)
-- =========================================
local aimbotEnabled = false
local autoShoot = false
local fov = 400

local aimbotBtn = makeButton("Aimbot NPCs: OFF", 120, function()
    aimbotEnabled = not aimbotEnabled
    aimbotBtn.Text = "Aimbot NPCs: " .. (aimbotEnabled and "ON" or "OFF")
    aimbotBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(50, 50, 50)
end)

local autoShootBtn = makeButton("Auto-Shoot: OFF", 160, function()
    autoShoot = not autoShoot
    autoShootBtn.Text = "Auto-Shoot: " .. (autoShoot and "ON" or "OFF")
    autoShootBtn.BackgroundColor3 = autoShoot and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(50, 50, 50)
end)

local function aimAtNPC()
    local mouse = player:GetMouse()
    local mousePos = UIS:GetMouseLocation()
    local best, bestDist = nil, fov
    for _, npc in ipairs(getNPCs()) do
        local head = npc:FindFirstChild("Head")
        if head then
            local sp, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                if d < bestDist then bestDist = d; best = head end
            end
        end
    end
    if best then
        camera.CFrame = CFrame.new(camera.CFrame.Position, best.Position)
    end
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        aimAtNPC()
        if autoShoot then
            pcall(function() mouse1click() end) -- manche Executoren
        end
    end
end)

-- =========================================
-- 💥 INSTANT KILL ALL (Button)
-- =========================================
local killAllBtn = makeButton("💥 Kill ALL NPCs", 200, function()
    for _, npc in ipairs(getNPCs()) do
        local hum = npc:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.Health = 0 end) end
    end
end)

-- =========================================
-- 🏃 SPEED
-- =========================================
local speedBtn = makeButton("Speed +30", 240, function()
    local c = player.Character
    if c and c:FindFirstChildOfClass("Humanoid") then
        c.Humanoid.WalkSpeed = c.Humanoid.WalkSpeed + 30
    end
end)

local resetSpeedBtn = makeButton("Speed Reset (16)", 280, function()
    local c = player.Character
    if c and c:FindFirstChildOfClass("Humanoid") then
        c.Humanoid.WalkSpeed = 16
    end
end)

-- =========================================
-- 🚀 FLY
-- =========================================
local flying = false
local flyConn
local flyBtn = makeButton("Fly: OFF", 320, function()
    flying = not flying
    flyBtn.Text = "Fly: " .. (flying and "ON" or "OFF")
    flyBtn.BackgroundColor3 = flying and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(50, 50, 50)

    local c = player.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flying then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        flyConn = RunService.RenderStepped:Connect(function()
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
            bv.Velocity = dir * 60
        end)
    else
        if flyConn then flyConn:Disconnect() end
        local bv = hrp:FindFirstChild("FlyBV")
        if bv then bv:Destroy() end
    end
end)

-- =========================================
-- 👁 ESP für NPCs
-- =========================================
local espEnabled = false
local espTab = {}
local drawOk = pcall(function() return Drawing.new("Text") end)

local espBtn = makeButton("ESP NPCs: OFF", 360, function()
    espEnabled = not espEnabled
    espBtn.Text = "ESP NPCs: " .. (espEnabled and "ON" or "OFF")
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(50, 50, 50)
end)

if drawOk then
    RunService.RenderStepped:Connect(function()
        -- Aufräumen
        for npc, obj in pairs(espTab) do
            if not npc.Parent or not espEnabled then
                obj.box:Remove(); obj.name:Remove()
                espTab[npc] = nil
            end
        end
        if not espEnabled then return end
        for _, npc in ipairs(getNPCs()) do
            if not espTab[npc] then
                local box = Drawing.new("Square")
                box.Thickness = 1
                box.Color = Color3.fromRGB(255, 60, 60)
                box.Filled = false
                local name = Drawing.new("Text")
                name.Size = 14
                name.Center = true
                name.Outline = true
                name.Color = Color3.fromRGB(255, 255, 0)
                espTab[npc] = {box = box, name = name}
            end
            local obj = espTab[npc]
            local head = npc:FindFirstChild("Head")
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if head and hrp then
                local top = camera:WorldToViewportPoint((head.Position + Vector3.new(0, 1.5, 0)))
                local bot = camera:WorldToViewportPoint((hrp.Position - Vector3.new(0, 3, 0)))
                if top.Z > 0 then
                    local h = math.abs(top.Y - bot.Y)
                    local w = h * 0.5
                    obj.box.Size = Vector2.new(w, h)
                    obj.box.Position = Vector2.new(top.X - w/2, top.Y)
                    obj.box.Visible = true
                    obj.name.Text = npc.Name
                    obj.name.Position = Vector2.new(top.X, top.Y - 18)
                    obj.name.Visible = true
                else
                    obj.box.Visible = false
                    obj.name.Visible = false
                end
            end
        end
    end)
end

-- =========================================
-- 📱 TELEPORT ZUM NÄCHSTEN NPC
-- =========================================
local tpBtn = makeButton("📱 TP zum nächsten NPC", 400, function()
    local npc = getNearestNPC(9999)
    if npc and npc:FindFirstChild("HumanoidRootPart") and player.Character then
        player.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
    end
end)
