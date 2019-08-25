Payouts = {
	ThanksForPlaying = {
		Name = "Thanks for Playing",
		Desc = "For participating!",
		GMC = 25
	},
	HoleInOne = {
		Name = "Hole in One",
		Desc = "GOOOOOAAAAAAAAAL! Wait wrong sport..",
		GMC = 500
	},
	OverBogey = {
		Name = "Over Double Bogey",
		Desc = "The higher the score the better... right?",
		GMC = 50
	}
}

for k, v in pairs(Payouts) do
	payout.Register(k, v)
end

local MoneyScores = {
	[-4] = {250, "Way to soar!"},
	[-3] = {200, "Really well done!"},
	[-2] = {150, "Fly like an eagle."},
	[-1] = {125, "Early bird gets the worm."},
	[0] = {100, "Just average."},
	[1] = {80, "Not bad. Try lowering your putt amounts."},
	[2] = {60, "You can do better."}
}

-- Scores is in the shared.lua file
for k, score in pairs(MoneyScores) do
	payout.Register(
		Scores[k],
		{
			Name = string.upper(Scores[k]), -- .. " (" .. k .. ")",
			Desc = score[2],
			GMC = score[1]
		}
	)
end

function GM:GiveMoney()
	if CLIENT then
		return
	end

	for _, ply in pairs(player.GetAll()) do
		if not ply.AFK then
			payout.Clear(ply)

			local swing = ply:Swing()

			local pardiff = ply:GetParDiff(swing)

			if swing == 1 then
				payout.Give(ply, "HoleInOne")
			else
				if MoneyScores[pardiff] then
					payout.Give(ply, Scores[pardiff])
				else
					payout.Give(ply, "OverBogey")
				end
			end

			payout.Payout(ply)
		end
	end
end
