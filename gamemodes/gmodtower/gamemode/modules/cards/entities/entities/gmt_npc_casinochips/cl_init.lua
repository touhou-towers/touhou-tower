
-----------------------------------------------------
include('shared.lua')

local function Rules()

	return "<font=GTowerbig>RULES OF 5 CARD DRAW</font>\n\n"..
			"Goal: Make the best 5-card poker hand possible after one draw, and bet accordingly. The player with the best hand after the second betting round takes the pot.\n\n"..
			"Each player must pay a predetermined ante before being dealt any cards.\n\n"..
			"<font=GTowerbigbold><color=white>DEAL ROUND</color></font>\n" .. "Once all players have anted, each player is dealt five cards face down.\n\n"..
			"<font=GTowerbigbold><color=white>BET ROUND</color></font>\n" .. "Players now begin to place bets. Players can RAISE the pot amount, CALL which is accepting a raise, or FOLD which forfiets your hand.\n\n"..
			"<font=GTowerbigbold><color=white>DRAW ROUND</color></font>\n" .. "When the betting round completes the draw round begins. Assuming players haven't folded, they have the option of changing up to 3 cards they choose.\n\n"..
			"<font=GTowerbigbold><color=white>FINAL DEAL ROUND</color></font>\n" .. "Once all players have received their new cards, each player must evaluate their hand and proceed to the second (and final) betting round. Once this betting round is completed it's time for the reveal."

end

usermessage.Hook( "NPCCasino", function( um )

	local menu = {
		{
			title = "Cash Chips",
			large = true,
			icon = "money",
			func = function()
				RunConsoleCommand( "gmt_casino_chips_cash" )
				SelectionMenuManager.Remove()
			end,
		},
		{
			title = "Buy Chips",
			icon = "money",
			func = function()
				Derma_NumberRequest(
					"Buy Chips",
					T( "PokerChipWorth", Cards.ChipCost ),
					function ( val ) RunConsoleCommand( "gmt_casino_chips_buy", val ) SelectionMenuManager.Remove() end,
					nil,
					"Buy",
					"Cancel",
					"GMC"
				)
			end,
		},
		{
			title = "Rules",
			icon = "about",
			func = function() MsgN( "wow!" ) end,
		},
	}

	SelectionMenuManager.Create( "towercasino", menu )

end )