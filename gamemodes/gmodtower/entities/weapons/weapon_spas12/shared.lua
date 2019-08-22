
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "SPAS-12"
SWEP.Slot		 = 3
SWEP.SlotPos		 = 1

SWEP.ViewModel		 = "models/weapons/v_pvp_s12.mdl"
SWEP.WorldModel		 = "models/weapons/w_pvp_s12.mdl"
SWEP.ViewModelFlip	 = false
SWEP.HoldType		 = "shotgun"
SWEP.AutoReload		 = false

SWEP.Primary.Delay	 = 0.3
SWEP.Primary.Damage	 = {8, 10}
SWEP.Primary.Cone	 = 0.09
SWEP.Primary.NumShots	 = 6
SWEP.Primary.ClipSize	 = 6
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Ammo	 = "Buckshot"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/Spas12/Spas12Fire.wav"

SWEP.Secondary.Delay	 = 0.5

SWEP.SoundPump		 = "GModTower/pvpbattle/Spas12/Spas12Pump.wav"
SWEP.SoundInsert	 = "GModTower/pvpbattle/Spas12/Spas12InsertShell.wav"

SWEP.PumpedTime		 = 0

SWEP.Description = "Typical shotgun with low spread. Each shell must be pumped (just use primary) after loading, so this shotgun takes more time to use."
SWEP.StoreBuyable = true
SWEP.StorePrice = 360

SWEP.IronSightsPos = Vector (-8.9445, -8.7188, -0.4974)
SWEP.IronSightsAng = Vector (-1.7418, 0.0104, 0.001)


GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound( self.Primary.Sound )
	GtowerPrecacheSound( self.SoundPump )
	GtowerPrecacheSound( self.SoundInsert )
end

function SWEP:CanPrimaryAttack()
	if self.Owner.Reloading then
		if self.Weapon:GetVar( "interrupt", 0 ) == 0 then
			self.Weapon:SetVar( "interrupt", 1 )
		end

		return false
	end

	if self.Weapon:Clip1() > 0 && ( self.Weapon:GetVar( "needspump", false ) || CurTime() == self.PumpedTime) then
		self:EmitSound( self.SoundPump )
		self:SendWeaponAnim( ACT_SHOTGUN_PUMP )

		if IsFirstTimePredicted() then
			self:SetNextPrimaryFire( CurTime() + 0.3 )

			self.PumpedTime = CurTime()
			self.Weapon:SetVar( "needspump", false )
		end

		return false
	elseif IsFirstTimePredicted() then
		self.Weapon:SetVar( "needspump", true )
	end

	return self.BaseClass.CanPrimaryAttack(self.Weapon)
end

function SWEP:SpecialReload()
	if self.Owner.Reloading then return true end

	self.Owner.Reloading = true

	self.Weapon:SetVar( "reloadtimer", CurTime() + 0.3 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )

	self.Weapon:SetVar( "interrupt", 0 )
	self.Weapon:SetVar( "needspump", true )

	self.Owner:SetAnimation( PLAYER_RELOAD )

	return true
end

function SWEP:Think()
	if !self.Owner.Reloading then return end
	if CurTime() < self.Weapon:GetVar( "reloadtimer", 0) then return end

	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:GetVar( "interrupt", 0 ) == 2 then
		self.Owner.Reloading = false
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 )
		return
	end

	self.Weapon:SetVar( "reloadtimer", CurTime() + 0.3 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )

	self.Owner:SetAnimation( PLAYER_RELOAD )

	self:EmitSound( self.SoundInsert )

	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
	self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
	if self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self.Weapon:GetVar( "interrupt", 0 ) == 1 then
		self.Weapon:SetVar( "interrupt", 2 )
		self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
	end
end

function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	self:ShootZoom()
end