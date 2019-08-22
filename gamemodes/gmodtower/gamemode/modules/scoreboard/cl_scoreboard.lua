
module( "Scoreboard.PlayerList", package.seeall )

DrawRespectIcons = CreateClientConVar( "gmt_respecticons", 1, true, false )
HearRangeV = CreateClientConVar( "gmt_rangevoice", 0, true, true )
/*function Label( strText, parent )

	local lbl = vgui.Create( "Label", parent )
	lbl:SetText( strText )
	lbl.SetTextColor = function( lbl, col )
  		lbl:SetFGColor( col.r, col.g, col.b, col.a )
  	end

	return lbl

end*/

function SinBetween( min, max, time )

    local diff = max - min
    local remain = max - diff

    return ( ( ( math.sin( time ) + 1 ) / 2 ) * diff ) + remain

end

// TAB

TAB = {}
TAB.Order = 1

function TAB:GetText()
	return "PLAYERS"
end

function TAB:OnOpen()
	if ValidPanel( self.Body ) then
		self.Body:OnOpen()
	end
end

function TAB:CreateBody()
	return vgui.Create( "ScoreboardPlayers", self )
end

vgui.Register( "ScoreboardPlayersTab", TAB, "ScoreboardTab" )

// PLAYER LIST

MATERIALS = {
	Add = Scoreboard.GenTexture( "ScoreboardAdd", "icon_add" ),
	//Money = Scoreboard.GenTexture( "ScoreboardMoney", "icon_money" ),
	Trade = Scoreboard.GenTexture( "ScoreboardTrade", "icon_trade" ),
	VIP = Scoreboard.GenTexture( "ScoreboardVIP", "icon_vip" ),
	Admin = Scoreboard.GenTexture( "ScoreboardAdmin", "icon_admin" ),
	Crown = Scoreboard.GenTexture( "ScoreboardCrown", "icon_note_crown" ),
	Finish = Scoreboard.GenTexture( "ScoreboardFinish", "icon_note_finish" ),
	Joystick = Scoreboard.GenTexture( "ScoreboardJoystick", "icon_note_joystick" ),
	Timer = Scoreboard.GenTexture( "ScoreboardTimer", "icon_note_timer" ),
	Trophy1 = Scoreboard.GenTexture( "ScoreboardTrophy1", "icon_note_trophy1" ),
	Trophy2 = Scoreboard.GenTexture( "ScoreboardTrophy2", "icon_note_trophy2" ),
	Trophy3 = Scoreboard.GenTexture( "ScoreboardTrophy3", "icon_note_trophy3" ),
}

LOCATIONS = {
	Gamemode = Scoreboard.GenTexture( "GamemodeFloor", "lobby/gamemode" ),
	Lobby = Scoreboard.GenTexture( "LobbyFloor", "lobby/lobby" ),
	Narnia = Scoreboard.GenTexture( "NarniaFloor", "lobby/narnia" ),
	Suite = Scoreboard.GenTexture( "SuiteFloor", "lobby/suite" ),
}

//Hard code this, I do not want to clean it for now
LOCATIONVALS = {
	[LOCATIONS.Gamemode] = {34, 35, 36, 37},
	[LOCATIONS.Lobby] = {2, 3, 7, 8, 9, 10, 31, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 59},
	[LOCATIONS.Suite] = {4, 5, 6, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 49},
	[LOCATIONS.Narnia] = {51}
}


local gradient = surface.GetTextureID( "VGUI/gradient_up" )
local cheight = CreateClientConVar( "gmt_score_height", 55, true, false )
local function GetPlayerSize()
	return math.Clamp( cheight:GetInt(), 32, 85 )
end

PLAYERS = {}
PLAYERS.Padding = 8
PLAYERS.Size = GetPlayerSize()
PLAYERS.Height = PLAYERS.Size + PLAYERS.Padding

function PLAYERS:Init()
	self.Players = {}
	--self.FakePlayers = {}
	self.NextUpdate = 0.0

	/*self.Slider = vgui.Create( "DNumSlider2", self )
	self.Slider:SetMinMax( 32, 85 )
	self.Slider:SetDecimals( 0 )
	self.Slider:SetConVar( "gmt_score_height" )
	self.Slider.NoText = true*/
end

function PLAYERS:AddPlayer( ply )

	local panel = vgui.Create("ScoreboardPlayer")
	panel:SetParent( self )
	panel:SetPlayer( ply )
	panel:SetVisible( true )

	self.Players[ ply ] = panel

end

function PLAYERS:OnOpen()

	for ply, panel in pairs( self.Players ) do

		if ValidPanel( panel ) then
			panel:OnOpen()
		end

	end

end

function PLAYERS:RemovePlayer( ply )

	if ValidPanel( self.Players[ ply ] ) then
		self.Players[ ply ]:Remove()
		self.Players[ ply ] = nil
	end

end

function PLAYERS:PerformLayout()

	/*if !self.NextLayout then self.NextLayout = CurTime() end
	if self.NextLayout && self.NextLayout > CurTime() then return end

	self.NextLayout = CurTime() + .25*/

	if !self.Players then
		self.Players = {}
	end

	local PlayerSorted = {}

	for ply, panel in pairs( self.Players ) do

		if !IsValid( ply ) then
			self:RemovePlayer( ply )
			continue
		end

		ply.Panel = panel
		table.insert( PlayerSorted, ply )

	end

	table.sort( PlayerSorted, Scoreboard.Customization.PlayersSort )

	local curX = 1
	local curY = 1

	for _, ply in pairs( PlayerSorted ) do

		ply.Panel:InvalidateLayout( true )
		ply.Panel:SetPos( curX, curY )
		ply.Panel:SetWide( self:GetWide() / 2 - 2 )
		ply.Panel:SetTall( self.Height )

		if curX == 1 then
			curX = math.floor( self:GetWide() / 2 ) + 1
		else
			curX = 1
			curY = curY + self.Height + 2
		end

	end

	//Check the end case, do we need to be a little higher?
	if curX > 1 then
		curY = curY + self.Height
	end

	/*self.Slider:SizeToContents()
	self.Slider:SetWide( self:GetWide() - ( self.Padding * 2 ) )
	self.Slider:AlignLeft( self.Padding )
	self.Slider:AlignBottom( 2 )

	curY = curY + self.Slider:GetTall()*/

	self:SetTall( curY )
	self:GetParent():InvalidateLayout()

end

function PLAYERS:PopulatePlayers()

	for ply, panel in pairs( self.Players ) do
		if !IsValid( ply ) then
			self:RemovePlayer( ply )
		else
			panel:SetTall( self.Height )
			panel:InvalidateLayout()
		end
	end

	for _, ply in pairs( player.GetAll() ) do
		if self.Players[ ply ] == nil then
			self:AddPlayer( ply )
		end
	end

end

function PLAYERS:PopulateLoadingPlayers()

	// Fake client support
	--for _, ply in pairs( self.FakePlayers ) do
	--	self:RemovePlayer( ply )
	--end

	// Get new ones
	--FakeClient.RequestFakeClients()

	--for _, ply in pairs( FakeClient.fakeclients ) do
	--	self:AddPlayer( ply )
	--	table.insert( self.FakePlayers, ply )
	--end

end

function PLAYERS:Think()

	if CurTime() < self.NextUpdate then return end

	self.Size = GetPlayerSize()
	self.Height = self.Size + self.Padding

	self:PopulatePlayers()

	if !self.NextLoadingUpdate || self.NextLoadingUpdate < CurTime() then
		self:PopulateLoadingPlayers()
		self.NextLoadingUpdate = CurTime() + 10
	end

	self:InvalidateLayout()
	self.NextUpdate = CurTime() + 1

end

vgui.Register( "ScoreboardPlayers", PLAYERS )


PLAYERAVATAR = {}
PLAYERAVATAR.Size = PLAYERS.Size
PLAYERAVATAR.ButtonSize = 16

function PLAYERAVATAR:Init()

	self.SteamProfile = vgui.Create( "DButton", self )
	self.SteamProfile:SetSize( self.Size, self.Size )
	self.SteamProfile:SetZPos( 1 )
	self.SteamProfile:SetText("")
	self.SteamProfile:SetMouseInputEnabled( true )
	self.SteamProfile.DoClick = function()
		if self.Player then
			self.Player:ShowProfile()
		end
	end
	self.SteamProfile.Paint = function()
		if self.SteamProfile.Hovered then
			surface.SetDrawColor( 0, 0, 0, 100 )
			surface.DrawRect( 0, 0, self:GetSize() )
		end
	end

	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:SetSize( self.Size, self.Size )
	self.Avatar:SetMouseInputEnabled( false )

	/*self.SteamProfile = vgui.Create( "DImageButton", self )
	self.SteamProfile:SetSize( self.ButtonSize, self.ButtonSize )
	self.SteamProfile:SetZPos( 1 )
	self.SteamProfile:SetImage( "icon16/vcard.png" )
	self.SteamProfile:AlignLeft()
	self.SteamProfile:SetMouseInputEnabled( true )
	self.SteamProfile.DoClick = function()
		if self.Player then
			self.Player:ShowProfile()
		end
	end

	self.Mute = vgui.Create( "DImageButton", self )
	self.Mute:SetSize( self.ButtonSize, self.ButtonSize )
	self.Mute:SetZPos( 1 )
	self.Mute:AlignRight( 8 )
	self.Mute:SetMouseInputEnabled( true )

	self.BG = vgui.Create( "DPanel", self )
	self.BG:SetSize( self.Size, self.ButtonSize )
	self.BG:AlignLeft()
	self.BG:SetMouseInputEnabled( false )
	self.BG.Paint = function( w,h )
		surface.SetDrawColor( 0, 0, 0, 230 )
		surface.DrawRect( 0, 0, self.BG:GetSize() )
	end

	self:SetButtonPos( 0, self.Size - self.ButtonSize )*/

end

/*PLAYERAVATAR.HideYPos = PLAYERAVATAR.Size + PLAYERAVATAR.ButtonSize

function PLAYERAVATAR:Think()

	local size = GetPlayerSize()
	self.HideYPos = size + self.ButtonSize

	if !self.YPos then
		self.YPos = self.HideYPos
	end

	if self.YPos == self.HideYPos then
		self:SetVisibleButtons( false )
	end

	local pos = self.HideYPos

	if self:IsMouseOver() then
		self:SetVisibleButtons( true )
		pos = self.Size - self.ButtonSize
	end

	self.YPos = math.Approach( self.YPos, pos, FrameTime() * 200 )
	self:SetButtonPos( 0, self.YPos )



	if !self.Mute:IsVisible() || !IsValid( self.Player ) then return end

	if self.Muted == nil || self.Muted != self.Player:IsMuted() then

		self.Muted = self.Player:IsMuted()
		if self.Muted then
			self.Mute:SetImage( "icon16/sound_mute.png" )
		else
			self.Mute:SetImage( "icon16/sound.png" )
		end

		self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

	end

end*/

function PLAYERAVATAR:PerformLayout()
	local size = GetPlayerSize()
	self.Avatar:SetSize( size, size )
end

/*function PLAYERAVATAR:IsMouseOver()

	local x,y = self:CursorPos()
	return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()

end

function PLAYERAVATAR:SetVisibleButtons( bool )
	self.SteamProfile:SetVisible( bool )
	self.Mute:SetVisible( bool )
	self.BG:SetVisible( bool )
end

function PLAYERAVATAR:SetButtonPos( x, y )
	self.SteamProfile:SetPos( x, y )
	self.Mute:SetPos( x, y )
	self.BG:SetPos( x, y )

	self.SteamProfile:AlignLeft()
	self.Mute:AlignRight()
end*/

function PLAYERAVATAR:SetPlayer( ply )

	self.Player = ply
	self.Avatar:SetPlayer( ply, self.Size )

end

vgui.Register( "ScoreboardPlayerAvatar", PLAYERAVATAR )


PLAYER = {}

function PLAYER:Init()

	self:SetTall( PLAYERS.Height )

	self.Avatar = vgui.Create( "ScoreboardPlayerAvatar", self )
	self.Avatar:SetPos( 8, 8 )
	self.Avatar:SetSize( PLAYERAVATAR.Size, PLAYERAVATAR.Size )
	self.Avatar:SetZPos( 1 )
	self.Avatar:SetMouseInputEnabled( true )

	//self.Name = Label( "", self )
	//self.Name:SetFont("SCPlyName")
	//self.Name:SetTextColor( Scoreboard.Customization.ColorFont )
	//self.Name:SetZPos( 0 )

	self.Info = vgui.Create( "ScoreboardPlayerInfo", self )
	self.Info:SetZPos( 1 )

	self.Action = vgui.Create( "ScoreboardActionBox", self )

end

function PLAYER:SetupNotificationIcon()
	if self.NotificationIcon then return end
	self.NotificationIcon = vgui.Create( "DImage", self )
	self.NotificationIcon:SetSize( 24, 24 )
	self.NotificationIcon:SetZPos( 2 )
	self.NotificationIcon:SetMouseInputEnabled( false )
end

function PLAYER:SetupSubtitle()
	if self.Subtitle then return end
	self.Subtitle = vgui.Create( "DLabel", self )
	self.Subtitle:SetFont("SCPlyLabel")
	self.Subtitle:SetTextColor( Scoreboard.Customization.ColorFont )
end

function PLAYER:OnOpen()

	self.Action:SetWide( 0 )
	self:InvalidateLayout()

end

function PLAYER:SetPlayer( ply )

	self.Player = ply

	self.Avatar:SetPlayer( ply, 64 )
	self.Avatar:SetVisible( true )

	self.Info:SetPlayer( ply )

end

function PLAYER:PerformLayout()

	local size = GetPlayerSize()
	local height = size + PLAYERS.Padding
	self:SetTall( height )

	self.Avatar:AlignTop( 4 )
	self.Avatar:SetSize( size, size )

	//self.Name:SizeToContents()
	//self.Name:MoveRightOf( self.Avatar, 5 )
	//self.Name:CenterVertical( 0.3 )

	self.Info:CenterVertical()
	self.Info:AlignRight()

	if self.NotificationIcon then
		self.NotificationIcon:MoveRightOf( self.Avatar, -8 )
		self.NotificationIcon:AlignBottom( -2 )
	end

	if self.Subtitle then
		self.Subtitle:SizeToContents()
		self.Subtitle:CenterVertical( 0.75 )

		if self.NotificationIcon && self.NotificationIcon:GetMaterial() then
			self.Subtitle:MoveRightOf( self.Avatar, 20 )
		else
			self.Subtitle:MoveRightOf( self.Avatar, 5 )
		end
	end

end

function PLAYER:Update()

	// Name
	//self.Name:SetText( self.Player:Name() )

	// Avatar res
	local size = GetPlayerSize()
	local res = 64
	if size > 64 then res = 128 end

	if self.Res != res then
		self.Res = res
		self.Avatar:SetPlayer( self.Player, res )
	end

	// Action box
	if self.Action then
		self.Action:InvalidateLayout()
	end

	// Subtitle
	local subtitle = Scoreboard.Customization.PlayerSubtitleText( self.Player )

	if subtitle && subtitle != "" then
		self:SetupSubtitle()
		self.Subtitle:SetText( subtitle )
	else
		if self.Subtitle then
			self.Subtitle:Remove()
			self.Subtitle = nil
		end
	end

	// Notification icon
	local noteicon = Scoreboard.Customization.PlayerNotificationIcon( self.Player )

	if noteicon then
		self:SetupNotificationIcon()
		if noteicon != self.NotificationIcon:GetMaterial() then
			self.NotificationIcon:SetMaterial( noteicon )
		end
	else
		if self.NotificationIcon then
			self.NotificationIcon:Remove()
			self.NotificationIcon = nil
		end
	end

	// Background
	self.BackgroundMaterial = Scoreboard.Customization.PlayerBackgroundMaterial( self.Player )

end

function PLAYER:Paint( w, h )

	local bgcolor = Scoreboard.Customization.ColorNormal

	if self.Player.IsLoading then
		bgcolor = Scoreboard.Customization.ColorDark
	end

	surface.SetDrawColor( bgcolor )
	surface.DrawRect( 0, 0, self:GetSize() )

		self:DrawBackground()

	if !IsValid( self.Player ) then return end

	// Yourself!
	if self.Player == LocalPlayer() then

		local col = Scoreboard.Customization.ColorBright
		local alpha = SinBetween( 0, 150, CurTime() * 2 )
		--local alpha = 0.5 + math.sin(SysTime()) * 0.5
		surface.SetDrawColor( Color( col.r, col.g, col.b, alpha ) )
		surface.DrawRect( 0, 0, w, h )

	end


	// Border start
	local borderSize = 1
	surface.SetDrawColor( Scoreboard.Customization.ColorDark )

	local DrawRespectBorder = self.Player:IsAdmin() || --[[( self.Player:IsVIP() ) || ]]
							  ( self.Player.IsDeveloper && self.Player:IsDeveloper() ) || ( self.Player.IsGModDeveloper && self.Player:IsGModDeveloper() )

	// Border effects
	if DrawRespectBorder then

		borderSize = 2

		local color = self.Player:GetDisplayTextColor()
		local colorDark = Color( color.r * .5, color.g * .5, color.b * .5, 255 )

		surface.SetDrawColor( Color( SinBetween( colorDark.r, color.r, CurTime() * 4 ), SinBetween( colorDark.g, color.g, CurTime() * 4 ), SinBetween( colorDark.b, color.b, CurTime() * 4 ), 255 ) )
		--surface.SetDrawColor( Color( 255, 255, 255, 255 ) )

		// Border
		surface.DrawRect( self.Avatar.x - ( borderSize * 4 ), self.Avatar.y - 1, borderSize * 4, self.Avatar:GetTall() + 2 )

		borderSize = 1
		surface.DrawRect( self.Avatar.x - borderSize, self.Avatar.y - borderSize, self.Avatar:GetWide() + ( borderSize * 2 ), self.Avatar:GetTall() + ( borderSize * 2 ) )

	else

		// Normal border
		surface.DrawRect( self.Avatar.x - borderSize, self.Avatar.y - borderSize, self.Avatar:GetWide() + ( borderSize * 2 ), self.Avatar:GetTall() + ( borderSize * 2 ) )

	end

	// Jazz effect (for winning the gamemode)
	local NoteIconSize = Scoreboard.Customization.PlayerNotificationIconSize
	if Scoreboard.Customization.PlayerAvatarJazz( self.Player ) then

		//BG
		local col = Scoreboard.Customization.ColorBright
		local alpha = SinBetween( 0, 200, CurTime() * 5 )
		surface.SetDrawColor( Color( col.r, col.g, col.b, alpha ) )
		surface.DrawRect( 0, 0, self:GetSize() )

		//Border
		local shift = SinBetween( 50, 150, CurTime() * 5 )
		jazzborderSize = SinBetween( 2, 6, CurTime() * 5 )

		surface.SetDrawColor( Color( math.random( shift, 255 ), math.random( shift, 255 ), math.random( shift, 255 ), 255 ) )

		//Notification Icon
		if self.NotificationIcon then
			local size = SinBetween( NoteIconSize, NoteIconSize * 1.35, CurTime() * 5 )
			self.NotificationIcon:SetSize( size, size )
		end

		// Border
		surface.DrawRect( self.Avatar.x - jazzborderSize, self.Avatar.y - jazzborderSize, self.Avatar:GetWide() + ( jazzborderSize * 2 ) + 2, self.Avatar:GetTall() + ( jazzborderSize * 2 ) + 2 )

	else

		// Normal notification icon
		if self.NotificationIcon then
			if self.NotificationIcon:GetSize() != NoteIconSize then
				self.NotificationIcon:SetSize( NoteIconSize, NoteIconSize )
			end
		end

	end

	// Name
	local nameX = self.Avatar.x + self.Avatar:GetWide() + 5
	local nameY = self.Avatar.y - 6 + ( self.PlayerNameOffset or 0 )
	local name = self.Player:GetName()

	surface.SetFont( "SCPlyName" )

	// Actual name
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( nameX, nameY )
	surface.DrawText( name )

	// Drop shadow
	/*surface.SetTextColor( 0, 0, 0, 80 )
	surface.SetTextPos( nameX + 2, nameY + 2 )
	surface.DrawText( name )

	local w, h = surface.GetTextSize( name )

	// Underline
	if DrawRespectBorder then
		surface.DrawRect( nameX, nameY + h - 5, w, 2 )
	end*/

end

function PLAYER:OnMousePressed( mc )

	if mc == MOUSE_LEFT then
		self.ActionBoxOn = !self.ActionBoxOn
	end

	//if !LocalPlayer():IsDeveloper() && !LocalPlayer():IsAdmin() then return end
	//if mc == MOUSE_LEFT then return end

	if GtowerMenu:IsOpen() then
		GtowerMenu:CloseAll()
		return
	end

    GtowerClintClick:ClickOnPlayer( self.Player, mc )

end

function PLAYER:DrawBackground()
	if self.BackgroundMaterial then
		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.SetMaterial( self.BackgroundMaterial )
		surface.DrawTexturedRect( 0, 0, 512, math.max( self:GetTall(), 80 ) )

	end

end

function PLAYER:Think()

	if IsValid( self.Player ) then
		self.Info:Update()
		self:Update()
		//self.Avatar:InvalidateLayout( true )
		//self.Info:InvalidateLayout( true )
	end

	// Not enabled
	if !Scoreboard.Customization.PlayerActionBoxEnabled then
		self.Action:SetVisible( false )
		return
	end

	if !ValidPanel( self.Action ) then return end

	if self:IsMouseInWindow() && self.Player != LocalPlayer() && !Scoreboard.Customization.PlayerActionBoxAlwaysShow then
		self:SetCursor( "hand" )
	else
		self:SetCursor( "default" )
	end

	local TargetWidth = 0
	local Speed = 15

	if Scoreboard.Customization.PlayerActionBoxAlwaysShow || ( self.ActionBoxOn && self.Player != LocalPlayer() ) then
		TargetWidth = self.Action.TargetWidth
	end

	local CurrentWidth = self.Action:GetWide()
	local Step = math.max( math.abs( CurrentWidth - TargetWidth ) * FrameTime() * Speed, 1 )

	self.Action:SetWide( math.Approach( CurrentWidth, TargetWidth, Step ) )

	// Draw the action box now...
	local ActionVisible = ( self.Action:GetWide() >= 1 ) && !self.Player.IsLoading
	self.Action:SetVisible( ActionVisible )

	if ActionVisible then
		self.Action:AlignRight()
		self.Action:CenterVertical()

		self.Info:MoveLeftOf( self.Action )
	end

end

function PLAYER:IsMouseInWindow()

    local x,y = self:CursorPos()
    return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()

end

vgui.Register("ScoreboardPlayer", PLAYER )




PLAYERINFO = {}
PLAYERINFO.Padding = 4

function PLAYERINFO:Init()

	self:SetSize( 112, self:GetParent():GetTall() )

	self.Value = Label(0, self)
	self.Value:SetFont( "SCPlyValue" )
	self.Value:SetTextColor( Scoreboard.Customization.ColorFont )

	self.ValueIconPanel = vgui.Create( "DImage", self )
	self.ValueIconPanel:SetSize( 16, 16 )

	local icon = Scoreboard.Customization.PlayerInfoValueIcon
	if icon then
		self.ValueIconPanel:SetMaterial( icon )
	end

	self.Ping = vgui.Create("LabelPing", self )

	//self:SetMouseInputEnabled( false )

end

function PLAYERINFO:OnMousePressed( mc )

	if mc == MOUSE_LEFT then
		self:GetParent().ActionBoxOn = !self:GetParent().ActionBoxOn
	end

end

function PLAYERINFO:SetPlayer( ply )

	self.Player = ply
	self.Ping:SetPlayer( ply )

end

function PLAYERINFO:Update()
	if Scoreboard.Customization.PlayerInfoValueVisible( self.Player ) then
		self.Value:SetText( Scoreboard.Customization.PlayerInfoValueGet( self.Player ) )
		self.Value:SizeToContents()
	end

	// Handle respect icons
	if DrawRespectIcons:GetBool() && self:RespectType() then

		if !ValidPanel( self.RespectIcon ) then
			self.RespectIcon = vgui.Create( "LabelIcon", self )
			self.RespectIcon.NoDrawSelectionBackground = true
			self.RespectIcon.IsLabel = true
		end

	else

		if ValidPanel( self.RespectIcon ) then
			self.RespectIcon:Remove()
			self.RespectIcon = nil
		end

	end

	// Subtitle Right
	local subtitleRight = Scoreboard.Customization.PlayerSubtitleRightText( self.Player )

	if subtitleRight && subtitleRight != "" then
		self:SetupRightSubtitle()
		self.SubtitleRight:SetText( subtitleRight )

		// Position
		local widealign = self.Ping:GetWide()
		if ValidPanel( self.RespectIcon ) && DrawRespectIcons:GetBool() && self:RespectType() then
			widealign = self.Ping:GetWide() + self.RespectIcon:GetWide()
		end

		self.SubtitleRight:AlignRight( widealign + ( self.Padding * 2 ) + 2 )

	else
		if self.SubtitleRight then
			self.SubtitleRight:Remove()
			self.SubtitleRight = nil
		end
	end

end

function PLAYERINFO:SetupRightSubtitle()
	if self.SubtitleRight then return end
	self.SubtitleRight = vgui.Create( "DLabel", self )
	self.SubtitleRight:SetFont("SCPlyLabel")
	self.SubtitleRight:SetTextColor( Scoreboard.Customization.ColorFont )
end

function PLAYERINFO:PerformLayout()

	local wide = 0

	if Scoreboard.Customization.PlayerInfoValueVisible( self.Player ) then

		self.Value:SetVisible( true )
		self.Value:SizeToContents()
		self.Value:CenterVertical( 0.25 )
		self.Value:AlignRight( self.Padding )

		self.ValueIconPanel:SetVisible( true )
		self.ValueIconPanel:AlignRight( self.Value:GetWide() + ( self.Padding * 2 ) )
		self.ValueIconPanel:CenterVertical( 0.25 )

		wide = wide + self.Value:GetWide()

	else
		self.Value:SetVisible( false )
		self.ValueIconPanel:SetVisible( false )
	end

	self.Ping:InvalidateLayout( true )
	self.Ping:CenterVertical( 0.75 )
	self.Ping:AlignRight( self.Padding )

	if self.Ping:IsVisible() then
		wide = wide + self.Ping:GetWide()
	end


	if ValidPanel( self.RespectIcon ) then

		local value, iconMaterial = self:RespectType()

		if value then

			self.RespectIcon:SetMaterial( iconMaterial, 16, 16, 16, 16 )
			self.RespectIcon:SetText( value )
			self.RespectIcon:InvalidateLayout( true )
			self.RespectIcon:CenterVertical( 0.75 )
			self.RespectIcon:AlignRight( self.Ping:GetWide() + ( self.Padding * 2 ) )

			local wideto = wide + self.RespectIcon:GetWide() + ( self.Padding * 2 )
			if wide < wideto then
				wide = wideto
			end
		end

	end

	if ValidPanel( self.SubtitleRight ) && self.SubtitleRight:GetText() != "" then

		self.SubtitleRight:SizeToContents()
		self.SubtitleRight:SetColor( Color( 255, 255, 255, 100 ) )
		self.SubtitleRight:CenterVertical( 0.75 )

		local wideto = wide + self.SubtitleRight:GetWide() + ( self.Padding * 2 ) + 2
		if wide < wideto then
			wide = wideto
		end
	end

	self:SetSize( wide, self:GetParent():GetTall() )

end

function PLAYERINFO:RespectType()

	if self.Player:GetTitle() != nil then

		return self.Player:GetTitle(), MATERIALS.Admin

	--elseif self.Player.IsGModDeveloper && self.Player:IsGModDeveloper() then

		--return "GMOD DEV", MATERIALS.Admin

	--elseif self.Player.IsDeveloper && self.Player:IsDeveloper() then

		--return "DEV", MATERIALS.Admin

	--elseif self.Player:IsVIP() then

	--	return "DONOR", MATERIALS.VIP

	end

end

function PLAYERINFO:Paint( w, h )

	local bgcolor = Scoreboard.Customization.ColorNormal

	if self.Player.IsLoading then
		bgcolor = Scoreboard.Customization.ColorDark
	end

	surface.SetDrawColor( bgcolor )
	surface.DrawRect( 0, 0, w, h )

	// Yourself!
	if self.Player == LocalPlayer() then

		local col = Scoreboard.Customization.ColorBright
		local alpha = SinBetween( 0, 150, CurTime() * 2 )
		--local alpha = 0.5 + math.sin(SysTime()) * 0.5
		surface.SetDrawColor( Color( col.r, col.g, col.b, alpha ) )
		surface.DrawRect( 0, 0, w, h )

	end

	// Jazz effect (for winning the gamemode)
	if Scoreboard.Customization.PlayerAvatarJazz( self.Player ) then

		local col = Scoreboard.Customization.ColorBright
		local alpha = SinBetween( 0, 200, CurTime() * 5 )
		--local alpha = 0.5 + math.sin(SysTime()) * 0.5
		surface.SetDrawColor( Color( col.r, col.g, col.b, alpha ) )
		surface.DrawRect( 0, 0, w, h )

	end

	//surface.SetDrawColor( Color( 255, 0, 0 ) )
	//surface.DrawRect( 0, 0, w, h )

end

vgui.Register("ScoreboardPlayerInfo", PLAYERINFO )




LABELICON = {}
LABELICON.WPadding = 16
LABELICON.HPadding = 4

function LABELICON:Init()

	self.Title = Label("", self)
	self.Title:SetFont("SCPlyLoc")
	self.Title:SetTextColor( Scoreboard.Customization.ColorFont )
	self.Title:SetZPos( 0 )

	/*self.TitleShadow = Label("125", self )
	self.TitleShadow:SetFont("SCPlyLoc")
	self.TitleShadow:SetTextColor( Scoreboard.Customization.ColorFontShadow )
	self.TitleShadow:SetZPos( -1 )*/

end

function LABELICON:SetMaterial( material, actW, actH, width, height )

	self.Material = material
	self.actW = actW
	self.actH = actH
	self.MaterialWidth = width
	self.MaterialHeight = height

end

function LABELICON:SetText( title, color )

	self.Text = title

	if !color then
		color = Scoreboard.Customization.ColorFont
	end

	self.Title:SetTextColor( color )

	self:UpdateText()

end

function LABELICON:UpdateText()

	local title = self.Text

	if !title then return end

	if self.ValueFunc && IsValid( self:GetParent():GetPlayer() ) then
		title = self.Text .. ":  " .. self.ValueFunc( self:GetParent():GetPlayer() )
	end

	self.Title:SetText( title )
	self.Title:SizeToContents()

	//self.TitleShadow:SetText( title )
	//self.TitleShadow:SizeToContents()

end

function LABELICON:SetValue( func )
	self.ValueFunc = func
end

function LABELICON:Paint( w, h )

	if self.OnMousePressed && !self.IsLabel && !self.NoDrawSelectionBackground && self:IsMouseInWindow() then
		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.DrawRect( 0, 0, self:GetSize() )
	end

	if self.Material then
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( self.Material )

		local x = 0

		if !self.IsLabel then
			x = self.WPadding / 2
		end

		surface.DrawTexturedRect( x, self.HPadding / 2, self.MaterialWidth, self.MaterialHeight )
	end
	//surface.SetDrawColor( 255, 0, 0, 150 )
	//surface.DrawRect( 0, 0, self:GetSize() )

end

function LABELICON:IsMouseInWindow()

    local x,y = self:CursorPos()
    return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()

end

function LABELICON:PerformLayout()

	self:UpdateText()

	self.Title:SizeToContents()
	self.Title:CenterVertical()
	self.Title:CenterHorizontal()

	local wide = self.Title:GetWide()
	local tall = self.Title:GetTall()

	if !self.IsLabel then
		wide = wide + self.WPadding
		tall = tall + self.HPadding
	end

	if self.Material then
		self.Title.x = self.actW + 4
		wide = self.actW + 4 + wide

		if !self.IsLabel then
			self.Title.x = self.Title.x + ( self.WPadding / 2 )
			wide = wide + ( self.WPadding / 2 )
		end
	else
		self.Title.x = ( self.WPadding / 2 )
		wide = wide + ( self.WPadding / 2 )
	end

	self:SetSize( wide, tall )

	//self.TitleShadow.x = self.Title.x + 2
	//self.TitleShadow.y = self.Title.y + 2

end

vgui.Register( "LabelIcon", LABELICON )



LABELPING = {}

function LABELPING:Init()

	self.Label = Label("125", self )
	self.Label:SetFont("SCPlyLoc")
	self.Label:SetTextColor( Scoreboard.Customization.ColorFont )
	self.Label:SetZPos( 0 )
	self.Label:SetMouseInputEnabled( false )

	self.Mute = vgui.Create( "DImageButton", self )
	self.Mute:SetSize( 16, 16 )
	self.Mute:SetZPos( 1 )
	self.Mute:SetMouseInputEnabled( true )

	self.PingBars = vgui.Create( "PingBars", self )
	self.PingBars:SetSize( 14, 16 )
	self.PingBars:SetZPos( 0 )

	/*self.LabelShadow = Label("125", self )
	self.LabelShadow:SetFont("SCPlyLoc")
	self.LabelShadow:SetTextColor( Scoreboard.Customization.ColorFontShadow )
	self.LabelShadow:SetZPos( -1 )*/

end

function LABELPING:SetPing( ping )

	self.Label:SetText( ping )
	self.Label:SizeToContents()
	//self.LabelShadow:SetText( ping )

end

function LABELPING:SetPlayer( ply )
	self.Player = ply
end

function LABELPING:PerformLayout()

	self.Mute:AlignRight()
	self.PingBars:AlignLeft( 4 )
	self.Label:AlignLeft( self.PingBars:GetWide() + 4 )

	self:SetSize( self.Mute:GetWide() + 24 + self.PingBars:GetWide() + 2, 16 )

	//self.LabelShadow.x = self.Label.x + 2
	//self.LabelShadow.y = self.Label.y + 2

end

function LABELPING:Think()

	if !IsValid( self.Player ) then return end

	self:SetPing( self.Player:Ping() )
	self.PingBars:SetPing( self.Player:Ping() )

	if self.Player == LocalPlayer() then
		self.Mute:SetVisible( false )
		return
	end

	if !self.Muted then
		if self.Mute.Hovered then
			self.Mute:SetColor( Color( 200, 200, 200 ) )
		else
			self.Mute:SetColor( Color( 255, 255, 255 ) )
		end
	end

	if self.Muted == nil || self.Muted != self.Player:IsMuted() then

		self.Muted = self.Player:IsMuted()
		if self.Muted then
			self.Mute:SetColor( Color( 255, 50, 50 ) )
			self.Mute:SetImage( Scoreboard.Customization.MatDirectory .. "icon_micmute.png" )
		else
			self.Mute:SetColor( Color( 255, 255, 255 ) )
			self.Mute:SetImage( Scoreboard.Customization.MatDirectory .. "icon_mic.png" )
		end

		self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

	end

end

vgui.Register( "LabelPing", LABELPING )


PINGBARS = {}
PINGBARS.Heights = { 3, 6, 9 }
PINGBARS.PingAmounts = { 300, 200, 100 }
PINGBARS.BaseSpacing = 1
PINGBARS.Ping = 1

function PINGBARS:SetPing( ping )
	self.Ping = ping
end

function PINGBARS:Paint( w, h )

	local height = self:GetTall()
	local ping = tonumber( self.Ping )
	local x = 0

	if !ping then return end

	// BG
	surface.SetDrawColor( 255, 255, 255, 10 )

	for _, h in pairs( self.Heights ) do
		surface.DrawRect( x, height - h - self.BaseSpacing, 3, h )
		x = x + 4
	end

	// Lit/Main
	x = 0
	surface.SetDrawColor( 255, 255, 255, 255 )

	for i=1, #self.Heights do

		local h = self.Heights[i]

		if ping < self.PingAmounts[i] then
			surface.DrawRect( x, height - h - self.BaseSpacing, 3, h )
		end

		x = x + 4

	end

end

vgui.Register( "PingBars", PINGBARS )





ACTIONBOX = {}
ACTIONBOX.TargetWidth = 0

function ACTIONBOX:Init()

	self.Items = {}
	hook.Call( "PlayerActionBoxPanel", GAMEMODE, self )

end

function ACTIONBOX:CreateItem()

	local item = vgui.Create( "LabelIcon", self )

	item:SetMouseInputEnabled( true )
	item:SetCursor( "hand" )
	item.GetPlayer = function()
		return self:GetPlayer()
	end

	table.insert( self.Items, item )

	return item

end

function ACTIONBOX:GetPlayer()
	return self:GetParent().Player
end

function ACTIONBOX:Paint( w, h )

	local color = Scoreboard.Customization.ColorDark
	//surface.SetDrawColor( color.r + 80, color.g + 80, color.b + 80, 255 )
	surface.SetDrawColor( color.r, color.g, color.b, Scoreboard.Customization.PlayerActionBoxBGAlpha )
	surface.DrawRect( 0, 0, self:GetSize() )

	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.SetTexture( gradient )
	surface.DrawTexturedRect( 0, 0, self:GetSize() )

end

function ACTIONBOX:PerformLayout()

	local ply = self:GetPlayer()

	if #self.Items == 0 then
		self:SetSize( 0, 0 )
		return
	end

	local size = GetPlayerSize()
	self:SetTall( size )

	local top = true
	local curX = 0
	local maxWidth = 0
	local ply = self:GetPlayer()

	for _, panel in pairs( self.Items ) do

		if panel.UpdateVisible then
			panel:SetVisible( panel:UpdateVisible( ply ) )
		end

		if panel:IsVisible() then

			panel:InvalidateLayout( true )
			panel:AlignLeft( curX )

			maxWidth = math.max( maxWidth, panel:GetWide() )

			if top == true then
				panel:CenterVertical( 0.28 )
			else
				panel:CenterVertical( 0.72 )
				curX = curX + maxWidth
				maxWidth = 0
			end

			top = !top

		end

	end

	self.TargetWidth = curX + maxWidth

	if Scoreboard.Customization.PlayerActionBoxRightPadding then
		self:AlignRight( Scoreboard.Customization.PlayerActionBoxRightPadding )
	end

	if Scoreboard.Customization.PlayerActionBoxWidth then
		self.TargetWidth = Scoreboard.Customization.PlayerActionBoxWidth
	end


end

vgui.Register("ScoreboardActionBox", ACTIONBOX )

/*ACTIONBOXLABEL = {}

function ACTIONBOXLABEL:Init()

end

function ACTIONBOXLABEL:GetPlayer()
	return self:GetParent().Player
end

function ACTIONBOXLABEL:Paint( w, h )

end

function ACTIONBOXLABEL:PerformLayout()

end

vgui.Register("ScoreboardActionBoxLabel", ACTIONBOXLABEL )*/
