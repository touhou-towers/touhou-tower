

-----------------------------------------------------


if SERVER then

	--AddCSLuaFile("racing.lua")

end



--print("RACING " .. (SERVER and "SERVER" or "CLIENT"))



module("racing", package.seeall)



MSG_RACE_STARTED = 0

MSG_RACE_CHECKPOINT = 1

MSG_RACE_FAILED = 2

MSG_RACE_FINISHED = 3



local function SafeCall(func, ...)

	if not func then return end

	local b,e = pcall(func, unpack({ ... }))

	if not b then

		print("ERROR: " .. tostring(e))

	end

	return e

end



if SERVER then



	util.AddNetworkString( "RaceInfo" )



	_ACTIVE_RACES = {}

	_RACE_RINGS = _RACE_RINGS or {}



	for k,v in pairs(_RACE_RINGS) do

		if IsValid(v) then v:Remove() end

	end



	_RACE_RINGS = {}



	local function SpawnRaceRing(pos, angle, radius)

		local e = ents.Create( "race_ring" )

		e:SetPos(pos)

		e:SetAngles(angle)

		e:SetRingSize(radius)

		e:Spawn()

		e:Activate()

		table.insert(_RACE_RINGS, e)

		return e

	end



	local function RaceThink()

		for k,v in pairs(_ACTIVE_RACES) do

			v.think()

		end

	end

	hook.Add("Think", "racethink", RaceThink)



	function Destroy( race, pl )

		if SERVER then
			if IsValid(pl) then
				for k,v in pairs(player.GetAll()) do
					v:SendLua([[GTowerChat.Chat:AddText("]]..pl:Name()..[[ has finished the race, winning 10,000 GMC!", Color(85, 225, 100, 255))]])
				end
			end
		end

		if IsValid(race.root) then race.root:Remove() end

		for k,v in pairs(race.nodes) do

			if IsValid(v.entity) then v.entity:Remove() end

		end



		for k,v in pairs(_ACTIVE_RACES) do

			if v == race then

				table.remove(_ACTIVE_RACES, k)

				break

			end

		end



		race = nil

	end



	function Reset( race )

		for k,v in pairs(race.nodes) do

			if IsValid(v.entity) then v.entity:Remove() end

		end

		race.started = false

		race.root:SetState(1)

		race.currentDuration = race.duration

	end



	local function RaceMSG( race, msg )

		SafeCall(function()

			net.Start( "RaceInfo" )

			net.WriteUInt( msg, 2 )

			net.WriteFloat( race.startTime )

			net.WriteFloat( race.currentDuration )

			net.Send( race.player )

		end)

	end



	function Create( racedata )

		if CLIENT then return end



		local data = {}

		local race = {}



		if type(racedata) == "string" then

			for s in string.gmatch(racedata,"[%-*%d*.*%d*]+") do

				local n = tonumber(s)

				table.insert(data, n)

			end

		elseif type(racedata) == "table" then

			for k,v in pairs(racedata) do

				table.insert(data, v.pos.x)

				table.insert(data, v.pos.y)

				table.insert(data, v.pos.z)

				table.insert(data, v.ang.p)

				table.insert(data, v.ang.y)

				table.insert(data, v.ang.r)

			end

		end



		race.nodes = {}

		race.think = function()

			if race.started then

				local dt = CurTime() - race.startTime

				race.timeLeft = race.currentDuration - dt

				if race.timeLeft <= 0 then

					race.timeLeft = 0

					race.started = false

					SafeCall(race.onFail, race, race.player)

					RaceMSG(race, MSG_RACE_FAILED)

					race.player = nil

				end

				if race.addTime then

					race.currentDuration = race.currentDuration + race.addTime

					race.addTime = nil

					SafeCall(race.onTimeAdded, race, race.player)

				end

			end

		end



		table.insert(_ACTIVE_RACES, race)



		for i=1, #data, 6 do

			local pos = Vector(data[i], data[i+1], data[i+2])

			local ang = Angle(data[i+3], data[i+4], data[i+5])

			local radius = 50



			if i == 1 then



				race.root = SpawnRaceRing(pos, ang, radius)

				race.root:SetState(1)

				race.root:SetTriggerCallback(function( ply )

					if race.exclusive and ply ~= race.exclusive then

						return false

					end



					race.started = true

					race.startTime = CurTime()

					race.player = ply

					race.currentDuration = race.duration

					SafeCall( race.onStart, race, ply )



					RaceMSG(race, MSG_RACE_STARTED)



					local last = race.root

					for k,v in pairs(race.nodes) do

						v.entity = SpawnRaceRing(v.pos, v.ang, v.radius)

						v.entity:SetTriggerCallback(function( ply )

							SafeCall( race.onCheckpoint, race, ply )



							race.think()



							RaceMSG(race, MSG_RACE_CHECKPOINT)

						end)



						last:SetNextRing(v.entity)

						last = v.entity

					end



					last:SetTriggerCallback(function( ply )

						SafeCall( race.onFinished, race, ply )



						RaceMSG(race, MSG_RACE_FINISHED)



						for k,v in pairs(race.nodes) do

							if IsValid(v.entity) then v.entity:Remove() end

							v.entity = nil

						end

					end)



				end)



			else



				table.insert(race.nodes, {

					pos = pos,

					ang = ang,

					radius = radius,

				})



			end



		end



		return race



	end



	local raceData = [[

	setpos 927.893433 -2813.376465 0.031250;setang -0.892188 89.760048 0.000000
setpos 937.779419 -2308.590088 13.739895;setang -0.628188 60.059669 0.000000
setpos 1249.029541 -1883.824463 64.031250;setang 2.011812 50.951633 0.000000
setpos 1449.878296 -1293.019287 64.031250;setang 1.747812 92.664314 0.000000
setpos 1120.650879 -334.955383 64.031250;setang 2.275812 114.312538 0.000000
setpos 731.548584 644.709229 48.031250;setang 1.879812 36.300205 0.000000
setpos 1206.659546 898.770752 64.031250;setang 2.407812 27.324160 0.000000
setpos 1527.723755 1480.359375 64.031250;setang -19.504185 89.364479 0.000000
setpos 1498.381958 2109.187744 256.031372;setang 0.295811 129.096710 0.000000
setpos 836.855896 2428.959717 256.031372;setang 1.087810 -177.971085 0.000000
setpos 422.028503 2198.205322 256.031372;setang 3.331810 -128.075058 0.000000
setpos 134.720703 1320.723022 256.031372;setang 1.879810 -91.114967 0.000000
setpos 309.868500 137.086746 301.031250;setang 10.987753 -67.750725 0.000000
setpos 586.281555 -488.622284 64.031250;setang 3.331755 -98.639252 0.000000
setpos 374.220581 -1107.005249 64.031250;setang 2.407755 -136.126984 0.000000
setpos 73.483055 -1410.114868 64.031250;setang -1.156245 -169.786850 0.000000
setpos -515.918884 -1476.259766 64.031250;setang 1.879755 146.257309 0.000000
setpos -710.419312 -820.521851 64.031250;setang 0.559756 116.821693 0.000000
setpos -1336.657471 -613.300476 64.031250;setang 0.295756 177.937531 0.000000
setpos -1724.150513 -324.506989 64.031250;setang 0.031756 85.273048 0.000000
setpos -1540.927612 13.582137 112.031250;setang -4.720243 -3.167048 0.000000
setpos -1168.031250 -235.872528 256.031250;setang -0.628244 -46.727081 0.000000
setpos -947.538086 -322.007294 256.031250;setang -3.268243 -15.707067 0.000000
setpos -767.708374 -380.967438 289.634094;setang 0.427756 -73.258652 0.000000
setpos -282.519196 -558.198853 453.968658;setang -89.000000 -11.614152 0.000000
setpos -282.519196 -558.198853 762.611328;setang -89.000000 -11.614152 0.000000
setpos -282.519196 -558.198853 1257.962402;setang -89.000000 -11.614152 0.000000
setpos -282.519196 -558.198853 1916.451782;setang -89.000000 -11.614152 0.000000
setpos -266.931549 -871.809631 2622.031250;setang 0.628023 -64.281776 0.000000
setpos -114.172714 -978.693726 2624.031250;setang 4.984022 37.622398 0.000000
setpos 278.652954 -679.503296 2624.031250;setang 4.060022 -0.525681 0.000000
setpos 975.415771 -685.896729 2624.031250;setang 4.060022 -0.525681 0.000000
setpos 1718.222778 -696.809448 2624.031250;setang 6.172022 -45.273823 0.000000
setpos 1895.356934 -1099.669189 2624.031250;setang 1.948023 -90.417961 0.000000
setpos 1890.276245 -1795.252075 2624.031250;setang 1.948023 -90.417961 0.000000
setpos 1815.853516 -2131.203857 2624.031250;setang 2.476023 -137.542038 0.000000
setpos 1257.505859 -2258.654541 2620.031250;setang 1.156023 179.426056 0.000000
setpos 992.256409 -2325.237549 2592.678223;setang 6.832022 -101.901810 0.000000
setpos 967.091064 -2887.330078 2624.031250;setang 1.420023 -147.045761 0.000000
setpos 312.583710 -2936.403564 2624.031250;setang -6.895976 -152.722366 0.000000
setpos 556.205688 -2918.750000 3344.031250;setang -0.295627 2.774228 0.000000
setpos 902.740540 -2904.779785 3308.031250;setang 2.608372 30.230223 0.000000
setpos 978.570984 -2351.968750 3296.031250;setang -0.635277 90.237991 0.000000
setpos 970.383606 -2028.974731 3307.145996;setang -2.803626 85.142265 0.000000
setpos 990.639771 -1720.792114 3356.031250;setang -5.839625 87.254227 0.000000


	]]



	local function startRaceTest()



		local r = Create(raceData)

		r.exclusive = nil --Set to only allow a specific player to run race

		r.duration = 3

		r.onFinished = function( race, pl )

			pl:ChatPrint("FINISHED RACE!")

			pl:AddMoney( 10000 )

			Destroy( race, pl )

		end



		r.onTimeAdded = function( race, pl ) end

		r.onCheckpoint = function( race, pl )

			race.addTime = 1.5

		end



		r.onStart = function( race, pl )

			pl:ChatPrint("START RACE!")

		end



		r.onFail = function( race, pl )

			pl:ChatPrint("YOU FAIL!")

			Reset(race)

		end



	end

	concommand.Add("gmt_startrace", function(ply)

		if ply:IsAdmin() then startRaceTest() end

	end)


	return



end



local CL_RACE_INFO = {}



surface.CreateFont( "RaceTimerFont", { font = "verdana", size = 40, weight = 50 } )



local function FormatTime(t)

	return string.format("%0.2i:%0.2i", math.floor(t), math.floor(t*100 % 100))

end



net.Receive( "RaceInfo", function(len)

	local msg = net.ReadUInt( 2 )

	local start = net.ReadFloat()

	local duration = net.ReadFloat()



	if msg == MSG_RACE_STARTED then

		CL_RACE_INFO.started = true

		CL_RACE_INFO.start = start

		CL_RACE_INFO.duration = duration

	elseif msg == MSG_RACE_CHECKPOINT then

		CL_RACE_INFO.start = start

		CL_RACE_INFO.checkpointTime = CurTime()

		CL_RACE_INFO.checkpointAdd = duration - CL_RACE_INFO.duration

		CL_RACE_INFO.duration = duration

	elseif msg == MSG_RACE_FAILED then

		CL_RACE_INFO.started = false

		CL_RACE_INFO.endTime = CurTime()

		CL_RACE_INFO.win = false

	elseif msg == MSG_RACE_FINISHED then

		CL_RACE_INFO.started = false

		CL_RACE_INFO.endTime = CurTime()

		CL_RACE_INFO.win = true

	end



	hook.Call("RaceState", GAMEMODE, msg, CL_RACE_INFO)

end)



local function drawRaceStats()

	if not CL_RACE_INFO.started then return end



	local t = CL_RACE_INFO.duration - ( CurTime() - CL_RACE_INFO.start )

	local ft = FormatTime(t)



	draw.SimpleTextOutlined(

		ft,

		"RaceTimerFont",

		ScrW()/2,

		20,

		Color(255,255,255,255),

		TEXT_ALIGN_CENTER,

		TEXT_ALIGN_LEFT,

		2,

		Color(0,0,0,255)

	)



	if not CL_RACE_INFO.checkpointTime then return end

	local ck_dt = 1 - math.min( CurTime() - CL_RACE_INFO.checkpointTime, 1 )



	draw.SimpleTextOutlined(

		"+" .. FormatTime(CL_RACE_INFO.checkpointAdd),

		"RaceTimerFont",

		ScrW()/2,

		50 + ck_dt * 20,

		Color(100,255,100,255 * ck_dt),

		TEXT_ALIGN_CENTER,

		TEXT_ALIGN_LEFT,

		1,

		Color(0,0,0,255 * ck_dt)

	)

end



hook.Add("HUDPaint", "racepaint", function()



	drawRaceStats()



	if (not CL_RACE_INFO.endTime) or CL_RACE_INFO.endTime < CurTime() - 2 then return end



	draw.SimpleTextOutlined(

		CL_RACE_INFO.win and "YOU WIN!" or "YOU LOSE!",

		"RaceTimerFont",

		ScrW()/2,

		50,

		CL_RACE_INFO.win and Color(255,255,100,255) or Color(255,100,100,255),

		TEXT_ALIGN_CENTER,

		TEXT_ALIGN_LEFT,

		2,

		Color(0,0,0,255)

	)

end)
