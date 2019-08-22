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
	self:EmitSound(self.SweepSound)

	local eff = EffectData()
	eff:SetEntity( self )
	eff:SetOrigin( self:GetPos()+Vector(0,0,55) )
	eff:SetNormal( self:GetUp() )
	util.Effect( "sweep", eff )

	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self.Radius-200)) do
		if string.StartWith( v:GetClass(), "zm_npc_" ) then
			self:EmitSound(self.BlastSound)
			v:TakeDamage( 100, self:GetOwner() )
			self:GetOwner():AddAchivement(ACHIVEMENTS.ZMRADIO,1)
		end
	end

	self:NextThink( CurTime() + 0.5 )
	return true
end
