
-----------------------------------------------------
local PokerHelpPanel = nil
local function ToggleHelp()

	if ValidPanel( PokerHelpPanel ) then
		PokerHelpPanel:Remove()
	else
		local w, h = 955 /* * .75*/, 543 /* * .75 */
		PokerHelpPanel = vgui.Create( "PokerHelpPanel" )
		PokerHelpPanel:SetSize( w, h )
		PokerHelpPanel:SetPos( ScrW()/2 - w/2, ScrH()/2 - h/2 )
	end

end

local PaintButton = function( panel )

	draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color( 10, 10, 10, 240 ) )

	if panel.Hovered then
		draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color( 50, 50, 50, 200 ) )
		panel:SetTextColor( Color( 255, 255, 255 ) )
	else
		panel:SetTextColor( Color( 150, 150, 150 ) )
	end

end

// ========================================================
// POKER BOARD PANEL
// ========================================================

local PANEL = {}
PANEL.Board = Material( "gmod_tower/casino/pokertable.png" )

function PANEL:Init()

	// Call Button
	self.CallButton = vgui.Create( "DButton", self )
	self.CallButton:SetZPos( 1 )
	self.CallButton:SetText( "CALL" )
	self.CallButton:SetFont( "PokerNames" )
	self.CallButton:SetVisible( false )
	self.CallButton.Paint = PaintButton
	self.CallButton.DoClick = function()
		RunConsoleCommand( "gmt_holdem_call", self.Table:EntIndex() )
	end

	// Raise Button
	self.RaiseButton = vgui.Create( "DButton", self )
	self.RaiseButton:SetZPos( 1 )
	self.RaiseButton:SetText( "RAISE" )
	self.RaiseButton:SetFont( "PokerNames" )
	self.RaiseButton:SetVisible( false )
	self.RaiseButton.Paint = PaintButton
	self.RaiseButton.DoClick = function()
		RunConsoleCommand( "gmt_holdem_raise", self.Table:EntIndex(), tonumber( self.BetSlider:GetValue() ) )
	end

	// Fold Button
	self.FoldButton = vgui.Create( "DButton", self )
	self.FoldButton:SetZPos( 1 )
	self.FoldButton:SetText( "FOLD" )
	self.FoldButton:SetFont( "PokerNames" )
	self.FoldButton:SetVisible( false )
	self.FoldButton.Paint = PaintButton
	self.FoldButton.DoClick = function()
		RunConsoleCommand( "gmt_holdem_fold", self.Table:EntIndex() )
	end

	// Help Button
	self.HelpButton = vgui.Create( "DButton", self )
	self.HelpButton:SetZPos( 1 )
	self.HelpButton:SetText( "HELP" )
	self.HelpButton:SetFont( "PokerSmall" )
	self.HelpButton.Paint = PaintButton
	self.HelpButton.DoClick = function()
		ToggleHelp()
	end

	// Bet Slider
	self.BetSlider = vgui.Create( "DNumSliderBet", self )
	self.BetSlider:SetZPos( 1 )
	self.BetSlider:SetText( "Bet" )
	self.BetSlider:SetWide( 200 )
	self.BetSlider:SetDecimals( 0 )
	self.BetSlider:SetVisible( false )

end

function PANEL:Think()

	if !self.Table then return end

	gui.EnableScreenClicker( true )
	self:UpdatePlayers()

	local tbl = self.Table
	local state = tbl:GetState()

	if state == tbl.States.STARTING then
		self.CardList:SetReveal( false )
	else

		// Reveal cards
		if tbl:StateIsBet() then
			self.CardList:SetReveal( true )
		end

	end

	// Handle controls for betting rounds
	if tbl:StateIsBet() then

		// Display controls for only the current player
		if self.CardList:IsRevealed() && tbl:GetCurrentPlayer() == LocalPlayer() then
			self:DisplayControls( true )
		else
			self:DisplayControls( false )
		end

	else
		self:DisplayControls( false )
	end

	/* // Discard Round
	if state != tbl.States.DRAW then
		self.CardList:SetButtons( false )
		self.DiscardButton:SetVisible( false )
	end
	*/

end

function PANEL:DisplayControls( bool )

	self.CallButton:SetVisible( bool )
	self.RaiseButton:SetVisible( bool )
	self.FoldButton:SetVisible( bool )
	self.BetSlider:SetVisible( bool )


	if !self.Table then return end

	local call = math.abs( self.Table:GetTopBet() - self.Table:GetIn( LocalPlayer() ) )
	if LocalPlayer():AffordPokerChips( call ) then

		if self.Table:GetIn( LocalPlayer() ) != self.Table:GetTopBet() then

			self.CallButton:SetText( "CALL" )

		else

			self.CallButton:SetText( "CHECK" )
			
		end

	else

		self.CallButton:SetText( "ALL IN" )
		self.RaiseButton:SetVisible( false )

	end

end

function PANEL:UpdatePlayers()

	if !self.Table.Players then return end

	self.PlayerPanels = self.PlayerPanels or {}
	self.PlayersCreated = self.PlayersCreated or {}

	// Add new player panels
	for id, ply in ipairs( self.Table.Players ) do

		if !IsValid( ply ) || !self.Table:IsInGame( ply ) then continue end
		if ply == LocalPlayer() then continue end

		// No duplicates
		if table.HasValue( self.PlayersCreated, ply ) then
			continue
		end

		local panel = vgui.Create( "HoldemPlayerPanel", self )
		panel:SetPlayer( ply, id )
		panel:SetTable( self.Table )
		panel.Community = Cards.Hand()

		table.insert( self.PlayerPanels, panel )
		table.insert( self.PlayersCreated, ply )

	end

	// Remove invalid player panels
	for id, panel in pairs( self.PlayerPanels ) do

		if !IsValid( panel.Player ) || !self.Table:IsInGame( panel.Player ) then
			panel:Remove()
			table.remove( self.PlayerPanels, id )
			table.remove( self.PlayersCreated, table.KeyFromValue( self.PlayersCreated, panel.Player ) )
		end

	end

end

function PANEL:SetTable( ent )

	self.Table = ent
	self.BetSlider:SetMinMax( ent:GetMinBet(), ent:GetMaxBet() )
	self.BetSlider:SetValue( ent:GetMinBet() )

end

function PANEL:PerformLayout()

	self.HelpButton:AlignLeft( self:GetWide() / 2 - 230 )
	self.HelpButton:SetSize( 50, 30 )

	self.FoldButton:AlignLeft( self:GetWide() / 2 + 145 )
	self.FoldButton:SetSize( 70, 40 )

	self.CallButton:AlignLeft( self.FoldButton.x + self.FoldButton:GetWide() + 15 )
	self.CallButton:SetSize( 70, 40 )

	self.RaiseButton:AlignLeft( self.CallButton.x + self.CallButton:GetWide() + 15 )
	self.RaiseButton:SetSize( 70, 40 )

	self.BetSlider:AlignLeft( self.FoldButton.x )
	self.BetSlider:SetWide( self.FoldButton:GetWide() + self.CallButton:GetWide() + self.RaiseButton:GetWide() + 30 )

	self.CallButton:AlignBottom( 60 )
	self.RaiseButton:AlignBottom( 60 )
	self.FoldButton:AlignBottom( 60 )
	self.HelpButton:AlignBottom( 70 )
	self.BetSlider:AlignTop( self.FoldButton.y - self.BetSlider:GetTall() - 15 )

	if self.PlayerPanels then

		local curX = 20
		for _, panel in pairs( self.PlayerPanels ) do
			panel.x = curX
			panel.y = 55
			curX = curX + panel:GetWide() + 10
		end

	end

end


function PANEL:SetupCommunity()

	local w, h = self:GetSize()
	if !ValidPanel( self.CommunityList ) then
		local panel = vgui.Create( "DModelCardList", self )
		panel:SetSize( w / 2, h / 3 )
		panel:SetPos( w / 2 - panel:GetWide() / 2, h / 2 - 98 )
		self.CommunityList = panel
	end
	self.CommunityList:SetBlankHand( 5 )
	self.CommunityList.Revealed = {}

end

function PANEL:AddCommunity( value, suit )

	if !self.CommunityList then return end
	self.Community = self.Community or Cards.Hand()
	local open = 0
	for i = 1, 5 do
		if !self.CommunityList.Revealed[i] then open = i break end
	end
	if open == 0 then
		print( "ERROR: Cannot add a community card when the river has already happened!" )
		return
	end
	local card = Cards.Card( value, suit )
	table.insert( self.Community.cards, card )
	local k = table.KeyFromValue( self.Community.cards, card )
	self.CommunityList:OverrideHand( self.Community )
	self.CommunityList.Revealed[k] = true
	self.CommunityList.Panels[k].Value = value
	self.CommunityList.Panels[k].Suit = suit
	self.CommunityList.Panels[k]:SetReveal( true )

	for k, v in pairs( self.PlayerPanels ) do
		
		v.Community = self.Community

	end

end
	

function PANEL:SetHand( hand )

	local w, h = self:GetSize()

	if !ValidPanel( self.CardList ) then
		self.CardList = vgui.Create( "DModelCardList", self )
		self.CardList:SetSize( w / 5, h / 3 )
		local whRatio = 1.43939393939393939393939394
		//self.CardList:SetFixedWidth( 204.8 )
		//self.CardList:SetFixedHeight( 204.8 * whRatio )
		self.CardList:SetPos( ( w / 2 ) - ( self.CardList:GetWide() / 2 ), ( h / 2 ) + 105 - 20 )
	end

	if !self.Hand then
		self.CardList:SetHand( hand )
		self.Table:EmitSound( self.Table.Sounds.SHUFFLE )
	else
		self.CardList:OverrideHand( hand )
	end

	self.Hand = hand

end

function PANEL:HighlightThink()

	if self.Hand then
		
		if #self.CommunityList.Revealed > 3 then
				
			local scored = self.Table:GetScoredHand( self.Hand, self.Community )
			local panels = {}

			for k, v in pairs( self.CardList.Panels ) do
				if self.Hand.cards[k] and v.Value == 1 then
					v.Value = self.Hand.cards[k].value
					v.Suit = self.Hand.cards[k].suit
				end
				table.insert( panels, v )
			end
			for k, v in pairs( self.CommunityList.Panels ) do
				if self.Community.cards[k] and v.Value == 1 then
					v.Value = self.Community.cards[k].value
					v.Suit = self.Community.cards[k].suit
				end
				table.insert( panels, v )
			end

			local function hasCard( card )

				for k, v in pairs( scored.cards ) do
					if card.Value == v.value and card.Suit == v.suit then return true end
				end
				return false

			end
			for k, v in pairs( panels ) do
				if hasCard( v ) then
					v:SetBright( 1 )
				elseif v:IsFullyRevealed() then
					v:SetBright( 0.4 )
				end
			end

		else

			self.CardList:SetAllBrightness( 1 )
			self.CommunityList:SetAllBrightness( 1 )

		end

	end

end

function PANEL:SetHandOther( hand, ply )

	if !self.PlayerPanels then return end

	// No need to set this for them, they already have it
	if ply == LocalPlayer() then return end

	for _, panel in pairs( self.PlayerPanels ) do

		if ply == panel.Player then
			panel:SetHand( hand )
			panel:Reveal()
		end

	end

end


function PANEL:Paint( w, h )

	//surface.SetDrawColor( 0, 0, 0, 250 )
	//surface.DrawRect( 0, 0, w, h )

	// Make sure no revealed cards aren't face-up
	for i = 1, 5 do
		if !self.Table:StatePlaying() then break end
		if self.Community and self.Community.cards[i] and self.Community.cards[i].value > 1 and !self.CommunityList.Panels[i]:IsFullyRevealed() then
			self.CommunityList.Panels[i]:SetReveal( true )
			self.CommunityList.Revealed[i] = true
		end
		if i < 3 and self.Hand and self.Hand.cards[i] and self.Hand.cards[i].value > 1 and !self.CardList.Panels[i]:IsFullyRevealed() then
			self.CardList.Panels[i]:SetReveal( true )
		end
	end

	if self.NextThink and self.NextThink < RealTime() then
		self.NextThink = RealTime() + 0.2
		self:HighlightThink()
	elseif !self.NextThink then
		self.NextThink = RealTime() + 0.2
	end

	// Draw board

	local function drawInfoBox( text, tcolor, color )

		local w2, h2, y = 250, 178, h - 260 + 20
		color = color or Color( 255, 255, 255 )
		draw.RoundedBox( 8, w / 2 - w2 / 2, y, w2, h2, color )
		draw.SimpleShadowText( text, "PokerText", w/2, y + h2, tcolor )

	end

	local tw, th = 1024, 512
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( self.Board )
	surface.DrawTexturedRect( w / 2 - tw / 2, h / 2 - th / 2, tw, th )

	local tbl = self.Table
	if !tbl then return end

	local action = tbl:GetAction( LocalPlayer() )

	// Display winner
	if tbl.Winners && table.HasValue( tbl.Winners, LocalPlayer() ) then

		local color = colorutil.Smooth( 2 )
		local win = "YOU WON!"

		if action == tbl.Actions.ALLIN then
			win = "YOU WON! THE POT WAS SPLIT"
		end

		drawInfoBox( win, color, Color( color.r, color.g, color.b, 50 ) )
		
		/*draw.RoundedBox( 8, 200, h - 220, w - 400, 180, Color( color.r, color.g, color.b, 50 ) )
		draw.SimpleShadowText( win, "PokerText", w/2, h/2 + 130, color )*/

	else

		// Draw folded
		if action == tbl.Actions.FOLD or action == tbl.Actions.FOLDAUTO then

			drawInfoBox( "YOU'VE FOLDED", nil, Color( 50, 50, 50, 150 ) )
			/*draw.RoundedBox( 8, 200, h - 220, w - 400, 180, Color( 50, 50, 50, 150 ) )
			draw.SimpleShadowText( "YOU'VE FOLDED", "PokerText", w/2, h/2 + 130 )*/

		// Draw all in
		elseif action == tbl.Actions.ALLIN then

			drawInfoBox( "ALL IN", nil, Color( 50, 50, 50, 150 ) )
			/*draw.RoundedBox( 8, 200, h - 220, w - 400, 180, Color( 50, 50, SinBetween( 80, 150, RealTime() * 2 ), 150 ) )
			draw.SimpleShadowText( "ALL IN", "PokerText", w/2, h/2 + 130 )*/

		end

	end

	// Draw current player
	local cur = tbl:GetCurrentPlayer()
	if IsValid( cur ) && tbl:StateHasTurns() then

		// Your turn
		if LocalPlayer() == cur then

			drawInfoBox( "YOUR TURN", nil, Color( 255, 50, 50, SinBetween( 100, 255, RealTime() * 2 ) ) )
			/*draw.RoundedBox( 8, 200, h - 220, w - 400, 180, Color( 255, 50, 50, SinBetween( 10, 50, RealTime() * 4 ) ) )
			draw.SimpleShadowText( "YOUR TURN", "PokerText", w/2, h/2 + 130, Color( 255, 50, 50, SinBetween( 100, 255, RealTime() * 2 ) ) )*/

		// Their turn
		else

			local name = cur:Name() .. "'s turn"
			//draw.SimpleText( name, "PokerNames", w / 2, h / 2 - 135, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			//draw.SimpleText( name, "PokerNames", w / 2 - 150, h / 2 - 135, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

	end

	// Draw status
	local title = tbl:GetStateTitle()
	draw.SimpleShadowText( title, "PokerText", w/2, h/2 - 130 )


	// Draw current round
	//draw.SimpleText( "Round " .. tbl:GetRound(), "PokerNames", w / 2 + 150, h / 2 - 135, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )


	// Draw pot
	surface.SetFont( "PokerNames" )
	local Width1 = surface.GetTextSize( "POT" ) + 6
	surface.SetFont( "PokerText" )
	local pot = string.FormatNumber( tbl:GetPot() ) .. " Chip" .. ( tbl:GetPot() == 1 and "" or "s" )
	local Width2 = surface.GetTextSize( pot )
	local Total = Width1 + Width2
	draw.SimpleText( "POT", "PokerNames", w / 2 - Total / 2, h / 2 - 90, Color( 0, 0, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleShadowText( pot, "PokerText", w/2 - Total / 2 + Width1, h/2 - 90, nil, nil, TEXT_ALIGN_LEFT )

	// Draw hand score
	if self.Hand && self.CardList:IsRevealed() and table.Count( self.CommunityList.Revealed ) >= 3 then
		local score = tbl:GetHandScore( self.Hand, self.Community, self.CommunityList.Revealed )
		draw.SimpleShadowText( score, "PokerNames", w/2, h/2 + 118, nil, nil, TEXT_ALIGN_CENTER )
	end

	// Display total raise
	local raise = tbl:GetIn( LocalPlayer() )
	if raise && raise > 0 then

		raise = string.FormatNumber( raise )
		draw.SimpleShadowText( "YOUR IN: " .. raise, "PokerNames", w/2 + 240, h/2 + 100, nil, nil, TEXT_ALIGN_RIGHT )
		draw.SimpleShadowText( "PROFIT: " .. tbl:GetPot() - raise, "PokerSmall", w / 2 + 240, h / 2 + 120, nil, nil, TEXT_ALIGN_RIGHT )

	end

	// Draw box under bet slider
	if self.BetSlider:IsVisible() then
		draw.RoundedBox( 8, self.BetSlider.x - 8, self.BetSlider.y - 8, self.BetSlider:GetWide() + 16, self.BetSlider:GetTall() + 16, Color( 10, 10, 10, 240 ) )
	end

end

vgui.Register( "HoldemPanel", PANEL )