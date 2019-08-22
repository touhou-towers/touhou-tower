
GMode.Name = "Ball Race"
GMode.Gamemode = "ballrace"

//Set true if players should be kicked if their "goserver" value on the database is not the same as the local server
GMode.Private = true

//This is amount of time between the players being server to play
//And the players be able to join the game
GMode.WaitingTime = 15.0

//This setting is for large group join
//When you want all people to connect at once, the server must be empty to people be able to join.
//Set this to false if you want people to be able to go in and out of the server at any time.
//Set also the min amount of players to join the sevrer
GMode.OneTimeJoin = true
GMode.MinPlayers = 2

//Set this if only a group can join
GMode.GroupJoin = false

GMode.MaxPlayers = 8 //Leave nil if the maxplayers are suppost to be the server maxplayers
GMode.Gameplay = "Physics-based Rolling"

GMode.View = {
	pos = Vector( 9619, 11281, 6754 ),
	ang = Angle( 5.3, 157.5, 0 )
}
GMode.Tips = {
	"Falling will result in popping, which is altogether unpleasant.",
	"Radioactive waste is hazardous to your health.",
	"Watch for falling hazards.",
	"Collect the most bananas to get the most GMC.",
	"In Memories, be weary of the Repellers and Attractors, they can be quite dangerous!",
	"New to Ball Race? Play Skyworld first."
}
GMode.Music = {
	"GModTower/balls/BallsMusicWGrass.mp3",
	"GModTower/balls/BallsMusicWKhromidro.mp3",
	"GModTower/balls/BallsMusicWMemories.mp3",
	"GModTower/balls/BallsMusicWParadise.mp3",
	"GModTower/balls/BallsMusicWSky.mp3",
}

GMode.Maps = { "gmt_ballracer_grassworld01", "gmt_ballracer_iceworld03", "gmt_ballracer_paradise03", "gmt_ballracer_khromidro02", "gmt_ballracer_sandworld02", "gmt_ballracer_skyworld01", "gmt_ballracer_midorib5", "gmt_ballracer_nightball", "gmt_ballracer_metalworld",
/*"gmt_ballracer_summit",*/ "gmt_ballracer_waterworld02", "gmt_ballracer_rainbowworld",
"gmt_ballracer_spaceworld", /*"gmt_ballracer_miracle",*/ /*"gmt_ballracer_prism03",*/ "gmt_ballracer_memories04", "gmt_ballracer_facile", "gmt_ballracer_tranquil", "gmt_ballracer_flyinhigh01", "gmt_ballracer_neonlights" }
GMode.MapsNames = {
	["gmt_ballracer_grassworld01"] = "Grass World",
	["gmt_ballracer_iceworld03"] = "Ice World",
	["gmt_ballracer_paradise03"] = "Paradise",
	["gmt_ballracer_khromidro02"] = "Khromidro",
	["gmt_ballracer_sandworld02"] = "Sand World",
	["gmt_ballracer_skyworld01"] = "Sky World",
	["gmt_ballracer_midorib5"] = "Midori",
	["gmt_ballracer_nightball"] = "Night World",
	["gmt_ballracer_metalworld"] = "Metal World",
	--["gmt_ballracer_summit"] = "Summit",
	["gmt_ballracer_waterworld02"] = "Water World",
	["gmt_ballracer_spaceworld"] = "Space World",
	--["gmt_ballracer_prism03"] = "Prism",
	["gmt_ballracer_memories04"] = "Memories",
	["gmt_ballracer_facile"] = "Facile",
	["gmt_ballracer_tranquil"] = "Tranquil",
	["gmt_ballracer_flyinhigh01"] = "Flyin' High",
	["gmt_ballracer_neonlights"] = "Neon Lights",
	["gmt_ballracer_rainbowworld"] = "Rainbow World",
	--["gmt_ballracer_miracle"] = "Miracle",
	//["xc_sky"] = "Sky World",
	//["xc_grass"] = "Grass World"
}

function GMode:GetMapTexture( map )

	if map == "gmt_ballracer_nightball" or map == "gmt_ballracer_rainbowworld" or map == "gmt_ballracer_rainbowworld" or map == "gmt_ballracer_neonlights" or map == "gmt_ballracer_metalworld" or map == "gmt_ballracer_summit" or map == "gmt_ballracer_tranquil" or map == "gmt_ballracer_facile" or map == "gmt_ballracer_waterworld" or map == "gmt_ballracer_spaceworld" then
		map = map
	else
		map = string.sub(map,0,#map-2)
	end

	return "gmod_tower/maps/" .. map

end

function GMode:GetMapName( map )
	return self.MapsNames[ map ]
end

local bonustext = "BONUS ROUND!"

function GMode:ProcessData( ent, data )

	if #data == 0 then
		ent.NoData = true
		return
	end

	ent.NoData = false

	if data == "#nogame" then
		ent.NoGameMarkup = markup.Parse( T( "GamemodeNoGame" ) )
		ent.NoGameMarkup.PosX = ent.TotalMinX + ent.TotalWidth * 0.5 - ent.NoGameMarkup:GetWidth() / 2
		ent.NoGameMarkup.PosY = ent.TotalMinY + ent.TopHeight * 0.75 - ent.NoGameMarkup:GetHeight() / 2
		return
	else
		ent.NoGameMarkup = nil
	end

	local RoundStatus = string.Explode("/", data )
	local cur, max = tonumber(RoundStatus[1]), tonumber(RoundStatus[2])

	ent.InBonusRound = (cur < 0)

	local frac = (math.abs(cur) / max)

	ent.ProgressX = ent.TotalMinX + ent.TotalWidth * 0.05
	ent.ProgressY = ent.TotalMinY + ent.TopHeight * 0.65

	local tr = (ent.TotalMinX + ent.TotalWidth * 0.45)

	local tw = (tr - ent.ProgressX)

	ent.ProgressWidth = tw * frac
	ent.CompleteWidth = tw

	ent.ProgressHeight = 30

	local text = "<font=GTowerbig><color=ltgrey>Round:</color> " .. string.format("%d / %d", math.abs(cur), max) .. "</font>"
	ent.ProgressText = markup.Parse(text)

	ent.ProgressText.PosX = ent.ProgressX + ( tw / 2 ) - ( ent.ProgressText:GetWidth() / 2 )
	ent.ProgressText.PosY = ent.ProgressY + ( ent.ProgressHeight / 2 ) - ( ent.ProgressText:GetHeight() / 2 )

	surface.SetFont("GTowerbig")
	local w, h = surface.GetTextSize(bonustext)

	ent.BonusX = ent.TotalMinX + ent.TotalWidth * 0.75 - (w/2)
	ent.BonusY = ent.TotalMinY + ent.TopHeight * 0.78 - (h/2)

end

local color_red = Color(200, 0, 0, 100)
local color_black = Color(0, 0, 0, 150)
local color_redbonus = Color(220, 0, 0, 255)

GMode.DrawData = function( ent )

	if ent.NoData then
		return
	end

	if ent.NoGameMarkup then
		ent.NoGameMarkup:Draw( ent.NoGameMarkup.PosX, ent.NoGameMarkup.PosY )
		return
	end

	surface.SetDrawColor(color_red)
	surface.DrawRect(ent.ProgressX, ent.ProgressY, ent.ProgressWidth, ent.ProgressHeight)
	surface.SetDrawColor(color_black)
	surface.DrawOutlinedRect(ent.ProgressX, ent.ProgressY, ent.CompleteWidth, ent.ProgressHeight)

	if ent.ProgressText then
		ent.ProgressText:Draw( ent.ProgressText.PosX, ent.ProgressText.PosY )
	end

	if ent.InBonusRound then
		surface.SetTextColor(color_redbonus)
		surface.SetTextPos(ent.BonusX, ent.BonusY)
		surface.SetFont("GTowerbig")
		surface.DrawText(bonustext)
	end

end
