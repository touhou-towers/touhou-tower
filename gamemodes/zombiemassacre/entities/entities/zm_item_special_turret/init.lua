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

	for k,v in pairs( ents.FindInSphere( self:GetPos(), self.Radius ) ) do
		if string.StartWith( v:GetClass(), "zm_npc_" ) then

			local tr = util.TraceLine( {
				start = self:GetPos() + Vector(0,0,25),
				endpos = self:GetEnemyPos(v),
				filter = { self, player.GetAll() }
			} )

			print(tr.Entity)

			if tr.Entity != v then continue end

			if !self.OldTarget || self.OldTarget != v then
				self:EmitSound(self.Sounds["TargetFound"])
			end

			local vPoint = self:GetShootPos()
			local effectdata = EffectData()
			effectdata:SetOrigin( vPoint )
			effectdata:SetStart( vPoint )
			effectdata:SetEntity( self )
			effectdata:SetAttachment( 1 )
			util.Effect( "gunflash", effectdata, true, true )

			self:PointAtEntity(v)
			v:TakeDamage(10,self:GetOwner())
			self:EmitSound(self.Sound,80)
			self.OldTarget = v
			return
		end


	end

	self:NextThink(CurTime() + 0.1)

end
