
GMode.Name = "Source Karts"
GMode.Gamemode = "sourcekarts"
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
GMode.MinPlayers = 2
//Set this if only a group can join
GMode.GroupJoin = false
GMode.MaxPlayers = 6 //Leave nil if the maxplayers are suppost to be the server maxplayers
GMode.Gameplay = "Kart Racing"
GMode.Maps = {"gmt_sk_lifelessraceway01", "gmt_sk_island01_fix", "gmt_sk_rave"}
GMode.MapsNames = {
	["gmt_sk_lifelessraceway01"] = "Lifeless Raceway",
	["gmt_sk_island01_fix"] = "Drift Island",
	["gmt_sk_rave"] = "Rave"
}
GMode.View = {
	pos = Vector( 9646, 9364, 6712 ),
	ang = Angle( -0.75, -156, 0 )
}

function GMode:GetMapTexture( map )

	if map == "gmt_sk_island01_fix" then
		map = "gmt_sk_island"
	elseif map == "gmt_sk_rave" || map == "gmt_sk_forest" then
		map = map
	else
		map = string.sub(map,0,#map-2)
	end

	return "gmod_tower/maps/" .. map

end

function GMode:GetMapName( map )
	return self.MapsNames[ map ]
end

GMode.Tips = {
	"Press space and turn to drift.",
	"Hold mouse right to look and throw items backwards.",
	"Disco makes you fast and invincible.",
	"Accelerate right when 'GO' is displayed for a starting boost.",
	"If you find yourself stuck or in a bad spot, press R to reset your kart.",
}
GMode.Music = {
	"GModTower/sourcekarts/music/island_race1.mp3",
	"GModTower/sourcekarts/music/island_race2.mp3",
	"GModTower/sourcekarts/music/island_race3.mp3",
	"GModTower/sourcekarts/music/raceway_race1.mp3",
	"GModTower/sourcekarts/music/raceway_race2.mp3",
	"GModTower/sourcekarts/music/raceway_race3.mp3",
}
function GMode:ProcessData( ent, data )
	// Check for no data
	ent.NoData = ( #data == 0 )
	if ent.NoData then return end
	// No game
	if data == "#nogame" then
		ent.NoGameMarkup = markup.Parse( T( "GamemodePanelNoGame" ) )
		ent.NoGameMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.5 - ent.NoGameMarkup:GetWidth() / 2
		ent.NoGameMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.75 - ent.NoGameMarkup:GetHeight() / 2
		return
	else
		ent.NoGameMarkup = nil
	end
	local Exploded = string.Explode( "||||", data )
	
	// Lap
	local LapString = Exploded[1]
	local lapExploded = string.Explode( "/", Exploded[ 2 ] )
	local CurLap = lapExploded[ 1 ]
	local MaxLaps = lapExploded[ 2 ]
	local Laps = string.format( "%d <color=ltgrey>/</color> %d", CurLap, MaxLaps )
	// Max Laps
	local roundExploded = string.Explode( "/", Exploded[ 2 ] )
	local CurRound = roundExploded[ 1 ]
	local MaxRounds = roundExploded[ 2 ]
	local Rounds = string.format( "%d <color=ltgrey>/</color> %d", CurRound, MaxRounds )
	// Parse and set position
	ent.TimeLeftTitle = markup.Parse( "<font=GTowerGMTitle><color=grey>LAP</color></font>" )
	ent.TimeLeftMarkup = markup.Parse( "<font=GTowerHUDMainLarge>" .. Laps .. "</font>" )
	ent.TimeLeftTitle.PosX = ent.TotalMinX + ent.TotalWidth * 0.15 - ent.TimeLeftTitle:GetWidth() / 2
	ent.TimeLeftTitle.PosY = ent.TotalMinY + ent.TopHeight * 0.60 - ent.TimeLeftTitle:GetHeight() / 2
	
	ent.TimeLeftMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.15 - ent.TimeLeftMarkup:GetWidth() / 2
	ent.TimeLeftMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.85 - ent.TimeLeftMarkup:GetHeight() / 2
	ent.RoundsTitle = markup.Parse( "<font=GTowerGMTitle><color=grey>TRACK</color></font>" )
	ent.RoundsMarkup = markup.Parse( "<font=GTowerHUDMainLarge>" .. Rounds .. "</font>" )
	ent.RoundsTitle.PosX = ent.TotalMinX + ent.TotalWidth * 0.85 - ent.RoundsTitle:GetWidth() / 2
	ent.RoundsTitle.PosY = ent.TotalMinY + ent.TopHeight * 0.60 - ent.RoundsTitle:GetHeight() / 2
	
	ent.RoundsMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.85 - ent.RoundsMarkup:GetWidth() / 2
	ent.RoundsMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.85 - ent.RoundsMarkup:GetHeight() / 2
end
GMode.DrawData = function( ent )
	if ent.NoData then return end
	if ent.NoGameMarkup then
		ent.NoGameMarkup:Draw( ent.NoGameMarkup.PosX, ent.NoGameMarkup.PosY )
		return
	end
	if ent.TimeLeftMarkup then
		ent.TimeLeftTitle:Draw( ent.TimeLeftTitle.PosX, ent.TimeLeftTitle.PosY )
		ent.TimeLeftMarkup:Draw( ent.TimeLeftMarkup.PosX, ent.TimeLeftMarkup.PosY )
	end

	if ent.RoundsMarkup then
		ent.RoundsTitle:Draw( ent.RoundsTitle.PosX, ent.RoundsTitle.PosY )
		ent.RoundsMarkup:Draw( ent.RoundsMarkup.PosX, ent.RoundsMarkup.PosY )
	end
end
