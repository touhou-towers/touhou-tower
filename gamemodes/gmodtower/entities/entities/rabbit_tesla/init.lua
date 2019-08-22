
include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()
	
	self:DrawShadow( false )
	self:SetNotSolid(true)
	
end

function ENT:SetRabbit( ply )
	
	self:SetPos( ply:GetPos() + Vector(0,0,64) )
	self:SetOwner( ply )
	self:SetParent( ply )

end

function ENT:GetBeanThrow()
	
	
	
end