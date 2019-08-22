
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Medieval Sword"

SWEP.WorldModel				= Model( "models/weapons/w_2hsword.mdl" )
SWEP.HoldType				= "melee2"

SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 200
SWEP.Primary.Delay			= 0.6

SWEP.MaxDurability			= 12
SWEP.IsMelee				= true

SWEP.SoundMHitP				= {	Sound( "GModTower/zom/weapons/sword/sword_hitflesh1.wav" ),
								Sound( "GModTower/zom/weapons/sword/sword_hitflesh2.wav" ) }

SWEP.SoundMHitW				= { Sound( "GModTower/zom/weapons/sword/sword_hit1.wav" ),
								Sound( "GModTower/zom/weapons/sword/sword_hit2.wav" ) }

SWEP.SoundMMiss				= {	Sound( "GModTower/zom/weapons/sword/sword_swing1.wav" ),
								Sound( "GModTower/zom/weapons/sword/sword_swing2.wav" ),
								Sound( "GModTower/zom/weapons/sword/sword_swing3.wav" ) }


function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return true end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	self:ShootMelee( self.Primary.Damage, self.SoundMHitW, self.SoundMHitP, self.SoundMMiss, "StunstickImpact" )

end