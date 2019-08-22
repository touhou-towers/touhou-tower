
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_spytech/rocket002_skybox.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)

	self:SetTrigger(true)

end

function ENT:Use(eOtherEnt)
	if eOtherEnt:IsPlayer() then
	  if(self.Wait) then return end
		self.Wait = true
		timer.Simple(5, function() self.Wait = false
		end)
		self:SetUseType( SIMPLE_USE )
		self:EmitSound(Sound("misc/doomsday_cap_open.wav") , 50 )
	end
end
