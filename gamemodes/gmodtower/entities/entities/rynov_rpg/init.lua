
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.RocketSpeed		= 900
ENT.PingRadius		= 2800
ENT.PingRate		= 0.5
ENT.WobbleScale		= 0.5
ENT.TargetAffinity	= 0.1
ENT.Damage			= 45

local sndThrustLoop = Sound("Missile.Accelerate")
local explosionSound = Sound("BaseExplosionEffect.Sound")
local sndStop = Sound("ambient/_period.wav")

function ENT:Initialize()
	self:SetModel( "models/Weapons/w_missile.mdl" )

	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_FLY)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

	self.EmittingSound = false

	self.Target = NULL
	self.NextPing = CurTime()
	self.RemoveTime = CurTime() + 5

	self.LastWobble = self:GetForward()
end

function ENT:PingTargets()
	for _,ent in pairs( ents.FindInSphere( self:GetPos(), self.PingRadius ) ) do
		if IsValid(ent) && ent != self && ent:IsPlayer() && ent:Alive() && ent != self:GetOwner() then
			//print(ent)
			if !self.Target then self.Target = ent end
		end
	end
end

function ENT:Think()
	if self.NextPing < CurTime() then
		self:PingTargets()
		self.NextPing = CurTime() + self.PingRate
	end

	if self.RemoveTime < CurTime() then
		self:Remove()
	end

	local Wobble = ( VectorRand() + self.LastWobble ):GetNormalized()
	local RocketAng = self:GetForward()
	local NewAng = Wobble * self.WobbleScale + RocketAng

	if IsValid( self.Target ) && self.Target != self:GetOwner() then
		local Displacement = ( self.Target:LocalToWorld( self.Target:OBBCenter() ) - self:GetPos() )
		NewAng = NewAng * ( Displacement:Length() / self.PingRadius ) + Displacement:GetNormalized() * self.TargetAffinity
	end
	NewAng = NewAng:GetNormalized()

	self:SetAngles( NewAng:Angle() )
	self:SetLocalVelocity( NewAng * self.RocketSpeed )

	self:StartSounds()
	self.LastWobble = Wobble
end

function ENT:Touch( hitEnt )
	if hitEnt == self:GetOwner() then return end
	self:Remove()
end

function ENT:OnRemove()
	--util.BlastDamage(self:GetOwner(), self:GetOwner(), self:GetPos(), self.Damage * 3, self.Damage)

	local eff = EffectData()
	eff:SetOrigin( self:GetPos() )
	util.Effect( "rynov_explosion", eff )

	local eff2 = EffectData()
	eff2:SetOrigin( self:GetPos() )
	util.Effect( "confetti", eff2 )

	local eff3 = EffectData()
	eff3:SetOrigin( self:GetPos() )
	util.Effect( "rynov_stars", eff3 )

	self:EmitSound( explosionSound )

	self:StopSounds()
end

function ENT:StartSounds()
	if !self.EmittingSound then
		self:EmitSound(sndThrustLoop, 60)
		self.EmittingSound = true
	end
end

function ENT:StopSounds()
	if self.EmittingSound then
		self:StopSound(sndThrustLoop)
		self:EmitSound(sndStop)
		self.EmittingSound = false
	end
end
