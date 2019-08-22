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

payout.Register( "WinBonusGhost", {
	Name = "Winning Team (Ghost)",
	Desc = "You were on the winning team, but\nsadly you're a ghost now.",
	GMC = 8,
	Diff = 1,
} )

payout.Register( "UCWinBonus", {
	Name = "Ultimate Chimera",
	Desc = "You truly are the ultimate chimera!",
	GMC = 45,
	Diff = 1,
} )

payout.Register( "Rank1", {
	Name = "Ensign Bonus",
	Desc = "Good day to be an alive Ensign.",
	GMC = 10,
	Diff = 1,
} )

payout.Register( "Rank2", {
	Name = "Captain Bonus",
	Desc = "Congrats, Captain.",
	GMC = 20,
	Diff = 1,
} )

payout.Register( "Rank3", {
	Name = "Major Bonus",
	Desc = "You are Majorly awesome.",
	GMC = 30,
	Diff = 1,
} )

payout.Register( "Rank4", {
	Name = "Colonel Bonus",
	Desc = "Being a Colonel never felt so good.",
	GMC = 40,
	Diff = 1,
} )

payout.Register( "UCRank1", {
	Name = "Rank Chomp Bonus",
	Desc = "You ate a Ensign.",
	GMC = 10,
	Diff = 1,
} )

payout.Register( "UCRank2", {
	Name = "Captain Chomp Bonus",
	Desc = "You ate a Captain.",
	GMC = 20,
	Diff = 1,
} )

payout.Register( "UCRank3", {
	Name = "Major Chomp Bonus",
	Desc = "You ate a Major.",
	GMC = 30,
	Diff = 1,
} )

payout.Register( "UCRank4", {
	Name = "Colonel Chomp Bonus",
	Desc = "You ate a Colonel.",
	GMC = 40,
	Diff = 1,
} )

payout.Register( "UCDeadPigs", {
	Name = "Dead Pigs Bonus",
	Desc = "You get 15 GMC per eaten Pigmask",
	GMC = 0,
	Diff = 2,
} )

payout.Register( "UCLastPig", {
	Name = "Last Pig Bonus",
	Desc = "You're last alive",
	GMC = 80,
	Diff = 1,
} )

winbonus = 15

function GM:GiveMoney()

	if CLIENT then return end

	local PlayerTable = player.GetAll()
	local teamid = self.WinningTeam

	// Payout
	for _, ply in ipairs( PlayerTable ) do

		payout.Clear( ply )
		
		// Chimera won
		if teamid == TEAM_CHIMERA then

			if ply.IsChimera then

				payout.Give( ply, "UCWinBonus" )

				if ply.HighestKilledRank then
					payout.Give( ply, "UCRank" .. ply.HighestKilledRank )
				end

			end

		// Pigs won
		elseif teamid == TEAM_PIGS then

			// Alive players get more bonus
			if ply:Team() == TEAM_PIGS then

				payout.Give( ply, "WinBonus" )
				payout.Give( ply, "Rank" .. ply.Rank )

			// You died during play, half of the winning bonus for you
			elseif ply:Team() == TEAM_GHOST then

				payout.Give( ply, "WinBonusGhost" )

			end

			if #team.GetPlayers( TEAM_PIGS ) == 1 then
				payout.Give( ply, "UCLastPig" )
			end

		end

		// Chimera gets paid a little more for more action
		if ply.IsChimera then

			local deadpigs = #team.GetPlayers( TEAM_GHOST )
			if deadpigs > 0 then
				payout.Give( ply, "UCDeadPigs", ( deadpigs * 15 ) )
			end

		end

		payout.Payout( ply )

	end

end