AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.RocketSpeed		= 600
ENT.WobbleScale		= 0.8
ENT.Damage			= 50
ENT.Homing			= false
ENT.PingRadius		= 2800
ENT.PingRate		= 0.2
ENT.TargetAffinity	= 0.1
--ENT.BlastSound		= Sound( "BaseExplosionEffect.Sound" )

local sndThrustLoop = Sound("Missile.Accelerate")
local sndStop = Sound("ambient/_period.wav")

function ENT:Initialize()
	self:SetModel( self.Model )

	self:PhysicsInit(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_FLY)	
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

	self.EmittingSound = false

	if self.Homing then
		self.Target = NULL
		self.NextPing = CurTime()
	end
	self.RemoveTime = CurTime() + 5

	self.LastWobble = self:GetForward()
end

function ENT:PingTargets()
	if !self.Homing then return end

	for _,ent in pairs( ents.FindInSphere( self:GetPos(), self.PingRadius ) ) do
		if IsValid(ent) && ent != self && ent:IsPlayer() && ent != self:GetOwner() then
			//print(ent)
			if !self.Target then self.Target = ent end
		end
	end
end

function ENT:Think()
	if self.Homing then
		if self.NextPing < CurTime() then
			self:PingTargets()
			self.NextPing = CurTime() + self.PingRate
		end
	end
	
	if self.RemoveTime < CurTime() then
		self:Remove()
	end

	local Wobble = ( VectorRand() + self.LastWobble ):GetNormalized()
	local RocketAng = self:GetForward()
	local NewAng = Wobble * self.WobbleScale + RocketAng
	
	if self.Homing then
		if IsValid( self.Target ) && self.Target != self:GetOwner() then
			local Displacement = ( self.Target:LocalToWorld( self.Target:OBBCenter() ) - self:GetPos() )
			NewAng = NewAng * ( Displacement:Length() / self.PingRadius ) + Displacement:GetNormalized() * self.TargetAffinity 
		end
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
	if IsValid( self:GetOwner() ) then util.BlastDamage(self:GetOwner(), self:GetOwner(), self:GetPos(), self.Damage * 3, self.Damage) end
	
	local eff = EffectData()
	eff:SetOrigin( self:GetPos() )
	util.Effect( "rpg_explosion", eff )

	self:EmitSound( self.BlastSounds[math.random(1,3)] )
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