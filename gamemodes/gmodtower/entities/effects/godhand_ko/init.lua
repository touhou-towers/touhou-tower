
function EFFECT:Init(data)
	local pos = data:GetOrigin()

	local emitter = ParticleEmitter(pos)
		for i=1, math.random(30, 46) do
			local particle = emitter:Add("sprites/light_glow02_add", pos)
			particle:SetVelocity(VectorRand() * 48 + Vector(0,0,200))
			particle:SetDieTime(1.5)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(50)
			particle:SetStartSize(8)
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetCollide(true)
			particle:SetColor(255, 180, 0)
			particle:SetBounce(0.75)
			particle:SetGravity(Vector(0,0,-600))
		end
		for i=1, math.random(10, 16) do
			local particle = emitter:Add("sprites/light_glow02_add", pos)
			particle:SetVelocity(VectorRand() * 32 + Vector(0,0,math.random(75, 100)))
			particle:SetDieTime(1.75)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(50)
			particle:SetStartSize(16)
			particle:SetEndSize(4)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetColor(255, 180, 0)
			particle:SetCollide(true)
			particle:SetAirResistance(80)
		end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
