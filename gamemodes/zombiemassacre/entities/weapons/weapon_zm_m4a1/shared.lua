
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "M4A1"

SWEP.WorldModel				= Model( "models/weapons/w_rif_m4a1.mdl" )
SWEP.HoldType				= "ar2"

SWEP.Primary.ClipSize		= 200
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay			= 0.07
SWEP.Primary.Cone			= 0.02

SWEP.Primary.Damage			= 40
SWEP.Primary.Sound			= Sound( "Weapon_M4A1.Single" )

SWEP.Offsets				= nil

SWEP.Tier = DropManager.UNCOMMON
