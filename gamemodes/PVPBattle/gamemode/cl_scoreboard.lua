
-----------------------------------------------------
module( "Scoreboard.Customization", package.seeall )



// COLORS

ColorFont = color_white

ColorFontShadow = Color( 6, 76, 127, 255 )



ColorNormal = Color( 34, 100, 156, 255 )

ColorBright = Color( 57, 131, 181, 255 )

ColorDark = Color( 17, 50, 78, 255 )



ColorBackground = colorutil.Brighten( ColorNormal, 0.75 )



ColorTabActive = Color( 0, 0, 64, 64 )

ColorTabDivider = Color( 191, 46, 19, 255 )

ColorTabInnerActive = colorutil.Brighten( ColorDark, 0.75, 200 )

ColorTabHighlight = colorutil.Brighten( ColorTabDivider, 3 )



ColorAwardsDescription = Color( 220, 220, 220, 255 )

ColorAwardsBarAchieved = Color( 178, 215, 243, 150 )

ColorAwardsBarNotAchieved = Color( 3, 67, 114, 150 )

ColorAwardsAchievedIcon = Color( 32, 255, 4, 150 )





// HEADER

HeaderTitle = ""

HeaderMatHeader = Scoreboard.GenTexture( "ScoreboardPVPLogo", "pvpbattle/main_header" )

HeaderMatFiller = Scoreboard.GenTexture( "ScoreboardPVPFiller", "pvpbattle/main_filler" )

HeaderMatRightBorder = Scoreboard.GenTexture( "ScoreboardPVPRightBorder", "pvpbattle/main_rightborder" )



// RANK SYSTEM

local function CalculateRanks()



	if NextCalcRank && NextCalcRank > CurTime() then

		return

	end



	local Players = player.GetAll()

	

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



	if !ply:Alive() then

		return "DEAD"

	end



	return ""



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



	if not GAMEMODE:IsRoundOver() then return false end



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