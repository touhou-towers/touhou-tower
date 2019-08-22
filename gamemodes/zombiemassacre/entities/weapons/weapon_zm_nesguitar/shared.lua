
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Retro Guitar"

SWEP.WorldModel				= Model( "models/weapons/w_2ds_rguitar.mdl" )
SWEP.HoldType				= "melee2"

SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 125
SWEP.Primary.Delay			= 0.45

SWEP.MaxDurability			= 8
SWEP.IsMelee				= true

SWEP.SoundMHitW				= { Sound( "GModTower/zom/weapons/rguitar/GuitarGround1.wav" ),
								Sound( "GModTower/zom/weapons/rguitar/GuitarGround2.wav" ),
								Sound( "GModTower/zom/weapons/rguitar/GuitarGround3.wav" ),
								Sound( "GModTower/zom/weapons/rguitar/GuitarGround4.wav" ) }

SWEP.SoundMHitP				= {	Sound( "GModTower/zom/weapons/rguitar/Guitar1.wav" ),
								Sound( "GModTower/zom/weapons/rguitar/Guitar2.wav" ),
								Sound( "GModTower/zom/weapons/rguitar/Guitar3.wav" ),
								Sound( "GModTower/zom/weapons/rguitar/Guitar4.wav" ) }

SWEP.SoundMMiss				= {	Sound( "GModTower/zom/weapons/rguitar/GuitarMiss1.wav" ),
								Sound( "GModTower/zom/weapons/rguitar/GuitarMiss2.wav" ) }
					
function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return true end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootMelee( self.Primary.Damage, self.SoundMHitW, self.SoundMHitP, self.SoundMMiss, "StunstickImpact", "gib_bloodemitter" )
end