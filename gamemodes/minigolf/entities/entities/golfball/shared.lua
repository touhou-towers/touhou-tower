if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type 			= "anim"
ENT.Base			= "base_anim"

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT
ENT.Model 			= "models/sunabouzu/golf_ball.mdl"


function ENT:GetGroundOffset()
	return Vector( 0, 0, 2 )
end

function ENT:SphereInit( r )

	self:PhysicsInitSphere( r, "super_ice" )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:SetMass( 1 )
		phys:SetDamping( 0.05, 0 )
		phys:SetBuoyancyRatio( 0 )
	end

end

function ENT:Initialize()

	self.Radius = 3

	self.OnHill = false
	self.UpHill = false
	self.DownHill = false

	//physenv.SetGravity( Vector( 0, 0, -900 ) ) // TODO

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
	self:SetCustomCollisionCheck( true )

	self.SettleDelay = CurTime() + 2

end

function ENT:Pocket()

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	self:EmitSound( SOUND_CUP, 100, math.random( 80, 120 ) )

	local effect = "golfpocket"

	-- Hole in one!
	if GAMEMODE:IsPlaying() && owner:Swing() == 1 then
		effect = "golfholeinone"
		self:StartLaunch()
	end

	-- Effect
	local edata = EffectData()
		edata:SetOrigin( self:GetPos() + Vector( 0, 0, 8 ) )
		edata:SetEntity( owner )
		edata:SetNormal( Vector( 0, 0, 0 ) )
	util.Effect( effect, edata, true, true )

	self.IsPocketed = true

end

function ENT:StartLaunch()

	umsg.Start( "LaunchingBall" )
		umsg.Entity( self )
		umsg.Bool( true )
	umsg.End()

	timer.Simple( .5, function()
		self.Launching = true
	end )

	self:EmitSound( SOUND_ROCKET )

	timer.Simple( 3, function()

		if IsValid( self ) && IsValid( self:GetOwner() ) then

			local color = self:GetOwner():GetBallColor() * 255

			local eff = EffectData()
				eff:SetOrigin( self:GetPos() )
				eff:SetEntity( self )
				eff:SetStart( Vector( color.r, color.g, color.b ) )
			util.Effect( "golffirework", eff, true, true )

			self:EnableMotion( false )
			self:SetNoDraw( true )

			umsg.Start( "LaunchingBall" )
				umsg.Entity( self )
				umsg.Bool( false )
			umsg.End()

			self:EmitSound( SOUND_EXPLOSION )

		end

	end )

end

function ENT:Think()

	local owner = self:GetOwner()
	if !IsValid( owner ) then
		if SERVER then
			self:Remove()
		end
		return
	end

	if self.IsPocketed then return end

	local vel = self:GetVelocity():Length()
	self:HandleReady( vel )

	if CLIENT then self:ClientThink() return end -- Client thinking

	if self.RemoveDelay && self.RemoveDelay < CurTime() then
		self:Remove()
	end

	if !self.RemoveDelay && self.BoundsDelay && self.BoundsDelay < CurTime() then
		self:RemoveOnOutOfBounds()
	end

	// Max stroke!
	if owner:Team() == TEAM_PLAYING then

		if self.LastStroke && self:IsReady() then
			owner:AutoFail( "STROKE LIMIT" )
		end

		// Tag for max stroke
		if owner:Swing() >= StrokeLimit then
			self.LastStroke = true
		end

	end

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end

	self:TraceDown()

end

function ENT:PhysicsUpdate( physobj )

	if self.Launching then
		physobj:AddVelocity( Vector( 0, 0, 12 ) )
	end

end

function ENT:IsReady()
	return self.Ready and not self:IsBeingRemoved()
end

function ENT:SetReady( isready )
	self.Ready = isready
end

// Determines when the ball is settled and can actually be putted
function ENT:HandleReady( vel )

	if vel < 2 && self:HitWorld( self:GetDownTrace() ) then

		if !self.ReadyDelay then
			self.ReadyDelay = CurTime() + 1
		end

		if CurTime() > self.ReadyDelay then
			self:SetReady( true )
			self.LastSafeSpot = self:GetPos()
		end

	else

		self.ReadyDelay = nil
		self:SetReady( false )

		// Undo AFK
		local owner = self:GetOwner()
		if IsValid( owner ) and SERVER then

			owner.AfkTime = (CurTime() + AFKTime)

		end

	end

end

function ENT:HandleSettle( vel, phys )

	if vel <= 2 && self:HitWorld( self:GetDownTrace() ) then

		// Settle the ball
		if !self.SettleDelay then
			self.SettleDelay = CurTime() + 2
		end

		if CurTime() > self.SettleDelay then
			phys:EnableMotion( false )
			self.SettleDelay = nil
		end

	else

		if self.SettleDelay then
			self.SettleDelay = nil
		end

	end

end

function ENT:GetDownTrace()

	local origin = self:GetPos()
	local filtered = ents.FindByClass( "golfball" )

	return util.TraceLine( {
		start = origin,
		endpos = origin + Vector( 0, 0, -8 ),
		filter = filtered
	} )

end

function ENT:HitWorld( trace )
	return trace.HitWorld || ( IsValid( trace.Entity ) && ( trace.Entity:GetClass() == "func_brush" || trace.Entity:GetClass() == "func_movelinear" ) )
end

function ENT:TraceDown()

	if self.TouchedWater then return end

	local origin = self:GetPos()
	local trace = self:GetDownTrace()

	// Hit water
	if self:WaterLevel() > 0 then

		self:StartOutOfBounds( "WATER HAZARD" )
		self.TouchedWater = true

		// Create particle splashes
		local edata = EffectData()
			edata:SetOrigin( self:GetPos() + Vector( 0, 0, 5 ) )
		util.Effect( "golfsplash", edata, true, true )

		// Create hl2 splash
		local data = EffectData()
			data:SetOrigin( self:GetPos() + Vector( 0, 0, 5 ) )
			data:SetNormal( Vector( 0, 0, 0 ) )
			data:SetScale( math.Rand( 4, 8 ) )
			data:SetFlags( 0x0 )
     	util.Effect( "gunshotsplash", data, true, true )

		return
	end

	if self:HitWorld( trace ) then

		// Hit sky
		if trace.HitSky then
			self:RemoveOnOutOfBounds( "FALL OUT" )
			return
		end

		// Handle Dampening
		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then

			local cos = trace.HitNormal:Dot( Vector( 0, 0, 1 ) )
			local steep = math.sqrt( 1 - cos * cos )

			// We're not on a hill!
			if steep == 0 then

				self.OnHill = false
				self.UpHill = false
				self.DownHill = false
				phys:SetDamping( 0.05, 4 )

			else // We're on a hill!

				self.OnHill = true

				// Get the velocity direction (ignoring z)
				local vel = self:GetVelocity()
				vel.z = 0
				hillTrace = util.TraceLine( {
					start = origin,
					endpos = origin + vel,
					filter = { self }
				} )

				// We're going uphill
				if table.HasValue( SafeMaterials, string.lower( hillTrace.HitTexture ) ) then

					phys:SetDamping( 0.015, 2 )

					/*if trace.Entity && trace.Entity:GetName() == "ignore_hill" then
						phys:SetDamping( 0.015, 2 )
					end*/

					self.UpHill = true

				else // We're going downhill

					if steep >= .2 then
						phys:SetDamping( 0, -1 )
					else
						phys:SetDamping( 0, 1 )
					end

					self.DownHill = true

				end

			end

		end

		// Handle dampening ahead
		/*local origin = self:GetPos() + Vector( 0, 0, 8 )
		local vel = self:GetVelocity()
		vel.z = 0

		local traceAhead = util.TraceLine( {
			start = origin,
			endpos = origin + vel,
			filter = { self }
		} )
		if traceAhead.HitPos then
			local cos = traceAhead.HitNormal:Dot( Vector( 0, 0, 1 ) )
			local steep = math.sqrt( 1 - cos * cos )
			if steep != 0 then
				local dist = origin:Distance( traceAhead.HitPos )
				if dist < 15 then
					phys:SetDamping( 0, 1 )
					self:GetOwner():ChatPrint( "Adjusting for hill ahead!" )
				end
			end
		end*/

		// Not the correct materials
		if self.HitBounds || !table.HasValue( SafeMaterials, string.lower( trace.HitTexture ) ) && !( self.AllowDisplacement && trace.HitTexture == "**displacement**" ) then
			//self:GetOwner():ChatPrint( trace.HitTexture )
			self:StartOutOfBounds()
			return
		end

		// Slow down on sand
		if table.HasValue( SandMaterials, string.lower( trace.HitTexture ) ) then
			//phys:SetDamping( 600, 604 )
			phys:SetVelocity( phys:GetVelocity() / 8 )
		end

		// No friction on ice
		if table.HasValue( IceMaterials, string.lower( trace.HitTexture ) ) then
			phys:SetDamping( .25, 0 )
		end

		// We're safe, let's store the current position
		/*if !self:IsOnHill() then
			self.LastSafeSpot = self:GetPos()
		end*/

		self:EndOutOfBounds()

	else // Flying in the air
		self:EndOutOfBounds()
	end

end

function ENT:IsOnHill()
	return self.OnHill or false
end

function ENT:EnableMotion( bool )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( bool )
	end

end

function ENT:StartOutOfBounds( message, delay )

	if !delay then delay = 1 end

	if !self.BoundsDelay then
		self.BoundsDelay = CurTime() + delay
		self.BoundsMessage = message
	end

end

function ENT:EndOutOfBounds()

	if self.BoundsDelay then
		self.BoundsDelay = nil
	end

	self.BoundsMessage = nil

end

function ENT:IsBeingRemoved()
	return self.BoundsDelay
end

function ENT:RemoveOnOutOfBounds( message )

	local owner = self:GetOwner()
	if IsValid( owner ) then

		if !message then
			message = self.BoundsMessage
		end

		owner:OutOfBounds( self.LastSafeSpot, message )

		self.TouchedWater = false
		self.HitBounds = false

	end

end

function ENT:RemoveOn( time )

	if !time or time == 0 then
		self:Remove()
		return
	end

	self.RemoveDelay = CurTime() + time

end

function ENT:PhysicsCollide( data, phys )

	if data.Speed < 50 then return end

	if data.DeltaTime > 0.2 then
		local pitch = math.Clamp( data.Speed / 1.25, 60, 100 )
		self:EmitSound( SOUND_HIT, 80, pitch )
	end

	// Don't do this if we're going up hill
	if self.UpHill then return end

	local LastSpeed = data.OurOldVelocity:Length()
	local NewVelocity = phys:GetVelocity():GetNormal()

	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	local vel = NewVelocity * LastSpeed * .7
	vel.z = 0
	phys:SetVelocity( vel )

	/*if data.Speed < 30 then return end

	// Handle reflection
	local origin = self:GetPos()
	local vel = self:GetVelocity()

	local trace = util.TraceLine( {
		start = origin,
		endpos = origin + vel,
		filter = { self }
	} )

	if trace.HitPos && !table.HasValue( SafeMaterials, trace.HitTexture ) then

		local aimvec = ( origin - trace.HitPos ):GetNormal()
		local normal = trace.HitNormal

		local reflect = aimvec - ( normal:Dot( aimvec ) ) * normal * 2
		local endpos = trace.HitPos - reflect * 100

		if normal != Vector( 0, 0, 0 ) then
			phys:SetVelocity( reflect * data.OurOldVelocity )
		end

	end*/

end


if SERVER then return end // CLIENT


//local matBall = Material( "sprites/sent_ball" )
surface.CreateFont( "ImpactName", { font = "Impact", size = 54, weight = 600 } )

function ENT:Draw()

	// HACK (to get the halo to render)
	/*self:SetColor( Color( 255, 255, 255, 1 ) )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetModelScale( .45, 0 )*/
	self:DrawModel()

	local owner = self:GetOwner()
	if IsValid( owner ) then

		--owner:ManualEquipmentDraw()
		owner:ManualBubbleDraw()

		// Setup color
		self.Color = owner:GetBallColor() * 255
		self:SetColor( Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )

		// Draw name
		self:DrawName( owner )

		// Draw sprite
		/*local size = 7
		render.SetMaterial( matBall )
		render.DrawSprite( self:GetPos(), size, size, Color( self.Color.r, self.Color.g, self.Color.b, 255 ) )*/

		local vel = self:GetVelocity():Length()
		if vel > 1250 then
			render.SetMaterial( Material( "particles/flamelet" .. math.random( 1, 5 ) ) )
			render.DrawSprite( self:GetPos(), 20, 20, Color( 255, 255, 255 ) )
		end

	end

end

function ENT:DrawName( owner )

	if owner == LocalPlayer() || !owner:Alive() || owner:IsPocketed() then return end

	local pos = self:GetPos()
	local ang = EyeAngles()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	local dist = LocalPlayer():GetPos():Distance( pos )

	if ( dist >= 800 ) then return end // no need to draw anything if the player is far away
	local opacity = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 250 ) // woot mathematica

	cam.Start3D2D( pos, Angle( 0, ang.y, 0 ), SinBetween( 0.12, 0.15, RealTime() * 1 ) )
		//draw.DrawText( string.upper( owner:GetName() ), "ImpactName", 25+2, -30+2, Color( 0, 0, 0, opacity ) )
		//draw.DrawText( string.upper( owner:GetName() ), "ImpactName", 25, -30, Color( self.Color.r, self.Color.g, self.Color.b, opacity ) )
		draw.SimpleTextOutlined( string.upper( owner:GetName() ), "HudNormal", 25, -30, Color( self.Color.r, self.Color.g, self.Color.b, opacity ), 0, 0, 2, Color( 0, 0, 0, 255 ) )
	cam.End3D2D()

end

function ENT:ClientThink()

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	local vel = self:GetVelocity():Length()
	local color = owner:GetBallColor() * 255

	if vel > 5 then

		self:DrawParticles( vel, color )

		local factor = vel * 0.1
		local dlight = DynamicLight( self:EntIndex() )
		if dlight then
			dlight.Pos = self:GetPos()
			dlight.r = color.r
			dlight.g = color.g
			dlight.b = color.b
			dlight.Brightness = 5
			dlight.Decay = factor + self.Radius * 2
			dlight.size = factor + self.Radius
			dlight.DieTime = CurTime() + 2
		end

	end

end

function ENT:DrawParticles( vel, color )

	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	self:DrawMainParticles( vel, color )

	if vel > 1250 then
		self:DrawSpeedParticles( vel, color )
	end

	if self.Launching then
		self:DrawSmokeParticles( vel, color )
	end

end

function ENT:DrawMainParticles( vel, color )

	local factor = vel * 0.015

	for i=1, 5 do

		local sprite = "sprites/powerup_effects"

		local particle = self.Emitter:Add( sprite, self:GetPos() )

		if particle then

			particle:SetDieTime( math.Rand( .2, 1 ) )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( factor + self.Radius )
			particle:SetEndSize( 0 )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( color.r, color.g, color.b, 200 )

		end

		self.Emitter:SetPos( self:GetPos() )

	end

end

function ENT:DrawSpeedParticles( vel, color )

	self.LastParticlePos = self.LastParticlePos or self:GetPos()
	local vDist = self:GetPos() - self.LastParticlePos
	local Length = vDist:Length()
	local vNorm = vDist:GetNormalized()

	for i = 0, Length, 8 do

		self.LastParticlePos = self.LastParticlePos + vNorm * 8

		if math.random( 3 ) > 1 then

			local particle = self.Emitter:Add( "effects/muzzleflash" .. math.random( 1, 4 ), self:GetPos() )
			particle:SetVelocity( VectorRand() * 40 )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 1.0, 1.5 ) )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.random( 5, 10 ) )
			particle:SetEndSize( math.random( 20, 35 ) )

			particle:SetColor( 255, 255, 255 )
			particle:SetAirResistance( 50 )
			particle:SetGravity( Vector( 0, 0, -50 ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.2 )

		end

		if math.random( 3 ) == 3 then

			local particle = self.Emitter:Add( "effects/muzzleflash" .. math.random( 1, 4 ), self:GetPos() )
			particle:SetVelocity( VectorRand() * 30 + Vector( 0, 0, 20 ) )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 0.1, 0.2 ) )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.random( 6, 12 ) )
			particle:SetEndSize( 1 )
			particle:SetColor( 255, 255, 255 )
			particle:SetAirResistance( 50 )

		end

		self.Emitter:SetPos( self:GetPos() )

	end

end

function ENT:DrawSmokeParticles( vel, color )

	self.LastParticlePos = self.LastParticlePos or self:GetPos()
	local vDist = self:GetPos() - self.LastParticlePos
	local Length = vDist:Length()
	local vNorm = vDist:GetNormalized()

	for i = 0, Length, 8 do

		self.LastParticlePos = self.LastParticlePos + vNorm * 8

		if math.random( 3 ) > 1 then

			local particle = self.Emitter:Add( "particles/smokey", self.LastParticlePos )
			particle:SetVelocity( VectorRand() * 40 )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.Rand( 1.0, 1.5 ) )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.random( 2, 5 ) )
			particle:SetEndSize( math.random( 20, 35 ) )

			local dark = math.Rand( 100, 200 )
			particle:SetColor( dark, dark, dark )
			particle:SetAirResistance( 50 )
			particle:SetGravity( Vector( 0, 0, math.random( -50, 50 ) ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.2 )

		end

		self.Emitter:SetPos( self:GetPos() )

	end

end

usermessage.Hook( "LaunchingBall", function( um )

	local ent = um:ReadEntity()
	ent.Launching = um:ReadBool()

end )
