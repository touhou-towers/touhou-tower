AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/breenbust.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:DrawShadow(false)

	self:SetTrigger(true)

	self:DrawShadow(false)
	--self:SetPos(self:GetPos() + Vector(0,0,10))

end

function ENT:Use(eOtherEnt)
	if eOtherEnt:IsPlayer() then
	  if(self.Wait) then return end
		self.Wait = true
		timer.Simple(5, function() self.Wait = false
		end)
		self:SetUseType( SIMPLE_USE )
		self:EmitSoundInLocation(table.Random(self.Voices), 65 )
	end
end
