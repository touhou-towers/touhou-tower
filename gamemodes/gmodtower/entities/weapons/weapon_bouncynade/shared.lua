
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Rubber Grenade"
SWEP.Slot		 = 5
SWEP.SlotPos		 = 1

SWEP.ViewModel			 = "models/weapons/v_eq_fraggrenade.mdl"
SWEP.WorldModel			 = "models/weapons/w_eq_fraggrenade.mdl"
SWEP.HoldType			 = "grenade"

SWEP.AutoReload		 = true

SWEP.Primary.Delay	 = 2
SWEP.Primary.ClipSize	 = 0
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo	 = "slam"
SWEP.AutoReload		 = true

SWEP.AnimDeploy 	 = ACT_VM_IDLE

SWEP.Throw		 = 0
SWEP.ThrowMode		 = 0

SWEP.Description = "Throw down and watch it bounce."
SWEP.StoreBuyable = true
SWEP.StorePrice = 0

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:CanPrimaryAttack()
	return self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self.Throw = CurTime()
	self.ThrowMode = 0

	self.Weapon:SendWeaponAnim( ACT_VM_THROW )

	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )

	self:Reload()	
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Think()
	if self.Throw == 0 then return end

	if CurTime() >= self.Throw + 0.5 && self.ThrowMode == 0 then

		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		if SERVER then
			self:ShootEnt( "pvp_bouncynade", 500 )
		end

		self.ThrowMode = 1

	elseif CurTime() >= self.Throw + 0.525 && self.ThrowMode == 1 then

		self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
		self.Throw = 0

	end
end

function SWEP:Reload()
	return false
end