
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
		RunConsoleCommand( "gmt_poker_call", self.Table:EntIndex() )
	end

	// Raise Button
	self.RaiseButton = vgui.Create( "DButton", self )
	self.RaiseButton:SetZPos( 1 )
	self.RaiseButton:SetText( "RAISE" )
	self.RaiseButton:SetFont( "PokerNames" )
	self.RaiseButton:SetVisible( false )
	self.RaiseButton.Paint = PaintButton
	self.RaiseButton.DoClick = function()
		RunConsoleCommand( "gmt_poker_raise", self.Table:EntIndex(), tonumber( self.BetSlider:GetValue() ) )
	end

	// Fold Button
	self.FoldButton = vgui.Create( "DButton", self )
	self.FoldButton:SetZPos( 1 )
	self.FoldButton:SetText( "FOLD" )
	self.FoldButton:SetFont( "PokerNames" )
	self.FoldButton:SetVisible( false )
	self.FoldButton.Paint = PaintButton
	self.FoldButton.DoClick = function()
		RunConsoleCommand( "gmt_poker_fold", self.Table:EntIndex() )
	end

	// Discard Button
	self.DiscardButton = vgui.Create( "DButton", self )
	self.DiscardButton:SetZPos( 1 )
	self.DiscardButton:SetText( "DISCARD" )
	self.DiscardButton:SetFont( "PokerNames" )
	self.DiscardButton:SetVisible( false )
	self.DiscardButton.Paint = PaintButton
	self.DiscardButton.DoClick = function()
		RunConsoleCommand( "gmt_poker_discard", self.Table:EntIndex(), self.CardList:GetNetworkDiscarded() )
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
		if state == tbl.States.BET || state == tbl.States.DRAW || state == tbl.States.BETFINAL then
			self.CardList:SetReveal( true )
		end

	end

	// Handle controls for betting rounds
	if state == tbl.States.BET || state == tbl.States.BETFINAL then

		// Display controls for only the current player
		if self.CardList:IsRevealed() && tbl:GetCurrentPlayer() == LocalPlayer() then
			self:DisplayControls( true )
		else
			self:DisplayControls( false )
		end

	else
		self:DisplayControls( false )
	end

	// Discard Round
	if state == tbl.States.DRAW then

		// Handle displaying the discard button
		local action = self.Table:GetAction( LocalPlayer() )

		if action == tbl.Actions.DISCARD || action == tbl.Actions.FOLD || action == tbl.Actions.FOLDAUTO then
			self.CardList:SetButtons( false )
			self.DiscardButton:SetVisible( false )
		else
			self.DiscardButton:SetVisible( true )
			self.DiscardButton:SetText( "DISCARD " .. tostring( self.CardList:NumDiscarded() ) )
			self.CardList:SetButtons( true ) // Draw card selection buttons if they haven't discarded anything yet
		end

	else
		self.CardList:SetButtons( false )
		self.DiscardButton:SetVisible( false )
	end

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

		local panel = vgui.Create( "PokerPlayerPanel", self )
		panel:SetPlayer( ply, id )
		panel:SetTable( self.Table )

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

	self.CallButton:Center()
	self.CallButton:SetSize( 70, 40 )

	self.HelpButton:AlignLeft( self.CallButton.x - self.CallButton:GetWide() - 130 )
	self.HelpButton:SetSize( 50, 30 )

	self.DiscardButton:AlignLeft( self.CallButton.x - self.CallButton:GetWide() - 30 )
	self.DiscardButton:SetSize( 100, 40 )

	self.RaiseButton:AlignLeft( self.CallButton.x + self.CallButton:GetWide() + 15 )
	self.RaiseButton:SetSize( 70, 40 )

	self.FoldButton:AlignLeft( self.CallButton.x - self.CallButton:GetWide() - 15 )
	self.FoldButton:SetSize( 70, 40 )

	self.BetSlider:AlignLeft( self.RaiseButton.x + self.RaiseButton:GetWide() + 30 )

	self.CallButton:AlignBottom( 80 )
	self.DiscardButton:AlignBottom( 80 )
	self.RaiseButton:AlignBottom( 80 )
	self.FoldButton:AlignBottom( 80 )
	self.HelpButton:AlignBottom( 90 )
	self.BetSlider:AlignBottom( 80 + 2 )

	if self.PlayerPanels then

		local curX = 20
		for _, panel in pairs( self.PlayerPanels ) do
			panel.x = curX
			panel.y = 55
			curX = curX + panel:GetWide() + 10
		end

	end

end

function PANEL:SetHand( hand )

	local w, h = self:GetSize()

	if !ValidPanel( self.CardList ) then
		self.CardList = vgui.Create( "DModelCardList", self )
		self.CardList:SetSize( w / 2, h / 3 )
		self.CardList:SetPos( ( w / 2 ) - ( self.CardList:GetWide() / 2 ), ( h / 2 ) + 40 )
	end

	if !self.Hand then
		self.CardList:SetHand( hand )
		self.Table:EmitSound( self.Table.Sounds.SHUFFLE )
	else
		self.CardList:OverrideHand( hand )
	end

	self.Hand = hand

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

	// Draw board
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

		draw.RoundedBox( 8, 200, h - 320, w - 400, 180, Color( color.r, color.g, color.b, 50 ) )
		draw.SimpleShadowText( win, "PokerText", w/2, h/2 + 30, color )

	else

		// Draw folded
		if action == tbl.Actions.FOLD or action == tbl.Actions.FOLDAUTO then

			draw.RoundedBox( 8, 200, h - 320, w - 400, 180, Color( 50, 50, 50, 150 ) )
			draw.SimpleShadowText( "YOU'VE FOLDED", "PokerText", w/2, h/2 + 30 )

		// Draw all in
		elseif action == tbl.Actions.ALLIN then

			draw.RoundedBox( 8, 200, h - 320, w - 400, 180, Color( 50, 50, SinBetween( 80, 150, RealTime() * 2 ), 150 ) )
			draw.SimpleShadowText( "ALL IN", "PokerText", w/2, h/2 + 30 )

		end

	end

	// Draw current player
	local cur = tbl:GetCurrentPlayer()
	if IsValid( cur ) && tbl:StateHasTurns() then

		// Your turn
		if LocalPlayer() == cur then

			draw.RoundedBox( 8, 200, h - 320, w - 400, 180, Color( 255, 50, 50, SinBetween( 10, 50, RealTime() * 4 ) ) )
			draw.SimpleShadowText( "YOUR TURN", "PokerText", w/2, h/2 + 30, Color( 255, 50, 50, SinBetween( 100, 255, RealTime() * 2 ) ) )

		// Their turn
		else

			local name = cur:Name() .. "'s turn"
			draw.SimpleText( name, "PokerNames", w / 2, h / 2 - 135, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			//draw.SimpleText( name, "PokerNames", w / 2 - 150, h / 2 - 135, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

	end

	// Draw status
	local title = tbl:GetStateTitle()
	draw.SimpleShadowText( title, "PokerText", w/2, h/2 - 100 )


	// Draw current round
	//draw.SimpleText( "Round " .. tbl:GetRound(), "PokerNames", w / 2 + 150, h / 2 - 135, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )


	// Draw pot
	local pot = string.FormatNumber( tbl:GetPot() ) .. " Chips"
	draw.SimpleText( "POT", "PokerNames", w / 2, h / 2 - 40 - 30, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleShadowText( pot, "PokerText", w/2, h/2 - 40 )

	// Draw hand score
	if self.Hand && self.CardList:IsRevealed() then
		local score = tbl:GetHandScore( self.Hand )
		draw.SimpleShadowText( score, "PokerNames", w/2 - 260, h/2 + 70, nil, nil, TEXT_ALIGN_LEFT )
	end

	// Display total raise
	local raise = tbl:GetIn( LocalPlayer() )
	if raise && raise > 0 then

		raise = string.FormatNumber( raise )
		draw.SimpleShadowText( "YOUR IN: " .. raise, "PokerNames", w/2 + 240, h/2 + 70, nil, nil, TEXT_ALIGN_RIGHT )

	end

	// Draw box under bet slider
	if self.BetSlider:IsVisible() then
		draw.RoundedBox( 8, self.BetSlider.x - 8, self.BetSlider.y - 8, self.BetSlider:GetWide() + 16, self.BetSlider:GetTall() + 16, Color( 10, 10, 10, 240 ) )
	end

end

vgui.Register( "PokerPanel", PANEL )