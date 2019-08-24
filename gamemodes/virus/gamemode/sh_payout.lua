Payouts = {
	ThanksForPlaying = {
		Name = "Thanks for Playing",
		Desc = "For participating!",
		GMC = 25
	},
	WinBonus = {
		Name = "Winning Team",
		Desc = "Your team won!",
		GMC = 25,
		Diff = 1
	},
	FirstInfectedBonus = {
		Name = "First Infect",
		Desc = "You spread the virus!",
		GMC = 50,
		Diff = 2
	},
	LastSurvivorBonus = {
		Name = "Last Survivor",
		Desc = "Only one may survive!",
		GMC = 500,
		Diff = 2
	},
	SurvivorBonus = {
		Name = "Survived the Infection",
		Desc = "You didn't get infected!",
		GMC = 100,
		Diff = 2
	},
	TeamPlayer = {
		Name = "Team Player",
		Desc = "You survived with 3 or more survivors.",
		GMC = 50,
		Diff = 2
	}
}
-- no ranks
for k, v in pairs(Payouts) do
	payout.Register(k, v)
end

function GM:GiveMoney()
	if CLIENT then
		return
	end

	local PlayerTable = player.GetAll()
	local survivors = team.GetPlayers(TEAM_PLAYERS)

	-- Gather last survivor
	local lastSurvivor = nil
	if #survivors == 1 then
		lastSurvivor = survivors[1]
	end

	-- Sort by best score, not rank
	table.sort(
		PlayerTable,
		function(a, b)
			local aScore, bScore = a:Frags(), b:Frags()
			if aScore == bScore then
				return a:Deaths() < b:Deaths()
			end

			return aScore > bScore
		end
	)

	-- Payout
	for k, ply in pairs(PlayerTable) do
		if not ply.AFK then
			payout.Clear(ply)

			self:RankThink(ply, true) -- is this necessary if there are no rank rewards?

			if self.VirusWins then
				if ply:Team() == TEAM_INFECTED then
					-- Give bonus to first infected for winning the round!
					if ply == self.FirstInfected then
						payout.Give(ply, "FirstInfectedBonus")
					end

					payout.Give(ply, "WinBonus")
				end
			else -- Survivors won
				if ply:Team() == TEAM_PLAYERS then
					-- Survivors get a bit more
					payout.Give(ply, "SurvivorBonus")

					if #team.GetPlayers(TEAM_PLAYERS) >= 3 then
						payout.Give(ply, "TeamPlayer")
					elseif lastSurvivor and ply == lastSurvivor then
						payout.Give(ply, "LastSurvivorBonus")
					end

					payout.Give(ply, "WinBonus")
				end
			end

			payout.Payout(ply)
		end
	end
end
