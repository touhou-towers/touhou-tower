
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_2fort/cow001_reference.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)

	self:SetTrigger(true)

	self:DrawShadow(false)
	self:SetPos(self:GetPos() + Vector(0,0,10))

end

function ENT:Use(eOtherEnt)
	if eOtherEnt:IsPlayer() then
	  if(self.Wait) then return end
		self.Wait = true
		timer.Simple(5, function() self.Wait = false
		end)
		self:SetUseType( SIMPLE_USE )
		self:EmitSoundInLocation("ambient/cow"..math.random(1,3)..".wav" , 60 )
	end
end
