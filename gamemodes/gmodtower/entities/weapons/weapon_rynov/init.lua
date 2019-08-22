
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")


function SWEP:ShootEnt( class )
	if CLIENT then return end

	local ent = ents.Create( class )
	if IsValid(ent) then
		local PlayerPos = self.Owner:GetShootPos()
		local PlayerAng = self.Owner:GetAimVector()
		local SpawnPos = PlayerPos + 42 * self.Owner:GetForward() + 25 * self.Owner:GetRight()
	
		local trace = {}
			trace.start = PlayerPos + PlayerAng * 32
			trace.endpos = PlayerPos + PlayerAng * 8192
			trace.filter = {self.Owner}
		local traceRes = util.TraceLine(trace)
	
		local SpawnAngle = (traceRes.HitPos - SpawnPos):GetNormalized():Angle()
		
		ent:SetPos( SpawnPos )
		ent:SetAngles( SpawnAngle )		
		ent:SetOwner( self.Owner )
		ent:SetPhysicsAttacker( self.Owner )
		ent:Spawn()
		ent:Activate()
	end
end