local Debug = false
local curMap = {}
curMap.Points = {}

concommand.Add( "cam_add", function( ply, cmd, args )

	if !ply:IsAdmin() then return end

	local pos = ply:GetPos() + Vector( 0, 0, 64 )
	local ang = ply:EyeAngles()
	table.insert( curMap.Points, { pos, ang } )

	if (!curMap.Controller) then
		curMap.Controller = Catmull.Controller:New()
	end

	curMap.Controller:AddPointAngle( pos, ang, 1.0 )

	if #curMap.Controller.PointsList > 3 then
		curMap.Controller:CalcEntireSpline()
	end
end )

concommand.Add( "cam_debug", function( ply, cmd, args ) 

	if !ply:IsAdmin() then return end
	Debug = !Debug

	if Debug then
		ply:PrintMessage( HUD_PRINTCONSOLE, "Cam Debug is ON\n" )
	else
		ply:PrintMessage( HUD_PRINTCONSOLE, "Cam Debug is OFF\n" )
	end

end )

concommand.Add( "cam_print", function( ply, cmd, args )

	if !ply:IsAdmin() then return end

	MsgN( "spline = Catmull.Controller:New()" )
	MsgN( "spline:Reset()" )

	for _, point in pairs( curMap.Points ) do
		local pos = point[1]
		local ang = point[2]
		MsgN( "spline:AddPointAngle( Vector( " .. math.Round( pos.x ) .. ", " .. math.Round( pos.y ) .. ", " .. math.Round( pos.z ) .. " ), Angle( " .. math.Round( ang.p ) .. ", " .. math.Round( ang.y ) .. ", 0 ), 1.0 )" )
	end

end	)

concommand.Add( "cam_start", function( ply, cmd, args ) 

	if !ply:IsAdmin() then return end

	Debug = !Debug

	spline = Catmull.Controller:New()
	spline:Reset()

	for _, point in pairs( curMap.Points ) do

		local pos = point[1]
		local ang = point[2]

		spline:AddPointAngle( pos, ang, 1.0 )

	end

	camsystem.AddSplineLocation( "Test", spline, 5 )
	ply:SetCamera( "Test", 0 )

end )

concommand.Add( "cam_end", function( ply, cmd, args )

	if !ply:IsAdmin() then return end

	ply:SetCamera( "Playing", 0 )
	RunConsoleCommand( "cam_debug" )
	RunConsoleCommand( "cam_print" )

end )

concommand.Add( "cam_clear", function( ply, cmd, args )

	if !ply:IsAdmin() then return end

	curMap = {}
	curMap.Points = {}
	curMap.Controller = Catmull.Controller:New()

end )

concommand.Add( "cam_remove", function( ply, cmd, args )

	if !ply:IsAdmin() then return end

	table.remove( curMap, #curMap )

end )

hook.Add( "PostDrawTranslucentRenderables", "DrawCameraLocations", function( ply, cmd, args )

	if !LocalPlayer():IsAdmin() then return end

	if !Debug then return end
	if (!curMap.Controller) then return end

	for id, point in pairs( curMap.Controller.PointsList ) do

		local pos = point
		local angle = curMap.Controller.FacingsList[id]:Angle()

		Debug3D.DrawAxis( pos, angle:Forward(), angle:Right(), angle:Up(), 10 )
		Debug3D.DrawSolidBox( pos, angle, Vector(-5,-5,-5), Vector(5,5,5) )

		// Draw the splines
		if #curMap.Controller.PointsList > 3 && id > 1 && id < #curMap.Controller.PointsList - 1 then

			for i=1, curMap.Controller.STEPS do

				local index = i + ((id-1) * curMap.Controller.STEPS) - curMap.Controller.STEPS

				// Draw line connecting
				local nxt = curMap.Controller.Spline[index+1]
				local cur = curMap.Controller.Spline[index]

				if nxt && cur then
					Debug3D.DrawLine( cur, nxt, 15, Color( 255, 255, 255 ) )
				end
				
			end
		end

	end

end )

hook.Add( "Think", "CameraTools", function()

	if !LocalPlayer():IsAdmin() then return end
	if !Debug then return end

	WasLeftClickHeld = IsLeftClickHeld
	WasRightClickHeld = IsRightClickHeld
	IsRightClickHeld = input.IsMouseDown( MOUSE_RIGHT )
	IsLeftClickHeld = input.IsMouseDown( MOUSE_LEFT )

	if IsLeftClickHeld && !WasLeftClickHeld then
		RunConsoleCommand( "cam_add" )
	end

	if IsRightClickHeld && !WasRightClickHeld then
		RunConsoleCommand( "cam_clear" )
	end

end )