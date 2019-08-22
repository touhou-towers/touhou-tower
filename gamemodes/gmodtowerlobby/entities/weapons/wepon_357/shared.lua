
-----------------------------------------------------
if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.PrintName				= ".357"
SWEP.Category				= "Stolen Junk"

SWEP.Base					= "weapon_base"
SWEP.HoldType				= "pistol"

SWEP.ViewModel				= "models/weapons/v_357.mdl"
SWEP.WorldModel				= "models/weapons/w_357.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector(-2.9547, -28.7916, 0.9214)
SWEP.IronSightsAng 			= Vector(95.4548, -9.2427, 0)

SWEP.SoundReady				= Sound( "Weapon_357.Spin" )
SWEP.SoundTrigger			= Sound( "Weapon_357.ReplaceLoader" )
SWEP.SoundShoot				= Sound( "Weapon_357.Single" )

SWEP.WeaponSafe				= true
SWEP.Description 			= "A gun? Better be careful with this."

function SWEP:Initialize()

	self.Suicide = 0
	self.State = 0

	self:SetWeaponHoldType( self.HoldType )

end

function SWEP:Reload()
	return false
end

function SWEP:Holster()
	return self.Suicide == 0
end

function SWEP:Think()
	if CurTime() > self.Suicide + 0.15 && self.State == 1 then
		if CLIENT then self:EmitSound( self.SoundTrigger ) end
		self.State = 2
	elseif CurTime() > self.Suicide + 0.75 && self.State == 2 then
		if CLIENT then self:EmitSound( self.SoundReady ) end
		self.State = 3
	elseif CurTime() > self.Suicide + 1 && self.State == 3 then
		self:Shoot()
		self.State = 4
	elseif CurTime() > self.Suicide + 1.25 && self.State == 4 then
		self:KillPlayer()
		self.State = 0
	end
end

local taunt = {"I can't take it anymore.", "I hate my life.", "Hug my life.", "Life is meaningless..."}

function SWEP:PrimaryAttack()
	if self.Suicide > 0 then return end

	self.Suicide = CurTime()
	self.State = 1

	if SERVER then
		self.Owner:ChatPrint( taunt[math.random(1,#taunt)] )
	end
end

function SWEP:Shoot()

	self.Owner:ViewPunch( Angle( math.Rand( -0.2, -0.1 ) * 50, math.Rand( -0.1, 0.1 ) * 50, 0 ) )

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if CLIENT then self:EmitSound( self.SoundShoot, 5, 100 ) end

end

function SWEP:KillPlayer()

	if SERVER then

		self.Owner:Kill()
		//self.Owner:CreateRagdoll()

		self.Owner:AddAchivement( ACHIVEMENTS.HUGMYLIFE, 1 )

		if GTowerRooms then
			local Room = self.Owner:GetRoom()

			if Room then
				Room:Finish()
			end

		end
	end

end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

local IRONSIGHT_TIME = 0.5
function SWEP:GetViewModelPosition( pos, ang )
	if self.Suicide == 0 then return pos, ang end

	local fIronTime = self.Suicide
	local Mul = 1.0

	if fIronTime > CurTime() - IRONSIGHT_TIME then

		Mul = math.Clamp( (CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1 )

	end

	local Offset = self.IronSightsPos

	if ( self.IronSightsAng ) then

		ang = ang * 1
		ang:RotateAroundAxis( ang:Right(), 		self.IronSightsAng.x * Mul )
		ang:RotateAroundAxis( ang:Up(), 		self.IronSightsAng.y * Mul )
		ang:RotateAroundAxis( ang:Forward(), 	self.IronSightsAng.z * Mul )

	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end
