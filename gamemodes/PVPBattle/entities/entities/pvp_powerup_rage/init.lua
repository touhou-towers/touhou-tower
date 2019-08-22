AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.ActiveTime = 20

ENT.StoreWeapons = {}

function ENT:PowerUpOn( ply )
	ply:SetColor( Color(235, 155, 10, 255) )
	PostEvent( ply, "purage_on" )
	
	if IsValid(ply:GetActiveWeapon()) then
		self.LastWeapon = ply:GetActiveWeapon():GetClass()
	else
		self.LastWeapon = ""
	end

	for k, v in pairs( ply:GetWeapons() ) do
		self.StoreWeapons[k] = v:GetClass()
	end
	ply:StripWeapons()
	ply:Give( "weapon_rage" )
	self:Damage( ply )
end

function ENT:Damage( ply )
	if IsValid(ply) && ply.PowerUp > 0 then
		if ply:Health() > 1 then
			ply:SetHealth( ply:Health() - 1 )
		else
			ply:Kill()
		end
		timer.Simple( .5, function() if !IsValid(self) then return end self:Damage( ply ) end )
	end
end

function ENT:PowerUpOff( ply )
	ply:SetColor( Color(255, 255, 255, 255) )
	PostEvent( ply, "purage_off" )

	for k, v in pairs( self.StoreWeapons ) do
		ply:Give( v )
	end
	ply:StripWeapon( "weapon_rage" )
	ply:SelectWeapon( self.LastWeapon )
	self.LastWeapon = nil
end