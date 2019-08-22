
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel(self.Model)
  self:DrawShadow(false)

  self:GetOwner():GetKart():SetIsInvincible(true)

end

function ENT:OnRemove()
    self:GetOwner():GetKart():SetIsInvincible(false)
end
