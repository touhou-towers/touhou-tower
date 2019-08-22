
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	= false
end

SWEP.PrintName 			= "Sword"
SWEP.Slot			= 0
SWEP.SlotPos			= 2

SWEP.ViewModel			= "models/weapons/v_pvp_swd.mdl"
SWEP.WorldModel			= "models/weapons/w_pvp_swd.mdl"
SWEP.ViewModelFlip		= false
SWEP.HoldType			= "melee2"

SWEP.Primary.Automatic		= true
SWEP.Primary.UnlimAmmo		= true
SWEP.Primary.Damage			= {65, 90}
SWEP.Primary.Delay			= 0.45

SWEP.Secondary.Automatic	= false
SWEP.Secondary.UnlimAmmo	= true
SWEP.Secondary.Delay		= 2

SWEP.SoundDeploy		= "GModTower/pvpbattle/Sword/SwordDeploy.wav"

SWEP.CrosshairDisabled	 	= true
SWEP.SwordHit			= "GModTower/pvpbattle/Sword/SwordHit.wav"
SWEP.SwordHitFlesh		= {	"GModTower/pvpbattle/Sword/SwordFlesh1.wav",
					"GModTower/pvpbattle/Sword/SwordFlesh2.wav",
					"GModTower/pvpbattle/Sword/SwordFlesh3.wav",
					"GModTower/pvpbattle/Sword/SwordFlesh4.wav" 	}
SWEP.SwordMiss			= {	"GModTower/pvpbattle/Sword/SwordMiss1.wav",
					"GModTower/pvpbattle/Sword/SwordMiss2.wav"  	}
SWEP.SwordSwing			= {	"GModTower/pvpbattle/Sword/SwordVSwing1.wav",
					"GModTower/pvpbattle/Sword/SwordVSwing2.wav",
					"GModTower/pvpbattle/Sword/SwordVSwing3.wav"	}
SWEP.SwordBigSwing		= {	"GModTower/pvpbattle/Sword/SwordVBigSwing1.wav",
					"GModTower/pvpbattle/Sword/SwordVBigSwing2.wav" }

SWEP.Description = "Slice and dice like a ninja. Dash forward and unleash your fury."
SWEP.StoreBuyable = true
SWEP.StorePrice = 200

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound(self.SoundDeploy)
	GtowerPrecacheSound(self.SwordHit)
	GtowerPrecacheSound("GModTower/pvpbattle/Sword/SwordVDeath.wav")
	GtowerPrecacheSound("GModTower/pvpbattle/Sword/SwordVKill.wav")
	GtowerPrecacheSoundTable(self.SwordHitFlesh)
	GtowerPrecacheSoundTable(self.SwordMiss)
	GtowerPrecacheSoundTable(self.SwordSwing)
	GtowerPrecacheSoundTable(self.SwordBigSwing)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if IsFirstTimePredicted() then
		self.Weapon:EmitSound( self.SwordSwing[#self.SwordSwing] )
	end

	self:ShootMelee( self.Primary.Damage, self.SwordHit, self.SwordHitFlesh, self.SwordMiss )
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	if IsFirstTimePredicted() then
		self.Weapon:EmitSound( self.SwordBigSwing[#self.SwordBigSwing] )
	end

	self.Owner.DashWeapon = CurTime()
end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return self.Owner:IsOnGround()
end
