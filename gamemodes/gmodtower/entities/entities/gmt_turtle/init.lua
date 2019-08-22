
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/gmod_tower/plush_turtle.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetTrigger(true)

	self:DrawShadow(false)
	self:SetPos(self:GetPos() + Vector(0,0,10))

	self.WaterWait = true

end

function ENT:Use(eOtherEnt)
	  if(self.Wait) then return end
		self.Wait = true
		timer.Simple(5, function() self.Wait = false
		end)
		self:SetUseType( SIMPLE_USE )
		self:Squish()
end
