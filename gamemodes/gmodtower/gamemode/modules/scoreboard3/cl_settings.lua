

local GAMEMODE = GAMEMODE

-----------------------------------------------------
module( "Scoreboard.Settings", package.seeall )

// TAB

hook.Add( "ScoreBoardItems", "Settings", function()
	return vgui.Create( "ScoreboardSettingsTab" )
end )

TAB = {}
TAB.Order = 4

function TAB:GetText()
	return "SETTINGS"
end

/*function TAB:OnOpen()
	if ValidPanel( self.Body ) then
		self.Body:Create()
	end
end*/

function TAB:CreateBody()
	return vgui.Create("ScoreboardSettings", self )
end

vgui.Register( "ScoreboardSettingsTab", TAB, "ScoreboardTab" )

// SETTINGS

SETTINGS = {}
SETTINGS.TabNames = {
	--"Gamemode", -- Automatically adds when needed.
	"General",
	"Graphics",
	"Voice/Media",
	"Chat",
	"Scoreboard",
	"HUD",
	
	"Nostalgia",
	"Notifications",
	--"Friends/Blocked", -- WIP
	"Advanced",
	--"Admin", -- Automatically adds when needed.
	--"Debug", -- Automatically adds when needed.
	--"Spawnlist", -- Automatically adds when needed.
	--"VIP", -- Automatically adds when needed.
}
SETTINGS.LobbyOnlyTabs = {
	"Graphics",
	"HUD",
	"Notifications",
	"Advanced",
	"VIP",
}
SETTINGS.GamemodesWithSettings = {
	"ballrace",
	"pvpbattle",
	"virus",
	"zombiemassacre",
	"minigolf"
}
SETTINGS.Tabs = {}

function SETTINGS:Init()

	self.ActiveTab = nil
	local firstTab = nil

	// Add gamemode settings
	if table.HasValue( self.GamemodesWithSettings, engine.ActiveGamemode() ) then
		table.insert( self.TabNames, "Gamemode" )
	end

	// Add VIP settings
	if LocalPlayer().IsVIP and LocalPlayer():IsVIP() then
		table.insert( self.TabNames, "VIP" )
	end

	// Add admin settings
	if LocalPlayer():IsAdmin() then
		table.insert( self.TabNames, "Admin" )
		table.insert( self.TabNames, "Debug" )
		table.insert( self.TabNames, "Spawnlist" )
	end

	// Create the tabs
	for id, name in pairs( self.TabNames ) do

		// Skip tabs that are lobby only
		if !IsLobby and table.HasValue( self.LobbyOnlyTabs, name ) then continue end

		local tab = self:CreateTab( id, name )

		if id == 1 then
			firstTab = tab
		end
	end

	// Set the first tab
	if firstTab then
		self:SetActiveTab( firstTab )
	end

end

function SETTINGS:CreateTab( id, name )

	local tab = vgui.Create( "ScoreboardTabInner", self )
	local group = vgui.Create( "ScoreboardSettingsCategoryTab", tab )

	tab:SetBody( group )
	tab:SetText( name )

	tab:SetOrder( id )
	tab.Name = name
	tab.Owner = self

	self:AddTab( tab )
	return tab

end

function SETTINGS:AddTab( tab )

	table.insert( self.Tabs, tab )
	tab:SetParent( self )

end

function SETTINGS:SetActiveTab( tab )

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
	newBody:OnOpenTab( tab )

	self:InvalidateLayout()

end

function SETTINGS:PerformLayout()

	local position = 5
	local width = 145

	// Sort their order
	table.sort( self.Tabs, function( a, b )
		if a.Order == b.Order then
			return a:GetText() > b:GetText()
		end

		return a.Order < b.Order
	end )

	// Get widest tab
	for _, tab in pairs( self.Tabs ) do
		width = math.max( width, tab:GetWide() )
	end

	// Set their positions and size
	for _, tab in pairs( self.Tabs ) do
		tab:SetTall( 24 )
		tab:InvalidateLayout( true )

		tab:SetPos( 0, position )
		--tab:AlignLeft( self:GetWide() - width )
		tab:SetWide( width )

		position = position + tab:GetTall()
	end

	self.TabHeight = position + 4
	self.TabWidth = width

	// Layout active tab
	if ValidPanel( self.ActiveTab ) then
		local body = self.ActiveTab:GetBody()
		body:InvalidateLayout( true )
		body:SetPos( self.TabWidth, 4 )
		body:SetWide( self:GetWide() - width )
		body:AlignRight()
	end

end

function SETTINGS:Paint( w, h )

	//surface.SetDrawColor( Scoreboard.Customization.ColorDark )
	//surface.DrawRect( 0, 0, self:GetWide(), 24 )

	local color = Scoreboard.Customization.ColorDark
	surface.SetDrawColor( color )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

	surface.SetDrawColor( color.r - 5, color.g - 5, color.b - 5 )
	surface.DrawRect( self.TabWidth, 4, 4, self:GetTall() )

end

function SETTINGS:Think()

	local current = self:GetTall()
	local targetHeight = 24

	// Resize for tab
	if ValidPanel( self.ActiveTab ) then

		local body = self.ActiveTab:GetBody()
		targetHeight = targetHeight + body:GetTall() - 4

		targetHeight = math.max( targetHeight, self.TabHeight )

	end

	self:SetTall( math.Approach( current, targetHeight, math.max( math.abs( (current-targetHeight) * FrameTime() * 15 ) ), 1 ) )
	self:Center()

end


function SETTINGS:OnMousePressed()
    GTowerMenu:CloseAll()
end

function SETTINGS:Removing()
end

vgui.Register("ScoreboardSettings", SETTINGS )


local SETTINGSCATEGORYTAB = {}

function SETTINGSCATEGORYTAB:Init()

	local grid = vgui.Create( "DGrid", self)
	grid:SetCols( 1 )
	grid:SetRowHeight( 20 )

	self:SetContents( grid )

end

function SETTINGSCATEGORYTAB:SetContents( contents )

	self.Contents = contents
	self.Contents:SetParent( self )
	self:InvalidateLayout()

end

function SETTINGSCATEGORYTAB:PerformLayout()

	local Padding = 12
	local width = self:GetWide() - Padding * 2

	if self.CurrentTab ~= "Spawnlist" then
		self.Contents:SetColWide( width )
	end

	for _, panel in pairs( self.Contents.Items ) do
		panel:SetWide( self.Contents:GetColWide() - 2 )
		panel:InvalidateLayout()
	end

	if self.Contents then

		self.Contents:SetPos( Padding, 0 )
		self.Contents:SetWide( width )
		self.Contents:InvalidateLayout( true )

		self:SetTall( self.Contents:GetTall() + ( Padding * 2 ) + 8 )

	end

end

function SETTINGSCATEGORYTAB:Think()

	if self.Togglables then

		for convar, item in pairs( self.Togglables ) do

			if !item then continue end
			if convar != nil then continue end

			if convar && GetConVar( convar ):GetBool() then
				item:SetAlpha( 255 )
				item:SetMouseInputEnabled( true )
			else
				item:SetAlpha( 5 )
				item:SetMouseInputEnabled( false )
			end
		end

	end

end

function SETTINGSCATEGORYTAB:OnOpenTab( tab )
	self:CreateContents( tab )
	self.CurrentTab = tab.Name
end

function SETTINGSCATEGORYTAB:Paint( w, h )
	--surface.SetDrawColor( Scoreboard.Customization.ColorDark )
	--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() - 6 )
end

function SETTINGSCATEGORYTAB:NewSetting( control, parent, text, convar, tip )

	local Control = vgui.Create( control, parent )
	if convar then Control:SetConVar( convar ) end

	if tip then Control:SetTooltip( T( tip ) ) end
	if text then Control:SetText( text ) end
	Control:SetWidth( 300 )

	return Control

end

function SETTINGSCATEGORYTAB:CheckBox( title, convar, toggle, tip )

	local canvas = self.Contents

	local newBox = self:NewSetting( "DCheckBoxLabel", canvas, title, convar, tip )
	newBox:SetTextColor( Color( 255, 255, 255 ) )
	--newBox:SetIndent( 12 )

	if toggle then
		self.Togglables[toggle] = newBox
		--newBox:SetIndent( 20 )
	end

	canvas:AddItem( newBox )
	newBox.Canvas = canvas

	return newBox
end

function SETTINGSCATEGORYTAB:Button( title, tip, click )

	local canvas = self.Contents

	local newBox = self:NewSetting( "DButton", canvas, title, nil, tip )
	newBox:SetTextColor( Color( 255, 255, 255 ) )
	--newBox:SetIndent( 12 )

	newBox.DoClick = click

	canvas:AddItem( newBox )
	newBox.Canvas = canvas

	return newBox

end

function SETTINGSCATEGORYTAB:SpawnButton( title, mdl, click )

	local canvas = self.Contents

	local newBox = self:NewSetting( "SpawnIcon", canvas, nil, nil, mdl )
	newBox:SetTextColor( Color( 255, 255, 255 ) )
	--newBox:SetIndent( 12 )

	newBox.DoClick = click
	newBox:SetModel( mdl )

	canvas:AddItem( newBox )
	newBox.Canvas = canvas

	return newBox

end

function SETTINGSCATEGORYTAB:Header( title )

	local canvas = self.Contents

	local header = vgui.Create( "DLabel", canvas )
	header:SetText( title )
	header:SetTextColor( Color( 255, 255, 255 ) )
	header:SetWidth( 300 )
	header:SetTall( 24 )
	header:SetFont( "GTowerHUDMain" )

	canvas:AddItem( header )
	header.Canvas = canvas

	self:Divider( true )

	return header

end

function SETTINGSCATEGORYTAB:Divider( drawline )

	local canvas = self.Contents

	local divider = vgui.Create( "DPanel", canvas )
	divider:SetWidth( 300 )
	divider:SetTall( 10 )

	if drawline then
		divider.Paint = function()
			local color = Scoreboard.Customization.ColorDark or Color( 85, 85, 85, 80 )
			surface.SetDrawColor( colorutil.Brighten( color, 1.5 ) )
			surface.DrawRect( 0, divider:GetTall() - 5, divider:GetWide(), 1 )
		end
	end

	canvas:AddItem( divider )

end

function SETTINGSCATEGORYTAB:Slider( title, convar, min, max, decimal, toggle, tip )

	local canvas = self.Contents

	local sliderType = "DNumSlider2"

	local newSlider = self:NewSetting( sliderType, canvas, title, convar, tip )
	newSlider:SetMinMax( min, max )
	newSlider:SetDecimals( decimal or 0 )

	if toggle then
		self.Togglables[toggle] = newSlider
	end

	canvas:AddItem( newSlider )
	newSlider.Canvas = canvas

	return newSlider

end

function SETTINGSCATEGORYTAB:CreateContents( tab )

	if tab.Created then return end
	tab.Created = true

	local tabname = tab.Name
	local settings = tab.Owner

	self.Togglables = {}

	self.Contents:SetCols( 1 )
	self.Contents:SetRowHeight( 20 )

	if tabname == "General" then
		self:Header( "Volume" )
		if string.StartWith(game.GetMap(),"gmt_build") then
			--self:Slider( "Music Volume", Volume.VarAudio, 0, 100 )
			--self:Slider( "Media Volume", "mediaplayer_volume", 0, 1 )
			self:Slider( "Instrument Volume", "gmt_volume_instrument", 0, 100 )
			self:CheckBox( "Enable Background Music", "gmt_ambiance_enable" )
			self:Slider( "Background Music Volume", "gmt_ambiance_volume", 1, 100, 0, "gmt_ambiance_enable" )

		else
			self:Slider( "Gamemode Music Volume", "gmt_volume_music", 0, 100 )
		end

		if IsLobby then

			self:Divider()

			self:Header( "General" )
			--self:CheckBox( "Hide Beta Message", "gmt_hidebetamsg" )
			self:CheckBox( "Enable Player Use Menu", "gmt_playermenu" )
			self:CheckBox( "Enable View Bob", "gmt_viewbob" )
			self:CheckBox( "Draw First Person Legs", "gmt_drawlegs" )
			self:CheckBox( "Draw Players While Playing Blockles", "gmt_tetris_drawplayers" )
			--self:Slider( "Condo Snap Grid Size (hold C while dragging)", "gmt_invsnapsize", 2, 16 )
		end

	end

	if tabname == "Scoreboard" then
		self:Header( "Scoreboard" )
		--self:CheckBox( "2 Players Per Line", "gmt_scoreboard_grid" )
		--self:Slider( "Player Card Height", "gmt_scoreboard_height", 32, 64, 0, nil, "SetScoreHeight" )
		self:CheckBox( "Enable Respect Icons", "gmt_scoreboard_respecticons", nil, "SetRespectIcons" )
		self:CheckBox( "Enable Blur", "gmt_scoreboard_blur", nil, "SetScoreboardBlur" )
		self:Slider( "Blur Amount", "gmt_scoreboard_blur_amount", 1, 10, 0, "gmt_scoreboard_blur", "SetScoreboardBlurAmt" )
	end

	if tabname == "Chat" then
		self:Header( "Chat" )
		self:CheckBox( "Enable Sounds", "gmt_chat_sound", nil, "SetChatSounds" )

		if IsLobby then
			self:CheckBox( "Enable Locations", "gmt_chat_loc", nil, "SetChatLocation" )
		end

		self:CheckBox( "Enable Timestamps", "gmt_chat_timestamp" )
		self:CheckBox( "Enable Timestamp 24 Hour Mode", "gmt_chat_timestamp24", "gmt_chat_timestamp" )
		self:CheckBox( "Enable Floating Chat", "gmt_drawfloatingchat" )
		self:CheckBox( "Enable Outline", "gmt_chat_outline" )
		self:Slider( "Outline Boldness", "gmt_chat_outlineamt", 0, 100, 0, "gmt_chat_outline" )
	end

	if tabname == "Voice/Media" then
		self:Header( "Voice/Media" )
		--self:CheckBox( "Enable Public Voice Chat", "gmt_allowvoice" )
		self:CheckBox( "Enable Voice Chat", "voice_enable" )
		if IsLobby then
			self:CheckBox( "Mute Mediaplayer When GMod Is Unfocused", "mediaplayer_mute_unfocused" )
			--self:CheckBox( "Enable Ambient Music", "gmt_ambiance_enable" )
			--self:Slider( "Ambient Music Volume", "gmt_ambiance_volume", 1, 100, 0, "gmt_ambiance_enable" )
			//self:CheckBox( "Enable Soundscapes", "gmt_soundscapes_enable" )
			//self:Slider( "Soundscape Volume", "gmt_soundscapes_volume", 0, 100, 0, "gmt_soundscapes_emable" )
		end
	end

	if tabname == "Notifications" then
		self:Header( "Notifications" )
		if IsLobby then
			self:CheckBox( "Enable Missing Content Notice", "gmt_notice" )
			--self:CheckBox( "Enable Missing Workshop Notice", "gmt_notice_workshop" )
			self:CheckBox( "Enable Auto Reconnect", "gmt_notice_reconnect" )
			
			self:CheckBox( "Enable Dark Notifications", "gmt_darknotif" )

			self:Divider()

			self:Header( "Requests" )
			self:CheckBox( "Ignore Trade Requests", "gmt_ignore_trade" )
			self:CheckBox( "Ignore Group Requests", "gmt_ignore_group" )
			self:CheckBox( "Ignore Gamemode Requests", "gmt_ignore_gamemode" )
			self:CheckBox( "Ignore Party Requests", "gmt_ignore_party" )
			self:CheckBox( "Ignore Duel Requests", "gmt_ignore_duel" )

			self:Divider()

			self:Header( "Friends" )
			self:CheckBox( "Notify When a Friend Joins", "gmt_notify_friendjoin" )
		end
	end

	if tabname == "Graphics" then
		self:Header( "Graphics/Performance" )
		if IsLobby then

			self:CheckBox( "Enable VIP Player Glow (expensive)", "gmt_vipglow" )
			self:CheckBox( "Enable Group Player Glow (expensive)", "gmt_groupglow" )
			self:CheckBox( "Enable Player Particle Effects", "gmt_enableparticles" )

			self:Divider()

			self:Header( "Items" )
			self:CheckBox( "Enable Rave Ball Effects", "gmt_visualizer_effects" )
			self:CheckBox( "Enable Dynamic Firework Lights", "gmt_fireworkdlight" )
			self:CheckBox( "Enable Jetpack Smoke", "gmt_jetpacksmoke" )

			self:Divider()

			self:Header( "Misc" )
			self:CheckBox( "Enable Blood Effects", "gmt_allowblood" )
			--self:CheckBox( "Enable Custom Minecraft Skins", "gmt_minecraftskins" )
		end
	end

	if tabname == "HUD" then
		self:Header( "HUD" )
		if IsLobby then
			self:CheckBox( "Enable HUD", "gmt_hud" )
			
			self:CheckBox( "Enable Lobby 2 HUD (Requires Rejoin)", "gmt_hud2", "gmt_hud" )
			self:CheckBox( "Enable HUD Location", "gmt_hud_location", "gmt_hud" )
			self:CheckBox( "Enable Compact Store Layout", "gmt_compactstores", "gmt_hud" )
			
			self:CheckBox( "Enable Third Person Button", "gmt_thirdpersonbutton" )
			//self:CheckBox( "Enable Crosshair", "gmt_hud_crosshair", "gmt_hud" )
			self:CheckBox( "Crosshair Always Visible", "gmt_hud_crosshair_always", "gmt_hud_crosshair" )
			//self:CheckBox( LobbyCanvas, "Enable Action Crosshair", "gmt_hud_crosshair_action", "gmt_hud_crosshair" )
			//self:CheckBox( LobbyCanvas, "Enable Gamemode Notice", "gmt_gmnotice" )
			//self:CheckBox( LobbyCanvas, "Enable News Ticker", "gmt_newsticker" )
			//self:CheckBox( LobbyCanvas, "Allow Sound Spam", "gmt_allowSoundSpam" )
		end
	end
	
	if tabname == "Nostalgia" then

		self:Header( "Nostalgia" )

			self:CheckBox( "Enable Name Text Coloring", "gmt_textcolor" )

	end

	if tabname == "Advanced" then
		self:Header( "Advanced" )
		if IsLobby then
			self:Slider( "Camera Distance", "gmt_setthirdpersondist", 35, 150 )
		end
	end

	if tabname == "Gamemode" then

		/*=========
		Virus Settings
		============*/
		if engine.ActiveGamemode() == "virus" then
			self:Header( "Virus" )
			self:CheckBox( "Display HUD", "gmt_virus_hud" )
			self:CheckBox( "Display Damage Notes", "gmt_virus_damagenotes" )

		end

		/*=========
		Zombie Massacre Settings
		============*/
		if engine.ActiveGamemode() == "zombiemassacre" then

			self:Header( "Zombie Massacre" )
			self:CheckBox( "Display HUD", "gmt_zm_hud" )
			self:CheckBox( "Display Blur", "gmt_zm_blur" )
			self:CheckBox( "Display Damage Notes", "gmt_zm_notes" )

			self:Slider( "Camera Speed", "gmt_zm_cameraspeed", 1, 5 )

			local ZMDLights = self:Slider( "Amount of Dynamic Lights", "gmt_zm_dlights", 0, 2 )
			ZMDLights.Descriptions = { "None", "Some", "All" }

		end

		/*=========
		Minigolf Settings
		============*/
		if engine.ActiveGamemode() == "minigolf" then

			self:Header( "Minigolf" )
			self:CheckBox( "Display HUD", "gmt_minigolf_hud", nil, "SetDisplayHUD" )
			self:CheckBox( "Display Blur", "gmt_minigolf_blur", nil, "SetDisplayBlur" )
			self:Slider( "Garden Grass Draw Dist", "cl_detaildist", 0, 1000, 0, nil, "SetMiniGrassDist" )

		end

		/*=========
		PVPBattle Settings
		============*/
		if engine.ActiveGamemode() == "pvpbattle" then

			self:Header( "PvP Battle" )
			self:CheckBox( "Use Old Ammo HUD", "gmt_pvp_oldammo" )

		end

		/*=========
		Ballrace Settings
		============*/
		if engine.ActiveGamemode() == "ballrace" then

			self:Header( "Ball Race" )
			self:Slider( "Ball Fading Amount", "gmt_ballrace_fade", 0, 1000 )

		end

	end

	if tabname == "VIP" then
		self:Header( "VIP" )
		self:Slider( "Jetpack Power", "gmt_jetpackpower", .1, 4, 1 )
		//self:CheckBox( VIPCanvas, "Draw Jetpack For Other Players", "gmt_jetpackvipdraw" )
	end

	if tabname == "Admin" then
		self:Header( "Admin" )

		//self:CheckBox( "Show Player Sprays", "gmt_admin_sprays" )
		self:CheckBox( "Show Player Positions", "gmt_admin_esp" )
		self:CheckBox( "Show Player Ghosts *EXTREMELY LAGGY*", "gmt_admin_playerghosts" )
		self:Slider( "Player Ghost Amount", "gmt_admin_playerghosts_amount", 15, 300, 0, "gmt_admin_playerghosts" )

		self:CheckBox( "Show Player Count", "gmt_admin_showplaycount" )
		//self:CheckBox( "Show Map List", "gmt_admin_showmaplist" )
		//self:CheckBox( "Hide Beta Message", "gmt_admin_hidebetamsg" )

	end

	if tabname == "Debug" then
		self:Header( "Tools" )

		self:CheckBox( "Developer Mode", "developer" )
		self:CheckBox( "Show Entity Information", "gmt_admin_showents" )
		self:CheckBox( "Show Net Info", "gmt_admin_shownetinfo" )
		self:CheckBox( "Show Extended Net Info", "gmt_admin_shownetinfo2", "gmt_admin_shownetinfo" )
		self:CheckBox( "Show Condo Information", "gmt_admin_showcondo" )
		self:CheckBox( "Show Usermessages (console)", "gmt_admin_showumsg" )
		self:CheckBox( "Show Usermessages (graph)", "gmt_admin_showumsggraph" )
		//self:CheckBox( "Show Profiler", "gmt_admin_profiler" )

		if Location then
			self:CheckBox( "Show Locations", "gmt_admin_locations" )
		end

		self:Divider()

		self:Header( "Performance" )
		self:Slider( "Net Graph", "net_graph", 0, 3 )
		self:Slider( "Fullbright", "mat_fullbright", 0, 2 )
		self:Slider( "Wireframe", "mat_wireframe", 0, 2 )
		self:CheckBox( "Show FPS", "cl_showfps" )
		self:CheckBox( "Hide +showbudget", "gmt_admin_showbudget" )
		self:CheckBox( "Draw Water", "mat_drawwater" )
		self:CheckBox( "Draw World", "r_drawworld" )
		self:CheckBox( "Draw Static Props", "r_drawstaticprops" )
		self:CheckBox( "Draw Decals", "r_drawdecals" )
		self:CheckBox( "Draw Skybox", "r_skybox" )
		self:CheckBox( "GL Clear", "gl_clear" )

		self:Divider()

		self:Header( "Art Debug" )
		self:CheckBox( "Show Collision Wireframes", "vcollide_wireframe" )
		self:CheckBox( "Show Shadow Wireframes", "r_shadowwireframe" )
		self:CheckBox( "Show Renderboxes", "gmt_admin_showrenders" )

	end

	if tabname == "Spawnlist" then

		local path = "models/gmod_tower/*"
		local Models = file.FindDir( path, "GAME" )

		self.Contents:SetCols( 10 )
		self.Contents:SetRowHeight( 64 )
		self.Contents:SetColWide( 64 )

		if Models then

			for _, f in pairs( Models ) do
				if string.GetExtensionFromFilename( f ) == "mdl" then
					local fpath = "models/gmod_tower/" .. f
					self:SpawnButton( string.StripExtension(f), fpath, function() RunConsoleCommand("gmt_create", fpath) end )
				end
			end

		end

	end

end

vgui.Register( "ScoreboardSettingsCategoryTab", SETTINGSCATEGORYTAB, "PanelList" )


SETTINGSLIST = {}

function SETTINGSLIST:Paint( w, h )

	surface.SetDrawColor( Scoreboard.Customization.ColorNormal )
	surface.DrawRect( 0, 0, w, h )

end

vgui.Register( "ScoreboardSettingsList", SETTINGSLIST, "DPanelList2" )


-- This is not really a good place for this, but this script as all the spawnlist logic, so...
/*function GAMEMODE:OnUndo( name )

	notification.AddLegacy( "#Undone_"..name, NOTIFY_UNDO, 2 )
	surface.PlaySound( "ambient/water/drip"..math.random(1, 4)..".wav" )

	-- Find a better sound :X
	surface.PlaySound( "buttons/button15.wav" )

end*/
