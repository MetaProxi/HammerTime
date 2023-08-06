--Avoiding some WET Code, this module will contain functions that are used to spawn things in the game.


local SpawnUtil = {}

function SpawnUtil:GetRandomOffset(spawnPart): Vector3
    return Vector3.new(
        math.random(-spawnPart.Size.X / 2, spawnPart.Size.X / 2),
        0,
        math.random(-spawnPart.Size.Z / 2, spawnPart.Size.Z / 2)
    )
end

return SpawnUtil
