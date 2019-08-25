function GM:EndServer()
	GTowerServers:EmptyServer()

	timer.Simple(
		2.5,
		function()
			local map = (GTowerServers:GetRandomMap() or GAMEMODE:RandomMap("gmt_minigolf"))

			hook.Call("LastChanceMapChange", GAMEMODE, map)
			RunConsoleCommand("changelevel", map)
		end
	)
end
