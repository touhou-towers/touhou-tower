
-----------------------------------------------------
SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

//Basic Setup
SWEP.PrintName				= "9mm Handgun"
SWEP.Slot					= 1

//Types
SWEP.HoldType				= "revolver"
SWEP.GunType				= "default"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel		 		= Model("models/weapons/v_vir_9mm1.mdl")
SWEP.WorldModel		 		= Model("models/weapons/w_vir_9mm1.mdl")

//Primary
SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Ammo			= "AlyxGun"
SWEP.Primary.Delay			= 0.25
SWEP.Primary.Recoil	 		= 1
SWEP.Primary.Cone			= 0.015
SWEP.Primary.Damage			= 25

//Sounds
SWEP.Primary.Sound			= Sound("GModTower/virus/weapons/9MM/shoot.wav")

function SWEP:CanSecondaryAttack() return false end