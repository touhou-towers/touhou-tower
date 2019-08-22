
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.BlastRange	= 220

function ENT:PhysicsCollide( data, phys )
	local ent = data.HitEntity

	if data.Speed > 80 && data.DeltaTime > 0.2 then
		self:EmitSound(self.BlastSound, 80)
	end

	local LastSpeed = data.OurOldVelocity:Length()
	local NewVelocity = phys:GetVelocity():GetNormalized()
	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	phys:SetVelocity( NewVelocity * LastSpeed * 0.9 )
end
