
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel(self.Model)
  self:DrawShadow(false)

  self:EmitSound( "gmodtower/sourcekarts/effects/powerups/disco"..math.random(1,7)..".mp3" )

end
