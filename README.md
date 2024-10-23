# Sparkly

Sparkly is a fast 3D particle system. It has sacrificed a lot of desired functionality for performance. 

## Getting Started

Creating particles (or 'sparks') is easy, just create a sparkData table and create your spark.

```lua
local sparkData: Sparkly.SparkData = {
	color = Color3.fromRGB(255, 0, 0),
	size = Vector3.new(1, 1, 1),
	lifetime = 2,
	cframe = workspace.Test.CFrame,
	acceleration = rng:NextUnitVector() * Vector3.new(50, 50, 50),
	velocity = Vector3.new(0, 0, 0),
	rotationalVelocity = Vector3.new(5, 5, 5),
	transparency = 1,
}

Sparkly.createSpark(sparkData)
```

## Installation

```toml title="wally.toml"
[dependencies]
Sparkly = "iminversed/sparkly@0.1.0"
```