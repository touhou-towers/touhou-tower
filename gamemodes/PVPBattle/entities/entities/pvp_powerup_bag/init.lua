AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.ActiveTime = 29

function ENT:PowerUpOn( ply )

	ply:SetWalkSpeed( 600 )
	ply:SetRunSpeed( 550 )
	ply.IsPulp = true

	PostEvent( ply, "bag_on" )

end

function ENT:PowerUpOff( ply )

	ply:SetWalkSpeed( 450 )
	ply:SetRunSpeed( 450 )
	ply.IsPulp = false

	PostEvent( ply, "bag_off" )

end

// wall jump
hook.Add( "KeyPress", "PulpVibe_WallJump", function( ply, key )

	if !ply.PowerUp || !ply.IsPulp || ply:IsOnGround() then return end

	local function WallJump( trace, dir, angle )

		if !trace || !dir || !angle then return end

		local tr = util.QuickTrace( ply:GetShootPos(), trace * 40, ply )
		if tr.Hit then

			local up = ply:GetUp()
			local upforce = up * math.random( 300, 320 )
			local moveforce = math.random( 225, 250 )

			ply:ViewPunch( angle )
			ply:SetLocalVelocity( ( dir * moveforce ) + upforce )

		end

	end

	local right = ply:GetRight()
	local left = right * -1
	local forward = ply:GetForward()
	local back = forward * -1

	if ply:KeyDown( IN_FORWARD ) then

		WallJump( back, foward, Angle( 5, 0, 0 ) )

	end
	if ply:KeyDown( IN_BACK ) then

		WallJump( forward, back, Angle( 5, 0, 0 ) )

	end
	if ply:KeyDown( IN_MOVELEFT ) then

		WallJump( right, left, Angle( 0, -5, 0 ) )

	end
	if ply:KeyDown( IN_MOVERIGHT ) then

		WallJump( left, right, Angle( 0, 5, 0 ) )

	end

end )
