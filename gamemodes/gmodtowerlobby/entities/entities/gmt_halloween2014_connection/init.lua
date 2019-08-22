
util.AddNetworkString("open_halloween")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Use(ply)
	net.Start("open_halloween")
	net.Send(ply)
end