function GM:StartRound()
	GAMEMODE:CleanUpMap()

	game.GetWorld().State = STATUS_INFECTING

	game.GetWorld().NumVirus = 0

	GAMEMODE.CurrentRound = GAMEMODE.CurrentRound + 1

	-- enable random modifiers

	-- zombie guns
	if GAMEMODE.CurrentRound > 4 then -- 5, 6, 7, 8, 9, 10
		-- 30% chance to allow zombies to have guns
		local zombieGuns = math.random(1, 10) < 4
		if zombieGuns then
			if GAMEMODE.CurrentRound == 10 then -- 10
				GAMEMODE.zombieGuns = {true, true, true, false} -- everything except tnt and snipers
			elseif GAMEMODE.CurrentRound > 7 then -- 8, 9
				GAMEMODE.zombieGuns = {true, true, false, false} -- pistols and smgs
			else -- 5, 6, 7
				GAMEMODE.zombieGuns = {true, false, false, false} -- pistols only
			end
		end
	end

	-- player gun restrictions (any round) 10% chance per round
	-- restrict 1 class of gun
	local restriction = math.random(1, 40)
	if restriction > 0 and restriction < 5 then -- 1, 2, 3, 4
		GAMEMODE.playerGuns[restriction] = false
	end
	-- 2.5% chance to make it snipers and tnt only
	if restriction == 5 then -- 5, 6
		GAMEMODE.playerGuns = {false, false, false, true}
		GAMEMODE.HumanSpeed = 500 -- speed up humans for this modifier
	end

	-- 50% chance to allow jumping
	GAMEMODE.jumpable = math.random(1, 2) == 2

	game.GetWorld().Round = GAMEMODE.CurrentRound
	game.GetWorld().MaxRounds = GAMEMODE.NumRounds

	GAMEMODE.HasLastSurvivor = false

	local plys = player.GetAll()

	for _, v in ipairs(plys) do
		v.IsVirus = false

		v:SetTeam(TEAM_PLAYERS)

		v:Freeze(false)

		v:SetFrags(0)
		v:SetDeaths(0)

		v:StripWeapons()
		v:RemoveAllAmmo()

		v:SetCanZoom(false)

		v:Spawn()
	end

	local randSong = math.random(1, GAMEMODE.NumWaitingForInfection)
	GAMEMODE.WaitingSong = randSong

	umsg.Start("StartRound")
	umsg.Char(randSong)
	umsg.End()

	if (game.GetWorld().MaxRounds == game.GetWorld().Round) then
		-- this is the last round
		GAMEMODE:HudMessage(nil, 4, 10)
	end

	local time = GAMEMODE.InfectingTime
	local infectRand = math.random(time[1], time[2])

	timer.Destroy("Infect")
	timer.Create("Infect", infectRand, 1, GAMEMODE.RandomInfect, GAMEMODE)
end

function GM:EndRound(virusWins)
	game.GetWorld().State = STATUS_INTERMISSION
	GAMEMODE.EndRoundMusic = virusWins

	-- reset round modifiers
	GAMEMODE.playerGuns = {true, true, true, true}
	GAMEMODE.zombieGuns = {false, false, false, false}
	GAMEMODE.jumpable = false
	GAMEMODE.HumanSpeed = 300

	local time = GAMEMODE.IntermissionTime

	game.GetWorld().Time = CurTime() + time

	local plys = player.GetAll()

	for _, v in ipairs(plys) do
		v:Freeze(true)

		v:StripWeapons()
		v:RemoveAllAmmo()

		if not v.IsVirus then
			v:AddAchivement(ACHIVEMENTS.VIRUSSTRONG, 1)
		end

		if v.Rank == 1 then
			v:AddAchivement(ACHIVEMENTS.VIRUSBRAGGING, 1)
		end

		v:AddAchivement(ACHIVEMENTS.VIRUSTIMESPLIT, 1)
		v:AddAchivement(ACHIVEMENTS.VIRUSMILESTONE1, 1)
	end

	local lastSurvivor = team.GetPlayers(TEAM_PLAYERS)[1]

	if IsValid(lastSurvivor) then
		lastSurvivor:AddAchivement(ACHIVEMENTS.VIRUSLASTALIVE, 1)
		lastSurvivor:AddAchivement(ACHIVEMENTS.VIRUSMILESTONERADAR, 1)
	end

	if #team.GetPlayers(TEAM_PLAYERS) >= 4 then
		for _, v in ipairs(team.GetPlayers(TEAM_PLAYERS)) do
			v:SetAchivement(ACHIVEMENTS.VIRUSTEAMPLAYER, 1)
		end
	end

	if virusWins then
		-- infected have prevailed
		GAMEMODE:HudMessage(nil, 11, 5)
	else
		-- survivors have won
		GAMEMODE:HudMessage(nil, 12, 5)
	end

	umsg.Start("EndRound")
	umsg.Bool(virusWins)
	umsg.End()

	GAMEMODE:GiveMoney()

	if game.GetWorld().Round >= game.GetWorld().MaxRounds then
		timer.Destroy("EndMap")
		timer.Create("EndMap", time + 3, 1, GAMEMODE.EndServer, GAMEMODE)

		return
	end

	timer.Destroy("RoundStart")
	timer.Create("RoundStart", time, 1, GAMEMODE.StartRound, GAMEMODE)

	GAMEMODE.HasLastSurvivor = false -- JUST IN CASE LOL
end
