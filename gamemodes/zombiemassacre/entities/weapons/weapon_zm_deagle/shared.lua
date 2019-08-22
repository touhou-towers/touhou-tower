
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Deagle"

SWEP.WorldModel				= Model( "models/weapons/w_pist_deagle.mdl" )
SWEP.HoldType				= "revolver"

SWEP.Primary.ClipSize		= 25
SWEP.Primary.Delay			= 0.25
SWEP.Primary.Cone			= 0.03

SWEP.Primary.Damage			= 75
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/deagle_fire.wav" )

SWEP.Offsets				= nil

