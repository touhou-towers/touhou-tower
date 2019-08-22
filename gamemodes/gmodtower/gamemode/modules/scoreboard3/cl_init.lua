

-----------------------------------------------------
module("Scoreboard", package.seeall )

MaxWidth = 900
MinWidth = 640

function ActionBoxLabel( panel, icon, label, valuefunc, clickfunc, fixedWidth )

	local item = panel:CreateItem( valuefunc )
	local ply = panel:GetPlayer()

	if icon then
		item:SetMaterial( icon, 16, 16, 16, 16 )
	end

	item:SetText( label )
	item:SetValue( valuefunc )
	if item.SetFixedWidth then
		item:SetFixedWidth( fixedWidth )
	end

	if clickfunc then

		item:SetMouseInputEnabled( true )
		item:SetCursor("hand")

		item.OnMousePressed = function( self )
			clickfunc( ply )
		end

	else

		item:SetMouseInputEnabled( false )
		item:SetCursor("default")

		item.IsLabel = true

	end

end

function GenTexture( textname, texture )

	return CreateMaterial( textname, "UnlitGeneric",
	{
		["$basetexture"] = Scoreboard.Customization.MatDirectory .. texture,
		["$ignorez"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$nolod"] = 1
	} )

end

function ParentMouseWheeled( self, dlta )

	// Insane...
	local parent = self:GetParent()
	if self && parent && parent:GetParent() then
		parent:GetParent():OnMouseWheeled( dlta )
	end

end

//include("shared.lua")
include( "cl_init_customize.lua" )
include( "cl_tabbase.lua" )
include( "cl_tabbase_inner.lua" )
include( "cl_scoreboard.lua" )
include( "cl_awards.lua" )
include( "cl_settings.lua" )
include( "cl_appearance.lua" )
include( "cl_news.lua" )
include( "cl_about.lua" )
include( "cl_payouts.lua" )
include( "cl_leaderboards.lua" )

/**
	The scoreboard is responsible for managing the tabs, resizing, and always keeping in the center of the screen
*/
SCOREBOARD = {}
SCOREBOARD.TitleWidth = Scoreboard.Customization.HeaderWidth
SCOREBOARD.TitleHeight = Scoreboard.Customization.HeaderHeight
SCOREBOARD.RightBorderSize = 0 //16

function SCOREBOARD:Init()

	self.Tabs = {}
	self.ActiveTab = nil

	if Scoreboard.Customization.HeaderTitle != "" then
		self.Title = Label( Scoreboard.Customization.HeaderTitle, self )
		self.Title:SetFont( Scoreboard.Customization.HeaderTitleFont )
		self.Title:SetTextColor( Scoreboard.Customization.HeaderTitleColor )
	end

	self:SetZPos( 2 )

	self.MapName = vgui.Create( "ScoreboardMap" )
	self.MapName:SetZPos( 1 )

	if not string.StartWith(game.GetMap(),"gmt_build") then
		self.ReturnButton = vgui.Create( "DButton" )
		self.ReturnButton:SetText("RETURN TO LOBBY")
		self.ReturnButton:SetFont( "GTowerHUDMainSmall" )
		self.ReturnButton:SetWide( 120 )
		self.ReturnButton:SetTextColor( Color( 255, 255, 255 ) )
		self.ReturnButton.Paint = function( panel, w, h )
			if panel:IsHovered() then
				surface.SetDrawColor( Color( 25, 25, 25, 240 ) )
			else
				surface.SetDrawColor( Color( 25, 25, 25, 150 ) )
			end
			surface.DrawRect( 0, 0, w, h )
		end
		self.ReturnButton.DoClick = function()
			Derma_Query( "Do you want to leave the gamemode and go back to the lobby?", "Back to Lobby",
				"Return to Lobby", function() RunConsoleCommand("gmt_returntolobby") end,
				"Cancel", nil
			)
		end
	end

	self.Resizer = vgui.Create( "GTowerResizer" )
	self.Resizer:SetZPos( 1 )
	self.Resizer:SetSettingName( "scoreboard_size" )
	self.Resizer:BothSides( true )
	self.Resizer.DefaultValue = MinWidth
	self.Resizer:SetMinMax( MinWidth, MaxWidth )
	self.Resizer:OnChange(
		function( value )
			if type( Gui ) == "Panel" then
				Gui:UpdateWide()
			end
		end
	)

	if not string.StartWith(game.GetMap(),"gmt_build") then
		self.GMCAmount = vgui.Create( "ScoreboardGMC" )
		self.GMCAmount:SetZPos( 1 )
		self.GMCAmount:SetVisible()
	end

	self:SetVisible( true )
	self:SetMouseInputEnabled( true )

	// Add players tab (ALWAYS THERE)
	self.PlayerTab = vgui.Create( "ScoreboardPlayersTab" )
	self:AddTab( self.PlayerTab )

	/*
		Look into the hook table for items to be added for the scoreboard
		Hook should return a panel that is inherited from the ScoreboardTab base class.
	*/
	local items = hook.GetTable()["ScoreBoardItems"]

	for _, itemFunc in pairs( items ) do

		local success, tab = SafeCall( itemFunc )

		if success then

			if tab.HideForGamemode && !string.StartWith(game.GetMap(),"gmt_build") then
				tab:SetVisible( false )
			elseif tab.OnlyForGamemode && string.StartWith(game.GetMap(),"gmt_build") then
				tab:SetVisible( false )
			else
				self:AddTab( tab )
			end

		end

	end

	//If there is anything on the scoreboard, set the selected one!
	if #self.Tabs > 0 then
		self:SetActiveTab( self.Tabs[1] )
	end

end

local gradient = surface.GetTextureID( "VGUI/gradient_up" )

function SCOREBOARD:Paint( w, h )

	surface.SetDrawColor( 255, 255, 255, 255 )

	surface.SetMaterial( Scoreboard.Customization.HeaderMatFiller )
	//surface.DrawTexturedRect( self.TitleWidth, 0, self:GetWide() - self.RightBorderSize - self.TitleWidth, self.TitleHeight )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self.TitleHeight )

	surface.SetMaterial( Scoreboard.Customization.HeaderMatHeader )
	surface.DrawTexturedRect( 0, 0, self.TitleWidth, self.TitleHeight )

	surface.SetMaterial( Scoreboard.Customization.HeaderMatRightBorder )
	surface.DrawTexturedRect( self:GetWide() - self.RightBorderSize, 0, self.RightBorderSize, self.TitleHeight )

	// Render the background
	surface.SetDrawColor( Scoreboard.Customization.ColorBackground )
	surface.DrawRect( 0, self.TitleHeight - 1, self:GetWide(), self:GetTall() - self.TitleHeight + 1 )


	surface.SetDrawColor( 0, 0, 0, 50 )
	surface.SetTexture( gradient )
	surface.DrawTexturedRect( 0, 0, self:GetSize() )

end

function SCOREBOARD:Think() end

function SCOREBOARD:AddTab( tab )

	table.insert( self.Tabs, tab )
	tab:SetParent( self )

end

function SCOREBOARD:UpdateWide()

	local wide = cookie.GetNumber( "scoreboard_size" )
	if not wide or wide > ScrW() then
		wide = MinWidth
	end

	if wide > MaxWidth then wide = MaxWidth end

	self:SetWide( wide )
	self:InvalidateLayout()

end

function SCOREBOARD:PerformLayout()

	self:UpdateWide()

	local position = self:GetWide() - self.RightBorderSize

	// Sort their order
	table.sort( self.Tabs, function( a, b )
		if a.Order == b.Order then
			return a:GetText() > b:GetText()
		end

		return a.Order > b.Order
	end )

	self.ShowTitle = true

	// Set their positions and size
	for _, tab in pairs( self.Tabs ) do
		tab:SetTall( self.TitleHeight )
		tab:InvalidateLayout( true )

		position = position - tab:GetWide()
		tab:SetPos( position, 0 )

		if self.Title then
			// See if we're hitting the title text
			local x, y = self.Title:GetPos()
			if position <= ( x + self.Title:GetWide() ) then
				self.ShowTitle = false
			end
		end
	end

	if self.Title then
		self.Title:SetVisible( self.ShowTitle ) // Hide for smaller resolutions
		self.Title:SizeToContents()
		self.Title:SetTall( self.TitleHeight )
		self.Title:AlignLeft( Scoreboard.Customization.HeaderTitleLeft )
	end

	// Layout active tab
	if ValidPanel( self.ActiveTab ) then
		local body, panel = self.ActiveTab:GetBody()
		//panel:InvalidateLayout( true )
		body:SetPos( 0, self.TitleHeight )
		body:SetWide( self:GetWide() )
		body:CenterHorizontal()
	end

	local x, y = self:GetPos()
	local w, h = self:GetSize()

	if ValidPanel( self.MapName ) then
		self.MapName:SetPos( ( ( x + w ) - self.MapName:GetWide() ), ( y + ( h + 2 ) ) )
	end

	if ValidPanel( self.GMCAmount ) then
		self.GMCAmount:CenterHorizontal()
		self.GMCAmount.y = ( y + ( h + 2 ) )
	end

	if ValidPanel( self.ReturnButton ) then
		self.ReturnButton:SetPos( x, ( y + ( h + 2 ) ) )
	end

	if ValidPanel( self.Resizer ) then
		self.Resizer:SetSize( w + 20, h )
		self.Resizer:SetPos( x - 10, y )
	end

end

function SCOREBOARD:Think()

	local current = self:GetTall()
	local targetHeight = self.TitleHeight

	// Resize for tab
	if ValidPanel( self.ActiveTab ) then
		local body, panel = self.ActiveTab:GetBody()

		body:SetTall( math.min( panel:GetTall(), ScrH() * 0.65 ) )

		targetHeight = targetHeight + body:GetTall() + 2
	end

	local diff = current - targetHeight
	local increaseAmount = math.ceil( math.abs( diff * .75 ) )

	self:SetTall( math.Approach( current, targetHeight, increaseAmount ) )
	//self:SetTall( math.Approach( current, targetHeight, math.max( math.abs( (current-targetHeight) * FrameTime() * 30 ) ), 1 ) )
	self:Center()


	/*local alpha = 255
	if self.Hide then
		alpha = 0
	end

	self.CurAlpha = math.Approach( self.CurAlpha, alpha, FrameTime() * 2500 )
	self:SetAlpha( self.CurAlpha )

	if self:IsVisible() && self.Hide && self.CurAlpha <= 0 then
		self:SetVisible( false )
	end*/

end

function SCOREBOARD:SetActiveTab( tab )

	if ValidPanel( self.ActiveTab ) then
		local oldBody = self.ActiveTab:GetBody()
		oldBody:SetParent( nil )
		oldBody:SetVisible( false )

		self.ActiveTab:SetActive( false )
	end

	local newBody = tab:GetBody()

	self.ActiveTab = tab
	self.ActiveTab:SetActive( true )

	newBody:SetParent( self )
	newBody:SetVisible( true )

	self:InvalidateLayout()

end

vgui.Register( "ScoreBoard", SCOREBOARD )


local MAP = {}

function MAP:Init() end

local function GetNiceMapName( map )
	if string.StartWith(game.GetMap(),"gmt_build") then
		map = "Lobby"
	end

	if string.StartWith(game.GetMap(),"gmt_lobby2") then
		map = "Lobby 2"
	end
	
	if game.GetMap() == "gmt_build0s2b" then
		map = "Summer Lobby"
	end

	if game.GetMap() == "gmt_build0s2" then
		map = "Spring Lobby"
	end
	
	if game.GetMap() == "gmt_build0c3a" then
		map = "Winter Lobby"
	end

	if game.GetMap() == "gmt_build0c3" then
		map = "Holiday Lobby"
	end
	
	if game.GetMap() == "gmt_build0h2" then
		map = "Halloween Lobby"
	end
	--return string.upper( Maps.GetName( map ) ) or nil
	return string.upper( map || game.GetMap() ) or nil

end

function MAP:PerformLayout()

	local txt = GetNiceMapName( game.GetMap() )

	if !txt then self:SetVisible( false ) return end

	surface.SetFont( "GTowerHUDMainSmall" )
	local w, h = surface.GetTextSize( txt )

	self:SetSize( w * 1.32, h )

end

function MAP:Paint( w, h )

	local txt = GetNiceMapName( game.GetMap() )
	if !txt then return end

	surface.SetDrawColor( Color( 25, 25, 25, 100 ) )
	surface.DrawRect( 0, 0, w, h )

	/*if string.StartWith(game.GetMap(),"gmt_build") then
		txt = txt .. " #" .. tostring(LocalPlayer()._ServerID)
	end*/

	draw.NiceText( txt, "GTowerHUDMainSmall", w * .5, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 250 )

end

vgui.Register( "ScoreboardMap", MAP, "Panel" )


local GMC = {}
GMC.MoneyIcon = Material( "gmod_tower/scoreboard/icon_money.png", "unlitsmooth" )
GMC.Padding = 8

function GMC:Init() end

function GMC:PerformLayout()

	surface.SetFont( "GTowerHUDMain" )
	local w, h = surface.GetTextSize( string.FormatNumber( Money() or 0 ) )

	self:SetSize( w + self.Padding + 16 + 1, h )

end

function GMC:Paint( w, h )

	surface.SetDrawColor( Color( 25, 25, 25, 100 ) )
	surface.DrawRect( 0, 0, w, h )

	surface.SetMaterial( self.MoneyIcon )
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawTexturedRect( 2, 4, 16, 16 )

	draw.NiceText( string.FormatNumber( Money() or 0 ), "GTowerHUDMain", 16 + (self.Padding/2), 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 250 )

end

vgui.Register( "ScoreboardGMC", GMC, "Panel" )


local BLUR = {}

local matBlurScreen = Material( "pp/blurscreen" )
local bBlurEnabled = CreateClientConVar( "gmt_scoreboard_blur", "0", true, false )
local fBlurAmount = CreateClientConVar( "gmt_scoreboard_blur_amount", "3", true, false )

function BLUR:Paint( w, h )

	// Blur background
	if bBlurEnabled:GetBool() then
		self:DrawBackgroundBlur()
	end

end

function BLUR:DrawBackgroundBlur()

	surface.SetMaterial( matBlurScreen )
	surface.SetDrawColor( 255, 255, 255, 150 )

	local blurAmount = 1 / math.Clamp( math.abs( fBlurAmount:GetFloat() ), 1, 10)
	local x, y = self:LocalToScreen( 0, 0 )

	for i = blurAmount, 1, blurAmount do

		matBlurScreen:SetFloat( "$blur", 5 * i )
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )

	end

end

vgui.Register( "Blur", BLUR )


hook.Add( "ScoreboardShow", "ShowGMTScoreboard", function( disableMouse )

	if !ValidPanel( Gui ) then
		Gui = vgui.Create("ScoreBoard")
	end

	if Gui && Gui.AlwaysOn then
		return true
	end

	Gui:InvalidateLayout()
	Gui:SetVisible( true )
	//Gui.CurAlpha = 0
	//Gui.Hide = false

	if Gui then

		if !ValidPanel(Gui.Background) then
			Gui.Background = vgui.Create( "Blur" )
			Gui.Background:SetPos( 0, 0 )
			Gui.Background:SetSize( ScrW(), ScrH() )
			Gui.Background:SetZPos( -1 )
		end

		if ValidPanel(Gui.Resizer) then
			Gui.Resizer:SetVisible( true )
		end

		if ValidPanel(Gui.GMCAmount) then
			Gui.GMCAmount:SetVisible( true )
		end

		if ValidPanel(Gui.ReturnButton) then
			Gui.ReturnButton:SetVisible( true )
		end

		if ValidPanel(Gui.MapName) then
			Gui.MapName:SetVisible( true )
		end

	end

	if Scoreboard.Customization.EnableMouse && !disableMouse then
		gui.EnableScreenClicker( true )
		RestoreCursorPosition()
	end

	return true

end )

hook.Add( "ScoreboardHide", "HideGMTScoreboard", function( disableMouse )

	if Gui && ValidPanel( Gui ) && Gui.AlwaysOn then
		return true
	end

	if ValidPanel( Gui ) then
		Gui:SetVisible( false )
		//Gui.Hide = true
	end

	if ValidPanel( Gui ) && Scoreboard.Customization.EnableMouse && !disableMouse then
		gui.EnableScreenClicker( false )
		RestoreCursorPosition()
	end

	if ValidPanel( Gui ) then

		if ValidPanel(Gui.Background) then
			Gui.Background:SetVisible( false )
			Gui.Background = nil
		end

		if ValidPanel(Gui.Resizer) then
			Gui.Resizer:SetVisible( false )
		end

		if ValidPanel(Gui.MapName) then
			Gui.MapName:SetVisible( false )
		end

		if ValidPanel(Gui.GMCAmount) then
			Gui.GMCAmount:SetVisible( false )
		end

		if ValidPanel(Gui.ReturnButton) then
			Gui.ReturnButton:SetVisible( false )
		end

	end

	GTowerMenu:CloseAll()
	if GTowerItems and GTowerItems.HideTooltip then GTowerItems:HideTooltip() end

	return true

end )


if ValidPanel( Gui ) then

	if ValidPanel( Gui.Resizer ) then Gui.Resizer:Remove() end
	if ValidPanel( Gui.MapName ) then Gui.MapName:Remove() end
	if ValidPanel( Gui.ReturnButton ) then Gui.ReturnButton:Remove() end
	if ValidPanel( Gui.GMCAmount ) then Gui.GMCAmount:Remove() end
	Gui:Remove()

end

concommand.Add( "gmt_showscores", function( ply, cmd, args )

	local enable = tobool( args[1] )

	if !enable then

		if ValidPanel( Gui ) then
			Gui.AlwaysOn = false
		end

		hook.Call( "ScoreboardHide", GAMEMODE, true )

	else

		timer.Simple( 3, function()

			hook.Call( "ScoreboardShow", GAMEMODE, true )

			if ValidPanel( Gui ) then
				Gui:SetActiveTab( Gui.PlayerTab )
				Gui.AlwaysOn = false //true
			end

		end )

	end

end )
