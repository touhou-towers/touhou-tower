
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_command.lua")
AddCSLuaFile("cl_mapchooser.lua")
include("shared.lua")
//include("join.lua")
//include("servers.lua")
include("network.lua")
include("waiting.lua")
include("player.lua")
//include("Nametable.lua")
include("server/server.lua")
//include("mapchooser.lua")

GTowerServers.Servers = {}

function GTowerServers:GetServersResponse(res)

	if res[1].status != true then -- TODO
		ErrorNoHalt("GetServers error " .. res[1].error)
		--Msg( status .. "\n")
		return
	end

	for k, v in pairs( res[1].data ) do
		local Id = tonumber( v.id )

		if !Id then
			GTowerServers:CreateServer( Id )
		end

		local Server = self:Get( Id )

		if Server == nil then
			GTowerServers:CreateServer( Id )
			Server = self:Get( Id )
		end

		Server:LoadSQL( v )
	end

	hook.Call("GTowerServerUpdate")
end

function GTowerServers:GetServers()

	if !tmysql then
		return
	end

	//No use sending queries if the server is empty.
	if player.GetCount() == 0 then
		return
	end

	local Query = "SELECT `id`,`ip`,`port`,`players`,HEX(`playerlist`) as `playerlist`,`msg`,`maxplayers`,`map`,`password`,`gamemode`,`status`,`lastupdate`,HEX(`lastplayers`) as `lastplayers`"
	.. "FROM `gm_servers` WHERE id!=" .. self:GetServerId() .. " AND `lastupdate`>" .. (os.time() - self.UpdateTolerance)


	 SQL.getDB():Query( Query, function(res)
		 GTowerServers:GetServersResponse(res)
	 end)

end

timer.Create("GTowerRequestData", GTowerServers.UpdateRate, 0, function()  GTowerServers:GetServers()
end)

hook.Add("InitPostEntity", "GTowerServers1Request", function() GTowerServers:GetServers() end )

function GTowerServers:Get( Id )
	return self.Servers[ Id ]
end

concommand.Add("gmt_multisetid", function( ply, cmd, args )

	if !ply:IsAdmin() then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 5, cmd, args )
		end
		return
	end

	if #args != 2 then
		return
	end

	local Ent = ents.GetByIndex( tonumber( args[1] ) or 0  )
	local Id = tonumber( args[2] )

	if !Id then
		return
	end

	if !IsValid( Ent ) || Ent:GetClass() != "gmt_multiserver" then
		return
	end

	Ent:SetId( Id )

end )


concommand.Add("gmt_multijoin", function( ply, cmd, args )

	if !ply:IsAdmin() then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 5, cmd, args )
		end
		return
	end

	if #args != 1 then
		return
	end

	local ServerId = tonumber( args[1] )
	local Server = GTowerServers:Get( ServerId )

	if !Server || !Server:Online() then return end

	if Server.PlayerCount >= Server.ServerMaxPlayers then
		ply:Msg2( T("GamemodeFull", Server.gamemode) )
		return
	end

	timer.Simple(1.5, function()
		GTowerServers:RedirectPlayers( Server.Ip, Server.Port, Server.Password, {ply} )
	end)
end )
