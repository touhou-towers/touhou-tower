
module("GTowerMapChange", package.seeall )

DefaultTime = 10

SetGlobalInt( "NewTime", 0 )
SetGlobalBool( "ShowChangelevel", false )

concommand.Add( "gmt_changelevel", function( ply, command, args, str )

	if ply == NULL or ply:IsAdmin() then
		if str == '' then
			ChangeLevel( game.GetMap(), ply )
		else
			ChangeLevel( str, ply )
		end
	else
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 5, command, args )
		end
	end

end )

concommand.Add( "gmt_forcelevel", function( ply, command, args, str )

	if ply == NULL or ply:IsAdmin() then
		RunConsoleCommand("changelevel", str)
	end

end )

local function FinalChangeHook(MapName)
	hook.Call("LastChanceMapChange", GAMEMODE, MapName)

	RunConsoleCommand("changelevel", MapName)
end

function ChangeLevel( map, ply )

	if timer.Exists( "ChangelevelTimer" ) then
		timer.Remove( "ChangelevelTimer" )
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[GTowerChat.Chat:AddText("Halting map restart...", Color(225, 20, 20, 255))]])
			end
			return
	end

	local FilePlace = "maps/"..map..".bsp"
	local MapName = map

	if file.Exists(FilePlace,"GAME") then
		for k,v in pairs(player.GetAll()) do
			v:SendLua([[GTowerChat.Chat:AddText("Restarting map for update in ]]..DefaultTime..[[ seconds...", Color(225, 20, 20, 255))]])
			--v:SendLua([[surface.PlaySound( "gmodtower/misc/changelevel.wav" )]])
		end

		timer.Create( "ChangelevelTimer", (DefaultTime - 0.5), 1, function()
			for k,v in pairs(player.GetAll()) do
				v:SendLua([[GTowerChat.Chat:AddText("Restarting map for update...", Color(225, 20, 20, 255))]])
			end
			timer.Simple(0.5, function() FinalChangeHook(MapName) end)
		end)

	else
		ply:Msg2("'"..map.."' not found on server! Use gmt_forcelevel to force a level change.")
	end
end
