
-----------------------------------------------------
include('shared.lua')

function ENT:Initialize()
end

function ENT:Think()
	
	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	self.LastParticlePos = self.LastParticlePos or self:GetPos()
	local vDist = self:GetPos() - self.LastParticlePos
	local vNorm = vDist:GetNormalized()
	local Length = vDist:Length()
	
	for i=0, Length, 8 do

		self.LastParticlePos = self.LastParticlePos + vNorm * 8
		self.ParticlesSpawned = self.ParticlesSpawned or 1
		self.ParticlesSpawned = self.ParticlesSpawned + 1
		
		if math.random(3) > 1 then

			local particle = self.Emitter:Add( "particles/smokey", self.LastParticlePos ) 
			particle:SetVelocity( VectorRand() * 40 ) 
			particle:SetLifeTime( 0 ) 
			particle:SetDieTime( math.Rand(1.0,1.5) ) 
			particle:SetStartAlpha( math.Rand(150,200) ) 
			particle:SetEndAlpha( 0 ) 
			particle:SetStartSize( math.random(2,5) ) 
			particle:SetEndSize( math.random(10,25) )

			local dark = math.random( 50, 150 )
			particle:SetColor( 200, dark, dark, 150 ) 
			particle:SetAirResistance( 50 )
			particle:SetGravity( Vector( 0, 0, math.random(-50,50) ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.2 )

		end
			
		if math.random(3) == 3 then

			local particle = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.LastParticlePos )
			particle:SetVelocity( VectorRand() * 30 + Vector(0,0,20) ) 
			particle:SetLifeTime( 0 ) 
			particle:SetDieTime( math.Rand(0.1,0.2) ) 
			particle:SetStartAlpha( 255 ) 
			particle:SetEndAlpha( 0 ) 
			particle:SetStartSize( math.random(6,12) ) 
			particle:SetEndSize( 1 )
			particle:SetColor( math.Rand( 150, 255 ), math.Rand( 100, 150 ), 100 )
	
			particle:SetAirResistance( 50 )

		end

		if self.ParticlesSpawned > 8 then
			self.Emitter:Finish()
			self.Emitter = ParticleEmitter( self.Entity:GetPos() )
			self.ParticlesSpawned = 0
		end

	end
	
end