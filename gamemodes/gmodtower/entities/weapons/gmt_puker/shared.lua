

-----------------------------------------------------
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Puker"
SWEP.Slot				= 0
SWEP.SlotPos			= 0

SWEP.ViewModel		= ""
SWEP.WorldModel		= ""
SWEP.ViewModelFlip		= false

SWEP.Primary.Delay		= 5
SWEP.Secondary.Delay 	= 5

SWEP.AdminDelay			= 0.5

SWEP.HoldType		= "normal"

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:Deploy()

	self.Owner:DrawViewModel( false )
	self.Owner:DrawWorldModel( false )
	
end

function SWEP:PrimaryAttack()
	
	if !self.Owner:IsAdmin() then
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	else
		self:SetNextPrimaryFire( CurTime() + self.AdminDelay	)
	end
	
	if SERVER then
		self:Puke( self.Owner )
	end
	
end

function SWEP:SecondaryAttack()

	if !self.Owner:IsAdmin() then
		self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	else
		self:SetNextSecondaryFire( CurTime() + self.AdminDelay )
	end
	
	if SERVER then
		local ply = self.Owner:GetEyeTrace().Entity
		
		if ( IsValid( ply ) && ply:IsPlayer() ) then
			self:Puke( ply )
		end
	end

end

function SWEP:Puke( ply )

	if !ply:IsAdmin() then
		ply:ViewPunch( Angle( -5, 0, 0 ) )
	end
	
	local edata = EffectData()
	edata:SetOrigin( ply:EyePos() )
	edata:SetEntity( ply )

	util.Effect( "puke", edata, true, true )
	
end

function SWEP:Reload()
	return false
end
