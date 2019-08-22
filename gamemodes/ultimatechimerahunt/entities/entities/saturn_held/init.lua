include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetNotSolid( true )

	self:DrawShadow( false )

end

function ENT:Think()

	if !IsValid( self:GetOwner() ) then return end
	
	local anim = self:LookupSequence( "walk" )
		self:SetPlaybackRate( 5 )
	self:ResetSequence( anim )

end