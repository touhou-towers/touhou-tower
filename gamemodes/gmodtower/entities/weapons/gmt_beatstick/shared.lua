
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Admin Beat Stick"
SWEP.Slot				= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= "models/weapons/v_stunstick.mdl"
SWEP.WorldModel			= "models/weapons/w_stunbaton.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Force		= 1500
SWEP.Primary.Delay		= 0.30

SWEP.Secondary.Delay	= 1.25

SWEP.StunHit			= {	"weapons/stunstick/stunstick_impact1.wav",
							"weapons/stunstick/stunstick_impact2.wav" }
SWEP.StunHitFlesh		= {	"weapons/stunstick/stunstick_fleshhit1.wav",
							"weapons/stunstick/stunstick_fleshhit2.wav" }
SWEP.StunMiss			= {	"weapons/stunstick/stunstick_swing1.wav",
							"weapons/stunstick/stunstick_swing2.wav" }

SWEP.HoldType			= "melee"


function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:Precache()
	GtowerPrecacheSoundTable(self.StunHitFlesh)
	GtowerPrecacheSoundTable(self.StunMiss)
	GtowerPrecacheSoundTable(self.StunHit)
	GtowerPrecacheSoundTable(self.Taunts)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self:BeatRagdoll( self.Primary.Force, self.StunHit, self.StunHitFlesh, self.StunMiss )
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	if CLIENT then return end
	local taunt = "GModTower/admin/Taunts"..math.random(1,32)..".wav"
	self.Owner:EmitSound( taunt )
end

function SWEP:BeatRagdoll( force, hitworld_sound, hitply_sound, miss_sound )
	local mdmg = 0

	if type(dmg) == "table" then
		mdmg = math.random(dmg[1],dmg[2])
	else
		mdmg = dmg
	end

	local trace = util.TraceHull({start=self.Owner:GetShootPos(),
			endpos=self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50,
			mins=Vector(-8, -8, -8), maxs=Vector(8, 8, 8),
			filter=self.Owner})

	local sound = miss_sound
	if trace.Hit then
		if IsValid(trace.Entity) && trace.Entity:IsPlayer() then
			sound = hitply_sound
		else
			sound = hitworld_sound
		end
	end

	if sound && IsFirstTimePredicted() then
		if type(sound) == "table" then
			self.Weapon:EmitSound( sound[math.random(1, #sound)] )
		else
			self.Weapon:EmitSound( sound )
		end
	end

	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if SERVER && IsValid(trace.Entity) then
		local bdmg = 0

		if type(dmg) == "table" then
			bdmg	= math.random(dmg[1],dmg[2])
		else
			bdmg	= dmg
		end

		if trace.Entity:IsPlayer() then
			trace.Entity:SetVelocity( self.Owner:GetAimVector() * force, 0 )
		else
			local phys = trace.Entity:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity( self.Owner:GetVelocity() + (self.Owner:GetAimVector() * force) )
			end
		end
	end
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
