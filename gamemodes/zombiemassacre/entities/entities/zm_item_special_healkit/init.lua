AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	timer.Simple( self.RemoveDelay, function()
		local vPoint = self:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		util.Effect( "explosion", effectdata )

		self:EmitSound("gmodtower/zom/weapons/explode"..math.random(3,5)..".wav",80)
		self:Remove()
	end )
end

function ENT:Think()

	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self.Radius)) do
		if v:IsPlayer() then
			v:SetHealth( math.Clamp( ( v:Health() + 10 ),0, 100 ) )
			self:GetOwner():AddAchivement(ACHIVEMENTS.ZMHEALKIT,10)
		end
	end

	self:NextThink( CurTime() + 1 )
	return true
end
