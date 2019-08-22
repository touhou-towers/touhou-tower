
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	= false
end

SWEP.PrintName 		 = "NES Zapper"
SWEP.Slot		 = 1
SWEP.SlotPos		 = 0

SWEP.ViewModel		 = "models/weapons/v_pvp_neslg.mdl"
SWEP.WorldModel		 = "models/weapons/w_pvp_neslg.mdl"
SWEP.HoldType		 = "pistol"

SWEP.AutoReload		 = false

SWEP.Primary.Delay	 = 0.6
SWEP.Primary.Damage	 = {40, 41}
SWEP.Primary.Cone	 = 0
SWEP.Primary.ClipSize	 = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Ammo	 = "357"
SWEP.Primary.Sound	 = {"GModTower/pvpbattle/NESZapper/NESZap1.wav",
			    "GModTower/pvpbattle/NESZapper/NESZap2.wav",
			    "GModTower/pvpbattle/NESZapper/NESZap3.wav"}

SWEP.SoundEmpty		 = {"GModTower/pvpbattle/NESZapper/NESEmpty1.wav",
			    "GModTower/pvpbattle/NESZapper/NESEmpty2.wav"}

SWEP.HitSound		 = {"GModTower/pvpbattle/NESZapper/NESHit1.wav",
			    "GModTower/pvpbattle/NESZapper/NESHit2.wav"}

SWEP.Description = "A throw back to classic gaming. Three shots per clip; 90% kill ratio. Due to the nature of light guns, there's no crosshair and it flashes the screen each shot."
SWEP.StoreBuyable = true
SWEP.StorePrice = 500

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSoundTable( self.Primary.Sound )
	GtowerPrecacheSoundTable( self.SoundEmpty )
	GtowerPrecacheSoundTable( self.HitSound )
	GtowerPrecacheSound( "GModTower/pvpbattle/NESZapper/NESKill.wav" )
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:ShootEffects(sound, recoil)
	self.BaseClass.ShootEffects(self.Weapon, sound, recoil)

	PostEvent( self.Owner, "neszapper" )
end
