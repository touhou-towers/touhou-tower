
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Auto Shotgun"

SWEP.WorldModel				= Model( "models/weapons/w_shot_xm1014.mdl" )
SWEP.HoldType				= "shotgun"

SWEP.Primary.ClipSize		= 16
SWEP.Primary.Delay			= 0.50
SWEP.Primary.Cone			= 0.1
SWEP.Primary.NumShots		= 5
SWEP.Primary.Automatic 		= true

SWEP.Primary.Damage			= 30
SWEP.Primary.Sound			= Sound( "Weapon_XM1014.Single" )

SWEP.Offsets				= nil
