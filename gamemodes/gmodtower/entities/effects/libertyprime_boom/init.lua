
--------------------------
-- Communist Destroyer
-- By Spacetech
--------------------------

function EFFECT:Init(Data)
	self.DieTime = CurTime() + 2
	
	self.Position = Data:GetOrigin()
	
	self.Emitter = ParticleEmitter(self.Position)
	
	for i=1, 10 do
		local Particle = self.Emitter:Add("particles/flamelet"..math.random(1, 5), self.Position)
		
		Particle:VelocityDecay(true)
		Particle:SetVelocity(math.Rand(5, 10) * Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(-10, 10)):GetNormalized())
		
		Particle:SetDieTime(math.Rand(0.5, 1.5))
		
		Particle:SetStartAlpha(math.random(235, 250))
		
		Particle:SetStartSize(math.random(30, 50))
		Particle:SetEndSize(math.random(45, 60))
		
		Particle:SetRoll(math.random(480, 540))
		Particle:SetRollDelta(math.Rand(-1, 1))
		
		Particle:SetColor(0, math.random(1, 255), 255)
	end
	
	self.Emitter:Finish()
end

function EFFECT:Think()
	if(self.DieTime <= CurTime()) then
		return false
	end
	return true
end

function EFFECT:Render()
end
