-- Return the list of players what would be joining the server
function ServerMeta:GetMovingPlayers()
	local PlayerBatches = self:GetBatches()

	-- print(self.Id, "GetMovingPlayers", PlayerBatches, #PlayerBatches, table.Count(PlayerBatches))
	if not PlayerBatches or #PlayerBatches == 0 then
		return
	end

	return PlayerBatches[1]
end

function ServerMeta:IsReady()
	-- First let's check if the server is ready
	-- And that the gamemode handles players in packs
	-- Give 60 seconds from last players joining to the server to update
	-- print(self.Id, "IsReady", self:Online(), self.Status, self.LastPlayerJoin, CurTime())

	if not self:Online() or self.Status == 2 or (self.LastPlayerJoin and (CurTime() - self.LastPlayerJoin) < 60) then
		self.QueuedAt = CurTime()
		return false
	end

	-- Now check for the player count and see if it meets the requirements
	local PlayerList = self:GetMovingPlayers()

	if not PlayerList then
		-- reset the auto-go timer
		self.QueuedAt = CurTime()
		return false
	end

	-- Check the limitations with the minimun amount of players
	local PlayerCount = table.Count(PlayerList)

	-- cant start without anyone
	if PlayerCount == 0 then
		-- reset the auto-go timer
		self.QueuedAt = CurTime()
		return false
	end

	local Gamemode = self:GetGamemode()

	-- if not enough people
	-- if not soloable OR not enough time has passed
	if
		(Gamemode.MinPlayers and PlayerCount < Gamemode.MinPlayers) and
			(not Gamemode.Soloable or CurTime() - self.QueuedAt < 30)
	 then
		return false
	end

	return true
end

concommand.Add(
	"gmt_clearconnectingplayers",
	function(ply)
		if not ply:IsAdmin() then
			return
		end
		SQL.getDB():Query("TRUNCATE `gm_loadingnames`")
		ply:Msg2("Cleaned loading names table.")
	end
)

concommand.Add(
	"gmt_setconnectingplayers",
	function(ply)
		if not ply:IsAdmin() then
			return
		end
		local gmlist = {"ballrace", "minigolf", "pvpbattle", "sourcekarts", "zombiemassacre", "virus", "ultimatechimerahunt"}

		for k, v in pairs(gmlist) do
			SQL.getDB():Query("INSERT INTO gm_loadingnames(gamemode,steamids) VALUES('" .. v .. "','1')")
			ply:Msg2("Wrote default players for " .. v .. ".")
		end
	end
)

function ServerMeta:Think()
	local IsReady = self:IsReady()
	local Gamemode = self:GetGamemode()

	if IsReady then
		-- print(self.GoJoinTime, #self:GetMovingPlayers())
		if not self.GoJoinTime then
			-- don't vote while the game is in state 3, it will reset itself
			if self.Status ~= 1 then
				return
			end

			-- print(self.Id, "start vote")
			self:StartMapVote()
			self.SendPlayersFinal = nil
		elseif CurTime() > self.GoJoinTime - 1 and self.MapChangeSent ~= true then
			-- print(self.Id, "count vote")
			self:CountMapVotes()
			local movingPlayers = self:GetMovingPlayers()

			self.SendPlayersFinal = movingPlayers -- this is it, these players are going whether they like it or not
			local SteamIDS = ""
			for k, v in pairs(movingPlayers) do
				if k == #movingPlayers then
					SteamIDS = SteamIDS .. v:SteamID64()
				else
					SteamIDS = SteamIDS .. v:SteamID64() .. ","
				end
			end
			SQL.getDB():Query(
				"UPDATE gm_loadingnames SET steamids = '" .. SteamIDS .. "' WHERE gamemode = '" .. Gamemode.Gamemode .. "';"
			)
		elseif CurTime() > self.GoJoinTime and self.SendPlayersFinal then
			if self.Status == 3 then
				-- print(self.Id, "move it!")
				self:PlayersToServer(self.SendPlayersFinal)
			end
		else
			self:SendMapVote()
		end
	elseif self.GoJoinTime then
		umsg.Start("GServ", nil)
		umsg.Char(10)
		umsg.Char(self.Id)
		umsg.End()

		timer.Destroy("MultiServerReady" .. self.Id)
		timer.Destroy("MultiServerChooseMap" .. self.Id)

		self.GoJoinTime = nil
	end
end

function ServerMeta:PlayersToServer(PlayerList)
	-- Well, the time has passed, and we are still here
	self.LastPlayerJoin = CurTime()
	self.GoJoinTime = nil

	local gameMode = self:GetGamemode()

	GTowerServers:RedirectPlayers(self.Ip, self.Port, self.Password, PlayerList, true, gameMode)
end

function ServerMeta:TimedThink(time)
	--timer.Create("MultiServerThink" .. self.Id, time or 0.0, 1, self.Think, self  )
	timer.Simple(
		(time or 0),
		function()
			self:Think()
		end
	)
end
