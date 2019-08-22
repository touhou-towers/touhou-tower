
module("Scoreboard", package.seeall )

TABBASE = {}
TABBASE.Order = 1

function TABBASE:Init()

	self:SetCursor("hand")

	if !ValidPanel( self.Label ) then
		self.Label = vgui.Create( "DLabel", self )
		self.Label:SetText( self:GetText() )
		self.Label:SetFont("SCTNavigation")
		self.Label:SetMouseInputEnabled( false )
		self.Label:SetTextColor( color_white )
	end
	
	self:SetMouseInputEnabled( true )
	
	self.Active = false
end

function TABBASE:GetText()
	return "TODO!"
end

function TABBASE:CreateBody()
	error( "TODO!: Implement me! " .. tostring(self:GetName()) )
end

function TABBASE:InvalidateLayout()

	if self.Label && self.Label:GetText() == self:GetText() then return end

	self:SetWide( 75 ) //self.Label:GetWide() + 10 )

	if self.Label then
		self.Label:SetText( self:GetText() )
		self.Label:SizeToContents()
		self.Label:Center()
	end

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
	
	if !ValidPanel( self.Body ) then
		self.Scroll = vgui.Create("DPanelList2")
		self.Scroll:SetScrollBarColors( Scoreboard.Customization.ColorNormal, Scoreboard.Customization.ColorBackground )

		self.Body = self:CreateBody()

		if !ValidPanel( self.Body ) then
			error("Unable to create body for panel")
		end
		
		self.Scroll:EnableVerticalScrollbar()
		self.Scroll:EnableHorizontal( false )
		self.Scroll.Paint = function() end
		self.Scroll:SetVisible( false )
		self.Scroll:AddItem( self.Body )
	end
	
	return self.Scroll, self.Body
	
end

TABBASE.HoverAlpha = 0

local gradient = surface.GetTextureID( "VGUI/gradient_up" )

function TABBASE:Paint( w, h )

	// Active
	if self.Active then

		/*local color = Scoreboard.Customization.ColorTabDivider
		surface.SetDrawColor( color.r, color.g, color.b, 50 )
		surface.DrawRect( 0, 0, 1, self:GetTall() )
		surface.DrawRect( self:GetWide() - 1, 0, 1, self:GetTall() )*/

		surface.SetDrawColor( Scoreboard.Customization.ColorTabActive )
		surface.DrawRect( 0, 0, self:GetSize() )
		self.HoverAlpha = 0

		/*surface.SetDrawColor( 0, 0, 0, 80 )
		surface.SetTexture( gradient )
		surface.DrawTexturedRect( 0, 0, self:GetSize() )*/

		return

	end

	// Seperator
	local color = Scoreboard.Customization.ColorTabActive
	surface.SetDrawColor( color.r, color.g, color.b, 50 )
	surface.DrawRect( 0, 0, 1, self:GetTall() )

	// Hover
	local color = Scoreboard.Customization.ColorTabHighlight
	local alpha = 0

	if self:IsMouseOver() then
		alpha = 20
	end

	self.HoverAlpha = math.Approach( self.HoverAlpha, alpha, FrameTime() * 160 )

	if self.HoverAlpha > 0 then
		surface.SetDrawColor( Color( color.r, color.g, color.b, self.HoverAlpha * 2 ) )
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

vgui.Register( "ScoreboardTab", TABBASE )