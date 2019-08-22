
-----------------------------------------------------
AddCSLuaFile("shared.lua")

ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "Smoke Machine"

ENT.SmokeOffset = Vector(0, -1, 3)
ENT.SmokeEjectVelocity = Vector( 0, -250, 0)
ENT.SmokeScaleFactor = 1
ENT.SmokeConeSize = 30
ENT.FogVolumeSize = 700
ENT.FogVolumeForward = 350

ENT.Model		= Model("models/gmod_tower/halloween_fogmachine.mdl")
--ENT.SmokeSound  = Sound() --TODO: this
ENT.SmokeMats = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}

ENT.IsSmoking = false

function ENT:Initialize()

	if CLIENT then return end

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

end

function ENT:Think()

end

if SERVER then return end

ENT.Color = Color( 255, 128, 40, 255 )
ENT.SpriteMat = Material( "sprites/powerup_effects" )

function ENT:Initialize()


end

function ENT:Think()
	self.IsSmoking = CurTime() % 60 < 15

	if self.IsSmoking then
		-- Spew some particles
		self:ThinkSmoke()
		self:ThinkSmokeVolume()

	-- Finish them off if we stopped
	elseif IsValid(self.Emitter) then
		--self.Emitter:Finish()
	end
end

function ENT:ThinkSmokeVolume()
	if LocalPlayer():GetPos():Distance( self:GetPos() ) > 2048 then
		if IsValid( self.Emitter ) then
			--self.Emitter:Finish()
		end
		return
	end

	if self.NextVolParticle and RealTime() < self.NextVolParticle then return end

	self.NextVolParticle = RealTime() + .25

	if not IsValid( self.Emitter ) then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	local prpos = VectorRand() * self.FogVolumeSize
	prpos.z = 32
	local p = self.Emitter:Add( table.Random( self.SmokeMats ), self:GetPos() + self:GetForward() * self.FogVolumeForward + prpos )

	if p then

		local gray = math.random(75, 200)
		p:SetColor(gray, gray, gray)
		p:SetStartAlpha(0)
		p:SetEndAlpha(50)
		p:SetLifeTime(0)

		p:SetDieTime(math.Rand(10, 20))

		p:SetStartSize(math.random(140, 150))
		p:SetEndSize(185)
		p:SetRoll(math.random(-180, 180))
		p:SetRollDelta(math.Rand(-0.1, 0.1))
		p:SetAirResistance(600)

		p:SetCollide(true)
		p:SetBounce(0.4)

		p:SetLighting(false)

	end
end

function ENT:ThinkSmoke()

	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	if self.NextParticle and self.NextParticle > CurTime() then
		return
	else
		self.NextParticle = CurTime() + .01
	end



	local smokeOffset = self.SmokeOffset * 1.0
	local smokeVelocity = self.SmokeEjectVelocity * 1.0 + Vector(math.random(-self.SmokeConeSize,self.SmokeConeSize),0,math.random(-self.SmokeConeSize,self.SmokeConeSize))
	smokeVelocity:Rotate( self:GetAngles() )
	smokeOffset:Rotate( self:GetAngles() )

	local pos = self:GetPos() + smokeOffset * 1 --Optional scale value if yall want

	for i=1, 2 do

		if math.random( 3 ) > 1 then

			local particle = self.Emitter:Add( "particles/smokey", pos )
			if particle then
				particle:SetVelocity( (VectorRand() * 10 + smokeVelocity ) * self.SmokeScaleFactor )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 7 ) )
				particle:SetStartAlpha( math.Rand( 50, 100 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 0, self.SmokeScaleFactor ) )
				particle:SetEndSize( math.random( 10, 15 ) * self.SmokeScaleFactor * 4 )
				particle:SetRoll( math.Rand( -10, 10 ) )
				particle:SetRollDelta( math.Rand( -5, 5 ) )

				local dark = math.Rand( 100, 200 )
				particle:SetColor( dark, dark, dark )
				particle:SetAirResistance( math.random(10, 200) )
				particle:SetGravity( Vector( 0, 0, math.random( 10, 30 ) ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.2 )
			end

		end

	end

end

