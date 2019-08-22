module( "Scoreboard.Customization", package.seeall )

// COLORS
ColorFont = color_white
ColorFontShadow = Color( 66, 35, 13, 255 )

ColorNormal = Color( 172, 121, 84, 255 )
ColorBright = Color( 228, 166, 121, 255 )
ColorDark = Color( 89, 49, 22, 255 )

ColorBackground = colorutil.Brighten( ColorNormal, 0.75 )

ColorTabActive = colorutil.Brighten( ColorDark, .75, 200 )
ColorTabDivider = ColorBright
ColorTabInnerActive = ColorTabActive
ColorTabHighlight = colorutil.Brighten( ColorBright, 3 )

ColorAwardsDescription = Color( 220, 220, 220, 255 )
ColorAwardsBarAchieved = Color( 174, 126, 91, 150 )
ColorAwardsBarNotAchieved = Color( 90, 60, 38, 150 )
ColorAwardsAchievedIcon = Color( 161, 219, 93, 255 )


// HEADER
HeaderTitle = ""
HeaderMatHeader = Scoreboard.GenTexture( "ScoreboardBRLogo", "ballrace/main_header" )
HeaderMatFiller = Scoreboard.GenTexture( "ScoreboardBRFiller", "ballrace/main_filler" )
HeaderMatRightBorder = Scoreboard.GenTexture( "ScoreboardBRRightBorder", "ballrace/main_rightborder" )

// RANK SYSTEM
local function CalculateRanks()

	if NextCalcRank && NextCalcRank > CurTime() then
		return
	end

	local Players = player.GetAll()

	table.sort( Players, function( a, b )

		local aScore, bScore = a:GetNWInt( "Placement" ), b:GetNWInt( "Placement" )
		return aScore < bScore

	end )

	for k, ply in pairs( Players ) do
		ply.TrophyRank = k
	end

	NextCalcRank = CurTime() + 1

end

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

	local completedtime = ply:GetNWString( "CompletedTime" )
	if completedtime and completedtime != "" then
		return completedtime .. " secs"
	end

	if !ply:Alive() && ply:Team() != TEAM_COMPLETED then
		return "DEAD"
	end

	return ""

end

// Background
PlayerBackgroundMaterial = function( ply )
end

local Trophies =
{
	Scoreboard.PlayerList.MATERIALS.Trophy1,
	Scoreboard.PlayerList.MATERIALS.Trophy2,
	Scoreboard.PlayerList.MATERIALS.Trophy3
}

// Notification (above avatar)
PlayerNotificationIcon = function( ply )

	if ply.TrophyRank && ply:Team() == TEAM_COMPLETED then
		if Trophies[ ply.TrophyRank ] then
			return Trophies[ ply.TrophyRank ]
		end
		return Scoreboard.PlayerList.MATERIALS.Finish
	end

	if ply:Team() == TEAM_COMPLETED then
		return Scoreboard.PlayerList.MATERIALS.Finish
	end

	return nil

end

// Jazz the player avatar? (for winner only)
PlayerAvatarJazz = function( ply )

	--if GetState() != STATE_INTERMISSION then return false end
	--if not game.GetWorld():GetNet( "Passed" ) then return false end

	CalculateRanks()
	return ( ply:GetNWInt("Placement") == 1 )

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
		"BANANAS",
		function( ply )
			return ply:Frags()
		end,
		nil
	)

	Scoreboard.ActionBoxLabel(
		panel,
		nil,
		"LIVES",
		function( ply )
			return ply:Deaths()
		end,
		nil
	)

end )
