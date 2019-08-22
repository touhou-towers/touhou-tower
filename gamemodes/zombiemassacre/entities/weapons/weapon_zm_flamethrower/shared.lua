
-----------------------------------------------------
SWEP.Base = "weapon_zm_base"

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.PrintName 				= "Flamethrower"

SWEP.WorldModel				= Model( "models/weapons/w_flamethro.mdl" )
SWEP.HoldType				= "ar2"

SWEP.Primary.ClipSize		= 200

SWEP.Primary.Damage			= 25
SWEP.Primary.Sound			= Sound( "GModTower/zom/weapons/flamethrower/shoot.wav" )

SWEP.Offsets				= nil

SWEP.Tier 					= DropManager.RARE

SWEP.FlameDamage = CurTime()

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire(CurTime() / 10)
	self.FlameDamage = CurTime() + 0.5

end

function SWEP:Think()
	
	if SERVER then
	
		if self:Clip1() == 0 then
			self.Owner:StripWeapon( self:GetClass() )
			return
		end

		if self.Owner:KeyDown( IN_ATTACK ) then
			self.Owner:SetNWBool( "FlameOn", true )
		else
			self.Owner:SetNWBool( "FlameOn", false )
			return
		end

		if !self.FlameDamage then
			self.FlameDamage = CurTime()
		end

		if CurTime() < self.FlameDamage + 0.1 then return end
		
		local trace = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 450 ),
			mins = Vector( -1.25, -1.25, -1.25 ),
			maxs = Vector( 1.25, 1.25, 1.25 ),
			filter = self.Owner
		})

		if IsValid(trace.Entity) then

			if trace.Entity:IsNPC() then

				trace.Entity:TakeDamage( self.Primary.Damage, self.Owner )

				if !trace.Entity.IsBoss then
					trace.Entity:Fire( "Ignite", "", 1 )
				end

			elseif trace.Entity:GetClass() == "prop_physics" then

				trace.Entity:Fire( "Ignite", "", 1 )

			end

		end

		self:TakePrimaryAmmo( 1 )
		self.FlameDamage = CurTime()

	else	//CLIENT-----------

		if !self.Owner:GetNWBool( "FlameOn" ) then

			if IsValid( self.Emitter ) then
				self.Emitter:Finish()
				self.Emitter = nil
				self.FlameSound:FadeOut( 0.5 )
			end

			return 
		end

		local attach = self:LookupAttachment("muzzle_flash")
		if attach > 0 then
			attach = self:GetAttachment(attach)
			attach = attach.Pos + ( attach.Ang:Forward() * -10 )
		else
			attach = self.Owner:GetShootPos()
		end

		local dir = self.Owner:GetAimVector()

		if !self.FlameSound then
			self.FlameSound = CreateSound( self.Owner, self.Primary.Sound )
		end

		if not self.Emitter then
			self.Emitter = ParticleEmitter( attach )
			self.Flame = CurTime()
			self.FlameSound:PlayEx( 1, 200 )
		end

		if CurTime() < self.Flame + 0.01 then return end

		//Blue Hot
		for i=0, 1 do
			local particle = self.Emitter:Add( "particles/flamelet" .. math.random( 1, 5 ), attach )
			if particle then
				particle:SetPos( attach + ( dir * i * 3 ) )
				particle:SetVelocity( dir * ( 200 + math.random() * 200 ) )
				particle:SetDieTime( math.Rand( 0.3, 0.4 ) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 150 )
				particle:SetStartSize( 0.6 * i )
				particle:SetEndSize( math.Rand( 24, 32 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -0.5, 0.5 ) )
				particle:SetColor( 30, 15, math.Rand( 190, 225 ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.2 )
			end
		end

		//Red Hot
		for i=1, 5 do
			local particle = self.Emitter:Add( "particles/flamelet" .. math.random( 1, 5 ), attach )
			if particle then
				particle:SetPos( attach + ( dir * i * 5 ) )
				particle:SetVelocity( dir * ( 400 + math.random() * 200 ) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.6 )
				particle:SetStartSize( 2 )
				particle:SetEndSize( 24 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetRoll( math.Rand( -10, 10 ) )
				particle:SetRollDelta( math.Rand( -2, 2 ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.2 )
			end
		end

		self.Flame = CurTime()

		if ConVarDLights:GetInt() < 1 then return end
		
		//Dlight
		local dlight = DynamicLight( self:EntIndex() )
		if dlight then
			dlight.Pos = attach
			dlight.r = 255
			dlight.g = math.random( 100, 150 )
			dlight.b = math.random( 30, 55 )
			dlight.Brightness = 4
			dlight.Decay = math.random( 200, 256 )
			dlight.size = math.random( 150, 180 )
			dlight.DieTime = CurTime() + .1
		end

	end

end

function SWEP:OnRemove()

	self:TurnOff()

end

function SWEP:Holster()

	self:TurnOff()
	return true

end

function SWEP:TurnOff()

	self.Owner:SetNWBool( "FlameOn", false )

	if IsValid( self.Emitter ) then
		self.Emitter:Finish()
		self.Emitter = nil
	end

	if self.FlameSound then
		self.FlameSound:Stop()
		self.FlameSound = nil
	end

end

function SWEP:DrawWorldModel()

	//if SERVER then return end

	self.Weapon:DrawModel()
	self:Think()

end