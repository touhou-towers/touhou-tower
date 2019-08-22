AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel( "models/weapons/w_pvp_chainsaw.mdl" )
	
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:PhysicsInitSphere( 8 )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
		phys:SetDamping( 0.2, 0 )
		phys:AddAngleVelocity( VectorRand() * 360 )
		phys:SetMass( 5 )
	end

	self.Hit = { 
		Sound( "physics/metal/metal_grenade_impact_hard1.wav" ),
		Sound( "physics/metal/metal_grenade_impact_hard2.wav" ),
		Sound( "physics/metal/metal_grenade_impact_hard3.wav" )
	}

	self.FleshHit = { 
		Sound( "physics/flesh/flesh_impact_bullet1.wav" ),
		Sound( "physics/flesh/flesh_impact_bullet2.wav" ),
		Sound( "physics/flesh/flesh_impact_bullet3.wav" )
	}

	util.SpriteTrail( self, 0, Color( 255, 0, 0 ), false, 15, 1, .8, 1/(15+1)*0.5, "trails/plasma.vmt" )

	self.LifeTime = CurTime() + 1
end

function ENT:Think()
	if CurTime() > self.LifeTime then
		self:Explode()
	end
end

function ENT:OnTakeDamage( dmginfo )
	if self.Exploded then return end

	self.Exploded = true
	self:Explode()
end

function ENT:PhysicsCollide( data, phys )
	local ent = data.HitEntity
	if !IsValid( ent ) then return end

	if ent:IsPlayer() && ent:Alive() then

		local effectdata = EffectData()
		effectdata:SetStart( data.HitPos )
		effectdata:SetOrigin( data.HitPos )
		effectdata:SetScale( 1 )
		util.Effect( "BloodImpact", effectdata )

		local effectdata = EffectData()
			effectdata:SetOrigin( data.HitPos )
		util.Effect( "gib_bloodemitter", effectdata )

		ent:TakeDamage( 100, self:GetOwner() )
		self:EmitSound( self.FleshHit[math.random( 1, #self.FleshHit )] )
		self:Remove()

	else
		local HitNormal = data.HitNormal
		local Trace = {}

		Trace.start = self:GetPos()
		Trace.endpos = Trace.start + (HitNormal * 50)
		Trace.filter = {self}

		local tr = util.TraceLine(Trace)

		if tr.HitSky then
			self:Remove()
			return
		end

		if ent:IsWorld() then
			util.Decal( "ManhackCut", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
			self:EmitSound( self.Hit[math.random( 1, #self.Hit )] )
			self:Remove()
		end
	end

	self:SetOwner( NULL )
end

function ENT:Explode()
	local owner = self:GetOwner()
	local pos = self:GetPos()

	if IsValid( owner ) then
		util.BlastDamage( self, owner, pos, 150, 50 )
	end

 	self:EmitSound( self.BlastSound, 400, 150 )

	local explode = EffectData()
	explode:SetStart( pos )
	explode:SetOrigin( pos )
	util.Effect( "Explosion", explode )

	self:Remove()
end