include('shared.lua')

ENT.Links = {}
ENT.plys = {}

function ENT:Link(ent,link)
	local repeller = self
	local ball = ent
	local link = link

	if !IsValid(repeller) || !IsValid(ball) then return end

	if !ball.Links then
		ball.Links = {}
	end

	if link && ball.Links then
		ball.Links[repeller] = true
		local edata = EffectData()

		edata:SetOrigin(repeller:LocalToWorld(repeller:OBBCenter()))
		edata:SetEntity(ball)
		edata:SetAttachment(repeller:EntIndex())

		util.Effect("lightning", edata)
	else
		ball.Links[repeller] = false
	end
end

function ENT:Think()

	self.plys = {}

    for k,v in pairs(ents.FindInSphere( self:GetPos(), 256 )) do
			if ( IsValid(v) and v:IsPlayer() and v:Alive() ) then
				table.insert(self.plys,v)
				if self.Links and !self.Links[v] then
					self.Links[v] = true
					self:Link(v,true)
				end
			end
		end

		for k,v in pairs(self.Links) do
			if !table.HasValue(self.plys,k) then
				self.Links[k] = false
				self:Link(k,false)
			end
		end

end

function ENT:OnRemove()
	for k,v in pairs(self.Links) do
		self.Links[k] = false
		self:Link(k,false)
	end
end
