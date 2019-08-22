
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Communist Destroyer"
SWEP.Slot				= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""
SWEP.HoldType			= "normal"

SWEP.Primary.Delay		= .5
SWEP.Sounds = {}
SWEP.PlaySounds = {}
SWEP.LaserSound = Sound("GModTower/lobby/communist_destroyer/libertyprime_laser.wav")

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:Precache()
	local CurrentSound
	local SoundBase = "GModTower/lobby/communist_destroyer/voc_robotlibertyprime_combat_%s.wav"
	for i=1,27 do
		if(i >= 10) then
			CurrentSound = tostring(i)
		else
			CurrentSound = "0"..tostring(i)
		end
		CurrentSound = Sound(string.format(SoundBase, CurrentSound))
		self.Sounds[i] = {CurrentSound, SoundDuration(CurrentSound) - 1}
	end
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	self.Owner:DrawWorldModel(false)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self.Owner:ViewPunch( Angle( -20, 0, 0 ) )

	if !IsFirstTimePredicted() then return end

	if SERVER then
		self.HitPos = self.Owner:GetEyeTrace().HitPos
		self.Weapon:Laser()
		self.Weapon:Explosion()
	end	
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	self:PlaySound()
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

if CLIENT then return end
function SWEP:PlaySound()
	local Count = table.Count(self.PlaySounds)
	
	if(Count == 0) then
		self.PlaySounds = table.Copy(self.Sounds)
		return self:PlaySound()
	end
	
	local Random = math.random(1, Count)
	
	local Selection = self.PlaySounds[Random]
	self.Owner:EmitSound(Selection[1], 120)
	self.Weapon:SetNextSecondaryFire(CurTime() + Selection[2])
	
	table.remove(self.PlaySounds, Random)
end

function SWEP:Laser()
	local LaserEffect = EffectData()
	LaserEffect:SetEntity(self.Owner)
	LaserEffect:SetStart(self.Owner:EyePos())
	LaserEffect:SetOrigin(self.HitPos)
	LaserEffect:SetAttachment(self.Owner:LookupAttachment("eyes"))
	util.Effect("ToolTracer", LaserEffect, true, true)
	
	--WorldSound(self.LaserSound, self.HitPos)
	self.Owner:EmitSound(self.LaserSound, 80)
end

function SWEP:Explosion()
	local LibertyPrimeBoom = EffectData()
	LibertyPrimeBoom:SetOrigin(self.HitPos)
	util.Effect("libertyprime_boom", LibertyPrimeBoom, true, true)
	util.BlastDamage(self.Weapon, self.Owner, self.HitPos, 50, 85)
end