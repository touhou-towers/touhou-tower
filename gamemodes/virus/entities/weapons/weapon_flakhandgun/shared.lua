SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

//Basic Setup
SWEP.PrintName				= "Flak Handgun"
SWEP.Slot					= 1

//Types
SWEP.HoldType				= "revolver"
SWEP.GunType				= "scifi"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel		 		= Model("models/weapons/v_vir_flakhg.mdl")
SWEP.WorldModel		 		= Model("models/weapons/w_vir_flakhg.mdl")

//Primary
SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Ammo			= "SMG1"
SWEP.Primary.Delay			= 2
SWEP.Primary.Recoil	 		= 2
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Damage			= { 50, 80 }
SWEP.Primary.NumShots		= 6

//Parameters
SWEP.Ricochet				= 1

//Effects
SWEP.Trace					= "flak"

//Sounds
SWEP.Primary.Sound			= Sound("GModTower/virus/weapons/FlakHandGun/shoot.wav")

SWEP.SoundReload			= Sound("GModTower/virus/weapons/FlakHandGun/reload.wav")
SWEP.SoundEmpty		 		= Sound("GModTower/virus/weapons/FlakHandGun/empty.wav")
SWEP.SoundDeploy			= Sound("GModTower/virus/weapons/FlakHandGun/deploy.wav")

function SWEP:PrimaryAttack()

	self.BaseClass.PrimaryAttack( self )
	self:TakePrimaryAmmo( 5 )

end

function SWEP:CanSecondaryAttack() return false end