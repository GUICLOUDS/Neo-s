local RunService = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local Players = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
local Workspace = cloneref and cloneref(game:GetService("Workspace")) or game:GetService("Workspace")
local UserInputService = cloneref and cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

if getgenv().UnifiedControllerCleanup then
    getgenv().UnifiedControllerCleanup()
end

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("CurrentCamera")

local IDLE_1_ID  = "rbxassetid://86477585495626"
local IDLE_2_ID  = "rbxassetid://86477585495626"
local WALK_ID    = "rbxassetid://73895488650369"
local RUN_ID     = "rbxassetid://113696424699661"
local LOOK_ID    = "rbxassetid://109668276932875"
local PITCH_ID   = "rbxassetid://102118966198436"
local CROUCH_ID  = "http://www.roblox.com/asset/?version=1&id=129443147411141"

local NORMAL_WALK_SPEED = 16
local CROUCH_WALK_SPEED = 8
local MIN_ANIMATION_SPEED = 0.1
local AIRBORNE_MULTIPLIER = 0.4

local ROTATE_THRESHOLD = math.rad(70)
local BACKWARD_ROTATE_AMOUNT = math.rad(60)
local BACKWARD_SMOOTHNESS = 14
local TURN_SMOOTHNESS = 10
local FORWARD_SMOOTHNESS = 10

local FORWARD_ENTER, FORWARD_EXIT = 0.25, 0.05
local BACKWARD_ENTER, BACKWARD_EXIT = -0.25, -0.05

local PriorityLayers = {
    Enum.AnimationPriority.Core,
    Enum.AnimationPriority.Idle,
    Enum.AnimationPriority.Movement,
    Enum.AnimationPriority.Action,
    Enum.AnimationPriority.Action2,
    Enum.AnimationPriority.Action3,
    Enum.AnimationPriority.Action4
}

local function setLayer(track, layer)
    layer = math.clamp(layer, 1, #PriorityLayers)
    track.Priority = PriorityLayers[layer]
end

local function lerpAngle(a, b, t)
    return a + math.atan2(math.sin(b - a), math.cos(b - a)) * t
end

local renderConnection = nil
local diedConnection = nil

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", 10)
local hrp = character:WaitForChild("HumanoidRootPart", 10)

if not humanoid or not hrp then return end

local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

humanoid.AutoRotate = false

local attachment = hrp:FindFirstChild("TiltAttachment") or Instance.new("Attachment")
attachment.Name = "TiltAttachment"
attachment.Parent = hrp

local align = hrp:FindFirstChild("BodyAlignOrientation") or Instance.new("AlignOrientation")
align.Name = "BodyAlignOrientation"
align.Mode = Enum.OrientationAlignmentMode.OneAttachment
align.Attachment0 = attachment
align.MaxTorque = math.huge
align.Responsiveness = 40
align.Parent = hrp

local pitchAnim = Instance.new("Animation")
pitchAnim.AnimationId = PITCH_ID

local idle1Anim = Instance.new("Animation")
idle1Anim.AnimationId = IDLE_1_ID
local idle2Anim = Instance.new("Animation")
idle2Anim.AnimationId = IDLE_2_ID

local walkAnim = Instance.new("Animation")
walkAnim.AnimationId = WALK_ID
local runAnim = Instance.new("Animation")
runAnim.AnimationId = RUN_ID

local lookAnim = Instance.new("Animation")
lookAnim.AnimationId = LOOK_ID

local pitchTrack = animator:LoadAnimation(pitchAnim)
setLayer(pitchTrack, 4)

local idleTrack1 = animator:LoadAnimation(idle1Anim)
local idleTrack2 = animator:LoadAnimation(idle2Anim)
idleTrack1.Priority = Enum.AnimationPriority.Idle
idleTrack2.Priority = Enum.AnimationPriority.Idle

local walkTrack = animator:LoadAnimation(walkAnim)
local runTrack = animator:LoadAnimation(runAnim)
walkTrack.Priority = Enum.AnimationPriority.Movement
runTrack.Priority = Enum.AnimationPriority.Movement
walkTrack.Looped = true
runTrack.Looped = true

local lookTrack = animator:LoadAnimation(lookAnim)
setLayer(lookTrack, 4)

local currentTrack = nil
local animationSpeed = 1
local activeLookDirection = nil
local activePitchDirection = nil
local isBackward, isForward = false, false
local backwardTargetYaw = nil
local currentYaw = math.atan2(-hrp.CFrame.LookVector.X, -hrp.CFrame.LookVector.Z)
local idlePlaying = false
local isCrouching = false
local crouchTrack = nil
local crouchGui = nil
local crouchButton = nil
local inputConnection = nil

local function setCrouch(state)
    if not humanoid or humanoid.Health <= 0 then return end
    if isCrouching == state then return end
    isCrouching = state

    if isCrouching then
        humanoid.WalkSpeed = CROUCH_WALK_SPEED
        if not crouchTrack then
            local crouchAnim = Instance.new("Animation")
            crouchAnim.AnimationId = CROUCH_ID
            crouchTrack = animator:LoadAnimation(crouchAnim)
            crouchTrack.Priority = Enum.AnimationPriority.Movement
            crouchTrack.Looped = true
        end
        crouchTrack:Play(0.1)
        crouchTrack.TimePosition = 0.5
        crouchTrack:AdjustSpeed(0)
        if crouchButton then
            crouchButton.Text = "CROUCH\nON"
        end
    else
        humanoid.WalkSpeed = NORMAL_WALK_SPEED
        if crouchTrack then
            crouchTrack:Stop(0.1)
        end
        if crouchButton then
            crouchButton.Text = "CROUCH"
        end
    end
end

local function createMobileCrouchButton()
    if not UserInputService.TouchEnabled then return end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end

    local touchGui = playerGui:WaitForChild("TouchGui", 5)
    local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
    local jumpButton = touchFrame and touchFrame:FindFirstChild("JumpButton")
    if not touchFrame or not jumpButton or not jumpButton:IsA("GuiButton") then return end

    local old = touchFrame:FindFirstChild("MinecraftCrouchButton")
    if old then old:Destroy() end

    crouchButton = Instance.new("TextButton")
    crouchButton.Name = "MinecraftCrouchButton"
    crouchButton.AnchorPoint = jumpButton.AnchorPoint
    crouchButton.Size = jumpButton.Size
    crouchButton.Position = UDim2.new(
        jumpButton.Position.X.Scale,
        jumpButton.Position.X.Offset - jumpButton.AbsoluteSize.X - 10,
        jumpButton.Position.Y.Scale,
        jumpButton.Position.Y.Offset
    )
    crouchButton.BackgroundTransparency = 0.15
    crouchButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    crouchButton.BorderSizePixel = 0
    crouchButton.TextColor3 = Color3.new(1, 1, 1)
    crouchButton.TextSize = 13
    crouchButton.Font = Enum.Font.GothamBold
    crouchButton.Text = "CROUCH"
    crouchButton.AutoButtonColor = true
    crouchButton.ZIndex = jumpButton.ZIndex + 1
    crouchButton.Parent = touchFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = crouchButton

    crouchButton.Activated:Connect(function()
        setCrouch(not isCrouching)
    end)
end

inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.C then
        setCrouch(not isCrouching)
    end
end)

local function cleanup()
    if renderConnection then 
        renderConnection:Disconnect() 
        renderConnection = nil
    end
    if diedConnection then
        diedConnection:Disconnect()
        diedConnection = nil
    end
    if inputConnection then
        inputConnection:Disconnect()
        inputConnection = nil
    end
    if crouchTrack then
        crouchTrack:Stop(0.05)
        crouchTrack:Destroy()
        crouchTrack = nil
    end
    isCrouching = false
    if crouchButton then
        crouchButton:Destroy()
        crouchButton = nil
    end
    crouchGui = nil
    if align then align:Destroy() end
    if attachment then attachment:Destroy() end
    if humanoid then 
        humanoid.AutoRotate = true 
        humanoid.WalkSpeed = NORMAL_WALK_SPEED
    end
    getgenv().UnifiedControllerCleanup = nil
end

getgenv().UnifiedControllerCleanup = cleanup

diedConnection = humanoid.Died:Connect(function()
    cleanup()
end)

createMobileCrouchButton()

local function playIdle()
    if idlePlaying then return end
    idlePlaying = true
    idleTrack1:Play(0.2)
    if IDLE_1_ID ~= IDLE_2_ID then
        task.spawn(function()
            idleTrack1.Stopped:Wait()
            if idlePlaying then idleTrack2:Play(0.2) end
        end)
    end
end

local function stopIdle()
    if not idlePlaying then return end
    idlePlaying = false
    idleTrack1:Stop(0.2)
    idleTrack2:Stop(0.2)
end

local function playMovementTrack(track)
    if currentTrack == track then return end
    if currentTrack then currentTrack:Stop(0.2) end
    currentTrack = track
    track:Play(0.2)
end

local function stopMovementAnimations()
    if currentTrack then
        currentTrack:Stop(0.2)
        currentTrack = nil
    end
end

local function playSidePose(direction)
    if activeLookDirection == direction then return end
    activeLookDirection = direction
    if not lookTrack.IsPlaying then
        lookTrack:Play(0.3)
        lookTrack:AdjustSpeed(0)
    end
    lookTrack.TimePosition = (direction == "Right") and 0.3 or 1.7
end

local function stopSidePose()
    if not activeLookDirection then return end
    activeLookDirection = nil
    lookTrack:Stop(0.3)
end

local function playPitchPose(direction)
    if activePitchDirection == direction then return end
    activePitchDirection = direction
    if not pitchTrack.IsPlaying then
        pitchTrack:Play(0.5)
        pitchTrack:AdjustSpeed(0)
    end
    pitchTrack.TimePosition = (direction == "Up") and 0.9 or 0.1
end

local function stopPitchPose()
    if not activePitchDirection then return end
    activePitchDirection = nil
    pitchTrack:Stop(0.5)
end

renderConnection = RunService.RenderStepped:Connect(function(dt)
    if not character or not character.Parent or humanoid.Health <= 0 then
        cleanup()
        return
    end

    Camera = Workspace.CurrentCamera or Camera
    
    if Camera then
        local verticalPitch = Camera.CFrame.LookVector.Y
        if verticalPitch > 0.4 then
            playPitchPose("Up")
        elseif verticalPitch < -0.4 then
            playPitchPose("Down")
        else
            stopPitchPose()
        end
    end

    local moveDir = humanoid.MoveDirection
    local isMoving = moveDir.Magnitude > 0.01

    if not isMoving then
        playIdle()
        stopMovementAnimations()
    else
        stopIdle()
        local state = humanoid:GetState()
        local airborne = (state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall)

        if humanoid.WalkSpeed > NORMAL_WALK_SPEED then
            playMovementTrack(runTrack)
            local targetSpeed = humanoid.WalkSpeed / NORMAL_WALK_SPEED
            animationSpeed += (targetSpeed - animationSpeed) * math.clamp(dt * 8, 0, 1)
            runTrack:AdjustSpeed(animationSpeed)
        else
            playMovementTrack(walkTrack)
            local targetSpeed = humanoid.WalkSpeed / NORMAL_WALK_SPEED
            if airborne then targetSpeed *= AIRBORNE_MULTIPLIER end
            targetSpeed = math.max(targetSpeed, MIN_ANIMATION_SPEED)
            animationSpeed += (targetSpeed - animationSpeed) * math.clamp(dt * 8, 0, 1)
            walkTrack:AdjustSpeed(animationSpeed)
        end
    end

    if Camera then
        local camLook = (Camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
        local charRight = hrp.CFrame.RightVector
        local rightDot = charRight:Dot(camLook)

        if rightDot > 0.4 then
            playSidePose("Right")
        elseif rightDot < -0.4 then
            playSidePose("Left")
        else
            stopSidePose()
        end
    end

    if Camera then
        local camDir = Camera.CFrame.LookVector
        local flatCamDir = Vector3.new(camDir.X, 0, camDir.Z)
        flatCamDir = (flatCamDir.Magnitude > 0.001) and flatCamDir.Unit or hrp.CFrame.LookVector

        local flatBodyDir = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z).Unit
        local camYaw = math.atan2(-flatCamDir.X, -flatCamDir.Z)
        local bodyYaw = math.atan2(-flatBodyDir.X, -flatBodyDir.Z)
        local angleDiff = math.atan2(math.sin(camYaw - bodyYaw), math.cos(camYaw - bodyYaw))

        local normalizedMoveDir = isMoving and moveDir.Unit or Vector3.zero
        local forwardDot = flatBodyDir:Dot(normalizedMoveDir)
        local rightDot = hrp.CFrame.RightVector:Dot(normalizedMoveDir)

        if isBackward then
            if forwardDot > BACKWARD_EXIT then isBackward = false end
        else
            if forwardDot < BACKWARD_ENTER then isBackward = true end
        end

        if isForward then
            if forwardDot < FORWARD_EXIT then isForward = false end
        else
            if forwardDot > FORWARD_ENTER then isForward = true end
        end

        if isBackward and isForward then isForward = false end

        local targetYaw = currentYaw
        local lerpSpeed = TURN_SMOOTHNESS

        if isBackward then
            if not backwardTargetYaw then
                local turnDir = rightDot >= 0 and 1 or -1
                backwardTargetYaw = bodyYaw + (turnDir * BACKWARD_ROTATE_AMOUNT)
            end
            targetYaw = backwardTargetYaw
            lerpSpeed = BACKWARD_SMOOTHNESS
        elseif isForward then
            backwardTargetYaw = nil
            targetYaw = camYaw
            lerpSpeed = FORWARD_SMOOTHNESS
        else
            backwardTargetYaw = nil
            if math.abs(angleDiff) > ROTATE_THRESHOLD then
                targetYaw = camYaw
                lerpSpeed = TURN_SMOOTHNESS
            end
        end

        local alpha = math.clamp(dt * lerpSpeed, 0, 1)
        currentYaw = lerpAngle(currentYaw, targetYaw, alpha)
        align.CFrame = CFrame.Angles(0, currentYaw, 0)
    end
end)