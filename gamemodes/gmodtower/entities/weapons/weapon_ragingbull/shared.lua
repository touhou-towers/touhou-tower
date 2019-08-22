
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Raging Bull"
SWEP.Slot		 = 1
SWEP.SlotPos		 = 1

SWEP.ViewModel		 = "models/weapons/v_pvp_ragingb.mdl"
SWEP.WorldModel		 = "models/weapons/w_pvp_ragingb.mdl"
SWEP.HoldType		 = "pistol"

SWEP.Primary.Delay	 = 0.5
SWEP.Primary.Cone	 = 0.03
SWEP.Primary.Damage	 = {45, 50}
SWEP.Primary.ClipSize	 = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Ammo	 = "357"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/RagingBull/deagle-1.wav"

SWEP.Ricochet		 = 6

SWEP.SoundReload	 = "GModTower/pvpbattle/RagingBull/bullreload.wav"
SWEP.SoundDeploy	 = "GModTower/pvpbattle/RagingBull/bulldraw.wav"

SWEP.Description = "Add a new meaning to fire power. Let waves of bullets ricochet off walls to both confuse, and destroy your enemies. Don't let the ricochets to deceive you, the Raging Bull is powerful on its own."
SWEP.StoreBuyable = true
SWEP.StorePrice = 225

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

GtowerPrecacheSound("weapons/fx/rics/ric4.wav")

function SWEP:Precache()
	GtowerPrecacheSound(self.Primary.Sound)
	GtowerPrecacheSound(self.SoundDeploy)
	GtowerPrecacheSound(self.SoundReload)
end

function SWEP:CanSecondaryAttack()
	return false
end
