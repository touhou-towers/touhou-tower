
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Glock"

SWEP.WorldModel				= Model( "models/weapons/w_pist_glock18.mdl" )
SWEP.HoldType				= "revolver"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.18
SWEP.Primary.Cone			= 0.03

SWEP.Primary.Damage			= 15
SWEP.Primary.Automatic		= true
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/handgun_fire.wav" )

SWEP.Offsets				= nil
SWEP.NoDrop 				= true