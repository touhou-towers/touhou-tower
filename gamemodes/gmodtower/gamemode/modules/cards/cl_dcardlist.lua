
-----------------------------------------------------
local PANEL = {}

function PANEL:Init()

	self.Panels = {}
	self:NoClipping( true )
	self:InvalidateLayout()

end

function PANEL:SetFixedWidth( x )

	self.FixedWidth = x > 0 and x or nil

end
function PANEL:SetFixedHeight( x )

	self.FixedHeight = x > 0 and x or nil

end

local gradient = surface.GetTextureID( "VGUI/gradient_down" )
local paintButton = function( panel )
	if panel.Hovered then
		surface.SetTexture( gradient )
		surface.SetDrawColor( 150, 50, 50, 200 )
		surface.DrawTexturedRect( 0, 0, panel:GetSize() )
		//draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color( 150, 50, 50, 200 ) )
	end
	if panel.Discard then
		surface.SetTexture( gradient )
		surface.SetDrawColor( 255, 50, 50, 200 )
		surface.DrawTexturedRect( 0, 0, panel:GetSize() )
		//draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color( 255, 50, 50, 200 ) )
	end
end

function PANEL:AddCard( suit, value )

	local cardpanel = vgui.Create( "DModelCard", self )
	cardpanel:SetCard( suit, value )
	cardpanel.Suit = suit
	cardpanel.Value = value
	cardpanel:SetPos( self:GetWide() / 2, -80 )
	cardpanel:SetMouseInputEnabled( false )
	cardpanel:NoClipping( true )
	cardpanel.GotoY = 0

	local highlight = vgui.Create( "DImage", self )
	highlight:SetZPos( 1 )
	highlight:NoClipping( true )
	highlight:SetVisible( false )
	highlight.Paint = function( panel )
		surface.SetTexture( gradient )
		surface.SetDrawColor( 50, 250, 50, 100 )
		surface.DrawTexturedRect( 0, 0, panel:GetSize() )
	end
	cardpanel.Highlight = highlight

	local button = vgui.Create( "DButton", self )
	button:SetText( "" )
	button:SetZPos( 1 )
	button:NoClipping( true )
	button:SetVisible( false )
	button.Paint = paintButton
	button.DoClick = function()
		self:SetDiscard( cardpanel, button, !( button.Discard or false ) )
	end

	cardpanel.Button = button

	local id = table.insert( self.Panels, cardpanel )
	cardpanel.ID = id

end

-- card highlighting
function PANEL:HighlightCard( value, suit, off )

	off = off and true or false // just to make sure it isn't nil
	for k, card in pairs( self.Panels ) do
		//if !card:IsFullyRevealed() then continue end
		if card.Value == value and card.Suit == suit then
			card.Highlight:SetVisible( !off )
		end
	end

end
function PANEL:HighlightAll( off )

	off = off and true or false
	for k, card in pairs( self.Panels ) do
		//if !card:IsFullyRevealed() then continue end
		card.Highlight:SetVisible( !off )
	end

end

function PANEL:SetCardBrightness( value, suit, bright )

	bright = bright or 1
	if bright > 1 then bright = bright / 255 end
	for k, card in pairs( self.Panels ) do
		//if !card:IsFullyRevealed() then continue end
		if card.Value == value and card.Suit == suit then
			card:SetBright( bright )
		end
	end

end

function PANEL:SetAllBrightness( bright )

	bright = bright or 1
	if bright > 1 then bright = bright / 255 end
	for k, card in pairs( self.Panels ) do
		//if !card:IsFullyRevealed() then continue end
		card:SetBright( bright )
	end

end

function PANEL:ClearHand()

	for id, panel in pairs( self.Panels ) do
		if ValidPanel( panel ) then
			panel:Remove()
			panel = nil
		end
	end

	self.Panels = {}

end

function PANEL:SetDiscard( cardpanel, button, bool )

	if !self.Discarded then
		self.Discarded = {}
	end

	if bool && self:NumDiscarded() == 3 then return end

	button.Discard = bool
	self.Discarded[cardpanel] = bool

	// Move it up a bit
	if bool then
		cardpanel.GotoY = -25
		surface.PlaySound( "GModTower/casino/cards/cardplace_soft" .. math.random( 1, 2 ) .. ".wav" )
	else
		cardpanel.GotoY = 0
		surface.PlaySound( "GModTower/casino/cards/cardplace_hard" .. math.random( 1, 2 ) .. ".wav" )
	end

end

function PANEL:GetDiscarded()
	return self.Discarded
end

function PANEL:NumDiscarded()

	if !self.Discarded then return 0 end

	local discarded = 0
	for id, toggled in pairs( self.Discarded ) do
		if toggled then
			discarded = discarded + 1
		end
	end

	return discarded

end

function PANEL:GetNetworkDiscarded()

	if !self.Discarded then return "" end

	local discarded = ""
	for cardpanel, toggled in pairs( self.Discarded ) do
		if toggled then
			discarded = discarded .. cardpanel.ID .. "|"
			self:SetDiscard( cardpanel, cardpanel.Button, false )
		end
	end

	return discarded

end

function PANEL:SetHand( hand )

	self:ClearHand()

	for id, card in pairs( hand.cards ) do
		self:AddCard( card.suit, card.value )
	end

end

function PANEL:OverrideHand( hand )

	for id, card in pairs( hand.cards ) do
		cardpanel = self.Panels[id]
		cardpanel:SetCard( card.suit, card.value )
		cardpanel.GotoY = 0
	end

end

function PANEL:SetBlankHand( num )

	self:ClearHand()

	for i=1, num do
		self:AddCard( 1, 1 )
	end

end

function PANEL:SetReveal( bool )

	for id, panel in pairs( self.Panels ) do
		panel:SetReveal( bool )
	end

end

function PANEL:IsRevealed()

	for id, panel in pairs( self.Panels ) do
		if !panel:IsFullyRevealed() then
			return false
		end
	end

	return true

end

function PANEL:SetButtons( bool )

	for id, panel in pairs( self.Panels ) do
		panel.Button:SetVisible( bool )
	end

end

function PANEL:Think()

	for id, panel in pairs( self.Panels ) do

		if panel.GotoX && panel.x != panel.GotoX then
			panel.x = math.Approach( panel.x, panel.GotoX, 4 )
		end

		if panel.GotoY && panel.y != panel.GotoY then
			panel.y = math.Approach( panel.y, panel.GotoY, 4 )
		end

		--panel.Button:SetPos( panel.x + ( panel:GetWide() / 4 ), panel.y + panel:GetTall() / 4 / 2 )
		panel.Button:SetPos( panel.x, panel.y + panel:GetTall() / 4 * 0.75 )
		panel.Highlight:SetPos( panel.x, panel.y + panel:GetTall() / 4 * 0.75 )

	end

end

function PANEL:PerformLayout()

	local curX = 0
	local curWide = 0
	local curTall = 0

	for id, panel in pairs( self.Panels ) do

		panel:SetWide( self.FixedWidth or self:GetWide() / #self.Panels * 2 )
		panel:SetTall( self.FixedHeight or self:GetTall() )

		panel.Button:SetWide( panel:GetWide() / 2 )
		panel.Button:SetTall( panel:GetTall() / 1.5 )
		panel.Highlight:SetSize( panel:GetWide() / 2, panel:GetTall() / 1.5 )

		panel.GotoX = curX
		curX = curX + ( panel:GetWide() / 2 )

		curWide = curWide + panel:GetWide()
		curTall = panel:GetTall()

	end

	//self:SetSize( curWide, curTall )

end

vgui.Register( "DModelCardList", PANEL, "Panel" )