include('shared.lua')

function ENT:Initialize()
	self:SetNoDraw(true)

	local ent = ents.GetByIndex(mul)
	local edata = EffectData()
	edata:SetOrigin(self:GetPos())
	util.Effect("karpar", edata)

	//ParticleEffect( "karpar", self:GetPos(), Angle(0,0,0), self )
end

function ENT:Draw()
end

function ENT:DrawTranslucent()
end