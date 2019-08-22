
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Smith Clone Maker"
SWEP.Slot				= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""
SWEP.HoldType			= "normal"

SWEP.Primary.Delay		= 1
local TotalTime = 7.5
--local heartsound = Sound(ply, "player/heartbeat1.wav")

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
		
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	self.Owner:DrawWorldModel(false)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() or self.Owner:GetPos():Distance(self.Owner:GetEyeTrace().Entity:GetPos()) > 50 then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	self.Owner:ViewPunch( Angle( -20, 0, 0 ) )

	if !IsFirstTimePredicted() then return end

	if SERVER then
		
		local ply = self.Owner:GetEyeTrace().Entity
		
		if ply:IsPlayer() then
			
			self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			
			local Enchant = enchant.New( "cloneplayer", self.Owner )
			Enchant:SetClone( ply )
			Enchant:EnableShared( true )
			
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