
-----------------------------------------------------
hook.Add( "Think", "ControlsThink", function()
	// Handle scoreboard mouse interaction
	--Scoreboard.Customization.EnableMouse = tobool( !LocalPlayer():CanPutt() )
	local ball = LocalPlayer():GetGolfBall()
	if IsValid( ball ) then
		if LocalPlayer():CanPutt() && !IsRightClickHeld then
		
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
	if GAMEMODE:GetState() != STATE_SETTINGS then
		if LocalPlayer()._ClickerEnabled then
			gui.EnableScreenClicker( false )
			LocalPlayer()._ClickerEnabled = false
		end
	end
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
	if !GAMEMODE:IsPlaying() && !GAMEMODE:IsPracticing() then 
		return
	end
	WasLeftClickHeld = IsLeftClickHeld
	WasRightClickHeld = IsRightClickHeld
	IsRightClickHeld = input.IsMouseDown( MOUSE_RIGHT )
	IsLeftClickHeld = input.IsMouseDown( MOUSE_LEFT )
	if IsLeftClickHeld && !WasLeftClickHeld then
		// Has PVS Issues
		if LocalPlayer():IsPocketed() && GAMEMODE:IsPlaying() then
			LocalPlayer():SetCamera( "Playing", 2 )
			LocalPlayer():SpectateNext()
		else
			LocalPlayer():ClearSpectate()
		end
	end
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
	local ball = LocalPlayer():GetGolfBall()
	if !IsValid( ball ) || !LocalPlayer():CanPutt() then return end
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
	--Obtain delta (hit power) and clamp to MaxPower
	local delta = position - target
	local deltaLen = delta:Length()
	
	if deltaLen > MaxPower then
		delta = delta * (MaxPower / deltaLen)
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
	Swing.power 		= math.Clamp( delta:Length(), 0, MaxPower )
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
function GM:GUIMousePressed( mc )
	if mc == MOUSE_LEFT then
		local ball = LocalPlayer():GetGolfBall()
		if IsValid( ball ) && LocalPlayer():CanPutt() && Swing.power > 0 then
			Swing.lastpower = Swing.power
			LocalPlayer().Swung = true
			// sv_controls.lua
			net.Start("MinigolfPutt")
				net.WriteVector( Vector( Swing.delta.x, Swing.delta.y, Swing.delta.z ) )
			net.SendToServer()
			timer.Simple( 1, function()
				LocalPlayer().Swung = false
			end )
		end
	end
end
function GM:PlayerBindPress( ply, bind, pressed )	// For testing...
	if bind == "+menu" then
		//RunConsoleCommand( "minigolf" )
		self:DisplayScorecard( !ValidPanel( Scorecard ) )
	end
	
	if bind == "+menu_context" then
		self:DisplayCustomizer( !ValidPanel( RADIAL ), true )
	end
end