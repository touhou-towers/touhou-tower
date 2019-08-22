
hook.Add("AdminCommand", "TeleportCmd", function( args, admin, ply )

	if args[1] == "goto" then		
		goto( ply, admin )
	elseif args[1] == "teleport" then
		teleport( ply, admin )
	end

end )

function GetSafePosition(player, position, filter)
	local closestPosition
	local distanceAmount = 8
	local directions = {}
	local yawForward = player:EyeAngles().yaw
	local angles = {
		math.NormalizeAngle(yawForward - 180),
		math.NormalizeAngle(yawForward - 135),
		math.NormalizeAngle(yawForward + 135),
		math.NormalizeAngle(yawForward + 45),
		math.NormalizeAngle(yawForward + 90),
		math.NormalizeAngle(yawForward - 45),
		math.NormalizeAngle(yawForward - 90),
		math.NormalizeAngle(yawForward)
	}
	
	position = position + Vector(0, 0, 4)
	
	if (!filter) then
		filter = {player}
	elseif (type(filter) != "table") then
		filter = {filter}
	end
	
	if ( !table.HasValue(filter, player) ) then
		filter[#filter + 1] = player
	end
	
	for i = 1, 8 do
		for k, v in ipairs(angles) do
			directions[#directions + 1] = {v, distanceAmount}
		end
		
		distanceAmount = distanceAmount * 2
	end
	
	local function GetLowerPosition(testPosition, ignoreHeight)
		local trace = {
			filter = filter,
			endpos = testPosition - Vector(0, 0, 1024),
			start = testPosition
		}
		
		return util.TraceLine(trace).HitPos + Vector(0, 0, 4)
	end
	
	local trace = {
		filter = filter,
		endpos = position + Vector(0, 0, 1024),
		start = position
	}
	
	local safePosition = GetLowerPosition(util.TraceLine(trace).HitPos)
	local k, v
	
	if (safePosition) then
		position = safePosition
	end
	
    for k, v in ipairs(directions) do
		local testPosition = position + ( Angle(0, v[1], 0):Forward() * v[2] )
		
		local trace = {
			filter = filter,
			endpos = testPosition,
			start = position
		}
		
		local traceLine = util.TraceEntity(trace, player)
		
		if (!traceLine.Hit) then
			return traceLine.HitPos
		end
    end
	
	return position
end

function goto( ply, admin )
	admin:SetPos( GetSafePosition( admin, ply:GetPos() ) )
end

function teleport( ply, admin )
	ply:SetPos( GetSafePosition( ply, admin:GetPos() ) )
end