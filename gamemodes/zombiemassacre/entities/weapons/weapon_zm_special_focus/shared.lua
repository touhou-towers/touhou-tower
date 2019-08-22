
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Focus Gun"

SWEP.WorldModel				= Model( "models/weapons/w_pist_fiveseven.mdl" )
SWEP.HoldType				= "pistol"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.08
SWEP.Primary.Cone			= 0
SWEP.Primary.Automatic 		= true

SWEP.Primary.Damage			= 180
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/focus_fire.wav" )
SWEP.Primary.Force			= 0

SWEP.Offsets				= nil
SWEP.NoDrop 				= true