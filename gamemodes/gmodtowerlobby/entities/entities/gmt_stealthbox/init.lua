AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include("shared.lua")

function ENT:Initialize()

	self.Entity:SetModel( self.Model )	

	self:SetSolid( SOLID_NONE )
	self:DrawShadow( false )

end

function ENT:SetBoxHolder( ply )

	self:SetPos( ply:GetPos() + Vector( 0, 0, 64 ) )
	self:SetAngles( Angle( 0, 0, 0 ) )
	
	self:SetOwner( ply )
	self:SetParent( ply )

end
