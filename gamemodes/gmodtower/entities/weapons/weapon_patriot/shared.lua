
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	= false
end

SWEP.PrintName 		 = "Patriot"
SWEP.Slot		 = 5
SWEP.SlotPos		 = 2

SWEP.ViewModel			 = "models/weapons/v_pvp_patriotmg.mdl"
SWEP.WorldModel			 = "models/weapons/w_pvp_patriotmg.mdl"
SWEP.ViewModelFlip		 = false
SWEP.HoldType			 = "ar2"

SWEP.Primary.Automatic	 = true
SWEP.Primary.UnlimAmmo	 = true
SWEP.Primary.Delay	 = 0.15
SWEP.Primary.Damage	 = {3, 5}
SWEP.Primary.Sound	 = "GModTower/pvpbattle/Patriot/PatriotFire.wav"

SWEP.SoundDeploy	 = "GModTower/pvpbattle/Patriot/PatriotDeploy.wav"

SWEP.HitEffect		 = "karparblood"

SWEP.Description = "Want more Snake in your life? This gun is dedicated to anyone who enjoys shooting like crazy. Ammo is unlimited, but damage is very low."
SWEP.StoreBuyable = true
SWEP.StorePrice = 60

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound(self.Primary.Sound)
	GtowerPrecacheSound(self.SoundDeploy)
	GtowerPrecacheSound("GModTower/pvpbattle/Patriot/PatriotKill.wav")
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

function SWEP:ShootEffects(sound, recoil)

	self.BaseClass.ShootEffects(self.Weapon, sound, recoil)
		
	if SERVER && !self.Owner:IsOnGround() then
	
		if gamemode.Get( "virus" ) then return end // no boosting in virus
		
		self.Owner:SetVelocity( self.Owner:GetAimVector() * -85, 0 )
	end
end