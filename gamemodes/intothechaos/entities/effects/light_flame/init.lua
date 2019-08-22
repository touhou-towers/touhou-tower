local PARTICLE_EMITTER = ParticleEmitter(Vector())

function EFFECT:Init(data)
	self.Attachment = data:GetAttachment()
	self.LightEntity = data:GetEntity()

	/*self.FlameScale = 1
	self.Scale = data:GetScale() || 1
	print(data:GetScale())

	if self.Scale <= 0 then
		self.Scale = .1
	end*/
end

function EFFECT:Think()
	if !IsValid(self.LightEntity) then return false end

	if (!self.NextFire || self.NextFire < CurTime()) then
		self.NextFire = CurTime() + .03

		local part, pos

		if self.Attachment then
			pos = self.LightEntity:GetAttachment(self.Attachment).Pos
		else
			pos = self.LightEntity:GetPos()
		end

		part = PARTICLE_EMITTER:Add("effects/softglow", pos)

		local r, g, b = self.LightEntity:GetLightColor()

		if part then
			part:SetVelocity(Vector(0, 0, math.sin(math.random()) * 7.63))
			part:SetDieTime(1)
			part:SetStartAlpha(255)
			part:SetEndAlpha(0)
			part:SetStartSize(0.71)
			part:SetEndSize(0.0)
			part:SetStartLength(0)
			part:SetEndLength(0)
			part:SetAirResistance(851.41)
			part:SetBounce(.2)
			part:SetColor(r, g, b, 255)
			part:SetGravity(Vector(0, 0, 60.59))
		end
	end

	return self.LightEntity:IsLit()
end

function EFFECT:Render()
end
