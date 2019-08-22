-----------------------------------------------------
module( "UCHAnim", package.seeall )

TYPE_PIG = 1
TYPE_GHOST = 2

function SetupPlayer( ply, id )

	--if not ply:Alive() then return end

	if id == TYPE_PIG then

		local pigmodel = "models/uch/pigmask.mdl"
		if ply:GetModel() != pigmodel then
			ply._OldModel = ply:GetModel()
		end

		ply:SetModel( pigmodel )
		ply.UCHType = TYPE_PIG

		ply:SetBodygroup( 2, 1 )
		ply:SetBodygroup( 1, 0 )
		ply:SetSkin( 3 )

	end

	if id == TYPE_GHOST then

		local ghostmodel = "models/uch/mghost.mdl"
		if ply:GetModel() != ghostmodel then
			ply._OldModel = ply:GetModel()
		end

		ply:SetModel( ghostmodel )
		ply.UCHType = TYPE_GHOST

		if ply.IsVIP && ply:IsVIP() then
			ply:SetBodygroup( 1, 1 )
		else
			ply:SetBodygroup( 1, 0 )
		end

		ply:DrawWorldModel( false )

	end

	if Hats then
		Hats.UpdateWearables( ply )
	end

end

if SERVER then
	hook.Add( "PlayerThink", "UCHPlayerThink", function( ply )

		if UCHAnim.IsGhost( ply ) then
			ply:DrawWorldModel( false )
		end

		// Disable cape and stuff
		if UCHAnim.ValidPlayer( ply ) then
			if ply:GetModelScale() != 1 then
				ply:SetBodygroup( 2, 0 )
			else
				ply:SetBodygroup( 2, 1 )
			end
		end

	end )
end

hook.Add( "PlayerFootstep", "UCHPlayerFootstep", function( ply, pos, foot, sound, volume, rf )

	if UCHAnim.IsGhost( ply ) then
		return true
	end

end )

hook.Add( "NoUpdatePlayerModel", "UCHNoUpdateModel", function( ply )
	return UCHAnim.ValidPlayer( ply )
end )

function ClearPlayer( ply )

	ply.UCHType = 0

	if ply._OldModel then
		ply:SetModel( ply._OldModel )
	end

	ply:DrawWorldModel( true )

	if Hats then
		Hats.UpdateWearables( ply )
	end

end

function ValidPlayer( ply )
	return IsGhost( ply ) || IsPig( ply )
end

function IsGhost( ply )
	return ply:GetModel() == "models/uch/mghost.mdl"
end

function IsPig( ply )
	return ply:GetModel() == "models/uch/pigmask.mdl"
end

function GetIdleSequence( ply )

	if IsGhost( ply ) then return "idle1" end
	if IsPig( ply ) then return "idle" end

end

function AnimatePig( ply, velocity )

	local len2d = velocity:Length2D()

	if ply:OnGround() then

		if len2d > 0 then

			if len2d > 300 then
				ply.CalcSeqOverride = "run"
			else
				ply.CalcSeqOverride = "walk"
			end

			if ply:Crouching() then
				ply.CalcSeqOverride = "crawl"
			end

		else

			if ply:Crouching() then
				ply.CalcSeqOverride = "crouchidle"
			end

		end

	else

		ply.CalcSeqOverride = "jump"

	end

	/*if ply:GetNet( "EmoteID" ) == 13 then // is taunting
		ply.CalcSeqOverride = "taunt2"
	end

	if ply:GetNet( "EmoteID" ) == 12 then // is taunting/wave
		ply.CalcSeqOverride = "taunt"
	end*/

	if ply:WaterLevel() > 0 && !( ply:IsOnGround() && ply:WaterLevel() <= 2 ) then

		local vel = ply:GetVelocity()
		vel.z = 0

		if vel:Length() > 5 then

			ply.CalcSeqOverride = "swim"

		else

			ply.CalcSeqOverride = "swimidle"

		end

	end

end

function AnimateGhost( ply, velocity )

	local len2d = velocity:Length2D()

	local seq = "idle1"

	if len2d > 0 then

		if ply:IsVIP() then
			seq = "walk2"
		else
			seq = "walk"
		end

	else

		if ply:IsVIP() then
			seq = "idle2"
		end

	end

	ply.LastOogly = ply.LastOogly or 0
	ply.LastSippyCup = ply.LastSippyCup or 0

	if CurTime() >= ply.LastOogly then
		ply.LastOogly = CurTime() + math.Rand( 10, 20 )
		ply:AnimRestartGesture( GESTURE_SLOT_GRENADE, ACT_GESTURE_RANGE_ATTACK2, true )
	end

	if ply:IsVIP() && CurTime() >= ply.LastSippyCup then

		ply.LastSippyCup = CurTime() + math.Rand( 20, 40 )
		ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GESTURE_MELEE_ATTACK1, true )

		if seq == "idle2" then
			timer.Simple( 2, function()

				if IsValid( ply ) && IsGhost( ply ) then
					local eff = EffectData()
						eff:SetOrigin( ply:GetPos() )
						eff:SetEntity( ply )
					util.Effect( "wine_splash", eff )
				end
			end )
		end

	end

	ply.CalcSeqOverride = seq

end

hook.Add( "UpdateAnimation", "UCHUpdateAnimation", function( ply, velocity, maxseqgroundspeed )

	if UCHAnim.ValidPlayer( ply ) then

		local eye = ply:EyeAngles()

		local estyaw = math.Clamp(  math.atan2( velocity.y, velocity.x ) * 180 / math.pi, -180, 180  )
		local myaw = math.NormalizeAngle( math.NormalizeAngle( eye.y ) - estyaw )

	    // set the move_yaw ( because it's not an hl2mp model )
		ply:SetPoseParameter( "move_yaw", -myaw )

		local len2d = velocity:Length2D()
		local rate = 1.0

		if len2d > 0.5 then
			rate = ( len2d * 0.01 ) / maxseqgroundspeed
		end

		ply.SmoothBodyAngles = ply.SmoothBodyAngles || eye.y

		local pp = ply:GetPoseParameter( "head_yaw" )

		if ( pp > .9 || pp < .1 || len2d > 0 ) then

			ply.SmoothBodyAngles = math.ApproachAngle( ply.SmoothBodyAngles, eye.y, 5 )

			local y = ply.SmoothBodyAngles

			// correct player angles
			ply:SetLocalAngles(  Angle( 0, y, 0 )  )

			/*if CLIENT then

				local rang = ply:GetRenderAngles()

				//local diff = ( math.abs( eye.y ) - math.abs( rang.y))

				if len2d <= 0 then
					local num = 65

					if ply.IsGhost then
						num = 25
					end

					if pp < .1 then
						rang.y = ( rang.y - num )
					else
						rang.y = ( rang.y + num )
					end
				end

				local diff = math.abs( math.AngleDifference( eye.y, rang.y ) )

				local num = diff * .12

				ply.SmoothBodyAnglesCL = ply.SmoothBodyAnglesCL || eye.y

				ply.SmoothBodyAnglesCL = math.ApproachAngle( ply.SmoothBodyAnglesCL, eye.y, num )

				ply:SetRenderAngles( Angle( 0, ply.SmoothBodyAnglesCL, 0 ) )

			end*/

		end

		rate = math.Clamp( rate, 0, 1 )
		ply:SetPlaybackRate( rate )

	end

end )

hook.Add( "CalcMainActivity", "UCHCalcMainActivity", function( ply, velocity )

	if UCHAnim.ValidPlayer( ply ) then

		ply.CalcIdeal = ACT_IDLE
		ply.CalcSeqOverride = "idle"

		if UCHAnim.IsGhost( ply ) then
			UCHAnim.AnimateGhost( ply, velocity )
			return ply.CalcIdeal, ply:LookupSequence( ply.CalcSeqOverride )
		end

		if UCHAnim.IsPig( ply ) then
			UCHAnim.AnimatePig( ply, velocity )
		end

		return ply.CalcIdeal, ply:LookupSequence( ply.CalcSeqOverride )

	end

end )

hook.Add( "DoAnimationEvent", "UCHDoAnimationEvent", function( ply, event, data )

	if UCHAnim.ValidPlayer( ply ) then

		if event == PLAYERANIMEVENT_ATTACK_PRIMARY then

			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true )

			return ACT_VM_PRIMARYATTACK

		elseif event == PLAYERANIMEVENT_JUMP then

			ply:AnimRestartMainSequence()

			return ACT_INVALID

		end

		return nil

	end

end )

hook.Add( "Move", "UCHGhostMove", function( ply, move )

	if !UCHAnim.IsGhost( ply ) || IsValid( ply.BallRaceBall ) then return end

	if !ply:IsOnGround() then

		local vel = ply:GetVelocity()

		if ply:KeyDown( IN_JUMP ) then

			local num = math.Clamp( vel.z * -.18, 0, 75 )
			num = num * .1

			vel.z = ( vel.z + ( 32 + ( 5 * num ) )  )
			vel.z = math.Clamp( vel.z, -250, 125 )

			if ply:KeyDown( IN_DUCK ) then
				vel = ply:GetAimVector() * 400
			end

		end

		if ply:KeyDown( IN_SPEED ) && !ply:KeyDown( IN_JUMP ) then

			vel.z = 9

		end

		move:SetVelocity( vel )

	end


end )

function RestartAnimation( ply )

	ply:AnimRestartMainSequence()

	umsg.Start( "UC_RestartAnimation" )
		umsg.Entity( ply )
	umsg.End()

end

function Taunt( ply, taunt )

	ply:SetCycle( 0 )
	local seq = ply:LookupSequence( taunt )
	ply:ResetSequence( seq )

	RestartAnimation( ply )

end

if CLIENT then

	usermessage.Hook( "UC_RestartAnimation", function( um )

		local ply = um:ReadEntity()
		if IsValid( ply ) then
			if ply.AnimRestartMainSequence then
				ply:AnimRestartMainSequence()
			end
		end

	end )

end
