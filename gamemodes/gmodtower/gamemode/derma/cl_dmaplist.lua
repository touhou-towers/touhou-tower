
/*   _
    ( )
   _| |   __   _ __   ___ ___     _ _
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_)

	DPanelList

	A window.

*/
local PANEL = {}

AccessorFunc( PANEL, "m_bSizeToContents", 		"AutoSize" )
AccessorFunc( PANEL, "m_bStretchHorizontally", 		"StretchHorizontally" )
AccessorFunc( PANEL, "m_bBackground", 			"DrawBackground" )
AccessorFunc( PANEL, "m_bBottomUp", 			"BottomUp" )
AccessorFunc( PANEL, "m_bNoSizing", 			"NoSizing" )

AccessorFunc( PANEL, "Spacing", 	"Spacing" )
AccessorFunc( PANEL, "Padding", 	"Padding" )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.pnlCanvas 	= vgui.Create( "Panel", self )
	self.pnlCanvas.OnMousePressed = function( self, code ) self:GetParent():OnMousePressed( code ) end
	self.pnlCanvas:SetMouseInputEnabled( true )
	self.pnlCanvas.InvalidateLayout = function() self:InvalidateLayout() end

	self.Items = {}
	self.YOffset = 0

	self:SetSpacing( 0 )
	self:SetPadding( 0 )
	self:EnableHorizontal( false )
	self:SetAutoSize( false )
	self:SetDrawBackground( true )
	self:SetBottomUp( false )
	self:SetNoSizing( false )

	self:SetMouseInputEnabled( true )

	// This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

end

/*---------------------------------------------------------
   Name: SizeToContents
---------------------------------------------------------*/
function PANEL:SizeToContents()

	self:SetSize( self.pnlCanvas:GetSize() )

end

/*---------------------------------------------------------
   Name: GetItems
---------------------------------------------------------*/
function PANEL:GetItems()

	// Should we return a copy of this to stop
	// people messing with it?
	return self.Items

end

/*---------------------------------------------------------
   Name: EnableHorizontal
---------------------------------------------------------*/
function PANEL:EnableHorizontal( bHoriz )

	self.Horizontal = bHoriz

end

/*---------------------------------------------------------
   Name: EnableVerticalScrollbar
---------------------------------------------------------*/
function PANEL:EnableVerticalScrollbar()

	if (self.VBar) then return end

	self.VBar = vgui.Create( "DVScrollBar", self )

end

/*---------------------------------------------------------
   Name: GetCanvas
---------------------------------------------------------*/
function PANEL:GetCanvas()

	return self.pnlCanvas

end

/*---------------------------------------------------------
   Name: GetCanvas
---------------------------------------------------------*/
function PANEL:Clear( bDelete )

	for k, panel in pairs( self.Items ) do

		if ( panel && panel:IsValid() ) then

			panel:SetParent( panel )
			panel:SetVisible( false )

			if ( bDelete ) then
				panel:Remove()
			end

		end

	end

	self.Items = {}

end

/*---------------------------------------------------------
   Name: AddItem
---------------------------------------------------------*/
function PANEL:AddItem( item )

	if (!item || !item:IsValid()) then return end

	item:SetVisible( true )
	item:SetParent( self:GetCanvas() )
	table.insert( self.Items, item )

	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: RemoveItem
---------------------------------------------------------*/
function PANEL:RemoveItem( item, bDontDelete )

	for k, panel in pairs( self.Items ) do

		if ( panel == item ) then

			self.Items[ k ] = nil

			if (!bDontDelete) then
				panel:Remove()
			end

			self:InvalidateLayout()

		end

	end

end

/*---------------------------------------------------------
   Name: Rebuild
---------------------------------------------------------*/
function PANEL:Rebuild()

	local Offset = 0

	for k, panel in pairs( self.Items ) do

		if ( panel:IsVisible() ) then

			panel:SetSize( self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall() )
			panel:SetPos( 0 - self:GetWide(), self.Padding + Offset )
			panel:MoveTo( self.pnlCanvas:GetWide()/2 - 250/2, self.Padding + Offset, 0.5 + (0.15 * k) ) // hacky x pos

			// Changing the width might ultimately change the height
			// So give the panel a chance to change its height now,
			// so when we call GetTall below the height will be correct.
			// True means layout now.
			panel:InvalidateLayout( true )

			Offset = Offset + panel:GetTall() + self.Spacing

		end

	end

	Offset = Offset + self.Padding

	self:GetCanvas():SetTall( Offset + (self.Padding) - self.Spacing )

	// This is a quick hack, ideally this setting will position the panels from the bottom upwards
	// This back just aligns the panel to the bottom
	if ( self.m_bBottomUp ) then
		self:GetCanvas():AlignBottom( self.Spacing )
	end

	// Although this behaviour isn't exactly implied, center vertically too
	if ( self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall() ) then

		self:GetCanvas():SetPos( 0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5 )

	end

end

/*---------------------------------------------------------
   Name: OnMouseWheeled
---------------------------------------------------------*/
function PANEL:OnMouseWheeled( dlta )

	if ( self.VBar ) then
		return self.VBar:OnMouseWheeled( dlta )
	end

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	derma.SkinHook( "Paint", "PanelList", self )
	return true

end

/*---------------------------------------------------------
   Name: OnVScroll
---------------------------------------------------------*/
function PANEL:OnVScroll( iOffset )

	self.pnlCanvas:SetPos( 0, iOffset )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	local Wide = self:GetWide()
	local YPos = 0

	if ( !self.Rebuild ) then
		debug.Trace()
	end

	self:Rebuild()

	if ( self.VBar && !m_bSizeToContents ) then

		self.VBar:SetPos( self:GetWide() - 16, 0 )
		self.VBar:SetSize( 16, self:GetTall() )
		self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
		YPos = self.VBar:GetOffset()

		if ( self.VBar.Enabled ) then Wide = Wide - 16 end

	end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )

	self:Rebuild()

	if ( self:GetAutoSize() ) then

		self:SetTall( self.pnlCanvas:GetTall() )
		self.pnlCanvas:SetPos( 0, 0 )

	end

end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )

	// Loop back if no VBar
	if ( !self.VBar && self:GetParent().OnMousePressed ) then
		return self:GetParent():OnMousePressed( mcode )
	end

	if ( mcode == MOUSE_RIGHT && self.VBar ) then
		self.VBar:Grip()
	end

end

/*---------------------------------------------------------
   Name: SortByMember
---------------------------------------------------------*/
function PANEL:SortByMember( key, desc )

	desc = desc or true

	table.sort( self.Items, function( a, b )

								if ( desc ) then

									local ta = a
									local tb = b

									a = tb
									b = ta

								end

								if ( a[ key ] == nil ) then return false end
								if ( b[ key ] == nil ) then return true end

								return a[ key ] > b[ key ]

							end )

end

function PANEL:Shuffle()

	table.shuffle( self.Items )
	self:Rebuild()

end

derma.DefineControl( "DMapList", "A Panel that neatly organises other panels", PANEL, "Panel" )
