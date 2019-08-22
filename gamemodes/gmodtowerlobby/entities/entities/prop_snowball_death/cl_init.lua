include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	//This thing causes problems and I'm not into it.
	/*local Emitter = ParticleEmitter(self.Entity:GetPos())

	if self.Entity:GetVelocity():Length() > 28 and math.random(1,3) == 2 then
		local particle = Emitter:Add("effects/blood_drop", self.Entity:GetPos())
		particle:SetVelocity(VectorRand() * 15)
		particle:SetDieTime(1)
		particle:SetStartAlpha(255)
		particle:SetStartSize(10)
		particle:SetEndSize(1)
		particle:SetRoll(180)
		particle:SetColor(255, 255, 255)
	end*/
end