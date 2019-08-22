module( "Scoreboard.Customization", package.seeall )

// COLORS
ColorFont = color_white
ColorFontShadow = Color( 164, 16, 81, 255 )

ColorNormal = Color( 148, 19, 76, 255 )
ColorBright = Color( 193, 48, 113, 255 )
ColorDark = Color( 179, 29, 96, 255 )

ColorBackground = colorutil.Brighten( ColorNormal, 0.75 )

ColorTabActive = Color( 0, 0, 64, 64 )
ColorTabDivider = ColorBright
ColorTabInnerActive = colorutil.Brighten( ColorDark, .75, 200 )
ColorTabHighlight = colorutil.Brighten( ColorBright, 3 )

ColorAwardsDescription = Color( 220, 220, 220, 255 )
ColorAwardsBarAchieved = Color( 171, 35, 97, 150 )
ColorAwardsBarNotAchieved = Color( 113, 11, 58, 150 )
ColorAwardsAchievedIcon = Color( 201, 65, 127, 150 )


// HEADER
HeaderTitle = ""
HeaderMatHeader = Scoreboard.GenTexture( "ScoreboardUCHLogo", "uch/main_header" )
HeaderMatFiller = Scoreboard.GenTexture( "ScoreboardUCHFiller", "uch/main_filler" )
HeaderMatRightBorder = Scoreboard.GenTexture( "ScoreboardUCHRightBorder", "uch/main_rightborder" )



// PLAYER

// Subtitle (under name)
PlayerSubtitleText = function( ply )

	if ply.IsGhost then

		if ply.IsFancy then
			return "FANCY GHOSTIE"
		end

		return "GHOSTIE"
	end

	if ply:Alive() && ply.GetRankName then
		return string.upper( ply:GetRankName() )
	end

	return ""

end

// Background
local backgrounds = {
	["ghost"] = Scoreboard.GenTexture( "UCHGhostBG", "uch/ghost" ),
	["ghostfancy"] = Scoreboard.GenTexture( "UCHGhostFancyBG", "uch/ghostfancy" ),
	["pigmask"] = Scoreboard.GenTexture( "UCHPigmaskBG", "uch/pigmask" ),
	["uch"] = Scoreboard.GenTexture( "UCHChimeraBG", "uch/uch" ),
}

PlayerBackgroundMaterial = function( ply )

	if ply.IsGhost then

		if ply.IsFancy then
			return backgrounds["ghostfancy"]
		end

		return backgrounds["ghost"]

	end

	if ply.IsChimera then
		return backgrounds["uch"]
	end

	if ply:Team() == TEAM_PIGS then
		return backgrounds["pigmask"]
	end

	return nil

end

// Notification (above avatar)
local ranks = {
	["captain"]			= "UCH/ranks/captain",
	["colonel"]			= "UCH/ranks/colonel",
	["ensign"]			= "UCH/ranks/ensign",
	["major"]			= "UCH/ranks/major",
	["captain_dead"]	= "UCH/ranks/captain_dead",
	["colonel_dead"]	= "UCH/ranks/colonel_dead",
	["ensign_dead"]		= "UCH/ranks/ensign_dead",
	["major_dead"]		= "UCH/ranks/major_dead",
}

PlayerNotificationIcon = function( ply )

	if ply.IsChimera then return nil end

	local rank = ""

	if ply.GetRankName then
		rank = string.lower( ply:GetRankName() )
	end

	if !rank then return nil end

	if ( ply.IsGhost ) || ply.Bit || ply.IsPancake || ply.IsDead || ply:Team() == TEAM_GHOST then
		rank = rank .. "_dead"
	end

	if !ranks[rank] then
		return nil
	end

	return ranks[rank]

end
PlayerNotificationIconSize = 32

// Jazz the player avatar? (for winner only)
PlayerAvatarJazz = function( ply )
	return false
end

// Action Box
PlayerActionBoxEnabled = false