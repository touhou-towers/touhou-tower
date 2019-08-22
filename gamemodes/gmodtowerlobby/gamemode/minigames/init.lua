include("shared.lua")

concommand.Add("gmt_loadmini", function( ply, cmd, args )
	
	if !ply:IsAdmin() then
		return
	end
	
	local MiniGameStr = args[1]
	if !MiniGameStr then 
		ply:Msg2("gmt_loadmini <gamename>")
		return
	end
	
	local MiniGame = minigames[ MiniGameStr ]
	if !MiniGame then 
		ply:Msg2("Could not find minigame.")
		return 
	end
	
	for _, v in ipairs(player.GetAll()) do
		v:MsgT( minigames[ MiniGameStr ]._M.MinigameMessage, ( minigames[ MiniGameStr ]._M.MinigameArg1 or "" ), ( minigames[ MiniGameStr ]._M.MinigameArg2 or "" ) )
	end
	AdminNotify(T( "AdminMiniStart", ply:GetName(), minigames[ MiniGameStr ]._M.MinigameName or MiniGameStr ))
	SafeCall( MiniGame.Start, args[2] or "" )
	
end )

concommand.Add("gmt_endmini", function( ply, cmd, args )
	
	if !ply:IsAdmin() then
		return
	end
	
	local MiniGameStr = args[1]
	if !MiniGameStr then 
		ply:Msg2("gmt_loadmini <gamename>")
		return
	end
	
	local MiniGame = minigames[ MiniGameStr ]
	if !MiniGame then 
		ply:Msg2("Could not find minigame")
		return 
	end
	
		AdminNotify(T( "AdminMiniEnd", ply:GetName(), minigames[ MiniGameStr ]._M.MinigameName or MiniGameStr ))

	SafeCall( MiniGame.End )
	
end )