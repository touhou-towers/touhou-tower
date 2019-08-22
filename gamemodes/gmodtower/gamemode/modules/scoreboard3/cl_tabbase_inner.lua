

-----------------------------------------------------
module("Scoreboard", package.seeall )

TABBASE = {}
TABBASE.Order = 1

function TABBASE:Init()

	self:SetCursor("hand")

	if !ValidPanel( self.Label ) then
		self.Label = Label( "Unknown" )
		self.Label:SetParent( self )
		self.Label:SetFont("SCTNavigation")
		self.Label:SetMouseInputEnabled( false )
		self.Label:SetTextColor( color_white )
	end

	if !ValidPanel( self.Label2 ) then
		self.Label2 = Label( "Unknown" )
		self.Label2:SetParent( self )
		self.Label2:SetFont("SCTNavigation")
		self.Label2:SetMouseInputEnabled( false )
		self.Label2:SetTextColor( color_white )
	end
	
	self:SetMouseInputEnabled( true )
	
	self.Active = false
end

function TABBASE:SetText( text )
	self.Text = text
end

function TABBASE:SetRightText( text )
	self.Text2 = text
end

function TABBASE:SetBody( body )
	self.Body = body
	self.Body:SetVisible( false )
end

function TABBASE:SetOrder( order )
	self.Order = order
end

function TABBASE:InvalidateLayout()
	
	self.Label:SetText( self.Text )
	self.Label:SizeToContents()

	self.Label2:SetText( self.Text2 or "" )
	self.Label2:SizeToContents()
	self.Label2:AlignRight(4)
	self.Label2:SetVisible( tobool(self.Text2) )
	
	self:SetWide( self.Label:GetWide() + 20 )
	self.Label:AlignLeft(8)

end

function TABBASE:SetActive( active )

	if self.Active == active then	
		return
	end

	self.Active = active

	if active then
		self:OnOpen()
		self:SetCursor("default")
	else
		self:OnClose()
		self:SetCursor("hand")
	end

end

function TABBASE:Think()

	if self.Active then
		self:SetCursor("default")
	else
		self:SetCursor("hand")
	end

end

function TABBASE:OnOpen()
end

function TABBASE:OnClose()
end

function TABBASE:GetBody()
	
	return self.Body
	
end

TABBASE.HoverAlpha = 0
TABBASE.HoverTextAlpha = 50
local gradient = surface.GetTextureID( "VGUI/gradient_up" )

function TABBASE:Paint( w, h )

	// Seperator
	surface.SetDrawColor( Scoreboard.Customization.ColorTabInnerActive )
	surface.DrawRect( 0, 0, 1, self:GetTall() )

	// Active
	if self.Active then

		surface.SetDrawColor( Scoreboard.Customization.ColorBright )
		surface.DrawRect( 0, 1, 1, self:GetTall() )
		surface.DrawRect( self:GetWide() - 1, 0, 1, self:GetTall() )

		surface.SetDrawColor( Scoreboard.Customization.ColorTabInnerActive )
		surface.DrawRect( 0, 0, self:GetSize() )
		self.HoverAlpha = 0

		self.Label:SetTextColor( color_white )
		return
	end

	local color = Scoreboard.Customization.ColorTabHighlight
	local alpha = 0
	local textAlpha = 50

	// Hover
	if self:IsMouseOver() and self:IsMouseInputEnabled() then
		alpha = 20
		textAlpha = 255
	end

	// Disabled
	if not self:IsMouseInputEnabled() then
		textAlpha = 5
		alpha = 0
	end

	self.HoverAlpha = alpha //math.Approach( self.HoverAlpha, alpha, FrameTime() * 120 )
	self.HoverTextAlpha = textAlpha //math.Approach( self.HoverTextAlpha, textAlpha, FrameTime() * 300 )

	self.Label:SetTextColor( Color( color_white.r, color_white.g, color_white.b, self.HoverTextAlpha ) )

	if self.HoverAlpha > 0 then
		surface.SetDrawColor( Color( color.r, color.g, color.b, self.HoverAlpha ) )
		//surface.DrawRect( 0, 0, self:GetSize() )

		surface.SetTexture( gradient )
		surface.DrawTexturedRect( 0, 0, self:GetSize() )
	end

end

function TABBASE:OnMousePressed()

	if self:GetParent().ActiveTab != self then
		self:GetParent():SetActiveTab( self )
	end

end

function TABBASE:IsMouseOver()

	local x,y = self:CursorPos()
	return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()

end

vgui.Register( "ScoreboardTabInner", TABBASE )