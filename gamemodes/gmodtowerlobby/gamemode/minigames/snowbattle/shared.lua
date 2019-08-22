local Vector, Angle = Vector, Angle
local CurTime = CurTime

local IsValid = IsValid

local GTowerLocation = GTowerLocation

module("minigames.snowbattle")

MinigameName = "Blizzard Storm"
MinigameLocation = 3
MinigameMessage = "MiniBattleGameStart"
MinigameArg1 = "Snowball Fight"
MinigameArg2 = GTowerLocation:GetName( MinigameLocation )

WeaponName = "weapon_snowball_death"
SpawnPos = Vector(929.531250, 170.593750, 406.718750)
SpawnThrow = Angle(10,90,0)