local function GetRandomSong( idx )

	local song = GAMEMODE.Music[idx][1] .. math.random( 1, GAMEMODE.Music[idx][2] ) .. ".mp3"
	//Msg( "Random Song: " .. song, "\n" )
	return song

end

function PlayMusic( idx, teamid )

	idx = idx or MUSIC_WAITING

	local ply = LocalPlayer()
	if !IsValid( ply ) then  //well this is awkward, lets try again

		timer.Simple( 1, function()

			Msg( "Failed to play song, attempting again." )
			PlayMusic( idx, teamid )

		end )

		return

	end
	
	if idx == MUSIC_WAITING then

		if ply.WaitingMusic && ply.WaitingMusic:IsPlaying() then
			ply.WaitingMusic:FadeOut( 1 )
		end

		ply.WaitingMusic = CreateSound( ply, GetRandomSong( MUSIC_WAITING ) )
		ply.WaitingMusic:PlayEx( 80, 100 )

	end

	if idx == MUSIC_ROUND then

		if ply.WaitingMusic && ply.WaitingMusic:IsPlaying() then
			ply.WaitingMusic:FadeOut( 1 )
		end

		if ply.Music && ply.Music:IsPlaying() then
			ply.Music:FadeOut( 1 )
		end

		if ply.EndRoundMusic then
			ply.EndRoundMusic:Stop()
		end

		timer.Simple( 2, function()
			ply.Music = CreateSound( ply, GetRandomSong( MUSIC_ROUND ) )
			ply.Music:PlayEx( 25, 100 )
		end )
		
	end

	if idx == MUSIC_ENDROUND then
		
		if ply.SpawnMusic && ply.SpawnMusic:IsPlaying() then
			ply.SpawnMusic:Stop()
			ply.SpawnMusic = nil
		end

		if ply.Music && ply.Music:IsPlaying() then
			ply.Music:FadeOut( 0.5 )
		end

		local song = GAMEMODE.Music[ MUSIC_ENDROUND ].Tie

		if teamid then

			if teamid == TEAM_PIGS then

				if ply:Team() == TEAM_PIGS || ply.IsGhost then

					song = GAMEMODE.Music[ MUSIC_ENDROUND ].Pigmask.win

				else

					song = GAMEMODE.Music[ MUSIC_ENDROUND ].Chimera.lose

				end

			elseif teamid == TEAM_CHIMERA then

				if ply.IsChimera then

					song = GAMEMODE.Music[ MUSIC_ENDROUND ].Chimera.win

				else

					song = GAMEMODE.Music[ MUSIC_ENDROUND ].Pigmask.lose

				end
				
			elseif teamid == TEAM_SALSA then

				song = GAMEMODE.Music[ MUSIC_ENDROUND ].Salsa
				
			end
	
		end

		ply.EndRoundMusic = CreateSound( ply, song )
		ply.EndRoundMusic:PlayEx( 100, 100 )

	end

	if idx == MUSIC_SPAWN then

		local song = nil
		
		if ply.SpawnMusic && ply.SpawnMusic:IsPlaying() then
			ply.SpawnMusic:Stop()
			ply.SpawnMusic = nil
		end

		if ply.IsChimera then

			song = GAMEMODE.Music[ MUSIC_SPAWN ].Chimera

		elseif !ply.IsGhost then

			local rank = ply.Rank

			if rank == RANK_ENSIGN then

				song = GAMEMODE.Music[ MUSIC_SPAWN ].Pigmask.ensign

			elseif rank == RANK_CAPTAIN then

				song = GAMEMODE.Music[ MUSIC_SPAWN ].Pigmask.captain

			elseif rank == RANK_MAJOR then

				song = GAMEMODE.Music[ MUSIC_SPAWN ].Pigmask.major

			elseif rank == RANK_COLONEL then

				song = GAMEMODE.Music[ MUSIC_SPAWN ].Pigmask.colonel

			end

		end

		if song then
			ply.SpawnMusic = CreateSound( ply, song )
			ply.SpawnMusic:PlayEx( 100, 100 )
		end
		
	end

	if idx == MUSIC_GHOST then

		if ply.Music then
			ply.Music:FadeOut( 1 )
		end

		timer.Simple( 1, function()

			local song = GetRandomSong( MUSIC_GHOST )
			if ply.IsFancy then
				song = GetRandomSong( MUSIC_FGHOST )
			end

			ply.Music = CreateSound( ply, song )
			ply.Music:PlayEx( 100, 100 )

		end )
		
	end

	if idx == MUSIC_30SEC then

		if ply.IsGhost then return end

		if ply.Music then
			ply.Music:Stop()
		end

		ply.Music = CreateSound( ply, GAMEMODE.Music[ MUSIC_30SEC ] )
		ply.Music:PlayEx( 100, 100 )
		
	end
	
	if idx == MUSIC_MRSATURN then

		if ply.SpawnMusic && ply.SpawnMusic:IsPlaying() then
			ply.SpawnMusic:Stop()
			ply.SpawnMusic = nil
		end

		ply.SpawnMusic = CreateSound( ply, GAMEMODE.Music[ MUSIC_MRSATURN ] )
		ply.SpawnMusic:PlayEx( 100, 100 )

	end

end

usermessage.Hook( "UC_PlayMusic", function( um )

	local idx 		= um:ReadChar() //Music index
	local teamid	= um:ReadChar() //Team that won

	PlayMusic( idx, teamid )

end )