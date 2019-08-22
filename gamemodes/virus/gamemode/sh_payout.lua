payout.Register( "ThanksForPlaying", {
	Name = "Thanks For Playing",
	Desc = "For participating in the game!",
	GMC = 25,
} )

payout.Register( "WinBonus", {
	Name = "Winning Team",
	Desc = "You and your team won!",
	GMC = 15,
	Diff = 1,
} )

payout.Register( "FirstInfectedBonus", {
	Name = "First Infected",
	Desc = "You successfully spread the virus.",
	GMC = 50,
	Diff = 2,
} )

payout.Register( "LastSurvivorBonus", {
	Name = "Last Survivor",
	Desc = "Cold Blooded.\nYou were the remaining survivor and you lived!",
	GMC = 200,
	Diff = 2,
} )

payout.Register( "SurvivorBonus", {
	Name = "Survived the Infection",
	Desc = "You didn't get infected with the virus.",
	GMC = 50,
	Diff = 2,
} )

payout.Register( "TeamPlayer", {
	Name = "Team Player",
	Desc = "Survived with 3 or more survivors.",
	GMC = 50,
	Diff = 2,
} )

payout.Register( "Rank1", {
	Name = "1st Place",
	Desc = "For being the top killer.",
	GMC = 200,
	Diff = 3,
} )

payout.Register( "Rank2", {
	Name = "2nd Place",
	Desc = "For being the second top killer.",
	GMC = 100,
	Diff = 3,
} )

payout.Register( "Rank3", {
	Name = "3rd Place",
	Desc = "For being the third top killer.",
	GMC = 75,
	Diff = 3,
} )

function GM:GiveMoney()

	if CLIENT then return end

	local PlayerTable = player.GetAll()
	local survivors = team.GetPlayers( TEAM_PLAYERS )

	// Gather last survivor
	local lastSurvivor = nil
	if #survivors == 1 then
		lastSurvivor = survivors[ 1 ]
	end

	// Sort by best score, not rank
	table.sort( PlayerTable, function( a, b )

		local aScore, bScore = a:Frags(), b:Frags()
		if aScore == bScore then
			return a:Deaths() < b:Deaths()
		end

		return aScore > bScore

	end )

	// Payout
	for k, ply in pairs( PlayerTable ) do

		if ply.AFK then continue end

		payout.Clear( ply )

		self:RankThink( ply, true )

		if ply:Frags() > 0 then
			if k == 1 then payout.Give( ply, "Rank1" ) end
			if k == 2 then payout.Give( ply, "Rank2" ) end
			if k == 3 then payout.Give( ply, "Rank3" ) end
		end

		if self.VirusWins then

			if ply:Team() == TEAM_INFECTED then

				// Give bonus to first infected for winning the round!
				if ply == self.FirstInfected then
					payout.Give( ply, "FirstInfectedBonus" )
				end

				payout.Give( ply, "WinBonus" )

			end

		else // Survivors won

			if ply:Team() == TEAM_PLAYERS then

				// Survivors get a bit more
				payout.Give( ply, "SurvivorBonus" )

				// Give the last survivor a bonus!
				if lastSurvivor && ply == lastSurvivor then
					payout.Give( ply, "LastSurvivorBonus" )
				end

				if #team.GetPlayers( TEAM_PLAYERS ) >= 3 then
					payout.Give( ply, "TeamPlayer" )
				end

				payout.Give( ply, "WinBonus" )

			end

		end

		payout.Payout( ply )

	end

end
