
-----------------------------------------------------
include( "cl_dcardlist.lua" )
include( "cl_dmodel_card.lua" )
include( "cl_dnumsliderbet.lua" )
include( "cl_panel_help.lua" )
include( "shared.lua" )
include( "sh_player.lua" )

module( "Cards", package.seeall )

hook.Add( "GTowerHUDPaint", "DrawChips", function()

	if not Location.IsCasino( LocalPlayer():Location() ) then return end
	local chips = LocalPlayer():PokerChips()
	if not chips then return end

	GTowerHUD.DrawExtraInfo( GTowerIcons.GetIcon("chips"), " " .. tostring(chips), 16 )

end )