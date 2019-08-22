
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Thompson"
SWEP.Slot		 = 4
SWEP.SlotPos		 = 1

SWEP.ViewModel			 = "models/weapons/v_pvp_tom.mdl"
SWEP.WorldModel			 = "models/weapons/w_pvp_tom.mdl"
SWEP.ViewModelFlip		 = true
SWEP.HoldType			 = "ar2"

SWEP.Primary.Automatic	 = true
SWEP.Primary.Delay	 = 0.10
SWEP.Primary.Damage	 = {10, 18}
SWEP.Primary.Cone	 = 0.025
SWEP.Primary.ClipSize	 = 25
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Ammo	 = "AR2"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/Thompson/ThompsonFire.wav"

SWEP.SoundReload	 = "GModTower/pvpbattle/Thompson/ThompsonReload.wav"
SWEP.SoundDeploy	 = "GModTower/pvpbattle/Thompson/ThompsonDeploy.wav"

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )


SWEP.Description = "Go back in time to prohibition and show those to fear the original portable machine gun.  Force them to make pay as you, a true gansta, puts holes in them like-a swiss cheese."
SWEP.StoreBuyable = true
SWEP.StorePrice = 0

function SWEP:Precache()
	GtowerPrecacheSound(self.Primary.Sound)
	GtowerPrecacheSound(self.SoundDeploy)
	GtowerPrecacheSound(self.SoundReload)
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:GetViewModelPosition( pos, ang )
	local right	= ang:Right()
	local up	= ang:Up()
	pos		= pos + up * 0.5
	ang:RotateAroundAxis(up, -5)
	ang:RotateAroundAxis(right, -1)
	return pos, ang
end
