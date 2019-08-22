

-----------------------------------------------------
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.PrintName 			= "Dosh Gun"
SWEP.Slot				= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= "models/weapons/v_pvp_ire.mdl"
SWEP.WorldModel			= "models/weapons/w_pvp_ire.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Delay		= 2
SWEP.AdminDelay			= .5
SWEP.Secondary.Delay	= 10

SWEP.Primary.Automatic	= true

SWEP.HoldType			= "fist"

SWEP.MoneySounds		= "GModTower/lobby/dosh/cash##.wav"
SWEP.InsultSounds		= "GModTower/lobby/dosh/insult##.wav"

SWEP.NumSounds			= 14
SWEP.NumInsults			= 18

SWEP.InsultDelay		= CurTime()


function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )

end


function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end

	if self.Owner:IsAdmin() then
		self.Weapon:SetNextPrimaryFire( CurTime() + self.AdminDelay )
	else
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end

	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if CLIENT then return end

	local ent = ents.Create( "gmt_cash" )

	if IsValid( ent ) then

		ent:SetPos( self.Owner:GetShootPos() )
		ent:SetOwner( self.Owner )
		ent:SetPhysicsAttacker( self.Owner )
		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()
		if IsValid( phys ) then
			phys:SetVelocity( self.Owner:GetVelocity() + ( self.Owner:GetAimVector() * 350 ) )
		end
	end


	if self.InsultDelay > CurTime() then return end

	local iSound = math.random( 1, self.NumSounds )
	local soundFile = string.gsub( self.MoneySounds, "##", iSound )

	self.Owner:EmitSound( soundFile )

	if self.Owner:IsAdmin() then
		self.InsultDelay = CurTime() + 1
	else
		self.InsultDelay = CurTime() + 1
	end

end

function SWEP:SecondaryAttack()

	if !self:CanSecondaryAttack() then return end

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	if CLIENT then return end


	if self.InsultDelay > CurTime() then return end

	local iSound = math.random( 1, self.NumInsults )
	local soundFile = string.gsub( self.InsultSounds, "##", iSound )

	self.Owner:EmitSound( soundFile )

	self.InsultDelay = CurTime() + 1

end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return true
end
