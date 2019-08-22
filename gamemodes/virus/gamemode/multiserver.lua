hook.Add("GTowerMsg", "GamemodeMessage", function()
	if GAMEMODE.CurrentRound == 0 then		
		return "#nogame"
	else
		return GAMEMODE:GetTimeLeft() .. "||||" .. tostring( GAMEMODE.CurrentRound ) .. "/" .. GAMEMODE.NumRounds
	end
end )

function GM:EndServer()

	GTowerServers:EmptyServer()
		
	timer.Simple( 2.5, function()
		local map = (GTowerServers:GetRandomMap() or GAMEMODE:RandomMap( "gmt_virus" ))
		hook.Call("LastChanceMapChange", GAMEMODE, map)
		RunConsoleCommand("changelevel", map)
	end)
	
end