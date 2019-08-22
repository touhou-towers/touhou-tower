
-----------------------------------------------------
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type 			= "anim"
ENT.Base			= "base_anim"

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT
ENT.Model 			= "models/dav0r/hoverball.mdl"

function ENT:SphereInit( r )

	self:PhysicsInitSphere( r, "super_ice" )
	
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass( 1 )
		phys:SetDamping( 0.05, 0 )
		phys:SetBuoyancyRatio( 0.5 )
	end

end

function ENT:Initialize()

	self.Radius = 3

	if SERVER then
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		//self:SetTrigger( true )
		self:SetCollisionBounds( Vector( -self.Radius, -self.Radius, -self.Radius ), 
								Vector( self.Radius, self.Radius, self.Radius )  )
		self:SphereInit( self.Radius )
	end

	self:SetModel( self.Model )
	self:DrawShadow( false )


end

function ENT:PhysicsCollide( data, phys )

	if data.HitEntity == "golfball" then
		self:EmitSound( SOUND_HIT, 100, math.random( 80, 120 ) )
	end

end


if SERVER then return end // CLIENT


function ENT:Think()
	self:DrawParticles()
end

function ENT:DrawParticles()

	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	if !self.NextParticle then
		self.NextParticle = CurTime()
	end

	local rot = Angle( 0, CurTime() * 100, 0 )
	local pos = self:GetPos()

	if CurTime() < self.NextParticle then return end
	self.NextParticle = CurTime() + .01




	local angle = Angle( 0, SinBetween( -360, 360, CurTime() * 5 ), 0 )
	local color = Color( 170 -50, 160 -50, 160 -50 )
	
	local pitch = angle.p
	local yaw = angle.y
	
	local maxParts = 2
	local direction = 0

	local emitter = ParticleEmitter( pos )
	for i = 1, maxParts do

		local pt = self.Emitter:Add( "particles/smokey", pos + rot:Forward() * 20 )
		if i < ( maxParts / 2 ) then

			pt:SetVelocity( angle:Forward() * 50 + Vector( 0, 0, 100 ) )
			pt:SetGravity( rot:Forward() * 50 + Vector( 0, 0, 100 ) )

		else

			local rot = math.rad( ( 360 / maxParts ) * i )
			local dir = Vector(
				math.cos( rot ),
				math.sin( rot ),
				0
			):Angle()

			dir:RotateAroundAxis( Vector( 0 , 1 , 0 ), pitch )
			dir:RotateAroundAxis( Vector( 0 , 0 , 1 ), yaw )
			dir = dir:Forward()
			direction = dir

			pt:SetVelocity( dir * 50 + Vector( 0, 0, 100 ) )

		end

		pt:SetDieTime( math.random( 2, 5 ) )
		pt:SetStartAlpha( 255 )
		pt:SetEndAlpha( 0 )
		pt:SetStartSize( 5 )
		pt:SetEndSize( 40 )
		pt:SetColor( color.r, color.g, color.b )

	end

	for i=1, 5 do

		local time = i * 2
		local angle = Angle( 0, SinBetween( -360, 360, CurTime() * time ), 0 )

		//local flare = Vector( 0, math.random( -10, 10 ), 0 )
		//local flare = Vector( 0, 0, math.random( -25, 25 ) )
		local size = 5
		local flare = Vector( CosBetween( -size, size, CurTime() * 2 ), SinBetween( -size, size, CurTime() * 2 ), size )
		local particle = self.Emitter:Add( "particles/smokey", pos + rot:Forward() * 20 )

		if particle then

			particle:SetVelocity( ( angle:Forward() * -40 ) + Vector( 0, 0, 100 ) )
			particle:SetDieTime( math.Rand( 5, 8 ) )
			particle:SetStartAlpha( 20 )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( math.random( 4, 20 ) )
			particle:SetEndSize( math.random( 4, 10 ) )

			particle:SetRoll( SinBetween( -360, 360, CurTime() * time ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( 170, 160, 160 )

			particle:SetGravity( ( angle:Forward() * -20 ) )

		end

	end

	local pos = pos + rot:Forward() * 20
	local Dist = LocalPlayer():GetPos():Distance( pos )
	local FleckSize = math.Clamp( Dist * 0.01, 8, 64 )
	local SurfaceColor = render.GetSurfaceColor( pos + Vector( 0, 0, -100 ), pos + Vector( 0, 0, 100 ) ) * 255

	SurfaceColor.r = math.Clamp( SurfaceColor.r+50, 0, 255 )
	SurfaceColor.g = math.Clamp( SurfaceColor.g+50, 0, 255 )
	SurfaceColor.b = math.Clamp( SurfaceColor.b+50, 0, 255 )

	for i =1, 2 do
	
		local particle
	
		if ( math.random( 0, 1 ) == 1 ) then
			particle = emitter:Add( "effects/fleck_cement1", pos )
		else
			particle = emitter:Add( "effects/fleck_cement2", pos )
		end

		if particle then

			particle:SetVelocity( ( ( direction + VectorRand() * .5 ) * math.Rand( 150, 200 ) ) * -1 + Vector( 0, 0, 200 ) )
			//particle:SetLifeTime( i )
			particle:SetDieTime( math.random( 1, 2 ) )
			particle:SetStartAlpha( 225 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( FleckSize * math.Rand( 0.25, 0.5 ) )
			particle:SetEndSize( 0 )
			particle:SetGravity( Vector( 0, 0, -600 ) )
			particle:SetAirResistance( 40 )
			particle:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
			//particle:SetAngleVelocity( Angle( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 800 )
			particle:SetCollide( true )
			particle:SetBounce( 0.2 )
			particle:SetColor( SurfaceColor )

		end

	end

end