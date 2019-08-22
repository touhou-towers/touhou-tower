
SWEP.Base					= "weapon_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.DrawCrosshair		= false
end

SWEP.PrintName 				= "Shana's Sword"
SWEP.Slot					= 0
SWEP.SlotPos				= 2

SWEP.ViewModel				= "models/weapons/v_shanasw.mdl"
SWEP.WorldModel				= "models/weapons/w_shanasw.mdl"
SWEP.ViewModelFlip			= false
SWEP.HoldType				= "melee2"

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Damage			= {35, 45}
SWEP.Primary.Delay			= 0.25

SWEP.SoundDeploy			= "GModTower/pvpbattle/Sword/SwordDeploy.wav"

SWEP.CrosshairDisabled	 	= true
SWEP.SwordHit				= "GModTower/pvpbattle/Sword/SwordHit.wav"
SWEP.SwordHitFlesh			= {	"GModTower/pvpbattle/Sword/SwordFlesh1.wav",
								"GModTower/pvpbattle/Sword/SwordFlesh2.wav",
								"GModTower/pvpbattle/Sword/SwordFlesh3.wav",
								"GModTower/pvpbattle/Sword/SwordFlesh4.wav" }
SWEP.SwordMiss				= {	"GModTower/pvpbattle/Sword/SwordMiss1.wav",
								"GModTower/pvpbattle/Sword/SwordMiss2.wav" }		

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	/*if IsFirstTimePredicted() then
		self.Weapon:EmitSound( self.SwordSwing[#self.SwordSwing] )
	end*/

	self:ShootMelee( self.Primary.Damage, self.SwordHit, self.SwordHitFlesh, self.SwordMiss )
end

function SWEP:ShootMelee( dmg, hitworld_sound, hitply_sound, miss_sound )
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

	if SERVER && IsValid(trace.Entity) && trace.Entity:IsPlayer() then
		local bdmg = 0

		if type(dmg) == "table" then
			bdmg	= math.random(dmg[1],dmg[2])
		else
			bdmg	= dmg
		end

		trace.Entity:TakeDamage(bdmg, self.Owner)
		if trace.Entity:Health() < 50 && trace.Entity:Alive() && !trace.Entity:IsAdmin() then 
			trace.Entity:Ignite(90)
			trace.Entity.HitByShana = self.Owner
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
	return false
end

function SWEP:Deploy()
	self.Owner:EmitSound(self.SoundDeploy)
	self:SendWeaponAnim( ACT_VM_DRAW )	
	if SERVER then self:Ignite(90) end
	return true
end

if CLIENT then return end


function SWEP:Think()
	if !self.Owner:Alive() then return end

	self:EmitAshes()		
	self:NextThink(CurTime() + 6)
end

function SWEP:EmitAshes()
	local edata = EffectData()
	edata:SetOrigin(self.Owner:GetPos())
	edata:SetEntity(self.Owner)

	util.Effect("shana_ashes", edata, true, true)
end

hook.Add("DoPlayerDeath", "ShanaCharple", function(ply /*, attacker, dmginfo */)
	if IsValid( ply.HitByShana ) then
		local Attacker = ply.HitByShana
		ply:Extinguish()
		ply:SetModel("models/player/charple01.mdl")
		ply.HitByShana = nil
		
		/*if Attacker != ply then
			umsg.Start( "PlayerKilledByPlayer" )
				umsg.Entity( ply )
				umsg.String( "Shana" )
				umsg.Entity( Attacker )
			umsg.End()
		end*/
	end
end)

function SWEP:Holster()
	self:Extinguish()
	return true
end