
-----------------------------------------------------
function GM:PlayerBindPress( ply, bind, pressed )
	if bind == "+menu" || bind == "invnext" || bind == "invprev" then
		if ( !pressed ) then return false end
		RunConsoleCommand("zm_swapwep")
		return true
	end
	if ( bind == "+speed" ) then
		RunConsoleCommand( "zm_power" )
		return true
	end
	if ( bind == "+menu_context" ) && pressed then
		RunConsoleCommand( "zm_lockwep" )
		return true
	end
	if bind == "+zoom" || bind == "+duck" || bind == "+jump" then
		return true
	end
	if bind == "+score" then
		RunConsoleCommand( "-attack" )
		return true
	end
end
function GM:GUIMousePressed( mcode )
	if mcode == MOUSE_LEFT then
		RunConsoleCommand( "+attack" )
	elseif mcode == MOUSE_RIGHT then
		RunConsoleCommand( "zm_specialitem" )
	end
end
function GM:GUIMouseReleased( mcode )
	if mcode == MOUSE_LEFT then
		RunConsoleCommand( "-attack" )
	end
end
/*local DoublePressTime = nil
function GM:KeyPress()
	if IN_RIGHT || IN_LEFT || IN_FORWARD || IN_BACK then
		if DoublePressTime && DoublePressTime > CurTime() then
			RunConsoleCommand("+speed")
			return
		end
		DoublePressTime = CurTime() + 0.08
	end
end
function GM:KeyRelease()
	if IN_RIGHT || IN_LEFT || IN_FORWARD || IN_BACK then
		RunConsoleCommand("-speed")
	end
end*/
local function Trace( ply, enemy )
	if !IsValid( enemy ) then return false end
	local tr = util.TraceLine({
		start = ply:GetPos(),
		endpos = enemy:GetPos() + Vector( 0, 0, 20 ),
		filter = { FadeableEnts }
	})
	return !tr.HitWorld
end
local HumanZombies = { "zm_npc_zombie", "zm_npc_crimson", "zm_npc_mutant" }
local function GetEntOffsetPos( ent )
	if ent:IsNPC() then
		// Get proper bone positions for a human-like zombies
		if table.HasValue( HumanZombies, ent:GetClass() ) then
			local Index = ent:LookupBone( "ValveBiped.Bip01_Spine2" )
			if Index then
				local Bonepos = ent:GetBonePosition( Index )
				pos = BonePos
			else
				pos = ent:GetPos()
			end
 		//Same as above, but with the dog
		elseif ent:GetClass() == "zm_npc_dog" then
			pos = ent:GetPos()
 		//Same as above, but with the spider
		elseif ent:GetClass() == "zm_npc_spider" then
			pos = ent:GetPos() + Vector( 0, 0, -50 )
 		//Unknown NPC?
		else
			pos = ent:GetPos()
		end
	 // If it's a prop_physics, just get the position normally
	else
		pos = ent:GetPos() + Vector( 0, 0, -20 )
	end
	return pos
end
// Pretty much anything explosive, if you want something else you want the player to aim at, add it here
local Shootables = {
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/propane_tank001a.mdl",
	//"models/props_explosive/explosive_butane_can.mdl",
	//"models/props_explosive/explosive_butane_can02.mdl",
}
local function IsValidBreakable( ent )
	return table.HasValue( Shootables, ent:GetModel() )
end
local function SnapToEntityBelowCursor( radius, offset, maxsnapdist )
	// Trace down from cursor for the position
	local cursorvec = gui.ScreenToVector(gui.MousePos()) --LocalPlayer():GetAimVector()
	local origin = LastCameraPosition
	local trace = util.TraceLine( { start = origin,
									endpos = origin + cursorvec * 9000,
									filter = { FadeableEnts, ents.FindByClass("zm_npc_*") } } )
	local pos = trace.HitPos + offset
	// Now let's find an enemy
	local enemy = NULL
	local position = Vector( 0, 0, 0 )
	// DEBUG
	//debugoverlay.Sphere( pos, radius, .05, Color( 255, 0, 0 ) )
	for id, ent in pairs( ents.FindInSphere( pos, radius ) ) do
		if IsValid( ent ) && ( ent:IsNPC() || IsValidBreakable( ent ) ) /*&& Trace( LocalPlayer(), ent )*/ then
			local entpos = GetEntOffsetPos( ent ) or ent:GetPos()
			local dist = entpos:Distance( pos )
			if dist < radius && dist < maxsnapdist then
				enemy = ent
				position = entpos
				radius = dist // keep looking
			end
		end
	end
	// DEBUG
	//LocalPlayer():ChatPrint( tostring( enemy ) )
	return position, enemy
end
function GM:CreateMove( cmd )
	-- Disable shooting during not playing or when scoreboard is open
	if self:GetState() != STATE_PLAYING --[[or ( ValidPanel( Scoreboard.Gui ) and Scoreboard.Gui:IsVisible() )]] then
		if cmd:KeyDown( IN_ATTACK ) then
			cmd:SetButtons( cmd:GetButtons() - IN_ATTACK )
		end
	end
	if not LocalPlayer():Alive() then return end
	-- Handle moving
	cmd:SetForwardMove( cmd:GetForwardMove() )
	cmd:SetSideMove( cmd:GetSideMove() )
	-- Handle aiming
	local pos = LocalPlayer():GetPos():ToScreen()
	local mx, my = gui.MousePos()
	local px = pos.x
	local py = ScrH() - pos.y
	local mx = mx
	local my = ScrH() - my
	local angle = 0
	local x,y
	if px < mx then
		x = mx - px
		if py < my then
			y = my - py
			angle = math.deg( math.atan(y/x) )
			angle = 90 - angle
		else
			y = py - my
			angle = math.deg( math.atan(y/x) )
			angle = 90 + angle
		end
	else
		x = px - mx
		if py < my then
			y = my - py
			angle = math.deg( math.atan(y/x) )
			angle = 270 + angle
		else
			y = py - my
			angle = math.deg( math.atan(y/x) )
			angle = 270 - angle
		end
	end

	//newAngle = LerpVector( ( newAngle / angle ) * FrameTime(), newAngle, angle )
	-- Handle snapping
	local ang = Angle( 0, 0, 0 )
	local aimvector = LocalPlayer():GetAimVector()
	local shootpos = LocalPlayer():GetShootPos() + (aimvector * -100) //make the cone start a little behind the player
	local entities = ents.GetAll()
	local snapEnt = nil
	/*local vec, ent = SnapToEntityAimvector( shootpos, aimvector, 750, 40 ) //TODO: Make max distance dependent on world distance of mouse to center of screen
	if IsValid( ent ) && vec then
		local angvec = vec - LocalPlayer():GetPos()
		ang = angvec:Angle()
	end*/
	-- Snap to enemies below cursor
	if cmd:KeyDown( IN_ATTACK ) && GAMEMODE:IsPlaying() then
		// Filter out melee weapons
		if LocalPlayer().GetActiveWeapon && LocalPlayer():GetActiveWeapon() && !LocalPlayer():GetActiveWeapon().IsMelee then
			// Finally, let's find some ents
			local vec, ent = SnapToEntityBelowCursor( 128, Vector( 0, 0, 20 ), 1024 )
			// Got one, snap away!
			if IsValid( ent ) && vec then
				local angvec = vec - LocalPlayer():GetPos()
				ang = angvec:Angle()
				snapEnt = ent
			end
		end
	end

	-- Focus power (Mercenary)
	if LocalPlayer():GetNWBool( "IsFocused" ) then
		local radius = 256
		local enemy = nil
		for _, ent in pairs( entities ) do
			if !IsValid( ent ) || !ent:IsNPC() || !Trace( LocalPlayer(), ent ) then continue end
			local dist = ent:GetPos():Distance( LocalPlayer():GetPos() )
			if dist < radius then
				enemy = ent
				radius = dist
			end
		end
		if IsValid( enemy ) then
			local angvec = enemy:GetPos() - LocalPlayer():GetPos()
			ang = angvec:Angle()
			cmd:SetViewAngles( Angle( math.NormalizeAngle( ang.p ), math.NormalizeAngle( ang.y ), 0 ) )
			RunConsoleCommand( "+attack" )
			LocalPlayer().IsFocusShooting = true
			LocalPlayer().FocusEnemy = enemy
			local toscr = enemy:GetPos():ToScreen()
			gui.SetMousePos( toscr.x, toscr.y )
		else
			RunConsoleCommand( "-attack" )
			LocalPlayer().IsFocusShooting = false
			LocalPlayer().FocusEnemy = nil
			cmd:SetViewAngles( Angle( 0, -angle, 0 ) )
		end
		return
	end
	-- Reset focus power (Mercenary)
	if LocalPlayer().IsFocusShooting then
		RunConsoleCommand( "-attack" )
		LocalPlayer().IsFocusShooting = nil
	end
	-- Handle normal shooting/snapping
	if snapEnt then
		cmd:SetViewAngles( Angle( math.NormalizeAngle( ang.p ), math.NormalizeAngle( ang.y ), 0 ) )
	else
		cmd:SetViewAngles( Angle( 0, -angle, 0 ) )
	end
end
LastCameraPosition = Vector( 0, 0, 0 )
function GM:CalcView( ply, pos, ang, fov )
	local dist = 350
	if !ply:Alive() then
		dist = 550
	end
	local followent = nil
	if self:GetState() == STATE_INTERMISSION then
		followent = GetGlobalEntity( "Helicopter" )
		if IsValid( followent ) then
			pos = followent:GetPos()
		end
	end
	// Offset camera
	local center = pos + Vector( -150, 0, dist )
	local ang = Angle( 65, 0, 0 )
	// Apply mouse controls
	//Make the origin of the mouse the center of the screen
	local mX, mY = gui.MousePos()
	local normX = ( 0.5 - mX / ScrW() ) / 0.5
	local normY = ( 0.5 - mY / ScrH() ) / 0.5
	local mousedist = dist * 0.4
	local maxdist = 300
	local speed = math.Clamp( ply:GetVelocity():Length() / 50, 1, 1.5 )
	speed = speed * math.Clamp( ConVarCameraSpeed:GetInt(), 1, 5 )
	if !ply:Alive() then
		mousedist = 1250
		maxdist = 1800
		speed = .55
	end
	if self:GetState() == STATE_UPGRADING then
		speed = .15
	end
	if IsValid( followent ) then
		speed = 5
	end
	local center = center + Vector( normY * mousedist, normX * mousedist, 0 )
	// Lerp
	local dist = math.max( center:Distance( LastCameraPosition ), maxdist )
	local pow = math.pow( dist / maxdist, 2 ) * FrameTime() * speed
	LastCameraPosition = LerpVector( math.Clamp( pow, 0, 1 ), LastCameraPosition, center )
	return {
		["origin"] = LastCameraPosition,
		["angles"] = ang
	}
end
