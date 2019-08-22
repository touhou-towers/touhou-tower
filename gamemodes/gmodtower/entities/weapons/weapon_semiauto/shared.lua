
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 = "Semi-auto Glock"
SWEP.Slot		 = 2
SWEP.SlotPos		 = 0

SWEP.ViewModel			 = "models/weapons/v_pvp_semiauto.mdl"
SWEP.WorldModel			 = "models/weapons/w_pvp_semiauto.mdl"
SWEP.HoldType			 = "pistol"

SWEP.Primary.Automatic	 = true
SWEP.Primary.Delay	 = 0.1
SWEP.Primary.Damage	 = {12, 18}
SWEP.Primary.Cone	 = 0.015
SWEP.Primary.ClipSize	 = 18
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Ammo	 = "SMG1"
SWEP.Primary.Sound	 = {"GModTower/pvpbattle/SemiAuto/SemiFire1.wav",
			    "GModTower/pvpbattle/SemiAuto/SemiFire2.wav"}

SWEP.SoundDeploy	 = "GModTower/pvpbattle/SemiAuto/SemiDeploy.wav"

SWEP.Shots		= 0
SWEP.ResetNext		= false

SWEP.Description = "Simple design, deadly results. Just fire like normal and let three bullets do the talking."
SWEP.StoreBuyable = true
SWEP.StorePrice = 0

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound(self.SoundDeploy)
	GtowerPrecacheSoundTable(self.Primary.Sound)
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:SpecialReload()
	if IsFirstTimePredicted() then
		self.Shots = 0
	end
end

function SWEP:PrimaryAttack()
	if self.BaseClass.PrimaryAttack(self.Weapon) then return end

	if IsFirstTimePredicted() then
		if self.ResetNext then
			self.Shots = 0
			self.ResetNext = false
		end
		self.Shots = self.Shots + 1
	end

	if self.Shots == 3 then
		self:SetNextPrimaryFire( CurTime() + 0.5 )

		if IsFirstTimePredicted() then
			self.ResetNext = true
		end

	elseif self.Shots > 3 then
		return false
	end
end
