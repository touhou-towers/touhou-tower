AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	timer.Simple( self.RemoveDelay, function()

		self:EmitSound("gmodtower/zom/weapons/explode"..math.random(3,5)..".wav",80)

		self.Transplant:SetNWBool( "IsPowerCombo", false )
		self.Transplant:SetNWInt( "Combo", 0 )
		self:Remove()
	end )
end

function ENT:Think()

	for k,v in ipairs(ents.FindInSphere(self:GetPos(),self.Radius)) do
		if string.StartWith(v:GetClass(),"zm_npc_") then
			v:TakeDamage(10,self.Transplant)
			self.Transplant:SetHealth( math.Clamp( ( self.Transplant:Health() + 10 ),0, 100 ) )
		end
	end

	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:SetTransplant(ply)
	self.Transplant = ply
	self:SetParent(ply)
end
