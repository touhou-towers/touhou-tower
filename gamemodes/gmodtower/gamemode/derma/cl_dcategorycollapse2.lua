

-----------------------------------------------------
/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DCategoryCollapse2: GMT Edition

*/

local PANEL = {}

Derma_Hook( PANEL, "Paint", "Paint", "CategoryHeader" )
Derma_Hook( PANEL, "ApplySchemeSettings", "Scheme", "CategoryHeader" )
Derma_Hook( PANEL, "PerformLayout", "Layout", "CategoryHeader" )

/*---------------------------------------------------------
	Init
---------------------------------------------------------*/
function PANEL:Init()

	self:SetContentAlignment( 4 )
	
end

/*---------------------------------------------------------
	OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )

	if ( mcode == MOUSE_LEFT ) then
		self:GetParent():Toggle()
	return end
	
	return self:GetParent():OnMousePressed( mcode )

end

derma.DefineControl( "DCategoryHeader", "Category Header", PANEL, "DButton" )



local PANEL = {}

AccessorFunc( PANEL, "m_bSizeExpanded", 		"Expanded", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_iContentHeight",	 	"StartHeight" )
AccessorFunc( PANEL, "m_fAnimTime", 			"AnimTime" )
AccessorFunc( PANEL, "m_bDrawBackground", 		"DrawBackground", 	FORCE_BOOL )
AccessorFunc( PANEL, "m_iPadding", 				"Padding" )

/*---------------------------------------------------------
	Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Title = ""
	self.Header = vgui.Create( "DCategoryHeader", self )
	self.Header:SetText( "" )
	
	self:SetExpanded( true )
	self:SetMouseInputEnabled( true )
	
	self:SetAnimTime( 0.2 )
	self.animSlide = Derma_Anim( "Anim", self, self.AnimSlide )
	
	self:SetDrawBackground( true )

	self:SetLabelFont( Scoreboard.Customization.CollapsablesFont, false )
	self:SetTabCurve( 0 )

	self:SetColors( 
		Scoreboard.Customization.ColorDark, 
		Scoreboard.Customization.ColorBackground, 
		Scoreboard.Customization.ColorBright, 
		Scoreboard.Customization.ColorBright
	)

	self:SetPadding( 2 )

end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()

	self.animSlide:Run()

end

/*---------------------------------------------------------
	SetLabel
---------------------------------------------------------*/
function PANEL:SetLabel( strLabel )

	self.Title = strLabel
	//self.Header:SetText( strLabel )

end

/*---------------------------------------------------------
	Paint
---------------------------------------------------------*/
function PANEL:Paint( w, h )

	//derma.SkinHook( "Paint", "CollapsibleCategory", self )

	local title = self.Title

	if self.LabelUppercase then
		title = string.upper( title )
	end

	local alpha = 255
	local tabcolor = self.TabColorEnabled
	local bgcolor = Scoreboard.Customization.ColorDark

	// Hover
	if self:IsMouseOver() then
		tabcolor = colorutil.Brighten( tabcolor, 1.25 )
		bgcolor = colorutil.Brighten( bgcolor, 1.25 )
	end

	// Closed
	if !self:GetExpanded() then

		alpha = 50
		tabcolor = self.TabColorDisabled
		bgcolor = Color( 0, 0, 0, 0 )

		if self:IsMouseOver() then
			alpha = 150
			tabcolor = colorutil.Brighten( self.TabColorDisabled, 1.1 )
		end

	end

	surface.SetFont( self.LabelFont )
	local tw, th = surface.GetTextSize( title )

	// Top bar
	surface.SetDrawColor( tabcolor )

	if self.TabCurve then
		draw.RoundedBox( self.TabCurve, 0, 0, self:GetWide(), th, tabcolor )
		surface.DrawRect( 0, 6, w, th - 6 )
	else
		surface.DrawRect( 0, 6, w, th )
	end

	// BG

	surface.SetDrawColor( bgcolor )
	surface.DrawRect( 0, th, w, h - th )

	// Text
	surface.SetTextColor( 255, 255, 255, alpha )
	surface.SetTextPos( 3, -1 )
	surface.DrawText( title )

end

function PANEL:SetColors( tabColor, tabColorDisabled, bgColor, bgColorDisabled )

	self.TabColorEnabled = tabColor
	self.TabColorDisabled = tabColorDisabled
	self.BGColorEnabled = bgColor
	self.BGColorDisabled = bgColorDisabled

end

function PANEL:SetLabelFont( font, upper )

	self.LabelFont = font
	self.LabelUppercase = upper

end

function PANEL:SetTabCurve( curve )

	self.TabCurve = curve

end

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	derma.SkinHook( "Scheme", "CollapsibleCategory", self )

end

/*---------------------------------------------------------
   Name: SetContents
---------------------------------------------------------*/
function PANEL:SetContents( pContents )

	self.Contents = pContents
	self.Contents:SetParent( self )
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: Toggle
---------------------------------------------------------*/
function PANEL:Toggle()

	if self.NoCollapse then
		self:SetExpanded( true )
	else
		self:SetExpanded( !self:GetExpanded() )
	end

	self.animSlide:Start( self:GetAnimTime(), { From = self:GetTall() } )
	
	self:InvalidateLayout( true )
	
	if self:GetParent() then
		self:GetParent():InvalidateLayout()
	end

	if self:GetParent():GetParent() then
		self:GetParent():GetParent():InvalidateLayout()
	end

	if !self.NoCollapse then

		local cookie = '1'
		if ( !self:GetExpanded() ) then cookie = '0' end
		self:SetCookie( "Open", cookie )

	end
	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	local Padding = self:GetPadding() or 0

	self.Header:SetPos( 0, 0 )
	self.Header:SetWide( self:GetWide() )
	
	if ( self.Contents ) then
			
		if ( self:GetExpanded() ) then
	
			self.Contents:SetPos( Padding, self.Header:GetTall() + Padding )
			self.Contents:SetWide( self:GetWide() - Padding * 2)	
			
			self.Contents:InvalidateLayout( true )
			
			self.Contents:SetVisible( true )
			self:SetTall( self.Contents:GetTall() + self.Header:GetTall() + Padding * 2 )
		
		else
		
			
			self.Contents:SetVisible( false )
			self:SetTall( self.Header:GetTall() )
		
		end	
		
	end
	
	// Make sure the color of header text is set
	self.Header:ApplySchemeSettings()
	
	self.animSlide:Run()

end

function PANEL:IsMouseOver()

	local x,y = self:CursorPos()
	return x >= 0 and y >= 0 and x <= self:GetWide() and y <= 22

end

/*---------------------------------------------------------
	OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )

	if ( !self:GetParent().OnMousePressed ) then return end;
	
	return self:GetParent():OnMousePressed( mcode )

end

/*---------------------------------------------------------
   Name: AnimSlide
---------------------------------------------------------*/
function PANEL:AnimSlide( anim, delta, data )
	
	if ( anim.Started ) then
		data.To = self:GetTall()	
	end
	
	if ( anim.Finished ) then
		self:InvalidateLayout()
	return end

	if ( self.Contents ) then self.Contents:SetVisible( true ) end
	
	self:SetTall( Lerp( delta, data.From, data.To ) )
	
	if self:GetParent() then
		self:GetParent():InvalidateLayout()
	end

	if self:GetParent():GetParent() then
		self:GetParent():GetParent():InvalidateLayout()
	end

end

/*---------------------------------------------------------
	LoadCookies
---------------------------------------------------------*/
function PANEL:LoadCookies()

	if self.NoCollapse then
		self:SetExpanded( true )
		return
	end

	local Open = self:GetCookieNumber( "Open", 1 ) == 1

	self:SetExpanded( Open )
	self:InvalidateLayout( true )
	self:GetParent():InvalidateLayout()
	self:GetParent():GetParent():InvalidateLayout()

end


/*---------------------------------------------------------
   Name: GenerateExample
---------------------------------------------------------*/
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		ctrl:SetLabel( "Category List Test Category" )
		ctrl:SetSize( 300, 300 )
		ctrl:SetPadding( 10 )
		
		// The contents can be any panel, even a DPanelList
		local Contents = vgui.Create( "DButton" )
		Contents:SetText( "This is the content of the control" )
		ctrl:SetContents( Contents )
		
		ctrl:InvalidateLayout( true )
		
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DCollapsibleCategory2", "Collapsable Category Panel", PANEL, "Panel" )