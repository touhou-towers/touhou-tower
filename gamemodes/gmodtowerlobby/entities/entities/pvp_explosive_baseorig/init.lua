AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Model		= nil
ENT.TrailColor	= Color( 0, 0, 0 )
ENT.BlastAuto	= true

function ENT:Initialize()
	if self.BlastAuto then self.BlastTime = CurTime() + math.random( 2.5, 3 ) end

	self:SetModel( self.Model )

	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	local phys = self:GetPhysicsObject()

	if !IsValid(phys) then
		self:PhysicsInitSphere(8)
		phys = self:GetPhysicsObject()
	end

	if IsValid(phys) then
		phys:Wake()
		phys:SetDamping( 0.2, 0 )
		phys:AddAngleVelocity( VectorRand() * 360 )
	end
	
	util.SpriteTrail( self, 0, self.TrailColor, false, 15, 1, .8, 1/(15+1)*0.5, "trails/plasma.vmt" )
end

function ENT:Think()
	if !self.BlastAuto then return end

	if CurTime() > self.BlastTime then
		self:Remove()
	end
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	local pos = self:GetPos()

 	self:EmitSound( self.BlastSound, 400, 150 )
	self:EmitSound( "GModTower/balls/TubePop.wav", 100, 50 )

	local eff = EffectData()
	eff:SetOrigin( self:GetPos() )
	util.Effect( "rynov_explosion", eff )

	local eff2 = EffectData()
	eff2:SetOrigin( self:GetPos() )
	util.Effect( "confetti", eff2 )
	
	local eff3 = EffectData()
	eff3:SetOrigin( self:GetPos() )
	util.Effect( "stars", eff3 )
end