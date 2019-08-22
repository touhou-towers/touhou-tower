
// TODO, should really be using camsystem.AddFunctionLocation( "Playing", CalcViewPlaying )
// to make you able to switch to the playing camera after level overview shots and shit
// like that.

-----------------------------------------------------
camera = {

	Pos = Vector(0,0,0),

	Shake = 0,

	Pitch = 0,

	FinalPitch = 0,

	Roll = 0,

	Yaw = 0,

	FOV = 0,

	Dist = 0,

	FinalDist = 0,

}


camsystem.AddFunctionLocation( "Playing", TemporarySKCalcView )

hook.Add("CalcView","TemporarySKCalcView", function( ply, origin, angles, fov )



	local kart = ply:GetKart()



	if ply:Team() == TEAM_CAMERA then return end


	if IsValid( kart ) then


		local firstperson = ( GetConVarNumber( "sk_camera" ) == 2 )

		local lookbackwards = input.IsMouseDown( MOUSE_RIGHT )

		local ang = kart:GetAngles()



		// Rotate around when upside down

		if kart.GetUpTrace && kart:HitWorld( kart:GetUpTrace() ) then

			ang:RotateAroundAxis( ang:Forward(), 180 )

		end



		camera.FinalDist = ApproachSupport2( camera.FinalDist, camera.Dist, 15 )



		local up = 48

		if firstperson then up = 19 end



		local center = kart:GetPos() + ang:Up() * ( up + ( kart.JumpVel or 0 ) )

		local vel = kart:GetVelocity()

		local speed = vel:Length()

		local dist = camera.FinalDist + math.Fit( speed, 0, 600, 130, 145 )



		// Trace for walls

		local tr = util.TraceLine( { start = center, endpos = center + ( ang:Forward() * -dist * 0.95 ), filter = { ents.FindByClass( "sk_item*" ) } } )

		if tr.HitWorld && tr.Fraction < 1 then

			dist = dist * ( tr.Fraction * 0.95 )

		end



		if firstperson then dist = 5 end



		// Look behind

		if lookbackwards then

			if firstperson then

				dist = -dist * -3

			else

				dist = -dist

			end

		end



		// Final pos

		local Pos = center + ( ang:Forward() * -dist * 0.95 )



		// Turn direction leaning

		local vec = ang:Right() * ang:Right():Dot(vel) * -0.08

		if !firstperson then

			Pos = Pos + vec

		end



		// In air lean

		if speed > 100 && kart.IsInAir && game.GetMap() != "gmt_sk_island01_fix" then

			camera.Pitch = ApproachSupport2( camera.Pitch, 15, 2 )

		else

			camera.Pitch = ApproachSupport2( camera.Pitch, 0, 2 )

		end

		Pos.z = Pos.z + ( camera.Pitch * 4 )



		local easePitch = ang.p + camera.Pitch

		if game.GetMap() != "gmt_sk_island01_fix" then
			if kart.IsInAir then easePitch = camera.Pitch end

		end


		camera.FinalPitch = ApproachSupport2( camera.FinalPitch, easePitch, 150 )



		// Turn with Q/E

		/*local turnAmount = 20

		if input.IsKeyDown( KEY_Q ) then

			camera.Yaw = ApproachSupport2( camera.Yaw, turnAmount, 2 )

		elseif input.IsKeyDown( KEY_E ) then

			camera.Yaw = ApproachSupport2( camera.Yaw, -turnAmount, 2 )

		else

			camera.Yaw = ApproachSupport2( camera.Yaw, 0, 2 )

		end*/



		camera.Roll = ang.r //ApproachSupport2( camera.Roll, ang.r, 30 )

		if game.GetMap() != "gmt_sk_island01_fix" then
			if kart.IsInAir then camera.Roll = 0 end

		end


		// Ease

		if !firstperson then

			camera.Pos.x = ApproachSupport2( camera.Pos.x, Pos.x, 80 )

			camera.Pos.y = ApproachSupport2( camera.Pos.y, Pos.y, 80 )

			camera.Pos.z = ApproachSupport2( camera.Pos.z, Pos.z, 120 )

		else

			camera.Pos = Pos

		end





		local newAngles = Angle( camera.FinalPitch, ang.y + camera.Yaw, camera.Roll )



		// Reverse angles

		if lookbackwards then

			newAngles:RotateAroundAxis( newAngles:Up(), 180 )

			newAngles:RotateAroundAxis( newAngles:Right(), -15 )

		end



		ply:SetEyeAngles( newAngles )



		if camera.FOV == 0 then camera.FOV = fov end



		// Boost effects

		if ( kart.GetIsBoosting && kart:GetIsBoosting() ) || ply.IsTeleporting then



			// Shake with boost

			camera.Shake = camera.Shake + .015





			if ply.IsTeleporting then

				// Adjust FOV with teleport

				camera.FOV = math.Clamp( camera.FOV + .75, fov, fov * 2 )

			else

				// Adjust FOV with boost

				camera.FOV = math.Clamp( camera.FOV + 0.2, fov, fov * 1.35 )

			end



		else



			if camera.Shake <= 0 then

				camera.Shake = 0

			else

				camera.Shake = camera.Shake - .085

			end



			if camera.FOV <= fov then

				camera.FOV = fov

			else

				camera.FOV = camera.FOV - .085

			end



		end



		// Shake

		if camera.Shake > 0 then

			camera.Pos = camera.Pos + VectorRand() * camera.Shake

		end



		// Drunk


    // TODO, use Anomaladox' GetNet() wrapper.
		/*if ply:GetNet("BAL") > 0 then

			local multiplier = ( 50 / 100 ) * ply:GetNet("BAL")

			newAngles.pitch = newAngles.pitch + math.sin( RealTime() ) * multiplier

			newAngles.roll = newAngles.roll + math.cos( RealTime() ) * multiplier

		end
*/


		return {

			origin = camera.Pos,

			angles = newAngles,

			fov = camera.FOV

		}



	end



end
)
