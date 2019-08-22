
// client files
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

// includes
include( "shared.lua" );

function ENT:Initialize( )
	self.Entity:SetModel( self.Model )	
	
	self:SetSolid( SOLID_NONE )
	
	self:DrawShadow( false )
end

function ENT:Think()
	local owner = self:GetOwner()

	if !IsValid(owner) || !owner:Alive() then
		self:Remove()
	end
end

function ENT:SetBoxHolder( ply )
	self:SetPos( ply:GetPos() + Vector(0,0,64) )
	self:SetAngles( Angle(0,0,0) )
	
	self:SetOwner( ply )
	self:SetParent( ply )

	ply.Box = self
end