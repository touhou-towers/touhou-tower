

-----------------------------------------------------
module( "music", package.seeall )

EVENT_PLAY = 1
EVENT_STOP = 2
EVENT_STOPALL = 3
EVENT_VOLUME = 4

DefaultVolume = 1
DefaultFadeTime = 1
DefaultFolder = "GModTower"

Songs = {}

function Register( id, file, data, map )

	// Is this song only for a certain map? If so, don't register it.
	--if map and not Maps.IsMap( map ) then return end

	if not data then data = {} end
	if not id then return end

	// Gather data
	data.ID = id // Unique ID of the song

	if string.StartWith(file,"pikauch") || string.StartWith(file,"rainbow") then data.File = file else // Fix for Neon Lights
		data.File = DefaultFolder .. "/" .. file // File of the song
	end

	data.Volume = data.Volume or DefaultVolume // Volume of the song
	data.Pitch = data.Pitch or 100 // Pitch of the song

	// For looping music tracks
	data.Loops = data.Loops or false // Does this song loop?
	data.Length = data.Length or 30 // Length of the song (for looping)

	// For randomized music tracks
	data.Num = data.Num or 1 // How many tracks are there to randomly select
	data.Ext = data.Ext or ".mp3" // What file extension to append. This is for randomized sound data

	// For sound clips
	data.Oneoff = data.Oneoff or false // Is this just a sound clip, i.e don't fade out existing tracks

	// For misc
	data.Append = data.Append or nil // This ia function that returns something to append to the song file

	// Insert into the system
	Songs[id] = data

end

function Get( id )
	return Songs[id]
end

// Example Usage:

// MUSIC_WAITING = 1
// music.Register( MUSIC_WAITING, "GModTower/minigolf/music/waiting", { Num = 7 } )
// ...
//
// if GAMEMODE:GetState() == STATE_WAITING then
// 		music.Play( MUSIC_WAITING )
// end
