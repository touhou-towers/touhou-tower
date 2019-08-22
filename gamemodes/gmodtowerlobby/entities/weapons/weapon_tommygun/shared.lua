
-----------------------------------------------------
SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

//Basic Setup
SWEP.PrintName				= "Tommy Gun"
SWEP.Slot					= 2

//Types
SWEP.HoldType				= "ar2"
SWEP.GunType				= "rifle"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel		 		= Model("models/weapons/v_vir_tom.mdl")
SWEP.WorldModel		 		= Model("models/weapons/w_pvp_tom.mdl")
SWEP.ViewModelFlip		 	= true

//Primary
SWEP.Primary.ClipSize		= 25
SWEP.Primary.DefaultClip	= 25
SWEP.Primary.Ammo			= "AR2"
SWEP.Primary.Delay			= 0.10
SWEP.Primary.Recoil	 		= 2.25
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Damage			= 12
SWEP.Primary.Automatic	 	= true

//Sounds
SWEP.Primary.Sound	 		= Sound("GModTower/pvpbattle/Thompson/ThompsonFire.wav")
SWEP.SoundReload	 		= Sound("GModTower/pvpbattle/Thompson/ThompsonReload.wav")
SWEP.SoundDeploy	 		= Sound("GModTower/pvpbattle/Thompson/ThompsonDeploy.wav")

function SWEP:CanSecondaryAttack() return false end

function SWEP:GetViewModelPosition( pos, ang )
	local right	= ang:Right()
	local up	= ang:Up()
	pos		= pos + up * 0.5
	ang:RotateAroundAxis(up, -5)
	ang:RotateAroundAxis(right, -1)
	return pos, ang
end