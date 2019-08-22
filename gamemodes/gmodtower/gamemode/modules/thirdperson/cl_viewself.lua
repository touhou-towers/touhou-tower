
hook.Add( "InputMouseApply", "ThirdPersonViewSelfMouseApply", function( cmd, x, y, ang )

	local ply = LocalPlayer()

	if ply.ViewingSelf then

		ThirdPerson.ViewSelfAngSafeGuard( ply )

		local ang = ply.ViewSelfAng
		local yaw = ( x * -GetConVar( "m_yaw" ):GetFloat() )
		local pitch = ( y * GetConVar( "m_pitch" ):GetFloat() )
		
		ang.y = ang.y + yaw
		ang.p = ang.p + pitch

		ply.ViewSelfAng = ang

		return true

	end

end )

hook.Add( "GetMotionBlurValues", "ThirdPersonViewSelfBlurValues", function( x, y, fwd, spin )
	if LocalPlayer().ViewingSelf then
		return 0, 0, 0, 0
	end
end ) 