include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )



function ENT:Initialize()

	self:SetNotSolid( true )
	self:SetParent( self:GetOwner() )
	self:SetPos( self:GetOwner():GetPos() )
	
	self:DrawShadow( false )

end


function ENT:SetWeapon( wep )
	
	if ( wep == nil ) then
	
		umsg.Start( "SetBack" )
			umsg.Entity( self )
			umsg.String( "" )
		umsg.End()
		
		return
		
	end
	
	local wep = wep.WorldModel
	if !wep then return end
	
	umsg.Start( "SetBack" )
		umsg.Entity( self )
		umsg.String( wep )
	umsg.End()
	
	self:SetModel( wep )
	
end