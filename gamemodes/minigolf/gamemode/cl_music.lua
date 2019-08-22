Musics = {}
Enabled = true
function FadeOutMusic( songid, time )
	if !Musics then return end
	local song = Musics[songid]
	if song && song:IsPlaying() then
		song:FadeOut( time or 1 )
	end
end
function StopMusic( songid )
	if !Musics then return end
	local song = Musics[songid]
	if song then
		song:Stop()
		Musics[songid] = nil
	end
end
function FadeOutAllMusic()
	if !Musics then return end
	for id, song in pairs( Musics ) do
		FadeOutMusic( id )
	end
end
function StopAllMusic()
	if !Musics then return end
	
	for id, song in pairs( Musics ) do
		StopMusic( id )
	end
end
function NewSong( songid, song, vol )
	local snd = CreateSound( LocalPlayer(), song )
	snd:PlayEx( vol, 100 )
	
	Musics[songid] = snd
	
	return snd
end
function GetRandomSongFromID( idx )
	return GAMEMODE.Music[idx][1] .. math.random( 1, GAMEMODE.Music[idx][2] ) .. ".mp3"
end
function PlayMusicFromID( idx )
	if !Enabled then return end
	idx = idx or MUSIC_WAITING
	if !IsValid( LocalPlayer() ) then  //well this is awkward, lets try again
		timer.Simple( 1, function()
			PlayMusicFromID( idx )
		end )
		return
	end
	if idx == MUSIC_NONE then
		FadeOutAllMusic( 4 )
	end
	
	// Waiting for players
	if idx == MUSIC_WAITING then
		StopAllMusic()
		NewSong( "waiting", GetRandomSongFromID( MUSIC_WAITING ), 80 )
	end
	// Customizing all that color
	if idx == MUSIC_SETTINGS then
		FadeOutMusic( "waiting" )
		NewSong( "settings", GetRandomSongFromID( MUSIC_SETTINGS ), 40 )
	end
	// Between holes
	if idx == MUSIC_INTERMISSION then
		StopAllMusic()
		NewSong( "intermission", GetRandomSongFromID( MUSIC_INTERMISSION ), 80 )
	end
	// End of all holes
	if idx == MUSIC_ENDINGGAME then
		StopAllMusic()
		NewSong( "ending", GetRandomSongFromID( MUSIC_ENDINGGAME ), 80 )
	end
	// At the end when you're finished with the hole
	if idx == MUSIC_ENDGAME then
		StopMusic( "endgame" )
		local music = GAMEMODE.Music[ MUSIC_ENDGAME ][4] // Wow you suck.
		local swing = LocalPlayer():Swing()
		local pardiff = LocalPlayer():GetParDiff( swing )
		// HOLE IN ONE!!
		if swing == 1 then
			music = GAMEMODE.Music[ MUSIC_ENDGAME ][1]
		// Pretty good...
		elseif pardiff <= -1 then
			music = GAMEMODE.Music[ MUSIC_ENDGAME ][2]
		// HOLY SHIT YOU'RE GOOD
		elseif pardiff <= 0 then
			music = GAMEMODE.Music[ MUSIC_ENDGAME ][3]
		end
		
		NewSong( "endgame", music, 80 )
	end
end
function PlaySoundFromID( idx, num )
	if idx == MUSIC_WAITING && num == 0 && GAMEMODE:IsPracticing()  then
		StopAllMusic()
		NewSong( "waiting", GetRandomSongFromID( MUSIC_WAITING ), 80 )
	else
		if idx == SOUNDINDEX_CLAP && num then
			surface.PlaySound( SOUND_CLAP .. num .. ".wav" )
		end
		if idx == SOUNDINDEX_ANNOUNCER then
			surface.PlaySound( SOUNDS_ANNOUNCER[ math.random( 1, #SOUNDS_ANNOUNCER ) ] )
		end
	end
end
usermessage.Hook( "PlayMusic", function( um )
	local idx = um:ReadChar() or 0 //Music index
	PlayMusicFromID( idx )
end )
usermessage.Hook( "PlaySoundEffect", function( um )
	local idx = um:ReadChar() or 0 //Sound index
	local num = um:ReadChar() or 0
	
	PlaySoundFromID( idx, num )
end )