
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "UZI"

SWEP.WorldModel				= Model( "models/weapons/w_smg_mac10.mdl" )
SWEP.HoldType				= "revolver"

SWEP.Primary.ClipSize		= 125
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay			= 0.09
SWEP.Primary.Cone			= 0.02

SWEP.Primary.Damage			= 25
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/uzi_fire.wav" )

SWEP.Offsets				= nil
