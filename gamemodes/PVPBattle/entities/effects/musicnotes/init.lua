EFFECT.NoteMat = Material("sprites/music")

function EFFECT:Init( data )
	self.entAttach = data:GetEntity()
	
	self.Pos = self.entAttach:EyePos()
	self.Emitter = ParticleEmitter( self.Pos )

	self.NumPerSecond = 3
	self.EmitWait = 1/self.NumPerSecond

	self.WaitForPowerup = false
	self.EmitTime = 0

	self.entAttach.MusicEffect = self
	self:Emit()
end

function EFFECT:Emit()
	if CurTime() < self.EmitTime + self.EmitWait then return end
	self.EmitTime = CurTime()

	self.Pos = self.entAttach:EyePos()
	
	local grav = Vector(0, 0, math.random(50, 60))
	local offset = Vector(0,0,25)
	//for i=0, math.random(0,1) do
		local particle = self.Emitter:Add( "sprites/music", self.Pos + offset )
		if (particle) then

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 2 )
		
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( 16 )
			particle:SetEndSize( 16 )

			particle:SetCollide( false )

			particle:SetRollDelta( math.Rand(-0.2, 0.2) )
			
			particle:SetVelocity(Vector(0,0,10))

			particle:SetGravity( grav )
			grav = grav + Vector(0, 0, math.random(0, 10))
			offset = offset + Vector(0, 0, 25)
		end
	//end
end

hook.Add("PowerupChange", "MusicAway", function(ply, powerup)
	if powerup == 0 then
		ply.MusicEffect = nil
	end
end)

function EFFECT:Think()
	if !IsValid(self.entAttach) || !self.entAttach:Alive() || self.entAttach.MusicEffect == nil then
		self.Emitter:Finish()
		return false
	end

	self:Emit()
	return true
end

function EFFECT:Render()
end