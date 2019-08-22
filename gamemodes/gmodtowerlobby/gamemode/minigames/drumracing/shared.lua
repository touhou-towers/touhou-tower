local Vector, Angle = Vector, Angle
local CurTime = CurTime

local IsValid = IsValid

module("minigames.dumbracing")

LocationBattle = 3
WeaponName = "weapon_chainsaw"
SpawnPos = Vector(929.531250, 170.593750, 406.718750)
SpawnThrow = Angle(10,90,0)

function ShouldCollide( a, b )

	if IsValid(a) && IsValid(b) && a:IsPlayer() && b:IsPlayer() then
		if a:Location() == LocationBattle || b.GLocation == LocationBattle then
			if (a.DisableCollision && a.DisableCollision > CurTime()) || (b.DisableCollision && b.DisableCollision > CurTime()) then
				return
			end
		
			return true
		end
	end
	
end