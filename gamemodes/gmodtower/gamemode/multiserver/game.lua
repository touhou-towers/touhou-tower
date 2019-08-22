
/* ================================================
 * THIS FILE WILL BE DEDICATED TO MANAGE THE PLAYERS WITHIN THE SERVER
 * - Throw all players back into the main server
 * - Store what players are allowed to join the main server unconditually
 * - Throw players into a server
  ================================================  */

GTowerServers.EmptyingServer = false

function MakeSureGoneA( uniqueid, ip, port, password )

	for _, ply in pairs( player.GetAll() ) do
		if ply:SteamID() == uniqueid then

			//Player still exists in the server?
			ply:SendLua("RunConsoleCommand(\"password\", \"" .. password .. "\")")
			ply:SendLua("LocalPlayer():ConCommand(\"disconnect; connect " .. ip .. ":" .. port .. "\")")

			timer.Simple( 5.0,  function() MakeSureGoneB( ply:SteamID() ) end)
		end
	end

end

function MakeSureGoneB( uniqueid )

	for _, v in pairs( player.GetAll() ) do
		if v:SteamID() == uniqueid then
			v:Kick( "Not redirected." )
		end
	end

end

function GTowerServers:StopRedirecting()
	for _, v in ipairs( player.GetAll() ) do
		if IsValid( v ) then
			v.HideRedir = false
		end
	end
end

//BRUTE COMMAND TO REMOVE PLAYERS
function GTowerServers:RedirectPlayers( ip, port, password, players, NoCheckGone, gameMode )

	local rp = RecipientFilter()

	if !players then
		players = player.GetAll()
	end

	if gameMode then
		local gameName = gameMode.Name or "unspecified gamemode"
		local numPlayers = #players or "an unknown number of"

		for _, v in ipairs( player.GetAll() ) do
			if IsValid( v ) then
				v.HideRedir = true
				v:ChatPrint( "Starting a game of " .. gameName .. " with " .. tostring( numPlayers ) .. " players!\n" )
			end
		end
	end

	local ips = {}

	for _, ply in pairs( players ) do
		if IsValid(ply) then
			table.insert(ips, ply:Name() .. "@" .. ply:IPAddress())

			rp:AddPlayer( ply )
			ply:Msg2("Sending you to server " .. tostring(ip) .. ":" .. tostring(port) .. " pass: " .. tostring(password))

			if NoCheckGone != true then
				timer.Simple( 5.0,  function() MakeSureGoneA( ply:SteamID(), ip, port, password ) end)
			end

			if self.DEBUG then Msg("Setting player " .. tostring( ply ) .. " to serverID#: " .. tostring(serverid) .. "\n") end
		end
	end

	if #ips > 0 then
		SQLLog( "redirectplayers", "Redirecting " .. table.concat(ips, ", ") )
	end

	umsg.Start("MServ", rp )
		umsg.Char( 0 )
		umsg.String( ip )
		umsg.String( port )
		umsg.String( password )
	umsg.End()

	if gameMode then
		timer.Simple( 2, function() GTowerServers.StopRedirecting( self ) end)
	end

end

//Returns on the callback the table of the main server table
//If it fails, the calls the callback with nil
local function GetMainServerCallbackResult(callback, res)

	//Unable to execute query
	if res[1].status != true then
		Msg( res[1].status .. "\n")
		callback( nil )
		return
	end

	for _, v in pairs( res[1].data ) do
		//Make sure the server has send a signal in the last 5 minutes and that it is alive.
		if tonumber( v.lastupdate ) > (os.time() - GTowerServers.UpdateTolerance) then
			callback( v )
			return
		end
	end

	callback( nil )
end

function GTowerServers:GetMainServer( callback )

	 /*SQL.getDB():Query( "SELECT `ip`,`port`,`password`,`lastupdate` FROM `gm_servers` WHERE `gamemode`='gmodtowerlobby' AND `id`!=" .. self:GetServerId(), function(res)
	GetMainServerCallbackResult(callback, res) end)*/

	SQL.getDB():Query( "SELECT `ip`,`port`,`password`,`lastupdate` FROM `gm_servers` WHERE `gamemode`='gmodtowerlobby' AND `id`!=" .. self:GetServerId(), GetMainServerCallbackResult, callback)

end

//Function to check what is the main server and send them there
//If if fails, call the failsafe function

concommand.Add('gmt_returntolobby', function( ply )
	GTowerServers:SendMainServer( {ply} )
end)

function GTowerServers:SendMainServer( Players )
	GTowerServers:GetMainServer( function( server )
		if !server then
			GTowerServers:FailSafeRemove( Players )
			return
		end

		GTowerServers:RedirectPlayers( server.ip, server.port, server.password, Players, true )
	end )
end

function GTowerServers:FailSafeRemove( Players )
	//this doesn't get the failsafeb, so just kick them
	// SIKE, FORCE CONNECT THEM THROUGH SENDING LUA AND RUNNING CONSOLE COMMANDS AS THE LOCAL PLAYER!
	for k,v in pairs(Players) do
		if IsValid(v) then
			--v:Kick("(This will be fixed soon.) Unable to find main server, try rejoining from the server browser or IP: join.gmodtower.org")
			v:SendLua([[LocalPlayer():ConCommand("connect join.gmodtower.org")]])
		end
	end
end


//Command to make sure all players will be redirected to the main server
//And they will be added to the stack allowing them to by-pass the max players
function GTowerServers:AuthorizeJoinedPlayers(golist)
	local PlayersIPs = {}

	for ip, v in pairs( golist ) do
		table.insert( PlayersIPs, ip )
	end

	local HexData = self:ListToHex( PlayersIPs )
	self:UpdateDatabase( HexData )
end

function GTowerServers:EmptyServer()

	// no need to empty again, we've already processed it
	if GTowerServers.EmptyingServer then return end

	SQLLog( "server", "Empty server"  )
	GTowerServers.EmptyingServer = true

	//Make a query to allow all the players that were previsuly accepted here
	//Be accepted in the main server at any cost
	GTowerServers:AuthorizeJoinedPlayers(GetAuthorizedPlayers())

	local Gamemode = self:Self()

	if Gamemode && Gamemode.Private == true then
		//I don't want confusions with people coming back
		GTowerServers:SetRandomPassword()
	end

end

local function EmptyNow()
	if !GTowerServers.EmptyingServer then return end

	for k,v in pairs(player.GetAll()) do
		v:Kick("Not redirected!")
	end
end

local function GoAway()
	if !GTowerServers.EmptyingServer then return end

	gatekeeper.DropAllClients("The game has ended")

	local clients = gatekeeper.GetNumClients()
	if clients.total > 0 then
		SQLLog( "multiserver", "Server is changing level but numClients > 0 !!!!!" )
	end
end

hook.Add("MapChange", "EmptyServerForReal", EmptyNow)
hook.Add("LastChanceMapChange", "EmptyServerLast", GoAway)

local function UpdatedDatabaseEmptyResult(res)
	if res[1].status != true then
		Msg( tostring(res[1].status) .. "\n")
		return
	end
end

hook.Add("GTowerServersDatabaseUpdated", "EmptyServer", function()
	if !GTowerServers.EmptyingServer then return end

	local allplayers = player.GetAll()

	// let's make sure the servers sync
	timer.Simple(1.5, function()
		//Now we send all the players to the main server
		GTowerServers:SendMainServer( allplayers )
	end)
end)

concommand.Add("gmt_emptyserver", function( ply, cmd, args )

	if ply == NULL || ply:IsAdmin() then

		GTowerServers:EmptyServer()

	end


end )
