
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Rocket Launcher"

SWEP.WorldModel				= Model( "models/Weapons/w_rocket_launcher.mdl" )
SWEP.HoldType				= "rpg"

SWEP.Primary.ClipSize		= 3
SWEP.Primary.Delay			= 2
SWEP.Primary.Cone			= 0

SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/rpg_fire.wav" )
SWEP.Primary.Force			= 600

SWEP.Offsets				= nil

SWEP.Tier					= DropManager.RARE

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return true end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootEffects( self.Primary.Sound, self.Primary.Effect, self.Primary.Force )
	self:TakePrimaryAmmo( 1 )

	if CLIENT then return end
	self:ShootEnt( "zm_rpg_regular", nil )	
end