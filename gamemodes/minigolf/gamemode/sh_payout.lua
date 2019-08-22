
-----------------------------------------------------
payout.Register( "ThanksForPlaying", {
	Name = "Thanks For Playing",
	Desc = "For participating in the game!",
	GMC = 25,
} )

payout.Register( "HoleInOne", {
	Name = "Hole In One!",
	Desc = "A perfect putt.",
	GMC = 250,
} )

payout.Register( "OverBogey", {
	Name = "Over Double Bogey",
	Desc = "You do know the goal is to get\nthe lowest score, right?",
	GMC = 20,
} )

local MoneyScores = {
	[-4] = { 250, "Way to soar!" },
	[-3] = { 200, "Really well done!" },
	[-2] = { 150, "Fly like an eagle." },
	[-1] = { 100, "Early bird gets the worm." },
	[0] = { 80, "Just average." },
	[1] = { 40, "Not bad. Try lowering your putt amounts." },
	[2] = { 30, "You can do better." },
}

for k, score in pairs( MoneyScores ) do

	payout.Register( Scores[k], {
		Name = string.upper( Scores[k] ), // .. " (" .. k .. ")",
		Desc = score[2],
		GMC = score[1],
	} )

end

function GM:GiveMoney()

	if CLIENT then return end

	for _, ply in pairs( player.GetAll() ) do

		if ply.AFK then continue end

		payout.Clear( ply )

		local swing = ply:Swing()
		local pardiff = ply:GetParDiff( swing )

		if swing == 1 then
			payout.Give( ply, "HoleInOne" )
		else
			if MoneyScores[pardiff] then
				payout.Give( ply, Scores[ pardiff ] )
			end
		end

		if pardiff > 2 then
			payout.Give( ply, "OverBogey" )
		end

		payout.Payout( ply )

	end

end
