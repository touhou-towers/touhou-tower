

-----------------------------------------------------
local PANEL = {}
PANEL.Padding = 4
PANEL.Spacing = 2

PANEL.Filters = {}

function PANEL:Init()

	self.Title = vgui.Create( "DLabel", self )
	self.Title:SetFont( "ChatVerdana16" )
	self.Title:SetText( "Show/Hide" )

	self.Filters = {}

	-- Create buttons
	for id, name in ipairs( GTowerChat.ChatGroups ) do
		self:AddFilter( id, name )
	end

	self:InvalidateLayout()

end

function PANEL:SetOwner( panel, textpanel )
	self.Panel = panel
	self.textpanel = textpanel
end

function PANEL:AddFilter( id, name )

	local check = vgui.Create( "DCheckBoxLabel", self )
	check:SetText( name )
	check:SetValue( true )
	check:SizeToContents()
	check.Bit = math.pow(2, id-1)

	check.OnChange = function(panel, toggle)

		local filter = self.textpanel:GetFilter()

		if !toggle then
			self.textpanel:SetFilter( bit.bor( filter, panel.Bit ) )
		else
			self.textpanel:SetFilter( bit.band( filter, (255-panel.Bit) ) )
		end

		self.textpanel:InvalidateLayout()

	end

	table.insert( self.Filters, check )

end

function PANEL:PerformLayout()

	local row, maxWidth = 0, 0
	local size = 16 + self.Spacing

	self.Title:SizeToContents()

	for _, panel in pairs( self.Filters ) do
		panel:SetPos( self.Padding, self.Title:GetTall() + self.Padding + ( row * size ) )
		row = row + 1
		if panel:GetWide() > maxWidth then maxWidth = panel:GetWide() end
	end

	if self.Title:GetWide() > maxWidth then maxWidth = self.Title:GetWide() end

	self:SetSize( (self.Padding*2) + maxWidth, self.Title:GetTall() + (self.Padding*2) + ( row * size ) ) --+ ( 16 + self.Padding ) )

	self.Title:CenterHorizontal()

end

function PANEL:Paint( w, h )
	local color = colorutil.Brighten( GTowerChat.BGColor, .75 )
	surface.SetDrawColor( color.r, color.g, color.b, 255 )
	surface.DrawRect( 0, 0, w, h )

	local color = GTowerChat.BGColor
	surface.SetDrawColor( color.r, color.g, color.b, 255 )
	surface.DrawRect( 0, self.Title.y, self:GetWide(), self.Title:GetTall() )
end

derma.DefineControl( "GTowerChatSettings", "", PANEL, "DPanel" )