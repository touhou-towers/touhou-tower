
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Super Shotty"
SWEP.Slot		 = 3
SWEP.SlotPos		 = 0

SWEP.ViewModel		 = "models/weapons/v_pvp_supershoty.mdl"
SWEP.WorldModel		 = "models/weapons/w_pvp_supershoty.mdl"
SWEP.HoldType		 = "shotgun"

SWEP.AutoReload		 = false

SWEP.Primary.Delay	 = 0.6
SWEP.Primary.Damage	 = 10
SWEP.Primary.Cone	 = 0.075
SWEP.Primary.NumShots	 = 6
SWEP.Primary.ClipSize	 = 6
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Ammo	 = "Buckshot"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/SuperShotty/SSGFire.wav"

SWEP.Description = "May look small, but this thing sure packs some heat. Fire at the ground to launch yourself up into the air. Automatically pumps, unlike the SPAS."
SWEP.StoreBuyable = true
SWEP.StorePrice = 0

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )


function SWEP:Precache()
	GtowerPrecacheSound( self.Primary.Sound )
end

function SWEP:ShootEffects(sound, recoil)
	self.BaseClass.ShootEffects(self.Weapon, sound, recoil)

	if SERVER then
		if ( !self.Owner.HasBoosted ) then

			// HACKHACK: disable boosting in virus
			if gamemode.Get( "virus" ) then return end

			self.Owner:SetVelocity( self.Owner:GetAimVector() * -500, 0 )
			self.Owner.HasBoosted = true

		end
	end
end

function SWEP:CanPrimaryAttack()
	if self.Owner.Reloading then
		if self.Weapon:GetVar( "interrupt", 0 ) == 0 then
			self.Weapon:SetVar( "interrupt", 1 )
		end

		return false
	end

	return self.BaseClass.CanPrimaryAttack(self.Weapon)
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:SpecialReload()
	if self.Owner.Reloading then return true end

	self.Owner.Reloading = true

	self.Weapon:SetVar( "reloadtimer", CurTime() + 0.4 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )

	self.Weapon:SetVar( "interrupt", 0 )

	self.Owner:SetAnimation( PLAYER_RELOAD )

	return true
end

function SWEP:Think()
	if ( self.Owner:IsOnGround() ) then
		self.Owner.HasBoosted = false
	end

	if !self.Owner.Reloading then return end
	if CurTime() < self.Weapon:GetVar( "reloadtimer", 0) then return end

	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:GetVar( "interrupt", 0 ) == 2 then
		self.Owner.Reloading = false
		self.Weapon:SetNextPrimaryFire( CurTime() + .4 )
		return
	end

	self.Weapon:SetVar( "reloadtimer", CurTime() + 0.4 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )

	self.Owner:SetAnimation( PLAYER_RELOAD )

	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
	self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )

	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:GetVar( "interrupt", 0 ) == 1 then
		self.Weapon:SetVar( "interrupt", 2 )
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
	end
end
