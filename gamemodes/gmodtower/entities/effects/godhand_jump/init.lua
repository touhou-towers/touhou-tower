
function EFFECT:Think()
	return CurTime() <= self.DieTime
end
local matRing = Material("effects/select_ring")
function EFFECT:Render()
	local ct = CurTime()
	if ct <= self.DieTime then
		local delta = self.DieTime - ct

		render.SetMaterial(matRing)
		local size = math.min((0.6 - delta) * 1400, 700)
		local alpha = math.min(255, delta * 500)
		local col = Color(255, 180, 5, alpha)
		render.DrawQuadEasy(self.Pos, self.Norm, size, size, col, 0)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, size, size, col, 0)
		local col2 = Color(255, 255, 255, alpha * 0.5)
		render.DrawQuadEasy(self.Pos, self.Norm, size, size, col2, 0)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, size, size, col2, 0)

	end
end

function EFFECT:Init(data)
	local normal = data:GetNormal()
	local pos = data:GetOrigin()
	self.DieTime = CurTime() + 0.6
	pos = pos + normal * 3
	self.Pos = pos
	self.Norm = normal
	self.Entity:SetRenderBoundsWS(pos + Vector(-400, -400, -400), pos + Vector(400, 400, 400))

	local dlight = DynamicLight(dlightcounter)
	if dlight then
		dlight.Pos = pos + normal * 32
		dlight.r = 255
		dlight.g = 180
		dlight.b = 0
		dlight.Brightness = 5
		dlight.Decay = 800
		dlight.Size = 650
		dlight.DieTime = self.DieTime + 0.5
	end

	local ang = normal:Angle()

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(36, 46)
	for i=1, 360, 3 do
		ang:RotateAroundAxis(ang:Forward(), 3)
		local dir = ang:Up()

		local particle = emitter:Add("effects/fire_cloud1", pos + dir * 8)
		particle:SetVelocity(dir * 5000)
		particle:SetDieTime(1)
		particle:SetStartAlpha(240)
		particle:SetEndAlpha(0)
		particle:SetStartSize(16)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-30, 30))
		particle:SetAirResistance(1800)
	end

	emitter:Finish()
end
