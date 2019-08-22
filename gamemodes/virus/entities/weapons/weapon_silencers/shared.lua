SWEP.Base 					= "weapon_virusbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

//Basic Setup
SWEP.PrintName				= "Dual Silencers"
SWEP.Slot					= 1
SWEP.SlotPos				= 0

//Types
SWEP.HoldType				= "duel"
SWEP.GunType				= "default"  //for muzzle/shell effects  (default, shotgun, rifle, highcal, or scifi)

//Models
SWEP.ViewModel				= "models/weapons/v_vir_dsilen.mdl"
SWEP.WorldModel				= "models/weapons/w_vir_dsilen.mdl"

//Primary
SWEP.Primary.ClipSize		= 36
SWEP.Primary.DefaultClip	= 36
SWEP.Primary.Ammo			= "357"
SWEP.Primary.Delay			= 0.09
SWEP.Primary.Recoil	 		= 2
SWEP.Primary.Cone			= 0.025
SWEP.Primary.Damage			= { 16, 20 }

//Secondary
SWEP.Secondary				= SWEP.Primary
SWEP.Secondary.Anim 		= ACT_VM_SECONDARYATTACK

//Parameters
SWEP.TracerOrigin			= "1"

//Sounds
SWEP.Primary.Sound			= "GModTower/virus/weapons/DualSilencer/shoot.wav"
SWEP.SoundDeploy	 		= "GModTower/virus/weapons/DualSilencer/deploy.wav"
SWEP.SoundReload			= "GModTower/virus/weapons/DualSilencer/reload.wav"

function SWEP:PrimaryAttack()
	self.TracerOrigin = "2"
	if self.BaseClass.PrimaryAttack(self.Weapon) then return end

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:SecondaryAttack()
	self.TracerOrigin = "1"
	if self.BaseClass.SecondaryAttack(self.Weapon) then return end

	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:GetTracerOrigin()
	local vm = self.Owner:GetViewModel()

	local attach = vm:LookupAttachment(self.TracerOrigin)
	if attach then
		return vm:GetAttachment( attach ).Pos
	end
end