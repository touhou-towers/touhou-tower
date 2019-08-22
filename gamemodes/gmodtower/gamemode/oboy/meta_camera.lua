
// Types of cameras
STATIC 			= 1 //does not move. just point/angle
FUNCTION 		= 2 //lua controlled. just like calcview
SPLINE 			= 3 //looping spline track
SPLINE_TIMED 	= 4 //timed spline track (start-finish)

local meta = FindMetaTable( "Player" )
if !meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:SetCamera( location, TransitionLength )

	TransitionLength = TransitionLength or 0.0

	if SERVER then 
		umsg.Start( "ChangeView", self )
			umsg.String( location )
			umsg.Float( TransitionLength )
		umsg.End()
	else
		if !camsystem.Locations[location] then return end
		camsystem.SetLocation( location, TransitionLength )

		RunConsoleCommand( "mat_motion_blur_enabled", 0 )
	end

	self.CurrentView = location
	self.UsingCamera = true

end

function meta:GetCamera()
	return self.CurrentView
end

TEAM_CAMERA = 0