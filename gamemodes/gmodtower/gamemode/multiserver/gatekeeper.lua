
--require("gatekeeper")

local gateKeep = {}
gateKeep.Bans = {} --Used to hold all the bans server-side, rather than query every time.

gateKeep.HardCodedBans = {
		{"STEAM_0:0:13388289", "stgn"},
		{"STEAM_0:1:22125535", "Tootage"},
		{"STEAM_0:1:10161682", "[YaS] BlackhawkGT"},
		{"STEAM_0:0:6847392", "||BoB||Squallboogie"},
		{"STEAM_0:1:17162420", "[D3]LuminousSilver"},
		{"STEAM_0:0:18607667", "Slash"},
		{"STEAM_0:0:20550704", "nitro-n20"},
		{"STEAM_0:0:9036955", "PWD]Xeldof"},
		{"STEAM_0:0:8563984", "Killer2"},
		{"STEAM_0:1:17399955", ".:[MDFB]:. .:GGC:. XMX Fabian"},
		{"STEAM_0:0:8268433", "Tommy the Commy"},
		{"STEAM_0:1:14884446", "Llamalords"},
		{"STEAM_0:0:14282678", "Whitefang"},
		{"STEAM_0:1:10742997", "Teddi"},
		{"STEAM_0:1:90573021", "Matt"},
		{"STEAM_0:0:50197118", "Zoephixical"},
		{"STEAM_0:1:61873778", "Sabina"},
		{"STEAM_0:1:21016813", "0x0539"},
	}

/*gateKeep.HardCodedIPBans = {
		{"86.171.25.0", "Killer2"}, // Killersservers.co.uk
		{"76.117.19.86", "Nvgg3t"}, // Nvgg3t
		{"86.171.155.131", "Killer2"}, // I might filter 86.171.*.*
		{"67.176.175.110", "Humble Bee"},
		{"74.13.124.205", "stgn"},
		{"85.224.15.191", "Tommy the Commy"},
	}*/

gateKeep.MaxSlots = 0
gateKeep.AdminBypass = true
gateKeep.AuthorizedPlayers = {}

function gateKeep:CreateBanList()

	SQL.getDB():Query("CREATE TABLE IF NOT EXISTS gm_bans(steamid TINYTEXT, Name TINYTEXT NOT NULL, ip TINYTEXT, reason TINYTEXT NOT NULL, bannedOn BIGINT NOT NULL, time BIGINT NOT NULL)")

	SQL.getDB():Query("SELECT * FROM gm_bans", function(res)

			if res[1].status != true then
				print("Error getting bans: " .. res[1].error)
				return
			end

			if #res[1].data then
				print("Retriving bans from MySQL")
				gateKeep:RetrieveBans(res[1].data)
			else
				print("Setting up Legacy Bans")
				gateKeep:LegacyBans()
			end

		end)

end

/*
* Adds the old bans back in.
*/
function gateKeep:LegacyBans()

	--SteamIDs
	for _, v in ipairs(gateKeep.HardCodedBans) do
		gateKeep:AddBan(v[1], v[2], v[3], "Hard coded perma-banned", 0)
	end

	--IPs
	/*for _, v in ipairs(gateKeep.HardCodedIPBans) do
		PrintTable(v)
		gateKeep:AddBan("unknown", v[2], v[1], "Hard coded perma-banned", 0)
	end*/

end

/*
* Checks against the database, without the need of the player entity
*/
function isPlayerBanned(ID, typ) --Check to see if the player is banned or not.

	for _, v in ipairs(gateKeep.Bans) do
		if (string.lower(typ) == "steamid" and ID == v.steamid)
		or (string.lower(typ) == "ip" and ID == v.ip) then
			if v.time != 0 and (v.bannedOn + v.time) <= os.time() then
				gateKeep:RemoveBan(v.steamid)
			else
				return v.reason
			end
		end
	end

end

function GetAuthorizedPlayers()

	return gateKeep.AuthorizedPlayers

end

hook.Add("Initialize", "GMTGateKeepInit", function()
		timer.Simple(0, function()
			gateKeep:GrabGoList()
			gateKeep:CreateBanList()
		end)
	end)

function gateKeep:AddBan(steamID, Name, ip, reason, time)
	--Adds the ban to the MySQL and the server-side variable.
	if !Name or Name == ""
	or type(reason) != "string" then return end

	local info = {}
	info.bannedOn = os.time()

	steamID = steamID or "unknown"
	reason = reason or "Old and useless"
	time = math.Clamp(time or 0, 0, math.huge)
	ip = ip or "unknown"

	if string.len(reason) > 30 then reason = "Old and useless" end

	if ip != "unknown" then

		local Pos = string.find(ip, ":")

		if !Pos then
			SQLLog('error', 'Banning a strange ip: ' .. tostring(ip) .. "\n")
			return
		end

		ip = string.sub(ip, 1, Pos - 1)

	end

	for i, v in ipairs(gateKeep.Bans) do

		if (string.lower(v.Name) == string.lower(Name))
		or (steamID != "unknown" and v.steamid == steamID)
		or (ip != "unknown" and v.ip == ip) then
			if v.time == time and (v.ip == ip or v.steamid == steamID) then --If the person already exists and his time is the same, do not add him again.
				return
			else
				info.Player = gateKeep.Bans[i]
				break
			end
		end

	end

	SQL.getDB():Query("SELECT * FROM gm_bans WHERE steamid=" .. SQLStr(steamID), function(res)
			if res[1].status != true then
				print("Error removing a ban: " .. res[1].error)
				return
			end

			if #res[1].data > 0 then
				SQL.getDB():Query("UPDATE gm_bans SET Name=" .. SQLStr(Name) .. ", reason=" .. SQLStr(reason) .. ", ip=" .. SQLStr(ip) .. ", bannedOn=" .. info.bannedOn .. ", time=" .. time .. " WHERE steamid=" .. SQLStr(steamID))
			else
				SQL.getDB():Query("INSERT INTO gm_bans (steamid, Name, ip, reason, bannedOn, time) VALUES (" .. SQLStr(steamID) .. ", " .. SQLStr(Name) .. ", " .. SQLStr(ip) .. ", " .. SQLStr(reason) .. ", " .. info.bannedOn .. ", " .. time .. ")")
			end
		end)

	if info.Player then --and info.Player.steamid == steamID then --If the player exists, then update the current ban

		if info.Player.steamid == "unknown" and info.Player.steamid != steamID then info.Player.steamid = steamID end
		info.Player.Name = Name
		if info.Player.ip == "unknown" and info.Player.ip != ip then info.Player.ip = ip end
		info.Player.reason = reason
		info.Player.bannedOn = info.bannedOn
		info.Player.time = time

	else

		table.insert(gateKeep.Bans, {
				["steamid"] = steamID,
				["Name"] = Name,
				["ip"] = ip,
				["reason"] = reason,
				["bannedOn"] = info.bannedOn,
				["time"] = time,
			})

	end

end

function gateKeep:RemoveBan(user) --Can be either a Name, steamID, or IP; continue is true when the gateKeep:RetrieveBans() is called, it's used to avoid an extra removal.
	--Removes the ban to the MySQL and the server-side variable.
	local typ

	if user or type(user) == "string" then
		/*local function testForIP(str)
			local possibleIP = string.Explode(".", str)

			if #possibleIP < 4 then return end

			function findpattern(text, pattern, start)
			 return string.sub(text, string.find(text, pattern, start))
			end


			for _, v in ipairs(possibleIP) do
				if string.sub(v, string.find(v, '%a', 1)) then return false end
			end

			return true

			return !string.sub(str, string.find(str, '%a', 1))

		end*/

		if string.match(user, "^(STEAM)") then
			typ = "steamid"
		/*elseif testForIP(user)then
			typ = "ip"*/
		else

			local newName
			typ = "Name"

			for i, v in ipairs(gateKeep.Bans) do

				if string.find(v.Name, user, 1, true) then
					table.remove(gateKeep.Bans, i)
					newName = v.Name
				end

			end

			if !newName then
				ErrorNoHalt("Ban doesn't exist.\n")
				return
			end

			user = newName

		end

	else
		ErrorNoHalt("Missing parameters. \n")
		return
	end

	SQL.getDB():Query("SELECT * FROM gm_bans WHERE " .. typ .. "=" .. SQLStr(user), function(res)
			if res[1].status != true then
				print("Error removing a ban: " .. res[1].error)
				return
			end

			if #res[1].data > 0 then
				SQL.getDB():Query("DELETE FROM gm_bans WHERE " .. typ .. "=" .. SQLStr(user))
			else
				ErrorNoHalt("Ban doesn't exist.\n")
			end
		end)

	/*if continue then return end
	print(2)
	--Checks to see if the table already exists.
	for i, v in ipairs(gateKeep.Bans) do
		if (typ == "steamid" and v.steamid == user) or (typ == "Name" and v.Name == user) then
			table.remove(gateKeep.Bans, i)
			break
		end
	end*/

end

function gateKeep:RetrieveBans(banList) --Obtains the bans from the MySQL.
	--Make sure to do a check:

	--local banList = sql.Query("SELECT * FROM gm_bans")

	for _, v in ipairs(banList) do

		v.bannedOn = tonumber(v.bannedOn)
		v.time = tonumber(v.time)

		if v.time != 0 and (v.bannedOn + v.time) <= os.time() then --If the amount of time as elapsed, then remove the line. time < os.time() then remove

			print(v.Name .. "'s ban has expired.")
			gateKeep:RemoveBan(v.steamid, true)

		else

			table.insert(gateKeep.Bans, {
				["steamid"] = v.steamid,
				["Name"] = v.Name,
				["ip"] = v.ip,
				["reason"] = v.reason,
				["bannedOn"] = v.bannedOn,
				["time"] = v.time
			})

		end

	end

end

function gateKeep:CheckPlayerBan(steam, ip)

	local checkResult = isPlayerBanned(steam, "steamid") or isPlayerBanned(ip, "ip")

	if checkResult then
		return {false, checkResult}
	end

	return {true}

end

hook.Add("PlayerAuthed", "OnlyGMTConnectionsSecondary", function(ply, steamID, UniqueID) --Makes sure that if the first line of security misses, this shouldn't.(At least, not as much)

		local playerBanned = gateKeep:CheckPlayerBan(steamID, ply:IPAddress())

		if !playerBanned[1] then
			RunConsoleCommand("kickid", ply:UserID(), playerBanned[2])
		end

	end)

hook.Add("PlayerPasswordAuth", "OnlyGMTConnections", function(Name, pass, steam, ip)

		local Gamemode = GTowerServers:Self()
		local Pos = string.find(ip, ":")

		if !Gamemode || !Pos then return end

		ip = string.sub(ip, 1, Pos - 1)

		local playerBanned = gateKeep:CheckPlayerBan(steam, ip)

		if !playerBanned[1] then return playerBanned end

		local message = "You are not authorized to join this server"

		--local clients = gatekeeper.GetNumClients()
		local total = gatekeeper.GetNumClients().total

		// allow admins to join regardless, based on steam
		if gateKeep.AdminBypass && IsAdmin(steam) then return end


		for _, v in ipairs( player.GetAll() ) do
			if v:IsAdmin() then
				total = total - 1
			end
		end

		if Gamemode.CheckForExtraSlots then

			if (total + 1) <= gateKeep.MaxSlots then return end
			message = "The server is full, and you aren't returning from another server."

		elseif total == Gamemode.MaxPlayers then

			// the maxplayers should be +1 so an admin can join, and also handle the bot
			if table.HasValue(GTowerAdmins, steam) then return end
			message = "This slot is reserved for admins"

		end

		if !gateKeep.AuthorizedPlayers[ip] then
			if Gamemode.Private then
				SQLLog( "multiserver", "Dropping connection from " .. tostring(ip) .. " (" .. tostring(Name) .. ") not authorized." )
			end
			return {false, message}
		end

	end)

/*
* Obtains the list of players currently on the server
*/
function gateKeep:GrabStackList(ServerID)
	local Query = "SELECT `id`,HEX(`lastplayers`) as `lastplayers`"
	.. "FROM `gm_servers` WHERE id!=" .. ServerID .. " AND `lastupdate`>" .. (os.time() - GTowerServers.UpdateTolerance)

	--Writes the new player's ips to a table.
	SQL.getDB():Query( Query, function(res)
			if res[1].status != true then
				print("Error getting players coming back" .. res[1].error)
				return
			end

			gateKeep.AuthorizedPlayers = {}

			if type(res[1].data) != "table" then return end

			for _, v in pairs(res[1].data) do

				for x, y in pairs(GTowerServers:PlayerListToIDs(v.lastplayers)) do

					gateKeep.AuthorizedPlayers[y] = true

				end

			end
		end)
end

function gateKeep:ResetEmptyReadyServer()

	local Count = player.GetCount()
	if Count == 0 && GTowerServers:GetState() == 3 then

		timer.Simple(60,function()
			local Count = player.GetCount()
			if Count == 0 && GTowerServers:GetState() == 3 then
				SQLLog( "multiserver", "In state 3 too long, changing level" )
				ErrorNoHalt("In state 3 but no players joined, restarting")
				GTowerServers:EmptyServer()
				--ChangeLevel(GTowerServers:GetRandomMap())
				local MapName = GTowerServers:GetRandomMap()
				hook.Call("LastChanceMapChange", GAMEMODE, MapName)
				RunConsoleCommand("changelevel", MapName)
			end
		end)
	end

end

// read text file generated to initialize list
function gateKeep:GrabGoingToServer(ServerID)

	local txt = "authedusers" .. tostring(GTowerServers:GetServerId()) .. ".txt"

	if file.Exists(txt, "DATA") then
		local contents = file.Read(txt)
		local ips = GTowerServers:PlayerListToIDs(contents)

		SQLLog( "multiserver", "Authorized ips " .. table.concat(ips, ", ") )
		for _, v in pairs(ips) do
			MultiUsers[v] = true
		end

		file.Delete(txt)

		// we can set state 3, ready for players, but this means we need to handle the case when nobody joins
		GTowerServers:SetState(3)
		timer.Simple( 45, function() gateKeep.ResetEmptyReadyServer() end)
	end

end

function gateKeep:GrabGoList()
	gateKeep.MaxSlots = GetMaxSlots()

	if !tmysql then return end

	local ServerID = GTowerServers:GetServerId()
	local Gamemode = GTowerServers:Self()

	if !Gamemode then return end

	// this server can overflow, if they're on the stack somewhere
	if Gamemode.CheckForExtraSlots then

		gateKeep:GrabStackList(ServerID)

		timer.Create( "GTowerServersGoList", 1, 0, function() gateKeep.GrabGoList() end)

	// this server can't overflow, but it can only accept connections from players from the list it got from gomap
	elseif Gamemode.Private then

		gateKeep:GrabGoingToServer(ServerID)

	end
end

concommand.Add("listauthorizedids", function(ply, cmd, args)
		if !IsValid(ply) or !ply:IsAdmin() then return end

		for k, _ in pairs(gateKeep.AuthorizedPlayers) do
			if !IsValid(ply) then
				print(k)
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, k)
			end
		end
	end)

concommand.Add("gmt_removeban", function(ply, cmd, args) --[1] = SteamID\Name

		if !ply:IsAdmin() or !args[1] then
			ply:PrintMessage(HUD_PRINTCONSOLE, "gmt_removeban <steamid/Name>\n")
			return
		end

		gateKeep:RemoveBan(args[1])

	end)

concommand.Add("gmt_ban", function(ply, cmd, args) --[1] = SteamID\UniqueID\Name, [2] = Time, [3] = Reason

		if !ply:IsAdmin() then
			return
		end

		if !args[1] or type(args[1]) != "string" then
			ply:PrintMessage(HUD_PRINTCONSOLE, "gmt_ban <steamID/uniqueID/Name> <time> <reason>\n")
			return
		end

		local function ChangeToSteamID(str)
			local steamid = str

			if steamid and !string.match(steamid, "^(STEAM)") then --If not a steamID, then it must be a Name
				--TODO: Needs to be cleaned up a little

				for _, v in ipairs(player.GetAll()) do
					if string.find(v:GetName(), steamid) or (tonumber(steamid) and v:UserID( ) == tonumber(steamid)) then steamid = v:SteamID() end
				end

				if steamid == str then return end

			end

			return steamid
		end

		local steamid = ChangeToSteamID(args[1])

		if !steamid then
			ErrorNoHalt("Player doesn't exist.")
			return
		end

		local banPlayer

		for _, v in ipairs(player.GetAll()) do
			if v:SteamID() == steamid then
				banPlayer = v
				break
			end
		end

		if !banPlayer then
			Msg("That is not a valid steamID.\n")
			return
		end

		local time, reason = tonumber(args[2]), args[3] or "Banned"

		if time > 0 then
			banPlayer:Ban( time, false )
			RunConsoleCommand("kickid", banPlayer:UserID(), reason )
		else
			banPlayer:Ban( 0, false )
			RunConsoleCommand("kickid", banPlayer:UserID(), reason )
		end

		/*local function convertTime()
			if time > 0 then
				return "for " .. time .. " second(s)"
			else
				return "permanently"
			end
		end

		gateKeep:AddBan(banPlayer:SteamID(), banPlayer:GetName(), banPlayer:IPAddress(), reason, time) --steam, Name, reason, amount

		//RunConsoleCommand("kickid", banPlayer:UserID(), "You have been banned " .. convertTime() .. " - Reason: " .. reason)
		// people have told me having too long of a kick message causes crashes, here's to test:
		RunConsoleCommand("kickid", banPlayer:UserID(), reason )*/
	end)

/*
* Allows a SUPERadmin to force ban a user. This allows the admin to ban a player than does not exist on the server at the time of ban.
*/
concommand.Add("gmt_forceban", function(ply, cmd, args) --[1] = Name, [2] = SteamID, [3] = Time, [4] = Reason

		if !ply:IsSuperAdmin()
		or !args[1] or type(args[1]) != "string"
		or !args[2] or !string.match(args[2], "^(STEAM)") then
			ply:PrintMessage(HUD_PRINTCONSOLE, "gmt_forceban <Name> <steamid> <time> <reason>\n")
			return
		end

		gateKeep:AddBan(args[2], args[1], "unknown", args[4], tonumber(args[3])) --steam, Name, ip, reason, amount

	end)

concommand.Add("gmt_checkbans", function(ply)

		if !ply:IsAdmin() then return end

		for i, v in ipairs(gateKeep.Bans) do

			ply:PrintMessage(HUD_PRINTCONSOLE, "i: " .. i)
			for j, k in pairs(v) do
				ply:PrintMessage(HUD_PRINTCONSOLE, j .. " = " .. k)
			end

		end

	end)

/*concommand.Add("gmt_clearbans", function(ply, cmd, args) --This will COMPLETELY clear the bans list. USE WITH CAUTION.
		if !ply:IsSuperAdmin()
		or args[1] != "foohyisoldanduseless"
		or (gateKeep.NextPossibleClear and gateKeep.NextPossibleClear > CurTime()) then return end

		gateKeep.NextPossibleClear = CurTime() + 900 --Can only be done every 15 minutes. This is to avoid taxing the server.
		print(ply:GetName() .. "(" .. ply:SteamID() .. ") HAS JUST CLEARED THE BANS LIST.")

		SQL.getDB():Query("TRUNCATE TABLE gm_bans")
		table.Empty(gateKeep.Bans)
		gateKeep:CreateBanList()

	end)*/
