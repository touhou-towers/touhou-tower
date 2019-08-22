
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Magnum"

SWEP.WorldModel				= Model( "models/weapons/w_357.mdl" )
SWEP.HoldType				= "revolver"

SWEP.Primary.ClipSize		= 25
SWEP.Primary.Delay			= 0.25
SWEP.Primary.Cone			= 0.03

SWEP.Primary.Damage			= 150
SWEP.Primary.Sound			= Sound( "weapons/357/357_fire2.wav" )
SWEP.Primary.Force			= 200

SWEP.Offsets				= nil
