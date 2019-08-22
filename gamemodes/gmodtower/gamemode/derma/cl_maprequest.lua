

-----------------------------------------------------
local function UpdateMapList( List )

	List:Clear()
	List.Maps = {}

	local gm = engine.ActiveGamemode()
	local maps = Maps.GetMapsInGamemode( gm )

	for _, map in pairs( maps ) do
		local name = Maps.GetName( map )
		List:AddLine( name, map )
		List.Maps[ name ] = map
	end

	// All maps
	/*for map, mapData in pairs( Maps.List ) do
		local name = mapData.Name
		List:AddLine( mapData.Gamemode .. " - " .. name )
		List.Maps[ name ] = map
	end*/

end

function Derma_MapRequest()

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( "Map Selection" )
	Window:SetDraggable( true )
	Window:ShowCloseButton( true )
	Window:SetBackgroundBlur( false )
	Window:SetDrawOnTop( true )

	local InnerPanel = vgui.Create( "DPanel", Window )

	local Text = vgui.Create( "DLabel", InnerPanel )
	Text:SetText( "Select a map to change level to" )
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( color_white )

	local ListView = vgui.Create( "DListView", InnerPanel )
	ListView:SetMultiSelect( false )
	ListView:AddColumn( "Name" )
	ListView:AddColumn( "Mapname" )
	ListView.OnRowSelected = function( panel, line )
		//ListView.SelectedMap = line
		ListView.SelectedMap = panel:GetLine(line):GetValue(1)
	end
	UpdateMapList( ListView )


	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )

	// Changelevel
	local Button1 = vgui.Create( "DButton", ButtonPanel )
	Button1:SetText( "Changelevel" )
	Button1:SizeToContents()
	Button1:SetTall( 20 )
	Button1:SetWide( Button1:GetWide() + 20 )
	Button1:SetPos( 5, 5 )
	Button1.DoClick = function()
		Window:Close()
		RunConsoleCommand( "gmt_changelevel", ListView.Maps[ ListView.SelectedMap ] )
	end
	Button1.Think = function( self )
		if ListView.SelectedMap then
			self:SetAlpha( 255 )
			self:SetMouseInputEnabled( true )
		else
			self:SetAlpha( 50 )
			self:SetMouseInputEnabled( false )
		end
	end

	// Force
	local Button2 = vgui.Create( "DButton", ButtonPanel )
	Button2:SetText( "Force Changelevel" )
	Button2:SizeToContents()
	Button2:SetTall( 20 )
	Button2:SetWide( Button2:GetWide() + 20 )
	Button2:SetPos( 5, 5 )
	Button2:MoveRightOf( Button1, 5 )
	Button2.DoClick = function()
		Window:Close()
		RunConsoleCommand( "gmt_forcechangelevel", ListView.Maps[ ListView.SelectedMap ] )
	end
	Button2.Think = function( self )
		if ListView.SelectedMap then
			self:SetAlpha( 255 )
			self:SetMouseInputEnabled( true )
		else
			self:SetAlpha( 50 )
			self:SetMouseInputEnabled( false )
		end
	end

	// Force
	local Button3 = vgui.Create( "DButton", ButtonPanel )
	Button3:SetText( "Restart Level" )
	Button3:SizeToContents()
	Button3:SetTall( 20 )
	Button3:SetWide( Button3:GetWide() + 20 )
	Button3:SetPos( 5, 5 )
	Button3:MoveRightOf( Button2, 5 )
	Button3.DoClick = function()
		Window:Close()
		RunConsoleCommand( "gmt_forcechangelevel" )
	end

	// Cancel
	local ButtonCancel = vgui.Create( "DButton", ButtonPanel )
	ButtonCancel:SetText( "Cancel" )
	ButtonCancel:SizeToContents()
	ButtonCancel:SetTall( 20 )
	ButtonCancel:SetWide( ButtonCancel:GetWide() + 20 )
	ButtonCancel:SetPos( 5, 5 )
	ButtonCancel.DoClick = function() Window:Close() if ( fnCancel ) then fnCancel( TextEntry:GetValue() ) end end
	ButtonCancel:MoveRightOf( Button3, 5 )

	ButtonPanel:SetWide( Button1:GetWide() + 5 + Button2:GetWide() + 5 + Button3:GetWide() + 5 + ButtonCancel:GetWide() + 10 )

	local w, h = Text:GetSize()
	w = math.max( w, 400 )

	Window:SetSize( w + 50, h + 300 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	Text:CenterHorizontal()
	Text:AlignTop( 5 )

	ListView:SetPos( 5, 25 )
	ListView:SetSize( Window:GetWide() - 20, 200 )
	ListView:StretchToParent( 5, nil, 5, nil )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()

end

concommand.Add( "gmt_maps", function( ply, cmd, args )

	if !ply:IsAdmin() then return end

	Derma_MapRequest()

end )
