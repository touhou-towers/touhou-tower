
SWEP.Base = "weapon_pvpbase"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 		 		= "Candy Corns of Doom"
SWEP.Slot		 	 		= 0
SWEP.SlotPos		 		= 0

SWEP.ViewModel		 		= ""
SWEP.WorldModel				= ""
SWEP.HoldType		 		= "normal"

SWEP.Primary.Delay			= 0.1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Sound	 		= { "weapons/357/357_fire2.wav", "weapons/357/357_fire3.wav" }
SWEP.Primary.Automatic		= true

SWEP.Primary.Delay			= 0.1
SWEP.Primary.Recoil	 		= 1.5
SWEP.Primary.Cone			= 0.015

SWEP.OverHeatTime			= 10
SWEP.CoolDownTime 			= 10
SWEP.ExponentDelay 			= 0.75

SWEP.MinDelay 				= 0.075
SWEP.MaxDelay 				= 0.3

SWEP.MinCone 				= 0.015
SWEP.MaxCone 				= 0.175


function SWEP:Initialize()

	self:SetWeaponHoldType( self.HoldType )
	self.OverHeat = 0
	
end

function SWEP:Think()

	if !IsValid( self.Owner )then return end

	if self.Owner:KeyDown( IN_ATTACK ) then

		if self.OverHeat == 1.0 then return end

		self.OverHeat = math.min( self.OverHeat + FrameTime() / self.OverHeatTime, 1.0 )		

	elseif self.OverHeat > 0.0 then
		
		self.OverHeat = math.max( self.OverHeat - FrameTime() / self.CoolDownTime, 0.0 )
		
	end

end

function SWEP:CanSecondaryAttack() return false end
function SWEP:Reload() return false end

function SWEP:UpdateScale()

	local Perc = math.pow( self.OverHeat, self.ExponentDelay )

	self.Primary.Delay = Lerp( Perc, self.MinDelay, self.MaxDelay )
	self.Primary.Cone = Lerp( Perc, self.MinCone, self.MaxCone )
	
end

function SWEP:PrimaryAttack()

	self:UpdateScale()

	if !self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if SERVER then	

		local bullet = ents.Create( "pvp_candycorn" )
		if IsValid( bullet ) then

			local viewAng = self.Owner:EyeAngles()

			bullet:SetAngles( Angle( viewAng.p + 90, viewAng.y, viewAng.r ) )
			bullet:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 * self.Primary.Cone ) )
			bullet:SetPhysicsAttacker( self.Owner )
			bullet:SetOwner( self.Owner )
			bullet:Spawn()
			bullet:Activate()

			local phys = bullet:GetPhysicsObject()
			if IsValid( phys ) then
				phys:ApplyForceCenter( self.Owner:GetAimVector() * 1000000 )
				phys:AddAngleVelocity( Vector( 0, 0, 500 ) )
			end

		end
		
	end

	self:ShootEffects( self.Primary.Sound, self.Primary.Recoil, self.Primary.Effect, ACT_VM_PRIMARYATTACK )

end