AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Model = ""
ENT.Sound = ""

function ENT:Initialize()

	self:PreInit()
	self:SetModel( self.Model )

	self:SetSolid( SOLID_BBOX )

	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self:SetCollisionBounds( Vector( -10, -10, -10 ), Vector( 10, 10, 10 )  )
	self:SetTrigger( true )

	self.RemoveTime = CurTime() + 10
	self.PickUpDelay = CurTime() + .15

	local effectdata = EffectData()
		effectdata:SetEntity( self )
		effectdata:SetOrigin( self:GetPos() )
	util.Effect( "item_spawn", effectdata )
	
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		local vel = VectorRand() * 100
		vel.z = 100
		
		phys:Wake()
		phys:SetDamping( 0, 100 )
		phys:SetVelocity( vel )
	end

end

function ENT:PreInit()
end

function ENT:Think()

	if self.NeverRemoves then return end

	if !self.RemoveTime then self:Remove() return end

	if self.RemoveTime < CurTime() then
		self:Remove()
	end

end

function ENT:Touch( ply )

	if !ply:IsPlayer() || self.PickUpDelay > CurTime() then return end

	if ( self:PickUp( ply ) ) then
	
		ply:EmitSound( self.Sound )
		self:Remove()
		
	end

end

function ENT:PickUp( ply )
	PostEvent( ply, "ppickup" )
end