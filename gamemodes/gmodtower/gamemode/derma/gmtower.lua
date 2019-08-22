
-- Define SetSkin() as gmtower

local surface = surface
local draw = draw
local Color = Color

SKIN = {}

// These are used in the settings panel

SKIN.PrintName 		= "Gmod Tower Skin"
SKIN.Author 		= "Team Gmode Tower"
SKIN.DermaVersion	= 1
SKIN.GwenTexture				= Material( "gwenskin/gmodtower.png" )

--local darker_blue = Color(38, 109, 175)
--local moredark_blue = Color(56, 142, 203)
--local lighter_blue = Color(65, 148, 207)
--local separator_blue = Color(49, 126, 179)
--
--local text_white = Color(255, 255, 255)
--local text_red = Color(200, 25, 25)
--
--local inactive_blue = Color(42, 114, 169)
--local rowa_blue = Color(85, 167, 221)
--local rowb_blue = Color(52, 137, 195)
--local header_blue = Color(25, 89, 147)
--
--local trans_blue = Color(85, 167, 221, 50)
--local dark_trans_blue = Color(38, 109, 175, 150)
--
--local progress_green = Color(50, 255, 50)
--
--SKIN.bg_color 					= darker_blue
--SKIN.bg_color_sleep 			= Color( 70, 70, 70, 255 )
--SKIN.bg_color_dark				= header_blue
--SKIN.bg_color_bright			= lighter_blue
--
--SKIN.bg_color_chat			= dark_trans_blue
--
--SKIN.fontFrame					= "Default"
--
--SKIN.fontItem 				= "mikubig"
--
--SKIN.control_color 				= lighter_blue
--SKIN.control_color_highlight	= darker_blue
--SKIN.control_color_active 		= moredark_blue
--SKIN.control_color_bright 		= Color( 255, 200, 100, 255 )
--SKIN.control_color_dark 		= inactive_blue
--
--SKIN.bg_alt1 					= rowa_blue
--SKIN.bg_alt2 					= rowb_blue
--
--SKIN.progressbar_color				= progress_green
--
--SKIN.listview_hover				= Color( 55, 150, 211, 255 )
--SKIN.listview_selected			= Color( 100, 170, 220, 255 )
--
--SKIN.text_bright				= Color( 255, 255, 255, 255 )
--SKIN.text_normal				= inactive_blue
--SKIN.text_dark					= Color( 20, 20, 20, 255 )
--SKIN.text_highlight				= text_white
--SKIN.text_shadow				= Color( 0, 0, 0, 200 )
--
--SKIN.texGradientUp				= Material( "gui/gradient_up" )
--SKIN.texGradientDown			= Material( "gui/gradient_down" )
--
--SKIN.combobox_selected			= SKIN.listview_selected
--
--SKIN.panel_transback			= trans_blue
--SKIN.tooltip					= Color( 255, 245, 175, 255 )
--
--SKIN.colPropertySheet 			= darker_blue
--SKIN.colTab			 			= moredark_blue
--SKIN.colTabInactive				= lighter_blue
--
--SKIN.colTabShadow				= separator_blue
--SKIN.colTabText		 			= text_white
--SKIN.colTabTextInactive			= inactive_blue
--SKIN.colTabTextAttention		= text_red
--
--SKIN.colCollapsibleCategory		= trans_blue
--
--SKIN.colCategoryText			= Color( 255, 255, 255, 255 )
--SKIN.colCategoryTextInactive	= Color( 200, 200, 200, 255 )
--SKIN.fontCategoryHeader			= "TabLarge"
--
--SKIN.colNumberWangBG			= Color( 255, 240, 150, 255 )
--SKIN.colTextEntryBG				= Color( 240, 240, 240, 255 )
--SKIN.colTextEntryBorder			= Color( 20, 20, 20, 255 )
--SKIN.colTextEntryText			= Color( 20, 20, 20, 255 )
--SKIN.colTextEntryTextHighlight	= Color( 20, 200, 250, 255 )
--SKIN.colTextEntryTextHighlight	= Color( 20, 200, 250, 255 )
--
--SKIN.colMenuBG					= Color( 255, 255, 255, 200 )
--SKIN.colMenuBorder				= Color( 0, 0, 0, 200 )
--
--SKIN.colButtonText				= Color( 255, 255, 255, 255 )
--SKIN.colButtonTextDisabled		= Color( 255, 255, 255, 55 )
--SKIN.colButtonBorder			= Color( 20, 20, 20, 255 )
--SKIN.colButtonBorderHighlight	= Color( 255, 255, 255, 50 )
--SKIN.colButtonBorderShadow		= Color( 0, 0, 0, 100 )
--SKIN.fontButton					= "Default"
--
--function SKIN:DrawGenericBackground( x, y, w, h, color )
--	draw.RoundedBox( 8, x, y, w, h, color )
--end
--
--function SKIN:DrawButtonBorder( x, y, w, h, depressed )
--
--	surface.SetDrawColor( self.colButtonBorder )
--	surface.DrawOutlinedRect( x, y, w, h )
--
--end
--
--function SKIN:PaintButton( panel, w, h )
--	if ( panel.m_bBackground ) then
--		if ( panel:GetDisabled() ) then
--			draw.RoundedBox( 8, 0, 0, w, h, self.control_color_dark )
--		elseif ( panel.Depressed || panel:GetDisabled() ) then
--			draw.RoundedBox( 8, 0, 0, w, h, self.control_color_dark )
--		elseif ( panel.Hovered ) then
--			draw.RoundedBox( 8, 0, 0, w, h, Color( 90, 170, 225 ) )
--		else
--			draw.RoundedBox( 8, 0, 0, w, h, self.control_color )
--		end
--	end
--end
--
--function SKIN:PaintOverButton( panel )
--	return false
--end
--
--/*---------------------------------------------------------
--   Chat
-----------------------------------------------------------*/
--function SKIN:PaintChat( panel )
--
--	self:DrawGenericBackground( 0, 0, panel:GetWide(), panel:GetTall(), self.bg_color_chat )
--
--end
--
--/*---------------------------------------------------------
--   Scoreboard
-----------------------------------------------------------*/
--function SKIN:PaintScoreboard( panel )
--
--	local color = self.bg_color
--	self:DrawGenericBackground( 0, 40, panel:GetWide(), panel:GetTall() - 40, color )
--
--end
--
--/*---------------------------------------------------------
--   ScoreboardItem
-----------------------------------------------------------*/
--function SKIN:PaintScoreboardItem( panel )
--	surface.SetDrawColor(255,255,255,255)
--
--	surface.SetTexture( panel.MiddleTexture ) 
--	surface.DrawTexturedRect( panel.MiddlePosStart, 0, panel.MiddleWidth, 64 )
--    
--	if panel.IsFirst then
--        surface.SetTexture( panel.LeftTexture )
--        surface.DrawTexturedRect( 0, 0, 16, 64 )
--	end
--    
--	if panel.IsLast then
--        surface.SetTexture( panel.RightTexture )
--        surface.DrawTexturedRect( panel.RightPos, 0, 16, 64 )
--	end
--    
--    surface.SetFont(self.fontItem)
--
--	local col = self.text_highlight
--	local alpha = math.Clamp( CurTime() - panel.HoverTime, 0.0, 0.7 )
--    
--	if panel:IsSelected() then 
--		surface.SetTextColor( self.text_shadow.r, self.text_shadow.g, self.text_shadow.b, self.text_shadow.a )
--		surface.SetTextPos( panel.TextX + 1, panel.TextY + 2 )
--		surface.DrawText( panel.Text )
--	end
--	
--	if !panel:IsSelected() && !panel.Hovered then
--		alpha = 0.7 - alpha
--	end
--	
--	surface.SetTextColor( col.r, col.g, col.b, (alpha+0.3) * 255 )
--	
--    
--	surface.SetTextPos( panel.TextX, panel.TextY )
--	surface.DrawText( panel.Text )
--end
--
--/*---------------------------------------------------------
--   ScoreboardHeader
-----------------------------------------------------------*/
--function SKIN:PaintScoreboardHeaderItem( panel )
--	local col = self.bg_color_dark
--	surface.SetDrawColor( col.r, col.g, col.b, col.a )
--    
--	surface.DrawRect( 3,0, panel:GetWide() - 6, 23 )
--end
--
--/*---------------------------------------------------------
--   ScoreboardListItem
-----------------------------------------------------------*/
--function SKIN:PaintScoreboardListItem( panel )
--	local col = self.bg_alt1
--	if panel.Alt then col = self.bg_alt2 end
--	surface.SetDrawColor( col.r, col.g, col.b, col.a )
--
--	surface.DrawRect( 0,0, panel:GetWide(), panel:GetTall() )
--end
--
--/*---------------------------------------------------------
--   NumSlider
-----------------------------------------------------------*/
--function SKIN:PaintNumSlider( panel )
--
--	local w, h = panel:GetSize()
--	
--	self:DrawGenericBackground( 0, 0, w, h, self.colCollapsibleCategory )
--	
--	surface.SetDrawColor( 0, 0, 0, 200 )
--	surface.DrawRect( 3, h/2, w-6, 1 )
--	
--end
--
--/*---------------------------------------------------------
--   NewMessage
-----------------------------------------------------------*/
--function SKIN:PaintNewMessage( panel )
--	local Wide, Tall = panel:GetWide(), panel:GetTall()
--    	local col = self.panel_transback
--
--	surface.SetDrawColor( col.r, col.g, col.b, panel.Alpha )
--	surface.DrawRect( 0,0, Wide, Tall )
--    
--	surface.SetFont("small")
--	col = self.text_highlight
--	surface.SetTextColor( col.r, col.g, col.b, math.Clamp( panel.Alpha * 2.5 , 128, 255 ) )
--	
--	local Height = 0
--	
--	for k, v in pairs( panel.Text ) do
--		local w, h = surface.GetTextSize( v )
--        
--        surface.SetTextPos( panel.TextXPos, Height + panel.TextStartY )
--		surface.DrawText( v )
--		
--		Height = Height + h + 2
--	end
--
--	col = self.progressbar_color
--	surface.SetDrawColor( col.r, col.g, col.b, panel.Alpha )
--    
--	if self.Timeleft == nil then
--		surface.DrawRect( 2, Tall - 3 , (Wide - 4) * ( (panel.DieTime - CurTime()) / panel.Duration ), 2 )
--	else
--		surface.DrawRect( 2, Tall - 3 , (Wide - 4) * ( panel.Timeleft / panel.Duration ), 2 )
--	end
--end
--
--/*---------------------------------------------------------
--   GroupPlayer
-----------------------------------------------------------*/
--function SKIN:PaintGroupPlayer( panel )
--	local col = self.bg_color_bright
--	surface.SetDrawColor( col.r, col.g, col.b, col.a )
--	surface.DrawRect( MikuGroup.AvatarSize, 0,             panel.BarWidth, panel.BarHeight )
--	surface.DrawRect( MikuGroup.AvatarSize, panel.StartY2 , panel.BarWidth, panel.BarHeight )
--	
--	surface.SetDrawColor( 55, 200 + math.sin( CurTime() + panel.TimeOffset ) * 20, 55, 255 )
--	surface.DrawRect( MikuGroup.AvatarSize + 2, panel.StartY2 + 2, panel.HealthSize, panel.BarHeight - 4 )
--end
--
--/*---------------------------------------------------------
--   Contect menu when you click on players
-----------------------------------------------------------*/
--function SKIN:PaintClientMenuMain( panel )
--	
--	local col = self.bg_color
--	surface.SetDrawColor( col.r, col.g, col.b, col.a )
--
--end
--
--function SKIN:PaintClientMenuTitle( panel )
--	
--	local col = self.bg_color_dark
--	surface.SetDrawColor( col.r, col.g, col.b, col.a )
--	
--	surface.SetTextColor( 255, 255, 255, 255 )
--
--end
--
--local MenuIconBack = surface.GetTextureID("menu/item_icon_back")
--
--function SKIN:PaintClientMenuItem( panel )
--	local col = self.bg_alt1
--	
--	if panel.Hovered || panel.SubMenu != nil then 
--		col = self.bg_alt2 
--	end
--	
--	surface.SetDrawColor( col.r, col.g, col.b, col.a )
--	
--	//SetDrawColor( (self.Hovered || self.SubMenu != nil) and HoveredColor or UnHoveredColor )
--    surface.DrawRect( 0,0, panel:GetWide(), panel:GetTall() )
--    
--	local CheckEnabled = panel:CheckEnabled()
--	
--	if CheckEnabled == nil then
--		col = self.colTabShadow
--		surface.SetDrawColor( col.r, col.g, col.b, col.a )
--	elseif CheckEnabled == false then
--		surface.SetDrawColor( 160, 30, 30, 100 )
--	else
--		surface.SetDrawColor( 30, 160, 30, 100 )
--	end
--	
--    surface.SetTexture( MenuIconBack )
--    surface.DrawTexturedRect( 0, 0, 32, 32 )
--    
--    
--
--    surface.SetFont("small")
--    surface.SetTextColor( 255, 255, 255, 255 )
--    surface.SetTextPos( panel.TextX, panel.TextY )
--    surface.DrawText( panel.Text )
--
--end
--
--function SKIN:PaintClientMenuClose( panel )
--	 local col = self.control_color_dark 
--	 
--	 if panel.Hovered then
--		col = self.control_color_active
--    end
--	
--	 surface.SetDrawColor( col.r, col.g, col.b, 250 )
--	
--
--end
--
--/*---------------------------------------------------------
--	ScrollBar
-----------------------------------------------------------*/
--function SKIN:PaintVScrollBar( panel )
--	draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color( self.bg_color.r, self.bg_color.g, self.bg_color.b, self.bg_color.a ) )
--end
--
--/*---------------------------------------------------------
--	ScrollBarGrip
-----------------------------------------------------------*/
--function SKIN:PaintScrollBarGrip( panel )
--	draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color( self.control_color.r, self.control_color.g, self.control_color.b, self.control_color.a ) )
--end
--
--/*---------------------------------------------------------
--	ScrollBar
-----------------------------------------------------------*/
--function SKIN:PaintMenu( panel )
--	draw.RoundedBox( 8, 0, 0, w, h, self.colMenuBG )
--end
--function SKIN:PaintOverMenu( panel )
--	draw.RoundedBox( 8, 0, 0, w, h, self.colMenuBorder )
--end
--
--/*---------------------------------------------------------
--	ListView
-----------------------------------------------------------*/
--function SKIN:PaintListView( panel )
--
--	if ( panel.m_bBackground ) then
--		surface.SetDrawColor( 45, 125, 175, 255 )
--		panel:DrawFilledRect()
--	end
--	
--end





local darker_blue = Color(38, 109, 175)
local moredark_blue = Color(56, 142, 203)
local lighter_blue = Color(65, 148, 207)
local separator_blue = Color(49, 126, 179)

local text_white = Color(255, 255, 255)
local text_red = Color(200, 25, 25)

local inactive_blue = Color(42, 114, 169)
local rowa_blue = Color(85, 167, 221)
local rowb_blue = Color(52, 137, 195)
local header_blue = Color(25, 89, 147)

local trans_blue = Color(85, 167, 221, 50)
local dark_trans_blue = Color(38, 109, 175, 150)

local progress_green = Color(50, 255, 50)

SKIN.bg_color 					= darker_blue
SKIN.bg_color_sleep 			= Color( 70, 70, 70, 255 )
SKIN.bg_color_dark				= header_blue
SKIN.bg_color_bright			= lighter_blue
SKIN.bg_color_chat				= dark_trans_blue

SKIN.frame_border				= lighter_blue
SKIN.frame_title				= header_blue
SKIN.fontFrame					= "Default"
SKIN.fontItem 					= "Gtowerbig"

SKIN.control_color 				= lighter_blue
SKIN.control_color_highlight	= darker_blue
SKIN.control_color_active 		= moredark_blue
SKIN.control_color_bright 		= Color( 255, 200, 100, 255 )
SKIN.control_color_dark 		= inactive_blue

SKIN.bg_alt1 					= rowa_blue
SKIN.bg_alt2 					= rowb_blue

SKIN.progressbar_color			= progress_green

SKIN.listview_hover				= Color( 55, 150, 211, 255 )
SKIN.listview_selected			= Color( 100, 170, 220, 255 )

SKIN.text_bright				= Color( 255, 255, 255, 255 )
SKIN.text_normal				= inactive_blue
SKIN.text_dark					= Color( 20, 20, 20, 255 )
SKIN.text_highlight				= text_white
SKIN.text_shadow				= Color( 0, 0, 0, 200 )

SKIN.texGradientUp				= Material( "gui/gradient_up" )
SKIN.texGradientDown			= Material( "gui/gradient_down" )

SKIN.combobox_selected			= SKIN.listview_selected

SKIN.panel_transback			= trans_blue
SKIN.tooltip					= Color( 255, 245, 175, 255 )

SKIN.colPropertySheet 			= darker_blue
SKIN.colTab			 			= moredark_blue
SKIN.colTabInactive				= lighter_blue

SKIN.colPropertySheet 			= Color( 170, 170, 170, 255 )
SKIN.colTab			 			= SKIN.colPropertySheet
SKIN.colTabText		 			= text_white
SKIN.colTabTextInactive			= inactive_blue
SKIN.colTabShadow				= separator_blue
SKIN.colTabTextAttention		= text_red
SKIN.fontTab					= "DermaDefault"

SKIN.colCollapsibleCategory		= trans_blue

SKIN.colCategoryText			= Color( 255, 255, 255, 255 )
SKIN.colCategoryTextInactive	= Color( 200, 200, 200, 255 )
SKIN.fontCategoryHeader			= "TabLarge"

SKIN.colNumberWangBG			= Color( 255, 240, 150, 255 )
SKIN.colTextEntryBG				= Color( 240, 240, 240, 255 )
SKIN.colTextEntryBorder			= Color( 20, 20, 20, 255 )
SKIN.colTextEntryText			= Color( 20, 20, 20, 255 )
SKIN.colTextEntryTextHighlight	= Color( 173, 208, 208, 255 )

SKIN.colMenuBG					= Color( 255, 255, 255, 200 )
SKIN.colMenuBorder				= Color( 0, 0, 0, 200 )

SKIN.colButtonText				= Color( 255, 255, 255, 255 )
SKIN.colButtonTextDisabled		= Color( 255, 255, 255, 55 )
SKIN.colButtonBorder			= Color( 20, 20, 20, 255 )
SKIN.colButtonBorderHighlight	= Color( 255, 255, 255, 50 )
SKIN.colButtonBorderShadow		= Color( 0, 0, 0, 100 )
SKIN.fontButton					= "Default"

SKIN.tex = {}

SKIN.tex.Selection		 			= GWEN.CreateTextureBorder( 384, 32, 31, 31, 4, 4, 4, 4 );

SKIN.tex.Panels = {}
SKIN.tex.Panels.Normal				= GWEN.CreateTextureBorder( 256,		0,	63,	63,	16,	16,		16,	16 )
SKIN.tex.Panels.Bright				= GWEN.CreateTextureBorder( 256+64,	0,	63,	63,	16,	16,		16,	16 )
SKIN.tex.Panels.Dark				= GWEN.CreateTextureBorder( 256,		64,	63,	63,	16,	16,		16,	16 )
SKIN.tex.Panels.Highlight			= GWEN.CreateTextureBorder( 256+64,	64,	63,	63,	16,	16,		16,	16 )

SKIN.tex.Button						= GWEN.CreateTextureBorder( 480, 0,	31,		31,		8,	8,		8,	8 )
SKIN.tex.Button_Hovered				= GWEN.CreateTextureBorder( 480, 32,	31,		31,		8,	8,		8,	8 )
SKIN.tex.Button_Dead				= GWEN.CreateTextureBorder( 480, 64,	31,		31,		8,	8,		8,	8 )
SKIN.tex.Button_Down				= GWEN.CreateTextureBorder( 480, 96,	31,		31,		8,	8,		8,	8 )
SKIN.tex.Shadow						= GWEN.CreateTextureBorder( 448, 0,	31,		31,		8,	8,		8,	8 )

SKIN.tex.Tree						= GWEN.CreateTextureBorder( 256, 128, 127,	127,	16,	16,		16,	16 )
SKIN.tex.Checkbox_Checked			= GWEN.CreateTextureNormal( 448, 32, 15, 15 )
SKIN.tex.Checkbox					= GWEN.CreateTextureNormal( 464, 32, 15, 15 )
SKIN.tex.CheckboxD_Checked			= GWEN.CreateTextureNormal( 448, 48, 15, 15 )
SKIN.tex.CheckboxD					= GWEN.CreateTextureNormal( 464, 48, 15, 15 )
--SKIN.tex.RadioButton_Checked		= GWEN.CreateTextureNormal( 448, 64, 15, 15 )
--SKIN.tex.RadioButton				= GWEN.CreateTextureNormal( 464, 64, 15, 15 )
--SKIN.tex.RadioButtonD_Checked		= GWEN.CreateTextureNormal( 448, 80, 15, 15 )
--SKIN.tex.RadioButtonD				= GWEN.CreateTextureNormal( 464, 80, 15, 15 )
SKIN.tex.TreePlus					= GWEN.CreateTextureNormal( 448, 96, 15, 15 )
SKIN.tex.TreeMinus					= GWEN.CreateTextureNormal( 464, 96, 15, 15 )
--SKIN.tex.Menu_Strip				= GWEN.CreateTextureBorder( 0, 128, 127, 21, 1, 1, 1, 1 )
SKIN.tex.TextBox					= GWEN.CreateTextureBorder( 0, 150, 127, 21,		4,	4,		4,	4 )
SKIN.tex.TextBox_Focus				= GWEN.CreateTextureBorder( 0, 172, 127, 21,		4,	4,		4,	4 )
SKIN.tex.TextBox_Disabled			= GWEN.CreateTextureBorder( 0, 193, 127, 21,		4,	4,		4,	4 )
SKIN.tex.MenuBG_Column				= GWEN.CreateTextureBorder( 128, 128, 127, 63,		24, 8, 8, 8 )
SKIN.tex.MenuBG						= GWEN.CreateTextureBorder( 128, 192, 127, 63,		8, 8, 8, 8 )
SKIN.tex.MenuBG_Hover				= GWEN.CreateTextureBorder( 128, 256, 127, 31,		8, 8, 8, 8 )
SKIN.tex.MenuBG_Spacer				= GWEN.CreateTextureNormal( 128, 288, 127, 3 )
SKIN.tex.Menu_Strip					= GWEN.CreateTextureBorder( 0, 128, 127, 21,		8, 8, 8, 8)
SKIN.tex.Menu_Check					= GWEN.CreateTextureNormal( 448, 112, 15, 15 )
SKIN.tex.Tab_Control				= GWEN.CreateTextureBorder( 0, 256, 127, 127, 8, 8, 8, 8 )
SKIN.tex.TabB_Active				= GWEN.CreateTextureBorder( 0,		416, 63, 31, 8, 8, 8, 8 )
SKIN.tex.TabB_Inactive				= GWEN.CreateTextureBorder( 0+128,	416, 63, 31, 8, 8, 8, 8 )
SKIN.tex.TabT_Active				= GWEN.CreateTextureBorder( 0,		384, 63, 31, 8, 8, 8, 8 )
SKIN.tex.TabT_Inactive				= GWEN.CreateTextureBorder( 0+128,	384, 63, 31, 8, 8, 8, 8 )
SKIN.tex.TabL_Active				= GWEN.CreateTextureBorder( 64,		384, 31, 63, 8, 8, 8, 8 )
SKIN.tex.TabL_Inactive				= GWEN.CreateTextureBorder( 64+128,	384, 31, 63, 8, 8, 8, 8 )
SKIN.tex.TabR_Active				= GWEN.CreateTextureBorder( 96,		384, 31, 63, 8, 8, 8, 8 )
SKIN.tex.TabR_Inactive				= GWEN.CreateTextureBorder( 96+128,	384, 31, 63, 8, 8, 8, 8 )
SKIN.tex.Tab_Bar					= GWEN.CreateTextureBorder( 128, 352, 127, 31, 4, 4, 4, 4 )
		
SKIN.tex.Window = {}

SKIN.tex.Window.Normal				= GWEN.CreateTextureBorder( 0,	0,	127,	127,	8,	32,		8,	8 )
SKIN.tex.Window.Inactive			= GWEN.CreateTextureBorder( 128,	0,	127,	127,	8,	32,		8,	8 )

SKIN.tex.Window.Close				= GWEN.CreateTextureNormal( 32, 448, 31, 31 );
SKIN.tex.Window.Close_Hover			= GWEN.CreateTextureNormal( 64, 448, 31, 31 );
SKIN.tex.Window.Close_Down			= GWEN.CreateTextureNormal( 96, 448, 31, 31 );

SKIN.tex.Window.Maxi				= GWEN.CreateTextureNormal( 32 + 96*2, 448, 31, 31 );
SKIN.tex.Window.Maxi_Hover			= GWEN.CreateTextureNormal( 64 + 96*2, 448, 31, 31 );
SKIN.tex.Window.Maxi_Down			= GWEN.CreateTextureNormal( 96 + 96*2, 448, 31, 31 );

SKIN.tex.Window.Restore				= GWEN.CreateTextureNormal( 32 + 96*2, 448+32, 31, 31 );
SKIN.tex.Window.Restore_Hover		= GWEN.CreateTextureNormal( 64 + 96*2, 448+32, 31, 31 );
SKIN.tex.Window.Restore_Down		= GWEN.CreateTextureNormal( 96 + 96*2, 448+32, 31, 31 );

SKIN.tex.Window.Mini				= GWEN.CreateTextureNormal( 32 + 96, 448, 31, 31 );
SKIN.tex.Window.Mini_Hover			= GWEN.CreateTextureNormal( 64 + 96, 448, 31, 31 );
SKIN.tex.Window.Mini_Down			= GWEN.CreateTextureNormal( 96 + 96, 448, 31, 31 );

SKIN.tex.Scroller = {}
SKIN.tex.Scroller.TrackV				= GWEN.CreateTextureBorder( 384,				208, 15, 127, 4, 4, 4, 4 );
SKIN.tex.Scroller.ButtonV_Normal		= GWEN.CreateTextureBorder( 384 + 16,		208, 15, 127, 4, 4, 4, 4 );
SKIN.tex.Scroller.ButtonV_Hover			= GWEN.CreateTextureBorder( 384 + 32,		208, 15, 127, 4, 4, 4, 4 );
SKIN.tex.Scroller.ButtonV_Down			= GWEN.CreateTextureBorder( 384 + 48,		208, 15, 127, 4, 4, 4, 4 );
SKIN.tex.Scroller.ButtonV_Disabled		= GWEN.CreateTextureBorder( 384 + 64,		208, 15, 127, 4, 4, 4, 4 );

SKIN.tex.Scroller.TrackH				= GWEN.CreateTextureBorder( 384,	128,		127, 15, 4, 4, 4, 4 );
SKIN.tex.Scroller.ButtonH_Normal		= GWEN.CreateTextureBorder( 384,	128 + 16,	127, 15, 4, 4, 4, 4 );
SKIN.tex.Scroller.ButtonH_Hover			= GWEN.CreateTextureBorder( 384,	128 + 32,	127, 15, 4, 4, 4, 4 );
SKIN.tex.Scroller.ButtonH_Down			= GWEN.CreateTextureBorder( 384,	128 + 48,	127, 15, 4, 4, 4, 4 );
SKIN.tex.Scroller.ButtonH_Disabled		= GWEN.CreateTextureBorder( 384,	128 + 64,	127, 15, 4, 4, 4, 4 );

SKIN.tex.Scroller.LeftButton_Normal		= GWEN.CreateTextureBorder( 464,			208,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.LeftButton_Hover		= GWEN.CreateTextureBorder( 480,			208,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.LeftButton_Down		= GWEN.CreateTextureBorder( 464,			272,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.LeftButton_Disabled	= GWEN.CreateTextureBorder( 480 + 48,	272,	15, 15, 2, 2, 2, 2 );

SKIN.tex.Scroller.UpButton_Normal		= GWEN.CreateTextureBorder( 464,			208 + 16,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.UpButton_Hover		= GWEN.CreateTextureBorder( 480,			208 + 16,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.UpButton_Down			= GWEN.CreateTextureBorder( 464,			272 + 16,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.UpButton_Disabled		= GWEN.CreateTextureBorder( 480 + 48,	272 + 16,	15, 15, 2, 2, 2, 2 );

SKIN.tex.Scroller.RightButton_Normal	= GWEN.CreateTextureBorder( 464,			208 + 32,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.RightButton_Hover		= GWEN.CreateTextureBorder( 480,			208 + 32,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.RightButton_Down		= GWEN.CreateTextureBorder( 464,			272 + 32,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.RightButton_Disabled	= GWEN.CreateTextureBorder( 480 + 48,	272 + 32,	15, 15, 2, 2, 2, 2 );

SKIN.tex.Scroller.DownButton_Normal		= GWEN.CreateTextureBorder( 464,			208 + 48,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.DownButton_Hover		= GWEN.CreateTextureBorder( 480,			208 + 48,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.DownButton_Down		= GWEN.CreateTextureBorder( 464,			272 + 48,	15, 15, 2, 2, 2, 2 );
SKIN.tex.Scroller.DownButton_Disabled	= GWEN.CreateTextureBorder( 480 + 48,	272 + 48,	15, 15, 2, 2, 2, 2 );

SKIN.tex.Menu = {}
SKIN.tex.Menu.RightArrow				= GWEN.CreateTextureNormal( 464, 112, 15, 15 );

SKIN.tex.Input = {}

SKIN.tex.Input.ComboBox = {}
SKIN.tex.Input.ComboBox.Normal			= GWEN.CreateTextureBorder( 384,	336,	127, 31, 8, 8, 32, 8 );
SKIN.tex.Input.ComboBox.Hover			= GWEN.CreateTextureBorder( 384,	336+32, 127, 31, 8, 8, 32, 8 );
SKIN.tex.Input.ComboBox.Down			= GWEN.CreateTextureBorder( 384,	336+64, 127, 31, 8, 8, 32, 8 );
SKIN.tex.Input.ComboBox.Disabled		= GWEN.CreateTextureBorder( 384,	336+96, 127, 31, 8, 8, 32, 8 );

SKIN.tex.Input.ComboBox.Button = {}
SKIN.tex.Input.ComboBox.Button.Normal		 = GWEN.CreateTextureNormal( 496,	272,	15, 15 );
SKIN.tex.Input.ComboBox.Button.Hover		 = GWEN.CreateTextureNormal( 496,	272+16, 15, 15 );
SKIN.tex.Input.ComboBox.Button.Down			 = GWEN.CreateTextureNormal( 496,	272+32, 15, 15 );
SKIN.tex.Input.ComboBox.Button.Disabled		 = GWEN.CreateTextureNormal( 496,	272+48, 15, 15 );

SKIN.tex.Input.UpDown = {}
SKIN.tex.Input.UpDown.Up = {}
SKIN.tex.Input.UpDown.Up.Normal				= GWEN.CreateTextureCentered( 384,		112,	7, 7 );
SKIN.tex.Input.UpDown.Up.Hover				= GWEN.CreateTextureCentered( 384+8,	112,	7, 7 );
SKIN.tex.Input.UpDown.Up.Down				= GWEN.CreateTextureCentered( 384+16,	112,	7, 7 );
SKIN.tex.Input.UpDown.Up.Disabled			= GWEN.CreateTextureCentered( 384+24,	112,	7, 7 );

SKIN.tex.Input.UpDown.Down = {}
SKIN.tex.Input.UpDown.Down.Normal			= GWEN.CreateTextureCentered( 384,		120,	7, 7 );
SKIN.tex.Input.UpDown.Down.Hover			= GWEN.CreateTextureCentered( 384+8,	120,	7, 7 );
SKIN.tex.Input.UpDown.Down.Down				= GWEN.CreateTextureCentered( 384+16,	120,	7, 7 );
SKIN.tex.Input.UpDown.Down.Disabled			= GWEN.CreateTextureCentered( 384+24,	120,	7, 7 );

SKIN.tex.Input.Slider = {}
SKIN.tex.Input.Slider.H = {}
SKIN.tex.Input.Slider.H.Normal			= GWEN.CreateTextureNormal( 416,	32,	15, 15 );
SKIN.tex.Input.Slider.H.Hover			= GWEN.CreateTextureNormal( 416,	32+16, 15, 15 );
SKIN.tex.Input.Slider.H.Down			= GWEN.CreateTextureNormal( 416,	32+32, 15, 15 );
SKIN.tex.Input.Slider.H.Disabled		= GWEN.CreateTextureNormal( 416,	32+48, 15, 15 );

SKIN.tex.Input.Slider.V = {}
SKIN.tex.Input.Slider.V.Normal			= GWEN.CreateTextureNormal( 416+16,	32,	15, 15 );
SKIN.tex.Input.Slider.V.Hover			= GWEN.CreateTextureNormal( 416+16,	32+16, 15, 15 );
SKIN.tex.Input.Slider.V.Down			= GWEN.CreateTextureNormal( 416+16,	32+32, 15, 15 );
SKIN.tex.Input.Slider.V.Disabled		= GWEN.CreateTextureNormal( 416+16,	32+48, 15, 15 );

SKIN.tex.Input.ListBox = {}
SKIN.tex.Input.ListBox.Background		= GWEN.CreateTextureBorder( 256,	256, 63, 127, 8, 8, 8, 8 );
SKIN.tex.Input.ListBox.Hovered			= GWEN.CreateTextureBorder( 320,	320, 31, 31, 8, 8, 8, 8 );
SKIN.tex.Input.ListBox.EvenLine			= GWEN.CreateTextureBorder( 352,  256, 31, 31, 8, 8, 8, 8 );
SKIN.tex.Input.ListBox.OddLine			= GWEN.CreateTextureBorder( 352,  288, 31, 31, 8, 8, 8, 8 );
SKIN.tex.Input.ListBox.EvenLineSelected			= GWEN.CreateTextureBorder( 320,	270, 31, 31, 8, 8, 8, 8 );
SKIN.tex.Input.ListBox.OddLineSelected			= GWEN.CreateTextureBorder( 320,	288, 31, 31, 8, 8, 8, 8 );

SKIN.tex.ProgressBar = {}
SKIN.tex.ProgressBar.Back		= GWEN.CreateTextureBorder( 384,	0, 31, 31, 8, 8, 8, 8 );
SKIN.tex.ProgressBar.Front		= GWEN.CreateTextureBorder( 384+32,	0, 31, 31, 8, 8, 8, 8 );


SKIN.tex.CategoryList = {}
SKIN.tex.CategoryList.Outer		= GWEN.CreateTextureBorder( 256,		384, 63, 63, 8, 8, 8, 8 );
SKIN.tex.CategoryList.Inner		= GWEN.CreateTextureBorder( 256 + 64,	384, 63, 63, 8, 21, 8, 8 );
SKIN.tex.CategoryList.Header	= GWEN.CreateTextureBorder( 320,			352, 63, 31, 8, 8, 8, 8 );

SKIN.tex.Tooltip		= GWEN.CreateTextureBorder( 384,	64, 31, 31, 8, 8, 8, 8 );
		
SKIN.Colours = {}

SKIN.Colours.Window = {}
SKIN.Colours.Window.TitleActive			= Color( 255, 255, 255 ); //GWEN.TextureColor( 4 + 8 * 0, 508 );
SKIN.Colours.Window.TitleInactive		= Color( 255, 255, 255 ); //GWEN.TextureColor( 4 + 8 * 1, 508 );

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal				= GWEN.TextureColor( 4 + 8 * 2, 508 );
SKIN.Colours.Button.Hover				= GWEN.TextureColor( 4 + 8 * 3, 508 );
SKIN.Colours.Button.Down				= GWEN.TextureColor( 4 + 8 * 2, 500 );
SKIN.Colours.Button.Disabled			= GWEN.TextureColor( 4 + 8 * 3, 500 );

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Active = {}
SKIN.Colours.Tab.Active.Normal			= GWEN.TextureColor( 4 + 8 * 4, 508 );
SKIN.Colours.Tab.Active.Hover			= GWEN.TextureColor( 4 + 8 * 5, 508 );
SKIN.Colours.Tab.Active.Down			= GWEN.TextureColor( 4 + 8 * 4, 500 );
SKIN.Colours.Tab.Active.Disabled		= GWEN.TextureColor( 4 + 8 * 5, 500 );

SKIN.Colours.Tab.Inactive = {}
SKIN.Colours.Tab.Inactive.Normal		= GWEN.TextureColor( 4 + 8 * 6, 508 );
SKIN.Colours.Tab.Inactive.Hover			= GWEN.TextureColor( 4 + 8 * 7, 508 );
SKIN.Colours.Tab.Inactive.Down			= GWEN.TextureColor( 4 + 8 * 6, 500 );
SKIN.Colours.Tab.Inactive.Disabled		= GWEN.TextureColor( 4 + 8 * 7, 500 );

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default				= GWEN.TextureColor( 4 + 8 * 8, 508 );
SKIN.Colours.Label.Bright				= GWEN.TextureColor( 4 + 8 * 9, 508 );
SKIN.Colours.Label.Dark					= GWEN.TextureColor( 4 + 8 * 8, 500 );
SKIN.Colours.Label.Highlight			= GWEN.TextureColor( 4 + 8 * 9, 500 );

SKIN.Colours.Tree = {}
SKIN.Colours.Tree.Lines					= GWEN.TextureColor( 4 + 8 * 10, 508 );		---- !!!
SKIN.Colours.Tree.Normal				= GWEN.TextureColor( 4 + 8 * 11, 508 );
SKIN.Colours.Tree.Hover					= GWEN.TextureColor( 4 + 8 * 10, 500 );
SKIN.Colours.Tree.Selected				= GWEN.TextureColor( 4 + 8 * 11, 500 );

SKIN.Colours.Properties = {}
SKIN.Colours.Properties.Line_Normal			= GWEN.TextureColor( 4 + 8 * 12, 508 );
SKIN.Colours.Properties.Line_Selected		= GWEN.TextureColor( 4 + 8 * 13, 508 );
SKIN.Colours.Properties.Line_Hover			= GWEN.TextureColor( 4 + 8 * 12, 500 );
SKIN.Colours.Properties.Title				= GWEN.TextureColor( 4 + 8 * 13, 500 );
SKIN.Colours.Properties.Column_Normal		= GWEN.TextureColor( 4 + 8 * 14, 508 );
SKIN.Colours.Properties.Column_Selected		= GWEN.TextureColor( 4 + 8 * 15, 508 );
SKIN.Colours.Properties.Column_Hover		= GWEN.TextureColor( 4 + 8 * 14, 500 );
SKIN.Colours.Properties.Border				= GWEN.TextureColor( 4 + 8 * 15, 500 );
SKIN.Colours.Properties.Label_Normal		= GWEN.TextureColor( 4 + 8 * 16, 508 );
SKIN.Colours.Properties.Label_Selected		= GWEN.TextureColor( 4 + 8 * 17, 508 );
SKIN.Colours.Properties.Label_Hover			= GWEN.TextureColor( 4 + 8 * 16, 500 );

SKIN.Colours.Category = {}
SKIN.Colours.Category.Header				= GWEN.TextureColor( 4 + 8 * 18, 500 );
SKIN.Colours.Category.Header_Closed			= GWEN.TextureColor( 4 + 8 * 19, 500 );
SKIN.Colours.Category.Line = {}
SKIN.Colours.Category.Line.Text				= GWEN.TextureColor( 4 + 8 * 20, 508 );
SKIN.Colours.Category.Line.Text_Hover		= GWEN.TextureColor( 4 + 8 * 21, 508 );
SKIN.Colours.Category.Line.Text_Selected	= GWEN.TextureColor( 4 + 8 * 20, 500 );
SKIN.Colours.Category.Line.Button			= GWEN.TextureColor( 4 + 8 * 21, 500 );
SKIN.Colours.Category.Line.Button_Hover		= GWEN.TextureColor( 4 + 8 * 22, 508 );
SKIN.Colours.Category.Line.Button_Selected	= GWEN.TextureColor( 4 + 8 * 23, 508 );
SKIN.Colours.Category.LineAlt = {}
SKIN.Colours.Category.LineAlt.Text				= GWEN.TextureColor( 4 + 8 * 22, 500 );
SKIN.Colours.Category.LineAlt.Text_Hover		= GWEN.TextureColor( 4 + 8 * 23, 500 );
SKIN.Colours.Category.LineAlt.Text_Selected		= GWEN.TextureColor( 4 + 8 * 24, 508 );
SKIN.Colours.Category.LineAlt.Button			= GWEN.TextureColor( 4 + 8 * 25, 508 );
SKIN.Colours.Category.LineAlt.Button_Hover		= GWEN.TextureColor( 4 + 8 * 24, 500 );
SKIN.Colours.Category.LineAlt.Button_Selected	= GWEN.TextureColor( 4 + 8 * 25, 500 );

SKIN.Colours.TooltipText	= GWEN.TextureColor( 4 + 8 * 26, 500 );


function SKIN:DrawGenericBackground( x, y, w, h, color )
	draw.RoundedBox( 8, x, y, w, h, color )
end

--[[---------------------------------------------------------
	Panel
-----------------------------------------------------------]]
function SKIN:PaintPanel( panel, w, h )

	if ( !panel.m_bBackground ) then return end	
	self.tex.Panels.Normal( 0, 0, w, h, panel.m_bgColor );

end

--[[---------------------------------------------------------
	Panel
-----------------------------------------------------------]]
function SKIN:PaintShadow( panel, w, h )

	SKIN.tex.Shadow( 0, 0, w, h );

end

--[[---------------------------------------------------------
	Frame
-----------------------------------------------------------]]
function SKIN:PaintFrame( panel, w, h )

	
	if ( panel.m_bPaintShadow ) then
	
		DisableClipping( true )
		SKIN.tex.Shadow( -4, -4, w+10, h+10 );
		DisableClipping( false )
	
	end
	
	if ( panel:HasHierarchicalFocus() ) then
	
		self.tex.Window.Normal( 0, 0, w, h );
		
	else
	
		self.tex.Window.Inactive( 0, 0, w, h );
		
	end

end

/*---------------------------------------------------------
   Chat
---------------------------------------------------------*/
function SKIN:PaintChat( panel )
	self:DrawGenericBackground( 0, 0, panel:GetWide(), panel:GetTall(), self.bg_color_chat )
end

--[[---------------------------------------------------------
	Button
-----------------------------------------------------------]]
/*function SKIN:PaintButton( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	if ( panel.Depressed || panel:IsSelected() || panel:GetToggle() ) then
		return self.tex.Button_Down( 0, 0, w, h );	
	end	
	
	if ( panel:GetDisabled() ) then
		return self.tex.Button_Dead( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Button_Hovered( 0, 0, w, h );	
	end
			
	self.tex.Button( 0, 0, w, h );

end*/

function SKIN:PaintButton( panel, w, h )

	panel:SetTextColor( Color( 255, 255, 255 ) )

	if ( panel.m_bBackground ) then

		if ( panel:GetDisabled() ) then

			draw.RoundedBox( 2, 0, 0, w, h, self.control_color_dark )

		elseif ( panel.Depressed ) then

			draw.RoundedBox( 2, 0, 0, w, h, self.control_color_dark )

		elseif ( panel.Hovered ) then

			draw.RoundedBox( 2, 0, 0, w, h, Color( 15 + 30, 78 + 30, 132 + 30 ) )

		else

			draw.RoundedBox( 2, 0, 0, w, h, self.control_color )

		end

	end

end

function SKIN:DrawButtonBorder( x, y, w, h, depressed )

	surface.SetDrawColor( self.colButtonBorder )
	surface.DrawOutlinedRect( x, y, w, h )

end

function SKIN:PaintOverButton( panel )
	return false
end


--[[---------------------------------------------------------
	Tree
-----------------------------------------------------------]]
function SKIN:PaintTree( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	//self.tex.Tree( 0, 0, w, h, panel.m_bgColor );

end

--[[---------------------------------------------------------
   NewMessage
-----------------------------------------------------------]]
function SKIN:PaintNewMessage( panel )
	local Wide, Tall = panel:GetWide(), panel:GetTall()
    	local col = self.panel_transback
	surface.SetDrawColor( col.r, col.g, col.b, panel.Alpha )
	surface.DrawRect( 0,0, Wide, Tall )
    
	surface.SetFont("small")
	col = self.text_highlight
	surface.SetTextColor( col.r, col.g, col.b, math.Clamp( panel.Alpha * 2.5 , 128, 255 ) )
	
	local Height = 0
	
	for k, v in pairs( panel.Text ) do
		local w, h = surface.GetTextSize( v )
        
        surface.SetTextPos( panel.TextXPos, Height + panel.TextStartY )
		surface.DrawText( v )
		
		Height = Height + h + 2
	end
	col = self.progressbar_color
	surface.SetDrawColor( col.r, col.g, col.b, panel.Alpha )
    
	if self.Timeleft == nil then
		surface.DrawRect( 2, Tall - 3 , (Wide - 4) * ( (panel.DieTime - CurTime()) / panel.Duration ), 2 )
	else
		surface.DrawRect( 2, Tall - 3 , (Wide - 4) * ( panel.Timeleft / panel.Duration ), 2 )
	end
end

--[[---------------------------------------------------------
	CheckBox
-----------------------------------------------------------]]
function SKIN:PaintCheckBox( panel, w, h )

	if ( panel:GetChecked() ) then
	
		if ( panel:GetDisabled() ) then
			self.tex.CheckboxD_Checked( 0, 0, w, h )
		else
			self.tex.Checkbox_Checked( 0, 0, w, h )
		end
		
	else
	
		if ( panel:GetDisabled() ) then
			self.tex.CheckboxD( 0, 0, w, h )
		else
			self.tex.Checkbox( 0, 0, w, h )
		end
		
	end	

end

--[[---------------------------------------------------------
	ExpandButton
-----------------------------------------------------------]]
function SKIN:PaintExpandButton( panel, w, h )

	if ( !panel:GetExpanded() ) then 
		self.tex.TreePlus( 0, 0, w, h )
	else 
		self.tex.TreeMinus( 0, 0, w, h )	
	end	

end

--[[---------------------------------------------------------
	TextEntry
-----------------------------------------------------------]]
function SKIN:PaintTextEntry( panel, w, h )

	if ( panel.m_bBackground ) then
	
		/*if ( panel:GetDisabled() ) then
			self.tex.TextBox_Disabled( 0, 0, w, h )
		elseif ( panel:HasFocus() ) then
			self.tex.TextBox_Focus( 0, 0, w, h )
		else*/
			self.tex.TextBox( 0, 0, w, h )
		//end
	
	end
	
	panel:DrawTextEntryText( panel.m_colText, panel.m_colHighlight, panel.m_colCursor )
	
end

function SKIN:SchemeTextEntry( panel ) ---------------------- TODO
	
	panel:SetTextColor( self.colTextEntryText )
	panel:SetHighlightColor( self.colTextEntryTextHighlight )
	panel:SetCursorColor( Color( 0, 0, 100, 255 ) )

end

--[[---------------------------------------------------------
	Menu
-----------------------------------------------------------]]
function SKIN:PaintMenu( panel, w, h )

	draw.RoundedBox( 8, 0, 0, w, h, self.colMenuBG )

	/*if ( panel:GetDrawColumn() ) then
		self.tex.MenuBG_Column( 0, 0, w, h )
	else
		self.tex.MenuBG( 0, 0, w, h )
	end*/
	
end

function SKIN:PaintOverMenu( panel )
	draw.RoundedBox( 8, 0, 0, w, h, self.colMenuBorder )
end

/*---------------------------------------------------------
   Scoreboard
---------------------------------------------------------*/
function SKIN:PaintScoreboard( panel )

	local color = self.bg_color
	self:DrawGenericBackground( 0, 40, panel:GetWide(), panel:GetTall() - 40, color )

end

/*---------------------------------------------------------
   ScoreboardItem
---------------------------------------------------------*/
function SKIN:PaintScoreboardItem( panel )
	surface.SetDrawColor(255,255,255,255)

	surface.SetTexture( panel.MiddleTexture ) 
	surface.DrawTexturedRect( panel.MiddlePosStart, 0, panel.MiddleWidth, 64 )
    
	if panel.IsFirst then
        surface.SetTexture( panel.LeftTexture )
        surface.DrawTexturedRect( 0, 0, 16, 64 )
	end
    
	if panel.IsLast then
        surface.SetTexture( panel.RightTexture )
        surface.DrawTexturedRect( panel.RightPos, 0, 16, 64 )
	end
    
    surface.SetFont(self.fontItem)

	local col = self.text_highlight
	local alpha = math.Clamp( CurTime() - panel.HoverTime, 0.0, 0.7 )
    
	if panel:IsSelected() then 
		surface.SetTextColor( self.text_shadow.r, self.text_shadow.g, self.text_shadow.b, self.text_shadow.a )
		surface.SetTextPos( panel.TextX + 1, panel.TextY + 2 )
		surface.DrawText( panel.Text )
	end
	
	if !panel:IsSelected() && !panel.Hovered then
		alpha = 0.7 - alpha
	end
	
	surface.SetTextColor( col.r, col.g, col.b, (alpha+0.3) * 255 )
	
    
	surface.SetTextPos( panel.TextX, panel.TextY )
	surface.DrawText( panel.Text )
end

/*---------------------------------------------------------
   ScoreboardHeader
---------------------------------------------------------*/
function SKIN:PaintScoreboardHeaderItem( panel )
	local col = self.bg_color_dark
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
    
	surface.DrawRect( 3,0, panel:GetWide() - 6, 23 )
end

/*---------------------------------------------------------
   ScoreboardListItem
---------------------------------------------------------*/
function SKIN:PaintScoreboardListItem( panel )
	local col = self.bg_alt1
	if panel.Alt then col = self.bg_alt2 end
	surface.SetDrawColor( col.r, col.g, col.b, col.a )

	surface.DrawRect( 0,0, panel:GetWide(), panel:GetTall() )
end

/*---------------------------------------------------------
   Contect menu when you click on players
---------------------------------------------------------*/
function SKIN:PaintClientMenuMain( panel )
	
	local col = self.bg_color
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
end
function SKIN:PaintClientMenuTitle( panel )
	
	local col = self.bg_color_dark
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
	
	surface.SetTextColor( 255, 255, 255, 255 )
end
local MenuIconBack = surface.GetTextureID("menu/item_icon_back")
function SKIN:PaintClientMenuItem( panel )
	local col = self.bg_alt1
	
	if panel.Hovered || panel.SubMenu != nil then 
		col = self.bg_alt2 
	end
	
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
	
	//SetDrawColor( (self.Hovered || self.SubMenu != nil) and HoveredColor or UnHovered
    surface.DrawRect( 0,0, panel:GetWide(), panel:GetTall() )
    
	local CheckEnabled = panel:CheckEnabled()
	
	if CheckEnabled == nil then
		col = self.colTabShadow
		surface.SetDrawColor( col.r, col.g, col.b, col.a )
	elseif CheckEnabled == false then
		surface.SetDrawColor( 160, 30, 30, 100 )
	else
		surface.SetDrawColor( 30, 160, 30, 100 )
	end
	
    surface.SetTexture( MenuIconBack )
    surface.DrawTexturedRect( 0, 0, 32, 32 )
    
    
    surface.SetFont("small")
    surface.SetTextColor( 255, 255, 255, 255 )
    surface.SetTextPos( panel.TextX, panel.TextY )
    surface.DrawText( panel.Text )
end
function SKIN:PaintClientMenuClose( panel )
	 local col = self.control_color_dark 
	 
	 if panel.Hovered then
		col = self.control_color_active
    end
	
	 surface.SetDrawColor( col.r, col.g, col.b, 250 )
	
end

--[[---------------------------------------------------------
	Menu
-----------------------------------------------------------]]
function SKIN:PaintMenuSpacer( panel, w, h )

	self.tex.MenuBG( 0, 0, w, h )
	
end

--[[---------------------------------------------------------
	MenuOption
-----------------------------------------------------------]]
function SKIN:PaintMenuOption( panel, w, h )

	if ( panel.m_bBackground && (panel.Hovered || panel.Highlight) ) then
		self.tex.MenuBG_Hover( 0, 0, w, h )
	end
	
	if ( panel:GetChecked() ) then
		self.tex.Menu_Check( 5, h/2-7, 15, 15 )
	end
	
end

--[[---------------------------------------------------------
	MenuRightArrow
-----------------------------------------------------------]]
function SKIN:PaintMenuRightArrow( panel, w, h )
	
	self.tex.Menu.RightArrow( 0, 0, w, h );

end

--[[---------------------------------------------------------
	PropertySheet
-----------------------------------------------------------]]
function SKIN:PaintPropertySheet( panel, w, h )

	-- TODO: Tabs at bottom, left, right

	local ActiveTab = panel:GetActiveTab()
	local Offset = 0
	if ( ActiveTab ) then Offset = ActiveTab:GetTall()-8 end
	
	self.tex.Tab_Control( 0, Offset, w, h-Offset )
	
end

--[[---------------------------------------------------------
	Tab
-----------------------------------------------------------]]
function SKIN:PaintTab( panel, w, h )

	//panel:SetTextColor( 255, 255, 255 )

	if ( panel:GetPropertySheet():GetActiveTab() == panel ) then
		return self:PaintActiveTab( panel, w, h )
	end
	
	self.tex.TabT_Inactive( 0, 0, w, h )
	
end

function SKIN:PaintActiveTab( panel, w, h )

	self.tex.TabT_Active( 0, 0, w, h )
	
end

--[[---------------------------------------------------------
	Button
-----------------------------------------------------------]]
function SKIN:PaintWindowCloseButton( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	if ( panel:GetDisabled() ) then
		return self.tex.Window.Close( 0, 0, w, h, Color( 255, 255, 255, 50 ) );	
	end	
	
	if ( panel.Depressed || panel:IsSelected() ) then
		return self.tex.Window.Close_Down( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Window.Close_Hover( 0, 0, w, h );	
	end
			
	self.tex.Window.Close( 0, 0, w, h );

end

function SKIN:PaintWindowMinimizeButton( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	if ( panel:GetDisabled() ) then
		return self.tex.Window.Mini( 0, 0, w, h, Color( 255, 255, 255, 50 ) );	
	end	
	
	if ( panel.Depressed || panel:IsSelected() ) then
		return self.tex.Window.Mini_Down( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Window.Mini_Hover( 0, 0, w, h );	
	end
			
	self.tex.Window.Mini( 0, 0, w, h );

end

function SKIN:PaintWindowMaximizeButton( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	if ( panel:GetDisabled() ) then
		return self.tex.Window.Maxi( 0, 0, w, h, Color( 255, 255, 255, 50 ) );	
	end	
	
	if ( panel.Depressed || panel:IsSelected() ) then
		return self.tex.Window.Maxi_Down( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Window.Maxi_Hover( 0, 0, w, h );	
	end
			
	self.tex.Window.Maxi( 0, 0, w, h );

end

--[[---------------------------------------------------------
	VScrollBar
-----------------------------------------------------------]]
function SKIN:PaintVScrollBar( panel, w, h )

	//surface.SetDrawColor( self.bg_color.r, self.bg_color.g, self.bg_color.b, self.bg_color.a )
	//surface.DrawRect( 0, 0, w, h )

	self.tex.Scroller.TrackV( 0, 0, w, h );	

end

function SKIN:LayoutVScrollBar( panel )

	/*panel:SetPos( panel:GetParent():GetWide() - 12, 0 )
	panel:SetSize( 12, panel:GetParent():GetTall() )*/
	
	local Wide = panel:GetWide()
	local Scroll = panel:GetScroll() / panel.CanvasSize
	local BarSize = math.max( panel:BarScale() * panel:GetTall(), 10 )
	local Track = panel:GetTall() - BarSize
	Track = Track + 1
	
	Scroll = Scroll * Track
	
	panel.btnGrip:SetPos( 0, math.Clamp( Scroll, Scroll, Track ) )
	panel.btnGrip:SetSize( Wide, BarSize )

	panel.btnUp:SetSize( 0, 0 )
	panel.btnUp:SetVisible( false )

	panel.btnDown:SetSize( 0, 0 )
	panel.btnDown:SetVisible( false )
	
	/*panel.btnUp:SetPos( 0, 0, Wide, Wide )
	panel.btnUp:SetSize( Wide, Wide )
	
	panel.btnDown:SetPos( 0, panel:GetTall() - Wide, Wide, Wide )
	panel.btnDown:SetSize( Wide, Wide )*/

end

--[[---------------------------------------------------------
	ScrollBarGrip
-----------------------------------------------------------]]
function SKIN:PaintScrollBarGrip( panel, w, h )

	//draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall(), Color( self.control_color.r, self.control_color.g, self.control_color.b, self.control_color.a ) )

	if ( panel:GetDisabled() ) then
		return self.tex.Scroller.ButtonV_Disabled( 0, 0, w, h );	
	end
	
	if ( panel.Depressed ) then
		return self.tex.Scroller.ButtonV_Down( 0, 0, w, h );	
	end
	
	if ( panel.Hovered ) then
		return self.tex.Scroller.ButtonV_Hover( 0, 0, w, h );	
	end
		
	return self.tex.Scroller.ButtonV_Normal( 0, 0, w, h );

end

--[[---------------------------------------------------------
	ButtonDown
-----------------------------------------------------------]]
function SKIN:PaintButtonDown( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	if ( panel.Depressed || panel:IsSelected() ) then
		return self.tex.Scroller.DownButton_Down( 0, 0, w, h );	
	end	
	
	if ( panel:GetDisabled() ) then
		return self.tex.Scroller.DownButton_Dead( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Scroller.DownButton_Hover( 0, 0, w, h );	
	end
			
	self.tex.Scroller.DownButton_Normal( 0, 0, w, h );

end

--[[---------------------------------------------------------
	ButtonUp
-----------------------------------------------------------]]
function SKIN:PaintButtonUp( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	if ( panel.Depressed || panel:IsSelected() ) then
		return self.tex.Scroller.UpButton_Down( 0, 0, w, h );	
	end	
	
	if ( panel:GetDisabled() ) then
		return self.tex.Scroller.UpButton_Dead( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Scroller.UpButton_Hover( 0, 0, w, h );	
	end
			
	self.tex.Scroller.UpButton_Normal( 0, 0, w, h );

end

--[[---------------------------------------------------------
	ButtonLeft
-----------------------------------------------------------]]
function SKIN:PaintButtonLeft( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	if ( panel.Depressed || panel:IsSelected() ) then
		return self.tex.Scroller.LeftButton_Down( 0, 0, w, h );	
	end	
	
	if ( panel:GetDisabled() ) then
		return self.tex.Scroller.LeftButton_Dead( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Scroller.LeftButton_Hover( 0, 0, w, h );	
	end
			
	self.tex.Scroller.LeftButton_Normal( 0, 0, w, h );

end

--[[---------------------------------------------------------
	ButtonRight
-----------------------------------------------------------]]
function SKIN:PaintButtonRight( panel, w, h )

	if ( !panel.m_bBackground ) then return end
	
	if ( panel.Depressed || panel:IsSelected() ) then
		return self.tex.Scroller.RightButton_Down( 0, 0, w, h );	
	end	
	
	if ( panel:GetDisabled() ) then
		return self.tex.Scroller.RightButton_Dead( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Scroller.RightButton_Hover( 0, 0, w, h );	
	end
			
	self.tex.Scroller.RightButton_Normal( 0, 0, w, h );

end


--[[---------------------------------------------------------
	ComboDownArrow
-----------------------------------------------------------]]
function SKIN:PaintComboDownArrow( panel, w, h )

	if ( panel.ComboBox:GetDisabled() ) then
		return self.Input.ComboBox.Button.Disabled( 0, 0, w, h );	
	end	
	
	if ( panel.ComboBox.Depressed || panel.ComboBox:IsMenuOpen() ) then
		return self.tex.Input.ComboBox.Button.Down( 0, 0, w, h );	
	end	
	
	if ( panel.ComboBox.Hovered ) then
		return self.tex.Input.ComboBox.Button.Hover( 0, 0, w, h );	
	end
			
	self.tex.Input.ComboBox.Button.Normal( 0, 0, w, h );

end

--[[---------------------------------------------------------
	ComboBox
-----------------------------------------------------------]]
function SKIN:PaintComboBox( panel, w, h )
	
	if ( panel:GetDisabled() ) then
		return self.Input.ComboBox.Disabled( 0, 0, w, h );	
	end	
	
	if ( panel.Depressed || panel:IsMenuOpen() ) then
		return self.tex.Input.ComboBox.Down( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Input.ComboBox.Hover( 0, 0, w, h );	
	end
			
	self.tex.Input.ComboBox.Normal( 0, 0, w, h );
	
end

--[[---------------------------------------------------------
	ComboBox
-----------------------------------------------------------]]
function SKIN:PaintListBox( panel, w, h )
	
	self.tex.Input.ListBox.Background( 0, 0, w, h );
	
end

--[[---------------------------------------------------------
	NumberUp
-----------------------------------------------------------]]
function SKIN:PaintNumberUp( panel, w, h )

	if ( panel:GetDisabled() ) then
		return self.Input.UpDown.Up.Disabled( 0, 0, w, h );	
	end	
	
	if ( panel.Depressed ) then
		return self.tex.Input.UpDown.Up.Down( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Input.UpDown.Up.Hover( 0, 0, w, h );	
	end
			
	self.tex.Input.UpDown.Up.Normal( 0, 0, w, h );
	
end
		
--[[---------------------------------------------------------
	NumberDown
-----------------------------------------------------------]]
function SKIN:PaintNumberDown( panel, w, h )

	if ( panel:GetDisabled() ) then
		return self.tex.Input.UpDown.Down.Disabled( 0, 0, w, h );	
	end	
	
	if ( panel.Depressed ) then
		return self.tex.Input.UpDown.Down.Down( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Input.UpDown.Down.Hover( 0, 0, w, h );	
	end
			
	self.tex.Input.UpDown.Down.Normal( 0, 0, w, h );
	
end

function SKIN:PaintTreeNode( panel, w, h )

	if ( !panel.m_bDrawLines ) then return end
	
	surface.SetDrawColor( self.Colours.Tree.Lines )
	
	if ( panel.m_bLastChild ) then
	
			surface.DrawRect( 9, 					0,		1, 	7 )
			surface.DrawRect( 9, 					7,		9, 	1 )
	
	else
			surface.DrawRect( 9, 					0,		1, 	h )
			surface.DrawRect( 9, 					7,		9, 	1 )
	end

end


function SKIN:PaintTreeNodeButton( panel, w, h )

	if ( !panel.m_bSelected ) then return end
	
	-- Don't worry this isn't working out the size every render
	-- it just gets the cached value from inside the Label
	local w, _ = panel:GetTextSize() 
	
	self.tex.Selection( 38, 0, w+6, h );

end

function SKIN:PaintSelection( panel, w, h )

	self.tex.Selection( 0, 0, w, h );

end

function SKIN:PaintSliderKnob( panel, w, h )

	if ( panel:GetDisabled() ) then	return self.tex.Input.Slider.H.Disabled( 0, 0, w, h ); end	
	
	if ( panel.Depressed ) then
		return self.tex.Input.Slider.H.Down( 0, 0, w, h );	
	end	
	
	if ( panel.Hovered ) then
		return self.tex.Input.Slider.H.Hover( 0, 0, w, h );	
	end
			
	self.tex.Input.Slider.H.Normal( 0, 0, w, h );

end

local function PaintNotches( x, y, w, h, num )

	if ( !num ) then return end

	local space = w / num
	
	for i=0, num do
	
		surface.DrawRect( x + i * space, y+4,	1,  5 )
	
	end

end

function SKIN:PaintNumSlider( panel, w, h )

	self:DrawGenericBackground( 0, 0, w, h, self.colCollapsibleCategory )
	surface.SetDrawColor( Color( 0, 0, 0, 100 ) )
	surface.DrawRect( 8, h/2-1,		w-15,  1 )
	
	PaintNotches( 8, h/2-1,		w-16,  1, panel.m_iNotches )

end

function SKIN:PaintProgress( panel, w, h )

	self.tex.ProgressBar.Back( 0, 0, w, h );
	self.tex.ProgressBar.Front( 0, 0, w * panel:GetFraction(), h );

end


function SKIN:PaintCategoryList( panel, w, h )

	self.tex.CategoryList.Outer( 0, 0, w, h );

end

function SKIN:PaintCategoryButton( panel, w, h )

	if ( panel.AltLine ) then

		if ( panel.Depressed || panel.m_bSelected ) then surface.SetDrawColor( self.Colours.Category.LineAlt.Button_Selected );
		elseif ( panel.Hovered ) then surface.SetDrawColor( self.Colours.Category.LineAlt.Button_Hover );
		else surface.SetDrawColor( self.Colours.Category.LineAlt.Button ); end
	
	else
	
		if ( panel.Depressed || panel.m_bSelected ) then surface.SetDrawColor( self.Colours.Category.Line.Button_Selected );
		elseif ( panel.Hovered ) then surface.SetDrawColor( self.Colours.Category.Line.Button_Hover );
		else surface.SetDrawColor( self.Colours.Category.Line.Button ); end
		
	end

	surface.DrawRect( 0, 0, w, h );

end

function SKIN:PaintListViewLine( panel, w, h )

	if ( panel:IsSelected() ) then

		self.tex.Input.ListBox.EvenLineSelected( 0, 0, w, h );
	 
	elseif ( panel.Hovered ) then

		self.tex.Input.ListBox.Hovered( 0, 0, w, h );
	 
	elseif ( panel.m_bAlt ) then

		self.tex.Input.ListBox.EvenLine( 0, 0, w, h );
	         
	end

	/*local Col = nil
	
	if ( panel:IsSelected() ) then
		Col = self.listview_selected
	elseif ( panel.Hovered ) then
		Col = self.listview_hover
	elseif ( panel.m_bAlt ) then
		Col = self.bg_alt2
		
	else
		return
	end
		
	surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
	surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() )*/

end

function SKIN:PaintListView( panel, w, h )

	self.tex.Input.ListBox.Background( 0, 0, w, h )

	/*if ( panel.m_bBackground ) then
		//surface.SetDrawColor( 45, 125, 175, 255 )
		//panel:DrawFilledRect()
	end*/

end

function SKIN:PaintTooltip( panel, w, h )

	self.tex.Tooltip( 0, 0, w, h )

end

function SKIN:PaintMenuBar( panel, w, h )

	self.tex.Menu_Strip( 0, 0, w, h )

end





// this needs to be at the bottom
derma.DefineSkin( "gmtower", SKIN.PrintName, SKIN )

function GM:ForceDermaSkin() return "gmtower" end

// in the chance that the above is being bypassed
local gtowerskin = derma.GetNamedSkin("gmtower")
function derma.GetDefaultSkin() return gtowerskin end
function derma.GetNamedSkin() return gtowerskin end 