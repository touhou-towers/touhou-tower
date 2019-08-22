util.AddNetworkString("money_button_start")

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_overlay.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
  	self:SetMoveType(MOVETYPE_VPHYSICS)
  	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Use(ply)
  self:SetUseType(SIMPLE_USE)
  if self.Wait then return end
  self.Wait = true
  timer.Simple(10,function()
    ply:AddMoney(1)
  end)
  timer.Simple(12,function()
    self.Wait = false
  end)
  local Seq = self:LookupSequence("press")
  self:ResetSequence(Seq)
  self:EmitSound("GModTower/podium_button/charge.mp3",60)
  net.Start("money_button_start")
  net.WriteEntity(self)
  net.Broadcast()
end
