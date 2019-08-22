
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	= false
end

SWEP.PrintName 			= "Fists"
SWEP.Slot			= 0
SWEP.SlotPos			= 1
SWEP.Wait = false

SWEP.ViewModel			= "models/weapons/v_pvp_ire.mdl"
SWEP.WorldModel			= "models/weapons/w_pvp_ire.mdl"
SWEP.ViewModelFlip		= false
SWEP.HoldType			= "fist"

SWEP.Primary.Automatic		= true
SWEP.Primary.UnlimAmmo		= true
SWEP.Primary.Damage		= {100, 125}
SWEP.Primary.Delay		= 0.35

SWEP.CrosshairDisabled	 	= true
SWEP.FistHit			= 	"GModTower/pvpbattle/Rage/RageHit.wav"
SWEP.FistHitFlesh		= {	"GModTower/pvpbattle/Rage/RageFlesh1.wav",
					"GModTower/pvpbattle/Rage/RageFlesh2.wav",
					"GModTower/pvpbattle/Rage/RageFlesh3.wav",
					"GModTower/pvpbattle/Rage/RageFlesh4.wav" }
SWEP.FistMiss			= {	"GModTower/pvpbattle/Rage/RageMiss1.wav",
					"GModTower/pvpbattle/Rage/RageMiss2.wav"  }

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

function SWEP:Precache()
	GtowerPrecacheSound(self.FistHit)
	GtowerPrecacheSoundTable(self.FistHitFlesh)
	GtowerPrecacheSoundTable(self.FistMiss)
end

function SWEP:PrimaryAttack()

	if string.StartWith(game.GetMap(),"gmt_build") and !self.Owner.ActiveDuel and !self.Owner:IsAdmin() then self.Primary.Damage = 0 end

	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:ShootMelee( self.Primary.Damage, self.FistHit, self.FistHitFlesh, self.FistMiss )
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	if !string.StartWith(game.GetMap(),"gmt_build") or !self.Owner:IsAdmin() then return end

	if not IsFirstTimePredicted() then return end
	if (self.Wait) then return end
	self.Wait = true
	timer.Simple(20,function() self.Wait = false end)
	self.Owner:EmitSound("gmodtower/pvpbattle/rage.mp3")
end

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end
