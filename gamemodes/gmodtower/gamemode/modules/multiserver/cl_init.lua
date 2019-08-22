
include("shared.lua")
include("cl_command.lua")
include("cl_mapchooser.lua")

GTowerServers.Servers = {}
GTowerServers.Ents = {}


GTowerServers.WaitinglistSrv = 0
GTowerServers.Vgui = nil

usermessage.Hook("GServ", function(um)

	local MsgId = um:ReadChar()

	if MsgId == 1 then

		GTowerServers:GetServerList( um )

	elseif MsgId == 4 then

		Msg2( "A player has left your group. Your group have been removed from the server waiting list." )

	elseif MsgId == 7 then

		Msg2( "You are not the group owner. Only group owners can choose the server." )

	elseif MsgId == 8 then

		Msg2( "You need to be a in a group to join this server." )

	elseif MsgId == 9 then
		//This message is to give that the server is ready and at what time it will redirect people

		local ServerId = um:ReadChar()
		local Endtime = um:ReadLong()
		local Server = GTowerServers:Get( ServerId )

		Server.RedirectingTime = Endtime

		//TODO: Give message game is starting
		//GtowerMessages:AddNewItem( "Server " .. GTowerServers.ServerNames[ ServerId ] .. " ready to play in: " .. Endtime .. " seconds ", Endtime - 0.75 )

	elseif MsgId == 10 then
		//This message is to give that server that was ready, is no longer ready

		local ServerId = um:ReadChar()
		local Server = GTowerServers:Get( ServerId )

		Server.RedirectingTime = nil

		GTowerServers:NoLongerWorking( ServerId )

	elseif MsgId == 11 then

		local ServerId = um:ReadChar()
		local Timeleft = um:ReadLong()
		local Gamemode = um:ReadString()
		local NumMaps = um:ReadChar()
		local MapVotes = {}
		local CooldownMapVotes = {}

		for i=1, NumMaps do
			MapVotes[ i ] = um:ReadChar()
			--Msg("Reading vote: " , MapVotes[ i ] , "\n")
		end
		
		for i=1, NumMaps do
			CooldownMapVotes[i] = um:ReadChar()
		end

		GTowerServers:OpenChooser( ServerId, Timeleft, Gamemode, MapVotes, CooldownMapVotes )

	elseif MsgId == 12 then

		GTowerServers:CloseMapChooser()

	else
		Msg("Called GServ with invalid id: " .. MsgId .. "\n")
	end

end )

local function SortByQueueTime(a, b)
	if a.QueueTime == b.QueueTime && a.Name && b.Name then
		return a:EntIndex() < b:EntIndex()
	end

	return (a.QueueTime or 0) < (b.QueueTime or 0)
end

function GTowerServers:GetServerList( um )

	local ServerId = um:ReadChar()
	local Online = um:ReadBool()
	local Server = GTowerServers:Get( ServerId )
	local ServerChange = false

	if Online then

		local ReadyForPlayers = um:ReadBool()
		local Players = {}

		local bits = um:ReadChar()
		for i=1,bits do
			if um:ReadBool() then
				table.insert(Players, Entity(i))
			end
		end

		table.sort(Players, SortByQueueTime)

		ServerChange = Server.Ready != ReadyForPlayers
		Server.Players = Players
		Server.Ready = ReadyForPlayers
	end

	Server.Online = Online

	hook.Call("GTowerServerUpdate", GAMEMODE, ServerId )
	self:UpdateEntities( ServerChange )
end

function GTowerServers:UpdateEntities( ServerChange )

	for _, v in pairs( ents.FindByClass("gmt_multiserver") ) do

		if v.UpdateData then
			v:UpdateData( ServerChange )
		end

	end

end

function GTowerServers:Get( id )
	if !self.Servers[id] then
		self.Servers[id] = {
			Id = id,
			Players = {},
			Online = false
		}
	end

	return self.Servers[id]
end

hook.Add("OpenSideMenu", "MultiServerAdmin", function()

	if !LocalPlayer():IsAdmin() then return end
	local Ent = LocalPlayer():GetEyeTrace().Entity

	if !IsValid( Ent ) || Ent:GetClass() != "gmt_multiserver" then
		return
	end

	local Form = vgui.Create("DForm")
	Form:SetName( tostring(Ent) )
	local Id = Ent:Id()

	local ChangeId = Form:Button( "Change ID (".. tostring(Id) ..")")
	ChangeId.DoClick = function()
		Derma_StringRequest( "Set server id: " .. tostring(Ent) ,
			"Set server id: " .. tostring(Ent),
			Id,
			function( strTextOut )
				local Output = tonumber( strTextOut )
				if Output then
					Msg2("You set " .. tostring(Ent) .. " to " .. Output )
					RunConsoleCommand("gmt_multisetid", Ent:EntIndex(), Output )
				end
			end,
			EmptyFunction,
			"Update",
			"Cancel" )
	end

	local JoinServer = Form:Button( "Join server")
	JoinServer.DoClick = function()

		Derma_Query( "Join server " .. tostring(Ent.ServerName),
			"Join server " .. tostring(Ent.ServerName),
			"JOIN", function() RunConsoleCommand("gmt_multijoin", Id ) end,
			"Cancel", EmptyFunction
		)
	end

	return Form

end )
