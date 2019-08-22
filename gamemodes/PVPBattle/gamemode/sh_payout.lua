function GM:GiveMoney()

	if CLIENT then return end

	local PlayerTable = player.GetAll()

	// Sort by top scores
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

		if ply:Frags() > 0 then
			if k == 1 then payout.Give( ply, "Rank1" ) end
			if k == 2 then payout.Give( ply, "Rank2" ) end
			if k == 3 then payout.Give( ply, "Rank3" ) end
		end

		if ply._HackerAmt >= 1 then
			payout.Give( ply, "Headshot" )
		end

		payout.Payout( ply )

	end

end

payout.Register( "ThanksForPlaying", {
	Name = "Thanks For Playing",
	Desc = "For participating in the game!",
	GMC = 100,
} )

payout.Register( "Rank1", {
	Name = "1st Place",
	Desc = "For being the top killer.",
	GMC = 300,
	Diff = 3,
} )

payout.Register( "Rank2", {
	Name = "2nd Place",
	Desc = "For being the second top killer.",
	GMC = 200,
	Diff = 3,
} )

payout.Register( "Rank3", {
	Name = "3rd Place",
	Desc = "For being the third top killer.",
	GMC = 150,
	Diff = 3,
} )

payout.Register( "Headshot", {
	Name = "One Click Headshot",
	Desc = "Got a headshot",
	GMC = 50,
	Diff = 3,
} )
