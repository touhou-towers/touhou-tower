
local lastpos = Vector(0,0,0)
local lastang = Angle(0,0,0)
local DEBUG = false

function GTowerItems:TraceHull( ent, filter )
	local mins, maxs = ent:WorldSpaceAABB()
	local Pos = ent:GetPos()
	local up = ent:GetUp()

	mins, maxs = (mins - Pos) * 0.95, (maxs - Pos) * 0.95
	OrderVectors(mins, maxs)

if DEBUG then
	print(CLIENT, ent, mins, maxs, ent:GetModel())
	if Pos != lastpos || ent:GetAngles() != lastang then
		lastpos = Pos
		lastang = ent:GetAngles()

		if SERVER then
			local lua = string.format("debugoverlay.Box(Vector(%.2f,%.2f,%.2f), Vector(%.2f,%.2f,%.2f), Vector(%.2f,%.2f,%.2f), 2, Color(0, 0, 255, 100))",
				Pos.x, Pos.y, Pos.z,
				mins.x, mins.y, mins.z,
				maxs.x, maxs.y, maxs.z)
			BroadcastLua(lua)
		else
			debugoverlay.Box(Pos, mins, maxs, 1, Color(255, 0, 0, 50))
		end
	end
end

	if !filter then filter = ent end

	local trace = util.TraceHull( {
		mins = mins,
		maxs = maxs,
		start = Pos,
		endpos = Pos + up * 2,
		filter = filter
	} )

if DEBUG then
	PrintTable(trace)
end

	return trace
end

function GTowerItems:CheckTraceHull( ent, filter )
	local Trace = GTowerItems:TraceHull( ent, filter )
	
	if GTowerItems.OnlyHitWorld == false then
		return Trace.Hit == false || Trace.Fraction	> 0.1
	else
		if IsValid( Trace.Entity ) && Trace.Entity:IsPlayer() then
			return false
		end
	
		return Trace.HitWorld == false || Trace.Fraction > 0.1
	end
end