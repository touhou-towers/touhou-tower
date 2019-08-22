

-----------------------------------------------------
module( "Scoreboard.PlayerList", package.seeall )



DrawRespectIcons = CreateClientConVar( "gmt_scoreboard_respecticons", 1, true, false )

ScoreGridMode = CreateClientConVar( "gmt_scoreboard_grid", 0, true, false )

/*function Label( strText, parent )



	local lbl = vgui.Create( "Label", parent )

	lbl:SetText( strText )

	lbl.SetTextColor = function( lbl, col )

  		lbl:SetFGColor( col.r, col.g, col.b, col.a )

  	end



	return lbl



end*/



// TAB



TAB = {}

TAB.Order = 1

local function CheckBlockedCache(ply)
	if ply.BlockStatus == nil then
		ply.BlockStatus = CheckBlocked(ply)
	end

	return ply.BlockStatus

end

local function CheckFriendCache(ply)
	if ply.FriendStatus == nil then
		ply.FriendStatus = CheckFriendship(ply)
	end

	return ply.FriendStatus

end

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



MATERIALS = {

	Group = Material("icon16/group_add.png"),

	MakeGroupOwner = Scoreboard.GenTexture( "ScoreboardCrown", "icon_note_crown" ),

	KickFromGroup = Material("icon16/group_delete.png"),

	Trade = Material("icon16/arrow_refresh.png"),

	Friend = Material("icon16/heart_add.png"),

	Unfriend = Material("icon16/heart_delete.png"),

	Block = Material("icon16/cancel.png"),

	Unblock = Material("icon16/cancel.png"),

	Mute = Material("icon16/sound_mute.png"),

	Gag = Material("icon16/comments_delete.png"),

	Goto = Material("icon16/arrow_up.png"),

	Tele = Material("icon16/arrow_down.png"),

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



local gradient = surface.GetTextureID( "VGUI/gradient_up" )



--local cheight = CreateClientConVar( "gmt_scoreboard_height", 44, true, false )

local function GetPlayerSize()

	return 42 --math.Clamp( cheight:GetInt(), 32, 64 )

end



PLAYERS = {}

PLAYERS.Tabs = {}

PLAYERS.TabWidth = 125

PLAYERS.TabNames = {

	"All",

	"Location",

	"Group",

	"TU Owner",

	"Admins",

	"Loading",

	"AFK",

	"__________________", -- Yes this is a divider and a hack.

	"Steam Friends",

	"Friends",

	"Blocked",

}

PLAYERS.LobbyOnlyTabs = {

	"Location",

	"Group",

}

PLAYERS.Padding = 8

PLAYERS.Size = GetPlayerSize()

PLAYERS.Height = PLAYERS.Size + PLAYERS.Padding

PLAYERS.PlayersDisplayed = 10

PLAYERS.StartHeight = 1



function PLAYERS:Init()



	self.Players = {}

	self.NextUpdate = 0



	self.PlayerList = vgui.Create("DPanelList2", self)

	self.PlayerList:SetScrollBarColors( Scoreboard.Customization.ColorNormal, Scoreboard.Customization.ColorBackground )

	self.PlayerList:EnableVerticalScrollbar()

	self.PlayerList:EnableHorizontal( false )

	self.PlayerList:SetSpacing( 1 )

	self.PlayerList.Paint = function( panel, w, h ) end



	self.Title = vgui.Create( "DLabel", self )

	self.Title:SetFont("SCPlyLoc")

	self.Title:SetTextColor( Scoreboard.Customization.ColorFont )

	self.Title:SetVisible( false )



	self.Button = vgui.Create("DButton",self)

	self.Button:SetWide( 100 )

	self.Button:SetVisible( false )



	self.ActiveTab = nil

	local firstTab = nil



	// Create the tabs

	for id, name in pairs( self.TabNames ) do



		// Skip tabs that are lobby only

		if !string.StartWith(game.GetMap(),"gmt_build") and table.HasValue( self.LobbyOnlyTabs, name ) then continue end



		local tab = self:CreateTab( id, name )

	end



	// Set the first tab

	timer.Simple(.1, function() self:SetActiveTab( self.Tabs[1] ) end )



	/*self.SearchEntry = vgui.Create( "DTextEntry", self )

	self.SearchEntry:SetPos( 2, self.SearchEntry )

	self.SearchEntry:SetText("Search for player...")

	self.SearchEntry:SetUpdateOnType( true )

	self.SearchEntry:SetKeyBoardInputEnabled( true )

	self.SearchEntry:SetMouseInputEnabled( true )

	self.SearchEntry.m_bBackground = false

	self.SearchEntry.m_colText = Scoreboard.Customization.ColorBright



	self.StartHeight = self.SearchEntry:GetTall() + ( self.SearchEntry.y * 2 )*/



end



function PLAYERS:CreateTab( id, name )



	local tab = vgui.Create( "ScoreboardTabInner", self )



	tab:SetText( name )



	tab:SetOrder( id )

	tab.Name = name



	self:AddTab( tab )

	return tab



end



function PLAYERS:AddTab( tab )



	table.insert( self.Tabs, tab )

	tab:SetParent( self )



end



function PLAYERS:SetActiveTab( tab )



	if ValidPanel( self.ActiveTab ) then

		self.ActiveTab:SetText( self.ActiveTab.Name )

		self.ActiveTab:SetActive( false )

	end



	self.ActiveTab = tab

	self.ActiveTab:SetActive( true )



	self.NextLayout = nil

	self.NextUpdate = CurTime() + .25



	self:PopulatePlayers( true )

	self:InvalidateLayout()



end



function PLAYERS:PerformLayout()



	local position = 5



	-- Set their positions and size

	for _, tab in pairs( self.Tabs ) do



		// Skip tabs that are lobby only

		if !string.StartWith(game.GetMap(),"gmt_build") and table.HasValue( self.LobbyOnlyTabs, tab.Name ) then continue end



		tab:SetTall( 24 )

		tab:InvalidateLayout( true )



		tab:SetPos( 0, position )

		tab:SetWide( self.TabWidth )



		position = position + tab:GetTall()



		-- Gather player number based on player filter tab

		local num = #self:GetPlayerList(tab.Name, true)



		-- Display player number

		tab:SetRightText( num )



		-- Disable or enable tab input

		tab:SetMouseInputEnabled( num > 0 )

		--tab.Disabled = ( num == 0 )



		-- Default to the main tab if there's no players.

		if self.ActiveTab == tab and num == 0 then

			self:SetActiveTab( self.Tabs[1] )

		end



	end



	self.TabHeight = position + 4



	-- Handle title/button height

	if self.Title:IsVisible() or self.Button:IsVisible() then

		self.StartHeight = 24

	else

		self.StartHeight = 1

	end



	-- Player list

	self:SortPlayers()

	self.PlayerList:SetPos( self.TabWidth + 2, self.StartHeight + 1 )

	self.PlayerList:SetWide( self:GetWide() - self.TabWidth - 4 )



	self.Title:AlignLeft(self.PlayerList.x + 2)

	self.Title:AlignTop(4)

	self.Button:AlignLeft(self.PlayerList.x)

	self.Button:AlignTop(1)



	-- Calc height

	local curY = self.StartHeight



	for _, ply in pairs( self.Players ) do

		ply.Panel:InvalidateLayout( true )

		curY = curY + self.Height + 1

	end



	self.PlayerList:SetTall( math.Clamp( curY, self.TabHeight, ( self.PlayersDisplayed * self.Height ) + ( self.Padding + self.StartHeight ) ) )

	self:SetTall( self.PlayerList:GetTall() + 2 + self.StartHeight )



end



function PLAYERS:Paint( w, h )



	//surface.SetDrawColor( Scoreboard.Customization.ColorDark )

	//surface.DrawRect( 0, 0, self:GetWide(), 24 )



	local color = Scoreboard.Customization.ColorDark

	surface.SetDrawColor( color )

	surface.DrawRect( 0, 0, w, h )



	surface.SetDrawColor( color.r - 5, color.g - 5, color.b - 5 )

	surface.DrawRect( self.TabWidth - 2, 4, 4, h )



end



function PLAYERS:SetButton( text, func )



	if not text then

		self.Button:SetVisible( false )

		return

	end



	self.Button:SetText( text )

	self.Button:SetWide( 100 )

	self.Button.DoClick = func

	self.Button:SetVisible( true )



end



function PLAYERS:SetTitle( title )



	if not title then

		self.Title:SetVisible( false )

		return

	end



	self.Title:SetText( title )

	self.Title:SizeToContents()

	self.Title:SetVisible( true )



end



function PLAYERS:OnOpen()



	for ply, panel in pairs( self.Players ) do



		if ValidPanel( panel ) then

			panel:OnOpen()

		end



	end



end



function PLAYERS:AddPlayer( ply )



	local panel = vgui.Create("ScoreboardPlayer", self.PlayerList)

	panel:SetPlayer( ply )

	panel:SetVisible( true )



	self.Players[ ply ] = panel

	self.PlayerList:AddItem( panel )



end



function PLAYERS:RemovePlayer( ply )



	if ValidPanel( self.Players[ ply ] ) then

		self.Players[ ply ]:Remove()

		self.Players[ ply ] = nil

	end



end



local function FilteredPlayerList( players )



	for i=#players, 1, -1 do

		--if Friends.IsBlocked( LocalPlayer(), players[i] ) then
		if players[i]:GetFriendStatus() == "blocked" || CheckBlockedCache(LocalPlayer(players[i])) then

			table.remove( players, i )

		end

	end



	return players



end



function PLAYERS:GetPlayerList( tabname, count )



	local players = {}



	if not count then

		self:SetButton( nil )

		self:SetTitle( nil )

	end



	-- Handle tabs

	if tabname == "All" then

		players = FilteredPlayerList( player.GetAll() )

	end


	if tabname == "Location" then

		if Location then

			--players = FilteredPlayerList( Location.GetPlayersInLocation( LocalPlayer():Location(), true ) )
			players = FilteredPlayerList( GTowerLocation:GetPlayersInLocation( GTowerLocation:GetPlyLocation( LocalPlayer() ) ) )



			-- Handle location title

			if not count then



				-- Get location name

				local title = GTowerLocation:GetName( GTowerLocation:GetPlyLocation( LocalPlayer() ) )



				-- Get room owner

				--[[local RoomID = Location.GetCondoID( GTowerLocation:GetPlyLocation( LocalPlayer() ) )

				if RoomID then

					local Room = GTowerRooms:Get( RoomID )

					if Room and IsValid( Room.Owner ) then

						title = title .. " - Owner: " .. Room.Owner:GetName()

					end

				end]]



				self:SetTitle( title )



			end



		end

	end



	if tabname == "Group" then

		if GTowerGroup and GTowerGroup:GetGroup() then

			players = GTowerGroup:GetGroup()



			if not count then

				self:SetButton( T("Group_leave"), function()

					Derma_Query( T("Group_leavesure"), T("Group_leavesure"),

	   					T("yes"), function() RunConsoleCommand("gmt_leavegroup") end,

   						T("no"), nil

  					)

  				end )

			end

		end

	end



	if tabname == "TU Owner" then

		for _, ply in ipairs( FilteredPlayerList( player.GetAll() ) ) do

			if ( ply:GetNWBool('VIP'))  then

				table.insert( players, ply )

			end

		end
		
		if not count then

			self:SetTitle( "These people have bought the successor to GMTower: Tower Unite" )

		end

	end



	if tabname == "AFK" then

		for _, ply in ipairs( FilteredPlayerList( player.GetAll() ) ) do

			if ply:GetNWBool("AFK") then

				table.insert( players, ply )

			end

		end

	end



	if tabname == "Loading" then

		/*for _, ply in pairs( fakeclients ) do

			table.insert( players, ply )

		end*/

	end



	if tabname == "Admins" then

		for _, ply in ipairs( player.GetAll() ) do

			if ( ply:IsAdmin() && !ply:GetNWBool("SecretAdmin") ) then

				table.insert( players, ply )

			end

		end

	end



	if tabname == "Steam Friends" then

		for _, ply in ipairs( FilteredPlayerList( player.GetAll() ) ) do

			if ply:GetFriendStatus() == "friend" then

				table.insert( players, ply )

			end

		end

	end



	if tabname == "Friends" then

		for _, ply in ipairs( player.GetAll() ) do

			--if Friends.IsFriend( LocalPlayer(), ply ) and not ply:IsHidden() then
			if CheckFriendCache( ply ) then

				table.insert( players, ply )

			end

		end



		if not count then

			self:SetTitle( T("Friends_FriendDesc") )

		end

	end



	if tabname == "Blocked" then

		for _, ply in ipairs( player.GetAll() ) do

			--if Friends.IsBlocked( LocalPlayer(), ply ) and not ply:IsHidden() then
			if ply:GetFriendStatus() == "blocked" || CheckBlockedCache(ply) then

				table.insert( players, ply )

			end

		end



		if not count then

			self:SetTitle( T("Friends_BlockedDesc") )

		end

	end



	return players



end



function PLAYERS:PopulatePlayers( clear )



	local tabname = "All"

	if self.ActiveTab then

		tabname = self.ActiveTab.Name

	end



	local players = self:GetPlayerList( tabname )



	if clear then



		for ply, panel in pairs( self.Players ) do

			self:RemovePlayer( ply )

		end



		for _, ply in pairs( players ) do

			self:AddPlayer( ply )

		end



		self:SortPlayers()



		return

	end



	------------------------------------------------------



	-- Remove players and update current

	for ply, panel in pairs( self.Players ) do

		if !IsValid( ply ) || !table.HasValue( players, ply ) then

			self:RemovePlayer( ply )

		else

			panel:SetTall( self.Height )

			panel:InvalidateLayout()

		end

	end



	-- Gather new players

	for _, ply in pairs( players ) do

		if self.Players[ ply ] == nil then

			self:AddPlayer( ply )

		end

	end



	-- Sort the players

	self:SortPlayers()



end



function PLAYERS:SortPlayers()

	table.sort( self.PlayerList.Items, function( a, b )

		local key = "Player"

		if ( a[ key ] == nil ) then return false end

		if ( b[ key ] == nil ) then return true end

		return Scoreboard.Customization.PlayersSort( a[ key ], b[ key ] )

	end )

end



function PLAYERS:Think()



	--if CurTime() < self.NextUpdate then return end



	self:PopulatePlayers()

	--self.NextUpdate = CurTime() + .25



	self.Size = GetPlayerSize()

	self.Height = self.Size + self.Padding



	-- Add loading players

	if !self.NextLoadingUpdate || self.NextLoadingUpdate < CurTime() then

		--FakeClient.RequestFakeClients()

		self.NextLoadingUpdate = CurTime() + 10

	end



	self:InvalidateLayout()

	self.PlayerList:InvalidateLayout()



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



function PLAYERAVATAR:Think()



		self.Avatar:SetPlayer( self.Player, self.Size )


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

	self.Subtitle:SetFont("SCPlyLoc")

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



	// Draw the action box now...

	local ActionVisible = ( self.Action:GetWide() > 0 ) && !self.Player.IsLoading && Scoreboard.Customization.PlayerActionBoxEnabled

	self.Action:SetVisible( ActionVisible )



	if ActionVisible then

		self.Action:AlignRight()

		self.Action:CenterVertical()



		self.Info:MoveLeftOf( self.Action, 5 )

	else

		self.Info:AlignRight()

	end



	self.Info:AlignBottom()



	if self.NotificationIcon then

		self.NotificationIcon:MoveRightOf( self.Avatar, -8 )

		self.NotificationIcon:AlignBottom( -2 )

	end



	if self.Subtitle then

		self.Subtitle:SizeToContents()

		self.Subtitle:AlignBottom(2)



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

		self.Subtitle:SizeToContents()

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



	if !IsValid( self.Player ) then return end



	// Draw the background

	self:PaintBG( w, h )



	// Border start

	surface.SetDrawColor( Scoreboard.Customization.ColorDark )



	local borderSize = 1

	local DrawRespectBorder = self.Player:GetTitle() and self.Player:GetTitle() ~= "Blocked"



	// Border effects

	if DrawRespectBorder then



		local color = self.Player:GetDisplayTextColor()

		local colorDark = Color( color.r * .5, color.g * .5, color.b * .5, 255 )



		surface.SetDrawColor( Color( SinBetween( colorDark.r, color.r, RealTime() * 4 ), SinBetween( colorDark.g, color.g, RealTime() * 4 ), SinBetween( colorDark.b, color.b, RealTime() * 4 ), 255 ) )



		// Border

		borderSize = 2

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



		// Notification Icon

		if self.NotificationIcon then

			local size = SinBetween( NoteIconSize, NoteIconSize * 1.35, RealTime() * 5 )

			self.NotificationIcon:SetSize( size, size )

		end



		// Border

		local shift = SinBetween( 50, 150, RealTime() * 5 )

		borderSize = SinBetween( 2, 6, RealTime() * 5 )



		surface.SetDrawColor( Color( math.random( shift, 255 ), math.random( shift, 255 ), math.random( shift, 255 ), 255 ) )

		surface.DrawRect( self.Avatar.x - borderSize, self.Avatar.y - borderSize, self.Avatar:GetWide() + ( borderSize * 2 ) + 2, self.Avatar:GetTall() + ( borderSize * 2 ) + 2 )



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

	local name = self.Player:Name() or "Loading..."



	surface.SetFont( "SCPlyName" )



	// Actual name

	surface.SetTextColor( 255, 255, 255, 255 )

	surface.SetTextPos( nameX, nameY )

	surface.DrawText( name )



	// Drop shadow

	surface.SetTextColor( 0, 0, 0, 80 )

	surface.SetTextPos( nameX + 1, nameY + 1 )

	surface.DrawText( name )



	// Underline

	/*local w, h = surface.GetTextSize( name )

	if DrawRespectBorder then

		surface.DrawRect( nameX, nameY + h - 5, w, 2 )

	end*/



end



function PLAYER:PaintBG( w, h )



	if !IsValid( self.Player ) then return end



	// Background color

	local bgcolor = Scoreboard.Customization.ColorNormal

	if self.Player.IsLoading then bgcolor = Scoreboard.Customization.ColorDark end





	surface.SetDrawColor( bgcolor )

	surface.DrawRect( 0, 0, w, h )



	// Background image

	if Scoreboard.Customization.ShowBackgrounds then

		self:DrawBGImage()

	end



	// Highlight yourself!

	if self.Player == LocalPlayer() then



		local col = Scoreboard.Customization.ColorBright

		local alpha = SinBetween( 0, 150, RealTime() * 2 )

		surface.SetDrawColor( Color( col.r, col.g, col.b, alpha ) )

		surface.DrawRect( 0, 0, w, h )



	end



	// Jazz on win

	if Scoreboard.Customization.PlayerAvatarJazz( self.Player ) then



		local col = Scoreboard.Customization.ColorBright

		local alpha = SinBetween( 0, 200, RealTime() * 5 )

		surface.SetDrawColor( Color( col.r, col.g, col.b, alpha ) )

		surface.DrawRect( 0, 0, w, h )



	end



	// On hover

	if self:CanClick() then

		local col = Scoreboard.Customization.ColorBright

		surface.SetDrawColor( Color( col.r, col.g, col.b, 100 ) )

		surface.DrawRect( 0, 0, w, h )

	end



end



function PLAYER:OnMousePressed( mc )



	if mc == MOUSE_LEFT then

		self.ActionBoxOn = !self.ActionBoxOn

	end



	--if !LocalPlayer():IsAdmin() then return end

	if mc == MOUSE_LEFT then return end



	if GTowerMenu:IsOpen() then

		GTowerMenu:CloseAll()

		return

	end


    GTowerClick:ClickOnPlayer( self.Player, mc )



end



function PLAYER:DrawBGImage()



	if self.BackgroundMaterial then



		surface.SetDrawColor( 255, 255, 255, 100 )

		surface.SetMaterial( self.BackgroundMaterial )

		surface.DrawTexturedRect( 0, 0, 512, math.max( self:GetTall(), 80 ) )



	end



end



function PLAYER:CanClick()

	return self:IsMouseInWindow() && self.Player != LocalPlayer() && !Scoreboard.Customization.PlayerActionBoxAlwaysShow && !self.Player.IsLoading && string.StartWith(game.GetMap(),"gmt_build")

end



function PLAYER:Think()



	if IsValid( self.Player ) then

		self.Info:Update()

		self:Update()

		//self.Avatar:InvalidateLayout( true )

		self.Info:InvalidateLayout( true )

	end



	// Not enabled

	if !Scoreboard.Customization.PlayerActionBoxEnabled then

		self.Action:SetVisible( false )

		return

	end



	if !ValidPanel( self.Action ) then return end



	if self:CanClick() then

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



end



function PLAYER:IsMouseInWindow()



    local x,y = self:CursorPos()

    return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()



end



vgui.Register("ScoreboardPlayer", PLAYER )









PLAYERINFO = {}

PLAYERINFO.Padding = 4



function PLAYERINFO:Init()



	self:SetSize( 112, 24 )



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

	if DrawRespectIcons:GetBool() && self:HasRespect() then



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

	if !self.Player:IsAdmin() and CheckFriendCache(self.Player) then

		self:SetupRightSubtitle()
		self.SubtitleRight:SetText( "Friend" )

	elseif !self.Player:IsAdmin() and CheckBlockedCache(self.Player) then

		self:SetupRightSubtitle()
		self.SubtitleRight:SetText( "Blocked" )

	elseif subtitleRight && subtitleRight != "" then

		self:SetupRightSubtitle()
		self.SubtitleRight:SetText( subtitleRight )



		// Position

		local widealign = self.Ping:GetWide()

		if ValidPanel( self.RespectIcon ) && DrawRespectIcons:GetBool() && self:HasRespect() then

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



	local wide = self.Padding



	if Scoreboard.Customization.PlayerInfoValueVisible( self.Player ) then



		self.Value:SetVisible( true )

		self.Value:SizeToContents()

		self.Value:AlignBottom(2)



		self.ValueIconPanel:SetVisible( true )

		self.ValueIconPanel:AlignRight(self.Ping:GetWide()+self.Value:GetWide()+(self.Padding*3))

		self.ValueIconPanel:AlignBottom(2)



		self.Value:MoveRightOf( self.ValueIconPanel, self.Padding )



		wide = wide + self.Value:GetWide() + self.ValueIconPanel:GetWide() + ( self.Padding * 4 )



	else

		self.Value:SetVisible( false )

		self.ValueIconPanel:SetVisible( false )

	end



	self.Ping:InvalidateLayout( true )

	self.Ping:AlignBottom(4)

	self.Ping:AlignRight(2)



	if self.Ping:IsVisible() then

		wide = wide + self.Ping:GetWide()

	end



	if ValidPanel( self.RespectIcon ) then



		local name = self.Player:GetTitle()

		if CheckFriendCache( self.Player ) then
			name = name .. " and friend"
		end



		if name then



			self.RespectIcon:SetText( name )

			self.RespectIcon:SetMouseInputEnabled( false )

			self.RespectIcon:InvalidateLayout( true )

			self.RespectIcon:AlignBottom(2)

			self.RespectIcon:AlignRight( wide + 4 )



			local wideto = wide + self.RespectIcon:GetWide() + ( self.Padding * 2 )

			if wide < wideto then

				wide = wideto

			end

		end



	end



	if ValidPanel( self.SubtitleRight ) && self.SubtitleRight:GetText() != "" then



		self.SubtitleRight:SizeToContents()

		self.SubtitleRight:SetColor( Color( 255, 255, 255, 100 ) )

		self.SubtitleRight:AlignBottom(2)



		local wideto = wide + self.SubtitleRight:GetWide() + ( self.Padding * 2 ) + 2

		if wide < wideto then

			wide = wideto

		end

	end



	self:SetWide( wide )



end



function PLAYERINFO:HasRespect()


	return self.Player:GetTitle()



end



function PLAYERINFO:Paint( w, h )



	PLAYER:PaintBG( w, h )



end



vgui.Register("ScoreboardPlayerInfo", PLAYERINFO )









LABELICON = {}

LABELICON.WPadding = 16

LABELICON.HPadding = 4



function LABELICON:Init()



	self.Title = Label("", self)

	self.Title:SetFont("SCPlyLabel")

	self.Title:SetTextColor( Scoreboard.Customization.ColorFont )

	self.Title:SetZPos( 0 )

	self.Title:SetMouseInputEnabled( false )

	self.Title:SetCursor( "hand" )



	self:SetMouseInputEnabled( false )



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



	self.Title:SetText( title )

	self.Title:SizeToContents()

	self.Title:CenterHorizontal()



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



	local color = Scoreboard.Customization.ColorFont



	self.Label = Label("125", self )

	self.Label:SetFont("SCPlyLabel")

	self.Label:SetTextColor( Color( color.r, color.g, color.b, 150 ) )

	self.Label:SetZPos( 0 )

	self.Label:SetSize( 24, 12 )

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



end



function LABELPING:SetPlayer( ply )

	self.Player = ply

end



function LABELPING:PerformLayout()



	self.Mute:AlignRight()



	self.PingBars:MoveLeftOf( self.Mute, self.Label:GetWide() + 2 )



	self.Label:MoveRightOf( self.PingBars, 1 )

	self.Label:AlignBottom()



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



	--local muted = LocalPlayer():HasMuted( self.Player )
	local muted = false



	/*if self.Muted == nil || self.Muted != self.Player:IsMuted() then



		self.Muted = self.Player:IsMuted()

		if self.Muted then

			self.Mute:SetColor( Color( 255, 50, 50 ) )

			self.Mute:SetImage( Scoreboard.Customization.MatDirectory .. "icon_micmute.png" )

		else

			self.Mute:SetColor( Color( 255, 255, 255 ) )

			self.Mute:SetImage( Scoreboard.Customization.MatDirectory .. "icon_mic.png" )

		end



		self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end*/



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

	surface.SetDrawColor( 255, 255, 255, 150 )



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



function ACTIONBOX:CreateItem( score )



	local item = nil



	if score then

		item = vgui.Create( "LabelScore", self )

		item.IsGrid = false

	else

		item = vgui.Create( "LabelIcon", self )

		item:SetMouseInputEnabled( true )

		item:SetCursor( "hand" )

		item.IsGrid = true

	end



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



	if #self.Items == 0 then

		self:SetSize( 0, 0 )

		return

	end



	self:SetTall( GetPlayerSize() )



	local width = 0

	local offset = 0

	local curX = 0

	local top = true



	local ply = self:GetPlayer()



	for _, panel in pairs( self.Items ) do



		if panel.UpdateVisible then

			panel:SetVisible( panel:UpdateVisible( ply ) )

		end



		if panel:IsVisible() then



			if curX == 0 then

				curX = offset

			end



			panel:InvalidateLayout( true )

			panel:AlignLeft( curX )



			// Grid

			if panel.IsGrid then



				if top == true then

					panel:CenterVertical( 0.28 )

				else

					panel:CenterVertical( 0.72 )

					curX = curX + panel:GetWide()

				end



				top = !top



			// Linear

			else



				curX = curX + panel:GetWide()



			end





		end



	end



	width = curX

	self.TargetWidth = width

	self:SetVisible( width > 0 )



	if Scoreboard.Customization.PlayerActionBoxRightPadding then

		self:AlignRight( Scoreboard.Customization.PlayerActionBoxRightPadding )

	end



	/*if Scoreboard.Customization.PlayerActionBoxWidth then

		self.TargetWidth = Scoreboard.Customization.PlayerActionBoxWidth

	end*/





end



vgui.Register("ScoreboardActionBox", ACTIONBOX )







local LABELSCORE = {}

function LABELSCORE:Init()



	local color = colorutil.Brighten( Scoreboard.Customization.ColorBright, 1.15 )



	self.Title = Label("", self)

	self.Title:SetFont("SCPlyScoreTitle")

	self.Title:SetTextColor( color )

	self.Title:SetZPos( 0 )



	self.Value = Label("", self)

	self.Value:SetFont("SCPlyScore")

	self.Value:SetTextColor( Scoreboard.Customization.ColorFont )

	self.Value:SetZPos( 0 )

	self.Value:SetVisible( false )



end



function LABELSCORE:SetText( title )



	self.Title:SetText( title )

	self:UpdateText()



end



function LABELSCORE:UpdateText()



	if self.ValueFunc && IsValid( self:GetParent():GetPlayer() ) then



		local value = self.ValueFunc( self:GetParent():GetPlayer() )

		if value then

			self.Value:SetText( value )

			self.Value:SetVisible( true )

			self:SetVisible( true )

		else

			self.Value:SetVisible( false )

			self:SetVisible( false )

		end



	end



end



function LABELSCORE:SetValue( func )

	self.ValueFunc = func

end



function LABELSCORE:SetFixedWidth( width )

	self.FixedWidth = width

end



function LABELSCORE:Paint( w, h )



end



function LABELSCORE:PerformLayout()



	self:UpdateText()



	self.Value:AlignTop( 8 )

	self.Title:SizeToContents()

	self.Value:SizeToContents()



	local width = self.FixedWidth or math.max( self.Title:GetWide() + 10, self.Value:GetWide() + 10 )

	self:SetSize( width, GetPlayerSize() )



	self.Title:CenterHorizontal()

	self.Value:CenterHorizontal()



end



vgui.Register( "LabelScore", LABELSCORE )
