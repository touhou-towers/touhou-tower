module( "camsystem", package.seeall )

//Types of cameras
STATIC 			= 1
FUNCTION 		= 2
SPLINE 			= 3
SPLINE_TIMED 	= 4

Locations = Locations or {}

//time, start value, change in value, duration
local function easeInOutQuad(t, b, c, d)
	t = t/( d/2 );
	if (t < 1) then return c/2*t*t + b end
	t = t - 1;

	return -c/2 * (t*(t-2) - 1) + b;
end

function AddStaticLocation( name, pos, ang )
	local tbl = {}
	tbl.Type = STATIC
	tbl.Position = pos
	tbl.Angles = ang 

	Locations[name] = tbl
end
function AddFunctionLocation( name, func)
	local tbl = {}
	tbl.Type = FUNCTION
	tbl.Function = func

	Locations[name] = tbl
end
function AddSplineLocation( name, catmull, speed )
	local tbl = {}
	tbl.Type = SPLINE
	tbl.Spline = catmull
	tbl.Speed = speed

	Locations[name] = tbl
end
function AddTimedSplineLocation( name, catmull, length )
	local tbl = {}
	tbl.Type = SPLINE_TIMED
	tbl.Spline = catmull
	tbl.Time = length

	Locations[name] = tbl
end

//Set the location and tween between the current location
function SetLocation( name, speed )
	local ply = LocalPlayer()
	//Don't set the view if it is already the current view
	if ply.Location == name then return end

	ply.PreviousLocation = ply.Location
	ply.Location = name
	ply.Approach = CurTime() + ( speed or 1.0 )
	ply.ApproachSpeed = speed
	ply.SplinePercent = 0
	ply.CurrentNode = 2

	if Locations[name] && Locations[name].Type == SPLINE_TIMED then
		ply.EndSplineAt = CurTime() + Locations[name].Time
	end
end

//Return whether the camera system is tweening between two locations for a given player
function IsTweening( ply )
	return ply.Approach && ply.Approach > CurTime()
end

//Perform calculations for timed cameras
local function TimedSplineThink( Catmull, length )
	local ply = LocalPlayer()
	if !ply.EndSplineAt || !Catmull then return end

	//Do some catmull magic
	local totalperc = 1.0 - ( ( ply.EndSplineAt - CurTime() ) / length )
	if totalperc > 1.0 then totalperc = 0.999999 end //hard clamp it

	local nodeperc = 0
	nodeperc, ply.CurrentNode = Catmull:GetLocalPercent( totalperc, #Catmull.PointsList - 2 )

	local pos = Catmull:Point( ply.CurrentNode + 1, nodeperc )
	local ang = Catmull:Angle( ply.CurrentNode + 1, nodeperc )

	return pos, ang
end

//Perform calculations for looping cameras
local function SplineThink( Catmull, speed )
	local ply = LocalPlayer()
	if !Catmull then return end
	ply.SplinePercent = ply.SplinePercent or 0
	ply.CurrentNode = ply.CurrentNode or 2

	//Do some catmull magic
	local mult = Catmull:GetMultiplier(ply.CurrentNode, ply.SplinePercent )
	ply.SplinePercent = ply.SplinePercent + FrameTime() * mult * speed

	if ply.SplinePercent > 1 then
		ply.CurrentNode = ply.CurrentNode + 1

		if ply.CurrentNode > #Catmull.PointsList - 2 then
			ply.CurrentNode = 2
		end

		ply.SplinePercent = 0
	end

	//local totalperc = 1.0 - ( ( ply.EndSplineAt - CurTime() ) / length )
	//if totalperc > 1.0 then 
	//	totalperc = 0 
	//	ply.EndSplineAt = CurTime() + length
	//end //hard clamp it

	//local nodeperc = 0
	//nodeperc, ply.CurrentNode = Catmull:GetLocalPercent( totalperc, #Catmull.PointsList - 2 )

	local pos = Catmull:Point( ply.CurrentNode, ply.SplinePercent )
	local ang = Catmull:Angle( ply.CurrentNode, ply.SplinePercent )

	return pos, ang
end

local view = {}
local function locationThink(location, ply, origin, ang, fov)
	loc = Locations[location]
	if loc == nil || loc.Type == nil then return origin, ang, fov end

	if !view then view = {} end

	view.origin = origin
	view.angles = ang 
	view.fov = fov

	if loc.Type == STATIC then
		view.origin = loc.Position
		view.angles = loc.Angles
	elseif loc.Type == FUNCTION then
		view = loc.Function( ply, origin, ang, fov )
	elseif loc.Type == SPLINE then
		if loc.Spline then
			local pos, ang = SplineThink( loc.Spline, loc.Speed)

			view.origin = pos or view.pos 
			view.angles = ang or view.angles 
		end
	elseif loc.Type == SPLINE_TIMED then
		if loc.Spline then
			local pos, ang = TimedSplineThink( loc.Spline, loc.Time )

			view.origin = pos or view.pos 
			view.angles = ang or view.angles 
		end
	end

	if !view then view = {} end

	return view.origin, view.angles, view.fov
end

hook.Add( "CalcView", "SetView", function( ply, origin, ang, fov)

	if !ply.UsingCamera then return end
	if !ply.Location then ply.Location = "Waiting" end
	if !ply.PreviousLocation then ply.PreviousLocation = "Waiting" end

	local location = ply.Location
	local prevLocation = ply.PreviousLocation

	local view = {}

	local pos, angles, fieldofview = locationThink( ply.Location, ply, origin, ang, fov )

	if (ply.Approach && ply.Approach > CurTime() && pos ) then
		local origin2, ang2, fov2 = locationThink( ply.PreviousLocation, ply, origin, ang, fov )

		local perc = ply.ApproachSpeed - (ply.Approach - CurTime())
		local easeperc = easeInOutQuad(perc, 0, 1.0, ply.ApproachSpeed )
		
		pos = LerpVector( easeperc, origin2, pos )
		angles = LerpAngle(easeperc, ang2, angles  )
		fieldofview = Lerp( easeperc, fov2, fieldofview )
	end


	ply.CameraPos = pos
	view.origin = pos
	view.angles = angles
	view.fov = fieldofview

	return view
end )

usermessage.Hook( "ChangeView", function( um )

	local view = um:ReadString()
	local length = um:ReadFloat()
	local ply = LocalPlayer()

	if IsValid( ply ) then
		ply:SetCamera( view, length )
	end

end )