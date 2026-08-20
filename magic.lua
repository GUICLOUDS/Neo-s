local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local activePush = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayermoveGUI"
ScreenGui.ResetOnSpawn = true

local success, err = pcall(function()
	ScreenGui.Parent = CoreGui
end)
if not success then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

LocalPlayer.CharacterAdded:Connect(function()
	if activePush then
		activePush.finished = true
		if activePush.physicsConnection then
			activePush.physicsConnection:Disconnect()
			activePush.physicsConnection = nil
		end
		if activePush.clone and activePush.clone.Parent then
			activePush.clone:Destroy()
		end
		activePush = nil
		local camera = Workspace.CurrentCamera
		if camera then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		end
	end
	ScreenGui:Destroy()
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 440)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(130, 12, 12)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(14, 4, 4)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 6)
TopCorner.Parent = TopBar

local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(0, 3, 0, 20)
AccentBar.Position = UDim2.new(0, 12, 0.5, -10)
AccentBar.BackgroundColor3 = Color3.fromRGB(210, 20, 20)
AccentBar.BorderSizePixel = 0
AccentBar.Parent = TopBar

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(0, 2)
AccentCorner.Parent = AccentBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 22, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Player flinger? idk"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -34, 0.5, -13)
CloseButton.BackgroundColor3 = Color3.fromRGB(22, 5, 5)
CloseButton.Text = "x"
CloseButton.TextColor3 = Color3.fromRGB(200, 40, 40)
CloseButton.TextSize = 12
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(100, 12, 12)
CloseStroke.Thickness = 1
CloseStroke.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
	CloseButton.BackgroundColor3 = Color3.fromRGB(160, 15, 15)
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
end)
CloseButton.MouseLeave:Connect(function()
	CloseButton.BackgroundColor3 = Color3.fromRGB(22, 5, 5)
	CloseButton.TextColor3 = Color3.fromRGB(200, 40, 40)
end)

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, 0, 0, 1)
Separator.Position = UDim2.new(0, 0, 0, 40)
Separator.BackgroundColor3 = Color3.fromRGB(70, 8, 8)
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -24, 0, 15)
TargetLabel.Position = UDim2.new(0, 12, 0, 48)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "SELECT TARGET"
TargetLabel.TextColor3 = Color3.fromRGB(170, 22, 22)
TargetLabel.TextSize = 10
TargetLabel.Font = Enum.Font.GothamBold
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = MainFrame

local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(1, -24, 0, 30)
SearchBar.Position = UDim2.new(0, 12, 0, 65)
SearchBar.BackgroundColor3 = Color3.fromRGB(16, 4, 4)
SearchBar.BorderSizePixel = 0
SearchBar.PlaceholderText = "Search player..."
SearchBar.PlaceholderColor3 = Color3.fromRGB(90, 30, 30)
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBar.TextSize = 12
SearchBar.Font = Enum.Font.Gotham
SearchBar.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 4)
SearchCorner.Parent = SearchBar

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = Color3.fromRGB(90, 10, 10)
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchBar

local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -24, 0, 110)
PlayerScroll.Position = UDim2.new(0, 12, 0, 105)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.BorderSizePixel = 0
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(160, 15, 15)
PlayerScroll.ClipsDescendants = true
PlayerScroll.Parent = MainFrame

local ScrollListLayout = Instance.new("UIListLayout")
ScrollListLayout.Padding = UDim.new(0, 4)
ScrollListLayout.Parent = PlayerScroll

local VelocityLabel = Instance.new("TextLabel")
VelocityLabel.Size = UDim2.new(1, -24, 0, 15)
VelocityLabel.Position = UDim2.new(0, 12, 0, 225)
VelocityLabel.BackgroundTransparency = 1
VelocityLabel.Text = "VELOCITY POWER"
VelocityLabel.TextColor3 = Color3.fromRGB(170, 22, 22)
VelocityLabel.TextSize = 10
VelocityLabel.Font = Enum.Font.GothamBold
VelocityLabel.TextXAlignment = Enum.TextXAlignment.Left
VelocityLabel.Parent = MainFrame

local function createButton(text, pos, size)
	local btn = Instance.new("TextButton")
	btn.Size = size
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(16, 4, 4)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(210, 210, 210)
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamBold
	btn.Parent = MainFrame
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = btn
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 12, 12)
	stroke.Thickness = 1
	stroke.Parent = btn
	return btn
end

local MinusBtn = createButton("-", UDim2.new(0, 12, 0, 242), UDim2.new(0, 30, 0, 30))
local PlusBtn = createButton("+", UDim2.new(1, -42, 0, 242), UDim2.new(0, 30, 0, 30))

local VelocityInput = Instance.new("TextBox")
VelocityInput.Size = UDim2.new(1, -94, 0, 30)
VelocityInput.Position = UDim2.new(0, 47, 0, 242)
VelocityInput.BackgroundColor3 = Color3.fromRGB(16, 4, 4)
VelocityInput.BorderSizePixel = 0
VelocityInput.Text = "150"
VelocityInput.TextColor3 = Color3.fromRGB(255, 255, 255)
VelocityInput.TextSize = 13
VelocityInput.Font = Enum.Font.GothamBold
VelocityInput.Parent = MainFrame

local VelocityCorner = Instance.new("UICorner")
VelocityCorner.CornerRadius = UDim.new(0, 4)
VelocityCorner.Parent = VelocityInput

local VelocityStroke = Instance.new("UIStroke")
VelocityStroke.Color = Color3.fromRGB(90, 10, 10)
VelocityStroke.Thickness = 1
VelocityStroke.Parent = VelocityInput

VelocityInput:GetPropertyChangedSignal("Text"):Connect(function()
	local filtered = VelocityInput.Text:gsub("%D", "")
	if filtered ~= VelocityInput.Text then
		VelocityInput.Text = filtered
	end
end)

local function adjustVelocity(amount)
	local current = tonumber(VelocityInput.Text) or 0
	local new = math.clamp(current + amount, 0, 5000)
	VelocityInput.Text = tostring(new)
end

MinusBtn.MouseButton1Click:Connect(function() adjustVelocity(-50) end)
PlusBtn.MouseButton1Click:Connect(function() adjustVelocity(50) end)

local DirHeader = Instance.new("TextLabel")
DirHeader.Size = UDim2.new(1, -24, 0, 15)
DirHeader.Position = UDim2.new(0, 12, 0, 282)
DirHeader.BackgroundTransparency = 1
DirHeader.Text = "PUSH DIRECTION"
DirHeader.TextColor3 = Color3.fromRGB(170, 22, 22)
DirHeader.TextSize = 10
DirHeader.Font = Enum.Font.GothamBold
DirHeader.TextXAlignment = Enum.TextXAlignment.Left
DirHeader.Parent = MainFrame

local ButtonGrid = Instance.new("Frame")
ButtonGrid.Size = UDim2.new(1, -24, 0, 140)
ButtonGrid.Position = UDim2.new(0, 12, 0, 302)
ButtonGrid.BackgroundTransparency = 1
ButtonGrid.Parent = MainFrame

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellSize = UDim2.new(0.33, -4, 0.33, -4)
UIGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
UIGridLayout.Parent = ButtonGrid

local directions = {"Front", "Up", "Back", "Left", "Down", "Right"}
local dirButtons = {}

for _, dir in ipairs(directions) do
	local btn = Instance.new("TextButton")
	btn.Name = dir .. "Button"
	btn.Text = dir
	btn.BackgroundColor3 = Color3.fromRGB(16, 4, 4)
	btn.TextColor3 = Color3.fromRGB(210, 210, 210)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.Parent = ButtonGrid

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = btn

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(100, 12, 12)
	btnStroke.Thickness = 1
	btnStroke.Parent = btn

	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(70, 8, 8)
		btnStroke.Color = Color3.fromRGB(190, 20, 20)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(16, 4, 4)
		btnStroke.Color = Color3.fromRGB(100, 12, 12)
		btn.TextColor3 = Color3.fromRGB(210, 210, 210)
	end)
	
	dirButtons[dir] = btn
end

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	if activePush then
		activePush.finished = true
		if activePush.physicsConnection then
			activePush.physicsConnection:Disconnect()
			activePush.physicsConnection = nil
		end
		if activePush.clone and activePush.clone.Parent then
			activePush.clone:Destroy()
		end
		if activePush.root and activePush.root.Parent then
			activePush.root.AssemblyLinearVelocity = Vector3.zero
			activePush.root.AssemblyAngularVelocity = Vector3.zero
			pcall(function() sethiddenproperty(activePush.root, "PhysicsRepRootPart", activePush.root) end)
			activePush.root.CFrame = activePush.originalCFrame
		end
		activePush = nil
	end
	ScreenGui:Destroy()
end)

local targetPlayer = nil
local selectedButtonFrame = nil
local selectedButtonStroke = nil

local function updatePlayerList()
	for _, child in ipairs(PlayerScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local searchText = string.lower(SearchBar.Text)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local displayName = player.DisplayName
			local username = player.Name

			if searchText == "" or string.find(string.lower(displayName), searchText) or string.find(string.lower(username), searchText) then
				local isSelected = targetPlayer == player

				local pFrame = Instance.new("Frame")
				pFrame.Size = UDim2.new(1, -6, 0, 42)
				pFrame.BackgroundColor3 = isSelected and Color3.fromRGB(90, 10, 10) or Color3.fromRGB(16, 4, 4)
				pFrame.BorderSizePixel = 0
				pFrame.Parent = PlayerScroll

				local pCorner = Instance.new("UICorner")
				pCorner.CornerRadius = UDim.new(0, 4)
				pCorner.Parent = pFrame

				local pStroke = Instance.new("UIStroke")
				pStroke.Color = isSelected and Color3.fromRGB(190, 20, 20) or Color3.fromRGB(65, 8, 8)
				pStroke.Thickness = 1
				pStroke.Parent = pFrame

				local pImage = Instance.new("ImageLabel")
				pImage.Size = UDim2.new(0, 30, 0, 30)
				pImage.Position = UDim2.new(0, 6, 0.5, -15)
				pImage.BackgroundColor3 = Color3.fromRGB(22, 5, 5)
				pImage.Parent = pFrame

				local imgCorner = Instance.new("UICorner")
				imgCorner.CornerRadius = UDim.new(1, 0)
				imgCorner.Parent = pImage

				local imgStroke = Instance.new("UIStroke")
				imgStroke.Color = Color3.fromRGB(100, 12, 12)
				imgStroke.Thickness = 1
				imgStroke.Parent = pImage

				task.spawn(function()
					local userId = player.UserId
					local thumbType = Enum.ThumbnailType.HeadShot
					local thumbSize = Enum.ThumbnailSize.Size48x48
					local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
					if isReady then pImage.Image = content end
				end)

				local dLabel = Instance.new("TextLabel")
				dLabel.Size = UDim2.new(1, -44, 0, 18)
				dLabel.Position = UDim2.new(0, 42, 0, 4)
				dLabel.BackgroundTransparency = 1
				dLabel.Text = displayName
				dLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
				dLabel.TextSize = 12
				dLabel.Font = Enum.Font.GothamBold
				dLabel.TextXAlignment = Enum.TextXAlignment.Left
				dLabel.Parent = pFrame

				local uLabel = Instance.new("TextLabel")
				uLabel.Size = UDim2.new(1, -44, 0, 14)
				uLabel.Position = UDim2.new(0, 42, 0, 22)
				uLabel.BackgroundTransparency = 1
				uLabel.Text = "@" .. username
				uLabel.TextColor3 = Color3.fromRGB(110, 35, 35)
				uLabel.TextSize = 10
				uLabel.Font = Enum.Font.Gotham
				uLabel.TextXAlignment = Enum.TextXAlignment.Left
				uLabel.Parent = pFrame

				local selectBtn = Instance.new("TextButton")
				selectBtn.Size = UDim2.new(1, 0, 1, 0)
				selectBtn.BackgroundTransparency = 1
				selectBtn.Text = ""
				selectBtn.Parent = pFrame

				selectBtn.MouseButton1Click:Connect(function()
					if targetPlayer == player then
						targetPlayer = nil
						pFrame.BackgroundColor3 = Color3.fromRGB(16, 4, 4)
						pStroke.Color = Color3.fromRGB(65, 8, 8)
					else
						if selectedButtonFrame then
							selectedButtonFrame.BackgroundColor3 = Color3.fromRGB(16, 4, 4)
							if selectedButtonStroke then
								selectedButtonStroke.Color = Color3.fromRGB(65, 8, 8)
							end
						end
						targetPlayer = player
						selectedButtonFrame = pFrame
						selectedButtonStroke = pStroke
						pFrame.BackgroundColor3 = Color3.fromRGB(90, 10, 10)
						pStroke.Color = Color3.fromRGB(190, 20, 20)
					end
				end)
			end
		end
	end
	PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, ScrollListLayout.AbsoluteContentSize.Y)
end

SearchBar:GetPropertyChangedSignal("Text"):Connect(updatePlayerList)
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(plr)
	if targetPlayer == plr then targetPlayer = nil end
	updatePlayerList()
end)
updatePlayerList()

local function getDirectionVector(dirName, targetHrp, originCFrame)
	if dirName == "Front" then return targetHrp.CFrame.LookVector
	elseif dirName == "Back" then return -targetHrp.CFrame.LookVector
	elseif dirName == "Left" then return -targetHrp.CFrame.RightVector
	elseif dirName == "Right" then return targetHrp.CFrame.RightVector
	elseif dirName == "Up" then return Vector3.new(0, 1, 0)
	elseif dirName == "Down" then return Vector3.new(0, -1, 0)
	end
	return Vector3.new(0, 0, 0)
end

local function setArchivableRecursive(instance)
	local original = {}
	for _, obj in ipairs(instance:GetDescendants()) do
		original[obj] = obj.Archivable
		obj.Archivable = true
	end
	return original
end

local function restoreArchivable(original)
	for obj, value in pairs(original) do
		if obj and obj.Parent then
			obj.Archivable = value
		end
	end
end

local function createTransparentClone(character, cloneCFrame)
	local oldCharacterArchivable = character.Archivable
	local originalArchivable = setArchivableRecursive(character)
	character.Archivable = true

	local clone
	local ok = pcall(function()
		clone = character:Clone()
	end)

	restoreArchivable(originalArchivable)
	character.Archivable = oldCharacterArchivable

	if not ok or not clone then
		return nil
	end

	clone.Name = LocalPlayer.Name .. "_TeleportClone"
	clone.Parent = Workspace

	pcall(function()
		clone:PivotTo(cloneCFrame)
	end)

	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
			obj:Destroy()
		elseif obj:IsA("BasePart") then
			obj.Anchored = true
			obj.CanCollide = false
			obj.CanTouch = false
			obj.CanQuery = false
			obj.Massless = true
			obj.CastShadow = false
			obj.Transparency = math.max(obj.Transparency, 0.55)
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = math.max(obj.Transparency, 0.55)
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
			obj.Enabled = false
		elseif obj:IsA("Humanoid") then
			obj.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			obj.BreakJointsOnDeath = false
			obj.AutoRotate = false
		end
	end

	return clone
end

local function stopRootMomentum(root)
	if not root or not root.Parent then return end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.Anchored = true
	pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", root) end)
end

local function cleanupActivePush()
	local state = activePush
	if not state then return end
	activePush = nil
	state.finished = true
	if state.physicsConnection then state.physicsConnection:Disconnect(); state.physicsConnection=nil end
	local root = state.root
	if root and root.Parent then
		stopRootMomentum(root)
		root.CFrame = state.originalCFrame
		RunService.Heartbeat:Wait()
		if root and root.Parent then
			root.CFrame = state.originalCFrame
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", root) end)
			RunService.Heartbeat:Wait()
			root.CFrame = state.originalCFrame
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			root.Anchored = false
			task.defer(function() if root and root.Parent then root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero end end)
		end
	end
	if state.clone and state.clone.Parent then state.clone:Destroy() end
	local camera=Workspace.CurrentCamera
	if camera then camera.CameraType=state.originalCameraType; camera.CameraSubject=state.originalCameraSubject; camera.CFrame=state.originalCameraCFrame end
end

local function executePush(dirName)
	cleanupActivePush()

	if not targetPlayer or not targetPlayer.Character then
		return
	end

	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local targetChar = targetPlayer.Character
	local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	local camera = Workspace.CurrentCamera

	if not myRoot or not targetHrp or not camera then
		return
	end

	local state = {
		root = myRoot,
		originalCFrame = myRoot.CFrame,
		originalCameraCFrame = camera.CFrame,
		originalCameraType = camera.CameraType,
		originalCameraSubject = camera.CameraSubject,
		clone = nil,
		physicsConnection = nil,
		finished = false
	}

	activePush = state

	state.clone = createTransparentClone(myChar, state.originalCFrame)

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = state.originalCameraCFrame

	local power = tonumber(VelocityInput.Text) or 0
	local direction = getDirectionVector(dirName, targetHrp, state.originalCFrame)
	local pushVector = direction * power
	local contactOffset = -direction * 1.2
	local startTime = os.clock()

	local function finish()
		if activePush ~= state or state.finished then return end
		state.finished = true
		if state.physicsConnection then state.physicsConnection:Disconnect(); state.physicsConnection=nil end
		activePush=nil
		if myRoot and myRoot.Parent then
			stopRootMomentum(myRoot)
			myRoot.CFrame=state.originalCFrame
			RunService.Heartbeat:Wait()
			if myRoot and myRoot.Parent then
				myRoot.CFrame=state.originalCFrame
				myRoot.AssemblyLinearVelocity=Vector3.zero
				myRoot.AssemblyAngularVelocity=Vector3.zero
				pcall(function() sethiddenproperty(myRoot, "PhysicsRepRootPart", myRoot) end)
				RunService.Heartbeat:Wait()
				myRoot.CFrame=state.originalCFrame
				myRoot.AssemblyLinearVelocity=Vector3.zero
				myRoot.AssemblyAngularVelocity=Vector3.zero
				myRoot.Anchored=false
				task.defer(function() if myRoot and myRoot.Parent then myRoot.AssemblyLinearVelocity=Vector3.zero; myRoot.AssemblyAngularVelocity=Vector3.zero end end)
			end
		end
		if state.clone and state.clone.Parent then state.clone:Destroy(); state.clone=nil end
		local currentCamera=Workspace.CurrentCamera
		if currentCamera then currentCamera.CameraType=state.originalCameraType; currentCamera.CameraSubject=state.originalCameraSubject; currentCamera.CFrame=state.originalCameraCFrame end
	end

	state.physicsConnection = RunService.Heartbeat:Connect(function()
		if activePush ~= state or state.finished then
			return
		end

		if os.clock() - startTime >= 0.15 then
			finish()
			return
		end

		if not myRoot.Parent or not targetHrp.Parent then
			finish()
			return
		end

		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = state.originalCameraCFrame

		pcall(function()
			sethiddenproperty(myRoot, "PhysicsRepRootPart", targetHrp)
		end)

		myRoot.CFrame = targetHrp.CFrame * CFrame.new(contactOffset)
		myRoot.AssemblyLinearVelocity = pushVector
		myRoot.AssemblyAngularVelocity = Vector3.new(0, power * 3.5, 0)
	end)
end

for dir, btn in pairs(dirButtons) do
	btn.MouseButton1Click:Connect(function()
		executePush(dir)
	end)
end
