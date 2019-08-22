AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetPos(self:GetPos()+Vector(0,0,10))
	self:SetMaterial("models/wireframe")
	self:SetColor(Color(255,102,0,255))
	self:SetParent(self:GetOwner())
	self.sheildsound = CreateSound( self, self.Sound )
	self.sheildsound:Play()
	timer.Simple( self.RemoveDelay, function() self.sheildsound:Stop() self:GetOwner():SetNWInt( "Combo", 0 ) self:GetOwner():SetNWBool( "IsPowerCombo", false ) self:GetOwner():ResetSpeeds() self:Remove() end )
end

function ENT:Think()
	/*local eff = EffectData()
	eff:SetEntity( self )
	eff:SetOrigin( self:GetPos() )
	eff:SetNormal( self:GetUp() )
	util.Effect( "shield_block", eff )
	self:NextThink( CurTime() )
	return true*/

	for k,v in ipairs(ents.FindInSphere(self:GetPos(),30)) do
		if string.StartWith( v:GetClass(), "zm_npc_" ) then
			self:EmitSound(self.HitSound)
			local target = v
			target:SetVelocity( target:GetAngles():Forward() * 1000000 )
			target:TakeDamage( 100, self:GetOwner(), self )
			--v:Fire("kill")
		end
	end

	self:NextThink( CurTime() )
	return true
end
