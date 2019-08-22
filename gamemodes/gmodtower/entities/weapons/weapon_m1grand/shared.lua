
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "M1 Garand"
SWEP.Slot		 	 = 4
SWEP.SlotPos		 = 0

SWEP.ViewModel		 = "models/weapons/v_pvp_m1.mdl"
SWEP.WorldModel		 = "models/weapons/w_pvp_m1.mdl"
SWEP.ViewModelFlip	 = false
SWEP.HoldType		 = "ar2"

SWEP.AutoReload		 = false

SWEP.Primary.Delay	 = 0.55
SWEP.Primary.Automatic	 = false
SWEP.Primary.Damage	 = {30, 40}
SWEP.Primary.Cone	 = 0.001
SWEP.Primary.Recoil	 	= 5
SWEP.Primary.ClipSize	 = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Ammo	 = "SniperRound"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/Garand/garand_shoot.wav"
SWEP.Primary.SoundFinal	 = "GModTower/pvpbattle/Garand/garand_empty.wav"

SWEP.SoundReload	 = "GModTower/pvpbattle/Garand/garand_reload.wav"

SWEP.Secondary.Delay	 = 0.5

SWEP.Ricochet		 = 1

SWEP.Description = "Built for the armed forces and used heavily in WW2, this rifle is one of the oldest.  Quick reload, a small spread, and a small ricochet are only the details."
SWEP.StoreBuyable = true
SWEP.StorePrice = 600

/*SWEP.IronSightsPos = Vector (-6.9382, -7.8342, 5.0538)
SWEP.IronSightsAng = Vector (0.5454, 0.108, -0.1055)*/

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound( self.Primary.Sound )
	GtowerPrecacheSound( self.Primary.SoundFinal )
	GtowerPrecacheSound( self.SoundReload )
end

function SWEP:SpecialReload()
	return self:Clip1() > 0
end

function SWEP:ShootEffects(sound, viewpunch, effect, anim)
	if self:Clip1() == 1 then
		sound = self.Primary.SoundFinal
	end

	self.BaseClass.ShootEffects(self.Weapon, sound, viewpunch, effect, anim)
end

/*function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	self:ShootZoom()
end*/

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:GetViewModelPosition( pos, ang )
	local right	= ang:Right()
	local up	= ang:Up()
	pos		= pos + up * 0.5
	ang:RotateAroundAxis(up, -4)
	ang:RotateAroundAxis(right, -2)

	return self.BaseClass.GetViewModelPosition(self.Weapon, pos, ang)
end
