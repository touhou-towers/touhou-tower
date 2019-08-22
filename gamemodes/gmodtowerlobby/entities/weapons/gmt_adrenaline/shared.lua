
-----------------------------------------------------
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"
SWEP.NoBank				= true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Adrenaline"
SWEP.Slot				= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= "models/weapons/v_vir_adrenaline.mdl"
SWEP.WorldModel 		= "models/weapons/w_vir_adrenaline.mdl"

SWEP.Primary.Delay		= 5

SWEP.AdminDelay			= 0.25
SWEP.PartySound			= Sound("GModTower/virus/weapons/Adrenaline/use.wav")
SWEP.HoldType			= "grenade"

SWEP.Duration			= 15

SWEP.SoundDeploy		= Sound("GModTower/virus/weapons/Adrenaline/deploy.wav")
SWEP.ExtraSounds		= Sound("GModTower/virus/weapons/Adrenaline/heartbeat.wav")

function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:PrimaryAttack()

	if !IsFirstTimePredicted() || self.Owner.UsingAdrenaline then return end

	self.Owner.UsingAdrenaline = true

	if CLIENT then
		self.Owner:EmitSound( self.SoundDeploy )
	end

	self:ShootEffects()

	local vm = self.Owner:GetViewModel()
	if IsValid( vm ) then

		local sequence = vm:LookupSequence( "adrenaline_injection" )
		vm:SetSequence( sequence )

	end

	timer.Simple( 0.5, function() self.Owner:AdrenalineOn() end)

end

function SWEP:CanSecondaryAttack() return false end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

end

function SWEP:Reload()
	return false
end


PlayerMeta = FindMetaTable( "Player" )
if !PlayerMeta then return end

function PlayerMeta:AdrenalineOn()

	if !IsValid( self ) then return end

	if SERVER then
		self:SetWalkSpeed( 650 )
		self:SetRunSpeed( 650 )
	else
		self:EmitSound( "GModTower/virus/weapons/Adrenaline/use.wav" )
		self:EmitSound( "GModTower/virus/weapons/Adrenaline/heartbeat.wav" )
	end

	PostEvent( self, "adrenaline_on" )

	timer.Simple( 0.5, function() if IsValid( self ) then self:SetDSP( 6 ) end end )
	timer.Create( "Adrenaline" .. self:UserID(), 10, 1, function() self:AdrenalineOff() end)

end

function PlayerMeta:ResetSpeeds()

	if IsValid( self.TakeOn ) then
		self:SetWalkSpeed( 550 )
	else
		self:SetWalkSpeed( 200 )
	end

	self:SetRunSpeed( 320 )
	self:SetCanWalk( true )

end

function PlayerMeta:AdrenalineOff()

	if !IsValid( self ) then return end

	if SERVER then
		self:ResetSpeeds()
	end

	self:SetDSP( 1 )
	PostEvent( self, "adrenaline_off" )
	self.UsingAdrenaline = false

	timer.Destroy( "Adrenaline" .. self:UserID() )

end
