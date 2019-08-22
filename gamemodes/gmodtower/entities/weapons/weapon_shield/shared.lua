

-----------------------------------------------------
SWEP.Base = "weapon_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName 			= "Shield"
	SWEP.Slot 				= 1
	SWEP.SlotPos 			= 2
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair 		= false
end

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_bugbait.mdl"
SWEP.WorldModel 			= "models/weapons/w_bugbait.mdl"
SWEP.HoldType				= "normal"

SWEP.Primary.Delay			= 0.5
SWEP.Primary.Ammo			= "none"
SWEP.ShieldOn				= false
SWEP.DamageOn				= false
SWEP.Shield					= nil

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

if SERVER then

	function SWEP:ToggleShield()
		if !self.ShieldOn then self:EnableShield() else self:DisableShield() end
	end

	function SWEP:EnableShield()
		if self.ShieldOn then return end

		self.ShieldOn = true

		self.Owner.Shield = ents.Create("shield")
		if !IsValid(self.Owner.Shield) then return end
		self.Owner.Shield:SetPos(self.Owner:GetPos())
		self.Owner.Shield:SetOwner(self.Owner)
		self.Owner.Shield:Spawn()
		self.Owner.Shield:Activate()
		self.Owner.Shield:SetShieldOwner( self.Owner )
		self.Owner.Shield:EmitSound("weapons/cguard/charging.wav", 80, 150)
	end

	function SWEP:DisableShield()
		if !self.ShieldOn then return end

		self.ShieldOn = false
		if IsValid(self.Owner.Shield) then
			self.Owner.Shield:Remove()
			self.Owner.Shield = nil
		end
		self.Owner:EmitSound("ambient/energy/powerdown2.wav", 80, 100)
	end

	function SWEP:RemoveShield()
		if IsValid(self.Owner.Shield) then
			self.Owner.Shield:Remove()
		end

		return true
	end

	SWEP.Holster = SWEP.RemoveShield
	SWEP.OnRemove = SWEP.RemoveShield
	hook.Add("PlayerDeath", "RemoveShield", function(ply) if IsValid(ply.Shield) then ply.Shield:Remove() end end)
	hook.Add("PlayerSilentDeath", "RemoveShield", function(ply) if IsValid(ply.Shield) then ply.Shield:Remove() end end)
	hook.Add("PlayerDisconnected", "RemoveShield", function(ply) if IsValid(ply.Shield) then ply.Shield:Remove() end end)
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if !IsFirstTimePredicted() or CLIENT then return end
	self:ToggleShield()
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
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
