

local TweenService = game:GetService("TweenService")

local LetterboxModule = {}
LetterboxModule.__index = LetterboxModule

export type boxingProperties = {
	Intensity: number?,
	Lifetime: number?
}

export type rotateProperties = {
	Angle: number?, 
	Lifetime: number?
}

export type rotateOverride = {
	[string]: rotateProperties
}

export type boxOverride = {
	[string]: boxingProperties
}

export type boxTweenOverride = {
	[string]: TweenInfo
}

local Defaults: boxingProperties = {
	Intensity = 0.2,
	Lifetime = 0,
}

local RotateDefaults: rotateProperties = {
	Angle = 5,
	Lifetime = 0
}

local DefaultTweenTime = 1.75

local boxingTweenDefault = TweenInfo.new(DefaultTweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local rotateTweenDefault = TweenInfo.new(DefaultTweenTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

-- Shared tween config for bars
local BAR_TWEEN_DATA = { Enum.EasingStyle.Circular, Enum.EasingDirection.In }
-- Shared tween config for rotation
local ROTATE_TWEEN_DATA = { Enum.EasingStyle.Sine, Enum.EasingDirection.InOut }

local Names = {
	"Top",
	"Bottom"
}

local letterboxData = {
	Top = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, -1)
	},
	Bottom = {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 2)
	}
}

export type LetterObject = typeof(LetterboxModule.New())

--------------------
--HELPER FUNCTIONS
--------------------

local function HandleDeadTween(letterObject: LetterObject, tween: Tween)
	local foundTweenIndex = table.find(letterObject.ActiveTweens, tween)

	if foundTweenIndex then
		table.remove(letterObject.ActiveTweens, foundTweenIndex)
	end

	if tween then 
		tween:Destroy()
	end
end

local function HandleTweenDemolishment(letterObject: LetterObject, tween: Tween)
	
	tween.Completed:Once(function()
		HandleDeadTween(letterObject, tween)
	end)

	tween.Destroying:Once(function()
		HandleDeadTween(letterObject, tween)
	end)
end

local function PlayTableOfTweens(Tweens: {Tween})

	for key, tween in pairs(Tweens) do

		tween:Play()

	end

end


function LetterboxModule.New(player: Player, DisplayOrder: number?)
	local self = setmetatable({}, LetterboxModule)
	
	local plrGui: PlayerGui = player:WaitForChild("PlayerGui")
	
	local letterboxFolder: Folder = plrGui:FindFirstChild("LetterboxGuis")
	
	if not letterboxFolder then
		letterboxFolder = Instance.new("Folder")
		letterboxFolder.Name = "LetterboxGuis"
		letterboxFolder.Parent = plrGui
	end
	
	local newLetterboxGui = Instance.new("ScreenGui")
	newLetterboxGui.Name = `LetterboxGui_{#letterboxFolder:GetChildren() + 1}`
	newLetterboxGui.IgnoreGuiInset = true
	newLetterboxGui.ClipToDeviceSafeArea = false
	newLetterboxGui.Parent = letterboxFolder
	newLetterboxGui.DisplayOrder = DisplayOrder ~= nil and DisplayOrder or -1
	
	
	self.LetterboxGui = newLetterboxGui
	self.Player = player
	self.UI = {}
	self.CenterFrames = {}
	self.LetterboxFrames = {}
	self.ActiveTweens = {}
	
	self:_CreateUI()
	
	return self
end


--------------------
--METHODS
--------------------

function LetterboxModule:Start(
	PropertyDefault: boxingProperties?, 
	FrameOverride: boxOverride?, 
	TweenDefault: TweenInfo?, 
	TweenOverride: boxTweenOverride?
)

	
	local function constructTween(tweenData: TweenInfo, Name: string)
		
		local tData = tweenData or TweenDefault or boxingTweenDefault
		
		local LetterboxFrames = self.LetterboxFrames
		local foundFrame: Frame = self:_GetLetterboxFrameFromName(Name)
		
		local boxPropData = letterboxData[Name]
		local intensity = (FrameOverride and FrameOverride[Name] and FrameOverride[Name].Intensity) 
			or (PropertyDefault and PropertyDefault.Intensity)
			or Defaults.Intensity
		intensity += 1			
		
		local newTween = TweenService:Create(foundFrame, tData, {
			Size = UDim2.fromScale(2, intensity)
		})
		
		table.insert(self.ActiveTweens, newTween)
		
		HandleTweenDemolishment(self, newTween)
		
		return newTween
		
	end
	
	local newTweens = {}
	
	for index, Name in ipairs(Names) do
		
		local foundTweenData = TweenOverride and TweenOverride[Name]
		
		local newTween = constructTween(foundTweenData, Name)
		
		newTweens[Name] = newTween
		
		local foundFrame: Frame = self:_GetLetterboxFrameFromName(Name)
		
		local OverrideProperties: boxingProperties = FrameOverride and FrameOverride[Name] or PropertyDefault
		local Lifetime = OverrideProperties.Lifetime
		
		if Lifetime then
			task.delay(Lifetime, function()
				
				self:Stop()
				
			end)
		end
		
	end
	
	PlayTableOfTweens(newTweens)
	
end

function LetterboxModule:Stop(
	StopOverride: {string}?, 
	TweenDefault: TweenInfo?, 
	TweenOverride: boxTweenOverride?
)
	
	local letterboxes = {}
	local letterboxNames: {string} = {}
	
	for index, name in ipairs(Names) do
		
		if StopOverride and table.find(StopOverride, name) then continue end
		
		local foundLetterbox: Frame = self:_GetLetterboxFrameFromName(name)
		
		letterboxes[name] = foundLetterbox
		
		table.insert(letterboxNames, name)
		
	end
	
	local function constructTween(tweenData: TweenInfo, Name: string)
		
		local tData = tweenData or TweenDefault or boxingTweenDefault
		
		local LetterboxFrames = self.LetterboxFrames
		local foundFrame: Frame = self:_GetLetterboxFrameFromName(Name)
		
		local newTween = TweenService:Create(foundFrame, tData, {
			Size = UDim2.fromScale(2, 1)
		})
		
		HandleTweenDemolishment(self, newTween)
		
		table.insert(self.ActiveTweens, newTween)
		
		return newTween
		
	end
	
	local newTweens = {}
	
	for index, Name in ipairs(letterboxNames) do
		
		local foundTweenData = TweenOverride and TweenOverride[Name]
		
		local newTween = constructTween(foundTweenData, Name)

		newTweens[Name] = newTween
		
		
	end
	
	PlayTableOfTweens(newTweens)
	 
end

function LetterboxModule:Rotate(
	StopOverride: {string}?,
	RotateDefault: rotateProperties?, 
	RotateOverride: rotateOverride?,
	RotTweenDefault: TweenInfo,
	RotateTweenOverride: boxTweenOverride
)
	
	local NamesToRotate: {string} = {}
	
	for index, Name in ipairs(Names) do
		
		if StopOverride and table.find(StopOverride, Name) then continue end
		
		table.insert(NamesToRotate, Name)
		
	end
	
	local function constuctTween(tweenData: TweenInfo, Name: string)
		
		local tData = tweenData or RotTweenDefault or rotateTweenDefault
		
		local foundFrame: Frame = self:_GetLetterboxFrameFromName(Name)
		local centerFrame = foundFrame.Parent
		
		local rotateProperties: rotateProperties = RotateOverride and RotateOverride[Name] or RotateDefault or RotateDefaults
		local rot = rotateProperties.Angle
		local Lifetime = rotateProperties.Lifetime
		
		local rotTween = TweenService:Create(centerFrame, tData, {
			Rotation = rot
		})
		
		local backTween = TweenService:Create(centerFrame, tData, {
			Rotation = 0
		})
		
		HandleTweenDemolishment(self, rotTween)
		
		if Lifetime and Lifetime > 0 then
			
			HandleTweenDemolishment(self, backTween)
			
			task.delay(Lifetime, function()
				backTween:Play()
			end)
		end
		
		return rotTween
		
	end
	
	local myTweens = {}
	
	for index, Name in ipairs(NamesToRotate) do
		
		local tweenData = RotateTweenOverride and RotateTweenOverride[Name]
		
		local newTween = constuctTween(tweenData, Name)
		
		myTweens[Name] = newTween
		
	end
	
	PlayTableOfTweens(myTweens)
	
end

function LetterboxModule:Destroy(smoothDestruction: boolean?)
	
	if smoothDestruction == nil then
		smoothDestruction = false
	end
	
	for index, tween in ipairs(self.ActiveTweens :: {Tween}) do
		tween:Destroy()
		tween = nil
	end
	
	if smoothDestruction then
		self:Stop()
		self:Rotate(nil, {
			Angle = 0
		})
		
		task.delay(DefaultTweenTime + 0.5, function()
			self.LetterboxGui:Destroy()
			self = nil
		end)
	else
		
		self.LetterboxGui:Destroy()
		self = nil
		
	end
	
	
end

-----------------------
--SEMI-PRIVATE METHODS
-----------------------

function LetterboxModule:_CreateUI()
	
	local PlayerGui: PlayerGui = self.Player:WaitForChild("PlayerGui")
	
	local LetterboxUI: ScreenGui = self.LetterboxGui
	
	if not LetterboxUI then
		LetterboxUI = Instance.new("ScreenGui")
		LetterboxUI.Name = "LetterboxGui"
		LetterboxUI.IgnoreGuiInset = true
		LetterboxUI.ClipToDeviceSafeArea = false
		LetterboxUI.Parent = PlayerGui
	end
	
	
	local function handleNewCentral(name: string)
		local NewCentralFrame = Instance.new("Frame")
		NewCentralFrame.Name = `Central_{name}`
		NewCentralFrame.Size = UDim2.fromScale(1, 1)
		NewCentralFrame.BackgroundTransparency = 1
		NewCentralFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		NewCentralFrame.Position = UDim2.fromScale(0.5, 0.5)
		NewCentralFrame.Parent = LetterboxUI

		table.insert(self.CenterFrames, NewCentralFrame)
	end
	
	local function handleNewLetterbox(name: string)
		
		local centralFrame: Frame = LetterboxUI:FindFirstChild(`Central_{name}`)
		
		local newLetterbox = Instance.new("Frame")
		newLetterbox.Name = name
		newLetterbox.Size = UDim2.fromScale(2, 1)
		newLetterbox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		newLetterbox.Parent = centralFrame
		
		local foundBoxData = letterboxData[name]
		
		for propKey, value in pairs(foundBoxData) do
			
			newLetterbox[propKey] = value
			
		end
		
		table.insert(self.LetterboxFrames, newLetterbox)
		
	end
	
	for index, name in ipairs(Names) do
		handleNewCentral(name)
		handleNewLetterbox(name)
	end
	
end

function LetterboxModule:_GetUI()
	return self.CenterFrames, self.LetterboxFrames
end

function LetterboxModule:_GetLetterboxFrameFromName(Name: string)
	
	local letterboxFrames: {Frame} = self.LetterboxFrames
	local foundLetterbox
	
	for index, letterbox in ipairs(letterboxFrames) do
		
		if letterbox.Name ~= Name then continue end
		
		foundLetterbox = letterbox
		
	end
	
	return foundLetterbox
	
end

return LetterboxModule
