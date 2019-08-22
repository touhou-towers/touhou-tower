
-----------------------------------------------------
SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
else
	SWEP.ViewModelFlip		= false
end

//Basic Setup
SWEP.PrintName				= "Double Barrel Shotgun"
SWEP.Slot					= 3

//Types
SWEP.HoldType				= "shotgun"
SWEP.GunType				= "shotgun"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel				= Model("models/weapons/v_vir_doubleb.mdl")
SWEP.WorldModel				= Model("models/weapons/w_vir_doubleb.mdl")

//Primary
SWEP.Primary.ClipSize		= 2
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Ammo			= "buckshot"
SWEP.Primary.Delay			= 0.5
SWEP.Primary.Recoil	 		= 2
SWEP.Primary.Cone			= 0.08
SWEP.Primary.Damage			= { 15, 20 }
SWEP.Primary.NumShots		= 8

//Secondary
SWEP.Secondary.ClipSize		= 2
SWEP.Secondary.DefaultClip	= 2
SWEP.Secondary.Ammo			= "buckshot"
SWEP.Secondary.Delay		= 0.5
SWEP.Secondary.Recoil	 	= 2
SWEP.Secondary.Cone			= 0.16
SWEP.Secondary.Damage		= { 15, 20 }
SWEP.Secondary.NumShots		= 16
SWEP.Secondary.AmmoAmount	= 2

//Parameters
SWEP.AutoReload				= false
SWEP.ReloadDelay			= 0.6

//Sounds
SWEP.Primary.Sound = Sound("GModTower/virus/weapons/DoubleBarrel/shoot.wav")
SWEP.Secondary.Sound = Sound("GModTower/virus/weapons/DoubleBarrel/shoot.wav")
SWEP.ExtraSounds = {
	ReloadStart = Sound("GModTower/virus/weapons/DoubleBarrel/reload_start.wav"),
	ReloadPump = Sound("GModTower/virus/weapons/DoubleBarrel/shell_insert.wav"),
	ReloadEnd = Sound("GModTower/virus/weapons/DoubleBarrel/reload_finish.wav")
}

function SWEP:CanPrimaryAttack()

	if self.Owner.Reloading then

		if self:GetVar( "interrupt", 0 ) == 0 then
			self:SetVar( "interrupt", 1 )
		end

		return false

	end

	return self.BaseClass.CanPrimaryAttack( self )

end

function SWEP:SpecialReload()

	//if self:Clip1() > 0 then return true end
	if self.Owner.Reloading then return true end

	self.Owner._Shell = 0
	self.Owner.Reloading = true

	self:SetVar( "reloadtimer", CurTime() + self.ReloadDelay )

	self:SendWeaponAnim( ACT_VM_RELOAD )
	self:EmitSound( self.ExtraSounds.ReloadStart )

	self:SetVar( "interrupt", 0 )

	self.Owner:SetAnimation( PLAYER_RELOAD )

	return true

end

function SWEP:Think()

	if !IsValid( self.Owner ) || !self.Owner.Reloading then return end

	if CurTime() < self:GetVar( "reloadtimer", 0) then return end

	if self:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self:GetVar( "interrupt", 0 ) == 2 then

		self.Owner.Reloading = false
		self:SetNextPrimaryFire( CurTime() + self.ReloadDelay )
		return

	end

	self:SetVar( "reloadtimer", CurTime() + self.ReloadDelay )

	self:SendWeaponAnim( ACT_VM_RELOAD )
	self.Owner:SetAnimation( PLAYER_RELOAD )
	self:EmitSound( self.ExtraSounds.ReloadPump, 100, math.random( 90, 100 ) )

	self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
	self:SetClip1(  self:Clip1() + 1 )

	if self:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 || self:GetVar( "interrupt", 0 ) == 1 then

		self:SetVar( "interrupt", 2 )
		self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
		self:EmitSound( self.ExtraSounds.ReloadEnd )

	end

end

function SWEP:CanSecondaryAttack() 

	if self.Owner.Reloading then

		if self:GetVar( "interrupt", 0 ) == 0 then
			self:SetVar( "interrupt", 1 )
		end

		return false

	end

	return self.BaseClass.CanPrimaryAttack( self )

end