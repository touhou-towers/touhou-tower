
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Katana"

SWEP.WorldModel				= Model( "models/weapons/w_shanasw.mdl" )
SWEP.HoldType				= "melee2"

SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 125
SWEP.Primary.Delay			= 0.2

SWEP.MaxDurability			= 15
SWEP.IsMelee				= true
SWEP.Tier 					= DropManager.UNCOMMON

SWEP.SoundMHitP				= {	Sound( "GModTower/pvpbattle/Sword/SwordFlesh1.wav" ),
								Sound( "GModTower/pvpbattle/Sword/SwordFlesh2.wav" ),
								Sound( "GModTower/pvpbattle/Sword/SwordFlesh3.wav" ),
								Sound( "GModTower/pvpbattle/Sword/SwordFlesh4.wav" )  }

SWEP.SoundMHitW				= Sound( "GModTower/pvpbattle/Sword/SwordHit.wav" )

SWEP.SoundMMiss				= {	Sound( "GModTower/pvpbattle/Sword/SwordMiss1.wav" ),
								Sound( "GModTower/pvpbattle/Sword/SwordMiss2.wav" ) }


function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return true end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootMelee( self.Primary.Damage, self.SoundMHitW, self.SoundMHitP, self.SoundMMiss, "StunstickImpact" )
end