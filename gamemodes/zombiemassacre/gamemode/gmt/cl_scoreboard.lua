
-----------------------------------------------------
module( "Scoreboard.Customization", package.seeall )

EnableMouse = false

// COLORS
ColorFont = color_white
ColorFontShadow = Color( 128, 6, 6, 255 )

ColorNormal = Color( 111, 14, 8, 255 )
ColorBright = Color( 152, 15, 7, 255 )
ColorDark = Color( 75, 9, 4, 255 )

ColorBackground = colorutil.Brighten( ColorNormal, 0.75 )

ColorTabActive = colorutil.Brighten( ColorDark, .75, 200 )
ColorTabDivider = ColorBright
ColorTabInnerActive = ColorTabActive
ColorTabHighlight = colorutil.Brighten( ColorBright, 3 )

ColorAwardsDescription = Color( 220, 220, 220, 255 )
ColorAwardsBarAchieved = Color( 116, 0, 0, 150 )
ColorAwardsBarNotAchieved = Color( 54, 3, 3, 150 )
ColorAwardsAchievedIcon = Color( 150, 6, 150, 255 )


// HEADER
HeaderTitle = ""
HeaderMatHeader = Scoreboard.GenTexture( "ScoreboardZMLogo", "zombiemassacre/main_header" )
HeaderMatFiller = Scoreboard.GenTexture( "ScoreboardZMFiller", "zombiemassacre/main_filler" )
HeaderMatRightBorder = Scoreboard.GenTexture( "ScoreboardZMRightBorder", "zombiemassacre/main_rightborder" )

// RANK SYSTEM
local function CalculateRanks()

	if NextCalcRank && NextCalcRank > CurTime() then
		return
	end

	local Players = player.GetAll()
	
	table.sort( Players, function( a, b )

		local aScore, bScore = a:GetNWInt( "Points" ), b:GetNWInt( "Points" )
		
		if aScore == bScore then
			return a:Frags() > b:Frags()
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

	local class = ply:GetNWString( "ClassName" )

	if !class then return "" end

	if !ply:Alive() then
		return "DEAD " .. class
	end

	return string.upper( class )

end

// Background
PlayerBackgroundMaterial = function( ply )
end

// Notification (above avatar)
PlayerNotificationIcon = function( ply )

	if ply:Frags() > 0 then

		CalculateRanks()

		if ply.TrophyRank then
			return Trophies[ ply.TrophyRank ]
		end

	end

	return nil

end

// Jazz the player avatar? (for winner only)
PlayerAvatarJazz = function( ply )

	if !GAMEMODE:IsRoundOver() then return false end

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
		"POINTS", 
		function( ply )
			return ply:GetNWInt( "Points" )
		end, 
		nil
	)

	Scoreboard.ActionBoxLabel(
		panel, 
		nil, 
		"KILLS", 
		function( ply )
			return ply:Frags() / 8
		end, 
		nil
	)

end )