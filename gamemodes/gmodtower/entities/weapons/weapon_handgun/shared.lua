
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	= false
end

SWEP.PrintName 		 = "Hand Gun"
SWEP.Slot			 = 0
SWEP.SlotPos		 = 0

SWEP.ViewModel		 = "models/weapons/v_pvp_handgun1.mdl"
SWEP.WorldModel		 = ""
SWEP.HoldType		 = "pistol"

SWEP.AutoReload		 = false

SWEP.Primary.Delay	 = 0.6
SWEP.Primary.Damage	 = 0
SWEP.Primary.Cone	 = 0
SWEP.Primary.ClipSize	 = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Ammo	 = "357"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/Handgun/hg_fire.wav"

SWEP.SoundEmpty		 = "GModTower/pvpbattle/Handgun/hg_empty.wav"
SWEP.SoundReload		 = "GModTower/pvpbattle/Handgun/hg_reload.wav"

/*SWEP.Description = "Frighten your foes by pressing a 'gun' behind their back.  If done right, they'll lose all their weapons and become blind."
SWEP.StoreBuyable = true
SWEP.StorePrice = 100*/
				
GtowerPrecacheModel( SWEP.ViewModel )
//GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound( self.Primary.Sound )
	GtowerPrecacheSound( self.SoundEmpty )
	GtowerPrecacheSound( self.SoundReload )
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootMelee( self.Primary.Damage, nil, nil, nil )
	self:ShootEffects(self.Primary.Sound, self.Primary.Recoil, self.Primary.Effect, ACT_VM_PRIMARYATTACK)

	self:TakePrimaryAmmo( 1 )
end

function SWEP:CanSecondaryAttack()
	return false
end 