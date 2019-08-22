
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "XM8 Compact"
SWEP.Slot			 = 4
SWEP.SlotPos		 = 2

SWEP.ViewModel			 = "models/weapons/v_pvp_xm8.mdl"
SWEP.WorldModel			 = "models/weapons/w_pvp_xm8.mdl"
SWEP.ViewModelFlip		 = true
SWEP.HoldType			 = "ar2"

SWEP.Primary.Automatic	 = true
SWEP.Primary.Delay	 = 0.1
SWEP.Primary.Damage	 = 15
SWEP.Primary.Cone	 = 0.015
SWEP.Primary.ClipSize	 = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Ammo	 = "AR2"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/XM8/XM8Fire.wav"

SWEP.Secondary.Delay	 = 0.5

SWEP.SoundReload	 = "GModTower/pvpbattle/XM8/XM8Reload.wav"
SWEP.SoundDeploy	 = "GModTower/pvpbattle/XM8/XM8Deploy.wav"

SWEP.IronZoom		 = true
SWEP.IronPost		 = true
SWEP.IronZoomFOV	 = 50

SWEP.Description = "Using one of the most advanced weapon designs, quickly tear into your foes with this zooming automatic rifle."
SWEP.StoreBuyable = true
SWEP.StorePrice = 700

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound(self.Primary.Sound)
	GtowerPrecacheSound(self.SoundDeploy)
	GtowerPrecacheSound(self.SoundReload)
	GtowerPrecacheSound(self.SoundZoom)
	GtowerPrecacheSound(self.SoundUnZoom)
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	self:ShootZoom()
end
