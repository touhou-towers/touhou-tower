module( "Scoreboard.Customization", package.seeall )

// COLORS
ColorFont = color_white
ColorFontShadow = Color( 31, 63, 4, 255 )

ColorNormal = Color( 70, 118, 34, 255 )
ColorBright = Color( 115, 196, 63, 255 )
ColorDark = Color( 44, 80, 15, 255 )

ColorBackground = colorutil.Brighten( ColorNormal, 0.75 )

ColorTabActive = Color( 0, 0, 64, 64 )
ColorTabDivider = ColorBright
ColorTabInnerActive = colorutil.Brighten( ColorDark, .75, 200 )
ColorTabHighlight = colorutil.Brighten( ColorBright, 3 )


ColorAwardsDescription = Color( 220, 220, 220, 255 )
ColorAwardsBarAchieved = Color( 93, 162, 36, 150 )
ColorAwardsBarNotAchieved = Color( 33, 62, 10, 150 )
ColorAwardsAchievedIcon = Color( 32, 255, 4, 150 )


// HEADER
HeaderTitle = ""
HeaderMatHeader = Scoreboard.GenTexture( "ScoreboardVirusLogo", "virus/main_header" )
HeaderMatFiller = Scoreboard.GenTexture( "ScoreboardVirusFiller", "virus/main_filler" )
HeaderMatRightBorder = Scoreboard.GenTexture( "ScoreboardVirusRightBorder", "virus/main_rightborder" )

// RANK SYSTEM
local function CalculateRanks()

	if NextCalcRank && NextCalcRank > CurTime() then
		return
	end

	local Players = player.GetAll()

	/*if GAMEMODE.WinningTeam then

		for k, ply in pairs( Players ) do
			ply.TrophyRank = 0
		end

		Players = team.GetPlayers( GAMEMODE.WinningTeam )

	end*/
	
	table.sort( Players, function( a, b )

		local aScore, bScore = a:Frags(), b:Frags()

		if aScore == bScore then
			return a:Deaths() < b:Deaths()
		end

		return aScore > bScore

	end )

	for k, ply in pairs( Players ) do
		ply.TrophyRank = k
	end

	NextCalcRank = CurTime() + 1

end

local Trophies = 
{
	Scoreboard.PlayerList.MATERIALS.Trophy1, 
	Scoreboard.PlayerList.MATERIALS.Trophy2,
	Scoreboard.PlayerList.MATERIALS.Trophy3
}

// PLAYER

PlayersSort = function( a, b )

	CalculateRanks()

	if !a.TrophyRank || !b.TrophyRank then
		return
	end

	return a.TrophyRank < b.TrophyRank

end

// Subtitle (under name)
PlayerSubtitleText = function( ply )

	if GAMEMODE:GetState() == STATUS_WAITING then return "" end

	if ply.IsVirus then
		return "INFECTED"
	end

	if ply:Alive() then
		return "SURVIVOR"
	end

	if !ply:Alive() then
		return "DEAD"
	end

	return ""

end

// Background
local infectedbg = Scoreboard.GenTexture( "VirusInfectedBG", "virus/infected" )
PlayerBackgroundMaterial = function( ply )

	if ply.IsVirus then
		return infectedbg
	end

	return nil

end

// Notification (above avatar)
PlayerNotificationIcon = function( ply )

	if ( GAMEMODE:IsPlaying() || GAMEMODE:GetState() == STATUS_INTERMISSION ) && ply:Frags() > 0 then

		CalculateRanks()

		if ply.TrophyRank then
			return Trophies[ ply.TrophyRank ]
		end

	end

	return nil

end

// Jazz the player avatar? (for winner only)
PlayerAvatarJazz = function( ply )

	if GAMEMODE:GetState() != STATUS_INTERMISSION then return false end

	CalculateRanks()

	return ( ply.TrophyRank == 1 )

end

// Action Box
PlayerActionBoxEnabled = true
PlayerActionBoxAlwaysShow = true
PlayerActionBoxWidth = 80
PlayerActionBoxRightPadding = 6
PlayerActionBoxBGAlpha = 80

hook.Add( "PlayerActionBoxPanel", "ActionBoxDefault", function( panel )

	Scoreboard.ActionBoxLabel(
		panel, 
		nil, 
		"KILLS", 
		function( ply )
			return ply:Frags()
		end, 
		nil
	)

	Scoreboard.ActionBoxLabel( 
		panel, 
		nil, 
		"DEATHS", 
		function( ply )
			return ply:Deaths()
		end, 
		nil
	)

end )