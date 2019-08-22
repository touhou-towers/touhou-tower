-- name is the title
-- desc is the description
-- GMC is the amount paid
-- diff is a identifier so you don't get the same reward?
-- or difficulty? or position in the HUD

Payouts = {
	-- thanksforplaying is automatically awarded i think
	ThanksForPlaying = {
		Name = "Thanks for Playing",
		Desc = "For participating!",
		GMC = 25
	},
	Completed = {
		Name = "Completed Level",
		Desc = "For reaching the end!",
		GMC = 50,
		Diff = 1
	},
	NoDie = {
		Name = "Didn't Die",
		Desc = "You didn't die!",
		GMC = 25,
		Diff = 1,
	},
	Button = {
		Name = "Team Player",
		Desc = "You pressed the button!",
		Diff = 4,
		GMC = 75
	},
	Collected = {
		Name = "Collected Bananas",
		Desc = "Banana bonus! (3 GMC ea)",
		Diff = 4,
		GMC = 0
	}
}

-- ranks can be calculated automatically
local descriptions = {"Amazing!", "Close one!", "Nice job!", "Pretty good.", "Average."}
for place = 1, #descriptions do
	Payouts["Rank" .. place] = {
		Name = "You're #" .. place,
		Desc = descriptions[place],
		Diff = 3,
		GMC = 50 * place
	}
end

-- actually register the payouts
for k, v in pairs(Payouts) do
	payout.Register(k, v)
end

function GM:GiveMoney()
	if CLIENT then return end

	for _, ply in pairs(player.GetAll()) do
		if ply.AFK then continue end

		payout.Clear(ply)
		local placement = ply:GetNWInt("Placement")

		if ply:Team() == TEAM_COMPLETED then
			payout.Give(ply, "Completed")
		end

		if !ply:GetNWBool("Died") then
			payout.Give(ply, "NoDie")
		end

		if ply:GetNWBool("PressedButton") then
			payout.Give(ply, "Button")
		end

		-- rank
		if  Payouts["Rank" .. placement] then
			payout.Give(ply, "Rank" .. placement)
		end

		-- frags here are bananas
		if ply:Frags() > 0 then
			payout.Give( ply, "Collected", ply:Frags() * 3 )
		end

		payout.Payout( ply )
	end
end