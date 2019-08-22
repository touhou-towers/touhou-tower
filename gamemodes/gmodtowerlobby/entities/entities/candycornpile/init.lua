include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()
	self:SetModel( self.Model )

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:DrawShadow(false)
	self:SetTrigger(true)

	self.Value = 5
	self.PickupTime = CurTime() + 1
	self.DieTime = CurTime() + 15
end

function ENT:PhysicsUpdate(phys)
	if phys:GetVelocity():Length() < 2 then
		phys:EnableMotion(false)
	end
end