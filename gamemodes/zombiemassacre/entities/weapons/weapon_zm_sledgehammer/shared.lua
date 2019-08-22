
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Sledge Hammer"

SWEP.WorldModel				= Model( "models/weapons/melee/w_sledgehammer.mdl" ) // model is off!
SWEP.HoldType				= "melee2"

SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 200
SWEP.Primary.Delay			= .75

SWEP.MaxDurability			= 10
SWEP.IsMelee				= true

SWEP.SoundMHitP				= Sound( "GModTower/zom/weapons/sledgehammer/hit.wav" )

SWEP.SoundMHitW				= Sound( "GModTower/zom/weapons/sledgehammer/hitworld.wav" )

SWEP.SoundMMiss				= {	Sound( "GModTower/zom/weapons/baseballbat/BatMiss1.wav" ),
								Sound( "GModTower/zom/weapons/baseballbat/BatMiss2.wav" ) }


function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return true end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootMelee( self.Primary.Damage, self.SoundMHitW, self.SoundMHitP, self.SoundMMiss, "StunstickImpact", "gib_bloodemitter" )

end