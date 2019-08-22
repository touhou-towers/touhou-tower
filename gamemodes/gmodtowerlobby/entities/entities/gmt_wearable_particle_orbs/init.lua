include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_NONE )
	self:SetNoDraw(true)
  self:DrawShadow(false)

end
