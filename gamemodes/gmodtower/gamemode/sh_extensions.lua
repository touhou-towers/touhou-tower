
local ExtensionList = {'cl_webmaterials','string','table','hook','safecall','tesla','concommand','disco','sv_hextable','cl_bass', 'entity_messages', 'util', 'umsg', 'sh_msg', 'sh_net', 'sh_player', 'sh_time', 'sh_entity' }

local function LoadExtensions( base )

	for _, v in pairs( ExtensionList ) do

		local Prefix = string.sub( v, 0, 3 )
		local IsServer = Prefix == "sv_"
		local IsClient = Prefix == "cl_"
		local Both = IsServer == false && IsClient == false
		local File = base .. "extensions/".. v ..".lua"

		if SERVER && (IsClient || Both) then
			AddCSLuaFile( File )
		end

		if Both || (SERVER && IsServer) || (CLIENT && IsClient) then
			include( File )
		end

	end

end

//Load it now, empty folder, since it is relative
LoadExtensions( "" )

function ReloadExtensions()
	//Load it relative to the lua base folder
	LoadExtensions( string.sub( GM.Folder, 11 )  .. "/gamemode/" )
end

if SERVER then
	concommand.Add("gmt_reloadexts", function( ply )

		if !ply:IsAdmin() then
			return
		end

		if game.SinglePlayer() || !game.IsDedicated() then
			ply:SendLua("ReloadExtensions()")
		end

		ReloadExtensions()

	end )
end
