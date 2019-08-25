if SERVER then
	util.AddNetworkString("NetworkPars")

	util.AddNetworkString("NetworkScores")

	util.AddNetworkString("RequestPars")

	util.AddNetworkString("RequestScores")

	local function SendPars(ply)
		local pars = {}

		for _, hole in pairs(GAMEMODE.Holes) do
			pars[tonumber(hole:GetHole())] = tonumber(hole:GetPar())
		end

		net.Start("NetworkPars")

		net.WriteTable(pars)

		net.Send(ply)
	end

	local function SendScores(ply)
		local scores = {}

		for _, ply2 in pairs(player.GetAll()) do
			scores[ply2] = GAMEMODE:GetScore(ply2)
		end

		net.Start("NetworkScores")

		net.WriteTable(scores)

		net.Send(ply)
	end

	function GM:SetScore(ply, hole, score)
		if not ply.Score then
			ply.Score = {}
		end

		ply.Score[tonumber(hole)] = score

		self:UpdateScore(ply)
	end

	function GM:GetScore(ply)
		self:UpdateScore(ply)

		return ply.Score
	end

	function GM:UpdateScore(ply)
		if not ply.Score then
			ply.Score = {}
		end

		local total = 0

		local curhole = GAMEMODE:GetHole() or 0

		for i = 1, curhole - 1 do
			local hole = GAMEMODE.Holes[i]

			local par = tonumber(hole:GetPar())

			local score = ply.Score[i] or 0

			-- Default any missing ones

			if score == 0 then
				score = self:DefaultScore(ply, i, par)
			end

			total = total + score
		end

		-- Update total

		ply:SetFrags(total)
	end

	function GM:DefaultScore(ply, holenum, par)
		if not ply.Score then
			ply.Score = {}
		end

		local score = (par + LatePenality)

		ply.Score[holenum] = score

		return score
	end

	net.Receive(
		"RequestPars",
		function(len, ply)
			SendPars(ply)
		end
	)

	net.Receive(
		"RequestScores",
		function(len, ply)
			SendScores(ply)
		end
	)
else -- CLIENT
	ScorePars = nil

	TotalScores = nil

	net.Receive(
		"NetworkPars",
		function(length, client)
			local pars = net.ReadTable()

			ScorePars = pars
		end
	)

	net.Receive(
		"NetworkScores",
		function(length, client)
			local scores = net.ReadTable()

			TotalScores = scores
		end
	)

	function GM:GetParOfHole(hole)
		if not ScorePars then
			return 0
		end
		return ScorePars[hole]
	end

	function GM:GetScoreOfPlayer(ply, hole)
		if not TotalScores or not TotalScores[ply] then
			return 0
		end

		local score = TotalScores[ply][tonumber(hole)]

		-- Use live swing amount if we're on the current hole and we have no score set

		if self:GetHole() == tonumber(hole) and (not score or score == 0) then
			return ply:Swing()
		end

		return score or 0
	end

	function GM:RequestScores()
		if not ScorePars then
			net.Start("RequestPars")

			net.SendToServer()
		end

		net.Start("RequestScores")

		net.SendToServer()
	end
end
