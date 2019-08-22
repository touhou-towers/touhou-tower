
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("game.lua")
include("password.lua")
include("gamemode.lua")
include("hex.lua")
include("gatekeeper.lua")

/*
	STATE LIST

	1 = Ready to get players
	2 = Server is busy
	3 = Has a list of players and ready to receive them
*/
GTowerServers.CurState = 0

local UpdateInProgress = false

function GTowerServers:GetState()
	return GTowerServers.CurState
end

function GTowerServers:SetState( state )
	GTowerServers.CurState = state

	SQLLog( "multiserver", "State changed to: " .. tostring( state ) )
end

function GM:SetStatus( state )
	GTowerServers:SetState( state )
end
GM.SetState = GM.SetStatus

function GTowerServers:GetServerId()
	return GetConVarNumber("gmt_srvid")
end

function GTowerServers:GetMessage()
	local HookMessages = hook.GetTable().GTowerMsg

	if HookMessages then
		for _, v in pairs( HookMessages ) do
			if type( v ) == "function" then
				return v()
			end
		end
	end

	return ""
end

function DecodePlayersFromSQLId(hex)
	local players = {}
	local data = Hex( hex )

	while data:CanRead( 8 ) do
		table.insert(players, data:Read(8))
	end

	return players
end

local function GetPlayerSQLIdHex()

	local Data = Hex()
	local PlayerList = player.GetAll()

	for _, ply in pairs( PlayerList ) do
		if ply.SQL && ply.SQL.Connected == true then
			Data:Write( ply:SQLId(), 8 )
		end
	end

	return Data:Get(), #PlayerList

end

local function GTowerServerDatabaseResult(res)
	UpdateInProgress = false

	if res[1].status != true then
		--ErrorNoHalt("DatabaseUpdate error " .. tostring(error)) -- We do have DB errors tmysql? What do
		--Msg( status .. "\n")
		return
	end

	hook.Call("GTowerServersDatabaseUpdated", GAMEMODE)
end

//The playerstack will be the list of players that will be allowed to join the main server
function GTowerServers:UpdateDatabase( playerstack )

	if !tmysql then
		Msg("TMysql Module still not loaded\n")
		return
	end

	local ServerID = self:GetServerId()
	local PlayerData, PlayerCount = GetPlayerSQLIdHex()
	local MapName =  SQL.getDB():Escape( string.lower( game.GetMap() ) ) //I don't know why I am escaping this
	local GameMode = self:Gamemode()
	local PassWord =  SQL.getDB():Escape( GetConVarString("sv_password") )

	if !MapName then
		return
	end

	if ServerID == 0 then
		Msg("No Server id found")
		return
	end

	local Query = "UPDATE `gm_servers` SET "
	.. "`players`=" .. PlayerCount
	.. ",`maxplayers`=" .. game.MaxPlayers()
	.. ",`map`='" .. MapName .. "'"
	.. ",`gamemode`='" .. GameMode .. "'"
	.. ",`password`='" .. PassWord .. "'"
	.. ",`status`='" .. self:GetState() .. "'"
	.. ",`playerlist`=" .. PlayerData .. ""
	.. ",`lastupdate`=" .. os.time()

	if playerstack then
		Query = Query .. ",`lastplayers`=" .. playerstack .. ""
	end

	local GameMessage = GTowerServers:GetMessage()
	if GameMessage then
		Query = Query .. ",`msg`='" ..  SQL.getDB():Escape( GameMessage ) .. "'"
	end

	Query = Query .. " WHERE id=" .. ServerID

	UpdateInProgress = true
	 SQL.getDB():Query( Query, function(res)
		 GTowerServerDatabaseResult(res)
	 end)
end

function UpdateMultiServer()
	GTowerServers:UpdateDatabase()
	timer.Start("GTowerServersRepeat")
end

hook.Add("MapChange", "GTowerMultiServersMap", function()
	//GTowerServers:SetState( 0 )
	UpdateMultiServer()
end )
hook.Add("InitPostEntity", "GTowerMultiServerInit", function()
	if GTowerServers:GetState() <= 1 then
		GTowerServers:SetState( 1 )
	end
	GTowerServers:UpdateDatabase()
end )
hook.Add("CanChangeLevel", "UpdatingMultiServer", function()
	if UpdateInProgress == true then
		return false
	end
end )


hook.Add("SQLConnect", "GTowerServersConnect", UpdateMultiServer )
hook.Add("PlayerDisconnected", "GTowerServersDisConnect", UpdateMultiServer	)
timer.Create( "GTowerServersRepeat", GTowerServers.UpdateRate, 0, function()
	UpdateMultiServer()
end)
