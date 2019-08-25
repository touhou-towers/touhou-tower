module("Scoreboard.Customization", package.seeall)

-- COLORS
ColorFont = color_white
ColorFontShadow = Color(25, 49, 8, 255)

ColorNormal = Color(44, 83, 17, 255)
ColorBright = Color(61, 102, 31, 255)
ColorDark = Color(25, 49, 8, 255)

ColorBackground = colorutil.Brighten(ColorNormal, 0.75)

ColorTabActive = colorutil.Brighten(ColorDark, 0.75, 150)
ColorTabDivider = ColorBright
ColorTabInnerActive = ColorTabActive
ColorTabHighlight = colorutil.Brighten(ColorBright, 3)

ColorAwardsDescription = Color(184, 239, 144, 255)
ColorAwardsBarAchieved = Color(61, 102, 31, 150)
ColorAwardsBarNotAchieved = Color(27, 42, 16, 150)
ColorAwardsAchievedIcon = Color(61, 102, 31, 255)

-- HEADER
HeaderTitle = ""
HeaderMatHeader = Scoreboard.GenTexture("ScoreboardMinigolfLogo", "minigolf/main_header")
HeaderMatFiller = Scoreboard.GenTexture("ScoreboardMinigolfFiller", "minigolf/main_filler")
HeaderMatRightBorder = Scoreboard.GenTexture("ScoreboardMinigolfRightBorder", "minigolf/main_rightborder")

-- PLAYER
-- Subtitle (under name)
PlayerSubtitleText = function(ply)
	if (ply:Team() == TEAM_FINISHED and ply:Swing() ~= 0) then
		return ply:GetSwingResult(ply:Swing())
	else
		return nil
	end
end

-- Background
PlayerBackgroundMaterial = function(ply)
	return nil
end

-- Notification (above avatar)
PlayerNotificationIcon = function(ply)
	if (ply:Team() == TEAM_FINISHED and ply:Swing() ~= 0) then
		return Scoreboard.PlayerList.MATERIALS.Finish
	end

	return nil
end

-- Jazz the player avatar? (for winner only)
PlayerAvatarJazz = function(ply)
	return false
end

-- Action Box
PlayerActionBoxEnabled = true
PlayerActionBoxAlwaysShow = true
PlayerActionBoxWidth = 80
PlayerActionBoxRightPadding = 6
PlayerActionBoxBGAlpha = 80

hook.Add(
	"PlayerActionBoxPanel",
	"ActionBoxDefault",
	function(panel)
		Scoreboard.ActionBoxLabel(
			panel,
			nil,
			"STROKE",
			function(ply)
				return ply:Swing()
			end,
			nil
		)
	end
)
