local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local C_CORE = Color3.fromRGB(255, 80, 20)
local C_MID = Color3.fromRGB(255, 180, 0)
local C_BRIGHT = Color3.fromRGB(255, 240, 180)
local C_DARK = Color3.fromRGB(160, 20, 0)
local C_WHITE = Color3.fromRGB(255, 255, 255)

local bgSound = Instance.new("Sound")
bgSound.SoundId = "rbxassetid://74387685521172"
bgSound.Volume = 0
bgSound.PlaybackSpeed = 0.1

local pitchShift = Instance.new("PitchShiftSoundEffect")
pitchShift.Octave = 1
pitchShift.Parent = bgSound
bgSound.Parent = workspace

if not bgSound.IsLoaded then
    bgSound.Loaded:Wait()
end

local TARGET_VOLUME = 4
local FADE_DURATION = 2.5

local function fadeVolume(targetVol, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(bgSound, tweenInfo, {Volume = targetVol})
    tween:Play()
    return tween
end

bgSound:Play()
fadeVolume(TARGET_VOLUME, FADE_DURATION)

task.spawn(function()
    while bgSound and bgSound.Parent do
        local realDuration = bgSound.TimeLength / bgSound.PlaybackSpeed
        local timeUntilFade = realDuration - FADE_DURATION
        task.wait(timeUntilFade)

        local fadeOut = fadeVolume(0, FADE_DURATION)
        fadeOut.Completed:Wait()

        bgSound.TimePosition = 0
        bgSound:Play()
        fadeVolume(TARGET_VOLUME, FADE_DURATION)
    end
end)

local function GetGitSoundID(GithubSnd, SoundName)
    SoundName = tostring(SoundName)
    local url = GithubSnd
    local FileName = SoundName
    local success, data = pcall(function()
        return game:HttpGet(url)
    end)
    if not success or not data then
        return nil
    end
    if data:sub(1, 15):find("<!DOCTYPE") or data:find("404: Not Found") or data:sub(1, 6):find("<html>") then
        return nil
    end
    writefile("customObject_Sound_"..FileName..".mp3", data)
    return (getcustomasset or getsynasset)("customObject_Sound_"..FileName..".mp3")
end

local function sfx(id, parent, duration)
    if not id or id == "" or id == "nil" then
        return nil
    end
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Parent = parent or workspace
    sound.Volume = 3
    sound:Play()
    task.spawn(function()
        if not duration then
            if not sound.IsLoaded then
                sound.Loaded:Wait()
            end
        end
        local totalDuration = duration or sound.TimeLength
        local fadeTime = 3
        local startFadeAt = math.max(totalDuration - fadeTime, 0)
        task.wait(startFadeAt)
        local startVolume = sound.Volume
        local steps = 30
        for i = 1, steps do
            if not sound or not sound.Parent then return end
            sound.Volume = startVolume * (1 - (i / steps))
            task.wait(fadeTime / steps)
        end
        sound.Volume = 0
    end)
    task.spawn(function()
        if not duration then
            if not sound.IsLoaded then sound.Loaded:Wait() end
        end
        local destroyDelay = duration or (sound.TimeLength > 0 and sound.TimeLength or 4)
        Debris:AddItem(sound, destroyDelay)
    end)
    return sound
end

local function getsfxid(id)
    local hi = nil
    if id == "clang" then
        hi = "rbxassetid://495135507"
    elseif id == "minosspawn" then
        local url = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/free_atlastMinos.mp3"
        hi = GetGitSoundID(url, "Theme")
    elseif id == "thunder" then
        hi = "rbxassetid://9046127360"
    elseif id == "chainclank" then
        hi = "rbxassetid://9125408736"
    elseif id == "impact" then
        hi = "rbxassetid://5801257793"
    end
    return tostring(hi)
end

local function sound(id, vol, parent)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. id
    s.Volume = vol
    s.Parent = parent or workspace
    s:Play()
    Debris:AddItem(s, 6)
    return s
end

local function neonPart(shape, size, color, pos, parent)
    local p = Instance.new("Part")
    p.Shape = shape or Enum.PartType.Ball
    p.Material = Enum.Material.Neon
    p.Size = size
    p.Color = color
    p.CanCollide = false
    p.CastShadow = false
    p.Anchored = true
    p.CFrame = CFrame.new(pos)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or workspace
    return p
end

local function addLight(parent, color, brightness, range)
    local l = Instance.new("PointLight")
    l.Color = color
    l.Brightness = brightness
    l.Range = range
    l.Parent = parent
    return l
end

local function effectSphere(pos, startSize, endSize, color, duration)
    local s = neonPart(Enum.PartType.Ball, Vector3.new(startSize,startSize,startSize), color, pos)
    local t = TweenService:Create(s, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(endSize, endSize, endSize),
        Transparency = 1
    })
    t:Play()
    Debris:AddItem(s, duration + 0.05)
end

local function effectRing(pos, startR, endR, color, duration, yOffset)
    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.CanCollide = false
    ring.CastShadow = false
    ring.Anchored = true
    ring.Size = Vector3.new(0.25, startR*2, startR*2)
    ring.CFrame = CFrame.new(pos + Vector3.new(0, yOffset or 0, 0)) * CFrame.Angles(0, 0, math.pi/2)
    ring.TopSurface = Enum.SurfaceType.Smooth
    ring.BottomSurface = Enum.SurfaceType.Smooth
    ring.Parent = workspace
    local t = TweenService:Create(ring, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.05, endR*2, endR*2),
        Transparency = 1
    })
    t:Play()
    Debris:AddItem(ring, duration + 0.05)
end

local function effectShockwaveBurst(pos)
    effectRing(pos, 0.5, 30, C_BRIGHT, 0.35, 0)
    effectRing(pos, 0.5, 22, C_MID, 0.45, 0.3)
    effectRing(pos, 0.5, 16, C_CORE, 0.55, 0.6)
    effectRing(pos, 0.5, 38, C_DARK, 0.25, 0)
    effectSphere(pos, 1, 18, C_BRIGHT, 0.2)
    effectSphere(pos, 1, 12, C_MID, 0.35)
    effectSphere(pos, 1, 8, C_CORE, 0.5)
end

local function effectSplash(pos, count, speed, color, lifetime, upBias)
    for i = 1, count do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.Neon
        p.Size = Vector3.new(math.random(2,6)/10, math.random(2,6)/10, math.random(2,6)/10)
        p.Color = color
        p.CanCollide = false
        p.CastShadow = false
        p.CFrame = CFrame.new(pos)
        p.Parent = workspace

        local dir = Vector3.new(math.random(-100,100), math.random(upBias or 10, 100), math.random(-100,100)).Unit
        local spd = math.random(speed * 60, speed * 100) / 100

        local bv = Instance.new("BodyVelocity")
        bv.Velocity = dir * spd
        bv.MaxForce = Vector3.new(1e4,1e4,1e4)
        bv.Parent = p

        local tweenT = TweenService:Create(p, TweenInfo.new(lifetime, Enum.EasingStyle.Quad), {Transparency = 1, Size = Vector3.new(0.01,0.01,0.01)})
        tweenT:Play()
        Debris:AddItem(p, lifetime)
    end
end

local function effectPillar(pos, color, height, duration)
    local pillar = Instance.new("Part")
    pillar.Material = Enum.Material.Neon
    pillar.Color = color
    pillar.CanCollide = false
    pillar.Anchored = true
    pillar.CastShadow = false
    pillar.Size = Vector3.new(2.5, 0.1, 2.5)
    pillar.CFrame = CFrame.new(pos)
    pillar.TopSurface = Enum.SurfaceType.Smooth
    pillar.BottomSurface = Enum.SurfaceType.Smooth
    pillar.Parent = workspace

    local expandUp = TweenService:Create(pillar, TweenInfo.new(duration * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(2.5, height, 2.5),
        CFrame = CFrame.new(pos + Vector3.new(0, height/2, 0))
    })
    expandUp:Play()
    expandUp.Completed:Connect(function()
        local fadeOut = TweenService:Create(pillar, TweenInfo.new(duration * 0.7, Enum.EasingStyle.Quad), {
            Transparency = 1,
            Size = Vector3.new(0.1, height, 0.1)
        })
        fadeOut:Play()
    end)
    Debris:AddItem(pillar, duration + 0.1)
    addLight(pillar, color, 3, 40)
end

local function effectLightning(from, to, color, segments, thickness, lifetime)
    segments = segments or 8
    local points = {from}
    for i = 1, segments - 1 do
        local alpha = i / segments
        local mid = from:Lerp(to, alpha)
        local perp = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100)).Unit * math.random(1,4)
        table.insert(points, mid + perp)
    end
    table.insert(points, to)

    for i = 1, #points - 1 do
        local a, b = points[i], points[i+1]
        local mid = (a + b) / 2
        local dist = (b - a).Magnitude
        local seg = Instance.new("Part")
        seg.Material = Enum.Material.Neon
        seg.Color = color
        seg.CanCollide = false
        seg.Anchored = true
        seg.CastShadow = false
        seg.Size = Vector3.new(thickness or 0.15, thickness or 0.15, dist)
        seg.CFrame = CFrame.lookAt(mid, b)
        seg.TopSurface = Enum.SurfaceType.Smooth
        seg.BottomSurface = Enum.SurfaceType.Smooth
        seg.Parent = workspace
        local t = TweenService:Create(seg, TweenInfo.new(lifetime or 0.15, Enum.EasingStyle.Linear), {Transparency = 1})
        t:Play()
        Debris:AddItem(seg, (lifetime or 0.15) + 0.02)
    end
end

local function effectOrbitalRing(centerPart, radius, count, color, speed, lifetime)
    local orbs = {}
    local startAngle = 0
    local conn

    for i = 1, count do
        local orb = neonPart(Enum.PartType.Ball,
            Vector3.new(0.4, 0.4, 0.4),
            color,
            centerPart.Position)
        addLight(orb, color, 1, 12)
        table.insert(orbs, orb)
    end

    conn = RunService.Heartbeat:Connect(function(dt)
        startAngle = startAngle + dt * speed
        if not centerPart or not centerPart.Parent then
            conn:Disconnect()
            for _, o in ipairs(orbs) do Debris:AddItem(o, 0) end
            return
        end
        local center = centerPart.Position
        for i, orb in ipairs(orbs) do
            local angle = startAngle + (i / count) * math.pi * 2
            orb.CFrame = CFrame.new(
                center + Vector3.new(math.cos(angle) * radius, math.sin(angle * 0.5) * 1.5, math.sin(angle) * radius)
            )
        end
    end)

    task.delay(lifetime, function()
        conn:Disconnect()
        for _, o in ipairs(orbs) do
            local t = TweenService:Create(o, TweenInfo.new(0.2), {Transparency = 1, Size = Vector3.new(0.01,0.01,0.01)})
            t:Play()
            Debris:AddItem(o, 0.25)
        end
    end)

    return conn, orbs
end

local function effectScreenFlash(duration)
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1,0,1,0)
    flash.BackgroundColor3 = C_WHITE
    flash.BackgroundTransparency = 0.1
    flash.BorderSizePixel = 0
    flash.ZIndex = 100
    flash.Parent = playerGui:FindFirstChild("MinosPrimeGui") or playerGui:FindFirstChild("MinosActionButtonsGui") or playerGui

    local t = TweenService:Create(flash, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    t:Play()
    t.Completed:Connect(function() flash:Destroy() end)
end

local function effectGroundCracks(pos, count, color)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2 + math.random(-10,10)/10
        local length = math.random(6, 18)
        local crack = Instance.new("Part")
        crack.Material = Enum.Material.Neon
        crack.Color = color
        crack.CanCollide = false
        crack.Anchored = true
        crack.CastShadow = false
        crack.Size = Vector3.new(0.18, 0.12, 0)
        crack.CFrame = CFrame.new(pos + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, angle, 0)
        crack.TopSurface = Enum.SurfaceType.Smooth
        crack.BottomSurface = Enum.SurfaceType.Smooth
        crack.Parent = workspace

        local grow = TweenService:Create(crack, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.18, 0.12, length),
            CFrame = CFrame.new(pos + Vector3.new(0, 0.1, 0) + Vector3.new(math.cos(angle), 0, math.sin(angle)) * length/2) * CFrame.Angles(0, angle, 0)
        })
        grow:Play()
        grow.Completed:Connect(function()
            local fade = TweenService:Create(crack, TweenInfo.new(0.6), {Transparency = 1})
            fade:Play()
        end)
        Debris:AddItem(crack, 1)
    end
end

local function effectRune(pos, color, lifetime)
    local bars = {}
    for i = 1, 4 do
        local bar = neonPart(Enum.PartType.Block, Vector3.new(0.2, 0.2, 12), color, pos)
        bar.CFrame = CFrame.new(pos) * CFrame.Angles(0, (i/4)*math.pi, 0)
        addLight(bar, color, 1, 20)
        table.insert(bars, bar)
    end

    local t0 = tick()
    local spinConn
    spinConn = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - t0
        if elapsed > lifetime then
            spinConn:Disconnect()
            for _, b in ipairs(bars) do
                local ft = TweenService:Create(b, TweenInfo.new(0.3), {Transparency = 1, Size = Vector3.new(0.01,0.01,0.01)})
                ft:Play()
                Debris:AddItem(b, 0.35)
            end
            return
        end
        local progress = elapsed / lifetime
        local scale = 1 + math.sin(progress * math.pi) * 0.5
        for i, b in ipairs(bars) do
            b.CFrame = CFrame.new(pos) * CFrame.Angles(0, (i/4)*math.pi + elapsed * 3, 0)
            b.Size = Vector3.new(0.2 * (1-progress), 0.2 * (1-progress), 12 * scale)
            b.Transparency = math.max(0, progress - 0.6) / 0.4
        end
    end)
end

local function effectLightningWeb(pos, bursts, color)
    for _ = 1, bursts do
        local toPos = pos + Vector3.new(math.random(-8,8), math.random(-4,4), math.random(-8,8))
        effectLightning(pos, toPos, color, 6, 0.12, math.random(8,15)/100)
    end
end

local function effectDebrisColumn(pos, color)
    for i = 1, 20 do
        local size = math.random(2,7)/10
        local chunk = neonPart(Enum.PartType.Block,
            Vector3.new(size,size,size), color, pos + Vector3.new(math.random(-3,3),0,math.random(-3,3)))
        chunk.Anchored = false
        chunk.Material = Enum.Material.SmoothPlastic
        chunk.Color = Color3.fromRGB(80,80,80)

        local vel = Vector3.new(math.random(-20,20), math.random(30,80), math.random(-20,20))
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = vel
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bv.Parent = chunk
        Debris:AddItem(bv, 0.1)

        local glow = Instance.new("SelectionBox")
        glow.Color3 = color
        glow.LineThickness = 0.03
        glow.Adornee = chunk
        glow.Parent = chunk
        Debris:AddItem(chunk, 2.5)
    end
end

local function screenShake(magnitude, duration)
    local camera = Workspace.CurrentCamera
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - t0
        if elapsed > duration then conn:Disconnect() return end
        local pct = 1 - (elapsed / duration)
        local shake = magnitude * pct
        camera.CFrame = camera.CFrame
            * CFrame.new(
                math.random(-100,100)/100 * shake,
                math.random(-100,100)/100 * shake,
                math.random(-100,100)/100 * shake
            )
            * CFrame.Angles(
                math.random(-10,10)/1000 * shake,
                math.random(-10,10)/1000 * shake,
                math.random(-10,10)/1000 * shake
            )
    end)
end

local function getPlayerFromPart(part)
    if not part then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and part:IsDescendantOf(p.Character) then
            return p
        end
    end
end

local function getTargetAssist(origin, aimDir, maxDist)
    local bestTarget = nil
    local bestDot = 0.85
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - origin).Magnitude
                if dist <= maxDist then
                    local dirToTarget = (root.Position - origin).Unit
                    local dot = aimDir:Dot(dirToTarget)
                    if dot > bestDot then
                        bestDot = dot
                        bestTarget = p
                    end
                end
            end
        end
    end
    return bestTarget
end

local function getClosestPlayer(origin, maxDist)
    local closestTarget = nil
    local minTargetDist = maxDist
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - origin).Magnitude
                if dist < minTargetDist then
                    minTargetDist = dist
                    closestTarget = p
                end
            end
        end
    end
    return closestTarget
end

local function blastParts(pos, radius)
    pcall(function()
        sethiddenproperty(player, "SimulationRadius", 100000)
        sethiddenproperty(player, "MaxSimulationRadius", 100000)
    end)
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    local parts = workspace:GetPartBoundsInRadius(pos, radius, params)
    for _, p in ipairs(parts) do
        if p:IsA("BasePart") and not p.CanCollide then
            local isChar = false
            local model = p:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChild("Humanoid") then
                isChar = true
            end
            if not isChar then
                p.Anchored = false
                p.CanCollide = true
                local dir = (p.Position - pos).Unit
                if dir.Magnitude == 0 or tostring(dir) == "NAN" then dir = Vector3.new(0, 1, 0) end
                p.AssemblyLinearVelocity = dir * math.random(100, 200) + Vector3.new(0, math.random(100, 200), 0)
                p.AssemblyAngularVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
            end
        end
    end
end

local FX = {}

FX.original = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogColor = Lighting.FogColor,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "MinosSpawn_ColorCorrection"
colorCorrection.Brightness = 0
colorCorrection.Contrast = 0
colorCorrection.Saturation = 0
colorCorrection.TintColor = Color3.new(1, 1, 1)
colorCorrection.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Name = "MinosSpawn_Bloom"
bloom.Intensity = 0
bloom.Size = 24
bloom.Threshold = 1.4
bloom.Parent = Lighting

local blur = Instance.new("BlurEffect")
blur.Name = "MinosSpawn_Blur"
blur.Size = 0
blur.Parent = Lighting

local function tween(obj, props, time, style, dir)
    return TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.Out), props)
end

function FX.DarkenAtmosphere(inTime)
    tween(Lighting, {
        Brightness = 0.05,
        ClockTime = 0,
        FogColor = Color3.fromRGB(0, 0, 0),
        FogStart = 4,
        FogEnd = 60,
        Ambient = Color3.fromRGB(0, 0, 0),
        OutdoorAmbient = Color3.fromRGB(0, 0, 0),
    }, inTime):Play()

    tween(colorCorrection, {
        Brightness = -0.25,
        Contrast = 0.2,
        Saturation = -0.6,
        TintColor = Color3.fromRGB(150, 190, 255),
    }, inTime):Play()

    tween(bloom, { Intensity = 1.6 }, inTime):Play()
    tween(blur, { Size = 2 }, inTime):Play()
end

function FX.RestoreAtmosphere(outTime)
    tween(Lighting, {
        Brightness = FX.original.Brightness,
        ClockTime = FX.original.ClockTime,
        FogColor = FX.original.FogColor,
        FogStart = FX.original.FogStart,
        FogEnd = FX.original.FogEnd,
        Ambient = FX.original.Ambient,
        OutdoorAmbient = FX.original.OutdoorAmbient,
    }, outTime):Play()

    tween(colorCorrection, { Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.new(1,1,1) }, outTime):Play()
    tween(bloom, { Intensity = 0 }, outTime):Play()
    tween(blur, { Size = 0 }, outTime):Play()

    task.delay(outTime + 0.5, function()
        pcall(function()
            colorCorrection:Destroy()
            bloom:Destroy()
            blur:Destroy()
        end)
    end)
end

function FX.CreateSpawnLight(parentPart)
    local light = Instance.new("PointLight")
    light.Name = "MinosSpawn_Light"
    light.Color = Color3.fromRGB(90, 150, 255)
    light.Range = 0
    light.Brightness = 0
    light.Shadows = true
    light.Parent = parentPart

    tween(light, { Range = 26, Brightness = 4 }, 0.8):Play()

    task.spawn(function()
        while light.Parent do
            tween(light, { Brightness = 6 }, 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
            task.wait(0.6)
            if not light.Parent then break end
            tween(light, { Brightness = 3 }, 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Play()
            task.wait(0.6)
        end
    end)

    return light
end

function FX.CreateRisingMotes(parentPart)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "MinosSpawn_Motes"
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Color = ColorSequence.new(Color3.fromRGB(120, 180, 255), Color3.fromRGB(60, 100, 220))
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(0.5, 0.35),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.8, 0.4),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Lifetime = NumberRange.new(1.5, 3)
    emitter.Rate = 40
    emitter.Speed = NumberRange.new(2, 5)
    emitter.SpreadAngle = Vector2.new(35, 35)
    emitter.Acceleration = Vector3.new(0, 6, 0)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-60, 60)
    emitter.LightEmission = 0.85
    emitter.LightInfluence = 0
    emitter.Parent = parentPart
    return emitter
end

function FX.DescendingOrb(targetPosition, onShatter)
    local orb = Instance.new("Part")
    orb.Shape = Enum.PartType.Ball
    orb.Material = Enum.Material.Glass
    orb.Color = Color3.fromRGB(120, 190, 255)
    orb.Transparency = 0.35
    orb.Anchored = true
    orb.CanCollide = false
    orb.CastShadow = false
    orb.Size = Vector3.new(3, 3, 3)
    orb.CFrame = CFrame.new(targetPosition + Vector3.new(0, 40, 0))
    orb.Parent = workspace

    local orbLight = Instance.new("PointLight")
    orbLight.Color = Color3.fromRGB(100, 170, 255)
    orbLight.Range = 22
    orbLight.Brightness = 5
    orbLight.Parent = orb

    local fallTween = tween(orb, { CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0)) }, 1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    fallTween:Play()
    fallTween.Completed:Wait()

    orbLight.Brightness = 14
    orb.Transparency = 1

    for i = 1, 10 do
        local shard = Instance.new("Part")
        shard.Size = Vector3.new(math.random(2,5)/10, math.random(2,5)/10, math.random(2,5)/10)
        shard.Material = Enum.Material.Glass
        shard.Color = Color3.fromRGB(120, 190, 255)
        shard.Anchored = false
        shard.CanCollide = false
        shard.CastShadow = false
        shard.Transparency = 0.1
        shard.CFrame = orb.CFrame * CFrame.new(math.random(-15,15)/10, math.random(-15,15)/10, math.random(-15,15)/10)
        shard.Parent = workspace

        local vel = Vector3.new(math.random(-10,10), math.random(2,10), math.random(-10,10))
        task.spawn(function()
            local t = tick()
            local startCFrame = shard.CFrame
            local conn
            conn = RunService.Heartbeat:Connect(function(dt)
                local e = tick() - t
                if e > 0.6 or not shard.Parent then conn:Disconnect() return end
                shard.CFrame = startCFrame + vel * e
                shard.Transparency = 0.1 + (e / 0.6) * 0.9
            end)
        end)
        Debris:AddItem(shard, 0.8)
    end

    orb:Destroy()
    if onShatter then onShatter() end
end

function FX.LightningFlicker(count, spotAbove)
    count = count or 3
    task.spawn(function()
        for i = 1, count do
            task.wait(math.random(15, 45) / 100)
            local flickerLight = Instance.new("PointLight")
            flickerLight.Color = Color3.fromRGB(200, 220, 255)
            flickerLight.Range = 60
            flickerLight.Brightness = 10
            flickerLight.Parent = spotAbove

            tween(flickerLight, { Brightness = 0, Range = 0 }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
            tween(colorCorrection, { Brightness = 0.15 }, 0.03):Play()
            task.delay(0.03, function()
                tween(colorCorrection, { Brightness = -0.25 }, 0.25):Play()
            end)

            local id = getsfxid("thunder")
            if id ~= "nil" then sfx(id, workspace, 1.2) end
            Debris:AddItem(flickerLight, 0.3)
        end
    end)
end

function FX.GroundShockwaveRing(position, color)
    color = color or Color3.fromRGB(140, 200, 255)

    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.Anchored = true
    ring.CanCollide = false
    ring.CastShadow = false
    ring.Size = Vector3.new(0.3, 1, 1)
    ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring.Transparency = 0.2
    ring.Parent = workspace

    tween(ring, { Size = Vector3.new(0.3, 40, 40), Transparency = 1 }, 1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    Debris:AddItem(ring, 1.2)

    for i = 1, 8 do
        local angle = (i / 8) * math.pi * 2
        local crack = Instance.new("Part")
        crack.Size = Vector3.new(0.2, 0.05, 0.2)
        crack.Material = Enum.Material.Neon
        crack.Color = color
        crack.Anchored = true
        crack.CanCollide = false
        crack.CastShadow = false
        crack.Transparency = 0.3
        local dir = Vector3.new(math.cos(angle), 0, math.sin(angle))
        crack.CFrame = CFrame.new(position) * CFrame.Angles(0, angle, 0)
        crack.Parent = workspace

        local targetLength = math.random(10, 18)
        task.spawn(function()
            local t0 = tick()
            while crack.Parent and tick() - t0 < 0.5 do
                local a = math.clamp((tick() - t0) / 0.5, 0, 1)
                crack.Size = Vector3.new(0.2 + a * 0.15, 0.05, targetLength * a)
                crack.CFrame = CFrame.new(position + dir * (targetLength * a / 2)) * CFrame.Angles(0, angle, 0)
                RunService.Heartbeat:Wait()
            end
        end)
        tween(crack, { Transparency = 1 }, 1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
        Debris:AddItem(crack, 1.8)
    end

    local id = getsfxid("impact")
    if id ~= "nil" then sfx(id, workspace, 2) end
end

function FX.ChainBurst(position, chainCount)
    chainCount = chainCount or 6
    for i = 1, chainCount do
        task.delay((i - 1) * 0.06, function()
            local angle = math.random() * math.pi * 2
            local dist = math.random(6, 14)
            local dropPos = position + Vector3.new(math.cos(angle) * dist, 25, math.sin(angle) * dist)
            local groundPos = position + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)

            local chain = Instance.new("Part")
            chain.Size = Vector3.new(0.6, 6, 0.6)
            chain.Material = Enum.Material.Metal
            chain.Color = Color3.fromRGB(30, 30, 35)
            chain.Anchored = true
            chain.CanCollide = false
            chain.CastShadow = true
            chain.CFrame = CFrame.new(dropPos)
            chain.Parent = workspace

            local rust = Instance.new("PointLight")
            rust.Color = Color3.fromRGB(120, 170, 255)
            rust.Range = 6
            rust.Brightness = 1.5
            rust.Parent = chain

            local fall = tween(chain, { CFrame = CFrame.new(groundPos) * CFrame.Angles(0, math.rad(math.random(0,360)), 0) }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            fall:Play()
            fall.Completed:Connect(function()
                local id = getsfxid("chainclank")
                if id ~= "nil" then sfx(id, chain, 1.5) end
                tween(chain, { Transparency = 1 }, 2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In):Play()
            end)
            Debris:AddItem(chain, 3)
        end)
    end
end

function FX.EyeGlow(char)
    local head = char:FindFirstChild("Head")
    if not head then return nil end

    local eyeLight = Instance.new("PointLight")
    eyeLight.Name = "MinosSpawn_EyeGlow"
    eyeLight.Color = Color3.fromRGB(255, 30, 30)
    eyeLight.Range = 0
    eyeLight.Brightness = 0
    eyeLight.Parent = head

    tween(eyeLight, { Range = 8, Brightness = 5 }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()

    task.spawn(function()
        while eyeLight.Parent do
            tween(eyeLight, { Brightness = 7 }, 0.3):Play()
            task.wait(0.3)
            if not eyeLight.Parent then break end
            tween(eyeLight, { Brightness = 4 }, 0.3):Play()
            task.wait(0.3)
        end
    end)

    return eyeLight
end

function FX.LightPillars(position, count, color)
    count = count or 6
    color = color or Color3.fromRGB(150, 200, 255)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local offset = Vector3.new(math.cos(angle) * 4, 0, math.sin(angle) * 4)
        local pillar = Instance.new("Part")
        pillar.Size = Vector3.new(1, 0.1, 1)
        pillar.Material = Enum.Material.Neon
        pillar.Color = color
        pillar.Anchored = true
        pillar.CanCollide = false
        pillar.CastShadow = false
        pillar.Transparency = 0.25
        pillar.CFrame = CFrame.new(position + offset + Vector3.new(0, 0.05, 0))
        pillar.Parent = workspace

        tween(pillar, { Size = Vector3.new(1, 30, 1) }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
        task.delay(0.5, function()
            tween(pillar, { Transparency = 1, Size = Vector3.new(1, 34, 1) }, 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
        end)
        Debris:AddItem(pillar, 1.5)
    end
end

function FX.JudgementCard(titleText, subtitleText)
    local gui = Instance.new("ScreenGui")
    gui.Name = "MinosSpawn_JudgementCard"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999998
    gui.Parent = playerGui

    local barTop = Instance.new("Frame")
    barTop.Size = UDim2.new(1, 0, 0, 3)
    barTop.Position = UDim2.new(0, 0, 0.38, 0)
    barTop.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    barTop.BorderSizePixel = 0
    barTop.BackgroundTransparency = 1
    barTop.Parent = gui

    local barBottom = barTop:Clone()
    barBottom.Position = UDim2.new(0, 0, 0.62, 0)
    barBottom.Parent = gui

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0.4, 0)
    title.Font = Enum.Font.Antique
    title.Text = titleText or "MINOS PRIME"
    title.TextColor3 = Color3.fromRGB(210, 230, 255)
    title.TextTransparency = 1
    title.TextStrokeTransparency = 1
    title.TextStrokeColor3 = Color3.fromRGB(20, 20, 30)
    title.TextScaled = true
    title.Parent = gui

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1, 0, 0.05, 0)
    subtitle.Position = UDim2.new(0, 0, 0.5, 0)
    subtitle.Font = Enum.Font.Antique
    subtitle.Text = subtitleText or "JUDGE OF HELL"
    subtitle.TextColor3 = Color3.fromRGB(150, 30, 30)
    subtitle.TextTransparency = 1
    subtitle.TextStrokeTransparency = 1
    subtitle.TextScaled = true
    subtitle.Parent = gui

    tween(barTop, { BackgroundTransparency = 0.1, Position = UDim2.new(0, 0, 0.4, 0) }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    tween(barBottom, { BackgroundTransparency = 0.1, Position = UDim2.new(0, 0, 0.6, 0) }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    tween(title, { TextTransparency = 0, TextStrokeTransparency = 0.4 }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    task.delay(0.15, function()
        tween(subtitle, { TextTransparency = 0.1, TextStrokeTransparency = 0.5 }, 0.6):Play()
    end)

    task.delay(2.6, function()
        tween(barTop, { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0.36, 0) }, 0.6):Play()
        tween(barBottom, { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0.64, 0) }, 0.6):Play()
        tween(title, { TextTransparency = 1, TextStrokeTransparency = 1 }, 0.6):Play()
        tween(subtitle, { TextTransparency = 1, TextStrokeTransparency = 1 }, 0.6):Play()
        Debris:AddItem(gui, 0.8)
    end)
end

function FX.RedVignettePulse(duration)
    duration = duration or 0.45
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999997
    gui.Parent = playerGui

    local vignette = Instance.new("Frame")
    vignette.Size = UDim2.fromScale(1, 1)
    vignette.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    vignette.BorderSizePixel = 0
    vignette.BackgroundTransparency = 1
    vignette.Parent = gui

    tween(vignette, { BackgroundTransparency = 0.75 }, duration * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    task.delay(duration * 0.3, function()
        tween(vignette, { BackgroundTransparency = 1 }, duration * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
        Debris:AddItem(gui, duration + 0.3)
    end)
end

function FX.JudgementGroundGlyph(position, duration)
    duration = duration or 5
    local glyph = Instance.new("Part")
    glyph.Shape = Enum.PartType.Cylinder
    glyph.Material = Enum.Material.Neon
    glyph.Color = Color3.fromRGB(100, 180, 255)
    glyph.Anchored = true
    glyph.CanCollide = false
    glyph.CastShadow = false
    glyph.Size = Vector3.new(0.05, 1, 1)

    local startPos = position - Vector3.new(0, 2.7, 0)
    glyph.CFrame = CFrame.new(startPos) * CFrame.Angles(0, 0, math.rad(90))
    glyph.Transparency = 0.8
    glyph.Parent = workspace

    tween(glyph, { Size = Vector3.new(0.05, 16, 16), Transparency = 0.25 }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()

    local conn
    local t0 = tick()
    conn = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - t0
        if elapsed >= duration or not glyph.Parent then
            conn:Disconnect()
            return
        end
        glyph.CFrame = CFrame.new(startPos) * CFrame.Angles(0, elapsed * 3, 0) * CFrame.Angles(0, 0, math.rad(90))
    end)

    task.delay(duration - 0.8, function()
        tween(glyph, { Transparency = 1, Size = Vector3.new(0.05, 0.1, 0.1) }, 0.8):Play()
    end)
    Debris:AddItem(glyph, duration + 0.2)
end

function FX.OrbitalAuraSpiral(parentPart, duration)
    duration = duration or 5
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "MinosSpawn_AuraSpiral"
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Color = ColorSequence.new(Color3.fromRGB(140, 200, 255), Color3.fromRGB(255, 60, 60))
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0.7),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Lifetime = NumberRange.new(1, 1.8)
    emitter.Rate = 50
    emitter.Speed = NumberRange.new(4, 7)
    emitter.SpreadAngle = Vector2.new(180, 0)
    emitter.Acceleration = Vector3.new(0, 7, 0)
    emitter.LightEmission = 0.95
    emitter.Parent = parentPart

    task.delay(duration - 1, function()
        emitter.Enabled = false
        Debris:AddItem(emitter, 1.5)
    end)
end

local CameraController = {
    ActiveConnection = nil,
    ShakeStart = 0,
    ShakeDur = 0,
    ShakeStr = 0
}

function CameraController.TriggerShake(duration, strength)
    CameraController.ShakeStart = tick()
    CameraController.ShakeDur = duration
    CameraController.ShakeStr = strength
end

function CameraController.GetShakeCFrame()
    local elapsed = tick() - CameraController.ShakeStart
    if elapsed < CameraController.ShakeDur then
        local fade = 1 - (elapsed / CameraController.ShakeDur)
        local str = CameraController.ShakeStr
        local x = (math.random() - 0.5) * 2 * str * fade
        local y = (math.random() - 0.5) * 2 * str * fade
        local rx = math.rad((math.random() - 0.5) * 6 * fade)
        local ry = math.rad((math.random() - 0.5) * 6 * fade)
        local rz = math.rad((math.random() - 0.5) * 3 * fade)
        return CFrame.new(x, y, 0) * CFrame.Angles(rx, ry, rz)
    end
    return CFrame.new()
end

function CameraController.PlayTopDownZoom(duration)
    if CameraController.ActiveConnection then CameraController.ActiveConnection:Disconnect() end
    camera.CameraType = Enum.CameraType.Scriptable

    local targetHead = hrp.Position + Vector3.new(0, 1.8, 0)
    local startCamPos = targetHead + Vector3.new(0, 22, 0)
    local endCamPos = targetHead + Vector3.new(0, 4.5, 0)

    local startTime = tick()
    local startFOV = 70
    local targetFOV = 35

    local upVector = hrp.CFrame.LookVector
    if upVector.Magnitude < 0.1 then upVector = Vector3.new(0, 0, -1) end

    CameraController.ActiveConnection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local alpha = math.clamp(elapsed / duration, 0, 1)

        local currentPos = startCamPos:Lerp(endCamPos, alpha)
        local currentLook = hrp.Position + Vector3.new(0, 1.2, 0)

        camera.CFrame = CFrame.lookAt(currentPos, currentLook, upVector) * CameraController.GetShakeCFrame()
        camera.FieldOfView = startFOV + (targetFOV - startFOV) * alpha
    end)
end

function CameraController.PlayAnim2Camera(duration, startPosition)
    if CameraController.ActiveConnection then CameraController.ActiveConnection:Disconnect() end
    camera.CameraType = Enum.CameraType.Scriptable

    local yawCFrame = CFrame.Angles(0, math.rad(hrp.Orientation.Y), 0)
    local frontDir = yawCFrame.LookVector

    local startCamPos = startPosition + (frontDir * 10) + Vector3.new(0, 1.8, 0)
    local endCamPos = startPosition + (frontDir * 7) + Vector3.new(0, 1.2, 0)

    local startTime = tick()
    local startFOV = 40
    local targetFOV = 35

    CameraController.ActiveConnection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local alpha = math.clamp(elapsed / duration, 0, 1)
        local easedAlpha = math.sin(alpha * (math.pi / 2))

        local currentPos = startCamPos:Lerp(endCamPos, easedAlpha)
        local lookTarget = hrp.Position + Vector3.new(0, 1.5, 0)

        camera.CFrame = CFrame.lookAt(currentPos, lookTarget) * CameraController.GetShakeCFrame()
        camera.FieldOfView = startFOV + (targetFOV - startFOV) * easedAlpha
    end)
end

function CameraController.StartOrbitCamera(duration)
    if CameraController.ActiveConnection then CameraController.ActiveConnection:Disconnect() end
    camera.CameraType = Enum.CameraType.Scriptable

    local orbitRadius = 11
    local height = 2.2
    local orbitSpeed = 1.4
    local startTime = tick()
    local startFOV = camera.FieldOfView
    local targetFOV = 38

    CameraController.ActiveConnection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local angle = elapsed * orbitSpeed

        local offset = Vector3.new(math.cos(angle) * orbitRadius, height + math.sin(elapsed * 2) * 0.4, math.sin(angle) * orbitRadius)
        local cameraPosition = hrp.Position + offset
        local lookTarget = hrp.Position + Vector3.new(0, 1.5, 0)

        camera.CFrame = CFrame.new(cameraPosition, lookTarget) * CameraController.GetShakeCFrame()

        local fovAlpha = math.clamp(elapsed / 0.8, 0, 1)
        camera.FieldOfView = startFOV + (targetFOV - startFOV) * fovAlpha + math.sin(elapsed * 2.5) * 1.2
    end)
end

function CameraController.SmoothReturnCamera(duration)
    if CameraController.ActiveConnection then CameraController.ActiveConnection:Disconnect() end
    camera.CameraType = Enum.CameraType.Scriptable

    local startCFrame = camera.CFrame
    local startFOV = camera.FieldOfView
    local targetFOV = 70
    local startTime = tick()

    CameraController.ActiveConnection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local alpha = math.clamp(elapsed / duration, 0, 1)
        local easedAlpha = 1 - (1 - alpha) * (1 - alpha)

        local targetCFrame = hrp.CFrame * CFrame.new(0, 2.5, 12)
        targetCFrame = CFrame.new(targetCFrame.Position, hrp.Position + Vector3.new(0, 1.5, 0))

        camera.CFrame = startCFrame:Lerp(targetCFrame, easedAlpha) * CameraController.GetShakeCFrame()
        camera.FieldOfView = startFOV + (targetFOV - startFOV) * easedAlpha

        if alpha >= 1 then
            if CameraController.ActiveConnection then
                CameraController.ActiveConnection:Disconnect()
                CameraController.ActiveConnection = nil
            end
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = humanoid
            camera.FieldOfView = targetFOV
        end
    end)
end

local function executeDie()
    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera

        if humanoid.FloorMaterial ~= Enum.Material.Air then
            return
        end

        local AIM_DURATION = 1.5
        local MAX_DISTANCE = 160
        local UNANCHOR_DELAY = 0.085
        local DASH_DISTANCE = 20

        if not ReplicatedStorage:FindFirstChild("neo'sfling") then
            local d = Instance.new("Decal")
            d.Name = "neo'sfling"
            d.Parent = ReplicatedStorage
        end

        local a1 = Instance.new("Animation")
        a1.AnimationId = "rbxassetid://184573779"
        local t1 = humanoid:LoadAnimation(a1)
        local a2 = Instance.new("Animation")
        a2.AnimationId = "rbxassetid://97170520"
        local t2 = humanoid:LoadAnimation(a2)
        local a3 = Instance.new("Animation")
        a3.AnimationId = "rbxassetid://220512718"
        local t3 = humanoid:LoadAnimation(a3)
        local a4 = Instance.new("Animation")
        a4.AnimationId = "rbxassetid://85836344"
        local t4 = humanoid:LoadAnimation(a4)

        humanoid.Sit = true
        humanoid.AutoRotate = false
        local floatPos = hrp.Position

        t1:Play(0.3)
        t1.TimePosition = 0.5
        t1:AdjustSpeed(0)
        t2:Play(0.3)
        t2.TimePosition = 0.5
        t2:AdjustSpeed(0)

        local chargeCore = neonPart(Enum.PartType.Ball, Vector3.new(1.5, 1.5, 1.5), C_BRIGHT, hrp.Position)
        chargeCore.Anchored = true
        addLight(chargeCore, C_CORE, 4, 35)

        local orbConn1, orbs1 = effectOrbitalRing(hrp, 4, 8, C_CORE, 2.5, AIM_DURATION)
        local orbConn2, orbs2 = effectOrbitalRing(hrp, 6, 10, C_MID, 2.0, AIM_DURATION)

        local chargeCount = 0
        local chargeConn
        local isAiming = true
        local finalAimDir = camera.CFrame.LookVector

        chargeConn = RunService.Heartbeat:Connect(function()
            chargeCount += 1
            if not isAiming then
                chargeConn:Disconnect()
                return
            end

            chargeCore.CFrame = CFrame.new(hrp.Position)
            local pulse = 1.5 + math.sin(chargeCount * 0.25) * 0.5
            chargeCore.Size = Vector3.new(pulse, pulse, pulse)

            if chargeCount % 3 == 0 then
                effectSplash(hrp.Position, 3, 8, C_CORE, 0.4, 20)
            end
            if chargeCount % 12 == 0 then
                local tip = hrp.Position + Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
                effectLightning(hrp.Position, tip, C_BRIGHT, 5, 0.1, 0.1)
            end
        end)

        local aimConn
        aimConn = RunService.RenderStepped:Connect(function()
            if not isAiming then
                aimConn:Disconnect()
                return
            end
            finalAimDir = camera.CFrame.LookVector
            hrp.CFrame = CFrame.lookAt(floatPos, floatPos + finalAimDir)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        task.wait(AIM_DURATION)

        isAiming = false
        humanoid.Sit = false
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        t1:Stop(0.3)
        t2:Stop(0.3)

        local coreDestroyTween = TweenService:Create(chargeCore, TweenInfo.new(0.15), {Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1)})
        coreDestroyTween:Play()
        Debris:AddItem(chargeCore, 0.2)

        effectShockwaveBurst(hrp.Position)
        effectSplash(hrp.Position, 30, 20, C_BRIGHT, 0.6, 40)
        effectSplash(hrp.Position, 20, 14, C_CORE, 0.8, 20)
        effectPillar(hrp.Position, C_BRIGHT, 50, 1.0)
        effectRune(hrp.Position, C_CORE, 0.6)
        effectLightningWeb(hrp.Position, 12, C_BRIGHT)
        effectScreenFlash(0.2)
        screenShake(1.8, 0.4)
        sound("129146504545701", 5)
        sound("112192533344145", 2)

        task.wait(0.05)

        local nearbyPlayer = getTargetAssist(hrp.Position, finalAimDir, MAX_DISTANCE)

        if nearbyPlayer then
            local tRoot = nearbyPlayer.Character and nearbyPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                hrp.CFrame = CFrame.lookAt(tRoot.Position, tRoot.Position + finalAimDir)
            end
            task.wait(0.02)

            t3:Play(0.2)
            t3.TimePosition = 0.3
            t3:AdjustSpeed(0.5)
            t4:Play(0.2)
            t4.TimePosition = 0
            t4:AdjustSpeed(1)

            if tRoot then
                effectShockwaveBurst(tRoot.Position)
                effectPillar(tRoot.Position, C_BRIGHT, 30, 0.7)
                effectLightningWeb(tRoot.Position, 16, C_BRIGHT)
                effectGroundCracks(tRoot.Position, 14, C_CORE)
                effectDebrisColumn(tRoot.Position, C_CORE)
                screenShake(2.5, 0.5)
                effectScreenFlash(0.15)
            end

            local attachActive = true
            local execFxCount = 0

            local attachConn = RunService.Heartbeat:Connect(function()
                local tc = nearbyPlayer and nearbyPlayer.Character
                local tr = tc and tc:FindFirstChild("HumanoidRootPart")
                if not character or not tr or not attachActive then
                    return
                end
                pcall(function()
                    sethiddenproperty(hrp, "PhysicsRepRootPart", tr)
                end)

                hrp.CFrame = tr.CFrame * CFrame.new(0, -5, 0)

                execFxCount += 1
                if execFxCount % 4 == 0 then
                    effectSplash(tr.Position, 4, 12, C_CORE, 0.3, 30)
                    if execFxCount % 16 == 0 then
                        effectLightning(tr.Position, tr.Position + Vector3.new(math.random(-6, 6), math.random(2, 8), math.random(-6, 6)), C_BRIGHT, 5, 0.1, 0.08)
                    end
                end
            end)

            task.spawn(function()
                local mv = 0.1
                while attachActive do
                    RunService.Heartbeat:Wait()
                    if not attachActive then
                        break
                    end
                    local v = hrp.Velocity
                    hrp.Velocity = v * 8.5 + Vector3.new(0, 8.5, 0)
                    RunService.RenderStepped:Wait()
                    if not attachActive then
                        break
                    end
                    hrp.Velocity = v
                    RunService.Stepped:Wait()
                    if not attachActive then
                        break
                    end
                    hrp.Velocity = v + Vector3.new(0, mv, 0)
                    mv = -mv
                end
            end)

            task.wait(UNANCHOR_DELAY + 0.5)
            attachActive = false
            attachConn:Disconnect()
            t3:Stop(0.2)
            t4:Stop(0.2)

            if tRoot and tRoot.Parent then
                local fp = tRoot.Position
                effectShockwaveBurst(fp)
                effectShockwaveBurst(fp + Vector3.new(0, 2, 0))
                effectSplash(fp, 50, 28, C_BRIGHT, 0.8, 60)
                effectSplash(fp, 40, 18, C_CORE, 1.0, 30)
                effectPillar(fp, C_BRIGHT, 80, 1.5)
                effectPillar(fp, C_CORE, 60, 1.2)
                effectRune(fp, C_BRIGHT, 0.8)
                effectGroundCracks(fp, 20, C_MID)
                effectDebrisColumn(fp, C_MID)
                effectLightningWeb(fp, 24, C_BRIGHT)

                local lightPart = Instance.new("Part")
                lightPart.Transparency = 1
                lightPart.Anchored = true
                lightPart.CanCollide = false
                lightPart.Position = fp
                lightPart.Parent = workspace
                addLight(lightPart, C_BRIGHT, 8, 80)
                Debris:AddItem(lightPart, 1.0)

                effectScreenFlash(0.35)
                screenShake(4.0, 0.6)
            end
        else
            local dashDir = finalAimDir
            if dashDir.Magnitude < 0.05 then
                dashDir = hrp.CFrame.LookVector
            end
            if dashDir.Magnitude < 0.05 then
                dashDir = Vector3.new(0, 0, -1)
            end
            dashDir = dashDir.Unit

            local rcParams = RaycastParams.new()
            rcParams.FilterDescendantsInstances = {character}
            rcParams.FilterType = Enum.RaycastFilterType.Exclude
            local dashRc = Workspace:Raycast(hrp.Position, dashDir * DASH_DISTANCE, rcParams)

            local dashPos = hrp.Position + dashDir * DASH_DISTANCE
            if dashRc then
                dashPos = dashRc.Position - dashDir * 2
            end

            humanoid.Sit = false
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

            local dashConn
            local moved = 0
            local dashTime = 0.18
            local dashSpeed = DASH_DISTANCE / dashTime

            dashConn = RunService.Heartbeat:Connect(function(dt)
                if not hrp.Parent or humanoid.Health <= 0 then
                    dashConn:Disconnect()
                    return
                end
                local step = math.min(dashSpeed * dt, DASH_DISTANCE - moved)
                moved += step
                hrp.CFrame = hrp.CFrame + dashDir * step
                hrp.AssemblyLinearVelocity = dashDir * 8
                hrp.AssemblyAngularVelocity = Vector3.zero
                if moved >= DASH_DISTANCE then
                    dashConn:Disconnect()
                end
            end)

            effectShockwaveBurst(dashPos)
            effectGroundCracks(dashPos, 10, C_CORE)
            screenShake(1.5, 0.3)
            task.wait(dashTime)
            hrp.CFrame = CFrame.lookAt(dashPos, dashPos + dashDir)
            humanoid.Sit = false
            humanoid.PlatformStand = false
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        local cl = hrp.CFrame.LookVector
        local flat = Vector3.new(cl.X, 0, cl.Z)
        if flat.Magnitude < 0.05 then
            flat = Vector3.new(0, 0, -1)
        end
        flat = flat.Unit
        hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flat)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.Anchored = false
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)
end

local function executeCrush()
    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera

        if humanoid.FloorMaterial ~= Enum.Material.Air then
            return
        end

        local AIM_DURATION = 0.7
        local MAX_DISTANCE = 300
        local UNANCHOR_DELAY = 0.081

        if not ReplicatedStorage:FindFirstChild("neo'sfling") then
            local d = Instance.new("Decal"); d.Name = "neo'sfling"; d.Parent = ReplicatedStorage
        end

        sound("138937922522006", 2)

        local a1 = Instance.new("Animation"); a1.AnimationId = "rbxassetid://56146409"; local tr1 = humanoid:LoadAnimation(a1)
        local a2 = Instance.new("Animation"); a2.AnimationId = "rbxassetid://97170520"; local tr2 = humanoid:LoadAnimation(a2)
        local a3 = Instance.new("Animation"); a3.AnimationId = "rbxassetid://220512718"; local tr3 = humanoid:LoadAnimation(a3)

        humanoid.Sit = true
        humanoid.AutoRotate = false
        local floatPos = hrp.Position

        tr1:Play(0.2); tr1.TimePosition = 1; tr1:AdjustSpeed(0)
        tr2:Play(0.2); tr2.TimePosition = 0.5; tr2:AdjustSpeed(0)
        tr3:Play(0.5); tr3.TimePosition = 0; tr3:AdjustSpeed(1)

        local crushCore = neonPart(Enum.PartType.Ball, Vector3.new(2,2,2), C_MID, hrp.Position)
        addLight(crushCore, C_MID, 5, 40)

        local crushOrbConn, crushOrbs = effectOrbitalRing(hrp, 3, 6, C_CORE, 3.5, AIM_DURATION)

        local crushCount = 0
        local isAiming = true
        local finalAimDir = camera.CFrame.LookVector

        local chargeConn = RunService.Heartbeat:Connect(function()
            crushCount += 1
            if not isAiming then return end
            crushCore.CFrame = CFrame.new(hrp.Position)
            local p = 2 + math.sin(crushCount * 0.3) * 0.8
            crushCore.Size = Vector3.new(p,p,p)

            if crushCount % 4 == 0 then
                effectSplash(hrp.Position, 4, 10, C_MID, 0.5, -30)
            end
            if crushCount % 10 == 0 then
                effectLightning(hrp.Position, hrp.Position + Vector3.new(math.random(-4,4), -math.random(3,8), math.random(-4,4)), C_MID, 6, 0.12, 0.1)
            end
        end)

        local aimConn = RunService.RenderStepped:Connect(function()
            if not isAiming then return end
            finalAimDir = camera.CFrame.LookVector
            hrp.CFrame = CFrame.lookAt(floatPos, floatPos + finalAimDir)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        task.wait(AIM_DURATION)
        isAiming = false
        chargeConn:Disconnect()
        aimConn:Disconnect()
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        tr1:Stop(0.2); tr2:Stop(0.2); tr3:Stop(0.5)

        TweenService:Create(crushCore, TweenInfo.new(0.1), {Transparency=1,Size=Vector3.new(0.01,0.01,0.01)}):Play()
        Debris:AddItem(crushCore, 0.15)

        effectSplash(hrp.Position, 40, 18, C_MID, 0.7, -20)
        effectShockwaveBurst(hrp.Position)
        effectLightningWeb(hrp.Position, 10, C_MID)
        effectScreenFlash(0.12)
        screenShake(2.0, 0.4)
        sound("112192533344145", 1)

        task.wait(0.05)

        local rcParams = RaycastParams.new()
        rcParams.FilterDescendantsInstances = {character}
        rcParams.FilterType = Enum.RaycastFilterType.Exclude
        local rcResult = Workspace:Raycast(hrp.Position, Vector3.new(0, -MAX_DISTANCE, 0), rcParams)

        local nearbyPlayer = getClosestPlayer(hrp.Position, MAX_DISTANCE)

        if rcResult or nearbyPlayer then
            local targetPos = rcResult and rcResult.Position or hrp.Position - Vector3.new(0, MAX_DISTANCE, 0)

            if nearbyPlayer then
                local th = nearbyPlayer.Character:FindFirstChild("HumanoidRootPart")
                if th then targetPos = th.Position end
            end

            if nearbyPlayer then
                hrp.CFrame = CFrame.lookAt(targetPos, targetPos + finalAimDir)
                task.wait(0.02)

                local tRoot = nearbyPlayer.Character and nearbyPlayer.Character:FindFirstChild("HumanoidRootPart")

                local landPos = tRoot and tRoot.Position or targetPos
                effectShockwaveBurst(landPos)
                effectGroundCracks(landPos, 18, C_MID)
                effectDebrisColumn(landPos, C_MID)
                effectPillar(landPos, C_MID, 40, 0.9)
                effectSplash(landPos, 50, 25, C_MID, 0.8, 10)
                effectLightningWeb(landPos, 14, C_BRIGHT)
                effectScreenFlash(0.25)
                screenShake(3.5, 0.7)
                blastParts(landPos, 50)

                local attachActive = true
                local attachConn = RunService.Heartbeat:Connect(function()
                    local tc = nearbyPlayer and nearbyPlayer.Character
                    local tr = tc and tc:FindFirstChild("HumanoidRootPart")
                    if not character or not tr or not attachActive then return end
                    pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", tr) end)
                    hrp.CFrame = tr.CFrame * CFrame.new(0, -5, 0)
                end)

                task.spawn(function()
                    local mv = 0.1
                    while attachActive do
                        RunService.Heartbeat:Wait(); if not attachActive then break end
                        local v = hrp.Velocity
                        hrp.Velocity = v * 7.7 + Vector3.new(0,7.7,0)
                        RunService.RenderStepped:Wait(); if not attachActive then break end
                        hrp.Velocity = v
                        RunService.Stepped:Wait(); if not attachActive then break end
                        hrp.Velocity = v + Vector3.new(0,mv,0); mv=-mv
                    end
                end)

                task.wait(UNANCHOR_DELAY)
                attachActive = false
                attachConn:Disconnect()

                if tRoot and tRoot.Parent then
                    effectShockwaveBurst(tRoot.Position)
                    effectGroundCracks(tRoot.Position, 24, C_BRIGHT)
                    effectSplash(tRoot.Position, 60, 30, C_BRIGHT, 1.0, 50)
                    effectPillar(tRoot.Position, C_BRIGHT, 60, 1.3)
                    screenShake(4.5, 0.8)
                end
            else
                hrp.Anchored = true
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.CFrame = CFrame.lookAt(targetPos, targetPos + finalAimDir)
                effectShockwaveBurst(targetPos)
                effectGroundCracks(targetPos, 16, C_MID)
                effectDebrisColumn(targetPos, C_MID)
                screenShake(2.5, 0.5)
                blastParts(targetPos, 50)
                task.wait(UNANCHOR_DELAY)
            end

            local cl = hrp.CFrame.LookVector
            local fl = Vector3.new(cl.X, 0, cl.Z).Unit
            hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fl)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            hrp.Anchored = false
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        else
            humanoid.AutoRotate = true
        end
    end)
end

local function executeJudgement()
    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")
        local Animator = humanoid:WaitForChild("Animator")

        sound("104042020906158", 4)

        effectRune(hrp.Position, C_BRIGHT, 1.5)
        effectOrbitalRing(hrp, 5, 12, C_CORE, 2.0, 2.0)
        effectPillar(hrp.Position, C_BRIGHT, 40, 1.0)
        effectLightningWeb(hrp.Position, 10, C_BRIGHT)
        effectScreenFlash(0.1)
        screenShake(1.2, 0.3)

        local isEnabled = true
        local isAttached = false
        local flingActive = false
        local targetPlayer = nil
        local attachConnection = nil
        local scanConnection = nil

        local dropAnim = Instance.new("Animation"); dropAnim.AnimationId = "rbxassetid://97170520"
        local activeTrack = nil

        if not ReplicatedStorage:FindFirstChild("neo'sfling") then
            local d = Instance.new("Decal"); d.Name = "neo'sfling"; d.Parent = ReplicatedStorage
        end

        local lastDir = hrp.CFrame.LookVector
        humanoid.AutoRotate = false

        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

        local startPos = hrp.Position
        local attachment = Instance.new("Attachment"); attachment.Parent = hrp

        local alignRot = Instance.new("AlignOrientation")
        alignRot.Mode = Enum.OrientationAlignmentMode.OneAttachment
        alignRot.Attachment0 = attachment
        alignRot.MaxTorque = math.huge; alignRot.Responsiveness = 200
        alignRot.RigidityEnabled = true; alignRot.CFrame = hrp.CFrame; alignRot.Parent = hrp

        local alignPos = Instance.new("AlignPosition")
        alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        alignPos.Attachment0 = attachment
        alignPos.MaxForce = math.huge; alignPos.Responsiveness = 200
        alignPos.RigidityEnabled = true; alignPos.Position = startPos; alignPos.Parent = hrp

        local Frames = {
            { Time=0.4, StayTime=0.4, RX=10, RY=0, RZ=0, PX=0, PY=0.3, PZ=0 },
            { Time=0.5, StayTime=1, RX=-60, RY=0, RZ=0, PX=0, PY=-1.7, PZ=0,
              Animations = {
                  {Id="rbxassetid://287325678", Duration=1.5},
                  {Id="rbxassetid://183294396", Duration=1.0}
              }
            },
            { Time=0, StayTime=0, RX=0, RY=0, RZ=0, PX=0, PY=0, PZ=0 }
        }

        local function lerp(a,b,t) return a+(b-a)*t end
        local function lerpAngle(a,b,t) return a+math.atan2(math.sin(b-a),math.cos(b-a))*t end

        local currentYaw = math.rad(hrp.Orientation.Y)
        local frame = 1; local frameStart = tick()
        local currentTracks = {}
        local judgementFxCount = 0

        local mainConn
        mainConn = RunService.Heartbeat:Connect(function(dt)
            judgementFxCount += 1

            if judgementFxCount % 8 == 0 then
                effectSplash(hrp.Position, 3, 8, C_CORE, 0.5, 20)
            end
            if judgementFxCount % 20 == 0 then
                effectLightning(hrp.Position,
                    hrp.Position + Vector3.new(math.random(-5,5), math.random(-3,5), math.random(-5,5)),
                    C_BRIGHT, 5, 0.1, 0.12)
            end

            if humanoid.Health <= 0 then
                mainConn:Disconnect()
                if alignRot.Parent then alignRot:Destroy() end
                if alignPos.Parent then alignPos:Destroy() end
                if attachment.Parent then attachment:Destroy() end
                for _,t in ipairs(currentTracks) do pcall(function() t:Stop(0.3) end) end
                humanoid.AutoRotate = true; humanoid.PlatformStand = false
                return
            end

            local cur = Frames[frame]
            if not cur then
                mainConn:Disconnect()
                if alignRot.Parent then alignRot:Destroy() end
                if alignPos.Parent then alignPos:Destroy() end
                if attachment.Parent then attachment:Destroy() end
                for _,t in ipairs(currentTracks) do pcall(function() t:Stop(0.3) end) end
                humanoid.AutoRotate = true; humanoid.PlatformStand = false
                return
            end

            if cur.Animations and #currentTracks == 0 then
                for _, ad in ipairs(cur.Animations) do
                    pcall(function()
                        local na = Instance.new("Animation"); na.AnimationId = ad.Id
                        local tk = Animator:LoadAnimation(na)
                        tk:Play(0.3); tk.TimePosition = 0; tk:AdjustSpeed(1)
                        table.insert(currentTracks, tk)
                        if ad.Duration then task.delay(ad.Duration, function() pcall(function() tk:Stop(0.3) end) end) end
                    end)
                end
            end

            local sRX,sRY,sRZ,sPX,sPY,sPZ = 0,0,0,0,0,0
            if frame > 1 then
                local prev = Frames[frame-1]
                sRX,sRY,sRZ = prev.RX,prev.RY,prev.RZ
                sPX,sPY,sPZ = prev.PX,prev.PY,prev.PZ
            end

            local elapsed = tick() - frameStart
            local alpha = math.clamp(elapsed / math.max(cur.Time, 0.001), 0, 1)

            alignRot.CFrame = CFrame.Angles(0, currentYaw, 0) * CFrame.fromEulerAnglesYXZ(
                math.rad(lerp(sRX,cur.RX,alpha)),
                math.rad(lerp(sRY,cur.RY,alpha)),
                math.rad(lerp(sRZ,cur.RZ,alpha))
            )
            alignPos.Position = startPos + Vector3.new(
                lerp(sPX,cur.PX,alpha), lerp(sPY,cur.PY,alpha), lerp(sPZ,cur.PZ,alpha)
            )

            local md = humanoid.MoveDirection
            local ty = currentYaw
            if md.Magnitude > 0.01 then ty = math.atan2(-md.X,-md.Z) end
            currentYaw = lerpAngle(currentYaw, ty, dt*15)

            if elapsed >= cur.Time + (cur.StayTime or 0) then
                frame += 1; frameStart = tick()
                for _,t in ipairs(currentTracks) do pcall(function() t:Stop(0.1) end) end
                table.clear(currentTracks)
            end
        end)

        task.wait(1.5)

        local cSize = character:GetExtentsSize()
        local hitboxLen = 50
        local hitbox = Instance.new("Part")
        hitbox.Name = "Hitbox"
        hitbox.Size = Vector3.new(cSize.X, cSize.Y, hitboxLen)
        hitbox.Transparency = 1; hitbox.CastShadow = false
        hitbox.CanCollide = false; hitbox.CanTouch = true
        hitbox.CanQuery = true; hitbox.Massless = true

        local function updateHitbox()
            if hitbox and hitbox.Parent and hrp then
                local fl = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z).Unit
                if fl.Magnitude == 0 or tostring(fl) == "NAN" then fl = Vector3.new(0,0,-1) end
                hitbox.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fl) * CFrame.new(0,0,-hitboxLen/2)
            end
        end
        updateHitbox(); hitbox.Parent = character

        task.spawn(function()
            local fl = Vector3.new(hrp.CFrame.LookVector.X,0,hrp.CFrame.LookVector.Z).Unit
            for i = 1, 5 do
                local beamPos = hrp.Position + fl * (i * 9)
                effectPillar(beamPos, C_BRIGHT, 15, 0.6)
                effectRing(beamPos, 0.5, 8, C_MID, 0.4)
            end
            effectLightning(hrp.Position, hrp.Position + fl * 50, C_BRIGHT, 12, 0.2, 0.2)
            screenShake(2.0, 0.4)
            effectScreenFlash(0.15)
            sound("112192533344145", 2)
        end)

        local function detach()
            if attachConnection then attachConnection:Disconnect(); attachConnection = nil end
            if not isAttached then targetPlayer = nil; isEnabled = false; return end
            task.spawn(function()
                task.wait(0.25)
                flingActive = false; isAttached = false; targetPlayer = nil; isEnabled = false
                if activeTrack then activeTrack:Stop(0.3); activeTrack = nil end
                if hrp then
                    local fl = Vector3.new(lastDir.X,0,lastDir.Z).Unit
                    if fl.Magnitude == 0 or tostring(fl)=="NAN" then fl = Vector3.new(0,0,-1) end
                    hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fl)
                    hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero
                end
                if humanoid then
                    humanoid.AutoRotate = true; humanoid.PlatformStand = false
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        end

        local function attach(plr)
            if not isEnabled then return end
            targetPlayer = plr; isAttached = true; flingActive = true
            local t0 = os.clock(); local dur = 0.5

            if mainConn then mainConn:Disconnect(); mainConn = nil end
            if alignRot.Parent then alignRot:Destroy() end
            if alignPos.Parent then alignPos:Destroy() end
            if attachment.Parent then attachment:Destroy() end
            for _,t in ipairs(currentTracks) do pcall(function() t:Stop(0.1) end) end
            table.clear(currentTracks)

            if humanoid then
                humanoid.AutoRotate = false; humanoid.PlatformStand = true
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end

            pcall(function()
                activeTrack = Animator:LoadAnimation(dropAnim)
                activeTrack:Play(0.3); activeTrack.TimePosition = 0.3; activeTrack:AdjustSpeed(1)
            end)

            local tc = plr.Character
            local tr = tc and tc:FindFirstChild("HumanoidRootPart")
            if tr then
                effectShockwaveBurst(tr.Position)
                effectGroundCracks(tr.Position, 20, C_BRIGHT)
                effectDebrisColumn(tr.Position, C_BRIGHT)
                effectPillar(tr.Position, C_BRIGHT, 50, 1.0)
                effectRune(tr.Position, C_CORE, 0.6)
                effectLightningWeb(tr.Position, 20, C_BRIGHT)
                effectSplash(tr.Position, 60, 30, C_BRIGHT, 0.9, 40)
                effectScreenFlash(0.3)
                screenShake(4.0, 0.8)
                sound("106734683831601", 3)
            end

            task.spawn(function()
                local mv = 0.1
                while flingActive do
                    RunService.Heartbeat:Wait(); if not flingActive then break end
                    local c = player.Character
                    local th = c and c:FindFirstChild("HumanoidRootPart")
                    if th then
                        local v = th.Velocity
                        th.Velocity = v * 1 + Vector3.new(0,0.5,0)
                        RunService.RenderStepped:Wait(); if not flingActive then break end
                        th.Velocity = v
                        RunService.Stepped:Wait(); if not flingActive then break end
                        th.Velocity = v + Vector3.new(0,mv,0); mv=-mv
                    end
                end
            end)

            local fxCount = 0
            attachConnection = RunService.Heartbeat:Connect(function()
                local mc = player.Character
                local tc2 = targetPlayer and targetPlayer.Character
                if not mc or not tc2 then detach(); return end
                local mr = mc:FindFirstChild("HumanoidRootPart")
                local tr2 = tc2:FindFirstChild("HumanoidRootPart")
                if not mr or not tr2 then detach(); return end

                local elapsed = os.clock() - t0
                local alpha = math.clamp(elapsed / dur, 0, 1)
                if alpha >= 1 then detach(); return end

                pcall(function() sethiddenproperty(mr, "PhysicsRepRootPart", tr2) end)

                local tp = tr2.Position; local mp = mr.Position
                local dir = Vector3.new(tp.X-mp.X, 0, tp.Z-mp.Z).Unit
                if dir.Magnitude == 0 or tostring(dir)=="NAN" then dir = mr.CFrame.LookVector end
                lastDir = dir

                local finalPos = tp - (dir * 6 * (1-alpha))
                mr.CFrame = CFrame.fromMatrix(finalPos, Vector3.new(0,1,0), -dir)

                fxCount += 1
                if fxCount % 5 == 0 then
                    effectSplash(tr2.Position, 5, 15, C_BRIGHT, 0.3, 30)
                end
                if fxCount % 15 == 0 then
                    effectLightning(tr2.Position,
                        tr2.Position + Vector3.new(math.random(-8,8), math.random(2,10), math.random(-8,8)),
                        C_BRIGHT, 6, 0.12, 0.1)
                end
            end)
        end

        local moveDir = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
        if moveDir.Magnitude < 0.05 then
            moveDir = hrp.CFrame.LookVector
        end
        if moveDir.Magnitude < 0.05 then
            moveDir = Vector3.new(0, 0, -1)
        end
        moveDir = moveDir.Unit

        if mainConn then mainConn:Disconnect(); mainConn = nil end
        if alignRot.Parent then alignRot:Destroy() end
        if alignPos.Parent then alignPos:Destroy() end
        if attachment.Parent then attachment:Destroy() end
        for _, t in ipairs(currentTracks) do pcall(function() t:Stop(0.1) end) end
        table.clear(currentTracks)

        local function restoreJudgementMovement()
            if humanoid and humanoid.Parent then
                humanoid.Sit = false
                humanoid.PlatformStand = false
                humanoid.AutoRotate = true
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            if hrp and hrp.Parent then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end

        scanConnection = RunService.Heartbeat:Connect(function()
            updateHitbox()
            if not isEnabled or targetPlayer or not hitbox or not hitbox.Parent then
                if scanConnection then scanConnection:Disconnect(); scanConnection = nil end
                return
            end
            local params = OverlapParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {character}
            local parts = workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size, params)
            local closest, closestDist = nil, math.huge
            for _, p in ipairs(parts) do
                local model = p:FindFirstAncestorOfClass("Model")
                if model then
                    local tp = Players:GetPlayerFromCharacter(model)
                    if tp and tp ~= player then
                        local tr = model:FindFirstChild("HumanoidRootPart")
                        if tr then
                            local d = (tr.Position - hrp.Position).Magnitude
                            if d < closestDist then closestDist = d; closest = tp end
                        end
                    end
                end
            end
            if closest then
                if scanConnection then scanConnection:Disconnect(); scanConnection = nil end
                if hitbox then hitbox:Destroy() end
                attach(closest)
            end
        end)

        task.delay(0.6, function()
            if hitbox then hitbox:Destroy() end
            if not isAttached then

                if hrp and hrp.Parent then
                    local teleportDistance = 20
                    local teleportPos = hrp.Position + moveDir * teleportDistance
                    local rcParams = RaycastParams.new()
                    rcParams.FilterDescendantsInstances = {character}
                    rcParams.FilterType = Enum.RaycastFilterType.Exclude
                    local result = Workspace:Raycast(hrp.Position, moveDir * teleportDistance, rcParams)
                    if result then
                        teleportPos = result.Position - moveDir * 2
                    end
                    hrp.CFrame = CFrame.lookAt(teleportPos, teleportPos + moveDir)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero

                    if humanoid then
                        humanoid.AutoRotate = true
                    end
                end
                targetPlayer = nil
                isEnabled = false
            end
        end)
    end)
end

task.spawn(function()
    local touchGui = playerGui:WaitForChild("TouchGui", 10)
    if touchGui then
        local touchControl = touchGui:WaitForChild("TouchControlFrame", 5)
        if touchControl then
            local jumpBtn = touchControl:WaitForChild("JumpButton", 5)
            if jumpBtn then
                jumpBtn.Visible = false
                jumpBtn:GetPropertyChangedSignal("Visible"):Connect(function()
                    if jumpBtn.Visible then jumpBtn.Visible = false end
                end)
            end
        end
    end
end)

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local C_CORE   = Color3.fromRGB(255, 80,  20)
local C_MID    = Color3.fromRGB(255, 180, 0)
local C_BRIGHT = Color3.fromRGB(255, 240, 180)
local C_DARK   = Color3.fromRGB(160, 20,  0)
local C_WHITE  = Color3.fromRGB(255, 255, 255)

local function addLight(parent, color, brightness, range)
    local l = Instance.new("PointLight")
    l.Color = color; l.Brightness = brightness; l.Range = range; l.Parent = parent
    return l
end

local function neonPart(shape, size, color, pos)
    local p = Instance.new("Part")
    p.Shape = shape or Enum.PartType.Ball
    p.Material = Enum.Material.Neon
    p.Size = size; p.Color = color
    p.CanCollide = false; p.CastShadow = false
    p.Anchored = true; p.CFrame = CFrame.new(pos)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = workspace
    return p
end

local function screenShake(magnitude, duration)
    local camera = Workspace.CurrentCamera
    local t0 = tick(); local conn
    conn = RunService.RenderStepped:Connect(function()
        local e = tick() - t0
        if e > duration then conn:Disconnect(); return end
        local pct = 1 - (e / duration)
        local s = magnitude * pct
        camera.CFrame = camera.CFrame
            * CFrame.new(math.random(-100,100)/100*s, math.random(-100,100)/100*s, math.random(-100,100)/100*s)
            * CFrame.Angles(math.random(-10,10)/1000*s, math.random(-10,10)/1000*s, math.random(-10,10)/1000*s)
    end)
end

local function screenFlash(duration, transparency)
    local gui = playerGui:FindFirstChild("PrepareFxGui") or (function()
        local g = Instance.new("ScreenGui")
        g.Name = "PrepareFxGui"; g.ResetOnSpawn = false; g.Parent = playerGui; return g
    end)()
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = C_WHITE
    f.BackgroundTransparency = transparency or 0.1
    f.BorderSizePixel = 0; f.ZIndex = 100; f.Parent = gui
    local t = TweenService:Create(f, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    t:Play(); t.Completed:Connect(function() f:Destroy() end)
end

local function effectCrossExplosion(pos)
    local directions = {
        Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1),
        Vector3.new(0,1,0),
    }
    for _, dir in ipairs(directions) do
        local arm = Instance.new("Part")
        arm.Material = Enum.Material.Neon
        arm.Color = C_BRIGHT
        arm.CanCollide = false; arm.CastShadow = false; arm.Anchored = true
        arm.Size = Vector3.new(1.4, 1.4, 0.1)
        arm.CFrame = CFrame.new(pos) * CFrame.lookAt(Vector3.zero, dir)
        arm.TopSurface = Enum.SurfaceType.Smooth; arm.BottomSurface = Enum.SurfaceType.Smooth
        arm.Parent = workspace
        addLight(arm, C_CORE, 3, 25)
        TweenService:Create(arm, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(1.4, 1.4, 28),
            CFrame = CFrame.new(pos + dir * 14) * CFrame.lookAt(Vector3.zero, dir),
            Transparency = 0
        }):Play()
        task.delay(0.4, function()
            TweenService:Create(arm, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Transparency = 1,
                Size = Vector3.new(0.2, 0.2, 28)
            }):Play()
            Debris:AddItem(arm, 0.35)
        end)
    end

    local core = neonPart(Enum.PartType.Ball, Vector3.new(2,2,2), C_WHITE, pos)
    addLight(core, C_BRIGHT, 8, 50)
    TweenService:Create(core, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(16, 16, 16),
        Transparency = 1
    }):Play()
    Debris:AddItem(core, 0.55)
end

local function effectHaloRing(pos, color, tiltAngle, duration)
    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.CanCollide = false; ring.CastShadow = false; ring.Anchored = true
    ring.Size = Vector3.new(0.3, 1, 1)
    ring.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi/2) * CFrame.Angles(math.rad(tiltAngle), 0, 0)
    ring.TopSurface = Enum.SurfaceType.Smooth; ring.BottomSurface = Enum.SurfaceType.Smooth
    ring.Parent = workspace
    addLight(ring, color, 2, 20)
    TweenService:Create(ring, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.05, 40, 40),
        Transparency = 1
    }):Play()
    Debris:AddItem(ring, duration + 0.05)
end

local function effectDivineHalo(pos)
    effectHaloRing(pos, C_BRIGHT,  0,  0.5)
    effectHaloRing(pos, C_MID,     45, 0.6)
    effectHaloRing(pos, C_CORE,   -45, 0.7)
    effectHaloRing(pos, C_BRIGHT,  90, 0.55)
end

local function effectLightningCircle(pos, count, radius, color)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local spawnPos = pos + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)

        local base = neonPart(Enum.PartType.Cylinder,
            Vector3.new(0.2, 1.5, 1.5), color, spawnPos)
        base.CFrame = CFrame.new(spawnPos) * CFrame.Angles(0, 0, math.pi/2)
        addLight(base, color, 2, 15)
        TweenService:Create(base, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.05, 5, 5), Transparency = 1
        }):Play()
        Debris:AddItem(base, 0.2)

        task.delay(0.05, function()
            local bolt = neonPart(Enum.PartType.Block,
                Vector3.new(0.2, 0.1, 0.2), color, spawnPos)
            addLight(bolt, color, 3, 20)
            TweenService:Create(bolt, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = Vector3.new(0.2, 30, 0.2),
                CFrame = CFrame.new(spawnPos + Vector3.new(0, 15, 0)),
                Transparency = 1
            }):Play()
            Debris:AddItem(bolt, 0.35)
        end)
    end
end

local function effectSpiralBurst(pos, count, color)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local radius = math.random(1, 3)
        local spawnPos = pos + Vector3.new(math.cos(angle)*radius, math.random(-2,2), math.sin(angle)*radius)
        local p = neonPart(Enum.PartType.Ball, Vector3.new(0.35, 0.35, 0.35), color, spawnPos)

        local outDir = Vector3.new(math.cos(angle), math.random(1,4)/4, math.sin(angle)).Unit
        local targetPos = pos + outDir * math.random(10, 22)

        TweenService:Create(p, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            CFrame = CFrame.new(targetPos),
            Size = Vector3.new(0.05, 0.05, 0.05),
            Transparency = 1
        }):Play()
        Debris:AddItem(p, 0.6)
    end
end

local function effectGroundShockwave(pos, color, endRadius, duration)
    local ring = Instance.new("Part")
    ring.Shape = Enum.PartType.Cylinder
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.CanCollide = false; ring.CastShadow = false; ring.Anchored = true
    ring.Size = Vector3.new(0.2, 0.5, 0.5)
    ring.CFrame = CFrame.new(pos + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.pi/2)
    ring.TopSurface = Enum.SurfaceType.Smooth; ring.BottomSurface = Enum.SurfaceType.Smooth
    ring.Parent = workspace
    addLight(ring, color, 3, 30)
    TweenService:Create(ring, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.05, endRadius*2, endRadius*2),
        Transparency = 1
    }):Play()
    Debris:AddItem(ring, duration + 0.05)
end

local function effectGroundCracks(pos, count, color)
    for i = 1, count do
        local angle = (i / count) * math.pi * 2 + math.random(-8,8)/8
        local length = math.random(7, 20)
        local crack = Instance.new("Part")
        crack.Material = Enum.Material.Neon; crack.Color = color
        crack.CanCollide = false; crack.Anchored = true; crack.CastShadow = false
        crack.Size = Vector3.new(0.18, 0.1, 0)
        crack.CFrame = CFrame.new(pos + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, angle, 0)
        crack.TopSurface = Enum.SurfaceType.Smooth; crack.BottomSurface = Enum.SurfaceType.Smooth
        crack.Parent = workspace
        local grow = TweenService:Create(crack, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.18, 0.1, length),
            CFrame = CFrame.new(pos + Vector3.new(0, 0.08, 0) + Vector3.new(math.cos(angle),0,math.sin(angle))*length/2) * CFrame.Angles(0, angle, 0)
        })
        grow:Play()
        grow.Completed:Connect(function()
            TweenService:Create(crack, TweenInfo.new(0.5), {Transparency=1}):Play()
        end)
        Debris:AddItem(crack, 0.75)
    end
end

local function effectDebris(pos)
    for i = 1, 16 do
        local sz = math.random(2,6)/10
        local chunk = Instance.new("Part")
        chunk.Material = Enum.Material.SmoothPlastic
        chunk.Color = Color3.fromRGB(70,70,70)
        chunk.Size = Vector3.new(sz,sz,sz)
        chunk.CanCollide = false; chunk.CastShadow = false
        chunk.CFrame = CFrame.new(pos + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
        chunk.Parent = workspace
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(math.random(-25,25), math.random(25,65), math.random(-25,25))
        bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Parent = chunk
        Debris:AddItem(bv, 0.12)
        local glow = Instance.new("SelectionBox")
        glow.Color3 = C_CORE; glow.LineThickness = 0.03; glow.Adornee = chunk; glow.Parent = chunk
        TweenService:Create(chunk, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
        Debris:AddItem(chunk, 1.3)
    end
end

local function effectPillar(pos, color, height, duration)
    local p = neonPart(Enum.PartType.Block, Vector3.new(2,0.1,2), color, pos)
    addLight(p, color, 4, 40)
    local grow = TweenService:Create(p, TweenInfo.new(duration*0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(2, height, 2),
        CFrame = CFrame.new(pos + Vector3.new(0, height/2, 0))
    })
    grow:Play()
    grow.Completed:Connect(function()
        TweenService:Create(p, TweenInfo.new(duration*0.72, Enum.EasingStyle.Quad), {
            Transparency = 1, Size = Vector3.new(0.2, height, 0.2)
        }):Play()
    end)
    Debris:AddItem(p, duration + 0.1)
end

local function effectSplash(pos, count, speed, color, lifetime, upBias)
    for i = 1, count do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball; p.Material = Enum.Material.Neon
        p.Size = Vector3.new(math.random(2,6)/10, math.random(2,6)/10, math.random(2,6)/10)
        p.Color = color; p.CanCollide = false; p.CastShadow = false
        p.CFrame = CFrame.new(pos); p.Parent = workspace
        local dir = Vector3.new(math.random(-100,100), math.random(upBias or 10, 100), math.random(-100,100)).Unit
        local spd = math.random(speed*60, speed*100)/100
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = dir*spd; bv.MaxForce = Vector3.new(1e4,1e4,1e4); bv.Parent = p
        TweenService:Create(p, TweenInfo.new(lifetime, Enum.EasingStyle.Quad), {Transparency=1, Size=Vector3.new(0.01,0.01,0.01)}):Play()
        Debris:AddItem(p, lifetime)
    end
end

local function executePrepareThyself()
    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid  = character:WaitForChild("Humanoid")
        local hrp       = character:WaitForChild("HumanoidRootPart")
        local animator  = humanoid:WaitForChild("Animator")

        if not ReplicatedStorage:FindFirstChild("neo'sfling") then
            local d = Instance.new("Decal"); d.Name = "neo'sfling"; d.Parent = ReplicatedStorage
        end

        local leapSound = Instance.new("Sound")
        leapSound.SoundId = "rbxassetid://135316239253287"
        leapSound.Volume = 1; leapSound.PlaybackSpeed = 1
        local ps = Instance.new("PitchShiftSoundEffect"); ps.Octave = 1; ps.Parent = leapSound
        leapSound.Parent = workspace; leapSound:Play()
        leapSound.Ended:Connect(function() leapSound:Destroy() end)

        local animLeap = Instance.new("Animation"); animLeap.AnimationId = "rbxassetid://218504594"
        local animTrack = humanoid:LoadAnimation(animLeap)
        animTrack:Play(0.2); animTrack.TimePosition = 0; animTrack:AdjustSpeed(0.7)
        task.delay(0.6, function() animTrack:Stop(0.2) end)

        local bv = Instance.new("BodyVelocity")
        bv.Velocity  = hrp.CFrame.LookVector * 30
        bv.MaxForce  = Vector3.new(100000, 100000, 100000)
        bv.P         = 5000; bv.Parent = hrp
        Debris:AddItem(bv, 0.1)

        task.spawn(function()
            for i = 1, 5 do
                task.wait(0.04)
                if hrp and hrp.Parent then
                    effectSplash(hrp.Position, 4, 8, C_CORE, 0.3, 15)
                    effectGroundShockwave(hrp.Position - Vector3.new(0, 2, 0), C_MID, 3, 0.2)
                end
            end
        end)

        task.wait(0.3)

        screenFlash(0.18, 0.05)
        screenShake(2.2, 0.45)

        local basePos = hrp.Position

        effectCrossExplosion(basePos)

        effectDivineHalo(basePos)

        effectLightningCircle(basePos, 10, 6, C_BRIGHT)

        effectPillar(basePos, C_BRIGHT, 60, 1.6)
        effectPillar(basePos + Vector3.new(4, 0, 0), C_CORE, 35, 1.1)
        effectPillar(basePos + Vector3.new(-4, 0, 0), C_CORE, 35, 1.1)

        effectGroundCracks(basePos, 18, C_MID)
        effectDebris(basePos)

        effectGroundShockwave(basePos, C_BRIGHT, 25, 0.45)
        task.delay(0.1, function() effectGroundShockwave(basePos, C_MID,    18, 0.55) end)
        task.delay(0.2, function() effectGroundShockwave(basePos, C_CORE,   12, 0.65) end)

        effectSpiralBurst(basePos, 24, C_BRIGHT)
        task.delay(0.12, function() effectSpiralBurst(basePos, 16, C_MID) end)

        task.wait(0.05)

        local anim1 = Instance.new("Animation"); anim1.AnimationId = "rbxassetid://21633130"
        local anim2 = Instance.new("Animation"); anim2.AnimationId = "rbxassetid://188853932"
        local anim3 = Instance.new("Animation"); anim3.AnimationId = "rbxassetid://188854226"
        local track1 = animator:LoadAnimation(anim1)
        local track2 = animator:LoadAnimation(anim2)
        local track3 = animator:LoadAnimation(anim3)

        local isEnabled    = true
        local targetPlayer = nil
        local comboCount   = 0
        local maxCombos    = 3

        local RELATIVE_POSITION = Vector3.new(0, -0.8, -0.1)
        local RELATIVE_ROTATION = Vector3.new(0, 180, 0)

        local characterSize = character:GetExtentsSize()
        local hitboxLen     = 40
        local hitbox = Instance.new("Part")
        hitbox.Name = "Hitbox"
        hitbox.Size = Vector3.new(characterSize.X, characterSize.Y, hitboxLen)
        hitbox.Transparency = 1; hitbox.CastShadow = false
        hitbox.CanCollide = false; hitbox.CanTouch = true
        hitbox.CanQuery = true; hitbox.Massless = true

        local function updateHitbox()
            if hitbox and hitbox.Parent and hrp then
                local fl = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z).Unit
                if fl.Magnitude == 0 or tostring(fl) == "NAN" then fl = Vector3.new(0,0,-1) end
                hitbox.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fl) * CFrame.new(0, 0, -hitboxLen/2)
            end
        end
        updateHitbox(); hitbox.Parent = character

        local function runComboSequence(targetPlr)
            targetPlayer = targetPlr
            humanoid.AutoRotate = false
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

            local offsetCFrame = CFrame.new(RELATIVE_POSITION)
                * CFrame.fromEulerAnglesYXZ(
                    math.rad(RELATIVE_ROTATION.X),
                    math.rad(RELATIVE_ROTATION.Y),
                    math.rad(RELATIVE_ROTATION.Z)
                )

            local tRoot = targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                local tp = tRoot.Position
                effectCrossExplosion(tp)
                effectDivineHalo(tp)
                effectGroundCracks(tp, 12, C_BRIGHT)
                effectDebris(tp)
                effectGroundShockwave(tp, C_BRIGHT, 20, 0.4)
                effectPillar(tp, C_BRIGHT, 40, 0.9)
                effectSpiralBurst(tp, 20, C_BRIGHT)
                screenShake(3.0, 0.55)
                screenFlash(0.18, 0.15)
            end

            local globalFlingActive = true
            local movel = 0.1
            task.delay(1.5, function() globalFlingActive = false end)

            task.spawn(function()
                while globalFlingActive and humanoid.Health > 0 and targetPlayer do
                    RunService.Heartbeat:Wait()
                    if not globalFlingActive then break end
                    if hrp then
                        local targetHrp = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local vel = targetHrp and targetHrp.Velocity or Vector3.zero
                        hrp.Velocity = vel * 4.0 + Vector3.new(0, 25, 120)
                        RunService.RenderStepped:Wait()
                        if not globalFlingActive then break end
                        if hrp then hrp.Velocity = vel end
                        RunService.Stepped:Wait()
                        if not globalFlingActive then break end
                        if hrp then hrp.Velocity = vel + Vector3.new(0, movel, 0) end
                        movel = -movel
                    end
                end
            end)

            for i = 1, maxCombos do
                if humanoid.Health <= 0 or not targetPlayer or not targetPlayer.Character then break end
                local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not targetHrp then break end
                comboCount = i

                humanoid.Sit = true

                local s1 = Instance.new("Sound")
                s1.SoundId = "rbxassetid://112192533344145"
                s1.Volume = 1; s1.PlaybackSpeed = 1
                local psfx = Instance.new("PitchShiftSoundEffect"); psfx.Octave = 1; psfx.Parent = s1
                s1.Parent = workspace; s1:Play()
                s1.Ended:Connect(function() s1:Destroy() end)

                local s2 = Instance.new("Sound")
                s2.SoundId = "rbxassetid://106734683831601"
                s2.Volume = 2; s2.Parent = workspace; s2:Play()
                s2.Ended:Connect(function() s2:Destroy() end)

                local hitPos = targetHrp.Position
                if i == maxCombos then
                    effectCrossExplosion(hitPos)
                    effectDivineHalo(hitPos)
                    effectLightningCircle(hitPos, 12, 8, C_BRIGHT)
                    effectGroundCracks(hitPos, 22, C_MID)
                    effectDebris(hitPos)
                    effectPillar(hitPos, C_BRIGHT, 55, 1.4)
                    effectPillar(hitPos, C_MID,    40, 1.1)
                    effectSpiralBurst(hitPos, 30, C_BRIGHT)
                    effectSpiralBurst(hitPos, 20, C_MID)
                    effectGroundShockwave(hitPos, C_BRIGHT, 28, 0.5)
                    effectGroundShockwave(hitPos, C_CORE,   20, 0.65)
                    screenShake(4.5, 0.9)
                    screenFlash(0.3, 0.08)
                else
                    effectGroundShockwave(hitPos, C_MID, 14, 0.4)
                    effectSpiralBurst(hitPos, 12, C_CORE)
                    effectGroundCracks(hitPos, 8, C_CORE)
                    screenShake(1.8, 0.28)
                end

                if i == 2 then
                    track1:Play(0.5); track1.TimePosition = 0; track1:AdjustSpeed(1)
                    track2:Play(0.1); track2.TimePosition = 0; track2:AdjustSpeed(1)
                    task.delay(0.5, function() track2:Stop(0.1) end)
                    task.delay(1.1, function() track1:Stop(0.5) end)
                elseif i == 3 then
                    track3:Play(0.1); track3.TimePosition = 0; track3:AdjustSpeed(1)
                    task.delay(0.5, function() track3:Stop(0.1) end)
                end

                local comboConn = RunService.Heartbeat:Connect(function()
                    if not targetHrp or humanoid.Health <= 0 then return end
                    hrp.CFrame = targetHrp.CFrame * offsetCFrame
                    pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", targetHrp) end)
                end)
                task.wait(0.1)
                comboConn:Disconnect()
                pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end)
                humanoid.Sit = false

                if i < maxCombos then task.wait(0.8) end
            end

            globalFlingActive = false
            task.wait()
            hrp.Velocity = Vector3.zero; hrp.RotVelocity = Vector3.zero
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            targetPlayer = nil; isEnabled = false
        end

        local scanConnection
        scanConnection = RunService.Heartbeat:Connect(function()
            updateHitbox()
            if not isEnabled or targetPlayer or not hitbox or not hitbox.Parent then
                if scanConnection then scanConnection:Disconnect(); scanConnection = nil end
                return
            end
            local params = OverlapParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {character}
            local parts = workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size, params)
            local closest, closestDist = nil, math.huge
            for _, part in ipairs(parts) do
                local model = part:FindFirstAncestorOfClass("Model")
                if model then
                    local tp = Players:GetPlayerFromCharacter(model)
                    if tp and tp ~= player then
                        local tr = model:FindFirstChild("HumanoidRootPart")
                        if tr then
                            local d = (tr.Position - hrp.Position).Magnitude
                            if d < closestDist then closestDist = d; closest = tp end
                        end
                    end
                end
            end
            if closest then
                if scanConnection then scanConnection:Disconnect(); scanConnection = nil end
                if hitbox then hitbox:Destroy() end
                runComboSequence(closest)
            end
        end)

        task.delay(0.3, function()
            if hitbox then hitbox:Destroy() end
            if comboCount == 0 then
                if scanConnection then scanConnection:Disconnect(); scanConnection = nil end
                targetPlayer = nil; isEnabled = false
            end
        end)
    end)
end

local function executeOverhead()
    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid  = character:WaitForChild("Humanoid")
        local hrp       = character:WaitForChild("HumanoidRootPart")

        local snd = Instance.new("Sound")
        snd.SoundId = "rbxassetid://137699582034003"
        snd.Volume  = 1
        snd.Parent  = workspace
        snd:Play()
        snd.Ended:Connect(function() snd:Destroy() end)

        effectRune(hrp.Position, C_CORE, 0.7)
        effectOrbitalRing(hrp, 3.5, 8, C_DARK, 3.0, 0.7)
        effectLightningWeb(hrp.Position, 8, C_CORE)
        effectPillar(hrp.Position, C_DARK, 30, 0.7)
        effectSplash(hrp.Position, 15, 10, C_CORE, 0.4, 30)
        screenShake(1.2, 0.3)
        effectScreenFlash(0.08)

        local animA = Instance.new("Animation")
        animA.AnimationId = "rbxassetid://94160738"
        local trackA = humanoid:LoadAnimation(animA)
        trackA:Play(0.3)
        trackA.TimePosition = 0
        trackA:AdjustSpeed(0.5)
        task.delay(1, function() trackA:Stop(0.3) end)

        if not ReplicatedStorage:FindFirstChild("neo'sfling") then
            local d = Instance.new("Decal")
            d.Name   = "neo'sfling"
            d.Parent = ReplicatedStorage
        end

        local targetPlayer2
        local attachConn2
        local flingConn2
        local scanConn2
        local oh_enabled = true

        local function oh_detach()
            if attachConn2 then attachConn2:Disconnect(); attachConn2 = nil end
            if flingConn2  then flingConn2:Disconnect();  flingConn2  = nil end
            if scanConn2   then scanConn2:Disconnect();   scanConn2   = nil end
            targetPlayer2 = nil
            oh_enabled    = false
        end

        local function oh_attach(plr)
            if not oh_enabled then return end
            targetPlayer2 = plr

            local tc = plr.Character
            local tr = tc and tc:FindFirstChild("HumanoidRootPart")
            if tr then
                local ip = tr.Position
                effectShockwaveBurst(ip)
                effectShockwaveBurst(ip + Vector3.new(0, 3, 0))
                effectGroundCracks(ip, 20, C_CORE)
                effectDebrisColumn(ip, C_CORE)
                effectPillar(ip, C_DARK,   60, 1.1)
                effectPillar(ip, C_CORE,   40, 0.9)
                effectRune(ip, C_BRIGHT, 0.55)
                effectLightningWeb(ip, 18, C_BRIGHT)
                effectSplash(ip, 50, 24, C_BRIGHT, 0.8, 60)
                effectSplash(ip, 30, 14, C_CORE,   0.6, 20)
                effectScreenFlash(0.25)
                screenShake(3.5, 0.6)
                sound("112192533344145", 2)
                sound("106734683831601", 3)
            end

            task.delay(1, oh_detach)

            attachConn2 = RunService.Heartbeat:Connect(function()
                local myChar = player.Character
                local tgChar = targetPlayer2 and targetPlayer2.Character
                if not myChar or not tgChar then return end
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local tgRoot = tgChar:FindFirstChild("HumanoidRootPart")
                if not myRoot or not tgRoot then return end
                pcall(function() sethiddenproperty(myRoot, "PhysicsRepRootPart", tgRoot) end)
                myRoot.CFrame = tgRoot.CFrame * CFrame.new(0, 1, 0.5)
            end)

            local movel = 0.1
            flingConn2 = RunService.Heartbeat:Connect(function()
                local myChar = player.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                local vel = myRoot.Velocity
                myRoot.Velocity = vel * 4.0 + Vector3.new(-25, 75, -150)
                task.spawn(function()
                    RunService.RenderStepped:Wait()
                    if myRoot then myRoot.Velocity = vel end
                    RunService.Stepped:Wait()
                    if myRoot then myRoot.Velocity = vel + Vector3.new(0, movel, 0) end
                    movel = -movel
                end)
            end)
        end

        scanConn2 = RunService.Heartbeat:Connect(function()
            if not oh_enabled or targetPlayer2 then return end
            local myChar = player.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            local best, bestDist = nil, 20
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local d = (root.Position - myRoot.Position).Magnitude
                        if d < bestDist then bestDist = d; best = plr end
                    end
                end
            end
            if best then oh_attach(best) end
        end)
    end)
end

local function executeUppercut()
    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid  = character:WaitForChild("Humanoid")
        local hrp       = character:WaitForChild("HumanoidRootPart")

        local snd2 = Instance.new("Sound")
        snd2.SoundId      = "rbxassetid://133798788003822"
        snd2.Volume       = 1
        snd2.PlaybackSpeed = 1
        local ps2 = Instance.new("PitchShiftSoundEffect")
        ps2.Octave  = 1
        ps2.Parent  = snd2
        snd2.Parent = workspace
        snd2:Play()
        snd2.Ended:Connect(function() snd2:Destroy() end)

        local animB = Instance.new("Animation")
        animB.AnimationId = "rbxassetid://233329237"
        local trackB = humanoid:LoadAnimation(animB)
        trackB:Play(0.3)
        trackB.TimePosition = 0.1
        trackB:AdjustSpeed(0)
        task.delay(0.5, function() trackB:Stop(0.3) end)

        effectPillar(hrp.Position, C_BRIGHT, 70, 1.0)
        effectPillar(hrp.Position, C_MID,    45, 0.75)
        effectRing(hrp.Position, 0.5, 18, C_BRIGHT, 0.45)
        effectRing(hrp.Position, 0.5, 10, C_MID,    0.55)
        effectLightningWeb(hrp.Position, 8, C_BRIGHT)
        effectSplash(hrp.Position, 20, 12, C_BRIGHT, 0.5, 80)
        effectOrbitalRing(hrp, 2.5, 6, C_MID, 4.0, 0.5)
        effectScreenFlash(0.1)
        screenShake(1.0, 0.25)

        task.wait(0.5)

        effectShockwaveBurst(hrp.Position)
        effectGroundCracks(hrp.Position, 12, C_MID)
        effectSplash(hrp.Position, 35, 22, C_BRIGHT, 0.6, 90)
        effectDebrisColumn(hrp.Position, C_MID)
        effectRune(hrp.Position, C_CORE, 0.45)
        screenShake(2.2, 0.4)
        effectScreenFlash(0.15)
        sound("112192533344145", 2)

        if not ReplicatedStorage:FindFirstChild("neo'sfling") then
            local d = Instance.new("Decal")
            d.Name   = "neo'sfling"
            d.Parent = ReplicatedStorage
        end

        local uc_target
        local uc_attachConn
        local uc_scanConn
        local uc_enabled  = true
        local uc_attached = false

        local leapDistance = 18
        local leapHeight   = 170

        local function uc_leapForward()
            if uc_attached or not hrp then return end
            local bv = Instance.new("BodyVelocity")
            bv.Velocity  = hrp.CFrame.LookVector * leapDistance + Vector3.new(0, leapHeight, 0)
            bv.MaxForce  = Vector3.new(100000, 100000, 100000)
            bv.P         = 5000
            bv.Parent    = hrp
            Debris:AddItem(bv, 0.1)

            effectPillar(hrp.Position, C_BRIGHT, 100, 1.4)
            effectSplash(hrp.Position, 20, 14, C_MID, 0.5, 90)
            effectLightningWeb(hrp.Position, 6, C_BRIGHT)
        end

        local function uc_detach()
            if uc_attachConn then uc_attachConn:Disconnect(); uc_attachConn = nil end
            if uc_scanConn   then uc_scanConn:Disconnect();   uc_scanConn   = nil end
            uc_target   = nil
            uc_enabled  = false
        end

        local function uc_attach(plr)
            if not uc_enabled or uc_attached then return end
            uc_attached = true
            uc_target   = plr

            local tc = plr.Character
            local tr = tc and tc:FindFirstChild("HumanoidRootPart")
            if tr then
                local ip = tr.Position
                effectShockwaveBurst(ip)
                effectShockwaveBurst(ip + Vector3.new(0, 5, 0))
                effectGroundCracks(ip, 16, C_BRIGHT)
                effectPillar(ip, C_BRIGHT, 90, 1.3)
                effectPillar(ip, C_MID,    60, 1.0)
                effectSplash(ip, 50, 28, C_BRIGHT, 0.8, 90)
                effectSplash(ip, 25, 16, C_MID,    0.6, 60)
                effectLightningWeb(ip, 16, C_BRIGHT)
                effectRune(ip, C_CORE, 0.6)
                effectDebrisColumn(ip, C_MID)
                effectScreenFlash(0.25)
                screenShake(4.0, 0.65)
                sound("129146504545701", 3)
                sound("106734683831601", 3)
            end

            task.delay(0.45, uc_detach)

            uc_attachConn = RunService.Heartbeat:Connect(function()
                local myChar = player.Character
                local tgChar = uc_target and uc_target.Character
                if not myChar or not tgChar then return end
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local tgRoot = tgChar:FindFirstChild("HumanoidRootPart")
                if not myRoot or not tgRoot then return end
                pcall(function() sethiddenproperty(myRoot, "PhysicsRepRootPart", tgRoot) end)
                myRoot.CFrame    = tgRoot.CFrame * CFrame.new(0, -3.88, -0.3)
                myRoot.Velocity  = Vector3.zero
                myRoot.RotVelocity = Vector3.zero
            end)
        end

        task.delay(0.8, function()
            if not uc_attached and uc_enabled then
                if uc_scanConn then uc_scanConn:Disconnect(); uc_scanConn = nil end
                uc_enabled = false
                uc_leapForward()
            end
        end)

        uc_scanConn = RunService.Heartbeat:Connect(function()
            if not uc_enabled or uc_attached or uc_target then return end
            local myChar = player.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and (root.Position - myRoot.Position).Magnitude <= 5 then
                        uc_attach(plr)
                        break
                    end
                end
            end
        end)

        local animC = Instance.new("Animation")
        animC.AnimationId = "rbxassetid://233064613"
        local trackC = humanoid:LoadAnimation(animC)
        trackC:Play(0.5)
        trackC.TimePosition = 0
        trackC:AdjustSpeed(1)
        task.delay(1, function() trackC:Stop(0.5) end)

        local animD = Instance.new("Animation")
        animD.AnimationId = "rbxassetid://85835312"
        local trackD = humanoid:LoadAnimation(animD)
        trackD:Play(0.45)
        trackD.TimePosition = 0
        trackD:AdjustSpeed(1)
        task.delay(1, function() trackD:Stop(0.45) end)
    end)
end

local actionCooldowns = {
    DieButton       = 0,
    CrushButton     = 0,
    JudgementButton = 0,
    PrepareButton   = 0,
    OverheadButton  = 0,
    UppercutButton  = 0
}

local cooldownTimes = {
    DieButton       = 4,
    CrushButton     = 6,
    JudgementButton = 8,
    PrepareButton   = 15,
    OverheadButton  = 5,
    UppercutButton  = 4
}

local buttonBusy = {
    DieButton       = false,
    CrushButton     = false,
    JudgementButton = false,
    PrepareButton   = false,
    OverheadButton  = false,
    UppercutButton  = false
}

local function createActionButtons()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MinosActionButtonsGui"
    screenGui.ResetOnSpawn = true
    screenGui.Parent = playerGui

    local topContainer = Instance.new("Frame")
    topContainer.Size               = UDim2.new(0, 130, 0, 62)
    topContainer.Position           = UDim2.new(1, -380, 1, -192)
    topContainer.BackgroundTransparency = 1
    topContainer.BorderSizePixel    = 0
    topContainer.Parent             = screenGui

    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection         = Enum.FillDirection.Horizontal
    topLayout.HorizontalAlignment   = Enum.HorizontalAlignment.Left
    topLayout.VerticalAlignment     = Enum.VerticalAlignment.Center
    topLayout.SortOrder             = Enum.SortOrder.LayoutOrder
    topLayout.Padding               = UDim.new(0, 10)
    topLayout.Parent                = topContainer

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 290, 0, 70)
    container.Position = UDim2.new(1, -380, 1, -110)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Parent = screenGui

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = container

    local function isOffCooldown(name)
        return tick() >= (actionCooldowns[name] + cooldownTimes[name])
    end

    local function fireAction(name, btn, text, onClick)
        if buttonBusy[name] then
            return
        end

        local currentTime = tick()
        if currentTime < (actionCooldowns[name] + cooldownTimes[name]) then
            return
        end

        if name == "DieButton" or name == "CrushButton" then
            local cChar = player.Character
            local cHum = cChar and cChar:FindFirstChild("Humanoid")
            if cHum and cHum.FloorMaterial ~= Enum.Material.Air then
                return
            end
        elseif name == "JudgementButton" then
            local cChar = player.Character
            local cHum = cChar and cChar:FindFirstChild("Humanoid")
            if cHum and cHum.FloorMaterial == Enum.Material.Air then
                return
            end
        end

        buttonBusy[name] = true
        actionCooldowns[name] = currentTime

        local originalText = btn and (btn:GetAttribute("BaseText") or text) or text
        if btn and btn.Parent then
            btn.Text = "CD"
            btn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
        end

        local skillSound = Instance.new("Sound")
        skillSound.SoundId = "rbxassetid://106734683831601"
        skillSound.Volume = 2
        skillSound.Parent = workspace
        skillSound:Play()
        skillSound.Ended:Connect(function()
            skillSound:Destroy()
        end)

        task.spawn(function()
            pcall(onClick)
        end)

        task.spawn(function()
            while btn and btn.Parent do
                local remaining = (actionCooldowns[name] + cooldownTimes[name]) - tick()
                if remaining <= 0 then
                    break
                end
                btn.Text = tostring(math.ceil(remaining))
                task.wait(0.1)
            end

            if btn and btn.Parent then
                btn.Text = originalText
                btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            end
            buttonBusy[name] = false
        end)
    end

    local function makeSquareButton(name, text, layoutOrder, onClick, parentContainer)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 60, 0, 60)
        btn.LayoutOrder = layoutOrder
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.TextWrapped = true
        btn.Text = text
        btn.BorderSizePixel = 0
        btn:SetAttribute("BaseText", text)
        btn.Parent = parentContainer or container

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(110, 110, 110)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = btn

        btn.MouseEnter:Connect(function()
            if isOffCooldown(name) and not buttonBusy[name] then
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            end
        end)

        btn.MouseLeave:Connect(function()
            if isOffCooldown(name) and not buttonBusy[name] then
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
            end
        end)

        btn.MouseButton1Down:Connect(function()
            if isOffCooldown(name) and not buttonBusy[name] then
                TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
            end
        end)

        btn.MouseButton1Up:Connect(function()
            if isOffCooldown(name) and not buttonBusy[name] then
                TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            end
        end)

        btn.Activated:Connect(function()
            fireAction(name, btn, text, onClick)
        end)

        return btn
    end

    local overheadBtn = makeSquareButton("OverheadButton", "OVER\nHEAD\nQ", 1, executeOverhead, topContainer)
    local uppercutBtn = makeSquareButton("UppercutButton", "UPPER\nCUT\nE", 2, executeUppercut, topContainer)

    for _, btn in ipairs({overheadBtn, uppercutBtn}) do
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = Color3.fromRGB(160, 30, 30)
        end
    end

    local dieBtn = makeSquareButton("DieButton", "DIE\n1", 1, executeDie)
    local crushBtn = makeSquareButton("CrushButton", "CRUSH\n2", 2, executeCrush)
    local judgementBtn = makeSquareButton("JudgementButton", "JUDGE\n3", 3, executeJudgement)
    local prepareBtn = makeSquareButton("PrepareButton", "PREPARE\n4", 4, executePrepareThyself)

    local customJumpBtn = Instance.new("TextButton")
    customJumpBtn.Name = "CustomJumpButton"
    customJumpBtn.Size = UDim2.new(0, 75, 0, 75)
    customJumpBtn.Position = UDim2.new(1, -115, 1, -115)
    customJumpBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    customJumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    customJumpBtn.Font = Enum.Font.GothamBold
    customJumpBtn.TextSize = 12
    customJumpBtn.Text = "JUMP\nSPACE"
    customJumpBtn.BorderSizePixel = 0
    customJumpBtn.Parent = screenGui

    local jumpCorner = Instance.new("UICorner")
    jumpCorner.CornerRadius = UDim.new(1, 0)
    jumpCorner.Parent = customJumpBtn

    local jumpStroke = Instance.new("UIStroke")
    jumpStroke.Thickness = 2
    jumpStroke.Color = Color3.fromRGB(110, 110, 110)
    jumpStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    jumpStroke.Parent = customJumpBtn

    customJumpBtn.MouseButton1Down:Connect(function()
        TweenService:Create(customJumpBtn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
    end)

    customJumpBtn.MouseButton1Up:Connect(function()
        TweenService:Create(customJumpBtn, TweenInfo.new(0.05), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
    end)

    local lastLeapTime = 0
    local LEAP_COOLDOWN = 3

    if UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled then
        customJumpBtn.Position = UDim2.new(1, -115, 1, -115)
    end

    customJumpBtn.Activated:Connect(function()
        local cChar = player.Character
        if not cChar then return end
        local cHum = cChar:FindFirstChild("Humanoid")
        local cRoot = cChar:FindFirstChild("HumanoidRootPart")
        if not cHum or not cRoot then return end

        local now = tick()
        if now - lastLeapTime < LEAP_COOLDOWN then return end
        lastLeapTime = now

        if cHum.Sit then
            cHum.Sit = false
            cHum.Jump = true
            return
        end

        local leapDistance = 0
        local leapHeight = 65

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = cRoot.CFrame.LookVector * leapDistance + Vector3.new(0, leapHeight, 0)
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.P = 5000
        bodyVelocity.Parent = cRoot

        Debris:AddItem(bodyVelocity, 0.1)
    end)

    local keyActions = {
        [Enum.KeyCode.Q] = {name = "OverheadButton", button = overheadBtn, text = "OVER\nHEAD\nQ", callback = executeOverhead},
        [Enum.KeyCode.E] = {name = "UppercutButton", button = uppercutBtn, text = "UPPER\nCUT\nE", callback = executeUppercut},
        [Enum.KeyCode.One] = {name = "DieButton", button = dieBtn, text = "DIE\n1", callback = executeDie},
        [Enum.KeyCode.Two] = {name = "CrushButton", button = crushBtn, text = "CRUSH\n2", callback = executeCrush},
        [Enum.KeyCode.Three] = {name = "JudgementButton", button = judgementBtn, text = "JUDGE\n3", callback = executeJudgement},
        [Enum.KeyCode.Four] = {name = "PrepareButton", button = prepareBtn, text = "PREPARE\n4", callback = executePrepareThyself}
    }

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not UserInputService.KeyboardEnabled then return end

        local action = keyActions[input.KeyCode]
        if action then
            fireAction(action.name, action.button, action.text, action.callback)
            return
        end

        if input.KeyCode == Enum.KeyCode.Space and customJumpBtn.Parent then
            customJumpBtn:Activate()
        end
    end)
end

humanoid.Died:Connect(function()
    if bgSound then
        bgSound:Destroy()
    end
    local uiButtons = playerGui:FindFirstChild("MinosActionButtonsGui")
    if uiButtons then
        uiButtons:Destroy()
    end
    local uiJudgement = playerGui:FindFirstChild("MinosSpawn_JudgementCard")
    if uiJudgement then
        uiJudgement:Destroy()
    end
    script.Enabled = false
    script:Destroy()
end)

FX.DarkenAtmosphere(1)
FX.LightningFlicker(3, hrp)

humanoid.AutoRotate = false
humanoid.PlatformStand = true
humanoid.Sit = true
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

local startPosition = hrp.Position
local attachment = Instance.new("Attachment"); attachment.Parent = hrp

local alignRot = Instance.new("AlignOrientation")
alignRot.Mode = Enum.OrientationAlignmentMode.OneAttachment
alignRot.Attachment0 = attachment
alignRot.MaxTorque = math.huge; alignRot.Responsiveness = 200
alignRot.RigidityEnabled = true; alignRot.CFrame = hrp.CFrame; alignRot.Parent = hrp

local alignPos = Instance.new("AlignPosition")
alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
alignPos.Attachment0 = attachment
alignPos.MaxForce = math.huge; alignPos.Responsiveness = 200
alignPos.RigidityEnabled = true; alignPos.Position = startPosition; alignPos.Parent = hrp

local spawnLight, motes, eyeGlow

FX.DescendingOrb(hrp.Position, function()
    spawnLight = FX.CreateSpawnLight(hrp)
    motes = FX.CreateRisingMotes(hrp)
    eyeGlow = FX.EyeGlow(character)

    FX.GroundShockwaveRing(hrp.Position - Vector3.new(0, 3, 0))
    FX.ChainBurst(hrp.Position)
    FX.LightPillars(hrp.Position)
    FX.JudgementCard("MINOS PRIME", "JUDGE OF HELL")

    local soundId = getsfxid("minosspawn")
    if soundId then sfx(soundId, workspace, 11) end
end)

local Frames = {
    { Time = 0.1, StayTime = 1.6, RX = 0, RY = 0, RZ = 0, PX = 0, PY = -5.5, PZ = 0 },
    { Time = 0, StayTime = 1.5, RX = -90, RY = 0, RZ = 0, PX = 0, PY = -2, PZ = 0 },
    { Time = 1, StayTime = 0.8, RX = -70, RY = 0, RZ = 0, PX = 0, PY = -2.2, PZ = 0 },
    { Time = 1, StayTime = 3.5, RX = 10, RY = 0, RZ = 0, PX = 0, PY = -0.1, PZ = 0 },
    { Time = 0.5, StayTime = 0.2, RX = 0, RY = 0, RZ = 0, PX = 0, PY = 0, PZ = 0 },
}

local function lerp(a, b, t) return a + (b - a) * t end
local function lerpAngle(a, b, t) return a + math.atan2(math.sin(b - a), math.cos(b - a)) * t end

local currentYaw = math.rad(hrp.Orientation.Y)
local frame = 1
local frameStart = tick()
local connection

local function cleanupPoseRig()
    if alignRot then alignRot:Destroy() end
    if alignPos then alignPos:Destroy() end
    if attachment then attachment:Destroy() end
    humanoid.AutoRotate = true
    humanoid.PlatformStand = false
    if spawnLight then
        tween(spawnLight, { Brightness = 0, Range = 0 }, 1):Play()
        Debris:AddItem(spawnLight, 1.2)
    end
    if motes then
        motes.Enabled = false
        Debris:AddItem(motes, 3)
    end
    if eyeGlow then
        tween(eyeGlow, { Brightness = 0, Range = 0 }, 1.5):Play()
        Debris:AddItem(eyeGlow, 1.6)
    end
    FX.RestoreAtmosphere(2)
end

connection = RunService.Heartbeat:Connect(function(dt)
    if humanoid.Health <= 0 then
        connection:Disconnect()
        cleanupPoseRig()
        return
    end
    local current = Frames[frame]
    if not current then
        connection:Disconnect()
        cleanupPoseRig()
        return
    end
    local startRX, startRY, startRZ = 0, 0, 0
    local startPX, startPY, startPZ = 0, 0, 0
    if frame > 1 then
        local previous = Frames[frame - 1]
        startRX, startRY, startRZ = previous.RX, previous.RY, previous.RZ
        startPX, startPY, startPZ = previous.PX, previous.PY, previous.PZ
    end
    local elapsed = tick() - frameStart
    local alpha = math.clamp(elapsed / current.Time, 0, 1)
    local rx = lerp(startRX, current.RX, alpha)
    local ry = lerp(startRY, current.RY, alpha)
    local rz = lerp(startRZ, current.RZ, alpha)
    local px = lerp(startPX, current.PX, alpha)
    local py = lerp(startPY, current.PY, alpha)
    local pz = lerp(startPZ, current.PZ, alpha)
    local moveDir = humanoid.MoveDirection
    local targetYaw = currentYaw
    if moveDir.Magnitude > 0.01 then
        targetYaw = math.atan2(-moveDir.X, -moveDir.Z)
    end
    currentYaw = lerpAngle(currentYaw, targetYaw, dt * 15)
    alignRot.CFrame = CFrame.Angles(0, currentYaw, 0) * CFrame.fromEulerAnglesYXZ(math.rad(rx), math.rad(ry), math.rad(rz))
    alignPos.Position = startPosition + Vector3.new(px, py, pz)
    if elapsed >= current.Time + (current.StayTime or 0) then
        frame += 1
        frameStart = tick()
    end
end)

task.spawn(function()
    CameraController.PlayTopDownZoom(1.5)
end)

do
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://121572214"
    local track = humanoid:LoadAnimation(anim)
    local fadeTime = 0.2
    track:Play(fadeTime)
    track.TimePosition = 1
    track:AdjustSpeed(0)
    task.delay(1.5, function() track:Stop(fadeTime) end)
end

task.wait(1.5)

task.spawn(function()
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.Parent = playerGui

    local flash = Instance.new("Frame")
    flash.Size = UDim2.fromScale(1, 1)
    flash.BackgroundColor3 = Color3.new(1, 1, 1)
    flash.BorderSizePixel = 0
    flash.BackgroundTransparency = 1
    flash.Parent = gui

    TweenService:Create(flash, TweenInfo.new(0.03, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
    task.wait(0.03)
    task.wait(0.1)
    TweenService:Create(flash, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
    task.wait(0.08)
    gui:Destroy()

    FX.RedVignettePulse(0.45)

    CameraController.TriggerShake(0.45, 0.8)
    CameraController.PlayAnim2Camera(3.0, startPosition)
end)

do
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://97170520"
    local track = humanoid:LoadAnimation(anim)
    local fadeTime = 0.5
    track:Play(fadeTime)
    track.TimePosition = 0.3
    track:AdjustSpeed(0.1)
    task.delay(3, function() track:Stop(fadeTime) end)
end

task.wait(3)

do
    FX.JudgementGroundGlyph(hrp.Position, 5)
    FX.OrbitalAuraSpiral(hrp, 5)

    CameraController.StartOrbitCamera(3.8)

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://93648331"
    local track = humanoid:LoadAnimation(anim)
    local fadeTime = 0.8
    track:Play(fadeTime)
    track.TimePosition = 0.25
    track:AdjustSpeed(0.1)

    task.wait(3.8)

    track:AdjustSpeed(0)

    CameraController.SmoothReturnCamera(1.2)

    task.delay(1.2, function()

        if alignRot then
            alignRot.Enabled = false
            alignRot:Destroy()
        end
        if alignPos then
            alignPos.Enabled = false
            alignPos:Destroy()
        end
        if attachment then attachment:Destroy() end

        humanoid.AutoRotate = true
        humanoid.PlatformStand = false

        track:Stop(fadeTime)

        createActionButtons()
    end)
end
