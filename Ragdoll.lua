export type RagdollDatas = {
	LimbsCollision: boolean;
	Duration: number;
}

local RagdollHandler = {}

local Players = game:GetService('Players')
local Debris = game:GetService('Debris')

local RagdollBlacklists = {
	States = {
		Enum.HumanoidStateType.Ragdoll;
		Enum.HumanoidStateType.FallingDown;
	};

	CollisionLimbs = {
		'HumanoidRootPart';
		'Torso';
		'UpperTorso';
		'LowerTorso';
	}
}

local CurrentRecoverThread = nil

function RagdollHandler.Ragdoll(Character: Model, Datas: RagdollDatas)
	assert(typeof(Character) == 'Instance' and Character:IsA('Model') and Character:FindFirstChild('Humanoid'), 'Character is not a valid character. Please check again!')

	Datas = Datas or {}

	local Humanoid = Character:WaitForChild('Humanoid')
	local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')

	if Humanoid:GetState().Name == 'Dead' then
		return
	end

	local Default_Datas: RagdollDatas = {
		LimbsCollision = true;
		Duration = 1;
	}	

	local function FillTableInfo(Template: {any}, GivenTable: {any})
		for Name, Value in Template do
			GivenTable[Name] = GivenTable[Name] or Value

			local DataType = typeof(GivenTable[Name])
			local DefaultDataType = typeof(Value)

			assert(DataType == DefaultDataType, `{Name} expected to be {DefaultDataType} but got {DataType} instead!`)

			if DataType == 'table' then
				FillTableInfo(Value, GivenTable[Name])
			end
		end
	end

	for Name, Value in Default_Datas do
		Datas[Name] = Datas[Name] or Value

		local DataType = typeof(Datas[Name])
		local DefaultDataType = typeof(Value)

		assert(DataType == DefaultDataType, `{Name} expected to be {DefaultDataType} but got {DataType} instead!`)

		if DataType == 'table' then
			FillTableInfo(Value, Datas[Name])
		end
	end

	for _, State in RagdollBlacklists.States do
		Humanoid:SetStateEnabled(State, false)
	end

	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	Humanoid.AutoRotate = false
	Humanoid.PlatformStand = true

	for _, Obj in Character:GetDescendants() do
		if Obj:IsA('Motor6D') then
			local RagdollSocket = Instance.new("BallSocketConstraint")
			local RagdollAttachment0 = Instance.new("Attachment")
			local RagdollAttachment1 = Instance.new("Attachment")

			RagdollAttachment0.Parent = Obj.Part0
			RagdollAttachment1.Parent = Obj.Part1
			RagdollSocket.Parent = Obj.Parent

			RagdollSocket:SetAttribute('RagdollAsset', true)
			RagdollAttachment0:SetAttribute('RagdollAsset', true)
			RagdollAttachment1:SetAttribute('RagdollAsset', true)

			RagdollSocket.Attachment0 = RagdollAttachment0
			RagdollSocket.Attachment1 = RagdollAttachment1

			RagdollAttachment0.CFrame = Obj.C0
			RagdollAttachment1.CFrame = Obj.C1

			RagdollSocket.LimitsEnabled = true
			RagdollSocket.TwistLimitsEnabled = true

			Obj.Enabled = false
		end
	end

	for _, Obj in Character:GetChildren() do
		if Datas.LimbsCollision and Obj:IsA('BasePart') and not table.find(RagdollBlacklists.CollisionLimbs, Obj.Name) then
			local LimbCopy = Obj:Clone()
			LimbCopy.Parent = Obj
			LimbCopy.Size = Vector3.new(Obj.Size.X / 2, Obj.Size.Y / 2, Obj.Size.Z / 2)
			LimbCopy.CFrame = Obj.CFrame
			LimbCopy.CanCollide = true
			LimbCopy.Anchored = false
			LimbCopy.Transparency = 1

			LimbCopy:SetAttribute('RagdollAsset', true)

			local LimbWeld = Instance.new('WeldConstraint')
			LimbWeld.Parent = LimbCopy
			LimbWeld.Part0 = LimbCopy
			LimbWeld.Part1 = Obj

			LimbWeld:SetAttribute('RagdollAsset', true)
		end
	end

	if Datas.Duration then
		if CurrentRecoverThread then
			task.cancel(CurrentRecoverThread)
			CurrentRecoverThread = nil
		end

		CurrentRecoverThread = task.delay(Datas.Duration, function()
			for _, Obj in Character:GetDescendants() do
				if Obj:GetAttribute('RagdollAsset') ~= nil then
					Obj:Destroy()
				end
			end

			for _, Obj in Character:GetDescendants() do
				if Obj:IsA('Motor6D') and not Obj.Enabled then
					Obj.Enabled = true
				end
			end

			Humanoid:ChangeState(Enum.HumanoidStateType.Running)

			Humanoid.AutoRotate = true
			Humanoid.PlatformStand = false

			for _, State in RagdollBlacklists.States do
				Humanoid:SetStateEnabled(State, true)
			end
		end)
	else
		for _, Obj in Character:GetDescendants() do
			if Obj:GetAttribute('RagdollAsset') ~= nil then
				Obj:Destroy()
			end
		end

		for _, Obj in Character:GetDescendants() do
			if Obj:IsA('Motor6D') and not Obj.Enabled then
				Obj.Enabled = true
			end
		end

		Humanoid:ChangeState(Enum.HumanoidStateType.Running)

		Humanoid.AutoRotate = true
		Humanoid.PlatformStand = false

		for _, State in RagdollBlacklists.States do
			Humanoid:SetStateEnabled(State, true)
		end
	end
end

return RagdollHandler
