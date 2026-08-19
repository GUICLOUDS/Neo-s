local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
if CoreGui:FindFirstChild("EmoteWheelV5") then
    CoreGui:FindFirstChild("EmoteWheelV5"):Destroy()
end
local getAsset = getcustomasset or getsynasset
local OPEN_KEY     = Enum.KeyCode.Q
local MAX_PER_PAGE = 5
local OUTER_R  = 175
local INNER_R  = 52
local GAP_DEG  = 3
local RES      = 420
local HALF     = RES / 2
local DISPLAY  = 400
local SCALE    = DISPLAY / RES
local KEYBINDS          = {}
local ListeningEmote    = nil
local ListeningKeyBtn   = nil
local KeybindRows       = {}
local EMOTES = {
    {
        Name      = "Konton Boogie",
        Short     = "Konton\nBoogie",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Konton%20boogie%20animation%20new%20base.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/konton.mp3",
        AudioName = "Konton",
        Duration  = 10, StartPos = 0, MusicEarly = 0.01,
    },
    {
        Name      = "Headlock",
        Short     = "Headlock",
        AnimationId = 115314801778772,
        AnimationSpeed = 1,
        DirectAnimation = true,
        MoveLock = true,
    },
    {
        Name      = "Tenna Dance",
        Short     = "Tenna\nDance",
        AnimationId = 75202452138001,
        AnimationSpeed = 1.524,
        DirectAnimation = true,
        MoveLock = true,
    },

    {
        Name      = "Looping the Rooms",
        Short     = "Looping\nRooms",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Looping%20the%20rooms%20animation%20new%20base.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260805210812.mp3",
        AudioName = "Looping",
        Duration  = 19, StartPos = 0, MusicEarly = 0.3,
    },
    {
        Name      = "Kwik Flip",
        Short     = "Kwik\nFlip",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Kwip%20trip%20animation%20new%20base.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260806002743.mp3",
        AudioName = "Kwik",
        Duration  = 19, StartPos = 0, MusicEarly = 0.3,
    },
    {
        Name      = "Silly Billy",
        Short     = "Silly\nBilly",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Silly_billy_animation.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260806103752.mp3",
        AudioName = "Silly",
        Duration  = 39, StartPos = 0, MusicEarly = 1.7,
    },
    {
        Name      = "Psyco Teddy",
        Short     = "Psyco\nTeddy",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Psyco_teddy_animation.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260806134152.mp3",
        AudioName = "Teddy",
        Duration  = 19, StartPos = 0, MusicEarly = 0.2,
    },
    {
        Name      = "Yararara",
        Short     = "Yararara",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Yararara%20animation.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260806181524.mp3",
        AudioName = "Yararara",
        Duration  = 19, StartPos = 0, MusicEarly = 0.3,
    },
    {
        Name      = "Imposter Syndrome",
        Short     = "Imposter\nSyndrome",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Imposter%20syndrome%20animation.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260806194113.mp3",
        AudioName = "Imposter",
        Duration  = 19, StartPos = 0, MusicEarly = 3,
    },
        {
        Name      = "Dont Hide Tung",
        Short     = "Dont Hide\nTung",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Don't%20hide%20tung%20animation.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260808162616.mp3",
        AudioName = "Tung",
        Duration  = 19, StartPos = 0, MusicEarly = 0.5,
    },
    {
        Name      = "Bang Bang",
        Short     = "Bang\nBang",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Bang%20bang%20bang%20animation.txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260808173335.mp3",
        AudioName = "Bang",
        Duration  = 19, StartPos = 0, MusicEarly = 1.25,
    },
    {
        Name      = "Hakari Dance",
        Short     = "Hakari\nDance",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/Hakari%20animation%20(1).txt",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260808221502.mp3",
        AudioName = "Hakari",
        Duration  = 19, StartPos = 0, MusicEarly = 0.1,
    },
    {
        Name      = "Kwik Bypass",
        Short     = "Kwik\nBypass",
        Url       = "https://raw.githubusercontent.com/GUICLOUDS/EMOTES/refs/heads/main/kwik%20bypass",
        AudioUrl  = "https://github.com/anhubuniversal-create/Obfuscation-/raw/refs/heads/main/lv_0_20260806002743.mp3",
        AudioName = "Kwik",
        Duration  = 19, StartPos = 0, MusicEarly = 0.3,
    },
}
local TotalPages   = math.max(1, math.ceil(#EMOTES / MAX_PER_PAGE))
local CurrentPage  = 1
local function getPageEmotes(page)
    local startIdx = (page - 1) * MAX_PER_PAGE + 1
    local endIdx   = math.min(startIdx + MAX_PER_PAGE - 1, #EMOTES)
    local result   = {}
    for i = startIdx, endIdx do
        table.insert(result, EMOTES[i])
    end
    return result
end
local ScriptCache    = {}
local WheelIsOpen    = false
local NoMusicEnabled = false
local CurrentSound   = nil
local HoveredSlice   = nil
local ActiveToken    = nil
local IsEmoting      = false
local EmoteOrigin    = nil
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Character.Archivable = true
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Character.Archivable = true
end)
for _, e in ipairs(EMOTES) do
    if not e.DirectAnimation then
        task.spawn(function()
            ScriptCache[e.Name] = game:HttpGet(e.Url)
            local fn = "ewv5_" .. e.AudioName .. ".mp3"
            if not isfile(fn) then writefile(fn, game:HttpGet(e.AudioUrl)) end
            e.LocalAudioId = getAsset(fn)
        end)
    end
end
local function CancelActiveEmote()
    if ActiveToken then
        ActiveToken.cancelled = true
        for _, conn in ipairs(ActiveToken.connections) do
            pcall(function() conn:Disconnect() end)
        end
        for _, snd in ipairs(ActiveToken.sounds) do
            pcall(function() if snd and snd.Parent then snd:Destroy() end end)
        end
        for _, trk in ipairs(ActiveToken.tracks) do
            pcall(function() trk:Stop(0) end)
        end
        local hum = ActiveToken.humanoid
        if hum then
            pcall(function()
                if ActiveToken.directTrack then
                    ActiveToken.directTrack:Stop(0)
                end
                hum.PlatformStand = false
                hum.Sit           = ActiveToken.oldSit or false
                hum.AutoRotate    = ActiveToken.oldAutoRotate ~= nil
                    and ActiveToken.oldAutoRotate or true
                if ActiveToken.oldWalkSpeed ~= nil then hum.WalkSpeed = ActiveToken.oldWalkSpeed end
                if ActiveToken.oldUseJumpPower ~= nil then hum.UseJumpPower = ActiveToken.oldUseJumpPower end
                if ActiveToken.oldJumpPower ~= nil then hum.JumpPower = ActiveToken.oldJumpPower end
                if ActiveToken.oldJumpHeight ~= nil then hum.JumpHeight = ActiveToken.oldJumpHeight end
            end)
        end
        if ActiveToken.restoreGhost then
            pcall(ActiveToken.restoreGhost)
        end
        local hrp = ActiveToken.hrp
        if hrp then
            pcall(function() hrp.Anchored = false end)
        end
        if ActiveToken.checkpoint then
            pcall(function()
                if ActiveToken.checkpoint.Parent then
                    ActiveToken.checkpoint:Destroy()
                end
            end)
        end
        ActiveToken = nil
    end
    if CurrentSound then CurrentSound:Destroy(); CurrentSound = nil end
    IsEmoting   = false
    EmoteOrigin = nil
end
local function NewToken()
    local token = {
        cancelled   = false,
        connections = {},
        sounds      = {},
        tracks      = {},
        humanoid    = nil,
        hrp         = nil,
        oldSit      = nil,
        oldAutoRotate = nil,
        oldWalkSpeed = nil,
        oldJumpPower = nil,
        oldJumpHeight = nil,
        oldUseJumpPower = nil,
        directAnimation = false,
        directTrack = nil,
        restoreGhost  = nil,
        checkpoint    = nil,
    }
    ActiveToken = token
    return token
end
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.22,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out),
        props):Play()
end
local ShowNotification = function() end
local function PlaySound(e)
    if CurrentSound then CurrentSound:Destroy(); CurrentSound = nil end
    if NoMusicEnabled then return end
    local s = Instance.new("Sound")
    while not e.LocalAudioId do task.wait(0.05) end
    s.SoundId, s.Volume, s.TimePosition = e.LocalAudioId, 1, (e.StartPos or 0)
    s.Parent = workspace; s:Play()
    CurrentSound = s
    task.delay(e.Duration, function()
        if s and s.Parent then s:Destroy() end
    end)
end
local function createSpoofedEnv(fn, token)
    local character = LocalPlayer.Character
    local fP  = setmetatable({Character = character},{__index = LocalPlayer})
    local fPs = setmetatable({LocalPlayer = fP},{__index = Players})
    local fRS = setmetatable({}, {
        __index = function(_, key)
            local orig = RunService[key]
            if key == "RenderStepped" or key == "Heartbeat" or key == "Stepped" then
                return setmetatable({}, {
                    __index = function(_, mkey)
                        if mkey == "Connect" then
                            return function(_, cb)
                                local conn = RunService[key]:Connect(function(dt)
                                    if token.cancelled then return end
                                    cb(dt)
                                end)
                                table.insert(token.connections, conn)
                                return conn
                            end
                        end
                        return orig[mkey]
                    end
                })
            end
            return orig
        end
    })
    local fG = setmetatable({Players = fPs}, {
        __index = function(_, k)
            if k == "GetService" then
                return function(_, svc)
                    if svc == "Players"    then return fPs end
                    if svc == "RunService" then return fRS end
                    return game:GetService(svc)
                end
            end
            return game[k]
        end
    })
    local fTask = setmetatable({}, {
        __index = function(_, k)
            if k == "spawn" then
                return function(cb)
                    task.spawn(function()
                        if token.cancelled then return end
                        cb()
                    end)
                end
            elseif k == "wait" or k == "delay" then
                return function(t2, cb2)
                    if cb2 then
                        task.delay(t2, function()
                            if token.cancelled then return end
                            cb2()
                        end)
                    else
                        task.wait(t2)
                    end
                end
            end
            return task[k]
        end
    })
    local function sfxWrapped(id, parent, duration, startPos)
        if token.cancelled then return Instance.new("Sound") end
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Parent  = parent
        s.Volume  = 1
        s:Play()
        s.TimePosition = startPos or 0
        table.insert(token.sounds, s)
        task.spawn(function()
            local fadeTime   = 3
            local startFade  = math.max((duration or s.TimeLength) - fadeTime, 0)
            task.wait(startFade)
            local startVol = s.Volume
            local steps    = 30
            for i = 1, steps do
                if not s.Parent or token.cancelled then break end
                s.Volume = startVol * (1 - (i / steps))
                task.wait(fadeTime / steps)
            end
            s.Volume = 0
        end)
        game.Debris:AddItem(s, duration or 0)
        return s
    end
    local humanoidProxy
    humanoidProxy = function(realHum)
        return setmetatable({}, {
            __index = function(_, k)
                if k == "LoadAnimation" then
                    return function(_, anim)
                        local trk = realHum:LoadAnimation(anim)
                        table.insert(token.tracks, trk)
                        return trk
                    end
                end
                if not token.humanoid then
                    token.humanoid       = realHum
                    token.oldSit         = realHum.Sit
                    token.oldAutoRotate  = realHum.AutoRotate
                end
                return realHum[k]
            end,
            __newindex = function(_, k, v)
                realHum[k] = v
            end,
        })
    end
    local charProxy = setmetatable({}, {
        __index = function(_, k)
            if k == "WaitForChild" then
                return function(_, name, timeout)
                    local obj = character:WaitForChild(name, timeout)
                    if name == "Humanoid" then
                        return humanoidProxy(obj)
                    end
                    if name == "HumanoidRootPart" then
                        token.hrp = obj
                    end
                    return obj
                end
            end
            return character[k]
        end,
        __newindex = function(_, k, v) character[k] = v end,
    })
    local fPWrapped  = setmetatable({Character = charProxy},{__index = LocalPlayer})
    local fPsWrapped = setmetatable({LocalPlayer = fPWrapped},{__index = Players})
    fG.Players = fPsWrapped
    local function WaitWrapped(t2)
        if token.cancelled then return end
        task.wait(t2)
    end
    local env = getfenv(fn)
    return setmetatable({
        game           = fG,
        Game           = fG,
        workspace      = workspace,
        task           = fTask,
        Wait           = WaitWrapped,
        wait           = WaitWrapped,
        sfx            = sfxWrapped,
        RunService     = fRS,
        _cancelToken   = token,
    }, {
        __index    = env,
        __newindex = function(_, k, v) env[k] = v end,
    })
end
local function ExecEmote(e)
    CancelActiveEmote()
    local token = NewToken()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then EmoteOrigin = hrp.CFrame end
    end
    IsEmoting = true
    ShowNotification(e.Name, not NoMusicEnabled)

    if e.DirectAnimation then
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then
            IsEmoting = false
            EmoteOrigin = nil
            ActiveToken = nil
            return
        end

        token.humanoid = hum
        token.hrp = char:FindFirstChild("HumanoidRootPart")
        token.oldSit = hum.Sit
        token.oldAutoRotate = hum.AutoRotate
        token.oldWalkSpeed = hum.WalkSpeed
        token.oldJumpPower = hum.JumpPower
        token.oldJumpHeight = hum.JumpHeight
        token.oldUseJumpPower = hum.UseJumpPower
        token.directAnimation = true

        local anim = Instance.new("Animation")
        anim.AnimationId = "http://www.roblox.com/asset/?version=1&id=" .. tostring(e.AnimationId)
        local track
        local ok = pcall(function()
            track = hum:LoadAnimation(anim)
        end)
        anim:Destroy()
        if not ok or not track then
            CancelActiveEmote()
            return
        end

        token.directTrack = track
        table.insert(token.tracks, track)
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = true

        if e.MoveLock then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.JumpHeight = 0
            hum.AutoRotate = false
            hum:Move(Vector3.zero, true)
        end

        track:Play(0.12, 1, e.AnimationSpeed or 1)
        return
    end

    local early = e.MusicEarly or 0
    PlaySound(e)
    task.spawn(function()
        local fallback = e.Duration or 30
        local elapsed  = 0
        local interval = 0.1
        local waitedForTrack = 0
        while #token.tracks == 0 and not token.cancelled and waitedForTrack < 3 do
            task.wait(interval)
            waitedForTrack = waitedForTrack + interval
        end
        if token.cancelled then return end
        if #token.tracks == 0 then
            task.wait(math.max(0, fallback - waitedForTrack))
            if ActiveToken == token then
                IsEmoting   = false
                EmoteOrigin = nil
            end
            return
        end
        while not token.cancelled and elapsed < fallback do
            task.wait(interval)
            elapsed = elapsed + interval
            local anyPlaying = false
            for _, trk in ipairs(token.tracks) do
                if trk and trk.IsPlaying then
                    anyPlaying = true
                    break
                end
            end
            if not anyPlaying then break end
        end
        if ActiveToken == token and not token.cancelled then
            IsEmoting   = false
            EmoteOrigin = nil
        end
    end)
    task.delay(early, function()
        if token.cancelled then return end
        local code = ScriptCache[e.Name]
        if code then
            task.spawn(function()
                local fn = loadstring(code)
                if fn then
                    setfenv(fn, createSpoofedEnv(fn, token))
                    pcall(fn)
                end
            end)
        elseif not ScriptCache[e.Name] then
            task.spawn(function()
                while not ScriptCache[e.Name] do task.wait(0.05) end
                if token.cancelled then return end
                local fn = loadstring(ScriptCache[e.Name])
                if fn then
                    setfenv(fn, createSpoofedEnv(fn, token))
                    pcall(fn)
                end
            end)
        end
    end)
end
local function RunRig(clone, e)
    task.spawn(function()
        if e.DirectAnimation then
            local hum = clone:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local anim = Instance.new("Animation")
            anim.AnimationId = "http://www.roblox.com/asset/?version=1&id=" .. tostring(e.AnimationId)
            local track
            local ok = pcall(function()
                track = hum:LoadAnimation(anim)
            end)
            anim:Destroy()
            if not ok or not track then return end
            track.Priority = Enum.AnimationPriority.Action
            track.Looped = true
            track:Play(0.12, 1, e.AnimationSpeed or 1)
            return
        end
        while not ScriptCache[e.Name] do task.wait(0.05) end
        local fn = loadstring(ScriptCache[e.Name])
        if fn then
            local fP  = setmetatable({Character=clone},{__index=LocalPlayer})
            local fPs = setmetatable({LocalPlayer=fP},{__index=Players})
            local fG  = setmetatable({Players=fPs},{
                __index = function(_,k)
                    if k=="GetService" then
                        return function(_,svc)
                            if svc=="Players" then return fPs end
                            return game:GetService(svc)
                        end
                    end
                    return game[k]
                end
            })
            local env = getfenv(fn)
            setfenv(fn, setmetatable({game=fG, Game=fG, workspace=clone.Parent},{
                __index    = env,
                __newindex = function(_,k,v) env[k]=v end
            }))
            pcall(fn)
        end
    end)
end
local function makeBuffer()
    return table.create(RES * RES * 4, 0)
end
local function normAngle(a)
    local TAU = math.pi * 2
    while a  <  0   do a = a + TAU end
    while a >= TAU  do a = a - TAU end
    return a
end
local function angleInSlice(a, sA, eA)
    a  = normAngle(a)
    sA = normAngle(sA)
    eA = normAngle(eA)
    if sA <= eA then
        return a >= sA and a < eA
    else
        return a >= sA or  a < eA
    end
end
local function drawWheel(buf, hovered, pageEmotes)
    for i = 1, #buf do buf[i] = 0 end
    local num      = #pageEmotes
    local sliceRad = math.rad(360 / num)
    local gapRad   = math.rad(GAP_DEG)
    local startBase = -math.pi / 2
    for i = 1, num do
        local sA  = startBase + (i-1) * sliceRad + gapRad * 0.5
        local eA  = startBase +  i    * sliceRad - gapRad * 0.5
        local isH = (hovered == i)
        for py = 0, RES-1 do
            for px = 0, RES-1 do
                local dx   = px - HALF
                local dy   = py - HALF
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist >= INNER_R and dist <= OUTER_R then
                    local ang = math.atan2(dy, dx)
                    if angleInSlice(ang, sA, eA) then
                        local t = (dist - INNER_R) / (OUTER_R - INNER_R)
                        local pr, pg, pb, alpha
                        if isH then
                            local bright = math.floor(200 + t * 40)
                            pr, pg, pb = bright, bright, bright
                            alpha = math.floor(230 + t * 20)
                        else
                            local dark = math.floor(15 + t * 10)
                            pr, pg, pb = dark, dark, dark
                            alpha = math.floor(170 + t * 30)
                        end
                        if dist > OUTER_R - 2 then
                            alpha = math.floor(alpha * (OUTER_R - dist) / 2)
                        elseif dist < INNER_R + 2 then
                            alpha = math.floor(alpha * (dist - INNER_R) / 2)
                        end
                        alpha = math.max(0, math.min(255, alpha))
                        local idx = (py * RES + px) * 4 + 1
                        buf[idx]   = pr
                        buf[idx+1] = pg
                        buf[idx+2] = pb
                        buf[idx+3] = alpha
                    end
                end
            end
        end
    end
    for py = 0, RES-1 do
        for px = 0, RES-1 do
            local dx   = px - HALF
            local dy   = py - HALF
            local dist = math.sqrt(dx*dx + dy*dy)
            local idx  = (py * RES + px) * 4 + 1
            if math.abs(dist - OUTER_R) < 1.8 then
                local a = math.max(0, 255 - math.abs(dist - OUTER_R) * 145)
                buf[idx]=220; buf[idx+1]=220; buf[idx+2]=220; buf[idx+3]=a
            end
            if math.abs(dist - INNER_R) < 1.4 then
                local a = math.max(0, 200 - math.abs(dist - INNER_R) * 155)
                buf[idx]=180; buf[idx+1]=180; buf[idx+2]=180; buf[idx+3]=a
            end
        end
    end
    for i = 1, num do
        local lineAng = startBase + (i-1) * sliceRad
        local lx = math.cos(lineAng)
        local ly = math.sin(lineAng)
        for r = INNER_R, OUTER_R do
            local wx = HALF + lx * r
            local wy = HALF + ly * r
            for ox = -1, 1 do
                for oy = -1, 1 do
                    local px2 = math.floor(wx + ox)
                    local py2 = math.floor(wy + oy)
                    if px2 >= 0 and px2 < RES and py2 >= 0 and py2 < RES then
                        local perp = math.abs(ox * (-ly) + oy * lx)
                        if perp < 0.9 then
                            local idx = (py2 * RES + px2) * 4 + 1
                            local alpha = math.floor(220 * (1 - perp))
                            buf[idx]   = 220
                            buf[idx+1] = 220
                            buf[idx+2] = 220
                            buf[idx+3] = math.min(255, buf[idx+3] + alpha)
                        end
                    end
                end
            end
        end
    end
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "EmoteWheelV5"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = CoreGui
local Overlay = Instance.new("Frame")
Overlay.Size             = UDim2.new(1,0, 1,0)
Overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel  = 0
Overlay.ZIndex           = 1
Overlay.Visible          = false
Overlay.Parent           = ScreenGui
local TopHolder = Instance.new("Frame")
TopHolder.Size            = UDim2.new(0,140, 0,28)
TopHolder.Position        = UDim2.new(0.5,-70, 0,14)
TopHolder.BackgroundColor3= Color3.fromRGB(10,10,10)
TopHolder.BackgroundTransparency = 0.25
TopHolder.BorderSizePixel = 0
TopHolder.ZIndex          = 30
TopHolder.Parent          = ScreenGui
Instance.new("UICorner", TopHolder).CornerRadius = UDim.new(0,14)
local TopStroke = Instance.new("UIStroke")
TopStroke.Color       = Color3.fromRGB(200,200,200)
TopStroke.Thickness   = 1.2
TopStroke.Transparency = 0.4
TopStroke.Parent      = TopHolder
local TopBtn = Instance.new("TextButton")
TopBtn.Size               = UDim2.new(1,0, 1,0)
TopBtn.BackgroundTransparency = 1
TopBtn.Font               = Enum.Font.GothamBold
TopBtn.TextSize           = 11
TopBtn.TextColor3         = Color3.fromRGB(220,220,220)
TopBtn.Text               = "EMOTES  [Q]"
TopBtn.ZIndex             = 31
TopBtn.Parent             = TopHolder
local WheelContainer = Instance.new("Frame")
WheelContainer.Size             = UDim2.new(0,DISPLAY, 0,DISPLAY)
WheelContainer.Position         = UDim2.new(0.5,-DISPLAY/2, 0.5,-DISPLAY/2)
WheelContainer.BackgroundTransparency = 1
WheelContainer.ClipsDescendants = false
WheelContainer.Visible          = false
WheelContainer.ZIndex           = 5
WheelContainer.Parent           = ScreenGui
local CanvasFrame = Instance.new("Frame")
CanvasFrame.Size  = UDim2.new(1,0, 1,0)
CanvasFrame.BackgroundTransparency = 1
CanvasFrame.ZIndex = 6
CanvasFrame.Parent = WheelContainer
local editImg, imgLabel
pcall(function()
    editImg = Instance.new("EditableImage")
    editImg.Size = Vector2.new(RES, RES)
    imgLabel = Instance.new("ImageLabel")
    imgLabel.Size = UDim2.new(1,0, 1,0)
    imgLabel.BackgroundTransparency = 1
    imgLabel.ZIndex = 6
    imgLabel.Parent = CanvasFrame
    editImg.Parent  = imgLabel
end)
local pixBuf = makeBuffer()
local function redrawWheel(hov, pageEmotes)
    if not editImg then return end
    drawWheel(pixBuf, hov, pageEmotes)
    editImg:WritePixels(Vector2.zero, Vector2.new(RES, RES), pixBuf)
end
local function makeArrow(side)
    local arr = Instance.new("Frame")
    arr.Size             = UDim2.new(0,36, 0,36)
    arr.BackgroundTransparency = 1
    arr.BorderSizePixel  = 0
    arr.ZIndex           = 8
    if side == "left" then
        arr.Position = UDim2.new(0,-58, 0.5,-18)
    else
        arr.Position = UDim2.new(1,22, 0.5,-18)
    end
    arr.Parent = WheelContainer
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0, 1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 26
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.Text = side == "left" and "<" or ">"
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 9
    lbl.Parent = arr
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0, 1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 10
    btn.Parent = arr
    btn.MouseEnter:Connect(function()
        Tween(lbl, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(lbl, {TextColor3 = Color3.fromRGB(200,200,200)}, 0.12)
    end)
    return btn, lbl
end
local LeftBtn,  LeftLbl  = makeArrow("left")
local RightBtn, RightLbl = makeArrow("right")
local SliceData      = {}
local SliceContainer = Instance.new("Frame")
SliceContainer.Size  = UDim2.new(1,0, 1,0)
SliceContainer.BackgroundTransparency = 1
SliceContainer.ZIndex = 10
SliceContainer.Parent = CanvasFrame
local RigReplayFuncs = {}
local function buildSlices(pageEmotes)
    for _, sd in ipairs(SliceData) do
        if sd.Holder and sd.Holder.Parent then
            sd.Holder:Destroy()
        end
    end
    SliceData       = {}
    RigReplayFuncs  = {}
    local num      = #pageEmotes
    local sliceDeg = 360 / num
    local VP_SIZE  = 64
    local vpMidR   = (INNER_R + OUTER_R) / 2
    for i, emote in ipairs(pageEmotes) do
        local midDeg = -90 + (i-1)*sliceDeg + sliceDeg/2
        local midRad = math.rad(midDeg)
        local cx = DISPLAY/2 + math.cos(midRad) * vpMidR * SCALE
        local cy = DISPLAY/2 + math.sin(midRad) * vpMidR * SCALE
        local holder = Instance.new("Frame")
        holder.Size     = UDim2.new(0, VP_SIZE, 0, VP_SIZE + 20)
        holder.Position = UDim2.new(0, cx - VP_SIZE/2, 0, cy - VP_SIZE/2)
        holder.BackgroundTransparency = 1
        holder.ZIndex   = 10
        holder.Parent   = SliceContainer
        local vpf = Instance.new("ViewportFrame")
        vpf.Size  = UDim2.new(1,0, 0,VP_SIZE)
        vpf.BackgroundTransparency = 1
        vpf.ZIndex = 10
        vpf.Parent = holder
        Instance.new("UICorner", vpf).CornerRadius = UDim.new(0,8)
        local wm    = Instance.new("WorldModel"); wm.Parent = vpf
        local clone = Character:Clone()
        clone:PivotTo(CFrame.new(0,-3,0)); clone.Parent = wm
        for _, v in pairs(clone:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end
        end
        local rigHum = clone:FindFirstChildOfClass("Humanoid")
        if rigHum then
            rigHum.MaxHealth = math.huge
            rigHum.Health    = math.huge
        end
        local root = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Torso")
        local cam  = Instance.new("Camera")
        if root then
            local rp = root.Position
            cam.CFrame = CFrame.new(rp + Vector3.new(0,0.5,-5.5), rp + Vector3.new(0,0.5,0))
            cam.FieldOfView = 52
        end
        cam.Parent = vpf; vpf.CurrentCamera = cam
        local function ReplayRig() RunRig(clone, emote) end
        table.insert(RigReplayFuncs, ReplayRig)
        ReplayRig()
        local hoverBtn = Instance.new("TextButton")
        hoverBtn.Size = UDim2.new(0, VP_SIZE+16, 0, VP_SIZE+16)
        hoverBtn.Position = UDim2.new(0,-8, 0,-8)
        hoverBtn.BackgroundTransparency = 1
        hoverBtn.Text = ""
        hoverBtn.ZIndex = 25
        hoverBtn.Parent = holder
        hoverBtn.MouseEnter:Connect(function()
            Tween(holder, {Size = UDim2.new(0, VP_SIZE+10, 0, VP_SIZE+28)}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tween(vpf, {BackgroundTransparency = 0.1}, 0.12)
        end)
        hoverBtn.MouseLeave:Connect(function()
            Tween(holder, {Size = UDim2.new(0, VP_SIZE, 0, VP_SIZE+20)}, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            Tween(vpf, {BackgroundTransparency = 1}, 0.12)
        end)
        local glowStroke = Instance.new("UIStroke")
        glowStroke.Color        = Color3.fromRGB(255,255,255)
        glowStroke.Thickness    = 2
        glowStroke.Transparency = 1
        glowStroke.Parent       = vpf
        local lbl = Instance.new("TextLabel")
        lbl.Size  = UDim2.new(1,10, 0,20)
        lbl.Position = UDim2.new(-0.08,0, 0,VP_SIZE+2)
        lbl.BackgroundTransparency = 1
        lbl.Font  = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextColor3 = Color3.fromRGB(160,160,160)
        lbl.Text  = emote.Short
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.LineHeight = 1.1
        lbl.ZIndex = 12
        lbl.Parent = holder
        SliceData[i] = {
            Emote      = emote,
            Holder     = holder,
            Label      = lbl,
            GlowStroke = glowStroke,
        }
    end
end
local hubPx = INNER_R * 2 * SCALE
local Hub = Instance.new("Frame")
Hub.Size             = UDim2.new(0,hubPx, 0,hubPx)
Hub.Position         = UDim2.new(0.5,-hubPx/2, 0.5,-hubPx/2)
Hub.BackgroundColor3 = Color3.fromRGB(8,8,8)
Hub.BackgroundTransparency = 0.15
Hub.BorderSizePixel  = 0
Hub.ZIndex           = 14
Hub.Parent           = WheelContainer
Instance.new("UICorner", Hub).CornerRadius = UDim.new(1,0)
local HubStroke = Instance.new("UIStroke")
HubStroke.Color     = Color3.fromRGB(200,200,200)
HubStroke.Thickness = 1.8
HubStroke.Transparency = 0.3
HubStroke.Parent    = Hub
local HubDots = Instance.new("TextLabel")
HubDots.Size     = UDim2.new(1,0, 0,20)
HubDots.Position = UDim2.new(0,0, 0.5,-18)
HubDots.BackgroundTransparency = 1
HubDots.Font     = Enum.Font.GothamBold
HubDots.TextSize = 16
HubDots.TextColor3 = Color3.fromRGB(240,240,240)
HubDots.Text     = "O  O"
HubDots.TextXAlignment = Enum.TextXAlignment.Center
HubDots.ZIndex   = 16
HubDots.Parent   = Hub
local HubLabel = Instance.new("TextLabel")
HubLabel.Size     = UDim2.new(1,-6, 0,14)
HubLabel.Position = UDim2.new(0,3, 0.5,4)
HubLabel.BackgroundTransparency = 1
HubLabel.Font     = Enum.Font.GothamBold
HubLabel.TextSize = 8
HubLabel.TextColor3 = Color3.fromRGB(180,180,180)
HubLabel.Text     = "SELECT"
HubLabel.TextWrapped = true
HubLabel.TextXAlignment = Enum.TextXAlignment.Center
HubLabel.ZIndex   = 15
HubLabel.Parent   = Hub
local HitArea = Instance.new("TextButton")
HitArea.Size  = UDim2.new(1,0, 1,0)
HitArea.BackgroundTransparency = 1
HitArea.Text  = ""
HitArea.ZIndex = 20
HitArea.Parent = CanvasFrame
local BottomBar = Instance.new("Frame")
BottomBar.Size            = UDim2.new(0,320, 0,26)
BottomBar.Position        = UDim2.new(0.5,-160, 1,10)
BottomBar.BackgroundColor3= Color3.fromRGB(8,8,8)
BottomBar.BackgroundTransparency = 0.2
BottomBar.BorderSizePixel = 0
BottomBar.ZIndex          = 5
BottomBar.Parent          = WheelContainer
Instance.new("UICorner", BottomBar).CornerRadius = UDim.new(0,13)
local BottomStroke = Instance.new("UIStroke")
BottomStroke.Color     = Color3.fromRGB(160,160,160)
BottomStroke.Thickness = 1
BottomStroke.Transparency = 0.5
BottomStroke.Parent    = BottomBar
local HoldHint = Instance.new("TextLabel")
HoldHint.Size     = UDim2.new(0,90, 1,0)
HoldHint.Position = UDim2.new(0,10, 0,0)
HoldHint.BackgroundTransparency = 1
HoldHint.Font     = Enum.Font.Gotham
HoldHint.TextSize = 9
HoldHint.TextXAlignment = Enum.TextXAlignment.Left
HoldHint.TextColor3 = Color3.fromRGB(150,150,150)
HoldHint.Text     = "Release [Q] to play"
HoldHint.ZIndex   = 6
HoldHint.Parent   = BottomBar
local PageLabel = Instance.new("TextLabel")
PageLabel.Size     = UDim2.new(0,60, 1,0)
PageLabel.Position = UDim2.new(0.4,-30, 0,0)
PageLabel.BackgroundTransparency = 1
PageLabel.Font     = Enum.Font.GothamBold
PageLabel.TextSize = 9
PageLabel.TextXAlignment = Enum.TextXAlignment.Center
PageLabel.TextColor3 = Color3.fromRGB(180,180,180)
PageLabel.Text     = "1 / " .. TotalPages
PageLabel.ZIndex   = 6
PageLabel.Parent   = BottomBar
local KeysBtn = Instance.new("TextButton")
KeysBtn.Size            = UDim2.new(0,62, 1,-4)
KeysBtn.Position        = UDim2.new(1,-152, 0,2)
KeysBtn.BackgroundColor3= Color3.fromRGB(18,18,18)
KeysBtn.BorderSizePixel = 0
KeysBtn.Font            = Enum.Font.GothamBold
KeysBtn.TextSize        = 9
KeysBtn.TextColor3      = Color3.fromRGB(200,200,200)
KeysBtn.Text            = "KEYS"
KeysBtn.ZIndex          = 7
KeysBtn.Parent          = BottomBar
local KeysBtnStroke = Instance.new("UIStroke")
KeysBtnStroke.Color       = Color3.fromRGB(200,200,200)
KeysBtnStroke.Thickness   = 1
KeysBtnStroke.Transparency= 0.5
KeysBtnStroke.Parent      = KeysBtn
local MusicBtn = Instance.new("TextButton")
MusicBtn.Size            = UDim2.new(0,68, 1,-4)
MusicBtn.Position        = UDim2.new(1,-74, 0,2)
MusicBtn.BackgroundColor3= Color3.fromRGB(18,40,20)
MusicBtn.BorderSizePixel = 0
MusicBtn.Font            = Enum.Font.GothamSemibold
MusicBtn.TextSize        = 9
MusicBtn.TextColor3      = Color3.fromRGB(130,220,130)
MusicBtn.Text            = "~ ON"
MusicBtn.ZIndex          = 7
MusicBtn.Parent          = BottomBar
local MusicBtnStroke = Instance.new("UIStroke")
MusicBtnStroke.Color       = Color3.fromRGB(100,200,100)
MusicBtnStroke.Thickness   = 1
MusicBtnStroke.Transparency= 0.5
MusicBtnStroke.Parent      = MusicBtn
local KeybindPanelOpen = false
local KB_ROW_H  = 34
local KB_ROWS   = #EMOTES
local KB_W      = 310
local KB_H      = 48 + KB_ROWS * KB_ROW_H
local KBPanel = Instance.new("Frame")
KBPanel.Name                  = "KeybindPanel"
KBPanel.Size                  = UDim2.new(0, KB_W, 0, KB_H)
KBPanel.Position              = UDim2.new(0.5, -KB_W/2, 0.5, -KB_H/2)
KBPanel.BackgroundColor3      = Color3.fromRGB(8,8,8)
KBPanel.BackgroundTransparency= 0.06
KBPanel.BorderSizePixel       = 0
KBPanel.ZIndex                = 50
KBPanel.Visible               = false
KBPanel.Parent                = ScreenGui
local KBStroke = Instance.new("UIStroke")
KBStroke.Color       = Color3.fromRGB(220,220,220)
KBStroke.Thickness   = 1.4
KBStroke.Transparency= 0.3
KBStroke.Parent      = KBPanel
local KBTitle = Instance.new("TextLabel")
KBTitle.Size              = UDim2.new(1,-50, 0,36)
KBTitle.Position          = UDim2.new(0,16, 0,0)
KBTitle.BackgroundTransparency = 1
KBTitle.Font              = Enum.Font.GothamBold
KBTitle.TextSize          = 13
KBTitle.TextColor3        = Color3.fromRGB(240,240,240)
KBTitle.Text              = "KEYBINDS"
KBTitle.TextXAlignment    = Enum.TextXAlignment.Left
KBTitle.ZIndex            = 51
KBTitle.Parent            = KBPanel

local KBHint = Instance.new("TextLabel")
KBHint.Size              = UDim2.new(1,-16, 0,14)
KBHint.Position          = UDim2.new(0,16, 0,22)
KBHint.BackgroundTransparency = 1
KBHint.Font              = Enum.Font.Gotham
KBHint.TextSize          = 8
KBHint.TextColor3        = Color3.fromRGB(110,110,110)
KBHint.Text              = "Click a slot then press any key  |  ESC to cancel"
KBHint.TextXAlignment    = Enum.TextXAlignment.Left
KBHint.ZIndex            = 51
KBHint.Parent            = KBPanel
local KBClose = Instance.new("TextButton")
KBClose.Size              = UDim2.new(0,32, 0,32)
KBClose.Position          = UDim2.new(1,-38, 0,2)
KBClose.BackgroundTransparency = 1
KBClose.BorderSizePixel   = 0
KBClose.Font              = Enum.Font.GothamBold
KBClose.TextSize          = 13
KBClose.TextColor3        = Color3.fromRGB(200,200,200)
KBClose.Text              = "X"
KBClose.ZIndex            = 52
KBClose.Parent            = KBPanel
local KBDiv = Instance.new("Frame")
KBDiv.Size                = UDim2.new(1,-32, 0,1)
KBDiv.Position            = UDim2.new(0,16, 0,38)
KBDiv.BackgroundColor3    = Color3.fromRGB(200,200,200)
KBDiv.BackgroundTransparency = 0.65
KBDiv.BorderSizePixel     = 0
KBDiv.ZIndex              = 51
KBDiv.Parent              = KBPanel
local function keyCodeName(kc)
    local s = tostring(kc)
    return s:match("%.([^%.]+)$") or s
end
local function cancelListening()
    if ListeningKeyBtn then
        Tween(ListeningKeyBtn, {BackgroundColor3 = Color3.fromRGB(16,16,16)}, 0.12)
        local eName = ListeningEmote
        if eName then
            local kc = KEYBINDS[eName]
            ListeningKeyBtn.Text = kc and ("[" .. keyCodeName(kc) .. "]") or "none"
            ListeningKeyBtn.TextColor3 = kc
                and Color3.fromRGB(220,220,220)
                or  Color3.fromRGB(70,70,70)
        end
    end
    ListeningEmote  = nil
    ListeningKeyBtn = nil
end
local function buildKeybindPanel()
    for _, row in pairs(KeybindRows) do
        if row.Frame and row.Frame.Parent then row.Frame:Destroy() end
    end
    KeybindRows = {}
    for idx, emote in ipairs(EMOTES) do
        local rowY = 42 + (idx-1) * KB_ROW_H
        local rowFrame = Instance.new("Frame")
        rowFrame.Size              = UDim2.new(1,0, 0, KB_ROW_H)
        rowFrame.Position          = UDim2.new(0,0, 0, rowY)
        rowFrame.BackgroundColor3  = idx % 2 == 0
            and Color3.fromRGB(14,14,14)
            or  Color3.fromRGB(10,10,10)
        rowFrame.BackgroundTransparency = 0.0
        rowFrame.BorderSizePixel   = 0
        rowFrame.ZIndex            = 51
        rowFrame.Parent            = KBPanel
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size              = UDim2.new(0,140, 1,0)
        nameLbl.Position          = UDim2.new(0,16, 0,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font              = Enum.Font.GothamSemibold
        nameLbl.TextSize          = 10
        nameLbl.TextColor3        = Color3.fromRGB(190,190,190)
        nameLbl.Text              = emote.Name
        nameLbl.TextXAlignment    = Enum.TextXAlignment.Left
        nameLbl.TextTruncate      = Enum.TextTruncate.AtEnd
        nameLbl.ZIndex            = 52
        nameLbl.Parent            = rowFrame
        local kc = KEYBINDS[emote.Name]
        local keyBtn = Instance.new("TextButton")
        keyBtn.Size              = UDim2.new(0,100, 0, KB_ROW_H - 8)
        keyBtn.Position          = UDim2.new(0,158, 0,4)
        keyBtn.BackgroundColor3  = Color3.fromRGB(16,16,16)
        keyBtn.BorderSizePixel   = 0
        keyBtn.Font              = Enum.Font.GothamBold
        keyBtn.TextSize          = 9
        keyBtn.TextColor3        = kc and Color3.fromRGB(220,220,220) or Color3.fromRGB(70,70,70)
        keyBtn.Text              = kc and ("[" .. keyCodeName(kc) .. "]") or "none"
        keyBtn.ZIndex            = 52
        keyBtn.Parent            = rowFrame
        local keyStroke = Instance.new("UIStroke")
        keyStroke.Color       = Color3.fromRGB(180,180,180)
        keyStroke.Thickness   = 1
        keyStroke.Transparency= 0.55
        keyStroke.Parent      = keyBtn
        local clearBtn = Instance.new("TextButton")
        clearBtn.Size            = UDim2.new(0,32, 0, KB_ROW_H - 8)
        clearBtn.Position        = UDim2.new(1,-44, 0,4)
        clearBtn.BackgroundColor3= Color3.fromRGB(16,16,16)
        clearBtn.BorderSizePixel = 0
        clearBtn.Font            = Enum.Font.GothamBold
        clearBtn.TextSize        = 8
        clearBtn.TextColor3      = Color3.fromRGB(140,60,60)
        clearBtn.Text            = "X"
        clearBtn.ZIndex          = 52
        clearBtn.Parent          = rowFrame
        local clrStroke = Instance.new("UIStroke")
        clrStroke.Color       = Color3.fromRGB(160,60,60)
        clrStroke.Thickness   = 1
        clrStroke.Transparency= 0.5
        clrStroke.Parent      = clearBtn
        local emoteName = emote.Name
        keyBtn.MouseButton1Click:Connect(function()
            if ListeningEmote == emoteName then
                cancelListening()
                return
            end
            cancelListening()
            ListeningEmote  = emoteName
            ListeningKeyBtn = keyBtn
            Tween(keyBtn, {BackgroundColor3 = Color3.fromRGB(30,28,10)}, 0.12)
            keyBtn.TextColor3 = Color3.fromRGB(240,210,60)
            keyBtn.Text = "Press key..."
        end)
        keyBtn.MouseEnter:Connect(function()
            if ListeningEmote ~= emoteName then
                Tween(keyBtn, {BackgroundColor3 = Color3.fromRGB(26,26,26)}, 0.10)
            end
        end)
        keyBtn.MouseLeave:Connect(function()
            if ListeningEmote ~= emoteName then
                Tween(keyBtn, {BackgroundColor3 = Color3.fromRGB(16,16,16)}, 0.10)
            end
        end)
        clearBtn.MouseButton1Click:Connect(function()
            if ListeningEmote == emoteName then cancelListening() end
            KEYBINDS[emoteName] = nil
            keyBtn.Text       = "none"
            keyBtn.TextColor3 = Color3.fromRGB(70,70,70)
            Tween(keyBtn, {BackgroundColor3 = Color3.fromRGB(16,16,16)}, 0.12)
        end)
        clearBtn.MouseEnter:Connect(function()
            Tween(clearBtn, {TextColor3 = Color3.fromRGB(255,80,80)}, 0.10)
        end)
        clearBtn.MouseLeave:Connect(function()
            Tween(clearBtn, {TextColor3 = Color3.fromRGB(140,60,60)}, 0.10)
        end)
        KeybindRows[emoteName] = {
            Frame    = rowFrame,
            KeyBtn   = keyBtn,
            ClearBtn = clearBtn,
        }
    end
end
local function openKeybindPanel()
    KeybindPanelOpen = true
    buildKeybindPanel()
    KBPanel.Visible = true
    KBPanel.BackgroundTransparency = 1
    Tween(KBPanel, {BackgroundTransparency = 0.06}, 0.18, Enum.EasingStyle.Quad)
    Tween(KeysBtn, {
        TextColor3       = Color3.fromRGB(255,255,255),
        BackgroundColor3 = Color3.fromRGB(28,28,28),
    }, 0.15)
end
local function closeKeybindPanel()
    cancelListening()
    KeybindPanelOpen = false
    Tween(KBPanel, {BackgroundTransparency = 1}, 0.15, Enum.EasingStyle.Quad)
    task.delay(0.16, function() KBPanel.Visible = false end)
    Tween(KeysBtn, {
        TextColor3       = Color3.fromRGB(200,200,200),
        BackgroundColor3 = Color3.fromRGB(18,18,18),
    }, 0.15)
end
KeysBtn.MouseButton1Click:Connect(function()
    if KeybindPanelOpen then closeKeybindPanel() else openKeybindPanel() end
end)
KBClose.MouseButton1Click:Connect(function()
    closeKeybindPanel()
end)
KBClose.MouseEnter:Connect(function()
    Tween(KBClose, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.10)
end)
KBClose.MouseLeave:Connect(function()
    Tween(KBClose, {TextColor3 = Color3.fromRGB(200,200,200)}, 0.10)
end)
local function updateArrowVisibility()
    local show = TotalPages > 1
    LeftLbl.TextTransparency  = show and 0 or 1
    RightLbl.TextTransparency = show and 0 or 1
end
local PageTransitioning = false
local function loadPage(page, skipRig, direction)
    if PageTransitioning and not skipRig then return end
    CurrentPage  = page
    HoveredSlice = nil
    local pageEmotes = getPageEmotes(page)
    if WheelIsOpen and not skipRig and direction then
        PageTransitioning = true
        local offsetX = direction == "right" and -80 or 80
        Tween(WheelContainer, {Position = UDim2.new(0.5, -DISPLAY/2 + offsetX, 0.5, -DISPLAY/2)}, 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.13, function()
            buildSlices(pageEmotes)
            redrawWheel(nil, pageEmotes)
            WheelContainer.Position = UDim2.new(0.5, -DISPLAY/2 - offsetX, 0.5, -DISPLAY/2)
            Tween(WheelContainer, {Position = UDim2.new(0.5, -DISPLAY/2, 0.5, -DISPLAY/2)}, 0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            if WheelIsOpen then
                for _, fn in ipairs(RigReplayFuncs) do fn() end
            end
            task.delay(0.22, function() PageTransitioning = false end)
        end)
    else
        buildSlices(pageEmotes)
        redrawWheel(nil, pageEmotes)
        if WheelIsOpen and not skipRig then
            for _, fn in ipairs(RigReplayFuncs) do fn() end
        end
    end
    PageLabel.Text = page .. " / " .. TotalPages
    HubLabel.Text = "SELECT"
    HubDots.Text  = "O  O"
    Tween(HubLabel,  {TextColor3 = Color3.fromRGB(180,180,180)}, 0.1)
    Tween(HubDots,   {TextColor3 = Color3.fromRGB(240,240,240)}, 0.1)
    Tween(HubStroke, {Transparency = 0.3, Color = Color3.fromRGB(200,200,200)}, 0.1)
end
LeftBtn.MouseButton1Click:Connect(function()
    if TotalPages <= 1 then return end
    local newPage = CurrentPage - 1
    if newPage < 1 then newPage = TotalPages end
    loadPage(newPage, false, "left")
end)
RightBtn.MouseButton1Click:Connect(function()
    if TotalPages <= 1 then return end
    local newPage = CurrentPage + 1
    if newPage > TotalPages then newPage = 1 end
    loadPage(newPage, false, "right")
end)
local function getSliceAtMouse()
    local pageEmotes = getPageEmotes(CurrentPage)
    local num        = #pageEmotes
    local sliceDeg   = 360 / num
    local mp  = UserInputService:GetMouseLocation()
    local abs = CanvasFrame.AbsolutePosition
    local sz  = CanvasFrame.AbsoluteSize
    local cx  = abs.X + sz.X / 2
    local cy  = abs.Y + sz.Y / 2
    local dx  = mp.X - cx
    local dy  = mp.Y - cy
    local dist    = math.sqrt(dx*dx + dy*dy)
    local pxS     = sz.X / DISPLAY
    local outerPx = OUTER_R * SCALE * pxS
    local innerPx = INNER_R * SCALE * pxS
    if dist < innerPx or dist > outerPx * 1.15 then return nil end
    local angle = math.deg(math.atan2(dy, dx)) + 90
    if angle < 0 then angle = angle + 360 end
    return math.floor(angle / sliceDeg) % num + 1
end
RunService.Heartbeat:Connect(function()
    if not WheelContainer.Visible then return end
    local idx = getSliceAtMouse()
    if idx == HoveredSlice then return end
    HoveredSlice = idx
    local pageEmotes = getPageEmotes(CurrentPage)
    redrawWheel(idx, pageEmotes)
    if idx and SliceData[idx] then
        local emote = pageEmotes[idx]
        HubLabel.Text = emote and emote.Short or "SELECT"
        HubDots.Text  = "O  O"
        Tween(HubLabel,  {TextColor3 = Color3.fromRGB(255,255,255)}, 0.12)
        Tween(HubDots,   {TextColor3 = Color3.fromRGB(255,255,255)}, 0.12)
        Tween(HubStroke, {Transparency = 0, Color = Color3.fromRGB(255,255,255)}, 0.12)
    else
        HubLabel.Text = "SELECT"
        HubDots.Text  = "O  O"
        Tween(HubLabel,  {TextColor3 = Color3.fromRGB(160,160,160)}, 0.12)
        Tween(HubDots,   {TextColor3 = Color3.fromRGB(220,220,220)}, 0.12)
        Tween(HubStroke, {Transparency = 0.3, Color = Color3.fromRGB(200,200,200)}, 0.12)
    end
    for i, sd in ipairs(SliceData) do
        if i == idx then
            Tween(sd.Label,      {TextColor3  = Color3.fromRGB(15,15,15)}, 0.10)
            Tween(sd.GlowStroke, {Transparency = 0},                        0.10)
        else
            Tween(sd.Label,      {TextColor3  = Color3.fromRGB(200,200,200)}, 0.10)
            Tween(sd.GlowStroke, {Transparency = 1},                           0.10)
        end
    end
end)
HitArea.MouseButton1Click:Connect(function()
    if IsEmoting then return end
    local idx = getSliceAtMouse()
    if idx and SliceData[idx] then
        local emote = SliceData[idx].Emote
        CloseWheel()
        ExecEmote(emote)
    end
end)
local function OpenWheel()
    if WheelIsOpen then return end
    if IsEmoting then return end
    WheelIsOpen  = true
    HoveredSlice = nil
    Overlay.Visible = true
    Overlay.BackgroundTransparency = 1
    Tween(Overlay, {BackgroundTransparency = 0.55}, 0.2, Enum.EasingStyle.Quad)
    WheelContainer.Visible  = true
    WheelContainer.Size     = UDim2.new(0, DISPLAY*0.6, 0, DISPLAY*0.6)
    WheelContainer.Position = UDim2.new(0.5,-DISPLAY*0.3, 0.5,-DISPLAY*0.3)
    Tween(WheelContainer, {
        Size     = UDim2.new(0,DISPLAY, 0,DISPLAY),
        Position = UDim2.new(0.5,-DISPLAY/2, 0.5,-DISPLAY/2),
    }, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local pageEmotes = getPageEmotes(CurrentPage)
    redrawWheel(nil, pageEmotes)
    for _, fn in ipairs(RigReplayFuncs) do fn() end
    TopBtn.Text = "CLOSE  x"
    Tween(TopBtn,    {TextColor3  = Color3.fromRGB(255,120,120)}, 0.18)
    Tween(TopStroke, {Color = Color3.fromRGB(255,100,100), Transparency = 0.2}, 0.18)
end
function CloseWheel()
    if not WheelIsOpen then return end
    WheelIsOpen    = false
    HoveredSlice   = nil
    Tween(Overlay, {BackgroundTransparency = 1}, 0.18, Enum.EasingStyle.Quad)
    Tween(WheelContainer, {
        Size     = UDim2.new(0, DISPLAY*0.6, 0, DISPLAY*0.6),
        Position = UDim2.new(0.5,-DISPLAY*0.3, 0.5,-DISPLAY*0.3),
    }, 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    task.delay(0.2, function()
        WheelContainer.Visible = false
        Overlay.Visible        = false
        WheelContainer.Size     = UDim2.new(0,DISPLAY, 0,DISPLAY)
        WheelContainer.Position = UDim2.new(0.5,-DISPLAY/2, 0.5,-DISPLAY/2)
    end)
    TopBtn.Text = "EMOTES  [Q]"
    Tween(TopBtn,    {TextColor3  = Color3.fromRGB(220,220,220)}, 0.18)
    Tween(TopStroke, {Color = Color3.fromRGB(200,200,200), Transparency = 0.4}, 0.18)
end
local SKIP_KEYS = {
    [Enum.KeyCode.LeftShift]   = true, [Enum.KeyCode.RightShift]  = true,
    [Enum.KeyCode.LeftControl] = true, [Enum.KeyCode.RightControl]= true,
    [Enum.KeyCode.LeftAlt]     = true, [Enum.KeyCode.RightAlt]    = true,
    [Enum.KeyCode.LeftMeta]    = true, [Enum.KeyCode.RightMeta]   = true,
    [Enum.KeyCode.CapsLock]    = true,
}
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        if ListeningEmote then cancelListening() end
        return
    end
    if ListeningEmote then
        if SKIP_KEYS[input.KeyCode] then return end
        local emoteName = ListeningEmote
        local btn       = ListeningKeyBtn
        for name, kc in pairs(KEYBINDS) do
            if kc == input.KeyCode and name ~= emoteName then
                KEYBINDS[name] = nil
                local row = KeybindRows[name]
                if row and row.KeyBtn then
                    row.KeyBtn.Text       = "none"
                    row.KeyBtn.TextColor3 = Color3.fromRGB(70,70,70)
                    Tween(row.KeyBtn, {BackgroundColor3 = Color3.fromRGB(16,16,16)}, 0.12)
                end
            end
        end
        KEYBINDS[emoteName] = input.KeyCode
        cancelListening()
        if btn and btn.Parent then
            btn.Text       = "[" .. keyCodeName(input.KeyCode) .. "]"
            btn.TextColor3 = Color3.fromRGB(220,220,220)
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(20,20,30)}, 0.12)
        end
        return
    end
    if gpe then return end
    if input.KeyCode == OPEN_KEY then
        if not IsEmoting then OpenWheel() end
        return
    end
    if not WheelIsOpen then
        for emoteName, kc in pairs(KEYBINDS) do
            if input.KeyCode == kc then
                for _, emote in ipairs(EMOTES) do
                    if emote.Name == emoteName then
                        ExecEmote(emote)
                        break
                    end
                end
                break
            end
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode ~= OPEN_KEY then return end
    if not WheelIsOpen then return end
    local idx = HoveredSlice
    CloseWheel()
    if idx and SliceData[idx] and not IsEmoting then
        task.delay(0.05, function() ExecEmote(SliceData[idx].Emote) end)
    end
end)
TopBtn.MouseButton1Click:Connect(function()
    if WheelIsOpen then CloseWheel() else OpenWheel() end
end)
TopHolder.MouseEnter:Connect(function()
    Tween(TopHolder, {BackgroundColor3 = Color3.fromRGB(25,25,25)}, 0.12)
end)
TopHolder.MouseLeave:Connect(function()
    Tween(TopHolder, {BackgroundColor3 = Color3.fromRGB(10,10,10)}, 0.12)
end)
MusicBtn.MouseButton1Click:Connect(function()
    NoMusicEnabled = not NoMusicEnabled
    if NoMusicEnabled then
        MusicBtn.Text = "~ OFF"
        Tween(MusicBtn, {
            TextColor3       = Color3.fromRGB(255,100,100),
            BackgroundColor3 = Color3.fromRGB(40,14,14),
        }, 0.15)
    else
        MusicBtn.Text = "~ ON"
        Tween(MusicBtn, {
            TextColor3       = Color3.fromRGB(130,220,130),
            BackgroundColor3 = Color3.fromRGB(18,40,20),
        }, 0.15)
    end
end)
task.spawn(function()
    while true do
        Tween(HubStroke, {Transparency=0.55}, 1.4, Enum.EasingStyle.Sine)
        task.wait(1.4)
        Tween(HubStroke, {Transparency=0.1}, 1.4, Enum.EasingStyle.Sine)
        task.wait(1.4)
    end
end)
local function DoEmoteReset()
    if not IsEmoting then return end
    if ActiveToken and ActiveToken.directAnimation then
        CancelActiveEmote()
        return
    end
    local savedCF = EmoteOrigin
    CancelActiveEmote()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
    local conn
    conn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        conn:Disconnect()
        if savedCF then
            task.delay(0.6, function()
                local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
                if hrp then hrp.CFrame = savedCF end
            end)
        end
        task.delay(0.8, function()
            loadPage(CurrentPage, true)
        end)
    end)
end
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space and IsEmoting then
        DoEmoteReset()
    end
end)
UserInputService.JumpRequest:Connect(function()
    if IsEmoting then
        DoEmoteReset()
    end
end)
local NotifHolder = Instance.new("Frame")
NotifHolder.Name              = "EmoteNotif"
NotifHolder.Size              = UDim2.new(0,200, 0,52)
NotifHolder.Position          = UDim2.new(1,10, 0,14)
NotifHolder.BackgroundColor3  = Color3.fromRGB(8,8,8)
NotifHolder.BackgroundTransparency = 0.15
NotifHolder.BorderSizePixel   = 0
NotifHolder.ZIndex            = 35
NotifHolder.ClipsDescendants  = false
NotifHolder.Parent            = ScreenGui

local NotifIcon = Instance.new("TextLabel")
NotifIcon.Size     = UDim2.new(0,28, 1,0)
NotifIcon.Position = UDim2.new(0,8, 0,0)
NotifIcon.BackgroundTransparency = 1
NotifIcon.Font     = Enum.Font.GothamBold
NotifIcon.TextSize = 18
NotifIcon.TextColor3 = Color3.fromRGB(255,220,80)
NotifIcon.Text     = "▶"
NotifIcon.TextXAlignment = Enum.TextXAlignment.Center
NotifIcon.ZIndex   = 36
NotifIcon.Parent   = NotifHolder
local NotifTitle = Instance.new("TextLabel")
NotifTitle.Size     = UDim2.new(1,-46, 0,20)
NotifTitle.Position = UDim2.new(0,38, 0,6)
NotifTitle.BackgroundTransparency = 1
NotifTitle.Font     = Enum.Font.GothamBold
NotifTitle.TextSize = 11
NotifTitle.TextColor3 = Color3.fromRGB(255,255,255)
NotifTitle.Text     = "Emote Playing"
NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
NotifTitle.TextTruncate = Enum.TextTruncate.AtEnd
NotifTitle.ZIndex   = 36
NotifTitle.Parent   = NotifHolder
local NotifSub = Instance.new("TextLabel")
NotifSub.Size     = UDim2.new(1,-46, 0,16)
NotifSub.Position = UDim2.new(0,38, 0,28)
NotifSub.BackgroundTransparency = 1
NotifSub.Font     = Enum.Font.Gotham
NotifSub.TextSize = 9
NotifSub.TextColor3 = Color3.fromRGB(255,255,255)
NotifSub.Text     = "♪ Music ON"
NotifSub.TextXAlignment = Enum.TextXAlignment.Left
NotifSub.ZIndex   = 36
NotifSub.Parent   = NotifHolder
local NotifBar = Instance.new("Frame")
NotifBar.Size             = UDim2.new(1,-16, 0,2)
NotifBar.Position         = UDim2.new(0,8, 1,-6)
NotifBar.BackgroundColor3 = Color3.fromRGB(255,220,80)
NotifBar.BackgroundTransparency = 0.2
NotifBar.BorderSizePixel  = 0
NotifBar.ZIndex           = 37
NotifBar.Parent           = NotifHolder
Instance.new("UICorner", NotifBar).CornerRadius = UDim.new(1,0)
local NotifTask = nil
local NOTIF_SHOW_X = UDim2.new(1,-218, 0,14)
local NOTIF_HIDE_X = UDim2.new(1,10, 0,14)
ShowNotification = function(emoteName, musicOn)
    if NotifTask then
        task.cancel(NotifTask)
        NotifTask = nil
    end
    NotifTitle.Text = emoteName or "Emote"
    NotifSub.Text   = musicOn and "♪ Music ON" or "♪ Music OFF"
    NotifIcon.TextColor3 = musicOn and Color3.fromRGB(255,220,80) or Color3.fromRGB(160,160,160)
    NotifHolder.Position = NOTIF_HIDE_X
    Tween(NotifHolder, {Position = NOTIF_SHOW_X}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    NotifBar.Size = UDim2.new(1,-16, 0,2)
    Tween(NotifBar, {Size = UDim2.new(0,0, 0,2)}, 3, Enum.EasingStyle.Linear)
    NotifTask = task.delay(3, function()
        Tween(NotifHolder, {Position = NOTIF_HIDE_X}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        NotifTask = nil
    end)
end
updateArrowVisibility()
loadPage(1, true)
