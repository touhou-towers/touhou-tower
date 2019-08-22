AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)

	self:SetPos(self:GetPos()+Vector(0,0,30))

	self.bladenoise = CreateSound( self, self.Sound )
	self.bladenoise:Play()

	timer.Simple( self.RemoveDelay, function()

		local vPoint = self:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		util.Effect( "explosion", effectdata )

		self:EmitSound("gmodtower/zom/weapons/explode"..math.random(3,5)..".wav",80)

		self.bladenoise:Stop()
		self:Remove()
	end )

	self.Blade = ents.Create( "prop_dynamic" )
	self.Blade:SetModel(self.BladeModel)
	self.Blade:SetPos(self:GetPos()+Vector(0,0,10))
	self.Blade:SetParent(self)
	self.Blade:Spawn()
end

function ENT:Think()
	--self:NextThink( CurTime() )

	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self.Radius-192)) do
		if string.StartWith( v:GetClass(), "zm_npc_" ) then
			self:EmitSound(self.SliceSound)
			v:TakeDamage( 100, self:GetOwner() )
			self:GetOwner():AddAchivement(ACHIVEMENTS.ZMBLADETRAP,1)
		end
	end

	self:NextThink( CurTime() + 0.15 )

end
