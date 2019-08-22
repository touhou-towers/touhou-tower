

-----------------------------------------------------
/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DScrollPanel2: GMT Edition
*/
local PANEL = {}

PANEL.ScrollBarWidth = 8
PANEL.ScrollBarBGColor = Color( 0, 0, 0 )
PANEL.ScrollBarGripColor = Color( 0, 0, 0 )

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
	
	self:SetPadding( 0 )
	
	self:SetMouseInputEnabled( true )
	
	// This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackground( false )

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

	return self.Items
	
end

/*---------------------------------------------------------
   Name: EnableVerticalScrollbar
---------------------------------------------------------*/
function PANEL:EnableVerticalScrollbar()

	if (self.VBar) then return end
	
	self.VBar = vgui.Create( "DVScrollBar2", self )
	self:ApplyScrollBarColors()
	
end


/*---------------------------------------------------------
   Name: SetScrollBarColors
---------------------------------------------------------*/
function PANEL:SetScrollBarColors( gripColor, bgColor )

	self.ScrollBarGripColor = gripColor
	self.ScrollBarBGColor = bgColor

	self:ApplyScrollBarColors()

end

/*---------------------------------------------------------
   Name: ApplyScrollBarColors
---------------------------------------------------------*/
function PANEL:ApplyScrollBarColors()

	if !self.VBar then return end

	self.VBar.btnGrip.Color = self.ScrollBarGripColor
	self.VBar.Color = self.ScrollBarBGColor

end

/*---------------------------------------------------------
   Name: SetScrollBarWidth
---------------------------------------------------------*/
function PANEL:SetScrollBarWidth( width )
	self.ScrollBarWidth = width
end

/*---------------------------------------------------------
   Name: GetVBar
---------------------------------------------------------*/
function PANEL:GetVBar()

	return self.VBar
	
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
	
		if ( IsValid( panel ) ) then
		
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

	if ( !IsValid( item ) ) then return end

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

	if ( !IsValid( self.VBar ) ) then
		self:GetCanvas():SetSize( self:GetSize() ) 
		return
	end

	local OffsetY = 0
	
	for k, panel in pairs( self.Items ) do
		
		if ( IsValid( panel ) && panel:IsVisible() ) then
			OffsetY = math.max( OffsetY, panel.y + panel:GetTall() )
		end
		
	end

	self:GetCanvas():SetTall( OffsetY + self.Padding ) 
	
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
	
	if ( self.VBar ) then

		self.VBar:SetPos( self:GetWide() - self.ScrollBarWidth, 0 )
		self.VBar:SetSize( self.ScrollBarWidth, self:GetTall() )
		self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
		YPos = self.VBar:GetOffset()
		
		if ( self.VBar.Enabled ) then Wide = Wide - self.ScrollBarWidth end

	end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )
	
	self:Rebuild()

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

derma.DefineControl( "DScrollPanel2", "", PANEL, "DPanel" )