# Ragdoll_Module

Ragdoll module is a free open source module to use. It was written by @Tranquananh2811. If you encounter any problems with it or have any questions or suggestions just let me know on my discord (noob1183_) 😊

## Setting up

You can get the module source from `Ragdoll.lua` and then copy it and make a module in studio and paste it in the module.

## What does this module do

This module will support R15 and R6 ragdoll. It is well optimized and very easy to use and configure.

## Usage of the module

```lua

local Players = game:GetService('Players')

local RagdollMod = require(path.to.module)

Players.PlayerAdded:Connect(function(Player: Player)
  Player.CharacterAdded:Connect(function(Character: Model)
    --[[

    For the "{}" inside the parameter it can be nil or empty because script will auto if it is nil or empty with default value which mention below:

    {
		LimbsCollision = true;
		Duration = 1;
    }

    The information you need to fill out are only these:

    {
    	LimbsCollision: boolean;
    	Duration: number;
    }

    --]]
    task.wait(5)
    RagdollMod.Ragdoll(Character, {})
  end)
end)

```
