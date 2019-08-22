
-----------------------------------------------------
local function GetRandomSong( idx )
	return GAMEMODE.Music[idx][1] .. math.random( 1, GAMEMODE.Music[idx][2] ) .. ".mp3"
end
function PlayMusic( idx, win )
	idx = idx or MUSIC_WAITING
	local ply = LocalPlayer()
	if !IsValid( ply ) then  //well this is awkward, lets try again
		timer.Simple( 1, function()
			//Msg( "Failed to play song, attempting again.\n" )
			PlayMusic( idx, win )
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
	if idx == MUSIC_UPGRADING then
		if ply.WinLoseMusic && ply.WinLoseMusic:IsPlaying() then
			ply.WinLoseMusic:FadeOut( 1 )
		end

		if ply.BossMusic && ply.BossMusic:IsPlaying() then
			ply.BossMusic:FadeOut( 1 )
		end
		if ply.WaitingMusic && ply.WaitingMusic:IsPlaying() then
			ply.WaitingMusic:FadeOut( 1 )
		end
		ply.UpgradingMusic = CreateSound( ply, GetRandomSong( MUSIC_UPGRADING ) )
		ply.UpgradingMusic:PlayEx( 80, 100 )
	end
	if idx == MUSIC_WARMUP then
		if ply.UpgradingMusic && ply.UpgradingMusic:IsPlaying() then
			ply.UpgradingMusic:FadeOut( 1 )
		end
		ply.WarmupMusic = CreateSound( ply, GetRandomSong( MUSIC_WARMUP ) )
		ply.WarmupMusic:PlayEx( 80, 100 )
	end
	if idx == MUSIC_ROUND then
		if ply.WarmupMusic && ply.WarmupMusic:IsPlaying() then
			ply.WarmupMusic:FadeOut( 1 )
		end

		if ply.Music && ply.Music:IsPlaying() then
			ply.Music:FadeOut( 1 )
		end
		if ply.WinLoseMusic then
			ply.WinLoseMusic:Stop()
		end

		--local song = GAMEMODE.Music[ MUSIC_ROUND ][1] .. ( ( GetGlobalInt( "Difficulty" ) + 1 ) or 2 ) .. ".mp3"
		local song = GAMEMODE.Music[ MUSIC_ROUND ][1] .. ( GetGlobalInt( "Round" ) + 1 ) .. ".mp3"
		ply.Music = CreateSound( ply, song )
		ply.Music:PlayEx( 25, 100 )
	end
	if idx == MUSIC_WINLOSE then
		if ply.Music && ply.Music:IsPlaying() then
			ply.Music:FadeOut( 0.5 )
		end
		if ply.DeathMusic then
			ply.DeathMusic:Stop()
		end
		local song = GAMEMODE.Music[ MUSIC_WINLOSE ].Lose
		if win then
			song = GAMEMODE.Music[ MUSIC_WINLOSE ].Win
		end

		ply.WinLoseMusic = CreateSound( ply, song )
		ply.WinLoseMusic:PlayEx( 100, 100 )
	end
	if idx == MUSIC_BOSS then
		if ply.Music then
			ply.Music:Stop()
		end
		if ply.DeathMusic then
			ply.DeathMusic:Stop()
		end
		if ply.WinLoseMusic then
			ply.WinLoseMusic:Stop()
		end
		ply.BossMusic = CreateSound( ply, GetRandomSong( MUSIC_BOSS ) )
		ply.BossMusic:PlayEx( 100, 100 )
	end

	if idx == MUSIC_DEATH then
		if ply.Music then
			ply.Music:ChangeVolume( .1, 0 )
		end

		if ply.BossMusic then
			ply.BossMusic:ChangeVolume( .1, 0 )
		end
		ply.DeathMusic = CreateSound( ply, GAMEMODE.Music[ MUSIC_DEATH ] )
		ply.DeathMusic:PlayEx( 100, 100 )
		//ply:SetDSP( 7 )
	end

	if idx == MUSIC_DEATHOFF then
		if ply.Music then
			ply.Music:ChangeVolume( 1, 0 )
		end
		if ply.DeathMusic then
			ply.DeathMusic:FadeOut( 0.5 )
		end
		//ply:SetDSP( 1 )
	end
end
usermessage.Hook( "ZMPlayMusic", function( um )
	local idx 		= um:ReadChar() //Music index
	local win		= um:ReadBool() //Win or lose
	PlayMusic( idx, win )
end )
