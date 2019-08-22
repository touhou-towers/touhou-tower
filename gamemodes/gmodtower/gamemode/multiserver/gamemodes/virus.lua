
GMode.Name = "Virus"
GMode.Gamemode = "virus"

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
GMode.Gameplay = "FPS"

local function Pluralize( word, count )

	if ( count > 1 ) then
		return word .. "s"
	end

	return word

end

local function NiceTimeShort( seconds, format )

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

GMode.Maps = { "gmt_virus_facility202", "gmt_virus_riposte01", "gmt_virus_aztec01", "gmt_virus_sewage01", "gmt_virus_dust03", "gmt_virus_metaldream05", "gmt_virus_hospital204", "gmt_virus_derelict01", "gmt_virus_parkinglot"}
GMode.View = {
	pos = Vector( 11514.360352, 11507.714844, 6751.542480 ),
	ang = Angle( -5.251342, -25.747440, 0.000000 )
}
GMode.MapsNames = {
	["gmt_virus_facility202"] = "Facility 2",
	["gmt_virus_riposte01"] = "Riposte",
	["gmt_virus_aztec01"] = "Aztec",
	["gmt_virus_sewage01"] = "Sewage",
	["gmt_virus_dust03"] = "Dust",
	["gmt_virus_metaldream05"] = "Metal Dreams",
	["gmt_virus_hospital204"] = "Hospital",
	["gmt_virus_derelict01"] = "Derelict Station",
	["gmt_virus_parkinglot"] = "Parking Lot",
}

function GMode:GetMapTexture( map )
	if map == "gmt_virus_parkinglot" then
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
	"Press C to quickly use your adrenaline.",
	"The infected are not looking for a hug, no matter what they say.",
	"You always have two different pistols.",
	"Try not to stand in the same place as the other survivors.",
	"The Dual Silencers fire with left click and right click."
}

GMode.Music = {
	"GModTower/virus/waiting_forplayers1.mp3",
	"GModTower/virus/waiting_forplayers2.mp3",
	"GModTower/virus/waiting_forplayers3.mp3",
	"GModTower/virus/waiting_forplayers4.mp3",
	"GModTower/virus/waiting_forplayers5.mp3",
	"GModTower/virus/waiting_forplayers6.mp3",
	"GModTower/virus/waiting_forplayers7.mp3",
	"GModTower/virus/waiting_forplayers8.mp3",
}


function GMode:ProcessData( ent, data )

	//data = "87||||1/10" // Testing!

	// Check for no data
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
	if Timeleft == 0 then leftString = "Infecting..." end

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
