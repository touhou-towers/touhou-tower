

-----------------------------------------------------
local SelectedPlayers = {}
local Pattern = "[^a-zA-Z0-9$]"

local function AddPlayerToList( listpanel, PlayerList, ply, multiselect )

	-- Since AvatarImages aren't clickable and that there is no DAvatarButton or something, we create one!
	local IconBttn = listpanel:Add( "DButton", listpanel )
	IconBttn:SetText( " " )
	IconBttn:SetSize( 64, 64 )
	IconBttn.Player = ply
	IconBttn.Think = function( self )
		if !IsValid( self.Player ) then
			PlayerList[ ply ] = nil
			self:Remove()
		end
	end
	IconBttn.DoClick = function( self )

		if multiselect then
			if table.HasValue( SelectedPlayers, self.Player ) then
				table.remove( SelectedPlayers, table.KeyFromValue( SelectedPlayers, self.Player ) )
			else
				table.uinsert( SelectedPlayers, ply )
			end
		else
			if SelectedPlayers[1] == self.Player then
				SelectedPlayers[1] = nil
			else
				SelectedPlayers[1] = ply
			end
		end
	end

	local NameDraw = vgui.Create( "DPanel", IconBttn )
	NameDraw:SetSize( 64, 64 )
	NameDraw:SetZPos( 2 )
	NameDraw:SetMouseInputEnabled( false )
	NameDraw.Player = ply
	NameDraw.Ticker = draw.NewTicker( 4, 2, math.random( 2, 3 ) )
	NameDraw.Paint = function( self )

		if !IsValid( self.Player ) then return end

		surface.SetDrawColor( 0, 0, 0, 200 )

		if table.HasValue( SelectedPlayers, self.Player ) then
			surface.SetDrawColor( 0, 0, 255, 250 )
		end

		surface.DrawRect( 2, 2, self:GetWide() - 4, 16 )

		draw.TickerText( string.upper( self.Player:GetName() ), "GTowerHUDMainTiny", Color( 255, 255, 255 ), self.Ticker, self:GetWide() )

	end

	local IconAvar = vgui.Create( "AvatarImage", IconBttn )
	IconAvar:SetZPos( 1 )
	IconAvar:SetSize( 64, 64 )

	--if ply:IsHidden() then
		--IconAvar:SetPlayer( nil )
	--else
		IconAvar:SetPlayer( ply, 64 )
	--end

	IconAvar:SetMouseInputEnabled( false )
	IconAvar.Player = ply
	IconAvar.Think = function( self )
		if table.HasValue( SelectedPlayers, self.Player ) then
			self:SetAlpha( 125 )
		else
			self:SetAlpha( 255 )
		end
	end

	-- Add here the namederma whatever it is, make sure you parent it to IconBttn and set SetMouseInputEnabled to false!

end

local function UpdateList( listpanel, PlayerList, multiselect )

	listpanel:Clear()

	for ply, hid in pairs( PlayerList ) do
		if !hid then AddPlayerToList( listpanel, PlayerList, ply, multiselect ) end
	end

end

local function SearchByPlayer( name, PlayerList )

	local searchlen, name = ( #name || 0 ), string.lower( name )
	name = string.gsub( name, Pattern, "" )

	for ply, _ in pairs( PlayerList ) do
		local plname = string.gsub( ply:Name(), Pattern, "" )
		plname = string.lower( string.sub( plname, 1, searchlen ) )

		if string.find( name, plname ) || ( name == "" ) then
			PlayerList[ ply ] = false
		else
			PlayerList[ ply ] = true
		end
	end

end

local function GetPlayerTable()

	local players = {}

	for _, ply in pairs( player.GetAll() ) do
		if ply != LocalPlayer() then
			players[ ply ] = false
		end
	end

	table.sort( players, function( a, b )
		return a:Name() < b:Name()
	end )

	return players

end

function Derma_DuelRequest( strTitle, strText, defaultVal, fnEnter, fnCancel, strButtonText, strButtonCancelText )

	local PlayerList = GetPlayerTable()
	SelectedPlayers = {}

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( strTitle or "Duel!" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( false )
	Window:SetDrawOnTop( true )

	local InnerPanel = vgui.Create( "DPanel", Window )

	local Text = vgui.Create( "DLabel", InnerPanel )
	Text:SetText( strText or "Message Text (Second Parameter)" )
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( color_white )

	local SearchText = vgui.Create( "DLabel", InnerPanel )
	SearchText:SetText( "Player Search" )
	SearchText:SizeToContents()
	SearchText:SetContentAlignment( 5 )
	SearchText:SetTextColor( color_white )

	local ScrlBar = vgui.Create( "DScrollPanel", InnerPanel )

	local ListIcon = vgui.Create( "DIconLayout", ScrlBar )
	ListIcon:SetSpaceY( 5 )
	ListIcon:SetSpaceX( 5 )

	local SearchEntry = vgui.Create( "DTextEntry", InnerPanel )
	SearchEntry:SetText("")
	SearchEntry:SetUpdateOnType( true )
	SearchEntry:SetWide( 250 )
	SearchEntry:SetKeyBoardInputEnabled( true )

	local TextEntry = vgui.Create( "DTextEntry", InnerPanel )
	TextEntry:SetText( 0 )
	TextEntry:SetNumeric( true )
	TextEntry:SetUpdateOnType( true )
	TextEntry:SetWide( 100 )
	TextEntry:RequestFocus()
	TextEntry:SetKeyBoardInputEnabled( true )
	TextEntry.OnValueChange = function( panel )
		value = tonumber( panel:GetValue() )

		if !value || value < 0 || value > Money() then
			value = math.Clamp( value or 0, 0, Money() )
			panel:SetText( value )
		end
	end
	TextEntry.UpdateConvarValue = TextEntry.OnValueChange
	TextEntry.AllowInput = function( panel, sInt )
		local strNumericNumber = "1234567890"

		-- We're going to make it only allow numbers ONLY, fuck floats, fuck negatives
		if sInt == "." || sInt == "-" || sInt == "[" || sInt == "]" || sInt == "(" || sInt == "%" then return true end
		if !string.find(strNumericNumber, sInt) then return true end

		return false
	end

	local TextEntryDesc = vgui.Create( "DLabel", InnerPanel )
	TextEntryDesc:SetText( "MAX GMC TO BET" )
	TextEntryDesc:SizeToContents()
	TextEntryDesc:SetContentAlignment( 5 )
	TextEntryDesc:SetTextColor( color_white )

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )

	local Button = vgui.Create( "DButton", ButtonPanel )
	Button:SetText( strButtonText or "OK" )
	Button:SizeToContents()
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )
	Button:SetPos( 5, 5 )
	Button.DoClick = function()
		Window:Close()
		fnEnter( SelectedPlayers[1], TextEntry:GetValue() )
	end
	Button.Think = function( self )
		if IsValid(SelectedPlayers[1]) then
			self:SetAlpha( 255 )
			self:SetMouseInputEnabled( true )
		else
			self:SetAlpha( 50 )
			self:SetMouseInputEnabled( false )
		end
	end

	local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
	ButtonCancel:SetText( strButtonCancelText or "Cancel" )
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( Button:GetWide() + 20 )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button, 5 )

	ButtonPanel:SetWide( Button:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local w, h = Text:GetSize()
	w = math.max( w, 400 )

	Window:SetSize( w + 50, h + 440 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	Text:CenterHorizontal()
	Text:AlignTop( 5 )

	SearchText:CenterHorizontal()
	SearchText:AlignTop( 30 )

	ScrlBar:StretchToParent( 5, nil, 5, nil )
	ScrlBar:AlignBottom( 5 )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	ScrlBar:SetPos( 5, 75 )
	ScrlBar:SetSize( Window:GetWide() - 20, 250 )

	ListIcon:SetSize( Window:GetWide() - 30, 250 )
	UpdateList( ListIcon, PlayerList )

	TextEntry:CenterHorizontal()
	TextEntry:AlignBottom( 5 )
	TextEntryDesc:CenterHorizontal()
	TextEntryDesc:AlignBottom( 30 )

	-- Had to move this down in order to get the ListIcon
	SearchEntry:CenterHorizontal()
	SearchEntry:AlignTop( 45 )
	SearchEntry.ListPanel = ListIcon
	SearchEntry.OnValueChange = function( panel )
		SearchByPlayer( panel:GetValue(), PlayerList )
		UpdateList( panel.ListPanel, PlayerList )
	end

	Window:MakePopup()
	Window:DoModal()

end



local function GetPlayersInSuite()

	local players = {}

	for _, ply in pairs( player.GetAll() ) do
		if ply:Location() == LocalPlayer():Location() && ply != LocalPlayer() then
			players[ ply ] = false
		end
	end

	table.sort( players, function( a, b )
		return a:Name() < b:Name()
	end )

	return players

end

function Derma_PlayerSuiteRequest( strTitle, strText, fnEnter, fnEnter2, fnCancel, fnClear, strButtonText, strButtonText2, strButtonCancelText )

	local PlayerList = GetPlayersInSuite()
	SelectedPlayers = {}

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( strTitle or "Player Management" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( false )
	Window:SetDrawOnTop( true )

	local InnerPanel = vgui.Create( "DPanel", Window )

	local Text = vgui.Create( "DLabel", InnerPanel )
	Text:SetText( strText or "Message Text (Second Parameter)" )
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( color_white )

	local SearchText = vgui.Create( "DLabel", InnerPanel )
	SearchText:SetText( "Player Search" )
	SearchText:SizeToContents()
	SearchText:SetContentAlignment( 5 )
	SearchText:SetTextColor( color_white )

	local ScrlBar = vgui.Create( "DScrollPanel", InnerPanel )

	local ListIcon = vgui.Create( "DIconLayout", ScrlBar )
	ListIcon:SetSpaceY( 5 )
	ListIcon:SetSpaceX( 5 )

	local SearchEntry = vgui.Create( "DTextEntry", InnerPanel )
	SearchEntry:SetText("")
	SearchEntry:SetUpdateOnType( true )
	SearchEntry:SetWide( 250 )
	SearchEntry:SetKeyBoardInputEnabled( true )

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )

	local Button = vgui.Create( "DButton", ButtonPanel )
	Button:SetText( strButtonText or "OK" )
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )
	Button:SetPos( 5, 5 )
	Button.DoClick = function()
		Window:Close()
		fnEnter( SelectedPlayers )
	end
	Button.Think = function( self )
		if #SelectedPlayers > 0 then
			self:SetAlpha( 255 )
			self:SetMouseInputEnabled( true )
		else
			self:SetAlpha( 50 )
			self:SetMouseInputEnabled( false )
		end
	end

	local Button2 = vgui.Create( "DButton", ButtonPanel )
	Button2:SetText( strButtonText2 or "OK" )
	Button2:SetTall( 20 )
	Button2:SetWide( Button:GetWide() )
	Button2:SetPos( 5, 5 )
	Button2.DoClick = function()
		Window:Close()
		fnEnter2( SelectedPlayers )
	end
	Button2:MoveRightOf( Button, 5 )
	Button2.Think = function( self )
		if #SelectedPlayers > 0 then
			self:SetAlpha( 255 )
			self:SetMouseInputEnabled( true )
		else
			self:SetAlpha( 50 )
			self:SetMouseInputEnabled( false )
		end
	end

	local ButtonClearBans = vgui.Create( "DButton", ButtonPanel )
	ButtonClearBans:SetText( "CLEAR BANS" )
	ButtonClearBans:SetTall( 20 )
	ButtonClearBans:SetWide( Button:GetWide() + 25 )
	ButtonClearBans:SetPos( 5, 5 )
	ButtonClearBans.DoClick = function()
		fnClear()
	end
	ButtonClearBans:MoveRightOf( Button2, 5 )

	local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
	ButtonCancel:SetText( strButtonCancelText or "Cancel" )
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( Button:GetWide() + 20 )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( ButtonClearBans, 5 )

	ButtonPanel:SetWide( Button:GetWide() + 5 + Button2:GetWide() + 5 + ButtonClearBans:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local w, h = Text:GetSize()
	w = math.max( w, 400 )

	Window:SetSize( w + 50, h + 440 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	Text:CenterHorizontal()
	Text:AlignTop( 5 )

	SearchText:CenterHorizontal()
	SearchText:AlignTop( 30 )

	ScrlBar:StretchToParent( 5, nil, 5, nil )
	ScrlBar:AlignBottom( 5 )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	ScrlBar:SetPos( 5, 75 )
	ScrlBar:SetSize( Window:GetWide() - 20, 250 )

	ListIcon:SetSize( Window:GetWide() - 30, 250 )
	UpdateList( ListIcon, PlayerList, true )

	-- Had to move this down in order to get the ListIcon
	SearchEntry:CenterHorizontal()
	SearchEntry:AlignTop( 45 )
	SearchEntry.ListPanel = ListIcon
	SearchEntry.OnValueChange = function( panel )
		SearchByPlayer( panel:GetValue(), PlayerList )
		UpdateList( panel.ListPanel, PlayerList, true )
	end

	Window:MakePopup()
	Window:DoModal()

end
