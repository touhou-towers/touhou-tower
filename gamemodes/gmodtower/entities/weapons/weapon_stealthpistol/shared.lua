
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair	= false
end

SWEP.PrintName 		 = "Stealth Pistol"
SWEP.Slot		 = 1
SWEP.SlotPos		 = 2

SWEP.ViewModel			 = "models/weapons/v_pvp_sp.mdl"
SWEP.WorldModel			 = "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip		 = false
SWEP.HoldType			 = "pistol"

SWEP.Primary.Delay	 = 0.2
SWEP.Primary.Damage	 = {12, 18}
SWEP.Primary.Cone	 = 0.04
SWEP.Primary.ClipSize	 = 14
SWEP.Primary.DefaultClip = 14
SWEP.Primary.Ammo	 = "Pistol"
SWEP.Primary.Sound	 = "GModTower/pvpbattle/StealthPistol/StealthPistolFire.wav"

SWEP.SoundReload	 = "GModTower/pvpbattle/StealthPistol/StealthPistolReload.wav"

GtowerPrecacheModel( SWEP.ViewModel )
GtowerPrecacheModel( SWEP.WorldModel )

SWEP.Description = "Crouch down and go Predator while your enemies seek your presence.  Slowly take each one out with this precise laser-guided pistol."
SWEP.StoreBuyable = true
SWEP.StorePrice = 380

if CLIENT then
	SWEP.StealthMat = Material("models/gmod_tower/pvpbattle/stealth")
end

function SWEP:Precache()
	GtowerPrecacheSound( self.Primary.Sound )
	GtowerPrecacheSound( self.SoundReload )
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:SpecialReload()
	self:CloakOff()
end

function SWEP:Think()
	if CLIENT then return end

	if self.Owner:Crouching() && self.Owner:GetVelocity():Length() == 0 &&
	   self.Owner:IsOnGround() && self.Owner.PowerUp == 0 then
		self:CloakOn()
	else
		self:CloakOff()
	end

	self:NextThink( CurTime() + 1 )
	return true
end


function SWEP:Holster()
	self:CloakOff()
	return true
end

function SWEP:OnRemove()
	self:CloakOff()
end

function SWEP:CloakOn()
	if !self.Cloaked then
		self.Cloaked = true
		PostEvent( self.Owner, "cloak_on" )
		self.Owner:SetMaterial( "models/gmod_tower/pvpbattle/stealth" )
		if CLIENT then self.Owner:DrawShadow( false ) end
		self:SetNoDraw( true )
	end
end

function SWEP:CloakOff()
	if self.Cloaked then
		self.Cloaked = false
		PostEvent( self.Owner, "cloak_off" )
		self.Owner:SetMaterial( "" )
		if CLIENT then self.Owner:DrawShadow( true ) end
		self:SetNoDraw( false )
	end
end