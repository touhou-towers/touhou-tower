
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "SPAS Shotgun"

SWEP.WorldModel				= Model( "models/weapons/w_shotspas12z.mdl" )
SWEP.HoldType				= "shotgun"

SWEP.Primary.ClipSize		= 16
SWEP.Primary.Automatic		= false
SWEP.Primary.Delay			= 0.3
SWEP.Primary.Cone			= 0.09
SWEP.Primary.NumShots		= 16

SWEP.Primary.Damage			= { 10, 15 }
SWEP.Primary.Sound			= Sound( "GModTower/pvpbattle/Spas12/Spas12Fire.wav" )

SWEP.PumpedTime				= 0
SWEP.SoundPump				= Sound( "GModTower/pvpbattle/Spas12/Spas12Pump.wav" )

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return true end

	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Trace )
	self:ShootEffects( self.Primary.Sound, self.Primary.Effect )

	self:TakePrimaryAmmo( 1 )
end

function SWEP:CanPrimaryAttack()
	if self.Weapon:Clip1() > 0 && ( self.Weapon:GetVar( "needspump", false ) || CurTime() == self.PumpedTime) then
		self:EmitSound( self.SoundPump )

		if IsFirstTimePredicted() then
			self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

			self.PumpedTime = CurTime()
			self.Weapon:SetVar( "needspump", false )
		end

		return false
	elseif IsFirstTimePredicted() then
		self.Weapon:SetVar( "needspump", true )
	end

	return self.BaseClass:CanPrimaryAttack()
end