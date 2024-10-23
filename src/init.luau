--[=[
	@within Sparkly
	@interface SparkData

	.color Color3
	.size Vector3
	.lifetime number
	.cframe CFrame
	.acceleration Vector3
	.velocity Vector3
	.rotationalVelocity Vector3
]=]
export type SparkData = {
	color: Color3,
	size: Vector3,
	lifetime: number,
	cframe: CFrame,
	acceleration: Vector3,
	velocity: Vector3,
	rotationalVelocity: Vector3,
	transparency: number,
}

--[=[
	@within Sparkly
	@interface PartialSparkData

	.color Color3?
	.size Vector3?
	.lifetime number?
	.cframe CFrame?
	.acceleration Vector3?
	.velocity Vector3?
	.rotationalVelocity Vector3?
]=]
export type PartialSparkData = {
	color: Color3?,
	size: Vector3?,
	lifetime: number?,
	cframe: CFrame?,
	acceleration: Vector3?,
	velocity: Vector3?,
	rotationalVelocity: Vector3?,
	transparency: number?,
}

local RunService = game:GetService("RunService")

local velocities = {}
local rotationalVelocities = {}
local accelerations = {}
local lifespans = {}

local instances = {}
local cframes = {}

--[=[
    @class Sparkly

    Allows you to make sparkles!
]=]
local Sparkly = {}

--[=[
    @within Sparkly
    @param sparkData SparkData
    @return Id number

    Lets you create a 'spark', which is a 3D particle.

    :::caution
    Ids expire immediately, so if you're going to use it, use it right as you get it.
    :::
]=]
function Sparkly.createSpark(sparkData: SparkData): number
	local cube = Instance.new("Part")
	cube.Anchored = true
	cube.CanCollide = false
	cube.Material = "Neon"
	cube.Color = sparkData.color
	cube.CFrame = sparkData.cframe
	cube.Size = sparkData.size
	cube.Parent = workspace

	table.insert(velocities, sparkData.velocity)
	table.insert(rotationalVelocities, sparkData.rotationalVelocity)
	table.insert(accelerations, sparkData.acceleration)
	table.insert(lifespans, Vector2.new(0, sparkData.lifetime))

	table.insert(instances, cube)
	table.insert(cframes, sparkData.cframe)

	return #velocities
end

function Sparkly.getAmountOfSparks()
	return #velocities
end

--[=[
    @param sparkIndex number
    @param sparkData PartialSparkData

    Sets the spark with the given index's data to sparkData.
]=]
function Sparkly.setSparkData(sparkIndex: number, sparkData: PartialSparkData)
	if velocities[sparkIndex] == nil then
		error(("sparkIndex '%s' does not exist"):format(tostring(sparkIndex)))
	end

	if sparkData.velocity then
		velocities[sparkIndex] = sparkData.velocity
	end
	if sparkData.rotationalVelocity then
		rotationalVelocities[sparkIndex] = sparkData.rotationalVelocity
	end
	if sparkData.acceleration then
		accelerations[sparkIndex] = sparkData.acceleration
	end
	if sparkData.cframe then
		cframes[sparkIndex] = sparkData.cframe
	end
	if sparkData.color then
		instances[sparkIndex].Color = sparkData.color
	end
end

--[=[
	Creates a 3D grid of particles of a specific size.

	@param sparkData SparkData
	@param gridSize Vector3
	@param distance number
]=]
function Sparkly.createSparks3DGrid(sparkData: SparkData, gridSize: Vector3, distance: number): (number, number)
	local originalPosition = sparkData.cframe

	local startIndex = #velocities
	local finishIndex = startIndex + gridSize.X * gridSize.Y * gridSize.Z

	for i = 1, gridSize.X do
		for j = 1, gridSize.Y do
			for k = 1, gridSize.Z do
				sparkData.cframe = originalPosition + Vector3.new(i, j, k) * distance
				Sparkly.createSpark(sparkData)
			end
		end
	end

	return startIndex, finishIndex
end

--[=[
	Creates a 2D grid of particles of a specific size.

	@param sparkData SparkData
	@param gridSize Vector2
	@param distance number
]=]
function Sparkly.createSparks2DGrid(sparkData: SparkData, gridSize: Vector2, distance: number)
	local originalPosition = sparkData.cframe

	for i = 1, gridSize.X do
		for j = 1, gridSize.Y do
			sparkData.cframe = originalPosition + Vector3.new(i, j) * distance
			Sparkly.createSpark(sparkData)
		end
	end
end

RunService.RenderStepped:Connect(function(deltaTime)
	-- SoA Layout
	for i = #instances, 1, -1 do
		local velocity = velocities[i] * deltaTime
		local rotationalVelocity = rotationalVelocities[i] * deltaTime
		local acceleration = accelerations[i]
		local lifespan = lifespans[i]

		velocities[i] += acceleration * deltaTime
		cframes[i] = cframes[i] * CFrame.Angles(rotationalVelocity.X, rotationalVelocity.Y, rotationalVelocity.Z)
			+ velocity
		lifespans[i] += Vector2.new(deltaTime, 0)

		if lifespan.X > lifespan.Y then
			instances[i]:Destroy()

			table.remove(instances, i)
			table.remove(cframes, i)
			table.remove(velocities, i)
			table.remove(accelerations, i)
			table.remove(lifespans, i)

			continue
		end
	end

	workspace:BulkMoveTo(instances, cframes, Enum.BulkMoveMode.FireCFrameChanged)
end)

return Sparkly
