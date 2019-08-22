
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	= false
end

SWEP.PrintName 		 = "AS-50 Sniper Rifle"
SWEP.Slot		 = 4
SWEP.SlotPos		 = 3

SWEP.ViewModel		 = "models/weapons/v_pvp_as50.mdl"
SWEP.WorldModel		 = "models/weapons/w_pvp_as50.mdl"
SWEP.HoldType		 = "ar2"

SWEP.Primary.Delay	 = 1.5
SWEP.Primary.Damage	 = {25, 40}
SWEP.Primary.Recoil	 = 6
SWEP.Primary.Cone	 = 0
SWEP.Primary.ClipSize	 = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Ammo	 = "SniperRound"
SWEP.Primary.Effect	 = "sniper_trace"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/Sniper/SniperFire.wav"

SWEP.Secondary.Delay	 = 1

SWEP.SoundEmpty		 = "Weapon_Pistol.Empty"

SWEP.IronZoom		 = true
SWEP.IronZoomFOV	 = 15


SWEP.Description = "With only two bullets a clip and deadly accuracy, this sniper will be critical for picking off innocent targets. However, be wary, as each bullet leaves a trail in the air."
SWEP.StoreBuyable = true
SWEP.StorePrice = 575


SWEP.IronSightsPos = Vector (3.6707, -6.297, 1.6166)
SWEP.IronSightsAng = Vector (-0.7847, 4.1086, 0.8058)

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound(self.Primary.Sound)
	GtowerPrecacheSound(self.SoundZoom)
	GtowerPrecacheSound(self.SoundUnZoom)
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	self:ShootZoom()
end