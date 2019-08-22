
--Some parts of this code writen by overv. I've got permission to use it.

--The current implementation of a combo box makes it almost the same as a drop down menu.
--If you use SetMultiple to true the player can select multiples ONLY by dragging their mouse down on the options.
--This means options have to be sequential for the player to select them.

surface.CreateFont( "MinigameFont", {
	font = "Oswald", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 45,
	weight = 500,
	antialias = true,
	italic = true,
	shadow = true,
	outline = true,
} )

include("vgui_commandbutton.lua")

local CheckBoxes = {}
local Wangs = {}
local Input = {}

local function TimerCaller( PlyId, id, value )
	RunConsoleCommand( "gmt_clientset", PlyId, id, value )
end

local function InitItems()

	for k, v in ipairs( ClientSettings.Items ) do

		if v.Disabled != true then
			if ClientSettings.DEBUG then Msg("\tAdding ", v.Name, " (".. k .. ")\n") end

			if v.NWType == "Bool" then
				table.insert( CheckBoxes, k )
			elseif ClientSettings:IsNumber( v.NWType ) && v.MinValue && v.MaxValue then
				table.insert( Wangs, k )
			else
				table.insert( Input, k )
			end
		end

	end

	local function SortingItems( a, b)
		local ItemA = ClientSettings.Items[ a ].Order
		local ItemB = ClientSettings.Items[ b ].Order

		if ItemA then
			if ItemB then
				if ItemA == ItemB then
					return a < b
				end

				return ItemA < ItemB
			end
			return true
		end
		return a < b
	end

	table.sort( CheckBoxes, SortingItems )
	table.sort( Wangs, SortingItems )
	table.sort( Input, SortingItems )
end

InitItems()

local function ShowMenu( ply )
if !LocalPlayer():IsAdmin() then return nil end
if !ClientSettings.AdminAllowSend then return nil end
	if ClientSettings.AdminPanel == nil then
		ClientSettings:CreateAdminPanel()
	else
		ClientSettings.AdminPanel:SetVisible( true ) ClientSettings:ScanPlayers()
		for _, v in pairs(ClientSettings.PlayerMenuItems) do if v.InvalidateLayout then v:InvalidateLayout() end end
	end
end
concommand.Add( "gmt_adminmenu", ShowMenu )

function ClientSettings:CreateAdminPanel()
	ClientSettings.AdminPanel = vgui.Create( "DFrame" )
	ClientSettings.AdminPanel:SetPos( ScrW() / 2 - 600 / 2, ScrH() / 2 - 425 / 2 )
	ClientSettings.AdminPanel:SetSize( 600, 425 )
	ClientSettings.AdminPanel:SetTitle( "GMod Tower | Admin Menu" )
	ClientSettings.AdminPanel:SetVisible( true )
	ClientSettings.AdminPanel:SetDraggable( true )
	ClientSettings.AdminPanel:ShowCloseButton( true )
	ClientSettings.AdminPanel:MakePopup()
	ClientSettings.AdminPanel.Close = function()
	ClientSettings.AdminPanel:SetVisible( false )
	end


	ClientSettings.Tabs = vgui.Create( "DPropertySheet" )
	ClientSettings.Tabs:SetParent( ClientSettings.AdminPanel )
	ClientSettings.Tabs:SetPos( 5, 25 )
	ClientSettings.Tabs:SetSize( 590, 395 )

	ClientSettings.TabPlayers = vgui.Create( "DPanel", ClientSettings.Tabs )
	ClientSettings.TabPlayers:SetPos( 5, 10 )
	ClientSettings.TabPlayers:SetSize( 600 - 10, 400 - 15 )
	ClientSettings.TabPlayers.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 0 )
		surface.SetFont("QuestionSmallTitle")
		surface.DrawRect( 0, 0, ClientSettings.TabPlayers:GetWide(), ClientSettings.TabPlayers:GetTall() )
	end

	ClientSettings.TabMultiPlayers = vgui.Create( "DPanel", ClientSettings.Tabs )
	ClientSettings.TabMultiPlayers:SetPos( 5, 10 )
	ClientSettings.TabMultiPlayers:SetSize( 600 - 10, 400 - 15 )
	ClientSettings.TabMultiPlayers.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 0 )
		surface.DrawRect( 0, 0, ClientSettings.TabMultiPlayers:GetWide(), ClientSettings.TabMultiPlayers:GetTall() )
	end

	ClientSettings.TabOther = vgui.Create( "DPanel", ClientSettings.Tabs )
	ClientSettings.TabOther:SetPos( 5, 10 )
	ClientSettings.TabOther:SetSize( 600 - 10, 400 - 15 )
	ClientSettings.TabOther.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 0 )
		surface.DrawRect( 0, 0, ClientSettings.TabOther:GetWide(), ClientSettings.TabOther:GetTall() )
	end

	ClientSettings.TabEvent = vgui.Create( "DPanel", ClientSettings.Tabs )
	ClientSettings.TabEvent:SetPos( 5, 10 )
	ClientSettings.TabEvent:SetSize( 600 - 10, 400 - 15 )
	ClientSettings.TabEvent.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 0 )
		surface.DrawRect( 0, 0, ClientSettings.TabEvent:GetWide(), ClientSettings.TabEvent:GetTall() )
	end

	ClientSettings.TabMiniGames = vgui.Create( "DPanel", ClientSettings.Tabs )
	ClientSettings.TabMiniGames:SetPos( 5, 10 )
	ClientSettings.TabMiniGames:SetSize( 600 - 10, 400 - 15 )
	ClientSettings.TabMiniGames.Paint = function()
		surface.SetDrawColor( 171, 171, 171, 0 )
		surface.DrawRect( 0, 0, ClientSettings.TabMiniGames:GetWide(), ClientSettings.TabMiniGames:GetTall() )
	end

	local button = vgui.Create( "DButton", ClientSettings.TabOther );
	button:SetSize( 100, 30 );
	button:SetPos( 10, 50 );
	button:SetText( "Your Settings" );
	button.DoClick = function( button )
		GtowerClintClick:ClickOnPlayer( LocalPlayer(), 0 )
		timer.Simple(0.1,function()
			GtowerClintClick:ClickOnPlayer( LocalPlayer(), 0 )
		end)
	end

	CreateAdminControls()

	ClientSettings.Tabs:AddSheet( "Players", ClientSettings.TabPlayers, "icon16/user.png", false, false, "Do something with players" )
	ClientSettings.Tabs:AddSheet( "Multiple Players", ClientSettings.TabMultiPlayers, "icon16/user.png", false, false, "Do something with multiple players" )
	ClientSettings.Tabs:AddSheet( "Other", ClientSettings.TabOther, "icon16/user.png", false, false, "Other server settings" )
	ClientSettings.Tabs:AddSheet( "Event System", ClientSettings.TabEvent, "icon16/user.png", false, false, "Event System settings" )
	ClientSettings.Tabs:AddSheet( "Mini Games", ClientSettings.TabMiniGames, "icon16/user.png", false, false, "Mini Games settings" )

end

function CreateAdminControls()
	local restartbutton = vgui.Create( "DButton", ClientSettings.TabOther );
	restartbutton:SetSize( 100, 30 );
	restartbutton:SetPos( 10, 10 );
	restartbutton:SetText( "Restart server" );
	restartbutton.DoClick = function( button )
	if !ClientSettings.AdminAllowSend and !LocalPlayer:IsSuperAdmin() then return nil end
		Derma_Query(
			"Are you sure you want to restart the server?",
			"SERVER RESTART",
			"Yes", function() RunConsoleCommand( "gmt_changelevel" ) end,
			"No", EmptyFunction
		)
	end

	CreateEventControls()
	CreateMiniGamesControls()

	ClientSettings.Players = vgui.Create( "DListView", ClientSettings.TabPlayers )
	ClientSettings.Players:SetPos( 0, 0 )
	ClientSettings.Players:SetSize( ClientSettings.TabPlayers:GetWide() - 220 , ClientSettings.TabPlayers:GetTall() - 19 )
	ClientSettings.Players:SetMultiSelect( false )
	ClientSettings.Players:AddColumn("Players")
	ClientSettings.Players.DoClick = function()
		for _, v in pairs(ClientSettings.PlayerMenuItems) do if v.InvalidateLayout then v:InvalidateLayout() end end
	end

	ClientSettings.MultiPlayers = vgui.Create( "DPanelList", ClientSettings.TabMultiPlayers )
	ClientSettings.MultiPlayers:SetPos( 0, 0 )
	ClientSettings.MultiPlayers:SetSize( ClientSettings.TabMultiPlayers:GetWide() - 220 , ClientSettings.TabMultiPlayers:GetTall() - 19 )
	ClientSettings.MultiPlayers.DoClick = function()
		for _, v in pairs(ClientSettings.PlayerMenuItems) do if v.InvalidateLayout then v:InvalidateLayout() end end
	end


	ClientSettings:ScanPlayers()

	ClientSettings.CommandList = vgui.Create( "DPanelList", ClientSettings.TabPlayers )
	ClientSettings.CommandList:EnableVerticalScrollbar( true )
	ClientSettings.CommandList:SetPos( ClientSettings.TabPlayers:GetWide() - 220, 0 )
	ClientSettings.CommandList:SetTall( ClientSettings.TabPlayers:GetTall() - 20 )
	ClientSettings.CommandList:SetWide( 210 )

	ClientSettings.MultiCommandList = vgui.Create( "DPanelList", ClientSettings.TabMultiPlayers )
	ClientSettings.MultiCommandList:EnableVerticalScrollbar( true )
	ClientSettings.MultiCommandList:SetPos( ClientSettings.TabMultiPlayers:GetWide() - 220, 0 )
	ClientSettings.MultiCommandList:SetTall( ClientSettings.TabMultiPlayers:GetTall() - 20 )
	ClientSettings.MultiCommandList:SetWide( 210 )

	ClientSettings:CreateCategories()

	ClientSettings:FillCommandList()
end

function CreateMiniGamesControls()

	local SelectedMinigame = "Choose a minigame!"

	local MinigameTitle = vgui.Create( "DLabel", ClientSettings.TabMiniGames )
	MinigameTitle:SetPos( 425, 10 )
	MinigameTitle:SetSize(125,30)
	MinigameTitle:SetFont("MinigameFont")

	MinigameTitle:SetText( "" )

	ClientSettings.MiniGamesSettingsList = vgui.Create( "DPanelList", ClientSettings.TabMiniGames )
	ClientSettings.MiniGamesSettingsList:EnableVerticalScrollbar( true )
	ClientSettings.MiniGamesSettingsList:SetPos( ClientSettings.TabMiniGames:GetWide() - 220, 0 )
	ClientSettings.MiniGamesSettingsList:SetTall( ClientSettings.TabMiniGames:GetTall() - 20 )
	ClientSettings.MiniGamesSettingsList:SetWide( 210 )

	ClientSettings.MiniGamesList = vgui.Create( "DListView", ClientSettings.TabMiniGames )
	ClientSettings.MiniGamesList:SetPos( 0, 0 )
	ClientSettings.MiniGamesList:SetSize( ClientSettings.TabMiniGames:GetWide() - 220 , ClientSettings.TabMiniGames:GetTall() - 19 )
	ClientSettings.MiniGamesList:SetMultiSelect( false )
	ClientSettings.MiniGamesList:AddColumn("Games")
	ClientSettings.MiniGamesList.OnRowSelected = function( self, line )
     SelectedMinigame = ClientSettings.MiniGamesList:GetLine( line ).Game
		 MinigameTitle:SetText( SelectedMinigame )
	end
	ClientSettings.MiniGamesList.DoClick = function()
	--	for _, v in pairs(ClientSettings.PlayerMenuItems) do if v.InvalidateLayout then v:InvalidateLayout() end end
	end

	local startminigame = vgui.Create( "DButton", ClientSettings.TabMiniGames );
	startminigame:SetSize( 100, 30 );
	startminigame:SetPos( 425, 50 );
	startminigame:SetText( "Start Minigame" );
	startminigame.DoClick = function( button )
	if !LocalPlayer():IsAdmin() then return nil end
		Derma_Query(
			"Are you sure you want start the '"..SelectedMinigame.."' minigame?",
			"Event System",
			"Yes",
			function()
					RunConsoleCommand( "gmt_loadmini", SelectedMinigame )
			end,
			"No", EmptyFunction
		)
	end

	local endminigame = vgui.Create( "DButton", ClientSettings.TabMiniGames );
	endminigame:SetSize( 100, 30 );
	endminigame:SetPos( 425, 85 );
	endminigame:SetText( "End Minigame" );
	endminigame.DoClick = function( button )
	if !LocalPlayer():IsAdmin() then return nil end
		Derma_Query(
			"Are you sure you want end the '"..SelectedMinigame.."' minigame?",
			"Event System",
			"Yes", function() RunConsoleCommand( "gmt_endmini", SelectedMinigame ) end,
			"No", EmptyFunction
		)
	end

	minigames.List = {

		"balloonpop",
		"chainsaw",
		"drumracing",
		"fun",
		"obamasmash",
		"plane",
		"pvpnarnia",
		"rabbitfight",
		"snowbattle"

	}

	--WILL LOAD LIKE THIS:
	for k,v in pairs(minigames.List) do
		ClientSettings.MiniGamesList:AddLine( v ).Game = v
	end

end

function CreateEventControls()
	local disableeventbutton = vgui.Create( "DButton", ClientSettings.TabEvent );
	disableeventbutton:SetSize( 100, 30 );
	disableeventbutton:SetPos( 10, 10 );
	disableeventbutton:SetText( "Disable event system" );
	disableeventbutton.DoClick = function( button )
	if !ClientSettings.AdminAllowSend and !LocalPlayer:IsSuperAdmin() then return nil end
		Derma_Query(
			"Are you sure you want to disable event system?",
			"Event System",
			"Yes", function() RunConsoleCommand( "gmt_disableevent" ) end,
			"No", EmptyFunction
		)
	end

	local enableeventbutton = vgui.Create( "DButton", ClientSettings.TabEvent );
	enableeventbutton:SetSize( 100, 30 );
	enableeventbutton:SetPos( 10, 50 );
	enableeventbutton:SetText( "Enable event system" );
	enableeventbutton.DoClick = function( button )
	if !ClientSettings.AdminAllowSend and !LocalPlayer:IsSuperAdmin() then return nil end
		Derma_Query(
			"Are you sure you want to enable event system?",
			"Event System",
			"Yes", function() RunConsoleCommand( "gmt_enableevent" ) end,
			"No", EmptyFunction
		)
	end

	local manualeventbutton = vgui.Create( "DButton", ClientSettings.TabEvent );
	manualeventbutton:SetSize( 100, 30 );
	manualeventbutton:SetPos( 10, 90 );
	manualeventbutton:SetText( "Start event" );
	manualeventbutton.DoClick = function( button )
	if !ClientSettings.AdminAllowSend and !LocalPlayer:IsSuperAdmin() then return nil end
		Derma_Query(
			"Are you sure you want to start event?",
			"Event System",
			"Yes", function() RunConsoleCommand( "gmt_manualevent" ) end,
			"No", EmptyFunction
		)
	end

	local skipeventbutton = vgui.Create( "DButton", ClientSettings.TabEvent );
	skipeventbutton:SetSize( 100, 30 );
	skipeventbutton:SetPos( 10, 130 );
	skipeventbutton:SetText( "Skip event" );
	skipeventbutton.DoClick = function( button )
	if !ClientSettings.AdminAllowSend and !LocalPlayer:IsSuperAdmin() then return nil end
		Derma_Query(
			"Are you sure you want to skip current event?",
			"Event System",
			"Yes", function() RunConsoleCommand( "gmt_skipevent" ) end,
			"No", EmptyFunction
		)
	end

--[[	ClientSettings.Events = vgui.Create( "DComboBox", ClientSettings.TabEvent )
	ClientSettings.Events:SetPos( 0, 0 )
	ClientSettings.Events:SetSize( ClientSettings.TabEvent:GetWide() - 420 , ClientSettings.TabEvent:GetTall() - 19 )
	ClientSettings.Events:SetMultiple( false )
	ClientSettings.Events.DoClick = function()
		--for _, v in pairs(ClientSettings.PlayerMenuItems) do if v.InvalidateLayout then v:InvalidateLayout() end end
	end
	ClientSettings.Events:AddItem( "Sale" )
	ClientSettings.Events:AddItem( "Mini Game" )]]

	minimumsale = vgui.Create("DLabel", ClientSettings.TabEvent)
	minimumsale:SetText("Minimum sale (max 1)")
	minimumsale:SetPos( 200, 0 )
	minimumsale:SizeToContents()

	minimumsaleval = vgui.Create("DTextEntry", ClientSettings.TabEvent)
	minimumsaleval:SetText("0.1")
	minimumsaleval:SetPos( 200, 20 )

	maximumsale = vgui.Create("DLabel", ClientSettings.TabEvent)
	maximumsale:SetText("Maximum sale (max 1)")
	maximumsale:SetPos( 200, 50 )
	maximumsale:SizeToContents()

	maximumsaleval = vgui.Create("DTextEntry", ClientSettings.TabEvent)
	maximumsaleval:SetText("0.5")
	maximumsaleval:SetPos( 200, 70 )

	saletime = vgui.Create("DLabel", ClientSettings.TabEvent)
	saletime:SetText("Sale duration (in sec)")
	saletime:SetPos( 200, 100 )
	saletime:SizeToContents()

	saletimeval = vgui.Create("DTextEntry", ClientSettings.TabEvent)
	saletimeval:SetText("60")
	saletimeval:SetPos( 200, 120 )

	minigametime = vgui.Create("DLabel", ClientSettings.TabEvent)
	minigametime:SetText("Mini Game duration (in sec)")
	minigametime:SetPos( 200, 150 )
	minigametime:SizeToContents()

	minigametimeval = vgui.Create("DTextEntry", ClientSettings.TabEvent)
	minigametimeval:SetText("600")
	minigametimeval:SetPos( 200, 170 )

	local saveeventsettingsbutton = vgui.Create( "DButton", ClientSettings.TabEvent );
	saveeventsettingsbutton:SetSize( 100, 30 );
	saveeventsettingsbutton:SetPos( 200, 200 );
	saveeventsettingsbutton:SetText( "Save settings" );
	saveeventsettingsbutton.DoClick = function( button )
	if !LocalPlayer():IsPrivAdmin() then return nil end
		RunConsoleCommand("gmt_eventsettings", minimumsaleval:GetValue(), maximumsaleval:GetValue(), minigametimeval:GetValue(), saletimeval:GetValue())
	end

end

function ClientSettings:ScanPlayers()
	ClientSettings.Players:Clear()

	for i, v in pairs(player.GetAll()) do
			FPlayer = ClientSettings.Players:AddLine( v:Nick() )
			FPlayer.Ply = v:EntIndex()

			local PlayerChk = vgui.Create( "DCheckBoxLabel" )
			PlayerChk:SetText( v:Nick() )
			PlayerChk:SetValue( 0 )
			PlayerChk:SizeToContents()
			PlayerChk:SetFont("QuestionSmallTitle")
			PlayerChk.Ply = v:EntIndex()
			ClientSettings.MultiPlayers:AddItem( PlayerChk ) -- Add the item above

			if v == LocalPlayer() then ClientSettings.Players:SelectItem( FPlayer ) end
	end
end

function ClientSettings:FillCommandList()
	for _, id in ipairs( CheckBoxes ) do
		local Item = ClientSettings:GetItem( id )
		ClientSettings:RegisterPlayerMenu( Item.Name, 1, true, true, id, nil, nil )
	end

	for _, id in ipairs( Input ) do
		local Item = ClientSettings:GetItem( id )
		ClientSettings:RegisterPlayerMenu( Item.Name, 2, nil, nil, id, true, nil )
	end

	--One bug, sliders should be in separate category or all positions will be screwed
	for _, id in ipairs( Wangs ) do
		local Item = ClientSettings:GetItem( id )
		ClientSettings:RegisterPlayerMenuSlider( Item.Name, 3, id, Item )
	end

	--Reset Button
	ClientSettings:RegisterPlayerMenu( "RESET PLAYER SETTINGS", 2, nil, nil, id, nil, true )

	for _, v in pairs(ClientSettings.PlayerMenuItems) do if v.InvalidateLayout then v:InvalidateLayout() end end
end

ClientSettings.PlayerMenuItems = {}
ClientSettings.Categories = {}
function ClientSettings:RegisterPlayerMenu( Text, CategoryID, Command, CheckBoolean, id, input, resetplayer )

	local temp = {}
	temp.Text = Text
	temp.CategoryID = CategoryID
	temp.CheckBoolean = CheckBoolean
	temp.Command = Command


	local Temp = vgui.Create( "CommandButton", ClientSettings:GetCategoryControlByCategoryID(CategoryID) )
	Temp:SetText( Text )
	Temp:SetPos( 0, ClientSettings:MenuItemsInCategory(CategoryID) * 15 )
	Temp:SetSize( ClientSettings.CommandList:GetWide() - 2, 15 )
	Temp:SetTextColor(Color(255,255,255,255))
	Temp.id = id
	Temp.Input = input
	Temp.Text = Text
	Temp.ResetPlayer = resetplayer
	if CheckBoolean ~= nil then
		Temp:AddCheckBox()
		Temp.CheckBoolean = CheckBoolean
	end
	Temp.Command = Command
	Temp.IgnoreResetFocus = false


	if ClientSettings:MenuItemsInCategory(CategoryID) / 2 == math.floor(ClientSettings:MenuItemsInCategory(CategoryID) / 2) then
		Temp:SetAlt( true )
	end

	temp.Control = Temp
	table.insert( ClientSettings.PlayerMenuItems, temp )
	Temp = nil
	ClientSettings:GetCategoryControlByCategoryID(CategoryID):SetTall( 15 * ClientSettings:MenuItemsInCategory(CategoryID) )
end

function ClientSettings:RegisterPlayerMenuSlider( Text, CategoryID, id, Item)

	local temp = {}
	temp.Text = Text
	temp.CategoryID = CategoryID
	temp.CheckBoolean = nil
	temp.Command = nil


	local Temp = vgui.Create( "DNumSlider", ClientSettings:GetCategoryControlByCategoryID(CategoryID) )
	Temp:SetText( Text )
	Temp:SetPos( 0, ClientSettings:MenuItemsInCategory(CategoryID) * 35 )
	Temp:SetSize( ClientSettings.CommandList:GetWide() - 2, 35 )
	Temp:SetValue( ClientSettings:Get( ClientSettings:GetSelectedPlayer(), id ) )
	Temp:SetMin( Item.MinValue )
	Temp:SetMax( Item.MaxValue )
	Temp:SetDecimals( Item.Decimals or 2 )
	Temp.IgnoreResetFocus = true -- Required

	Temp.OnValueChanged = function( _, value )
	    for _, v in pairs(ClientSettings:GetSelectedPlayer()) do
			if ClientSettings.AdminAllowSend == true then
				timer.Create(id .. "-ClientSettingAdminWang", 0.3, 1, function()
					TimerCaller(ClientSettings:GetSelectedPlayer():EntIndex(), id, tostring(value))
				end)
			end
		end
	end

	temp.Control = Temp
	table.insert( ClientSettings.PlayerMenuItems, temp )
	Temp = nil
	ClientSettings:GetCategoryControlByCategoryID(CategoryID):SetTall( 35 * ClientSettings:MenuItemsInCategory(CategoryID) )
end

function ClientSettings:AddCategory( Text, CategoryID )
	local CatTempHeader = vgui.Create( "DCollapsibleCategory", ClientSettings.CommandList )
	CatTempHeader:SetPos( 1, #ClientSettings.Categories * 23 )
	CatTempHeader:SetSize( ClientSettings.CommandList:GetWide() - 2, 50 )
	CatTempHeader:SetExpanded( 0 )
	CatTempHeader:SetLabel( Text )

	local CatTempContainer = vgui.Create( "DPanelList" )
	CatTempContainer:SetAutoSize( false )
	CatTempContainer:SetWide( CatTempHeader:GetWide() )
	CatTempContainer:SetTall( 0 )
	CatTempContainer:SetSpacing( 5 )
	CatTempContainer:EnableHorizontal( false )

	CatTempHeader:SetContents( CatTempContainer )

	local Temp = {}
	Temp.Text = Text
	Temp.CategoryID = CategoryID
	Temp.Header = CatTempHeader
	Temp.Container = CatTempContainer

	table.insert( ClientSettings.Categories, Temp )
end

function ClientSettings:GetCategoryControlByCategoryID( CategoryID )
	for _, i in pairs( ClientSettings.Categories ) do
		if i.CategoryID == CategoryID then
			return i.Container
		end
	end
end

function ClientSettings:MenuItemsInCategory( CategoryID )
	amount = 0
	for _, i in pairs(ClientSettings.PlayerMenuItems) do
		if i.CategoryID == CategoryID then amount = amount + 1 end
	end

	return amount
end

function ClientSettings:GetSelectedPlayer()
	--return ClientSettings.Players.SelectedItems
	local SelItem = ClientSettings.Players:GetSelected()

	return player.GetByID(SelItem[1].Ply)
end

function ClientSettings:CreateCategories()
	ClientSettings:AddCategory( "Player Permissions", 1 )
	ClientSettings:AddCategory( "Player Control", 2 )
	ClientSettings:AddCategory( "Player Limits", 3 )
	--AddCategory( "Category 4", 4 )
end

local function MoveCategories()
	local CurrentTop = 0
	for _, v in pairs(ClientSettings.Categories) do
		v.Header:SetPos( 0, CurrentTop )
		CurrentTop = CurrentTop + v.Header:GetTall() + 1
	end
end
timer.Create( "MoveStuff", 0.01, 0, function()
	MoveCategories()
end)
