include("roundrestart.lua")

local placement = 0
local timecompleted = 0
local level = 1

tries = 0

LEVEL_MUSIC = 1
BONUS_STAGE = 2
STAGE_FAILED = 3

local lcount = 0

function LvlAmount()
	if lcount ~= 0 then
		return lcount
	end

	for k, v in pairs(ents.FindByClass("info_target")) do
		if string.StartWith(v:GetName(), "lv") then
			lcount = lcount + 1
		end
	end
	return lcount
end

hook.Add(
	"GTowerMsg",
	"GamemodeMessage",
	function()
		if player.GetCount() < 1 then
			return "#nogame"
		else
			local levels = LvlAmount() + 1
			if
				LateSpawn ~= nil and
					(LateSpawn:GetName() == "bonus_start" or LateSpawn:GetName() == "bns_start" or LateSpawn:GetName() == "bonus")
			 then
				return "-1/" .. levels
			else
				return tostring(math.Clamp(level, 1, levels)) .. "/" .. levels
			end
		end
	end
)

-- TODO: figure out how this works
function GetNextSpawn()
	-- Check if it's lvl 1.
	for k, v in pairs(ents.FindByClass("info_target")) do
		if LateSpawn == nil then
			if (v:GetName() == "lvl2_start" or v:GetName() == "lv2_start") then
				return v
			end
		end
	end

	if LateSpawn == nil then
		return
	end

	if string.StartWith(game.GetMap(), "gmt_ballracer_memories") then
		if LateSpawn:GetName() == "lvl6_start" then
			for k, v in pairs(ents.FindByClass("info_target")) do
				-- On the path level, choose random.
				if math.random(1, 2) == 1 then
					if v:GetName() == "lvlRT_1_start" then
						return v
					end
				else
					if v:GetName() == "lvlLT_1_start" then
						return v
					end
				end
			end
		else
			-- Path management
			for k, v in pairs(ents.FindByClass("info_target")) do
				if string.StartWith(LateSpawn:GetName(), "lvlRT") or string.StartWith(LateSpawn:GetName(), "lvlLT") then
					if LateSpawn:GetName() ~= "lvlLT_2_start" and LateSpawn:GetName() ~= "lvlRT_2_start" then
						if string.StartWith(LateSpawn:GetName(), "lvlRT") then
							if v:GetName() == "lvlRT_2_start" then
								return v
							end
						elseif string.StartWith(LateSpawn:GetName(), "lvlLT") then
							if v:GetName() == "lvlLT_2_start" then
								return v
							end
						end
					else
						if v:GetName() == "lvl7_start" then
							return v
						end
					end
				end
			end
		end

	--return false
	end

	-- Prevents the other code from running
	local memlvls = {"lvl6_start", "lvlLT_1_start", "lvlLT_2_start", "lvlRT_1_start", "lvlRT_2_start"}
	if string.StartWith(game.GetMap(), "gmt_ballracer_memories") and table.HasValue(memlvls, LateSpawn:GetName()) then
		return
	end

	-- Get the next level under normal circumstances
	for k, v in pairs(ents.FindByClass("info_target")) do
		-- Gets the number of the current spawn
		local CurLVL = string.gsub(LateSpawn:GetName(), "[%a _]", "")

		-- Gets the name before the number, in every map always 'lvl'.
		local CurLVLName = string.gsub(LateSpawn:GetName(), "%d", "")

		-- Checks for the left/right paths on Memories.

		-- No paths found, gets the first 3 letters.
		if string.StartWith(game.GetMap(), "gmt_ballracer_neonlights") then
			CurLVLName = string.sub(CurLVLName, 1, 2)
		else
			CurLVLName = string.sub(CurLVLName, 1, 3)
		end

		-- Makes it 'lvlnumber_start'
		if v:GetName() == CurLVLName .. (tonumber(CurLVL) + 1) .. "_start" then
			return v
		end
	end
end

function GM:UpdateStatus(disc)
	if GetState() ~= STATUS_PLAYING then
		return
	end

	local dead = NumPlayers(TEAM_DEAD)
	local complete = NumPlayers(TEAM_COMPLETED)

	local total = player.GetCount()
	if disc then
		total = total - 1
		dead = dead - 1
	end

	if total == 0 then
		self:RestartLevel()
		return
	end

	if dead + complete >= total then
		timer.Destroy("RoundEnd")

		if complete > 0 then
			for k, v in pairs(player.GetAll()) do
				for ply, afk in pairs(afks) do
					if afk then
						if not IsValid(ply) or not IsValid(v) then
							return
						end
						v:SendLua(
							[[GTowerChat.Chat:AddText("]] ..
								ply:Name() .. [[ has automatically forfeited due to being AFK.", Color(100, 100, 100, 255))]]
						)
					end
				end
			end

			timer.Simple(
				0.5,
				function()
					level = level + 1
				end
			)
			tries = 0
			-- Fokin' network delay
			timer.Simple(
				0.2,
				function()
					GAMEMODE:GiveMoney()
				end
			)

			if NextMap then
				if string.StartWith(game.GetMap(), "gmt_ballracer_memories") then
					for k, v in pairs(player.GetAll()) do
						v:AddAchivement(ACHIVEMENTS.BRMEMORIES, 1)
					end
				end
				for k, v in pairs(player.GetAll()) do
					if not v:GetNWBool("Popped") then
						v:AddAchivement(ACHIVEMENTS.BRUNPOPABLE, 1)
					end
				end
				net.Start("roundmessage")
				net.WriteInt(3, 3)
				net.Broadcast()
				timer.Simple(
					8,
					function()
						self:EndServer()
					end
				)
			else
				net.Start("roundmessage")
				net.WriteInt(1, 3)
				net.Broadcast()
			end
			LateSpawn = ActiveTeleport
		else
			if
				LateSpawn ~= nil and
					(LateSpawn:GetName() == "bonus_start" or LateSpawn:GetName() == "bns_start" or LateSpawn:GetName() == "bonus")
			 then
				net.Start("roundmessage")
				net.WriteInt(1, 3)
				net.Broadcast()
				LateSpawn = BonusTeleport
				ActiveTeleport = BonusTeleport
				timer.Simple(
					0.2,
					function()
						GAMEMODE:GiveMoney()
					end
				)
			else
				net.Start("roundmessage")
				if tries < 1 then
					net.WriteInt(2, 3)
				else
					net.WriteInt(1, 3)
				end
				net.Broadcast()
				self:ResetGame(true)
			end
		end

		SetState(STATUS_INTERMISSION)

		timer.Simple(8, self.StartRound, self)
	end
end

function GM:StopRound()
	for k, v in ipairs(player.GetAll()) do
		if v:Team() == TEAM_PLAYERS then
			v:SetDeaths(1)
			v:Kill()
		end
	end
end

function GM:StartRound()
	for k, v in pairs(player.GetAll()) do
		v.BestTime = nil
	end

	if NextMap then
		return
	end

	SetState(STATUS_SPAWNING)

	GAMEMODE:SpawnAllPlayers()

	SetState(STATUS_PLAYING)

	timer.Destroy("RoundEnd")

	for k, v in pairs(player.GetAll()) do
		v:SetNWBool("Died", false)
		v:SetNWBool("PressedButton", false)

		v:SetFrags(0)

		v:SetNWString("CompletedTime", "")
		v:SetNWInt("Placement", 0)
		placement = 0
	end

	if
		LateSpawn ~= nil and
			(LateSpawn:GetName() == "bonus_start" or LateSpawn:GetName() == "bns_start" or LateSpawn:GetName() == "bonus")
	 then
		music.Play(1, MUSIC_BONUS)
		timer.Create("RoundEnd", 30, 1, GAMEMODE.StopRound, GAMEMODE)
		SetTime(CurTime() + 30)
	else
		music.Play(1, MUSIC_LEVEL)
		timer.Create("RoundEnd", GAMEMODE.DefaultLevelTime, 1, GAMEMODE.StopRound, GAMEMODE)
		SetTime(CurTime() + GAMEMODE.DefaultLevelTime)
	end
	placement = 0
end

function GM:RestartLevel()
	game.ConsoleCommand("changelevel " .. table.Random(Levels) .. "\n")
end

function GM:ResetGame()
	for k, v in pairs(player.GetAll()) do
		v.BestTime = nil
	end

	tries = tries + 1

	if tries == GAMEMODE.Tries then
		tries = 0

		local lvls = {}

		for k, v in pairs(ents.FindByClass("info_target")) do
			local LVL = string.gsub(v:GetName(), "[%a _]", "")
			table.insert(lvls, LVL)
		end

		if level ~= #lvls then
			level = level + 1
			local NextLVL = GetNextSpawn()

			if (not IsValid(GetNextSpawn()) or GetNextSpawn() == false) then
				net.Start("roundmessage")
				net.WriteInt(3, 3)
				net.Broadcast()
				for k, v in pairs(player.GetAll()) do
					v:SendLua([[GTowerChat.Chat:AddText("You've failed too many times! Ending game!", Color(255, 255, 255, 255))]])
				end
				timer.Simple(
					4,
					function()
						self:EndServer()
					end
				)
				return
			end

			timer.Simple(
				0.2,
				function()
					ActiveTeleport = NextLVL
					LateSpawn = NextLVL
				end
			)

			for k, v in pairs(player.GetAll()) do
				v:SendLua(
					[[GTowerChat.Chat:AddText("You've failed too many times! Moving to the next level!", Color(255, 255, 255, 255))]]
				)
			end
		else
			net.Start("roundmessage")
			net.WriteInt(3, 3)
			net.Broadcast()
			timer.Simple(
				4,
				function()
					self:EndServer()
				end
			)
		end
	end

	net.Start("BGM")
	net.WriteInt(STAGE_FAILED, 3)
	net.Broadcast()

	music.StopAll(true, 1)

	for k, v in pairs(player.GetAll()) do
		v:SetFrags(0)
	end

	timer.Simple(
		1,
		function()
			game.CleanUpMapEx()
			GAMEMODE.SpawnPoints = nil
		end
	)
end

function GM:LostPlayer(ply, disc)
	if IsValid(ply.Ball) then
		ply.Ball:Remove()
	end

	ply.Ball = nil
	ply:SetBall(NULL)

	GAMEMODE:UpdateStatus(disc)
end

function GM:SaveBestTime(ply, lvl, time, update)
	if string.StartWith(game.GetMap(), "gmt_ballracer_memories") then
		if lvl == 7 and string.StartWith(LateSpawn:GetName(), "lvlRT") then
			lvl = 71
		end
		if lvl == 8 and string.StartWith(LateSpawn:GetName(), "lvlRT") then
			lvl = 81
		end

		if lvl == 7 and string.StartWith(LateSpawn:GetName(), "lvlLT") then
			lvl = 72
		end
		if lvl == 8 and string.StartWith(LateSpawn:GetName(), "lvlLT") then
			lvl = 82
		end
	end

	if not tmysql and SQL.getDB() ~= false then
		return
	end

	if update then
		SQL.getDB():Query(
			"UPDATE gm_ballrace SET time=" ..
				time ..
					" WHERE ply='" ..
						ply:SteamID64() .. "' AND name='" .. ply:Name() .. "' AND map='" .. game.GetMap() .. "' AND lvl='" .. lvl .. "'",
			SQLLogResult
		)
		ply:AddAchivement(ACHIVEMENTS.BRTHATSARECORD, 1)
		ply:AddAchivement(ACHIVEMENTS.BRHARDERBETTERFASTERSTRONGER, 1)
		return
	end
	SQL.getDB():Query(
		"CREATE TABLE IF NOT EXISTS gm_ballrace(ply TINYTEXT, name TINYTEXT,map TINYTEXT, lvl TINYTEXT, time FLOAT NOT NULL)"
	)

	SQL.getDB():Query(
		"INSERT INTO gm_ballrace(`ply`,`name`,`map`,`lvl`,`time`) VALUES ('" ..
			ply:SteamID64() .. "','" .. ply:Name() .. "','" .. game.GetMap() .. "','" .. lvl .. "'," .. time .. ")",
		SQLLogResult
	)
end

function GM:GetBestTime(ply, lvl)
	if string.StartWith(game.GetMap(), "gmt_ballracer_memories") then
		if lvl == 7 and string.StartWith(LateSpawn:GetName(), "lvlRT") then
			lvl = 71
		end
		if lvl == 8 and string.StartWith(LateSpawn:GetName(), "lvlRT") then
			lvl = 81
		end

		if lvl == 7 and string.StartWith(LateSpawn:GetName(), "lvlLT") then
			lvl = 72
		end
		if lvl == 8 and string.StartWith(LateSpawn:GetName(), "lvlLT") then
			lvl = 82
		end
	end

	if not tmysql and SQL.getDB() ~= false then
		return
	end

	local res =
		SQL.getDB():Query(
		"SELECT * FROM gm_ballrace WHERE ply='" ..
			ply:SteamID64() .. "' AND map='" .. game.GetMap() .. "' AND lvl='" .. lvl .. "'",
		function(res)
			if not res then
				return
			end

			local row = res[1].data[1]
			if row then
				ply.BestTime = tonumber(row.time)
			end
		end
	)
end

function GM:PlayerComplete(ply)
	ply.RaceTime = GetRaceTime()
	ply.NextSpawn = CurTime()
	ply:KillSilent()

	ply:AddAchivement(ACHIVEMENTS.BRMASTER, 1)
	ply:AddAchivement(ACHIVEMENTS.BRMILESTONE1, 1)

	if ply:Frags() == 0 then
		ply:AddAchivement(ACHIVEMENTS.BRLASTINLINE, 1)
	end

	if tmysql and SQL.getDB() ~= false then
		self:GetBestTime(ply, level)

		timer.Simple(
			0.25,
			function()
				if ply.BestTime == nil then
					ply:SendLua([[GTowerChat.Chat:AddText("New best time!", Color(65, 115, 200, 255))]])
					self:SaveBestTime(ply, level, ply.RaceTime, false)
				else
					if ply.BestTime <= ply.RaceTime then
						ply:SendLua(
							[[GTowerChat.Chat:AddText("Your best time is still ]] ..
								math.Round(ply.BestTime, 2) .. [[", Color(65, 115, 200, 255))]]
						)
					end

					if ply.BestTime > ply.RaceTime then
						ply:SendLua(
							[[GTowerChat.Chat:AddText("New best time ]] ..
								math.Round(ply.RaceTime, 2) ..
									[[! Old time was ]] .. math.Round(ply.BestTime, 2) .. [[", Color(65, 115, 200, 255))]]
						)
						self:SaveBestTime(ply, level, ply.RaceTime, true)
					end
				end

				ply.BestTime = nil
			end
		)
	end

	local vPoint = ply:GetPos()
	local effectdata = EffectData()
	effectdata:SetOrigin(vPoint)
	util.Effect("ball_transport", effectdata)

	ply:SetTeam(TEAM_COMPLETED)
	GAMEMODE:UpdateSpecs(ply, true)

	GAMEMODE:LostPlayer(ply)

	placement = placement + 1

	ply:SetNWInt("Placement", placement)
	ply:SetNWString("CompletedTime", string.Replace(string.FormattedTime(ply.RaceTime, "%2i:%02i.%02i"), "0:", ""))

	for k, v in pairs(player.GetAll()) do
		v:SendLua(
			[[GTowerChat.Chat:AddText("LVL ]] ..
				level ..
					[[ #]] ..
						placement ..
							[[ ]] ..
								ply:Name() ..
									[[ |]] ..
										string.Replace(string.FormattedTime(ply.RaceTime, "%2i:%02i.%02i"), "0:", "") ..
											[[", Color(255, 255, 255, 255))]]
		)
	end
end

function GM:SpawnAllPlayers()
	for k, v in ipairs(player.GetAll()) do
		v:SetDeaths(GAMEMODE.Lives)
		v:Spawn()
	end
end

function GM:UpdateSpecs(ply, dead)
	-- don't bother updating specs when we're spawning
	if GetState() == STATUS_SPAWNING then
		return
	end

	for k, v in ipairs(player.GetAll()) do
		if v:Team() ~= TEAM_PLAYERS and v.Spectating == ply:EntIndex() then
			if dead then
				GAMEMODE:SpectateNext(v)
			else
				v:SetBall(ply.Ball)
			end
		end
	end
end

function GM:SpectateNext(ply)
	local start = ply.Spectating

	local newspec = start

	local players = player.GetAll()

	local k, v = next(players, start)
	if not k then
		k, v = next(players)
	end

	while k ~= start do
		if v:Team() == TEAM_PLAYERS then
			newspec = k
			break
		end

		k, v = next(players, k)
		if not k then
			if start == nil then
				break
			end
			k, v = next(players)
		end
	end

	ply.Spectating = newspec

	local ent = nil
	if players[newspec] then
		ent = players[newspec].Ball
	end

	ply:SetBall(ent)
end
