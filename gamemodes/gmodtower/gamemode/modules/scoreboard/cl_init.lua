
module("Scoreboard", package.seeall )

function SinBetween( min, max, time )

    local diff = max - min
    local remain = max - diff

    return ( ( ( math.sin( time ) + 1 ) / 2 ) * diff ) + remain

end

function CosBetween( min, max, time )

    local diff = max - min
    local remain = max - diff

    return ( ( ( math.cos( time ) + 1 ) / 2 ) * diff ) + remain

end

function ActionBoxLabel( panel, icon, label, valuefunc, clickfunc )

	local item = panel:CreateItem()
	local ply = panel:GetPlayer()

	if icon then
		item:SetMaterial( icon, 16, 16, 16, 16 )
	end

	item:SetText( label )
	item:SetValue( valuefunc )

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

function GenTexture( textName, texture )

	return CreateMaterial( textName, "UnlitGeneric",
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
	if self && self:GetParent() && self:GetParent():GetParent() then
		self:GetParent():GetParent():OnMouseWheeled( dlta )
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

/**
	The scoreboard is responsible for managing the tabs, resizing, and always keeping in the center of the screen
*/
SCOREBOARD = {}
SCOREBOARD.TitleWidth = Scoreboard.Customization.HeaderWidth
SCOREBOARD.TitleHeight = Scoreboard.Customization.HeaderHeight

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
	
	if not game.GetGamemode == "deathrun" then
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
				"To Lobby #1", function() RunConsoleCommand("gmt_returntolobby") end,
				"To Lobby #2", function() RunConsoleCommand("gmt_returntolobby", 2) end,
				T("no"), nil
			)
		end
	end
	
	self.Resizer = vgui.Create( "GTowerResizer" )
	self.Resizer:SetZPos( 1 )
	self.Resizer:SetSettingName( "scoreboard_size" )
	self.Resizer:BothSides( true )
	self.Resizer.DefaultValue = ScrW() * 0.88
	self.Resizer:SetMinMax( 640, ScrW() * 0.9 )
	self.Resizer:OnChange( 
		function( value )
			if type( Gui ) == "Panel" then
				Gui:UpdateWide()
			end
		end
	)
	
	self:SetVisible( true )
	self:SetMouseInputEnabled( true )
	
	self.RightBorderSize = 16
	
	// Force these tabs because the automated methoed was borked
	
	// Add players tab (ALWAYS THERE)
	self.PlayerTab = vgui.Create( "ScoreboardPlayersTab" )
	self:AddTab( self.PlayerTab )
	
	self.AwardsTab = vgui.Create( "ScoreboardAwardsTab" )
	self:AddTab( self.AwardsTab )

	self.SettingsTab = vgui.Create( "ScoreboardSettingsTab" )
	self:AddTab( self.SettingsTab )
	
	self.AppTab = vgui.Create( "AppearancePlayersTab" )
	self:AddTab( self.AppTab )
	
	self.NewsTab = vgui.Create( "NewsTab" )
	self:AddTab( self.NewsTab )
	
	self.AboutTab = vgui.Create( "AboutTab" )
	self:AddTab( self.AboutTab )
	

	/*
		Look into the hook table for items to be added for the scoreboard
		Hook should return a panel that is inherited from the ScoreboardTab base class.
	*/
	
	--[[local items = hook.GetTable()["ScoreBoardItems"]

	for _, itemFunc in pairs( items ) do

		local success, tab = itemFunc 

		if success then

			--if tab.HideForGamemode && !IsLobby then
			--	tab:SetVisible( false )
			--else
				self:AddTab( tab )
			--end

		end

	end]]--
	
	//If there is anything on the scoreboard, set the selected one!
	if #self.Tabs > 0 then
		self:SetActiveTab( self.Tabs[1] )
	end

end

local gradient = surface.GetTextureID( "VGUI/gradient_up" )

function SCOREBOARD:Paint( w, h )

	self.RightBorderSize = 16

	surface.SetDrawColor( 255, 255, 255, 255 )
	
	surface.SetMaterial( Scoreboard.Customization.HeaderMatHeader )
	surface.DrawTexturedRect( 0, 0, self.TitleWidth, self.TitleHeight )
	
	surface.SetMaterial( Scoreboard.Customization.HeaderMatFiller )
	surface.DrawTexturedRect( self.TitleWidth, 0, self:GetWide() - self.RightBorderSize - self.TitleWidth, self.TitleHeight )
	
	surface.SetMaterial( Scoreboard.Customization.HeaderMatRightBorder )
	surface.DrawTexturedRect( self:GetWide() - self.RightBorderSize, 0, self.RightBorderSize, self.TitleHeight )
	
	//Render the background
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

	self:SetWide( cookie.GetNumber( "scoreboard_size" ) or ScrW() * 0.88 )
	self:InvalidateLayout()

end

function SCOREBOARD:PerformLayout()

	self:SetWide( cookie.GetNumber( "scoreboard_size" ) or ScrW() * 0.88 )
	
	self.RightBorderSize = 16

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
		body:SetPos( 0, self.TitleHeight + 1 )
		body:SetWide( self:GetWide() - 4 )
		body:CenterHorizontal()
	end

	local x, y = self:GetPos()
	local w, h = self:GetSize()

	if ValidPanel( self.MapName ) then
		self.MapName:SetPos( ( ( x + w ) - self.MapName:GetWide() ), ( y + ( h + 2 ) ) )
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
		
		targetHeight = targetHeight + body:GetTall() + 6
	end

	local diff = current - targetHeight
	local increaseAmount = math.ceil( math.abs( diff * .1 ) )

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
		self.ActiveTab:SetActive( false )
		local oldBody = self.ActiveTab:GetBody()
		
		oldBody:SetParent( nil )
		oldBody:SetVisible( false )
	end
	
	local newBody = tab:GetBody()
	
	self.ActiveTab = tab
	self.ActiveTab:SetActive( true )
	
	newBody:SetParent( self )
	newBody:SetVisible( true )
	
	self:InvalidateLayout()

end

vgui.Register( "ScoreBoard", SCOREBOARD )



local function MapNames()
	local map = game.GetMap()
	
	if map == "gmt_virus_riposte01" then
		return "Riposte"
	elseif map == "gmt_virus_facility202" or map == "gmt_virus_facility201" or map == "gmt_virus_facility01" then
		return "Facility"
	elseif map == "gmt_virus_hospital203" or map == "gmt_virus_hospital204" then
		return "HOSPITAL"
	elseif map == "gmt_virus_metaldream05" then
		return "Metal Dreams"
	elseif map == "gmt_virus_sewage01" then
		return "Sewage"
	elseif map == "gmt_virus_dust03" then
		return "Dust"
	elseif map == "gmt_virus_derelict01" then
		return "Derelict"
	elseif map == "gmt_virus_aztec01" then
		return "Aztec"
	end
	
	return
end

MAP = {}

function MAP:Init() end

local function GetNiceMapName( map )

	return MapNames() --game.GetMap() or nil --Maps.GetName( map ) or nil

end

function MAP:PerformLayout()

	local txt = GetNiceMapName( MapNames() )

	if !txt then self:SetVisible( false ) return end

	surface.SetFont( "GTowerHUDMainSmall" )
	local w, h = surface.GetTextSize( txt )

	self:SetSize( w * 1.62, h )

end

function MAP:Paint()

	local txt = GetNiceMapName( MapNames() )
	if !txt then return end
	
	local w, h = self:GetSize()
	draw.RoundedBox( 0, 0, 0, w, h, Color( 25, 25, 25, 100 ) )

	draw.NiceText( string.upper( MapNames() ), "GTowerHUDMainSmall", w * .5, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, 250 )

end

vgui.Register( "ScoreboardMap", MAP, "Panel" )


BLUR = {}

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

		if !Gui.Background then
			Gui.Background = vgui.Create( "Blur" )
			Gui.Background:SetPos( 0, 0 ) 
			Gui.Background:SetSize( ScrW(), ScrH() )
			Gui.Background:SetZPos( -1 )
		end

		if Gui.Resizer then
			Gui.Resizer:SetVisible( true )
		end
		
		if ValidPanel(Gui.ReturnButton) then
			Gui.ReturnButton:SetVisible( true )
		end
		
		if Gui.MapName then
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

		if Gui.Background then
			Gui.Background:SetVisible( false )
			Gui.Background = nil
		end

		if Gui.Resizer then
			Gui.Resizer:SetVisible( false )
		end
		
		if ValidPanel(Gui.ReturnButton) then
			Gui.ReturnButton:SetVisible( false )
		end

		if Gui.MapName then
			Gui.MapName:SetVisible( false )
		end

	end

	GTowerMenu:CloseAll()

	return true

end )


if ValidPanel( Gui ) then

	if ValidPanel( Gui.Resizer ) then Gui.Resizer:Remove() end
	if ValidPanel( Gui.MapName ) then Gui.MapName:Remove() end
	if ValidPanel( Gui.ReturnButton ) then Gui.ReturnButton:Remove() end
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