
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Affected = {}

function ENT:Initialize()
  self:SetModel(self.Model)
  self:DrawShadow(false)

  self.Sound = CreateSound( self, SOUND_FLUX )
  self.Sound:Play()
end

function ENT:Think()
  local AllKarts = ents.FindByClass( "sk_kart" )
  local ValidKarts = ents.FindInSphere( self:GetPos(), 2048 )

  for k,v in pairs( AllKarts ) do

    if v:GetOwner() == self:GetOwner() then continue end

    if table.HasValue( ValidKarts, v ) then
      v.IsFluxxed = true
    else
      v.IsFluxxed = false
    end

    if v.IsFluxxed then
      if table.HasValue(self.Affected,v) then return end
      PostEvent( v:GetOwner(), "fluxon" )
      table.insert(self.Affected,v)
    end

  end

end

function ENT:OnRemove()
    for k,v in pairs(ents.FindByClass("sk_kart")) do
      v.IsFluxxed = false
    end
    self.Sound:Stop()
end
