AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Model		= nil
ENT.TrailColor	= Color( 0, 0, 0 )
ENT.BlastAuto	= true
ENT.BlastRange	= 320
ENT.BlastDmg	= 320

function ENT:Initialize()
	if self.BlastAuto then self.BlastTime = CurTime() + math.random( 2.5, 3 ) end

	self:SetModel( self.Model )
	
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	
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

	if IsValid(owner) then
		util.BlastDamage( self, owner, pos, self.BlastRange, self.BlastDmg )
	end
	
 	self:EmitSound( self.BlastSound, 400, 150 )

	local explode = EffectData()
	explode:SetStart( pos )
	explode:SetOrigin( pos )
	util.Effect( "Explosion", explode )
end