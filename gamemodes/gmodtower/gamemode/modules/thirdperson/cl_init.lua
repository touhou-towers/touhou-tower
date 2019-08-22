
ThirdPerson = {}
ThirdPerson.Dist = CreateClientConVar( "gmt_setthirdpersondist", 100, true )

// entities that the camera should go through, should be edited with ThirdPerson.ExcludeEnt
ThirdPerson.IgnoreEnts = {
	"player", // always exclude the player
	"gmt_npc_base"
}

include( "cl_hud.lua" )
include( "cl_viewself.lua" )

function ThirdPerson.Override( ply )

	local forceThird = hook.Call( "ForceThirdperson", GAMEMODE, ply )
	local forceView = hook.Call( "ForceViewSelf", GAMEMODE, ply )

	// Always be in third person...
	if forceThird || forceView then

		ThirdPerson.SaveThirdPersonStatus( ply )
		ply.ThirdPerson = true

		if forceView then
			ply.ViewingSelf = true
		end

	else
		ThirdPerson.RestoreThirdPersonStatus( ply )
	end

	// Disable all
	if hook.Call( "DisableThirdpersonAll", GAMEMODE, ply ) then
		return true
	end

	// Disable view self
	if hook.Call( "DisableViewSelf", GAMEMODE, ply ) then
		ply.ViewingSelf = false
	end

	return false

end

function ThirdPerson.SaveThirdPersonStatus( ply )

	if !ply._StoredThirdperson then
		ply._StoredThirdperson = true
		ply._WasThirdperson = ply.ThirdPerson
	end

end

function ThirdPerson.RestoreThirdPersonStatus( ply )

	if ply._StoredThirdperson then
		ply._StoredThirdperson = false
		ply.ThirdPerson = ply._WasThirdperson
		ply.ViewingSelf = false
	end

end

hook.Add( "CalcView", "GMTThirdPerson", function( ply, origin, angles, fov )

	if ThirdPerson.Override( ply ) then return end

	// there should only be one hook for this, per gamemode
	local ret = hook.Call( "GShouldCalcView", GAMEMODE, ply, origin, angles, fov )

	if ply.ThirdPerson || ret || !ply:Alive() then

		local filters = {}

		ThirdPerson.ShouldDraw = true

		// default values
		local scale = ( ply:GetModelScale() ) * GTowerModels.GetScale( ply:GetModel() )

		// Adjust for bone modifications
		/*if BoneMod && ply.BoneMod != 0 then
			local boneScale = BoneMod:GetBoneScale( ply, "Head1" )
			local boneScaleX = boneScale.x or 1
			if boneScaleX > 1 then boneScaleX = boneScaleX * .5 end

			scale = scale * boneScaleX
		end*/

		local pos = ply:GetPos() + Vector( 0, 0, 75 * scale )
		if !ply:Alive() then
			local rag = ply:GetRagdollEntity()
			if IsValid( rag ) then
				pos = rag:GetPos()
			end
		end

		local ang = angles
		local dist = math.Clamp( ThirdPerson.Dist:GetInt() or 1, 35, 150 )

		// we'll let the gamemode calcview override our position and distance
		local thirdHook = hook.GetTable().GCalcView
		if ( thirdHook && table.Count( thirdHook ) > 0 ) then
			local b, pos2, dist2 = pcall( table.GetFirstValue( thirdHook ), ply, pos, dist )

			if ( b ) then // the hook function was successful, lets override our pos and distance
				pos = pos2
				dist = dist2
			else
				Msg( "Unable to call thirdperson calc view: ", pos2, "\n" )
			end
		end

		// filter out ents that should not collide with where the camera is located
		for _, ent in ipairs( ThirdPerson.IgnoreEnts ) do
			table.Add( filters, ents.FindByClass( ent ) )
			table.Add( filters, ents.FindByBase( ent ) )
		end

		// calculate the view now
		local center = pos
		local offset = center + ang:Forward()


		// Handle viewing self
		if ply.ViewingSelf then

			if !ply._StoredViewAng then
				ply._StoredViewAng = true
				ply.ViewSelfAng = ang
			end

			ThirdPerson.ViewSelfAngSafeGuard( ply )
			ang = ply.ViewSelfAng
			ply.CurAng = ang

		else // Stop viewing self

			if ply.ViewSelfAng && ply:Alive() then
				ply.ViewSelfAng = nil
				ply._StoredViewAng = nil
			end

			// Animate back
			if ang && ply.CurAng && ply.CurAng != ang then

				// Limit it
				ply.CurAng.y = math.Clamp( ply.CurAng.y, -180, 180 )
				ply.CurAng.p = math.Clamp( ply.CurAng.p, -180, 180 )
				ply.CurAng.r = math.Clamp( ply.CurAng.r, -180, 180 )

				// SWOOOOOOOOOOOOOOSH
				ply.CurAng.y = math.Approach( ply.CurAng.y, ang.y, FrameTime() * 500 )
				ply.CurAng.p = math.Approach( ply.CurAng.p, ang.p, FrameTime() * 500 )
				ply.CurAng.r = math.Approach( ply.CurAng.r, ang.r, FrameTime() * 500 )
				ang = ply.CurAng

			else
				ply.CurAng = nil
			end

		end



		if !dist then dist = math.Clamp( ThirdPerson.Dist:GetInt() or 1, 35, 150 ) end

		// Check for walls
		local trWall = util.TraceHull( { start = center,
									 endpos = center + ( ang:Forward() * -dist * 0.95 ),
									 mins= Vector( -8, -8, -8 ), maxs = Vector( 8, 8, 8 ),
									 filter = filters } )
		if trWall.Fraction < 1 then

			dist = dist * ( trWall.Fraction * 0.95 )

			// Check for intersections
			local tr = util.TraceLine( { start = center,
										 endpos = center + ( ang:Forward() * -dist * 0.95 ),
										 filter = filters } )
			if tr.Fraction < 1 then
				dist = dist * ( tr.Fraction * 0.95 )

				// Check for closed spaces
				local trClosed = util.TraceLine( { start = ply:GetPos() + Vector( 0, 0, 10 ),
											 endpos = ply:GetPos() + Vector( 0, 0, 70 ),
											 filter = filters } )
				if trClosed.HitWorld then // We hit the world, revert to first person
					ThirdPerson.ShouldDraw = false
					return {
						origin = origin,
						angles = angles,
						fov = fov,
						vm_origin = ply:GetShootPos(),
						vm_angles = ply:EyeAngles(),
					}
				end

			end

		end

		if !ply.ViewingSelf then

			// Angle is too much, revert to first person
			// Too close, revert to first person
			if ( ang.p < -40 && dist <= 68 ) || dist <= 10 then
				ThirdPerson.ShouldDraw = false
				return {
					origin = origin,
					angles = angles,
					fov = fov,
					vm_origin = ply:GetShootPos(),
					vm_angles = ply:EyeAngles(),
				}
			end

		end

		// Final position
		local finalPos = center + ( ang:Forward() * -dist * 0.95 )

		if finalPos != ply.CameraPos then
			ply.CameraPos = finalPos
		end

		ply.CameraAngle = Angle( ang.p + 2, ang.y, ang.r )

		// View it up
		return {
			origin = finalPos,
			angles = ply.CameraAngle,
			fov = fov,
			vm_origin = ply:GetShootPos(),
			vm_angles = ply:EyeAngles(),
		}

	else

		if ply.CameraPos != ply:GetShootPos() then
			ply.CameraPos = ply:GetShootPos()
		end

		if ply.CameraAngle != ply:EyeAngles() then
			ply.CameraAngle = ply:EyeAngles()
		end

	end

end )

hook.Add("ShouldDrawLocalPlayer", "GMTThirdDrawLocal", function( ply )
	return ( ply.ThirdPerson || ply.ViewingSelf ) && ThirdPerson.ShouldDraw
end )

local function ExEnt( ent )

	if !ent || table.HasValue( ThirdPerson.IgnoreEnts, ent ) then return end

	table.insert( ThirdPerson.IgnoreEnts, ent )

end

// accepts a string or table of strings
// this adds an entity to an exclusion list for camera collision
function ThirdPerson.ExcludeEnt( ent )

	if !ent then return end

	if type( ent ) == "table" then

		for _, v in ipairs( ent ) do
			ExEnt( v )
		end

	elseif type( ent ) == "string" then

		ExEnt( ent )

	end

end

function ThirdPerson.ViewSelfAngSafeGuard( ply )

	if !ply.ViewSelfAng then

		local ang = ply:EyeAngles()
		ang.p = 45
		ply.ViewSelfAng = ang

	end

end

hook.Add( "PlayerBindPress", "ThirdPersonViewSelfZoomWheel", function( ply, bind, pressed )

	if LocalPlayer().GetActiveWeapon then

		local weapon = LocalPlayer():GetActiveWeapon()

		if IsValid( weapon ) && weapon:GetClass() == "weapon_physgun" then
			return false
		end

	end

	if bind == "invprev" && pressed then

		local dist = ThirdPerson.Dist:GetInt() - 10

		if dist <= 35 then
			ThirdPerson.Toggle( ply, false )
		end

		RunConsoleCommand( "gmt_setthirdpersondist", math.Clamp( dist, 35, 150 ) )

		return true

	elseif bind == "invnext" && pressed then

		local dist = ThirdPerson.Dist:GetInt() + 10

		ThirdPerson.Toggle( ply, true )
		RunConsoleCommand( "gmt_setthirdpersondist", math.Clamp( dist, 35, 150 ) )

		return true
	end

end )

hook.Add( "KeyPress", "ThirdPersonViewSelfKeyPress", function( ply, key )

	if key == IN_ATTACK2 && !ply.ViewingSelf then
		ThirdPerson.ViewSelfToggle( ply, true )
	end

	/*if key == IN_FORWARD || key == IN_BACK || key == IN_MOVELEFT || key == IN_MOVERIGHT || key == IN_JUMP then
		ThirdPerson.ViewSelfToggle( ply, false )
	end*/

end )

hook.Add( "KeyRelease", "ThirdPersonViewSelfKeyRelease", function( ply, key )

	if key == IN_ATTACK2 && ply.ViewingSelf then
		ThirdPerson.ViewSelfToggle( ply, false )
	end

end )

hook.Add( "PlayerThink", "ThirdPersonViewSelfThink", function( ply )

	if !ply:CanViewSelf() then
		ply.ViewingSelf = false
	end

end)

concommand.Add( "gmt_thirdperson", function( ply, cmd, args )
	ThirdPerson.Toggle( ply, nil, true )
end )

concommand.Add( "+viewself", function( ply, cmd, args )
	ThirdPerson.ViewSelfToggle( ply, true )
end )

concommand.Add( "-viewself", function( ply, cmd, args )
	ThirdPerson.ViewSelfToggle( ply, false )
end )

function ThirdPerson.Toggle( ply, on, toggle )

	if ply.ViewingSelf then
		ply.ThirdPerson = true
		return
	end

	if toggle then
		ply.ThirdPerson = !ply.ThirdPerson
	else
		ply.ThirdPerson = on
	end

end

function ThirdPerson.ViewSelfToggle( ply, on )

	if on then

		if !ply:CanViewSelf() || ply.ViewingSelf then return end

		ply._WasThirdPerson = ply.ThirdPerson
		ply.ThirdPerson = true

		//Msg( "Was" .. tostring( ply._WasThirdPerson ) .. " Third: " .. tostring( ply.ThirdPerson ) .. "\n" )
		ply.ViewingSelf = true

		//ply:SetCycle( 0 )

	else

		if !ply.ViewingSelf then return end

		ply.ViewingSelf = false
		ply.ThirdPerson = ply._WasThirdPerson

	end

end


local meta = FindMetaTable( "Player" )
if !meta then return end

function meta:CanViewSelf()

	if hook.Call( "DisableViewSelf", GAMEMODE, self ) then return false end

	if !self:Alive() then
		return false
	end

	/*if !self:IsOnGround() then
		return false
	end*/

	if emote && emote.IsEmoting( self ) then
		return false
	end

	local wep = self:GetActiveWeapon()
	if IsValid( wep ) then
		if ( wep.CanSecondaryAttack && wep:CanSecondaryAttack() ) ||
			wep:GetClass() == "weapon_crossbow" || wep:GetClass() == "weapon_physgun" then
			return false
		end
	end

	return true
end
