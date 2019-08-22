
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	 = false
end

SWEP.PrintName 			 = "Toy Hammer"
SWEP.Slot				 = 0
SWEP.SlotPos			 = 1

SWEP.ViewModel			 = "models/weapons/v_pvp_toy.mdl"
SWEP.WorldModel			 = "models/weapons/w_pvp_toy.mdl"
SWEP.ViewModelFlip		 = false
SWEP.HoldType			 = "melee"

SWEP.Primary.Automatic	= true
SWEP.Primary.UnlimAmmo	= true
SWEP.Primary.Effect		= "toy_zap"
SWEP.Primary.Sound		= "GModTower/pvpbattle/ToyHammer/ToyZap.wav"
SWEP.Primary.Damage		= {20, 30}

SWEP.Secondary.Damage	= {80, 90}

SWEP.AutoReload			= false

SWEP.SoundDeploy		= Sound("GModTower/pvpbattle/ToyHammer/ToyDeploy.wav")
SWEP.SoundSwing			= Sound("weapons/iceaxe/iceaxe_swing1.wav")

SWEP.CrosshairDisabled	= true
SWEP.LaserDelay			= CurTime()

SWEP.MeleeHitSound		= {	"GModTower/pvpbattle/ToyHammer/ToyHit1.wav",
							"GModTower/pvpbattle/ToyHammer/ToyHit2.wav",
							"GModTower/pvpbattle/ToyHammer/ToyHit3.wav" }

SWEP.Description		= "Squeak your opponents to their death. Doesn't deal much damage, so be careful."
SWEP.StoreBuyable		= true
SWEP.StorePrice 		= 0

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound( self.SoundDeploy )
	GtowerPrecacheSound( self.Primary.Sound )
	GtowerPrecacheSound( self.SoundSwing )
	GtowerPrecacheSoundTable( self.MeleeHitSound )
end

function SWEP:Think()
	self.BaseClass:Think()

	if self.LaserDelay < CurTime() then
		self.Owner._LaserOn = false
	end
end

function SWEP:FireLaser()

	self:SetNextPrimaryFire( CurTime() + 1 )
	self.Owner._LaserOn = true
	self.LaserDelay = CurTime() + 0.15

	self:ShootBullet(self.Primary.Damage, 1, 0, "none")
	self:ShootEffects(self.Primary.Sound, Angle( 2, 1, 0 ), self.Primary.Effect, ACT_VM_HITCENTER)

end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end

	if ( self.Owner:KeyDown( IN_ATTACK2 ) &&
		self.Owner:KeyDown( IN_DUCK ) &&
		self.Owner:IsOnGround() ) then

		self:FireLaser()

	else
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:ShootMelee( self.Secondary.Damage, self.MeleeHitSound, self.MeleeHitSound, self.SoundSwing )
	end
end

function SWEP:SecondaryAttack()

	if ( !self.Owner:IsAdmin() ) then return end

	if !string.StartWith(game.GetMap(),"gmt_build") then return end

	self:FireLaser()

end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end
