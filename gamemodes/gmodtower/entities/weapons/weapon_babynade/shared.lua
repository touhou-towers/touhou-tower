
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Babynade"
SWEP.Slot		 = 5
SWEP.SlotPos		 = 0

SWEP.ViewModel			 = "models/weapons/v_pvp_babynade.mdl"
SWEP.WorldModel			 = "models/props_c17/doll01.mdl"
SWEP.ViewModelFlip		 = false
SWEP.HoldType			 = "grenade"

SWEP.AutoReload		 = true

SWEP.Primary.Delay	 = 1.6
SWEP.Primary.Cone	 = 0
SWEP.Primary.ClipSize	 = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo	 = "SMG1_Grenade"

SWEP.Secondary		 = SWEP.Primary

SWEP.SoundDeploy	 = "ambient/creatures/teddy.wav"

SWEP.Throw		 = 0
SWEP.ThrowHard		 = false
SWEP.ThrowMode		 = 0

SWEP.Description = "Use care when planning, as the explosion is quite deadly."
SWEP.StoreBuyable = true
SWEP.StorePrice = 625

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound( self.SoundDeploy )
end

function SWEP:Deploy()
	self.Throw = 0

	return self.BaseClass.Deploy(self.Weapon)
end

function SWEP:CanPrimaryAttack()
	return self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0
end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then
		if !SERVER then return end
		
		self.Owner:SwitchToNextWeapon() 
		return
	end
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	

	self.Throw = CurTime()
	self.ThrowHard = true
	self.ThrowMode = 0

	self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH )

	self:Reload()
end


function SWEP:SecondaryAttack()

	if ( !self:CanPrimaryAttack() ) then
		if !SERVER then return end
		
		self.Owner:SwitchToNextWeapon() // we're out of ammo, lets switch weapons
		return
	end
	
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self.Throw = CurTime()
	self.ThrowHard = false
	self.ThrowMode = 0

	self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH )

	self:Reload()
	
end

function SWEP:Think()
	if self.Throw == 0 then return end

	if CurTime() >= self.Throw + 0.5 && self.ThrowMode == 0 then

		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		self.Weapon:SendWeaponAnim( ACT_VM_THROW )
		
		if SERVER then
			local force = 200

			if self.ThrowHard then
				force = 2250
			end
			
			self:ShootEnt( "pvp_babynade", force )
		end
		
		self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )

		self.ThrowMode = 1

	elseif CurTime() >= self.Throw + 0.75 && self.ThrowMode == 1 then

		self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
		self.Throw = 0

	end
	
end

function SWEP:Reload()
	return false
end