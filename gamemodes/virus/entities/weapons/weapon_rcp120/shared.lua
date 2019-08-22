SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.ViewModelFlip		= false
end

//Basic Setup
SWEP.PrintName				= "RCP 120"
SWEP.Slot					= 2

//Types
SWEP.HoldType				= "ar2"
SWEP.GunType				= "default"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models  TODO
SWEP.ViewModel			 	= "models/weapons/v_rcp120.mdl"
SWEP.WorldModel			 	= "models/weapons/w_rcp120.mdl"

//Primary
SWEP.Primary.ClipSize		= 60
SWEP.Primary.DefaultClip	= 60
SWEP.Primary.Ammo			= "AR2"
SWEP.Primary.Delay			= 0.12
SWEP.Primary.Recoil	 		= 2
SWEP.Primary.Cone			= 0.015
SWEP.Primary.Damage			= 18
SWEP.Primary.Automatic		= true

//Secondary
SWEP.Secondary.Delay	 	= 0.15

//Parameters
SWEP.AutoReload				= false
SWEP.ReloadDelay			= 0.6

//Sounds
SWEP.Primary.Sound			= "GModTower/virus/weapons/RCP120/shoot.wav"
SWEP.SoundReload	 		= "GModTower/virus/weapons/RCP120/reload.wav"
SWEP.SoundDeploy	 		= "GModTower/virus/weapons/RCP120/deploy.wav"

//Iron
SWEP.IronZoom				= true
SWEP.IronPost				= true
SWEP.IronZoomFOV	 		= 50

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	self:ShootZoom()
end