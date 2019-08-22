
if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType		= "normal"

SWEP.PrintName		= "Rabbit Exterminator"
SWEP.Slot		= 3
SWEP.SlotPos		= 1


SWEP.Base		= "weapon_base"

SWEP.Spawnable		= true
SWEP.AdminSpawnable	= true

SWEP.ViewModel		= ""
SWEP.WorldModel		= ""

SWEP.Weight		= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false

SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo	= "none"

SWEP.Secondary.Automatic= false
SWEP.Secondary.Ammo	= "none"

SWEP.LoopSound = "weapons/rpg/rocket1.wav"

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

	RegisterNWTable(self, { {"FlameN", false, NWTYPE_BOOL, REPL_EVERYONE} })
end

function SWEP:Deploy()
	self.FlameN = false
	self.FlameDamage = CurTime()

	self:SendWeaponAnim(ACT_VM_DEPLOY)

	self.Owner:DrawViewModel(false)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime())

	if SERVER then
		self.FlameN = true
	end

	self.FlameDamage = CurTime()
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:Reload()
	return false
end

if SERVER then

function SWEP:Think()
	if !self.Owner:KeyDown(IN_ATTACK) then
		self.FlameN = false
		return
	end

	if !self.FlameDamage then
		self.FlameDamage = CurTime()
	end

	if CurTime() < self.FlameDamage + 0.5 then return end

	local shootpos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()

	local trace = util.TraceLine({start=shootpos, endpos=shootpos + (dir * 250), filter=self.Owner})

	if IsValid(trace.Entity) && trace.Entity:IsPlayer() && trace.Entity:IsRabbit() && trace.Entity:Alive() then
		if trace.Entity:IsAdmin() then
			trace.Entity = self.Owner
		end

		trace.Entity:Ignite(90)
		trace.Entity:TakeDamage(10, self.Owner)

		trace.Entity.HitByFlamethrower = self.Owner
	end

	self.FlameDamage = CurTime()
end

hook.Add("DoPlayerDeath", "FTCharple", function(ply /*, attacker, dmginfo */)
	if IsValid( ply.HitByFlamethrower ) then
		local Attacker = ply.HitByFlamethrower
		ply:Extinguish()
		ply:SetModel("models/player/charple01.mdl")
		ply.HitByFlamethrower = nil

		if Attacker != ply && IsValid(Attacker) then
			umsg.Start( "PlayerKilledByPlayer" )
				umsg.Entity( ply )
				umsg.String( "Rab.Ext." )
				umsg.Entity( Attacker )
			umsg.End()
		end

		//Does not work D:
		//if dmginfo then
		//	dmginfo:SetAttacker( Attacker )
		//end
	end
end)

else

function SWEP:OnRemove()
	if self.Emitter then
		self.Emitter:Finish()
		self.Emitter = nil
	end

	if self.FlameSound then
		self.FlameSound:FadeOut(0.1)
	end
end

function SWEP:Think()
	local flame = self.FlameN

	if flame == false && !self.Emitter then return end

	if (self.Owner == LocalPlayer() && !self.Owner:KeyDown(IN_ATTACK)) || (self.Emitter && !flame) then
		if self.Emitter then
			self.Emitter:Finish()
			self.Emitter = nil
			self.FlameSound:FadeOut(0.5)
		end
		return
	end

	local dir = self.Owner:GetAimVector()
	local shootpos = self.Owner:EyePos()

	if !self.FlameSound then
		self.FlameSound = CreateSound(self.Owner, self.LoopSound)
	end

	if !self.Emitter then
		self.Emitter = ParticleEmitter(shootpos)
		self.Flame = CurTime()
		self.FlameSound:PlayEx(1, 200)
	end

	if CurTime() < self.Flame + 0.01 then return end



	for i=1, 5 do
		local particle = self.Emitter:Add("particles/flamelet" .. math.random(1, 5), shootpos)
		if particle then
			particle:SetPos(shootpos + (dir * i * 5))
			particle:SetVelocity(dir * (200 + math.random() * 200))
			particle:SetLifeTime(0)
			particle:SetDieTime(0.6)
			particle:SetStartSize(2)
			particle:SetEndSize(16)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetRoll(math.Rand(-10, 10))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetCollide(true)
			particle:SetBounce(0.2)
		end
	end

	self.Flame = CurTime()
end

function SWEP:DrawWorldModel()
	self.Weapon:DrawModel()
	self:Think()
end

end
