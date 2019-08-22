
module( "Scoreboard.Settings", package.seeall )

// TAB

hook.Add( "ScoreBoardItems", "Settings", function()
	return vgui.Create( "ScoreboardSettingsTab" )
end )

TAB = {}
TAB.Order = 3

function TAB:GetText()
	return "SETTINGS"
end

/*function TAB:OnOpen()
	if ValidPanel( self.Body ) then
		self.Body:Create()
	end
end*/

function TAB:CreateBody()
	return vgui.Create("ScoreBoardSettings", self )
end

vgui.Register( "ScoreboardSettingsTab", TAB, "ScoreboardTab" )

// SETTINGS

SETTINGS = {}

function SETTINGS:NewCategory( Name, id )

	local Category = vgui.Create( "ScoreboardSettingsCategory", self)
	Category:SetLabel( Name )
	Category:SetPos( 0, 10 )
	Category.OnMouseWheeled = function( Category, dlta )
		Scoreboard.ParentMouseWheeled( self, dlta )
	end

	local Canvas = vgui.Create( "ScoreboardSettingsList", Category )
	Canvas:SetAutoSize( true )
	Canvas:EnableVerticalScrollbar( true )
	Canvas:EnableHorizontal( false )
	Canvas:SetSpacing( 4 )
	Canvas:SetPadding( 4 )
	Canvas:EnableVerticalScrollbar()
	Canvas.OnMouseWheeled = function( Canvas, dlta )
		Scoreboard.ParentMouseWheeled( self, dlta )
	end

	Category:SetContents( Canvas )

	self.Groups[id] = Category

	return Canvas

end

function SETTINGS:NewSetting( control, parent, text, convar, tip )

	local Control = vgui.Create( control, parent )
	Control:SetConVar( convar )
	--if tip then Control:SetTooltip( T( tip ) ) end
	Control:SetText( text )
	Control:SetWidth( 300 )

	/*if Control.SetTextColor then
		Control:SetTextColor( 255, 255, 255 )
	end*/

	return Control

end

function SETTINGS:CheckBox( canvas, title, convar, toggle, tip )

	local newBox = self:NewSetting( "DCheckBoxLabel", canvas, title, convar, tip )

	if toggle then
		self.Togglables[toggle] = newBox
		newBox._RealTall = 16
	end

	canvas:AddItem( newBox )
	newBox.Canvas = canvas

	return newBox
end

function SETTINGS:Header( canvas, title )

	local header = vgui.Create( "DLabel", canvas )
	header:SetText( title )
	header:SetWidth( 300 )
	header:SetTall( 32 )
	header:SetFont( "GTowerHUDMain" )

	header.Paint = function()
		surface.SetDrawColor( 7, 30, 58, 30 )
		surface.DrawRect( 0, 0, header:GetSize() )
	end

	canvas:AddItem( header )
	header.Canvas = canvas

	return header

end

function SETTINGS:Slider( canvas, title, convar, min, max, decimal, toggle, tip )

	local sliderType = "DNumSlider2"

	if decimal == 1 then
		sliderType = "DNumSlider"
	end

	local newSlider = self:NewSetting( sliderType, canvas, title, convar, tip )
	newSlider:SetMinMax( min, max )
	newSlider:SetDecimals( decimal or 0 )

	if toggle then
		self.Togglables[toggle] = newSlider
		newSlider._RealTall = 32
	end

	canvas:AddItem( newSlider )
	newSlider.Canvas = canvas

	return newSlider

end

function SETTINGS:Init()

	self:Create()

end

function SETTINGS:Create()

	self.Groups = {}
	self.Togglables = {}

	/*=========
	General Settings
	============*/

	local MainCanvas = self:NewCategory( "General Settings", 1 )

	self:Header( MainCanvas, "Scoreboard" )
	self:Slider( MainCanvas, "Player Card Height", "gmt_score_height", 32, 64, 0, nil, "SetScoreHeight" )
	self:CheckBox( MainCanvas, "Enable Respect Icons", "gmt_respecticons", nil, "SetRespectIcons" )
	self:CheckBox( MainCanvas, "Enable Range Voice", "gmt_rangevoice", nil, "SetRangeVoice" )
	self:CheckBox( MainCanvas, "Enable Blur", "gmt_scoreboard_blur", nil, "SetScoreboardBlur" )
	self:Slider( MainCanvas, "Blur Amount", "gmt_scoreboard_blur_amount", 1, 10, 0, "gmt_scoreboard_blur", "SetScoreboardBlurAmt" )

	self:Header( MainCanvas, "Chat" )
	self:CheckBox( MainCanvas, "Enable Sounds", "gmt_chat_sound", nil, "SetChatSounds" )

	if IsLobby then
		self:CheckBox( MainCanvas, "Enable Locations", "gmt_chat_loc", nil, "SetChatLocation" )
	end

	self:CheckBox( MainCanvas, "Enable Timestamps", "gmt_chat_timestamp" )
	self:CheckBox( MainCanvas, "Enable Timestamp 24 Hour Mode", "gmt_chat_timestamp24", "gmt_chat_timestamp" )
	self:CheckBox( MainCanvas, "Enable Outline", "gmt_chat_outline" )
	self:Slider( MainCanvas, "Outline Boldness", "gmt_chat_outlineamt", 0, 100, 1, "gmt_chat_outline" )
	//self:CheckBox( MainCanvas, "Enable Location Voice Chat", "gmt_allowvoice" )



	/*=========
	Lobby Settings
	============*/

	if game.GetMap() == "gmt_build0s2b" then

		local LobbyCanvas = self:NewCategory( "Lobby Settings", 2 )

		self:Header( LobbyCanvas, "General" )
		self:CheckBox( LobbyCanvas, "Enable Missing Content Notice", "gmt_notice" )
		self:CheckBox( LobbyCanvas, "Enable Player Use Menu", "gmt_playermenu" )
		////self:Slider( LobbyCanvas, "Volume", Volume.Var, 1, 100 )


		self:Header( LobbyCanvas, "Requests" )
		self:CheckBox( LobbyCanvas, "Ignore Trade Requests", "gmt_ignore_trade" )
		self:CheckBox( LobbyCanvas, "Ignore Group Requests", "gmt_ignore_group" )
		self:CheckBox( LobbyCanvas, "Ignore Gamemode Requests", "gmt_ignore_gamemode" )
		self:CheckBox( LobbyCanvas, "Ignore Party Requests", "gmt_ignore_party" )
		self:CheckBox( LobbyCanvas, "Ignore Duel Requests", "gmt_ignore_duel" )


		self:Header( LobbyCanvas, "Performance" )
		self:CheckBox( LobbyCanvas, "Enable VIP Glow", "gmt_vipglow" )
		self:CheckBox( LobbyCanvas, "Enable Group Glow", "gmt_groupglow" )
		self:CheckBox( LobbyCanvas, "Enable Player Particle Effects", "gmt_enableparticles" )
		self:CheckBox( LobbyCanvas, "Enable Rave Ball Effects", "gmt_visualizer_effects" )
		self:CheckBox( LobbyCanvas, "Enable Dynamic Firework Lights", "gmt_fireworkdlight" )
		self:CheckBox( LobbyCanvas, "Enable Blood", "gmt_allowblood" )
		self:CheckBox( LobbyCanvas, "Enable Jetpack Smoke", "gmt_jetpacksmoke" )
		//self:CheckBox( LobbyCanvas, "Disable Fog", "gmt_removefog" )
		//self:CheckBox( LobbyCanvas, "Rave Ball: Shake", "gmt_visualizer_shake" )


		self:Header( LobbyCanvas, "Customization" )
		self:CheckBox( LobbyCanvas, "Enable Compact Store Mode", "gmt_compactstores" )
		self:CheckBox( LobbyCanvas, "Enable Custom Minecraft Skins", "gmt_minecraftskins" )
		self:CheckBox( LobbyCanvas, "Use Old Teleporter Font", "gmt_oldtele" )
		self:CheckBox( LobbyCanvas, "Enable Crosshair", "gmt_hud_crosshair" )
		self:CheckBox( LobbyCanvas, "Crosshair Always Visible", "gmt_hud_crosshair_always", "gmt_hud_crosshair" )
		//self:CheckBox( LobbyCanvas, "Enable Action Crosshair", "gmt_hud_crosshair_action", "gmt_hud_crosshair" )
		self:CheckBox( LobbyCanvas, "Enable HUD", "gmt_hud" )
		self:CheckBox( LobbyCanvas, "Enable HUD Location", "gmt_hud_location", "gmt_hud" )
		self:CheckBox( LobbyCanvas, "Enable Event Timer", "gmt_draweventtimer" )
		self:CheckBox( LobbyCanvas, "Enable Floating Chat", "gmt_drawfloatingchat" )
		//self:CheckBox( LobbyCanvas, "Enable Gamemode Notice", "gmt_gmnotice" )
		//self:CheckBox( LobbyCanvas, "Enable News Ticker", "gmt_newsticker" )
		self:CheckBox( LobbyCanvas, "Enable View Bob", "gmt_viewbob" )
		self:CheckBox( LobbyCanvas, "Draw First Person Legs", "gmt_drawlegs" )
		self:CheckBox( LobbyCanvas, "Draw Players While Playing Blockles", "gmt_tetris_drawplayers" )
		//self:CheckBox( LobbyCanvas, "Allow Sound Spam", "gmt_allowSoundSpam" )

		self:CheckBox( LobbyCanvas, "Enable Ambient Music", "gmt_ambiance_enable" )
		self:Slider( LobbyCanvas, "Ambient Music Volume", "gmt_ambiance_volume", 1, 100, 0, "gmt_ambiance_enable" )

		////self:Slider( LobbyCanvas, "Suite Snap Grid Size", "gmt_invsnapsize", 2, 16 )
		self:Slider( LobbyCanvas, "Third Person Camera Distance", "gmt_setthirdpersondist", 35, 150 )

		//self:CheckBox( LobbyCanvas, "Enable Soundscapes", "gmt_soundscapes_enable" )
		//self:Slider( LobbyCanvas, "Soundscape Volume", "gmt_soundscapes_volume", 0, 100, 0, "gmt_soundscapes_emable" )

		self.Groups["LobbyCategory"] = LobbyCategory

	end

	/*=========
	Virus Settings
	============*/

	if gamemode.Get( "virus" ) then

		local VirusCanvas = self:NewCategory( "Virus Settings", 2 )

		self:CheckBox( VirusCanvas, "Display HUD", "gmt_virus_hud" )
		self:CheckBox( VirusCanvas, "Display Damage Notes", "gmt_virus_damagenotes" )

	end

	/*=========
	Zombie Massacre Settings
	============*/

	if gamemode.Get( "zombiemassacre" ) then

		local ZMCanvas = self:NewCategory( "Zombie Massacre Settings", 2 )

		self:CheckBox( ZMCanvas, "Display HUD", "gmt_zm_hud" )
		self:CheckBox( ZMCanvas, "Display Blur", "gmt_zm_blur" )
		self:CheckBox( ZMCanvas, "Display Damage Notes", "gmt_zm_notes" )

		self:Slider( ZMCanvas, "Camera Speed", "gmt_zm_cameraspeed", 1, 5 )

		local ZMDLights = self:Slider( ZMCanvas, "Amount of Dynamic Lights", "gmt_zm_dlights", 0, 2 )
		ZMDLights.Descriptions = { "None", "Some", "All" }

	end

	/*=========
	Minigolf Settings
	============*/

	if gamemode.Get( "minigolf" ) then

		local MiniCanvas = self:NewCategory( "Minigolf Settings", 2 )

		self:CheckBox( MiniCanvas, "Display HUD", "gmt_minigolf_hud", nil, "SetDisplayHUD" )
		self:CheckBox( MiniCanvas, "Display Blur", "gmt_minigolf_blur", nil, "SetDisplayBlur" )
		self:Slider( MiniCanvas, "Garden Grass Draw Dist", "cl_detaildist", 0, 1000, 0, nil, "SetMiniGrassDist" )

	end

end

function SETTINGS:CreateAdmin()

	if !LocalPlayer():IsAdmin() then return end

	self.AdminCreated = true

	local AdminCanvas = self:NewCategory( "Admin Settings", #self.Groups + 1 )
	self:CheckBox( AdminCanvas, "Show Usermessages (console)", "gmt_admin_showumsg" )
	//self:CheckBox( AdminCanvas, "Show Profiler", "gmt_admin_profiler" )
	self:CheckBox( AdminCanvas, "Show Entity Information", "gmt_admin_showents" )
	self:CheckBox( AdminCanvas, "Show Net Info", "gmt_admin_shownetinfo" )
	self:CheckBox( AdminCanvas, "Show Extended Net Info", "gmt_admin_shownetinfo2", "gmt_admin_shownetinfo" )
	self:CheckBox( AdminCanvas, "Show Player Info", "gmt_admin_showplayinfo" )
	self:CheckBox( AdminCanvas, "Show Players", "gmt_admin_esp" )
	self:CheckBox( AdminCanvas, "Show Renderboxes", "gmt_admin_showrenders" )

	if Location then
		self:CheckBox( AdminCanvas, "Show Locations", "gmt_admin_locations" )
	end

	self:CheckBox( AdminCanvas, "Show Player Ghosts", "gmt_admin_playerghosts" )
	self:Slider( AdminCanvas, "Player Ghost Amount", "gmt_admin_playerghosts_amount", 15, 300, 1 )

end

function SETTINGS:OnMousePressed()
    GTowerMenu:CloseAll()
end

function SETTINGS:Removing()
end

function SETTINGS:AnimateTall( item, newTall )

	if item:GetTall() != newTall then

		item:SetTall( math.Approach( item:GetTall(), newTall, 1 ) )
		item.Canvas:InvalidateLayout()
		self:InvalidateLayout()

		item._IsAnimating = true

	else

		item._IsAnimating = false

	end

end

function SETTINGS:Think()

	if IsLobby then

		/*=========
		VIP Settings
		============*/
		if LocalPlayer().IsVIP && LocalPlayer():IsVIP() && !self.VIPCreated then
			self:CreateVIP()
		end

	end

	/*=========
	Admin Settings
	============*/
	--[[if LocalPlayer():IsAdmin() && !self.AdminCreated then
		self:CreateAdmin()
	end

	if self.Togglables then

		for convar, item in pairs( self.Togglables ) do

			if !item then continue end

			if convar && GetConVar( convar ):GetBool() then

				item:SetAlpha( 255 )
				item:SetMouseInputEnabled( true )
				item._TallTo = item._RealTall

				if item._TallTo then

					self:AnimateTall( item, item._TallTo )

					if !item._IsAnimating then
						item._TallTo = nil
					end

				end

			else

				item:SetAlpha( 50 )
				item:SetMouseInputEnabled( false )
				item._TallTo = 0

				if item._TallTo then

					self:AnimateTall( item, item._TallTo )

					if !item._IsAnimating then
						item._TallTo = nil
					end

				end

			end

		end

	end]]--

end

function SETTINGS:Paint( w, h )
end

function SETTINGS:PerformLayout()

	local curY = 2

	for id, category in ipairs( self.Groups ) do

		category:SetWide( self:GetWide() - 6 )
		category:SetPos( 3, curY )

		curY = curY + category:GetTall() + 2

	end

	//self.ItemParent:SetTargetTall( SumHeight, self )
	self:SetTall( curY )

end

vgui.Register( "ScoreBoardSettings", SETTINGS )

/**
	A single collapsable category that holds settings
*/
SETTINGSCATEGORY = {}

function SETTINGSCATEGORY:Init()

	self:SetLabel( "Unknown" )
	self:SetLabelFont( Scoreboard.Customization.CollapsablesFont, false )
	self:SetTabCurve( 0 )

	self:SetColors(
		Scoreboard.Customization.ColorDark,
		Scoreboard.Customization.ColorBackground,
		Scoreboard.Customization.ColorBright,
		Scoreboard.Customization.ColorBright
	)

	self:SetPadding( 2 )
	//self:EnableVerticalScrollbar( false )

end

vgui.Register( "ScoreboardSettingsCategory", SETTINGSCATEGORY, "DCollapsibleCategory2" )




SETTINGSLIST = {}

function SETTINGSLIST:Paint( w, h )

	surface.SetDrawColor( Scoreboard.Customization.ColorNormal )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

end

vgui.Register( "ScoreboardSettingsList", SETTINGSLIST, "DPanelList2" )
