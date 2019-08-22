
GMode.Name = "Gourmet Race"
GMode.Gamemode = "gourmetrace"

//Set true if players should be kicked if their "goserver" value on the database is not the same as the local server
GMode.Private = true

//Set true if this is only played by VIPs
GMode.VIP = false

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

GMode.MaxPlayers = 10 //Leave nil if the maxplayers are suppost to be the server maxplayers
GMode.Gameplay = ""

GMode.Maps = {"gmt_gr_nile","gmt_gr_ruins"}
GMode.MapsNames = {
	["gmt_gr_nile"] = "Nile",
	["gmt_gr_ruins"] = "Ruins",
}
GMode.View = {
	pos = Vector( 10237, 12240, 6745 ),
	ang = Angle( -7, 90, 0 )
}

GMode.Tips = {
	"Collect as many food as you can for the highest amount of GMC!",
	"Keep an eye out for invincibility candies, they will help you out a lot!",
	"Some maps have secret passage ways, can you find them all?",
	"Hit people with your hammer to slow them down!",
}

GMode.Music = {
	"gmodtower/gourmetrace/music/round/round1.mp3",
	"gmodtower/gourmetrace/music/round/round3.mp3",
	"gmodtower/gourmetrace/music/round/round8.mp3",
	"gmodtower/gourmetrace/music/waiting/waiting1.mp3",
}

function GMode:GetMapTexture( map )

	if map == "gmt_gr_ruins" or map == "gmt_gr_nile" then
		map = map
	else
		map = string.sub(map,0,#map-2)
	end

	return "gmod_tower/maps/" .. map

end

function GMode:GetMapName( map )
	return self.MapsNames[ map ]
end

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

end
