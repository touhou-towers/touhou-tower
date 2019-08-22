

-----------------------------------------------------

include("sh_init.lua")

module( "music", package.seeall )

SongData = {}

ClientVolume = CreateClientConVar( "gmt_volume_music", 100, true, false )

net.Receive( "MusicEvent", function( length, ply )

	local message = net.ReadInt( 4 )
	-- PLAY
	if message == EVENT_PLAY then

		local song = net.ReadInt( 8 )
		--local rnd = net.ReadInt( 8 )
		PlaySong( song )

	end

	-- STOP
	if message == EVENT_STOP then

		local song = net.ReadInt( 8 )
		local songdata = Get( song )

		local fade = numtobool( net.ReadInt(1) )
		local fadetime = net.ReadInt(8)

		StopSong( songdata, fade, fadetime )

	end

	-- STOP ALL
	if message == EVENT_STOPALL then

		local fade = net.ReadBool()
		local fadetime = net.ReadInt(8)

		StopAllSongs( fade, fadetime )

	end

	-- CHANGE VOLUME
	if message == EVENT_VOLUME then

		local volume = net.ReadFloat()
		SetSongVolume( volume )

	end

end )

hook.Add( "Think", "MusicLoopThink", function()

	HandleClientVolume()

	for _, songdata in pairs( SongData ) do

		if songdata.Sound and songdata.Loops then
			local time = RealTime() - songdata.StartedPlaying

			if time >= songdata.Length then
				RepeatSong( songdata )
			end
		end

	end

end )

function GetClientVolume()
	return ClientVolume:GetInt() / 100
end

function HandleClientVolume()

	if !LastClientVolume then
		LastClientVolume = GetClientVolume()
	end
	if LastClientVolume != GetClientVolume() then
		LastClientVolume = GetClientVolume()
		ClientVolumeChanged()
	end

end

function ClientVolumeChanged()

	for id, songdata in pairs( SongData ) do

		if songdata.Sound and songdata.Sound:IsPlaying() then
			songdata.Sound:ChangeVolume( GetClientVolume() * songdata.Volume, 0 )
		end

	end

end

function PlaySong( song, rnd )

	local songdata = Get( song )
	local filename = songdata.File

	-- Get append
	if songdata.Append then
		filename = filename .. songdata.Append()
	end

	-- Get randomized song file
	if songdata.Num > 1 then
		filename = filename .. math.random(1,songdata.Num)
	end

	-- Add extension
	filename = filename .. songdata.Ext

	if songdata.Oneoff then
		surface.PlaySound( filename )
		return
	end

	PlayNewSong( songdata, filename )

end

function PlayNewSong( songdata, filename )

	for id, data in pairs( SongData ) do

		if (songdata == data and songdata.Sound and songdata.Sound:IsPlaying()) then
			return
		end

	end

	-- Stop existing songs
	StopAllSongs( true )

	timer.Simple( .1, function()
		songdata.Sound = CreateSound( LocalPlayer(), filename or songdata.File )
		songdata.Sound:PlayEx( GetClientVolume() * songdata.Volume, songdata.Pitch )

		songdata.StartedPlaying = RealTime()
	end )

	-- Add to manager
	table.insert( SongData, songdata )

end

function StopSong( songdata, fade, fadetime )

	if songdata.Sound and songdata.Sound:IsPlaying() then

		-- Double check if the song already ended (IsPlaying sucks)
		local time = RealTime() - songdata.StartedPlaying
		if songdata.Length > time then
			songdata.Sound:Stop()
		else

			-- Song is playing, let's stop it
			if fade and GetClientVolume() > 0 then
				songdata.Sound:FadeOut( fadetime or DefaultFadeTime )
			else
				songdata.Sound:Stop()
			end

		end

	end

	songdata.StartedPlaying = nil
	songdata.Sound = nil

	-- Remove from manager
	table.remove( SongData, table.KeyFromValue( SongData, songdata ) )

end

function RepeatSong( songdata )

	if GetClientVolume() == 0 then return end -- No need.

	songdata.StartedPlaying = RealTime()

	songdata.Sound:Stop()
	songdata.Sound:PlayEx( GetClientVolume() * songdata.Volume, songdata.Pitch )

end

function StopAllSongs( fade, fadetime )

	for id, songdata in pairs( SongData ) do

		StopSong( songdata, fade, fadetime )
		table.remove( SongData, id )

	end

end

function SetSongVolume( volume )

	for id, songdata in pairs( SongData ) do

		if songdata.Sound and songdata.Sound:IsPlaying() then
			songdata.Sound:ChangeVolume( volume, 0 )
		end

	end

end
