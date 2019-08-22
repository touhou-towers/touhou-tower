AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:SetModel(self.Model)
	self:EmitSound(self.Sound)
	self:SetPos( self:GetPos() + Vector(0,0,250) )
	self.HeliSound = CreateSound(self,self.Sound)
	self.HeliSound:Play()
end

function ENT:OnRemove()
    self.HeliSound:Stop()
end
