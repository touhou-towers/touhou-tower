
GMode.Name = "Ultimate Chimera Hunt"
GMode.Gamemode = "ultimatechimerahunt"
//Set true if players should be kicked if their "goserver" value on the database is not the same as the local server
GMode.Private = true
//Set true if this is only played by VIPs
GMode.VIP = false
//This is amount of time between the players being server to play
//And the players be able to join the game
GMode.WaitingTime = 20.0
//This setting is for large group join
//When you want all people to connect at once, the server must be empty to people be able to join.
//Set this to false if you want people to be able to go in and out of the server at any time.
//Set also the min amount of players to join the sevrer
GMode.OneTimeJoin = true
GMode.MinPlayers = 5
//Set this if only a group can join
GMode.GroupJoin = false
GMode.MaxPlayers = 12 //Leave nil if the maxplayers are suppost to be the server maxplayers
GMode.Gameplay = "Mother 3"
function Pluralize( str, num )

	if num > 1 then
		str = str .. "s"
	end

	return str

end

function NiceTimeShort( seconds, format )

	seconds = tonumber( seconds )

	local minsLeft = math.floor( seconds / 60 )
	local secsLeft = math.floor( seconds % 60 )

	local str = ""

	// Min
	str = str .. minsLeft

	if format then str = str .. "<color=ltgrey>" end
	str = str .. " " .. Pluralize( "min", minsLeft )
	if format then str = str .. "</color>" end

	// Space
	str = str .. " "

	// Secs
	str = str .. secsLeft

	if format then str = str .. "<color=ltgrey>" end
	str = str .. " " .. Pluralize( "sec", secsLeft )
	if format then str = str .. "</color>" end

	return str

end
GMode.Maps = { "gmt_uch_tazmily01", "gmt_uch_snowedin01","gmt_uch_clubtitiboo04", "gmt_uch_shadyoaks03", "gmt_uch_laboratory01", "gmt_uch_camping01", "gmt_uch_downtown04", "gmt_uch_headquarters02","gmt_uch_falloff01","gmt_uch_mrsaturnvalley02","gmt_uch_woodland03" }
GMode.MapsNames = {
	[ "gmt_uch_tazmily01" ] = "Tazmily Village",
	[ "gmt_uch_snowedin01" ] = "Snowed In",
	[ "gmt_uch_clubtitiboo04" ] = "Club Titiboo",
	[ "gmt_uch_shadyoaks03" ] = "Shady Oaks",
	[ "gmt_uch_laboratory01" ] = "Laboratory",
	[ "gmt_uch_camping01" ] = "Camping Grounds",
	[ "gmt_uch_downtown04" ] = "Downtown",
	[ "gmt_uch_headquarters02" ] = "Headquarters",
	[ "gmt_uch_falloff01" ] = "Falloff",
	[ "gmt_uch_mrsaturnvalley02" ] = "Mr. Saturn Valley",
	[ "gmt_uch_woodland03" ] = "Woodlands",
}
GMode.View = {
	pos = Vector( 9643, 11854, 6734 ),
	ang = Angle( -4.8, 156, 0 )
}

function GMode:GetMapTexture( map )
	map = string.sub(map,0,#map-2)
	return "gmod_tower/maps/" .. map
end

function GMode:GetMapName( map )
	return self.MapsNames[ map ]
end
GMode.Music = {
	"UCH/music/waiting/waiting_music1.mp3",
	"UCH/music/waiting/waiting_music2.mp3",
	"UCH/music/waiting/waiting_music3.mp3",
	"UCH/music/waiting/waiting_music4.mp3",
	"UCH/music/waiting/waiting_music5.mp3",
	"UCH/music/waiting/waiting_music6.mp3",
	"UCH/music/waiting/waiting_music7.mp3",
	"UCH/music/waiting/waiting_music8.mp3",
	"UCH/music/waiting/waiting_music9.mp3",
	"UCH/music/waiting/waiting_music10.mp3",
	"UCH/music/waiting/waiting_music11.mp3",
	"UCH/music/waiting/waiting_music12.mp3",
	"UCH/music/waiting/waiting_music13.mp3",
	"UCH/music/waiting/waiting_music14.mp3",
	"UCH/music/waiting/waiting_music15.mp3",
	"UCH/music/waiting/waiting_music16.mp3",
	"UCH/music/waiting/waiting_music17.mp3",
}
GMode.Tips = {
	"Press the button or throw Mr. Saturn at the Ultimate Chimera to disable it.",
	"You get more GMC based on your Pigmask rank.",
	"You can dash foward for only so long as a Pigmask, use it sparingly!",
	"Mr. Saturn gets scared easily.",
	"Right click to taunt as a Pigmask. Try not to get eaten during it.",
	"Chimeras can press R to wag their tails and swat away Pigmasks.",
	"Right click to roar as a Chimera and scare off the Pigmasks.",
	"Falling off of cliffs will result in a dazed and confused Ultimate Chimera.",
	"Falling off of cliffs as a Pigmask results in death."
}
function GMode:ProcessData( ent, data )

	ent.NoData = ( #data == 0 )
	if ent.NoData then return end
	// No game
	if data == "#nogame" then
		ent.NoGameMarkup = markup.Parse( T( "GamemodePanelNoGame" ) )
		ent.NoGameMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.5 - ent.NoGameMarkup:GetWidth() / 2
		ent.NoGameMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.75 - ent.NoGameMarkup:GetHeight() / 2
		return
	end
	ent.NoGameMarkup = nil
	local leftTitle = "TIME LEFT"
	local rightTitle = "ROUND"
	// Game running, now parse
	local Exploded = string.Explode( "||||", data )
	// Time
	local Timeleft = tonumber( Exploded[1] )
	local leftString = NiceTimeShort( Timeleft, true )
	// Rounds
	local roundExploded = string.Explode( "/", Exploded[2] )
	local CurRound = roundExploded[1]
	local MaxRounds = roundExploded[2]
	local rightString = string.format( "%d <color=ltgrey>/</color> %d", CurRound, MaxRounds )
	// Parse and set position
	ent.LeftTitle = markup.Parse( "<font=GTowerGMTitle><color=grey>" .. leftTitle .. "</color></font>" )
	ent.LeftMarkup = markup.Parse( "<font=GTowerHUDMainLarge>" .. leftString .. "</font>" )
	ent.LeftTitle.PosX = ent.TotalMinX + ent.TotalWidth * 0.15 - ent.LeftTitle:GetWidth() / 2
	ent.LeftTitle.PosY = ent.TotalMinY + ent.TopHeight * 0.60 - ent.LeftTitle:GetHeight() / 2

	ent.LeftMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.15 - ent.LeftMarkup:GetWidth() / 2
	ent.LeftMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.85 - ent.LeftMarkup:GetHeight() / 2
	ent.RightTitle = markup.Parse( "<font=GTowerGMTitle><color=grey>" .. rightTitle .. "</color></font>" )
	ent.RightMarkup = markup.Parse( "<font=GTowerHUDMainLarge>" .. rightString .. "</font>" )
	ent.RightTitle.PosX = ent.TotalMinX + ent.TotalWidth * 0.85 - ent.RightTitle:GetWidth() / 2
	ent.RightTitle.PosY = ent.TotalMinY + ent.TopHeight * 0.60 - ent.RightTitle:GetHeight() / 2

	ent.RightMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.85 - ent.RightMarkup:GetWidth() / 2
	ent.RightMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.85 - ent.RightMarkup:GetHeight() / 2
end
GMode.DrawData = function( ent )
	if ent.NoData then return end
	if ent.NoGameMarkup then
		ent.NoGameMarkup:Draw( ent.NoGameMarkup.PosX, ent.NoGameMarkup.PosY )
		return
	end
	if ent.LeftMarkup then
		ent.LeftTitle:Draw( ent.LeftTitle.PosX, ent.LeftTitle.PosY )
		ent.LeftMarkup:Draw( ent.LeftMarkup.PosX, ent.LeftMarkup.PosY )
	end
	if ent.RightMarkup then
		ent.RightTitle:Draw( ent.RightTitle.PosX, ent.RightTitle.PosY )
		ent.RightMarkup:Draw( ent.RightMarkup.PosX, ent.RightMarkup.PosY )
	end
end
