
//

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEBUGMODE = false

ChairOffsets = {}
ChairOffsets["models/props/de_inferno/furniture_couch02a.mdl"] = {
	Vector(7.6080, 0.2916, -5.1108)
}
ChairOffsets["models/fishy/furniture/piano_seat.mdl"] = {
	Vector(2.7427, 13.2392, 22)
}

ChairOffsets["models/gmod_tower/css_couch.mdl"] = {
                Vector(12.83425617218, -25.016822814941, 19.691375732422),
                Vector(11.887982368469, 0.47359153628349, 19.074829101563),
                Vector(11.508950233459, 26.898155212402, 18.528305053711),
}
ChairOffsets["models/props/cs_office/sofa.mdl"] = {
                Vector(12.83425617218, -25.016822814941, 19.691375732422),
                Vector(11.887982368469, 0.47359153628349, 19.074829101563),
                Vector(11.508950233459, 26.898155212402, 18.528305053711),
}
ChairOffsets["models/props_vtmb/sofa.mdl"] = {
	Vector(35, 5, 20),
	Vector(0, 4, 20),
	Vector(-35, 6, 20),
}
ChairOffsets["models/splayn/rp/lr/couch.mdl"] = {
                Vector(2.83425617218, -25.016822814941, 19.691375732422),
                Vector(1.887982368469, 0.47359153628349, 19.074829101563),
                Vector(1.508950233459, 26.898155212402, 18.528305053711),
}
ChairOffsets["models/pt/lobby/pt_couch.mdl"] = {
                Vector(2.83425617218, -20.016822814941, 15.691375732422),
                Vector(1.508950233459, 20.898155212402, 15.528305053711),
}
ChairOffsets["models/props/cs_office/sofa_chair.mdl"] = {
                Vector(7.77490234375, -0.62280207872391, 20.302822113037),
}
ChairOffsets["models/splayn/rp/lr/chair.mdl"] = {
                Vector(7.77490234375, -0.62280207872391, 20.302822113037),
}
ChairOffsets["models/props/de_tides/patio_chair2.mdl"] = {
                Vector(1.4963380098343, -1.5668944120407, 17.591537475586),
}
ChairOffsets["models/gmod_tower/medchair.mdl"] = {
                Vector(-2.4963380098343, 0.5668944120407, 17.591537475586),
}
ChairOffsets["models/gmod_tower/plazabooth.mdl"] = {
                Vector(26.779298782349, -48.443725585938, 17.575805664063),
                Vector(24.627443313599, -22.173582077026, 17.693496704102),
                Vector(24.728271484375, 4.1212167739868, 17.712997436523),
                Vector(24.429685592651, 29.835939407349, 17.069671630859),
                Vector(25.442136764526, 53.892211914063, 18.112731933594),
}
ChairOffsets["models/props_trainstation/traincar_seats001.mdl"] = {
                Vector(4.6150, 41.7277, 18.5313),
                Vector(4.7320, 14.4948, 18.5313),
                Vector(4.5561, -13.3913, 18.5313),
                Vector(5.4507, -40.9903, 18.5313)
}
ChairOffsets["models/gmod_tower/theater_seat.mdl"] = {
                Vector(0, -5, 23),
                --Vector(4.7320, 14.4948, 18.5313),
               -- Vector(4.5561, -13.3913, 18.5313),
               -- Vector(5.4507, -40.9903, 18.5313)
}
ChairOffsets["models/props_c17/chair02a.mdl"] = {
                Vector(16.809963226318, 5.6439781188965, 1.887882232666),
}
ChairOffsets["models/props_interiors/furniture_chair03a.mdl"] = {
                Vector(-2, 0, -2.5),
}
ChairOffsets["models/props_c17/chair_stool01a.mdl"] = {
                Vector(-0.4295127093792, -1.5806334018707, 35.876251220703),
}
ChairOffsets["models/props_vtmb/armchair.mdl"] = {
                Vector(-1.4295127093792, -2.5806334018707, 13.876251220703),
}
ChairOffsets["models/props/cs_militia/barstool01.mdl"] = {
                Vector(-0.72143560647964, 0.90307611227036, 33.387348175049),
}
ChairOffsets["models/props_interiors/furniture_chair01a.mdl"] = {
                Vector(0.46997031569481, -0.053411800414324, -1.7953878641129),
}
ChairOffsets["models/props/cs_militia/couch.mdl"] = {
                Vector(30.384033203125, 5.251708984375, 15.507431030273),
                Vector(0.44091796875, 4.386474609375, 16.095657348633),
                Vector(-31.472412109375, 6.045166015625, 16.215229034424),
}
ChairOffsets["models/props_c17/furnituretoilet001a.mdl"] = {
                Vector(0.90478515625, -0.208984375, -30.683263778687),
}
ChairOffsets["models/props/cs_office/chair_office.mdl"] = {
                Vector(2.5078778266907, 1.4323912858963, 14.806640625),
}
ChairOffsets["models/gmod_tower/stealth box/box.mdl"] = {
                Vector(-2.0869002342224, -10.265548706055, 37.816131591797),
}
ChairOffsets["models/props_c17/furniturechair001a.mdl"] = {
                Vector(0.30538135766983, 0.14535087347031, -6.69970703125),
}
ChairOffsets["models/gmod_tower/comfychair.mdl"] = {
                Vector(0.30538135766983, 0.14535087347031, 12.69970703125),
}
ChairOffsets["models/haxxer/me2_props/illusive_chair.mdl"] = {
                Vector(0.30538135766983, 0.14535087347031, 14.69970703125),
}
ChairOffsets["models/sunabouzu/lobby_chair.mdl"] = {
                Vector(5.30538135766983, 0.14535087347031, 25.69970703125),
}
ChairOffsets["models/props/de_tides/patio_chair.mdl"] = {
                Vector(0.30538135766983, 0.14535087347031, 20.69970703125),
}
ChairOffsets["models/props_vtmb/chairfancyhotel.mdl"] = {
                Vector(-1, 6, 18.69970703125),
}
ChairOffsets["models/props/de_inferno/chairantique.mdl"] = {
                Vector(0.30538135766983, 0.14535087347031, 12.69970703125),
}
ChairOffsets["models/haxxer/me2_props/reclining_chair.mdl"] = {
                Vector(0.30538135766983, 0.14535087347031, 12.69970703125),
}
ChairOffsets["models/props_c17/furniturearmchair001a.mdl"] = {
                Vector(25.30538135766983, 32.14535087347031, 15.69970703125),
}
ChairOffsets["models/gmod_tower/suitecouch.mdl"] = {
                Vector(2.5263111591339, -25.540681838989, 17.753444671631),
                Vector(2.563271522522, 0.83294534683228, 17.750255584717),
                Vector(1.3705009222031, 27.729253768921, 17.448686599731),
}
ChairOffsets["models/mirrorsedge/bench_wooden.mdl"] = {
                Vector(1, -25.540681838989, 13.753444671631),
                Vector(1, 0.83294534683228, 13.750255584717),
                Vector(1, 27.729253768921, 13.448686599731),
}
ChairOffsets["models/map_detail/plaza_bench.mdl"] = {
                Vector(1, -25.540681838989, 15.753444671631),
                Vector(1, 0.83294534683228, 15.750255584717),
                Vector(1, 27.729253768921, 15.448686599731),
}
ChairOffsets["models/props_combine/breenchair.mdl"] = {
                Vector(6.8169813156128, -2.8282260894775, 16.551658630371),
}
ChairOffsets["models/mirrorsedge/seat_blue2.mdl"] = {
                Vector(0, -3, 14),
}
ChairOffsets["models/mirrorsedge/seat_blue1.mdl"] = {
                Vector(0, -3, 14),
}
ChairOffsets["models/props_interiors/toilet.mdl"] = {
                Vector(25, 0, 15),
}


NotRight = {	["models/props/de_tides/patio_chair2.mdl"]	= 180,
	 	["models/props/cs_militia/couch.mdl"]		= 0,
		["models/gmod_tower/stealth box/box.mdl"]	= 180,
		["models/gmod_tower/theater_seat.mdl"]	= 180,
		["models/haxxer/me2_props/illusive_chair.mdl"]	= 90,
		["models/haxxer/me2_props/reclining_chair.mdl"]	= 0,
		["models/mirrorsedge/seat_blue2.mdl"] = 180,
		["models/mirrorsedge/seat_blue1.mdl"] = 180,
		["models/mirrorsedge/bench_wooden.mdl"] = 90,
		["models/props_vtmb/armchair.mdl"] = 0,
		["models/props_vtmb/sofa.mdl"] = 0,
}

local function HandleRollercoasterAnimation( vehicle, player )
	return player:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER )
end

function CreateSeatAtPos(pos, angle)
	local ent = ents.Create("prop_vehicle_prisoner_pod")
	ent:SetModel("models/nova/airboat_seat.mdl")
	ent:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
	ent:SetPos(pos)
	ent:SetAngles(angle)
	ent:SetNotSolid(true)
	ent:SetNoDraw(true)

	ent.HandleAnimation = HandleRollercoasterAnimation

	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	return ent
end

hook.Add("KeyRelease", "EnterSeat", function(ply, key)
	if key != IN_USE || ply:InVehicle() || (ply.ExitTime && CurTime() < ply.ExitTime + 1) then return end

	local eye = ply:EyePos()
	local trace = util.TraceLine({start=eye, endpos=eye+ply:GetAimVector()*100, filter=ply})

	if !IsValid(trace.Entity) then return end

	local model = trace.Entity:GetModel()

	local offsets = ChairOffsets[model]
	if !offsets then return end

	local usetable = trace.Entity.UseTable or {}
	local pos = -1

	if #offsets > 1 then
		local localpos = trace.Entity:WorldToLocal(trace.HitPos)
		local bestpos, bestdist = -1

		for k,v in pairs(offsets) do
			local dist = localpos:Distance(v)
			if !usetable[k] && (bestpos == -1 || dist < bestdist) then
				bestpos, bestdist = k, dist
			end
		end

		if bestpos == -1 then return end
		pos = bestpos
	elseif !usetable[1] then
		pos = 1
	else
		return
	end

	usetable[pos] = true
	trace.Entity.UseTable = usetable

	ply:SetNWVector("SeatEntry",ply:GetPos())
	ply:SetNWVector("SeatEntryAng",ply:EyeAngles())
	ply.SeatEnt = trace.Entity
	ply.SeatPos = pos

	-- disable jetpack when we sit down
	ply.JetpackStart = 0

	local ang = trace.Entity:GetAngles()
	if NotRight[model] then
		ang:RotateAroundAxis(trace.Entity:GetUp(), NotRight[model])
	else
		ang:RotateAroundAxis(trace.Entity:GetUp(), -90)
	end

	local s = CreateSeatAtPos(trace.Entity:LocalToWorld(offsets[pos]), ang)
	s:SetParent(trace.Entity)
	s:SetOwner(ply)

	ply:EnterVehicle(s)
end)

hook.Add("CanPlayerEnterVehicle", "EnterSeat", function(ply, vehicle)
	if vehicle:GetClass() != "prop_vehicle_prisoner_pod" then return end

	if vehicle.Removing then return false end
	return (vehicle:GetOwner() == ply)
end)

local airdist = Vector(0,0,48)

function TryPlayerExit(ply, ent)
	local pos = ent:GetPos()
	local trydist = 8
	local yawval = 0
	local yaw = Angle(0, ent:GetAngles().y, 0)

	while trydist <= 64 do
		local telepos = pos + yaw:Forward() * trydist
		local trace = util.TraceEntity({start=telepos, endpos=telepos - airdist}, ply)

		if !trace.StartSolid && trace.Fraction > 0 && trace.Hit then
			ply:SetPos(telepos)
			return
		end

		yaw:RotateAroundAxis(yaw:Up(), 15)
		yawval = yawval + 15
		if yawval > 360 then
			yawval = 0
			trydist = trydist + 8
		end
	end

	print("player", ply, "couldn't get out")
end

local function PlayerLeaveVehice( vehicle, ply )

	if vehicle:GetClass() != "prop_vehicle_prisoner_pod" then return end

	if DEBUGMODE then print("exit") end
	if !IsValid(ply.SeatEnt) then
		return true
	end

	if ply.SeatEnt.UseTable then
		ply.SeatEnt.UseTable[ply.SeatPos] = false
	end
	ply.SeatPos = 0
	ply.SeatEnt = nil

	ply.ExitTime = CurTime()
	ply:ExitVehicle()

	ply:SetEyeAngles(ply:GetNWAngle("SeatEntryAng"))

	local trace = util.TraceEntity({start=ply:GetNWVector("SeatEntry"), endpos=ply:GetNWVector("SeatEntry")}, ply)

	ply:SetPos(ply:GetNWVector("SeatEntry", Vector(1957, 592, 280)))

	vehicle.Removing = true
	vehicle:Remove()

	ply:ResetEquipmentAfterVehicle()
	ply:CrosshairDisable()
	--ply:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	return false

end

hook.Add("CanExitVehicle", "Leave", PlayerLeaveVehice)

function PlayerExitLeft( ply )

	ply:CrosshairDisable()

	local Vehicle = ply:GetVehicle()

	if IsValid( Vehicle ) then
		PlayerLeaveVehice( Vehicle, ply )
	end
end

hook.Add("PlayerDeath", "VehicleKilled", PlayerExitLeft)
hook.Add("PlayerSilentDeath", "VehicleKilled", PlayerExitLeft)
hook.Add("PlayerDisconnected","VehicleCleanup", PlayerExitLeft)


timer.Create("GTowerCheckVehicle", 10.0, 0, function()
	for _, ply in pairs( player.GetAll() ) do
		local Vehicle = ply:GetVehicle()

		if IsValid( Vehicle ) then
			ply:AddAchivement( ACHIVEMENTS.LONGSEATGETALIFE, 10/60 )
		end
	end
end )

if !DEBUGMODE then return end

DEBUGOFFSETS = {}

hook.Add("InitPostEntity", "CreateSeats", function(ent)
	local phys = ents.FindByClass("prop_physics")

	for k,v in pairs(phys) do
		local model = v:GetModel()
		if ChairOffsets[model] then
			for x,y in pairs(ChairOffsets[model]) do
				local ang = v:GetRight():Angle()
				if NotRight[model] then ang = (v:GetForward() * NotRight[model]):Angle() end

				local s = CreateSeatAtPos(v:LocalToWorld(y), ang)
				s:SetParent(v)
			end
		end
	end
end)

hook.Add("KeyPress", "DebugPos", function(ply, key)
	if key != IN_USE then return end

	local trace = util.TraceLine(util.GetPlayerTrace(ply))
	if !IsValid(trace.Entity) || (trace.Entity:IsVehicle()) then return end

	local ent = CreateSeatAtPos(trace.HitPos, trace.Entity:GetRight():Angle())
	constraint.NoCollide(ent, trace.Entity, 0, 0)

	local model = trace.Entity:GetModel()

	if !DEBUGOFFSETS[model] then DEBUGOFFSETS[model] = {} end

	table.insert(DEBUGOFFSETS[model], {trace.Entity, ent})
end)

concommand.Add("dump_seats", function()

	for k,v in pairs(DEBUGOFFSETS) do
		print("ChairOffsets[\"" .. tostring(k) .. "\"] = {")
		for k,v in pairs(v) do
			if IsValid(v[2]) then
				local offset = v[1]:WorldToLocal(v[2]:GetPos())
				print("\t\tVector(" .. tostring(offset.x) .. ", " .. tostring(offset.y) .. ", " .. tostring(offset.z) .. "),")
			end
		end
		print("}")
	end
end)
