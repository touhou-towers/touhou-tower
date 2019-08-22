AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.ActiveTime = 31
ENT.StoreWeapons = {}

function ENT:PowerUpOn( ply )

	/*ply:SetColor( 235, 155, 10, 255 )
	PostEvent( ply, "purage_on" )*/
	ply:SetWalkSpeed( 250 )
	ply:SetRunSpeed( 150 )

	if IsValid( ply:GetActiveWeapon() ) then

		self.LastWeapon = ply:GetActiveWeapon():GetClass()

	else

		self.LastWeapon = ""

	end

	for k, v in pairs( ply:GetWeapons() ) do

		self.StoreWeapons[k] = v:GetClass()

	end

	self.LastPlayerModel = ply:GetModel()

	ply:StripWeapons()
	ply:Give( "weapon_pvpcandycorn" )
	ply:SetModel( "models/props_halloween/ghost.mdl" )

end

function ENT:PowerUpOff( ply )

	/*ply:SetColor( 255, 255, 255, 255 )
	PostEvent( ply, "purage_off" )*/
	ply:SetWalkSpeed( 450 )
	ply:SetRunSpeed( 450 )

	for k, v in pairs( self.StoreWeapons ) do

		ply:Give( v )

	end

	ply:StripWeapon( "weapon_pvpcandycorn" )
	ply:SelectWeapon( self.LastWeapon )
	ply:SetModel( self.LastPlayerModel )
	self.LastWeapon = nil

end
