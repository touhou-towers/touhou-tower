
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"
SWEP.NoBank				= true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Confetti!"
SWEP.Slot				= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= "models/weapons/v_bugbait.mdl"
SWEP.WorldModel 		= "models/weapons/w_bugbait.mdl"
SWEP.ViewModelFlip		= true

SWEP.Primary.Delay		= 5

SWEP.AdminDelay			= 0.25
SWEP.PartySound			= "GModTower/misc/confetti.wav"
SWEP.HoldType			= "normal"

/*
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"
*/

SWEP.WeaponSafe = true

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:Precache()
	//GtowerPrecacheSound(self.PartySound)
end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
	self.Owner:DrawWorldModel(false)
	
	if SERVER then
		if self.InventoryItem && self.InventoryItem.WeaponDeployed then
			self.InventoryItem:WeaponDeployed()
		else
			self.Owner.UsesLeft = -1
			self.Owner.MaxUses = -1
		end
	end
	
	//return true
end

function SWEP:Holster()

	if SERVER then
		if self.InventoryItem && self.InventoryItem.WeaponHolstered then
			self.InventoryItem:WeaponHolstered()
		else
			self.Owner.UsesLeft = -1
			self.Owner.MaxUses = -1
		end
	end
	
	return true
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	if !self.Owner:IsAdmin() then
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self.Owner:ViewPunch( Angle( -20, 0, 0 ) )
	else
		self.Weapon:SetNextPrimaryFire( CurTime() + self.AdminDelay	)
	end

	self.Owner:ViewPunch( Angle( -20, 0, 0 ) )
	if !IsFirstTimePredicted() then return end

	local sfx = EffectData()
		sfx:SetOrigin( self.Owner:EyePos() )
	util.Effect( "confetti", sfx )

	if SERVER then
		self.Owner:EmitSound( self.PartySound, 50, 100 )
		
		if self.InventoryItem && self.InventoryItem.WeaponFired then
			self.InventoryItem:WeaponFired()
		end
		
	end
	
end
--[[
function SWEP:SecondaryAttack()
	/*
	if !self:CanSecondaryAttack() then return end
	
	if !self.Owner:IsAdmin() then
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	else
		self.Weapon:SetNextSecondaryFire( CurTime() + self.AdminDelay )
	end

	local sfx = EffectData()
		sfx:SetOrigin( self.Owner:EyePos() )
	util.Effect( "confetti", sfx )
	*/
	
end
--]]

function SWEP:Reload()
	return false
end

function SWEP:CanPrimaryAttack()
	return !Location.IsTheater( GTowerLocation:FindPlacePos(self:GetOwner():GetPos()) )
end

function SWEP:CanSecondaryAttack()
	return false
end