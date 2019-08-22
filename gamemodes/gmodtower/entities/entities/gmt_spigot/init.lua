
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_farm/water_spigot.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetTrigger(true)

	self:DrawShadow(false)
	self:SetPos(self:GetPos() + Vector(0,0,10))

	self.WaterWait = true

	timer.Create("WaterSplasher",0.25,0,function()

		if self.WaterWait then return end

		local vPoint = self:GetPos() + Vector(0,0,25) + ( self:GetAngles():Forward() * 8 )
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		util.Effect( "watersplash", effectdata )
		self.WaterWait = true

	end)

end

function ENT:Use(eOtherEnt)
	  if(self.Wait) then return end
		self.Wait = true
		self.WaterWait = false
		timer.Simple(2, function() self.Wait = false
		end)
		self:SetUseType( SIMPLE_USE )
		--self:EmitSound("ambient/cow"..math.random(1,3)..".wav" , 60 )
end

function ENT:OnRemove()
    if timer.Exists("WaterSplasher") then
			timer.Destroy("WaterSplasher")
		end
end
