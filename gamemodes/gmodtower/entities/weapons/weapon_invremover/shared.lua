
if SERVER then
	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_viewscreen.lua")
else
	include("cl_viewscreen.lua")
end

SWEP.PrintName		= "Inventory REMOVER"
SWEP.Category		= ""

SWEP.Base		= "weapon_base"
SWEP.HoldType		= "pistol"

SWEP.ViewModel			= "models/weapons/v_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	
end

function SWEP:Reload()
end


function SWEP:PrimaryAttack()	
	self:RemoveEyeEntity()	
end

function SWEP:SecondaryAttack()
	self:RemoveEyeEntity()
end


function SWEP:RemoveEyeEntity()
	
	if SERVER && self.Owner:GetSetting("GTInvAdminBank") == true then
		
		local EyeTrace = self.Owner:GetEyeTrace()
		
		if EyeTrace.HitWorld || !IsValid( EyeTrace.Entity ) then
			return
		end
		
		local InvId = GTowerItems:FindByEntity( EyeTrace.Entity )
	
		if InvId then
			EyeTrace.Entity:Remove()
		end
	
	end

end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end

