local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")
-- Shared Character Management
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Animator = Humanoid:WaitForChild("Animator")
-- 1. VR CFRAME & VISUAL AVATAR SETUP
local defaultMaxZoom = player.CameraMaxZoomDistance
local defaultMinZoom = player.CameraMinZoomDistance
local defaultFOV = Camera.FieldOfView
local defaultOffset = Humanoid.CameraOffset
local defaultAutoRotate = Humanoid.AutoRotate
local hrp0 = RootPart
local hrp1 = hrp0:Clone()
Character.Parent = nil
hrp0.Parent = hrp1
if hrp0:FindFirstChild("RootJoint") then
hrp0.RootJoint.Part0 = nil
end
hrp1.Parent = Character
Character.Parent = workspace
hrp0.Transparency = 1
player.CameraMaxZoomDistance = 0.5
player.CameraMinZoomDistance = 0.5
Camera.FieldOfView = 100
Humanoid.CameraOffset = Vector3.new(0, 0, -2)
Humanoid.AutoRotate = false
for _, child in pairs(Character:GetChildren()) do
if child:IsA("BasePart") then
child:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
child.LocalTransparencyModifier = 1
end)
child.LocalTransparencyModifier = 1
child.Transparency = 1
end
end
local Proxy
local camAnchor
local vrConnections = {}
local function DisconnectVR()
for _, connection in ipairs(vrConnections) do
connection:Disconnect()
end
table.clear(vrConnections)
end
local function CleanupVR()
DisconnectVR()
player.CameraMaxZoomDistance = defaultMaxZoom
player.CameraMinZoomDistance = defaultMinZoom
Camera.FieldOfView = defaultFOV
if Humanoid and Humanoid.Parent then
Humanoid.CameraOffset = defaultOffset
Humanoid.AutoRotate = defaultAutoRotate
Camera.CameraSubject = Humanoid
end
Camera.CameraType = Enum.CameraType.Custom
if camAnchor then
camAnchor:Destroy()
camAnchor = nil
end
if Proxy then
Proxy:Destroy()
Proxy = nil
end
end
local function HideObject(object)
if object:IsA("BasePart") then
object.LocalTransparencyModifier = 1
object.Transparency = 1
elseif object:IsA("Decal") or object:IsA("Texture") then
object.Transparency = 1
elseif object:IsA("ParticleEmitter")
or object:IsA("Trail")
or object:IsA("Beam")
or object:IsA("Smoke")
or object:IsA("Fire")
or object:IsA("Sparkles") then
object.Enabled = false
end
end
local function HideCharacter(char)
for _, object in ipairs(char:GetDescendants()) do
HideObject(object)
end
end
local function MakePart(name, size)
local part = Instance.new("Part")
part.Name = name
part.Size = size
part.Color = Color3.fromRGB(130, 130, 130)
part.Material = Enum.Material.SmoothPlastic
part.Anchored = true
part.CanCollide = false
part.CanTouch = false
part.CanQuery = false
part.Massless = true
part.Parent = Proxy
return part
end
local function IsInvisibleActivator(part)
return part
and part:IsA("BasePart")
and part.Name == "INVISIBLE_ACTIVATE"
and part.Transparency == 1
end
local function IsInsideActivator(part, activator)
if not IsInvisibleActivator(activator) then
return false
end
local relative = activator.CFrame:PointToObjectSpace(part.Position)
local halfSize = activator.Size / 2
local limbHalfSize = part.Size / 2
return math.abs(relative.X) <= halfSize.X + limbHalfSize.X
and math.abs(relative.Y) <= halfSize.Y + limbHalfSize.Y
and math.abs(relative.Z) <= halfSize.Z + limbHalfSize.Z
end
local function UpdateVisibility(part, activator)
if not part then return end
if activator and IsInsideActivator(part, activator) then
part.Transparency = 1
else
part.Transparency = 0
end
end
local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftUpperArm")
local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightUpperArm")
Proxy = Instance.new("Model")
Proxy.Name = "LocalVisualAvatar"
Proxy.Parent = workspace
local ProxyLeftArm = MakePart("LeftArm", LeftArm and LeftArm.Size or Vector3.new(1, 2, 1))
local ProxyRightArm = MakePart("RightArm", RightArm and RightArm.Size or Vector3.new(1, 2, 1))
HideCharacter(Character)
table.insert(vrConnections, Character.DescendantAdded:Connect(function(object)
HideObject(object)
end))
table.insert(vrConnections, Humanoid.Died:Connect(CleanupVR))
table.insert(vrConnections, Character.AncestryChanged:Connect(function(_, parent)
if not parent then CleanupVR() end
end))
local cameraHeight = 2
camAnchor = Instance.new("Part")
camAnchor.Name = "CameraAnchor"
camAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
camAnchor.Transparency = 1
camAnchor.CanCollide = false
camAnchor.Massless = true
camAnchor.CFrame = hrp1.CFrame * CFrame.new(0, cameraHeight, 0)
camAnchor.Parent = Character
local weld = Instance.new("WeldConstraint")
weld.Part0 = hrp1
weld.Part1 = camAnchor
weld.Parent = camAnchor
Camera.CameraSubject = camAnchor
table.insert(vrConnections, Camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
if Camera.CameraSubject and Camera.CameraSubject:IsA("VehicleSeat") then
Camera.CameraSubject = camAnchor
end
end))

-- 1B. PC FIRST-PERSON FREE MOUSE / HOLD RIGHT CLICK TO ROTATE
-- In first person, the mouse stays free until RMB is held.
-- Holding RMB locks the mouse to the center and lets the character rotate with the camera.
local rightClickHeld = false
local wasFirstPerson = false

local function IsFirstPerson()
    if not Camera then return false end
    return (Camera.Focus.Position - Camera.CFrame.Position).Magnitude <= 0.6
end

local function ResetPCMouse()
    rightClickHeld = false
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    if Humanoid and Humanoid.Parent then
        Humanoid.AutoRotate = false
    end
end

table.insert(vrConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightClickHeld = true
    end
end))

table.insert(vrConnections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightClickHeld = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        if Humanoid and Humanoid.Parent and IsFirstPerson() then
            Humanoid.AutoRotate = false
        end
    end
end))

table.insert(vrConnections, UserInputService.WindowFocusReleased:Connect(ResetPCMouse))

table.insert(vrConnections, RunService.RenderStepped:Connect(function()
    if not Humanoid or not Humanoid.Parent then return end

    local inFirstPerson = IsFirstPerson()
    if inFirstPerson then
        if rightClickHeld then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            Humanoid.AutoRotate = true
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            Humanoid.AutoRotate = false
        end
    else
        if wasFirstPerson then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        Humanoid.AutoRotate = false
    end
    wasFirstPerson = inFirstPerson
end))

local stiffness = 35
local damping = 3.5
local maxTilt = 0.2

local pivotOffset = Vector3.new(0, 1.5, 0)
local currentAngleX, currentAngleZ = 0, 0
local velocityX, velocityZ = 0, 0
local deadzoneAngle = math.rad(45)
local currentBodyYaw = 0
local maxVerticalOffset = 0.8
local maxHorizontalOffset = 0.5
local currentYOffset = 0
local currentXOffset = 0
local function NormalizeAngle(angle)
return (angle + math.pi) % (2 * math.pi) - math.pi
end
table.insert(vrConnections, RunService.RenderStepped:Connect(function(dt)
if not Character or not Character.Parent or Humanoid.Health <= 0 then
CleanupVR()
return
end
HideCharacter(Character)
local camCFrame = Camera.CFrame
local camLook = camCFrame.LookVector
local targetCamYaw = math.atan2(-camLook.X, -camLook.Z)
local yawDiff = NormalizeAngle(targetCamYaw - currentBodyYaw)
if yawDiff > deadzoneAngle then
currentBodyYaw = targetCamYaw - deadzoneAngle
elseif yawDiff < -deadzoneAngle then
currentBodyYaw = targetCamYaw + deadzoneAngle
end
currentBodyYaw = NormalizeAngle(currentBodyYaw)
hrp1.CFrame = CFrame.new(hrp1.Position) * CFrame.Angles(0, currentBodyYaw, 0)
local pitchY = camLook.Y
local targetYOffset = pitchY * maxVerticalOffset
local relativeYaw = NormalizeAngle(targetCamYaw - currentBodyYaw)
local yawFraction = math.clamp(relativeYaw / deadzoneAngle, -1, 1)
local targetXOffset = -yawFraction * maxHorizontalOffset
local lerpSpeed = math.clamp(dt * 15, 0, 1)
currentYOffset = currentYOffset + (targetYOffset - currentYOffset) * lerpSpeed
currentXOffset = currentXOffset + (targetXOffset - currentXOffset) * lerpSpeed
local moveVel = hrp1.CFrame:VectorToObjectSpace(hrp1.AssemblyLinearVelocity)
local targetAngleX = math.clamp(moveVel.Z * 0.03 + (moveVel.Y * 0.015), -maxTilt, maxTilt)
local targetAngleZ = math.clamp(-moveVel.X * 0.03, -maxTilt, maxTilt)
local characterLook = hrp1.CFrame.LookVector
local characterRight = hrp1.CFrame.RightVector
local upVector = Vector3.new(0, 1, 0)
local gravityPitch = characterLook:Dot(upVector)
local gravityRoll = characterRight:Dot(upVector)
targetAngleX = math.clamp(targetAngleX - (gravityPitch * 1.5), -maxTilt, maxTilt)
targetAngleZ = math.clamp(targetAngleZ + (gravityRoll * 1.5), -maxTilt, maxTilt)
local forceX = (targetAngleX - currentAngleX) * stiffness
velocityX = (velocityX + forceX * dt) * math.clamp(1 - (damping * dt), 0, 1)
currentAngleX = currentAngleX + velocityX * dt
local forceZ = (targetAngleZ - currentAngleZ) * stiffness
velocityZ = (velocityZ + forceZ * dt) * math.clamp(1 - (damping * dt), 0, 1)
currentAngleZ = currentAngleZ + velocityZ * dt
local offsetVector = Vector3.new(currentXOffset, currentYOffset, 0)
local baseCFrame = hrp1.CFrame * CFrame.new(offsetVector)
local pivotCFrame = baseCFrame * CFrame.new(pivotOffset)
local tiltRotation = CFrame.Angles(currentAngleX, 0, currentAngleZ)
hrp0.CFrame = pivotCFrame * tiltRotation * CFrame.new(-pivotOffset)
hrp0.AssemblyLinearVelocity = hrp1.AssemblyLinearVelocity
if LeftArm and ProxyLeftArm then
local relativeLeft = hrp1.CFrame:ToObjectSpace(LeftArm.CFrame)
ProxyLeftArm.CFrame = hrp0.CFrame * relativeLeft
end
if RightArm and ProxyRightArm then
local relativeRight = hrp1.CFrame:ToObjectSpace(RightArm.CFrame)
ProxyRightArm.CFrame = hrp0.CFrame * relativeRight
end
local Activator = workspace:FindFirstChild("INVISIBLE_ACTIVATE")
if Activator and IsInvisibleActivator(Activator) then
UpdateVisibility(ProxyLeftArm, Activator)
UpdateVisibility(ProxyRightArm, Activator)
else
if ProxyLeftArm then ProxyLeftArm.Transparency = 0 end
if ProxyRightArm then ProxyRightArm.Transparency = 0 end
end
end))
-- 2. PROCEDURAL & DIRECTIONAL ANIMATIONS SETUP
local PriorityLayers = {
Enum.AnimationPriority.Core,
Enum.AnimationPriority.Idle,
Enum.AnimationPriority.Movement,
Enum.AnimationPriority.Action,
Enum.AnimationPriority.Action2,
Enum.AnimationPriority.Action3,
Enum.AnimationPriority.Action4
}
local function SetLayer(track, layerIndex)
layerIndex = math.clamp(layerIndex, 1, #PriorityLayers)
track.Priority = PriorityLayers[layerIndex]
end
local HORIZONTAL_THRESHOLD = 0.35
local UP_THRESHOLD         = 0.35
local DOWN_THRESHOLD       = -0.35
local FULLY_DOWN_THRESHOLD = -0.75
local BASE_FADE     = 0.5
local MIN_FADE_TIME = 0.3
local activeTracks = {}
local function loadTrack(assetId)
if not Animator then return nil end
local anim = Instance.new("Animation")
anim.AnimationId = assetId
local track = Animator:LoadAnimation(anim)
SetLayer(track, 2)
table.insert(activeTracks, track)
return track
end
local baseWalkTrack = loadTrack("rbxassetid://214748382")
local directionalTracks = {
ForwardAnim = loadTrack("rbxassetid://46196309"),
ForwardPose = loadTrack("http://www.roblox.com/asset/?version=1&id=35152447"),
Backward    = loadTrack("http://www.roblox.com/asset/?version=1&id=48957148"),
Side        = loadTrack("http://www.roblox.com/asset/?version=1&id=190075311")
}
local airTracks = {
Fall = loadTrack("http://www.roblox.com/asset/?version=1&id=287325678")
}
local cameraTracks = {
Left      = loadTrack("rbxassetid://93693205"),
Right     = loadTrack("rbxassetid://88016955"),
Up        = loadTrack("rbxassetid://165167557"),
Down      = loadTrack("rbxassetid://68433924"),
FullyDown = loadTrack("rbxassetid://68433924")
}
local renderConnection
local stateConnection
local isAlive = true
local function hardKill()
if not isAlive then return end
isAlive = false
if renderConnection then renderConnection:Disconnect() renderConnection = nil end
if stateConnection then stateConnection:Disconnect() stateConnection = nil end
for _, track in ipairs(activeTracks) do
if track then
track:Stop(0)
track:Destroy()
end
end
table.clear(activeTracks)
if Animator then
for _, track in ipairs(Animator:GetPlayingAnimationTracks()) do
track:Stop(0)
end
end
end
Humanoid.Died:Connect(hardKill)
Character.Destroying:Connect(hardKill)
local fadeTime = 0.2
local isAirborne = false
local lastSideDirection = ""
local currentHorizontal, currentVertical = "Center", "Center"
local lastDot, lastLookY = 0, 0
local function ensurePlaying(track, targetTime)
if not isAlive or not track then return end
if not track.IsPlaying then
track:Play(fadeTime, 0.001)
if targetTime then track.TimePosition = targetTime end
end
end
ensurePlaying(baseWalkTrack, 0)
baseWalkTrack:AdjustWeight(1, 0)
ensurePlaying(directionalTracks.ForwardAnim, 0)
ensurePlaying(directionalTracks.ForwardPose, 0.5)
ensurePlaying(directionalTracks.Backward, 0.4)
ensurePlaying(directionalTracks.Side, 0.6)
ensurePlaying(airTracks.Fall, 0.3)
stateConnection = Humanoid.StateChanged:Connect(function(_, newState)
if not isAlive or Humanoid.Health <= 0 then return end
if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
isAirborne = true
ensurePlaying(airTracks.Fall, 0.3)
airTracks.Fall:AdjustWeight(0.5, fadeTime)
airTracks.Fall:AdjustSpeed(0)
elseif newState == Enum.HumanoidStateType.Landed
or newState == Enum.HumanoidStateType.Running
or newState == Enum.HumanoidStateType.RunningNoPhysics then
if isAirborne then
isAirborne = false
if airTracks.Fall then airTracks.Fall:AdjustWeight(0.001, fadeTime) end
end
end
end)
renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
if not isAlive or Humanoid.Health <= 0 or not Character:IsDescendantOf(workspace) then
hardKill()
return
end
local cameraLook = Camera.CFrame.LookVector
local flatCameraLook = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
local dot = RootPart.CFrame.RightVector:Dot(flatCameraLook)
local turnSpeed = math.abs(dot - lastDot) / deltaTime
lastDot = dot
local newHorizontal = "Center"
if dot > HORIZONTAL_THRESHOLD then
newHorizontal = "Right"
elseif dot < -HORIZONTAL_THRESHOLD then
newHorizontal = "Left"
end
if newHorizontal ~= currentHorizontal then
local hSpeedFactor = math.clamp(turnSpeed / 3, 0, 1)
local fade = math.clamp(BASE_FADE * (1 - hSpeedFactor * 0.4), MIN_FADE_TIME, BASE_FADE)
if newHorizontal == "Left" then
if cameraTracks.Right.IsPlaying then cameraTracks.Right:Stop(fade) end
cameraTracks.Left:Play(fade)
cameraTracks.Left.TimePosition = 0.3
cameraTracks.Left:AdjustSpeed(0)
elseif newHorizontal == "Right" then
if cameraTracks.Left.IsPlaying then cameraTracks.Left:Stop(fade) end
cameraTracks.Right:Play(fade)
cameraTracks.Right.TimePosition = 0
cameraTracks.Right:AdjustSpeed(1)
else
if cameraTracks.Left.IsPlaying then cameraTracks.Left:Stop(fade) end
if cameraTracks.Right.IsPlaying then cameraTracks.Right:Stop(fade) end
end
currentHorizontal = newHorizontal
end
local lookY = cameraLook.Y
local pitchSpeed = math.abs(lookY - lastLookY) / deltaTime
lastLookY = lookY
local newVertical = "Center"
if lookY >= UP_THRESHOLD then
newVertical = "Up"
elseif lookY <= FULLY_DOWN_THRESHOLD then
newVertical = "FullyDown"
elseif lookY <= DOWN_THRESHOLD then
newVertical = "Down"
end
if newVertical ~= currentVertical then
local vSpeedFactor = math.clamp(pitchSpeed / 3, 0, 1)
local fade = math.clamp(BASE_FADE * (1 - vSpeedFactor * 0.4), MIN_FADE_TIME, BASE_FADE)
if newVertical == "Up" then
if cameraTracks.Down.IsPlaying then cameraTracks.Down:Stop(fade) end
if cameraTracks.FullyDown.IsPlaying then cameraTracks.FullyDown:Stop(fade) end
cameraTracks.Up:Play(fade)
cameraTracks.Up.TimePosition = 0.3
cameraTracks.Up:AdjustSpeed(0)
elseif newVertical == "Down" then
if cameraTracks.Up.IsPlaying then cameraTracks.Up:Stop(fade) end
if cameraTracks.FullyDown.IsPlaying then cameraTracks.FullyDown:Stop(fade) end
cameraTracks.Down:Play(fade)
cameraTracks.Down.TimePosition = 0.75
cameraTracks.Down:AdjustSpeed(0)
elseif newVertical == "FullyDown" then
if cameraTracks.Up.IsPlaying then cameraTracks.Up:Stop(fade) end
if cameraTracks.Down.IsPlaying then cameraTracks.Down:Stop(fade) end
cameraTracks.FullyDown:Play(fade)
cameraTracks.FullyDown.TimePosition = 0.65
cameraTracks.FullyDown:AdjustSpeed(0)
else
if cameraTracks.Up.IsPlaying then cameraTracks.Up:Stop(fade) end
if cameraTracks.Down.IsPlaying then cameraTracks.Down:Stop(fade) end
if cameraTracks.FullyDown.IsPlaying then cameraTracks.FullyDown:Stop(fade) end
end
currentVertical = newVertical
end
local moveDirection = Humanoid.MoveDirection
local magnitude = moveDirection.Magnitude
ensurePlaying(baseWalkTrack)
ensurePlaying(directionalTracks.ForwardAnim)
ensurePlaying(directionalTracks.ForwardPose)
ensurePlaying(directionalTracks.Backward)
ensurePlaying(directionalTracks.Side)
if magnitude > 0.05 then
local localMove = RootPart.CFrame:VectorToObjectSpace(moveDirection)
local forwardWeight  = math.clamp(-localMove.Z, 0, 1)
local backwardWeight = math.clamp(localMove.Z,  0, 1)
local rightWeight    = math.clamp(localMove.X,  0, 1)
local leftWeight     = math.clamp(-localMove.X, 0, 1)
local sideWeight     = math.max(rightWeight, leftWeight)
baseWalkTrack:AdjustWeight(1, fadeTime)
baseWalkTrack:AdjustSpeed(0.8)
directionalTracks.ForwardAnim:AdjustWeight(math.max(forwardWeight, 0.001), fadeTime)
directionalTracks.ForwardPose:AdjustWeight(math.max(forwardWeight, 0.001), fadeTime)
directionalTracks.Backward:AdjustWeight(math.max(backwardWeight, 0.001), fadeTime)
directionalTracks.Side:AdjustWeight(math.max(sideWeight, 0.001), fadeTime)
if rightWeight > leftWeight and lastSideDirection ~= "Right" then
lastSideDirection = "Right"
directionalTracks.Side.TimePosition = 0.6
elseif leftWeight > rightWeight and lastSideDirection ~= "Left" then
lastSideDirection = "Left"
directionalTracks.Side.TimePosition = 1.0
end
directionalTracks.ForwardAnim:AdjustSpeed(0.8)
directionalTracks.ForwardPose:AdjustSpeed(0)
directionalTracks.Backward:AdjustSpeed(0)
directionalTracks.Side:AdjustSpeed(0)
else
lastSideDirection = ""
baseWalkTrack:AdjustSpeed(0)
directionalTracks.ForwardAnim:AdjustSpeed(0)
directionalTracks.ForwardPose:AdjustSpeed(0)
directionalTracks.Backward:AdjustSpeed(0)
directionalTracks.Side:AdjustSpeed(0)
end
end)
-- 3. DUAL BOX CONTROL GUI & ANIMATION CONTROLLER
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DualBoxGui"
screenGui.ResetOnSpawn = true
screenGui.Parent = playerGui
local COLOR_BLUE_ON = Color3.fromRGB(0, 100, 255)
local COLOR_BLUE_OFF = Color3.fromRGB(0, 30, 80)
local COLOR_RED_ON = Color3.fromRGB(255, 0, 0)
local COLOR_RED_OFF = Color3.fromRGB(80, 0, 0)
local COLOR_SUB_RED = Color3.fromRGB(200, 50, 50)
local COLOR_TOP_RED_OFF = Color3.fromRGB(220, 20, 20)
local COLOR_TOP_RED_ON = Color3.fromRGB(70, 0, 0)
local blueFrame = Instance.new("Frame")
blueFrame.Name = "BlueBox"
blueFrame.Size = UDim2.new(0, 30, 0, 30)
blueFrame.Position = UDim2.new(0.5, -45, 0.5, -15)
blueFrame.BackgroundColor3 = COLOR_BLUE_ON
blueFrame.BorderSizePixel = 0
blueFrame.Active = true
blueFrame.Parent = screenGui
local blueStroke = Instance.new("UIStroke")
blueStroke.Color = Color3.fromRGB(255, 0, 0)
blueStroke.Thickness = 2
blueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
blueStroke.Parent = blueFrame
local redFrame = Instance.new("Frame")
redFrame.Name = "RedBox"
redFrame.Size = UDim2.new(0, 30, 0, 30)
redFrame.Position = UDim2.new(0.5, 15, 0.5, -15)
redFrame.BackgroundColor3 = COLOR_RED_ON
redFrame.BorderSizePixel = 0
redFrame.Active = true
redFrame.Parent = screenGui
local redStroke = Instance.new("UIStroke")
redStroke.Color = Color3.fromRGB(0, 100, 255)
redStroke.Thickness = 2
redStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
redStroke.Parent = redFrame
local subRedFrame = Instance.new("Frame")
subRedFrame.Name = "SubRedBox"
subRedFrame.Size = UDim2.new(1, 0, 1, 0)
subRedFrame.Position = UDim2.new(0, 0, -1, -5)
subRedFrame.BackgroundColor3 = COLOR_SUB_RED
subRedFrame.BorderSizePixel = 0
subRedFrame.Active = true
subRedFrame.Parent = redFrame
local subRedStroke = Instance.new("UIStroke")
subRedStroke.Color = Color3.fromRGB(255, 255, 255)
subRedStroke.Thickness = 1.5
subRedStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
subRedStroke.Parent = subRedFrame
local topRedFrame = Instance.new("Frame")
topRedFrame.Name = "TopRedBox"
topRedFrame.Size = UDim2.new(1, 0, 1, 0)
topRedFrame.Position = UDim2.new(0, 0, -1, -5)
topRedFrame.BackgroundColor3 = COLOR_TOP_RED_OFF
topRedFrame.BorderSizePixel = 0
topRedFrame.Active = true
topRedFrame.Parent = subRedFrame
local topRedStroke = Instance.new("UIStroke")
topRedStroke.Color = Color3.fromRGB(255, 255, 255)
topRedStroke.Thickness = 1.5
topRedStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
topRedStroke.Parent = topRedFrame
local loadedTracksBlue = {}
local loadedTracksRed = {}
local blueEnabled = true
local redEnabled = true
local topRedActive = false
local blueAnimConfigs = {
VeryTop = { Id = "rbxassetid://94861246", TimePosition = 1, Speed = 0 },
Up = { Id = "rbxassetid://56146409", TimePosition = 0, Speed = 1 },
Middle = { Id = "rbxassetid://183294396", TimePosition = 0.4, Speed = 0 },
Down = { Id = "rbxassetid://56153856", TimePosition = 0.3, Speed = 0 },
VeryDown = { Id = "rbxassetid://225975820", TimePosition = 0.5, Speed = 0 }
}
local redAnimConfigs = {
FarLeft = { Id = "rbxassetid://299225058", TimePosition = 0, Speed = 1 },
Left = { Id = "rbxassetid://299225058", TimePosition = 0, Speed = 1 },
Center = { Id = "rbxassetid://183294396", TimePosition = 0.4, Speed = 0 },
Right = { Id = "rbxassetid://313735596", TimePosition = 0.3, Speed = 0 },
FarRight = { Id = "rbxassetid://313735596", TimePosition = 0.3, Speed = 0 }
}
local activeEmoteTrack = nil
local isSubRedHolding = false
local stopTask = nil
local function LoadAllAnimations()
loadedTracksBlue = {}
loadedTracksRed = {}
for zoneName, config in pairs(blueAnimConfigs) do
local animObj = Instance.new("Animation")
animObj.AnimationId = config.Id
local track = Animator:LoadAnimation(animObj)
SetLayer(track, 4)
loadedTracksBlue[zoneName] = track
end
for zoneName, config in pairs(redAnimConfigs) do
local animObj = Instance.new("Animation")
animObj.AnimationId = config.Id
local track = Animator:LoadAnimation(animObj)
SetLayer(track, topRedActive and 5 or 4)
loadedTracksRed[zoneName] = track
end
end
LoadAllAnimations()
local function OnCharacterDied()
isSubRedHolding = false
if stopTask then
task.cancel(stopTask)
stopTask = nil
end
if activeEmoteTrack then
activeEmoteTrack:Stop(0)
activeEmoteTrack = nil
end
if screenGui then
screenGui:Destroy()
end
end
Humanoid.Died:Connect(OnCharacterDied)
player.CharacterAdded:Connect(function(newChar)
Character = newChar
Humanoid = Character:WaitForChild("Humanoid")
Animator = Humanoid:WaitForChild("Animator")
Humanoid.Died:Connect(OnCharacterDied)
task.wait(0.1)
LoadAllAnimations()
end)
local currentZoneBlue = ""
local currentZoneRed = ""
local currentTrackBlue = nil
local currentTrackRed = nil
local function PlayBlueAnimation(zoneName, forceRefresh)
if not blueEnabled then
if currentTrackBlue then
currentTrackBlue:Stop(0.2)
currentTrackBlue = nil
end
currentZoneBlue = ""
return
end
if currentZoneBlue == zoneName and not forceRefresh then return end
currentZoneBlue = zoneName
local config = blueAnimConfigs[zoneName]
local newTrack = loadedTracksBlue[zoneName]
if not config or not newTrack then return end
if currentTrackBlue and currentTrackBlue ~= newTrack then
currentTrackBlue:Stop(0.2)
end
newTrack:Play(0.2)
currentTrackBlue = newTrack
if config.Speed == 0 then
newTrack.TimePosition = config.TimePosition
newTrack:AdjustSpeed(0)
task.spawn(function()
task.wait()
if currentTrackBlue == newTrack then
newTrack.TimePosition = config.TimePosition
newTrack:AdjustSpeed(0)
end
end)
else
newTrack:AdjustSpeed(config.Speed)
if config.TimePosition > 0 then
newTrack.TimePosition = config.TimePosition
end
end
end
local function PlayRedAnimation(zoneName, forceRefresh)
if not redEnabled or isSubRedHolding then
if currentTrackRed then
currentTrackRed:Stop(0.2)
currentTrackRed = nil
end
currentZoneRed = ""
return
end
if currentZoneRed == zoneName and not forceRefresh then return end
currentZoneRed = zoneName
local config = redAnimConfigs[zoneName]
local newTrack = loadedTracksRed[zoneName]
if not config or not newTrack then return end
SetLayer(newTrack, topRedActive and 5 or 4)
if currentTrackRed and currentTrackRed ~= newTrack then
currentTrackRed:Stop(0.2)
end
newTrack:Play(0.2)
currentTrackRed = newTrack
if config.Speed == 0 then
newTrack.TimePosition = config.TimePosition
newTrack:AdjustSpeed(0)
task.spawn(function()
task.wait()
if currentTrackRed == newTrack then
newTrack.TimePosition = config.TimePosition
newTrack:AdjustSpeed(0)
end
end)
else
newTrack:AdjustSpeed(config.Speed)
if config.TimePosition > 0 then
newTrack.TimePosition = config.TimePosition
end
end
end
topRedFrame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
topRedActive = not topRedActive
topRedFrame.BackgroundColor3 = topRedActive and COLOR_TOP_RED_ON or COLOR_TOP_RED_OFF
for _, track in pairs(loadedTracksRed) do
SetLayer(track, topRedActive and 5 or 4)
end
end
end)
local function StartSubRedEmote()
local redOnRight = (currentZoneRed == "Right" or currentZoneRed == "FarRight")
local blueAtMiddleOrDown = (currentZoneBlue == "Middle" or currentZoneBlue == "Down" or currentZoneBlue == "VeryDown")
if not (redOnRight and blueAtMiddleOrDown) then return end
isSubRedHolding = true
if currentTrackRed then
currentTrackRed:Stop(0.2)
currentTrackRed = nil
end
if stopTask then
task.cancel(stopTask)
stopTask = nil
end
local animId = "http://www.roblox.com/asset/?version=1&id=181262679"
local fadeTime = 0.35
local timePos = 0.8
local speed = 1
local targetLayer = topRedActive and 6 or 5
local autoStopDelay = 0.9
local function playLoopCycle()
if not isSubRedHolding then return end
local animObj = Instance.new("Animation")
animObj.AnimationId = animId
activeEmoteTrack = Animator:LoadAnimation(animObj)
SetLayer(activeEmoteTrack, targetLayer)
activeEmoteTrack.Looped = true
activeEmoteTrack:Play(fadeTime)
activeEmoteTrack.TimePosition = timePos
activeEmoteTrack:AdjustSpeed(speed)
if autoStopDelay then
stopTask = task.delay(autoStopDelay, function()
if activeEmoteTrack then
activeEmoteTrack:Stop(fadeTime)
activeEmoteTrack = nil
end
if isSubRedHolding then
playLoopCycle()
end
end)
end
end
playLoopCycle()
end
local function StopSubRedEmote()
if not isSubRedHolding then return end
isSubRedHolding = false
if stopTask then
task.cancel(stopTask)
stopTask = nil
end
if activeEmoteTrack then
activeEmoteTrack:Stop(0.35)
activeEmoteTrack = nil
end
currentZoneRed = ""
end
subRedFrame.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
StartSubRedEmote()
end
end)
subRedFrame.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
StopSubRedEmote()
end
end)
local function CheckScreenZones()
if Humanoid.Health <= 0 then return end
if not Camera then return end
local viewportSize = Camera.ViewportSize
if blueEnabled then
local blueCenterY = blueFrame.AbsolutePosition.Y + (blueFrame.AbsoluteSize.Y / 2)
local b1 = viewportSize.Y * 0.38
local b2 = viewportSize.Y * 0.46
local b3 = viewportSize.Y * 0.54
local b4 = viewportSize.Y * 0.62
if blueCenterY < b1 then
PlayBlueAnimation("VeryTop")
elseif blueCenterY < b2 then
PlayBlueAnimation("Up")
elseif blueCenterY < b3 then
PlayBlueAnimation("Middle")
elseif blueCenterY < b4 then
PlayBlueAnimation("Down")
else
PlayBlueAnimation("VeryDown")
end
end
if redEnabled then
local redCenterX = redFrame.AbsolutePosition.X + (redFrame.AbsoluteSize.X / 2)
local r1 = viewportSize.X * 0.38
local r2 = viewportSize.X * 0.46
local r3 = viewportSize.X * 0.54
local r4 = viewportSize.X * 0.62
if redCenterX < r1 then
PlayRedAnimation("FarLeft")
elseif redCenterX < r2 then
PlayRedAnimation("Left")
elseif redCenterX < r3 then
PlayRedAnimation("Center")
elseif redCenterX < r4 then
PlayRedAnimation("Right")
else
PlayRedAnimation("FarRight")
end
end
end
RunService.RenderStepped:Connect(function()
CheckScreenZones()
end)
local function SetupBoxControls(targetFrame, isRedBox)
    -- PC + mobile dragging. A short click toggles; dragging moves the box.
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    local clickStartTime = 0
    local moved = false
    local dragThreshold = 6
    local dragConnection = nil

    local function update(inputPosition)
        if not dragStart or not startPos then return end
        local delta = inputPosition - dragStart
        if delta.Magnitude >= dragThreshold then
            moved = true
        end
        targetFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    local function finishInteraction()
        if not dragging then return end
        local heldFor = tick() - clickStartTime
        dragging = false

        if dragConnection then
            dragConnection:Disconnect()
            dragConnection = nil
        end

        -- Only a real click toggles the box; dragging never toggles it.
        if moved or heldFor >= 0.35 then
            return
        end

        if isRedBox then
            if redEnabled and not blueEnabled then return end
            redEnabled = not redEnabled
            targetFrame.BackgroundColor3 = redEnabled and COLOR_RED_ON or COLOR_RED_OFF
            if not redEnabled then
                PlayRedAnimation("", true)
            else
                currentZoneRed = ""
            end
            currentZoneBlue = ""
        else
            if blueEnabled and not redEnabled then return end
            blueEnabled = not blueEnabled
            targetFrame.BackgroundColor3 = blueEnabled and COLOR_BLUE_ON or COLOR_BLUE_OFF
            if not blueEnabled then
                PlayBlueAnimation("", true)
            else
                currentZoneBlue = ""
            end
            currentZoneRed = ""
        end
    end

    targetFrame.InputBegan:Connect(function(input)
        local mouse = input.UserInputType == Enum.UserInputType.MouseButton1
        local touch = input.UserInputType == Enum.UserInputType.Touch
        if not (mouse or touch) then return end

        dragging = true
        moved = false
        dragInput = input
        dragStart = input.Position
        startPos = targetFrame.Position
        clickStartTime = tick()

        dragConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                finishInteraction()
            end
        end)
    end)

    targetFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input == dragInput
            or input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            update(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            finishInteraction()
        end
    end)
end

SetupBoxControls(blueFrame, false)
SetupBoxControls(redFrame, true)
