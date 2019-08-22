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
		if string.StartWith( v:GetClass(), "zm_npc_" ) then
			v:EmitSound( Sound("gmodtower/zom/powerups/lasercharge.wav") )
      v:TakeDamage( 25, self:GetOwner() )
		end
	end

	self:NextThink( CurTime() + 0.5 )
	return true
end
