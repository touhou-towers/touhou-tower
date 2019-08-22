if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type 			= "anim"
ENT.Base			= "base_anim"

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT
ENT.Model 			= "models/sunabouzu/golf_ball.mdl"

SOUND_CUP = "GModTower/minigolf/effects/cup.wav"
SOUND_HIT = "GModTower/minigolf/effects/hit.wav"
SOUND_EXPLOSION = "GModTower/minigolf/effects/explosion.wav"
SOUND_ROCKET = "GModTower/minigolf/effects/launch.wav"
SOUND_SWING = "GModTower/minigolf/effects/swing" // power + .wav
SOUND_CLAP = "GModTower/minigolf/effects/golfclap" // 1-3 + .wav

local novel = Vector( 0, 0, 0 )



hook.Add("Move","GolfBallMove", function( ply, movedata )

	--if IsValid( ply:GetGolfBall() ) || ( !self:IsPlaying() && self:GetState() != STATE_WAITING ) then
	if IsValid( ply.GolfBall ) then

		movedata:SetForwardSpeed( 0 )
		movedata:SetSideSpeed( 0 )
		movedata:SetVelocity( novel )

		if SERVER then ply:SetGroundEntity( NULL ) end

		local ball = ply.GolfBall
		local offset = 16

		if IsValid( ball ) then

			if ball:WaterLevel() > 0 then
				offset = 64
			end

			movedata:SetOrigin( ball:GetPos() + Vector( 0, 0, offset ) )

		end

		return true

	end

	if !ply:Alive() then

		return true

	end

end)

if CLIENT then
surface.CreateFont( "HudNormal", { font = "FOP Title Style Font", size = ScreenScale( 20 ) } )
hook.Add("CreateMove","GolfBallMoveCam", function(cmd)
	local ball = LocalPlayer().GolfBall

	if IsValid( ball ) then
		if !ball:IsReady() || IsRightClickHeld then
			CamRot = cmd:GetViewAngles().y
		end

		cmd:SetViewAngles( Angle( 0, CamRot, 0 ) )

		return true
	end
end)


CamUp = 150
CamUpWant = 150
CamRot = 0

local function CalcViewPlaying( ply, origin, angles, fov )
	local ball = ply.GolfBall
	
	if ball == nil then return end
	
	if IsValid( ball ) then
		local center = ball:GetPos() + Vector( 0, 0, CamUp * 1.5 )
		local dist = CamUp

		// Trace for walls
		local tr = util.TraceLine( { start = center, 
									 endpos = center + ( angles:Forward() * -dist * 0.95 ), filter = ball } )

		if ( tr.HitWorld || tr.HitNoDraw ) && tr.Fraction < 1 then
			dist = dist * ( tr.Fraction * .85 )
		end

		// Final pos
		local Pos = center + ( angles:Forward() * -dist * 0.95 )

		// Ease
		if !LastPos then LastPos = Pos end

		local ease = 150

		--if ply:CanPutt() && !IsRightClickHeld then ease = 50 end

		LastPos.x = ApproachSupport2( LastPos.x, Pos.x, ease )
		LastPos.y = ApproachSupport2( LastPos.y, Pos.y, ease )
		LastPos.z = ApproachSupport2( LastPos.z, Pos.z, ease )

		return {
			origin = LastPos,
			angles = Angle( math.Clamp( angles.p + ( CamUp / 4 ), 35, 150 ), angles.y, 0 ),
			fov = 90
		}
	end

	return {
		origin = origin,
		angles = angles,
		fov = fov
	}
end
	hook.Add("CalcView","GolfMileStone",CalcViewPlaying)
	
	
-----------------------------------------------------
hook.Add( "Think", "ControlsThink", function()
	// Handle scoreboard mouse interaction
	--Scoreboard.Customization.EnableMouse = tobool( !LocalPlayer():CanPutt() )
	local ball = LocalPlayer().GolfBall
	if IsValid( ball ) then
		if ball:IsReady() && !IsRightClickHeld then
		
			// Enable mouse clicker
			gui.EnableScreenClicker( true )
			LocalPlayer()._ClickerEnabled = true
			
			// Handle keyboard controls
			HandleControls()
			return
		end

		HandleControls()
	end

	// Disable mouse clicker
	--[[if GAMEMODE:GetState() != STATE_SETTINGS then
		if LocalPlayer()._ClickerEnabled then
			gui.EnableScreenClicker( false )
			LocalPlayer()._ClickerEnabled = false
		end
	end]]
end )

// CAMERA CONTROLS =====
function HandleControls()
	if gui.IsGameUIVisible() || gui.IsConsoleVisible() then return end

	if GTowerChat.Chat && !GTowerChat.Chat.inputpanel:IsVisible() then
		if !LocalPlayer():IsTyping() then
			local speed = 1

			if input.IsKeyDown( KEY_LSHIFT ) then speed = speed * 2 end
			if input.IsKeyDown( KEY_A ) then CamRot = CamRot - speed end
			if input.IsKeyDown( KEY_D ) then CamRot = CamRot + speed end
			if input.IsKeyDown( KEY_W ) then CamUpWant = CamUpWant - speed end
			if input.IsKeyDown( KEY_S ) then CamUpWant = CamUpWant + speed end
		end
	end

	WasLeftClickHeld = IsLeftClickHeld
	WasRightClickHeld = IsRightClickHeld
	IsRightClickHeld = input.IsMouseDown( MOUSE_RIGHT )
	IsLeftClickHeld = input.IsMouseDown( MOUSE_LEFT )

end

// AIMING =====
Swing = {
	power 		=	0,
	midpoint 	=	Vector(),
	delta 		=	Vector(),
	lastpower	= 	0,
}

RenderSettings = {
	target 		= 	Vector(),
	aimplane 	= 	Vector(),
	direction 	= 	0,
	pWidth 		= 	0,
	pHeight 	= 	0,
	arWidth 	= 	0,
	arHeight 	= 	0,
	drawAimer 	= 	true,
}

function HandleAiming( ViewOrigin, ViewAngles, ViewFOV )
	local ball = LocalPlayer().GolfBall
	if !IsValid( ball ) || !ball:IsReady() then return end

	--Screen coordinates to aim vector
	local mouseX, mouseY = gui.MousePos()
	local screenvector = util.AimVector( ViewAngles, ViewFOV, mouseX, mouseY, ScrW(), ScrH() )

	--Clamp camera pitch
	local pitch = 0.01
	/*local pitch = ViewAngles.p - 30
	
	if pitch > 0.4 then pitch = 0.4 end
	if pitch < -40 then pitch = -40 end*/

	--Aiming plane position
	local target = ball:GetPos() + Vector(0,0,-3)

	--Derive aiming plane from camera angle
	local aimangle = Angle(pitch,ViewAngles.y,0)
	local aimplane = aimangle:Up()

	--Project cursor onto aiming plane
	local d = ( target - ViewOrigin ):Dot( aimplane ) / screenvector:Dot( aimplane )
	local position = ViewOrigin + screenvector * d

	--If projecting from back of plane ignore projection
	if d < 0 then position = target end

	--If not screen clicking, ignore projection
	if mouseX == 0 and mouseY == 0 then position = target end

	--Obtain delta (hit power) and clamp to 300
	local delta = position - target
	local deltaLen = delta:Length()

	if deltaLen > 300 then
		delta = delta * (300 / deltaLen)
	end

	--Obtain local coordinates on plane
	local localX = aimangle:Right():Dot(delta)
	local localY = aimangle:Forward():Dot(delta)

	--Plane size when rendered
	local plimitW = 50
	local plimitH = 50

	--Scale plane rendering to match coordinates
	if math.abs(localX) > plimitW then plimitW = localX end
	if math.abs(localY) > plimitH then plimitH = localY end

	--Obtain aiming direction in the context of the plane
	local direction = 90 + (math.atan2(localY, localX) * 57.3)

	if pitch > 0 then direction = direction + 180 end

	--Store midpoint and hit settings
	Swing.midpoint 		= target + delta / 2
	Swing.delta 		= delta
	Swing.power 		= math.Clamp( delta:Length(), 0, 300 )

	--Calculate arrow size
	local arWidth = 2
	local arHeight = Swing.power/2
	if arHeight < 5 then arHeight = 5 end
	if d < 0 then arHeight = 0 end

	--Pass rendering information to PostDrawOpaqueRenderables
	RenderSettings.target 		= target
	RenderSettings.aimplane 	= aimplane
	RenderSettings.direction 	= direction
	RenderSettings.pWidth 		= plimitW
	RenderSettings.pHeight 		= plimitH
	RenderSettings.arWidth 		= arWidth
	RenderSettings.arHeight 	= arHeight
end

hook.Add( "RenderScene", "MinigolfRenderScene", HandleAiming )

hook.Add("GUIMousePressed","GolfMousePress", function(mc)
	if mc == MOUSE_LEFT then
		local ball = LocalPlayer().GolfBall

		if IsValid( ball ) && ball:IsReady() && Swing.power > 0 then
			LocalPlayer().Swung = true

			// sv_controls.lua
			/*net.Start("MinigolfPutt")
				net.WriteVector( Vector( Swing.delta.x, Swing.delta.y, Swing.delta.z ) )
			net.SendToServer()*/
			
			RunConsoleCommand( "gmt_minigolf_putt", Swing.delta.x, Swing.delta.y, Swing.delta.z )

			timer.Simple( 1, function()
				LocalPlayer().Swung = false
			end )
		end
	end
end)

--[[function GM:PlayerBindPress( ply, bind, pressed )
	// For testing...
	if bind == "+menu" then
		//RunConsoleCommand( "minigolf" )
		self:DisplayScorecard( !ValidPanel( Scorecard ) )
	end
	
	if bind == "+menu_context" then
		self:DisplayCustomizer( !ValidPanel( RADIAL ), true )
	end
end]]
	
	local lasermat 	=	Material( "effects/laser1.vmt" )
local wire 		=	Material( "models/wireframe.vmt" )
local color 	=	Material( "color.vmt" )
local arrow 	=	Material( "vgui/gradient_up.vmt" )
local sprite 	= Material( "sprites/powerup_effects" )
local putter 	= Model( "models/gmod_tower/putter.mdl" )

Debug = false // DEBUG

----------------------------------------
--RENDERING TOOLS
----------------------------------------
RenderUTIL = {}

RenderUTIL.renderLine = function( startpos, endpos, thickness, color )
	render.SetMaterial( lasermat )
	render.DrawBeam( startpos, endpos, thickness or 8, 0, 1, color or Color( 255, 255, 255, 255 ) )
	render.SetMaterial( sprite )
	render.DrawSprite( startpos, thickness * 2, thickness * 2, color or Color( 255, 255, 255, 255 ) )
end

RenderUTIL.renderReflection = function( hit, aimvec, normal, thickness, color )
	local reflect = aimvec - ( normal:Dot( aimvec ) ) * normal * 2
	local endpos = hit - reflect * 100

	if normal != Vector( 0, 0, 0 ) then
		DrawLine( hit, endpos, thickness, color )
	end

	/*local trace = util.TraceLine( { start = hit, 
								  endpos = endpos,
								  filter = { ball } } )

	local aimvec = ( endpos - trace.HitPos ):GetNormal()
	local normal = trace.HitNormal

	DrawReflections( trace.HitPos, aimvec, normal )*/
end

RenderUTIL.renderBox = function(pos, min, max, bcolor)
	render.SetMaterial( color )
	render.DrawBox( pos, Angle(0,0,0), min, max, bcolor or Color(255,255,255,255) )
end

RenderUTIL.renderPlane = function(pos, normal, width, height, bcolor)
	local vec = normal:Angle()

	render.SetMaterial( color )
	render.DrawBox( pos, vec, Vector(0,-width,-height), Vector(0.01,width,height), bcolor or Color(0,0,255,150) )
end

RenderUTIL.renderArrowOnPlane = function(pos, normal, dir, width, height, bcolor)
	local vec = normal:Angle() + Angle(0,0,180)
	
	vec:RotateAroundAxis(normal, dir)
	pos = pos + vec:Up() * height

	render.SetMaterial( arrow )
	render.DrawBox( pos, vec, Vector(0,-width,-height), Vector(0.01,width,height), bcolor or Color(255,0,0,255) )
end

RenderUTIL.renderAxis = function(pos, vec)
	vec = vec:Angle()

	render.SetMaterial( color )
	render.DrawBox(pos, vec, Vector(0,-0.2,-0.2), Vector(6,0.2,0.2), Color(0,0,255,255))
	render.DrawBox(pos, vec, Vector(-0.2,-0.2,0), Vector(0.2,0.2,6), Color(255,0,0,255))
	render.DrawBox(pos, vec, Vector(-0.2,0,-0.2), Vector(0.2,6,0.2), Color(0,255,0,255))
end

RenderUTIL.renderPutter = function( draw, ball )
	if draw then
		if !IsValid( Putter ) then
			Putter = ClientsideModel( putter )
		end

		local normal = RenderSettings.aimplane
		local dir = RenderSettings.direction
		local dist = math.Clamp( ( Swing.power / 5 ), 5, 40 )

		// Animate the swing
		if LocalPlayer().Swung then
			dist = 2
		end

		if !PutterDist then
			PutterDist = dist
		end

		PutterDist = math.Approach( PutterDist, dist, FrameTime() * 120 )

		local vec = normal:Angle() + Angle( 90, 90, PutterDist / 3 )
		vec:RotateAroundAxis( normal, dir )
		//vec.p = 0

		local color = Color(255,255,255)

		Putter:SetColor( Color( color.r, color.g, color.b, 255 ) )
		Putter:SetPos( ball:GetPos() + Vector( 0, 0, -72 ) + vec:Right() * -PutterDist  )
		Putter:SetRenderAngles( vec )
		Putter:SetModelScale( 1.75, 0 )
		Putter:DrawModel()
	else
		if IsValid( Putter ) then
			Putter:Remove()
			Putter = nil
		end
	end
end

local function DrawMinigolf( ball )
	if IsValid( ball ) && ball:IsReady() && Swing.power > 0 then
		/*local perc = 1 - ( Swing.power / MaxPower )
		local color = Color( 255, 255 * perc, 255 * perc )*/
		local color = Color(255,255,255)

		RenderUTIL.renderArrowOnPlane(
			RenderSettings.target,
			RenderSettings.aimplane, 
			RenderSettings.direction, 
			RenderSettings.arWidth, 
			RenderSettings.arHeight,
			Color( color.r, color.g, color.b )
		)
	end
end

hook.Add("PostDrawTranslucentRenderables","golftransrenderpre", function()
	local ball = LocalPlayer().GolfBall

	if IsValid( ball ) then
		local trace = ball:GetDownTrace()

		if trace.Entity && !trace.HitWorld then
			DrawMinigolf( ball )
		end
	end
end)

hook.Add("PreDrawTranslucentRenderables","golftransrenderpre", function()
	local ball = LocalPlayer().GolfBall

	if IsValid( ball ) then
		local trace = ball:GetDownTrace()

		if trace.HitWorld then
			DrawMinigolf( ball )
		end
	end
end)
	
end

if SERVER then

	function RealPutt( ball, vec )
		if !IsValid(ball) then return end
			if vec:IsZero() then return end
		local phys = ball:GetPhysicsObject()
		local ply = ball:GetOwner()
		--local oldputts = ply:Swing()
		ball:EnableMotion( true )
		phys:SetVelocity(vec)
		phys:SetDamping( 0.015, 2 )
	end

	local swingSounds = { 125, 100, 50, 0 }

	function Putt( self, ball, power, vec )
		--if !ball:IsReady() then return end

		if !ball then
			ball = self.GolfBall
		end

		// Play swing sound
		for _, snd in ipairs( swingSounds ) do
			if power >= snd then
				ball:EmitSound( SOUND_SWING .. snd .. ".wav", 100, math.random( 80, 120 ) )
				break
			end
		end

		// Effect
		local edata = EffectData()
		edata:SetOrigin( ball:GetPos() )
		edata:SetStart( Vector( power, power, power ) )
		edata:SetEntity( self )
		util.Effect( "golfhit", edata, true, true )

		// sv_controls.lua
		RealPutt( ball, vec )

	end

	concommand.Add( "gmt_minigolf_putt", function( ply, cmd, args ) 
		local ball = ply.GolfBall
		local delta = Vector( args[1], args[2], args[3] )
		local target = ball:GetPos() + Vector(0,0,-3)
		local Swing = {}
		
		Swing.midpoint = target + delta / 2
		Swing.delta = delta
		Swing.power = math.Clamp( delta:Length(), 0, 300 )
		Putt(ply, ball, Swing.power, (delta*4)*1.325)
	end)
end

function ENT:IsReady()
	return self.Ready
end

function ENT:SetReady( isready )
	self.Ready = isready
end

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
	self:GetOwner().GolfBall = self
	self:GetOwner():SetNoDraw(true)
	if self:GetOwner().CosmeticEquipment then
		for k,v in pairs(self:GetOwner().CosmeticEquipment) do
			self:GetOwner():SetNoDraw( true )
		end	
	end
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

			local color = Color(255,255,255)

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

function ENT:OnRemove()

	local ply = self:GetOwner()

	if ply.CosmeticEquipment then
		for k,v in pairs(ply.CosmeticEquipment) do
			v:SetNoDraw( false )
		end	
	end

	ply:SetNoDraw(false)
	ply.GolfBall = nil
end

function ENT:Think()

	local owner = self:GetOwner()
	if !IsValid( owner ) then
		if SERVER then
			self:Remove()
		end
		return
	end

	--if self.IsPocketed then return end

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

	--self:TraceDown()

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
	local filtered = ents.FindByClass( "gmt_golfball" )

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

	--if self.TouchedWater then return end

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
		self.Color = Color(255,255,255)
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

	if owner == LocalPlayer() || !owner:Alive() then return end

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
	local color = Color(255,255,255)

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

