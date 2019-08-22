
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Minigun"

SWEP.WorldModel				= Model( "models/weapons/w_minigun.mdl" )
SWEP.HoldType				= "physgun"

SWEP.Primary.ClipSize		= 225
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay			= 0.05
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Trace			= "minigun_trace"

SWEP.Primary.Damage			= 45
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/minigun/shoot.wav" )
SWEP.StartSound				= Sound( "GModTower/zom/weapons/minigun/startshoot.wav" )
SWEP.EndSound				= Sound( "GModTower/zom/weapons/minigun/endshoot.wav" )

SWEP.Offsets				= nil

SWEP.Tier 					= DropManager.RARE

SWEP.SpinStart			= 0
SWEP.SpinLength			= 1 // 1 second

SWEP.NextFire			= 0


function SWEP:BeginSpin()

	self.SpinStart = CurTime()
	self.NextFire = CurTime() + self.Primary.Delay

	// Sound
	if !self.SpinUpSound then
		self.SpinUpSound = CreateSound( self.Owner, self.StartSound )
		self.SpinUpSound:Play()
	else
		if !self.SpinUpSound:IsPlaying() then
			self.SpinUpSound:Play()
		end
	end
	
end

function SWEP:UpdateSpin()

	if ( self.SpinStart == 0 ) then return end
	
	local diff = CurTime() - self.SpinStart
	
	if ( diff > self.SpinLength ) then
	
		if ( CurTime() > self.NextFire ) then

			for i=1, 3 do
				local offset = VectorRand():GetNormal() * 8
				self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, self.Primary.Trace, offset )
			end

			self:ShootEffects( nil, self.Primary.Effect )

			self:TakePrimaryAmmo( 1 )
		
			self.NextFire = CurTime() + self.Primary.Delay
			
		end

		if self.SpinUpSound:IsPlaying() then
			self.SpinUpSound:Stop()
		end

		// Sound
		if !self.ShootSound then
			self.ShootSound = CreateSound( self.Owner, self.Primary.Sound )
			self.ShootSound:Play()
		else
			if !self.ShootSound:IsPlaying() then
				self.ShootSound:Play()
			end
		end
	
	end

end

function SWEP:EndSpin()

	self.SpinStart = 0

	// Sound
	if self.ShootSound && self.ShootSound:IsPlaying() then
		self.ShootSound:FadeOut( .1 )
	end

	if !self.SpinDownSound then
		self.SpinDownSound = CreateSound( self.Owner, self.EndSound )
		self.SpinDownSound:Play()
	else
		if !self.SpinDownSound:IsPlaying() then
			self.SpinDownSound:Play()
		end
	end
	
end

function SWEP:Holster()

	if self.ShootSound && self.ShootSound:IsPlaying() then
		self.ShootSound:FadeOut( .1 )
		self.ShootSound = nil
	end

	return true

end

function SWEP:OnRemove()

	if self.ShootSound && self.ShootSound:IsPlaying() then
		self.ShootSound:FadeOut( .1 )
		self.ShootSound = nil
	end

end

function SWEP:Think()
	
	if SERVER && self:Clip1() == 0 then
		self.Owner:StripWeapon(self:GetClass())
		return
	end
	
	if ( self.Owner:KeyPressed( IN_ATTACK ) ) then
	
		self:BeginSpin()
		
	elseif ( self.Owner:KeyDown( IN_ATTACK ) ) then
	
		self:UpdateSpin()
		
	elseif ( self.Owner:KeyReleased( IN_ATTACK ) ) then
	
		self:EndSpin()
		
	end
	
end

function SWEP:PrimaryAttack() end