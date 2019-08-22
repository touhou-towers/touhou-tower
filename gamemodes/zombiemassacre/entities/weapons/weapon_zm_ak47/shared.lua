
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "AK47"

SWEP.WorldModel				= Model( "models/weapons/w_rif_ak47.mdl" )
SWEP.HoldType				= "ar2"

SWEP.Primary.ClipSize		= 200
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay			= 0.07
SWEP.Primary.Cone			= 0.02

SWEP.Primary.Damage			= 40
SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )

SWEP.Offsets				= nil

SWEP.Tier 					= DropManager.UNCOMMON