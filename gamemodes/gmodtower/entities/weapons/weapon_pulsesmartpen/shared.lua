
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	= false
end

SWEP.PrintName 		 = "Pulse Smart Pen"
SWEP.Slot		 = 0
SWEP.SlotPos		 = 3

SWEP.ViewModel			 = "models/weapons/v_psmartpen.mdl"
SWEP.WorldModel			 = "models/weapons/w_psmartpen.mdl"
SWEP.ViewModelFlip		 = false
SWEP.HoldType			 = "melee"

SWEP.Primary.Damage	= {75, 90}

SWEP.AutoReload			= false
SWEP.SoundSwing			= "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.CrosshairDisabled		= true

SWEP.MeleeHitSound		= {	"GModTower/pvpbattle/PulseSmartPen/Write1.wav",
					"GModTower/pvpbattle/PulseSmartPen/Write2.wav"}

SWEP.Taunts			= {}
for i=1,3 do
	SWEP.Taunts[i] = "GModTower/pvpbattle/PulseSmartPen/YouGotThat" .. tostring(i) .. ".wav"
end

SWEP.Description = "Write on your enemies and make sure they got that."
SWEP.StoreBuyable = true
SWEP.StorePrice = 145

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )


function SWEP:Precache()
	GtowerPrecacheSound(self.SoundSwing)
	GtowerPrecacheSoundTable(self.MeleeHitSound)
	GtowerPrecacheSoundTable(self.Taunts)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire( CurTime() + 0.4 )
	self:ShootMelee( self.Primary.Damage, self.MeleeHitSound, self.MeleeHitSound, self.SoundSwing )
end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end
