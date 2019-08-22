AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Sound = "GModTower/zom/weapon_pickup.wav"


function ENT:PreInit()

	local wep = DropManager.GetRandomWeapon()

	self.Weapon = wep.ClassName
	self.WeaponName = wep.PrintName
	self.Model = wep.WorldModel

end

function ENT:PickUp( ply )

	// we don't pick it up if the player already owns it
	if ( ply:HasWeapon( self.Weapon ) ) then return false end

	self.BaseClass:PickUp( ply )

	ply:AddAchivement( ACHIVEMENTS.ZMWEAPONS, 1 )

	--if ( ply:IsFullyEquipped() ) then
		--ply:GiveWeapon( self.Weapon, ply.SelectedWeapon )
	--else
		ply:Give( self.Weapon )
		ply:SelectWeapon( self.Weapon )
	--end

	umsg.Start( "PickupHUD", ply )
		umsg.String(string.upper(self.WeaponName))
		umsg.Char(3)
	umsg.End()

	local effect = EffectData()
		effect:SetOrigin( self:LocalToWorld( self:OBBCenter() ) )
	util.Effect( "pickup_weapon", effect, true, true )

	return true

end
