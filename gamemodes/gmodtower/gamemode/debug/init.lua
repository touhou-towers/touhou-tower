
include("shared.lua")
include("sql.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("GTDebug")

function DEBUG:AddPlayer( ply, Name )

	local item = self.List[ Name ]

	if !item then
		return
	end

	if !item.listen then
		item.listen = {}
	end

	if !table.HasValue( item.listen, ply ) then
		table.insert( item.listen, ply )
	end

	DEBUG:Enable( Name )

end

function DEBUG:RemovePlayer( ply, Name )

	local item = self.List[ Name ]

	if !item then
		return
	end

	if item.listen then
		for k, v in ipairs( item.listen ) do

			if v == ply then
				table.remove( item.listen, k )
			end

		end

		if table.Count( item.listen ) == 0 then
			DEBUG:Disable( Name )
		end

	end



end


concommand.Add("debug_listen", function( ply, cmd, args )

	if !ply:IsAdmin() then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 5, cmd, args )
		end
		return
	end

	if #args != 2 then
		return
	end

	local Name = args[1]
	local Enable = tobool( args[2] )

	if DEBUG:Exists( Name ) then

		if Enable == true then
			DEBUG:AddPlayer( ply, Name )
		else
			DEBUG:RemovePlayer( ply, Name )
		end

	end

end )


hook.Add("DebugMsg", "SendClientMessage", function( Name, msg )

	local item = DEBUG.List[ Name ]

	if !item || !item.listen || #item.listen == 0 then
		return
	end

	local players = {}

	for _, ply in pairs( item.listen ) do
		table.insert( players, ply )
	end

	if #players == 0 then
		return
	end

	if string.len( Name ) + string.len( msg ) > 254 then
		msg = string.sub( msg, 1, 254 - string.len( Name ) )
	end

	local rp = RecipientFilter()

	for _, ply in pairs( players ) do
		rp:AddPlayer( ply )
	end

	net.Start("GTDebug")
		net.WriteString( Name )
		net.WriteString( msg )
	net.Send(rp)

	/*umsg.Start("GTDebug", rp )
		umsg.String( Name )
		umsg.String( msg )
	umsg.End()*/

end )

hook.Add("PlayerDisconnected", "RemoveDebug", function( ply )
	for _, v in pairs( DEBUG.List ) do
		if v.listen then
			table.RemoveValue( v.listen, ply )
		end
	end
end )
