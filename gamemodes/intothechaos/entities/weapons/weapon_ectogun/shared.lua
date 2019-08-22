SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

//Basic Setup
SWEP.PrintName				= "Ecto-Gun"
SWEP.Slot					= 1

//Types
SWEP.HoldType				= "revolver"
SWEP.GunType				= "scifi"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel		 		= "models/weapons/v_vir_scifihg.mdl"
SWEP.WorldModel		 		= "models/weapons/w_vir_scifihg.mdl"

//Primary
SWEP.Primary.ClipSize		= 24
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Delay			= 0.15
SWEP.Primary.Recoil	 		= 2
SWEP.Primary.Cone			= 0.005
SWEP.Primary.Damage			= { 25, 30 }

//Parameters
SWEP.Ricochet				= 3

//Effects
SWEP.Trace					= "scifi_trace"
SWEP.Effect					= "scifi"

//Sounds
SWEP.Primary.Sound			= Sound("GModTower/zom/weapons/laser_fire.wav")
SWEP.SoundReload	 		= Sound("GModTower/virus/weapons/ScifiHandgun/reload.wav")
SWEP.SoundDeploy	 		= Sound("GModTower/virus/weapons/ScifiHandgun/deploy.wav")

function SWEP:CanSecondaryAttack() return false end
