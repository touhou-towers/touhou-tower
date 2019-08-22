
module( "Scoreboard.Customization", package.seeall )

MatDirectory = "gmod_tower/scoreboard/"
EnableMouse = true
ShowBackgrounds = true

// COLORS
ColorFont = color_white
ColorFontShadow = Color( 6, 76, 127, 255 )

ColorNormal = Color( 34, 100, 156, 255 )
ColorBright = Color( 57, 131, 181, 255 )
ColorDark = Color( 17, 50, 78, 255 )

local ratio = 0.75
local ratioBright = 3

ColorBackground = Color( ColorNormal.r * ratio, ColorNormal.g * ratio, ColorNormal.b * ratio, 255 )

ColorTabActive = Color( 0, 0, 64, 64 )
ColorTabDivider = ColorBright
ColorTabInnerActive = Color( ColorDark.r * ratio, ColorDark.g * ratio, ColorDark.b * ratio, 200 )
ColorTabHighlight = Color( ColorBright.r * ratioBright, ColorBright.g * ratioBright, ColorBright.b * ratioBright, 255 )

ColorAwardsDescription = Color( 162, 203, 233, 255 )
ColorAwardsBarAchieved = Color( 178, 215, 243, 150 )
ColorAwardsBarNotAchieved = Color( 3 * 2, 67 * 2, 114 * 2, 150 )
ColorAwardsAchievedIcon = Color( 32, 255, 4, 150 )


// HEADER
HeaderTitle = "GMod Tower"
HeaderTitleFont = "SCTitle"
HeaderTitleColor = color_white
HeaderTitleLeft = 188
HeaderWidth = 256
HeaderHeight = 64
HeaderMatHeader = Scoreboard.GenTexture( "ScoreboardLogo", "main_header" )
HeaderMatFiller = Scoreboard.GenTexture( "ScoreboardFiller", "main_filler" )
HeaderMatRightBorder = Scoreboard.GenTexture( "ScoreboardRightBorder", "main_rightborder" )


// COLLAPSABLES
CollapsablesFont = "GTowerHUDMain"


// PLAYER

PlayersSort = function( a, b )
	return string.lower( a:Name() ) < string.lower( b:Name() )
end

// Subtitle (under Name)
PlayerSubtitleText = function( ply )
	if string.StartWith(game.GetMap(),"gmt_build") then
		local text = GTowerLocation:GetName( GTowerLocation:GetPlyLocation( ply ) ) or "Unknown"
		return text
	else
		return nil
	end

end

// Subtitle right (under Name)
PlayerSubtitleRightText = function( ply )
	if ply.IsLoading then
		return "LOADING"
	end
	return ""
end

// Background
PlayerBackgroundMaterial = function( ply )
	if game.GetMap() == "gmt_build0s2b" then
	if GTowerLocation:GetPlyLocation( ply ) then
		local location = GTowerLocation:GetPlyLocation( ply )

		for material, ids in pairs( Scoreboard.PlayerList.LOCATIONVALS ) do
			if table.HasValue( ids, location ) then
				return material
			end
		end
	end
	else
		return nil
	end
end

// Notification (above avatar)
PlayerNotificationIcon = function( ply )

	return nil

end
PlayerNotificationIconSize = 24

// Jazz the player avatar? (for winner only)
PlayerAvatarJazz = function( ply )

	return false

end

// Info Value
PlayerInfoValueVisible = function( ply )
	return LocalPlayer() == ply
end

PlayerInfoValueIcon = MatDirectory .. "icon_money.png"
PlayerInfoValueGet = function( ply )
	return string.FormatNumber( Money() or 0 )
end

// Action Box
PlayerActionBoxEnabled = true
PlayerActionBoxAlwaysShow = false


// FONTS
surface.CreateFont( "SCTitle", { font = "TodaySHOP-BoldItalic", size = 64, weight = 400 } )
surface.CreateFont( "SCTNavigation", { font = "Oswald", size = 24, weight = 400 } )

surface.CreateFont( "SCPlyName", { font = "Oswald", size = 32, weight = 400 } )
surface.CreateFont( "SCPlyGroupName", { font = "Oswald", size = 20, weight = 400 } )
surface.CreateFont( "SCPlyGroupLocName", { font = "Oswald", size = 16, weight = 400 } )
surface.CreateFont( "SCPlyValue", { font = "Oswald", size = 24, weight = 400 } )
surface.CreateFont( "SCPlyLabel", { font = "Oswald", size = 18, weight = 400 } )
surface.CreateFont( "SCPlyLoc", { font = "Oswald", size = 18, weight = 400 } )
surface.CreateFont( "SCMapName", { font = "TodaySHOP-Bold", size = 24, weight = 500 } )

surface.CreateFont( "SCAwardCategory", { font = "Oswald", size = 18, weight = 400 } )
surface.CreateFont( "SCAwardTitle", { font = "Oswald", size = 26, weight = 400 } )
surface.CreateFont( "SCAwardDescription", { font = "Arial", size = 14, weight = 400 } )
surface.CreateFont( "SCAwardProgress", { font = "Akfar", size = 12, weight = 400 } )

/*surface.CreateFont( "SCAwardDescription", { font = "Oswald Light", size = 28, weight = 400 } )
surface.CreateFont( "SCAwardProgress", { font = "Oswald Light", size = 24, weight = 400 } )*/
