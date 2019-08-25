function GM:EndServer()
	-- I guess it it good bye
	GTowerServers:EmptyServer()

	--timer.Simple( 2.5, ChangeLevel, GTowerServers:GetRandomMap() or GAMEMODE:RandomMap( "gmt_ballracer" ) )
	timer.Simple(
		2.5,
		function()
			local map = (GTowerServers:GetRandomMap() or GAMEMODE:RandomMap("gmt_zm_arena"))

			hook.Call("LastChanceMapChange", GAMEMODE, map)
			RunConsoleCommand("changelevel", map)
		end
	)

	Msg(" !! You are all dead !!\n")
end

function GM:EnterPlayingState()
	if self.CurrentLevel == 0 then
		self:AdvanceLevelStatus()
	end

	self:SetState(2)
end
