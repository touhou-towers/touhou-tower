
-----------------------------------------------------
AddCSLuaFile("shared.lua")

ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "Toy Train Small"

ENT.Model		= Model( "models/gmod_tower/rubikscube.mdl" )

if SERVER then
	function ENT:Initialize()

		self:SetModel( self.Model )
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableMotion(false)
		end

		self.Train = ents.Create( "gmt_train" )
		self.Train:SetPos( self:GetPos() + Vector( 0, 0, -9 ) )
		self.Train:Spawn()
		self.Train:Activate()
		self.Train:SetRadius( 30 )
		self.Train:SetTrainVelocity( 25 )
		self.Train:SetTrainCount( 5 )
		self.Train:SetParent( self )

	end

	function ENT:OnRemove()

		if IsValid( self.Train ) then
			self.Train:Remove()
		end

	end

else // CLIENT

	function ENT:Draw()
	end

end