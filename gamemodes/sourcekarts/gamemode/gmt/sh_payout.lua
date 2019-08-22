
-----------------------------------------------------
/*payout.Register( "ThanksForPlaying", {
	Name = "Thanks For Playing",
	Desc = "For participating in the game!",
	GMC = 150,
} )

payout.Register( "FinishBonus", {
	Name = "Finished",
	Desc = "You passed the finish line!",
	GMC = 50,
	Diff = 1,
} )

payout.Register( "Rank1", {
	Name = "1st Place! - Gold Medal",
	Desc = "Congratulations, you won the race!",
	GMC = 250,
	Diff = 3,
} )

payout.Register( "Rank2", {
	Name = "2nd Place - Silver Medal",
	Desc = "Aw, so close!",
	GMC = 200,
	Diff = 3,
} )

payout.Register( "Rank3", {
	Name = "3rd Place - Bronze Medal",
	Desc = "",
	GMC = 150,
	Diff = 3,
} )

payout.Register( "RankBattle1", {
	Name = "1st Place",
	Desc = "For being the top combatant.",
	GMC = 200,
	Diff = 3,
} )

payout.Register( "RankBattle2", {
	Name = "2nd Place",
	Desc = "For being the second top combatant.",
	GMC = 100,
	Diff = 3,
} )

payout.Register( "RankBattle3", {
	Name = "3rd Place",
	Desc = "For being the third top combatant.",
	GMC = 75,
	Diff = 3,
} )

function GM:GiveMoney( race )

	if CLIENT then return end

	local PlayerTable = player.GetAll()

	// Payout race
	if race then

		for k, ply in pairs( PlayerTable ) do

			payout.Clear( ply )

			if ply:GetPosition() && ply:GetPosition() > 0 then
				if ply:GetPosition() == 1 then payout.Give( ply, "Rank1" ) end
				if ply:GetPosition() == 2 then payout.Give( ply, "Rank2" ) end
				if ply:GetPosition() == 3 then payout.Give( ply, "Rank3" ) end
			end

			if ply:Team() == TEAM_FINISHED then
				payout.Give( ply, "FinishBonus" )
			end

			payout.Payout( ply )

		end

	// Payout battle
	else

		for k, ply in pairs( PlayerTable ) do

			payout.Clear( ply )

			if ply:GetPosition() && ply:GetPosition() > 0 then
				if ply:GetPosition() == 1 then payout.Give( ply, "RankBattle1" ) end
				if ply:GetPosition() == 2 then payout.Give( ply, "RankBattle2" ) end
				if ply:GetPosition() == 3 then payout.Give( ply, "RankBattle3" ) end
			end

			payout.Payout( ply )

		end

	end

end*/
