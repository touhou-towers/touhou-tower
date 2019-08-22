
-----------------------------------------------------
payout.Register( "ThanksForPlaying", {
	Name = "Thanks For Playing",
	Desc = "For participating in the game!",
	GMC = 25,
} )

payout.Register( "Completed", {
	Name = "Completed Level",
	Desc = "For completing the level.",
	GMC = 25,
	Diff = 1,
} )

payout.Register( "NoDie", {
	Name = "Didn't Die",
	Desc = "You didn't lose any lives.",
	GMC = 25,
	Diff = 1,
} )

payout.Register( "Rank1", {
	Name = "1st Place",
	Desc = "Congratulations!",
	GMC = 150,
	Diff = 3,
} )

payout.Register( "Rank2", {
	Name = "2nd Place",
	Desc = "Aw, so close!",
	GMC = 100,
	Diff = 3,
} )

payout.Register( "Rank3", {
	Name = "3rd Place",
	Desc = "",
	GMC = 50,
	Diff = 3,
} )

payout.Register( "Button", {
	Name = "Team Player",
	Desc = "For pressing a button.",
	Diff = 4,
	GMC = 50,
} )

payout.Register( "Collected", {
	Name = "Collected Bananas",
	Desc = "Bonus for collecting bananas (5 GMC each).",
	Diff = 4,
	GMC = 0,
} )

function GM:GiveMoney()

	if CLIENT then return end

	--local PlayerTable = player.sqlGetAll()

		for _, ply in pairs( player.GetAll() ) do

			if ply.AFK then continue end

			payout.Clear( ply )


			local placement = ply:GetNWInt("Placement")

			if ply:Team() == TEAM_COMPLETED then
				payout.Give( ply, "Completed" )
			end

			if !ply:GetNWBool("Died") then
				payout.Give( ply, "NoDie" )
			end

			if ply:GetNWBool("PressedButton") then
				payout.Give( ply, "Button" )
			end

			if placement == 1 then
				payout.Give( ply, "Rank1" )
			elseif placement == 2 then
				payout.Give( ply, "Rank2" )
			elseif placement == 3 then
				payout.Give( ply, "Rank3" )
			end

			if ply:Frags() > 0 then
      	payout.Give( ply, "Collected", ply:Frags() * 5 )
			end

			payout.Payout( ply )

		end

end
