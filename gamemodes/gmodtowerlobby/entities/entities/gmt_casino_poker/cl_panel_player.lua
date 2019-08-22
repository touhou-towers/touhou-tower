
-----------------------------------------------------
// ========================================================
// POKER PLAYER PANEL
// ========================================================

local PANEL = {}
PANEL.AvatarSize = 64
PANEL.Size = 164

function PANEL:Init()

	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( self.AvatarSize, self.AvatarSize )
	self.Avatar:SetZPos( 1 )

	self.PlayerInfo = vgui.Create( "DPanel", self )
	self.PlayerInfo:SetSize( 64, 64 )
	self.PlayerInfo:SetZPos( 2 )
	self.PlayerInfo:SetMouseInputEnabled( false )
	self.PlayerInfo.Paint = function( self )

		if !IsValid( self.Player ) then return end

		local w = self:GetWide() - 4
		surface.SetDrawColor( 0, 0, 0, 250 )
		surface.DrawRect( 2, 2, w, 22 )

		draw.SimpleText( "#" .. tostring(self.PlayerID), "PokerSmall", w/2, 2, color_white, TEXT_ALIGN_CENTER )

	end

	self:SetSize( self.Size + 64, self.Size - 24 )

end

function PANEL:SetPlayer( ply, id )

	if ply:IsHidden() then
		self.Avatar:SetPlayer( nil )
	else
		self.Avatar:SetPlayer( ply, self.AvatarSize )
	end

	self.Player = ply
	self.PlayerInfo.Player = ply
	self.PlayerInfo.PlayerID = id

	// No need to set this up for the local player... they already have their's visible
	if ply != LocalPlayer() then
		self:SetHand()
	end

	if ply == LocalPlayer() then
		self:SetTall( self.AvatarSize + 12 )
	end

	self:InvalidateLayout()

end

function PANEL:SetHand( hand )

	local w, h = self:GetSize()

	if !ValidPanel( self.CardList ) then
		self.CardList = vgui.Create( "DModelCardList", self )
		self.CardList:SetSize( w, h )
		self.CardList:SetPos( ( w / 2 ) - ( self.CardList:GetWide() / 2 ), ( h / 2 ) - 30 )
	end

	if hand then
		self.CardList:OverrideHand( hand )
		self.Hand = hand
	else
		self.CardList:SetBlankHand( 5 )
	end

end

function PANEL:Think()

	if !self.Table then return end

	if self.Hand && self.Table:GetState() == self.Table.States.REVEAL then
		self:SetTall( self.Size )
	else
		self:SetTall( self.Size - 24 )
	end

	// Clear out old hand
	if self.Table:GetState() != self.Table.States.REVEAL && self.CardList:IsRevealed() then
		self.CardList:SetBlankHand( 5 )
		self.CardList:SetReveal( false )
	end

end

function PANEL:Reveal()
	self.CardList:SetReveal( true )
end

function PANEL:SetTable( table )
	self.Table = table
end

function PANEL:PerformLayout()

	self.Avatar.y = 6
	self.Avatar:AlignLeft( 6 )

	self.PlayerInfo:SetPos( self.Avatar.x, self.Avatar.y )

end

function PANEL:Paint( w, h )

	draw.RoundedBox( 8, 0, 0, w, h, Color( 10, 10, 10, 200 ) )

	if !self.Table then return end
	if !IsValid( self.Player ) then return end

	local action = self.Table:GetAction( self.Player )
	local state = self.Table:GetState()

	// Highlight for current player
	local iscurrent = ( self.Table:GetCurrentPlayer() == self.Player ) && self.Table:StateHasTurns()
	if iscurrent then
		draw.RoundedBox( 8, 0, 0, w, h, Color( 255, 50, 50, SinBetween( 10, 50, RealTime() * 4 ) ) )
	end

	// Highlight for draw round
	if state == self.Table.States.DRAW then

		if action != self.Table.Actions.DISCARD && action != self.Table.Actions.FOLD && action != self.Table.Actions.FOLDAUTO then
			draw.RoundedBox( 8, 0, 0, w, h, Color( 255, 50, 50, SinBetween( 10, 50, RealTime() * 4 ) ) )
		end

	end

	local x = self.AvatarSize + 6 + 6
	local y = 6
	local offsetY = 0

	// Player name
	draw.SimpleText( self.Player:Name(), "PokerSmall", x, y, color_white, TEXT_ALIGN_LEFT )
	surface.SetFont( "PokerTiny" )

	// Display total raise
	local raise = self.Table:GetIn( self.Player )
	if raise && raise > 0 then

		offsetY = 20
		local tx, ty = surface.GetTextSize( "in" )

		draw.SimpleText( "in", "PokerTiny", x, y + offsetY + 4, Color( 150, 150, 150, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( string.FormatNumber( raise ), "PokerSmall", x + tx + 2, y + offsetY, color_white, TEXT_ALIGN_LEFT )

	end


	// Display winners
	if self.Table.Winners && table.HasValue( self.Table.Winners, self.Player ) then

		-- offsetY = 40 -- this draws over "ALL-IN" messages
		offsetY = 20
		local color = colorutil.Smooth( 2 )

		draw.RoundedBox( 8, 0, 0, w, h, Color( color.r, color.g, color.b, 20 ) )
		draw.SimpleText( "WINNER!", "PokerSmall", x + 2, y + offsetY, color, TEXT_ALIGN_LEFT )

	end


	// Display hand score
	if self.Hand && state == self.Table.States.REVEAL then

		local handscore = self.Table:GetHandScore( self.Hand )
		draw.SimpleText( handscore, "PokerSmall", w/2, h - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end


	// Display action
	if action then

		local name = self.Table:GetActionName( action )

		local offsetX = x
		offsetY = 40

		// Any extra info on that action? (raise or discard amount)
		if name && self.Player._PActionVar then

			local tw, ty = surface.GetTextSize( name )
			draw.SimpleText( name, "PokerTiny", x, y + offsetY + 4, Color( 150, 150, 150, 150 ), TEXT_ALIGN_LEFT )

			local actionvar = string.FormatNumber( self.Player._PActionVar )
			draw.SimpleText( actionvar, "PokerSmall", x + tw - 4, y + offsetY, color_white, TEXT_ALIGN_LEFT )

			return

		end

		if name then
			draw.SimpleText( name, "PokerSmall", offsetX, y + offsetY, color_white, TEXT_ALIGN_LEFT )
		end

	end

	// Display last action
	/*local lastaction = self.Table:GetActionName( self.Player, self.Player._PLastAction )
	if lastaction then

		// Any extra info on that action? (raise or discard amount)
		if self.Player._PLastActionVar && ( self.Player._PLastAction == self.Table.Actions.RAISE || self.Player._PLastAction == self.Table.Actions.DISCARD ) then
			lastaction = lastaction .. ": " .. string.FormatNumber( self.Player._PLastActionVar )
		end

		offsetY = 40
		local tx, ty = surface.GetTextSize( "Last" )

		draw.SimpleText( "Last", "PokerTiny", x, y + offsetY + 4, Color( 150, 150, 150, 150 ), TEXT_ALIGN_LEFT )
		draw.SimpleText( lastaction, "PokerSmall", x + tx + 2, y + offsetY, color_white, TEXT_ALIGN_LEFT )

	end*/

end

vgui.Register( "PokerPlayerPanel", PANEL )