game.ConsoleCommand("sv_scriptenforcer 1\n")
GTowerServers:SetRandomPassword()

hook.Add("GTowerMsg", "GamemodeMessage", function()

	if GetGlobalInt("Round") == 0 then		
		return "#nogame"
	else
		return math.ceil( GAMEMODE:GetTimeLeft() ).. "||||" .. tostring( GetGlobalInt("Round") ) .. "/" .. GAMEMODE.NumRounds
	end

end )


function GM:EndServer()
	//I guess it it good bye
	GTowerServers:EmptyServer()

	--timer.Simple( 2.5, ChangeLevel, GTowerServers:GetRandomMap() or GAMEMODE:RandomMap( "gmt_ballracer" ) )
	timer.Simple(2.5,function()

		local map = (GTowerServers:GetRandomMap() or GAMEMODE:RandomMap( "gmt_uch" ))

		hook.Call("LastChanceMapChange", GAMEMODE, map)
		RunConsoleCommand("changelevel", map)

	end)

	Msg( " !! You are all dead !!\n" )

end

/*function GM:GiveMoney( teamid )

	local ThanksForPlaying = 10
	local ChimeraBonus = 10
	
	for _, v in ipairs( player.GetAll() ) do

		local money = ThanksForPlaying  // everyone gets something for just playing

		if !v.IsChimera then money = money + ( v.Rank * 8 ) end  // pigs with higher rank get a bonus
		
		//Chimera won
		if teamid == TEAM_CHIMERA then

			if v.IsChimera then

				money = money + ChimeraBonus + ( ( v.HighestKilledRank or 0 ) * 8 )
				local totalpigs = #team.GetPlayers( TEAM_PIGS ) + #team.GetPlayers( TEAM_GHOST )
				
				if totalpigs >= 2 then
					money = money * ( totalpigs * .75 ) // chimera gets paid a little more for more action
				end
				
			elseif v:Team() == TEAM_PIGS || v:Team() == TEAM_GHOST then

				money = money - ChimeraBonus  // you lost

			end

		elseif teamid == TEAM_PIGS then //Pigs won

			if v:Team() == TEAM_PIGS then

				money = money + ChimeraBonus  // alive players get more bonus

			elseif v:Team() == TEAM_GHOST then

				money = money + ( ChimeraBonus / 2 )  // you died during play, half of the winning bonus for you

			end

		end

		v:AddMoney( money )

	end
	
end*/