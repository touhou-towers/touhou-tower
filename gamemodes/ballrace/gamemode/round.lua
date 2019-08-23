include("roundrestart.lua")

local placement = 0
local timecompleted = 0
local level = 1
local memlvls = {
	"lvl6_start",
	"lvlLT_1_start",
	"lvlLT_2_start",
	"lvlRT_1_start",
	"lvlRT_2_start"
}

local function GetNextSpawn()
	-- Check if it's lvl 1.
	for k, v in pairs(ents.FindByClass("info_target")) do
		if LateSpawn == nil then
			if (v:GetName() == "lvl2_start" || v:GetName() == "lv2_start") then
				return v
			end
		end
	end

	if LateSpawn == nil then return end

	if string.StartWith(game.GetMap(), "gmt_ballracer_memories") then
		if LateSpawn:GetName() == "lvl6_start" then
			for _, v in pairs(ents.FindByClass("info_target")) do
				-- On the path level, choose random.
				if (math.random(1, 2) == 1 && v:GetName() == "lvlRT_1_start") then
					return v 
				elseif v:GetName() == "lvlLT_1_start" then 
					return v 
				end
			end
		else
			-- Path management
			-- god knows what this is
			for k, v in pairs(ents.FindByClass("info_target")) do
				if string.StartWith( LateSpawn:GetName(), "lvlRT" ) or string.StartWith( LateSpawn:GetName(), "lvlLT" ) then
					if LateSpawn:GetName() != "lvlLT_2_start" and LateSpawn:GetName() != "lvlRT_2_start" then
						if string.StartWith( LateSpawn:GetName(), "lvlRT" ) then
							if v:GetName() == "lvlRT_2_start" then return v end
						elseif string.StartWith( LateSpawn:GetName(), "lvlLT" ) then
							if v:GetName() == "lvlLT_2_start" then return v end
						end
					else
						if v:GetName() == "lvl7_start" then return v end
					end
				end
			end
		end
	end

	-- Prevents the other code from running
	if string.StartWith( game.GetMap(), "gmt_ballracer_memories" ) and table.HasValue(memlvls,LateSpawn:GetName()) then
		return
	end

	-- Get the next level under normal circumstances
	for k,v in pairs(ents.FindByClass("info_target")) do
		// Gets the number of the current spawn
		local CurLVL = string.gsub( LateSpawn:GetName(), '[%a _]', '' )

		-- Gets the name before the number, in every map always 'lvl'.
		local CurLVLName = string.gsub( LateSpawn:GetName(), '%d', '' )

		-- Checks for the left/right paths on Memories.

		-- No paths found, gets the first 3 letters.
		if string.StartWith( game.GetMap(), "gmt_ballracer_neonlights" ) then
			CurLVLName = string.sub( CurLVLName, 1, 2 )
		else
			CurLVLName = string.sub( CurLVLName, 1, 3 )
		end

		-- Makes it 'lvlnumber_start'
		if v:GetName() == CurLVLName .. ( tonumber( CurLVL ) + 1 ) .. "_start" then return v end
	end
end

function GM:StartRound()
	for k,v in pairs(player.GetAll()) do v.BestTime = nil end

	if NextMap then
		return
	end

	SetState(STATUS_SPAWNING)
	GAMEMODE:SpawnAllPlayers()
	SetState(STATUS_PLAYING)

	timer.Destroy("RoundEnd")

	for k,v in pairs(player.GetAll()) do
		v:SetNWBool("Died",false)
		v:SetNWBool("PressedButton",false)

		v:SetFrags(0)

		v:SetNWString("CompletedTime","")
		v:SetNWInt("Placement",0)
		placement = 0
	end

	if LateSpawn != nil && (LateSpawn:GetName() == 'bonus_start' || LateSpawn:GetName() == 'bns_start' || LateSpawn:GetName() == 'bonus') then
		music.Play( 1, MUSIC_BONUS )
		timer.Create("RoundEnd", 30, 1, GAMEMODE.StopRound, GAMEMODE)
		SetTime(CurTime() + 30)
	else
		music.Play( 1, MUSIC_LEVEL )
		timer.Create("RoundEnd", GAMEMODE.DefaultLevelTime, 1, GAMEMODE.StopRound, GAMEMODE)
		SetTime(CurTime() + GAMEMODE.DefaultLevelTime)
	end
	placement = 0
end

function GM:ResetGame()
	for k,v in pairs(player.GetAll()) do v.BestTime = nil end
	tries = tries + 1

	if tries == GAMEMODE.Tries then
		tries = 0
		local lvls = {}

		for k,v in pairs(ents.FindByClass("info_target")) do
			local LVL = string.gsub( v:GetName(), '[%a _]', '' )
			table.insert(lvls,LVL)
		end

		if level != #lvls then
			level = level + 1
			local NextLVL = GetNextSpawn()

			if (!IsValid(GetNextSpawn()) || GetNextSpawn() == false) then
				net.Start("roundmessage")
				net.WriteInt( 3, 3 )
				net.Broadcast()
				for k,v in pairs(player.GetAll()) do
					v:SendLua([[GTowerChat.Chat:AddText("You've failed too many times! Ending game!", Color(255, 255, 255, 255))]])
				end
				timer.Simple(4,function()
					self:EndServer()
				end)
				return
			end

			timer.Simple(0.2,function()
				ActiveTeleport = NextLVL
				LateSpawn = NextLVL
			end)

			for k,v in pairs(player.GetAll()) do
				v:SendLua([[GTowerChat.Chat:AddText("You've failed too many times! Moving to the next level!", Color(255, 255, 255, 255))]])
			end
		else
			net.Start("roundmessage")
			net.WriteInt( 3, 3 )
			net.Broadcast()
			timer.Simple(4,function()
				self:EndServer()
			end)
		end

	end

	net.Start("BGM")
	net.WriteInt( STAGE_FAILED, 3 )
	net.Broadcast()

	music.StopAll( true, 1 )

	for k,v in pairs(player.GetAll()) do
		v:SetFrags(0)
	end

	timer.Simple(1, function()
		game.CleanUpMapEx()
		GAMEMODE.SpawnPoints = nil
	end)
end

function GM:SaveBestTime(ply, lvl, time, update)

	if string.StartWith(game.GetMap(),"gmt_ballracer_memories") then
		if lvl == 7 and string.StartWith( LateSpawn:GetName(), "lvlRT" ) then lvl = 71 end
		if lvl == 8 and string.StartWith( LateSpawn:GetName(), "lvlRT" ) then lvl = 81 end

		if lvl == 7 and string.StartWith( LateSpawn:GetName(), "lvlLT" ) then lvl = 72 end
		if lvl == 8 and string.StartWith( LateSpawn:GetName(), "lvlLT" ) then lvl = 82 end
	end

	if !tmysql and SQL.getDB() != false then
		return
	end

	if update then
		SQL.getDB():Query(
		"UPDATE gm_ballrace SET time=".. time .." WHERE ply='"..ply:SteamID64().."' AND name='"..ply:Name().."' AND map='"..game.GetMap().."' AND lvl='"..lvl.."'", SQLLogResult)
		ply:AddAchivement( ACHIVEMENTS.BRTHATSARECORD, 1 )
		ply:AddAchivement( ACHIVEMENTS.BRHARDERBETTERFASTERSTRONGER, 1 )
		return
	end
	SQL.getDB():Query("CREATE TABLE IF NOT EXISTS gm_ballrace(ply TINYTEXT, name TINYTEXT,map TINYTEXT, lvl TINYTEXT, time FLOAT NOT NULL)")

	SQL.getDB():Query(
	"INSERT INTO gm_ballrace(`ply`,`name`,`map`,`lvl`,`time`) VALUES ('".. ply:SteamID64() .."','".. ply:Name() .."','".. game.GetMap() .."','".. lvl .."',".. time ..")", SQLLogResult)

end

function GM:GetBestTime(ply, lvl)

	if string.StartWith(game.GetMap(),"gmt_ballracer_memories") then
		if lvl == 7 and string.StartWith( LateSpawn:GetName(), "lvlRT" ) then lvl = 71 end
		if lvl == 8 and string.StartWith( LateSpawn:GetName(), "lvlRT" ) then lvl = 81 end

		if lvl == 7 and string.StartWith( LateSpawn:GetName(), "lvlLT" ) then lvl = 72 end
		if lvl == 8 and string.StartWith( LateSpawn:GetName(), "lvlLT" ) then lvl = 82 end
	end

	if !tmysql and SQL.getDB() != false then
		return
	end

	local res = SQL.getDB():Query("SELECT * FROM gm_ballrace WHERE ply='"..ply:SteamID64().."' AND map='"..game.GetMap().."' AND lvl='"..lvl.."'", function(res)

		if !res then return end

		local row = res[1].data[1]
		if row then
			ply.BestTime = tonumber(row.time)
		end
	end)

end

function GM:PlayerComplete(ply)
	ply.RaceTime = GetRaceTime()
	ply.NextSpawn = CurTime()
	ply:KillSilent()

	ply:AddAchivement( ACHIVEMENTS.BRMASTER, 1 )
	ply:AddAchivement( ACHIVEMENTS.BRMILESTONE1, 1 )

	if ply:Frags() == 0 then ply:AddAchivement( ACHIVEMENTS.BRLASTINLINE, 1 ) end

	if tmysql and SQL.getDB() != false then

	self:GetBestTime(ply, level)

	timer.Simple(0.25,function()

		if ply.BestTime == nil then
			ply:SendLua([[GTowerChat.Chat:AddText("New best time!", Color(65, 115, 200, 255))]])
			self:SaveBestTime(ply, level, ply.RaceTime, false)
		else
			if ply.BestTime <= ply.RaceTime then
				ply:SendLua([[GTowerChat.Chat:AddText("Your best time is still ]]..math.Round(ply.BestTime,2)..[[", Color(65, 115, 200, 255))]])
			end

			if ply.BestTime > ply.RaceTime then
				ply:SendLua([[GTowerChat.Chat:AddText("New best time ]]..math.Round(ply.RaceTime,2)..[[! Old time was ]]..math.Round(ply.BestTime,2)..[[", Color(65, 115, 200, 255))]])
				self:SaveBestTime(ply, level, ply.RaceTime, true)
			end

		end

		ply.BestTime = nil

	end)

	end

	local vPoint = ply:GetPos()
	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	util.Effect( "ball_transport", effectdata )

	ply:SetTeam(TEAM_COMPLETED)
	GAMEMODE:UpdateSpecs(ply, true)

	GAMEMODE:LostPlayer(ply)

	placement = placement + 1

	ply:SetNWInt( "Placement", placement )
	ply:SetNWString( "CompletedTime", string.Replace(string.FormattedTime(ply.RaceTime, "%2i:%02i.%02i"), "0:", "") )

	for k,v in pairs(player.GetAll()) do
		v:SendLua([[GTowerChat.Chat:AddText("LVL ]]..level..[[ #]]..placement..[[ ]]..ply:Name()..[[ |]]..string.Replace(string.FormattedTime(ply.RaceTime, "%2i:%02i.%02i"), "0:", "")..[[", Color(255, 255, 255, 255))]])
	end
end