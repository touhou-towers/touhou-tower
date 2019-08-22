

-----------------------------------------------------
local tblOpenMenus = {}
local vguiCreate = vgui.Create

// Force all DFrame windows to be registered for vgui.CloseAllMenus (CloseAllMenus gets called on player click??)
function vgui.Create( name, parent, targetname )
	
	local panel = vguiCreate( name, parent, targetname )

	if name == "DFrame" then
		//MsgN( "Panel for close... ", name )
		table.insert( tblOpenMenus, panel )
	end

	return panel

end

function vgui.CloseDermaMenus()

	for k, menu in pairs( tblOpenMenus ) do
	
		if IsValid( menu ) then
		
			menu:Close()
			menu:Remove()
			
		end
	
	end

end

hook.Add( "OnReloaded", "CloseDermaOnReload", function()

	vgui.CloseDermaMenus()

end )

function Derma_SliderRequest( strTitle, strText, defaultVal, minRange, maxRange, decimals, fnEnter, fnCancel, strButtonText, strButtonCancelText, onChanged, type )

	local Window = vgui.Create( "DFrame" )
		Window:SetTitle( strTitle or "Message Title (First Parameter)" )
		Window:SetDraggable( false )
		Window:ShowCloseButton( false )
		Window:SetBackgroundBlur( true )
		Window:SetDrawOnTop( true )
		
	local InnerPanel = vgui.Create( "DPanel", Window )
	
	local Text = vgui.Create( "DLabel", InnerPanel )
		Text:SetText( strText or "Message Text (Second Parameter)" )
		Text:SizeToContents()
		Text:SetContentAlignment( 5 )
		Text:SetTextColor( color_white )
	
	local SliderEntry = vgui.Create( "DNumSlider2", InnerPanel )
		SliderEntry:SetText( "" )
		SliderEntry:SetMin( minRange )
		SliderEntry:SetMax( maxRange )
		SliderEntry:SetDecimals( decimals )
		SliderEntry:SetValue( defaultVal )
		SliderEntry.Type = type
		SliderEntry.Think = onChanged
	

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )
		
	local Button = vgui.Create( "DButton", ButtonPanel )
		Button:SetText( strButtonText or "OK" )
		Button:SizeToContents()
		Button:SetTall( 20 )
		Button:SetWide( Button:GetWide() + 20 )
		Button:SetPos( 5, 5 )
		Button.DoClick = function() Window:Close() fnEnter( SliderEntry:GetValue() ) end
		
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
	
	Window:SetSize( w + 50, h + 25 + 75 + 10 + 20 )
	Window:Center()
	
	InnerPanel:StretchToParent( 5, 25, 5, 45 )
	
	Text:StretchToParent( 5, 5, 5, 35 )	
	
	SliderEntry:StretchToParent( 5, nil, 5, nil )
	SliderEntry:AlignBottom( 5 )
	
	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )
	
	Window:MakePopup()
	Window:DoModal()

end

function Derma_NumberRequest( strTitle, strText, fnEnter, fnCancel, strButtonText, strButtonCancelText, typeName )

	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( strTitle or "Message Title (First Parameter)" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )
		
	local InnerPanel = vgui.Create( "DPanel", Window )
	
	local Text = vgui.Create( "DLabel", InnerPanel )
	Text:SetText( strText or "Message Text (Second Parameter)" )
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	Text:SetTextColor( color_white )

	local TextEntryDesc = vgui.Create( "DLabel", InnerPanel )
	TextEntryDesc:SetText( "" )
	TextEntryDesc:SizeToContents()
	TextEntryDesc:SetContentAlignment( 5 )
	TextEntryDesc:SetTextColor( color_white )

	local TextEntry = vgui.Create( "DTextEntry", InnerPanel )
	TextEntry:SetText( 0 )
	TextEntry:SetNumeric( true )
	TextEntry:SetUpdateOnType( true )
	TextEntry:SetWide( 100 )
	TextEntry:RequestFocus()
	TextEntry:SetKeyBoardInputEnabled( true )
	TextEntry.OnValueChange = function( panel )

		if !ValidPanel( panel ) then return end

		value = tonumber( panel:GetValue() )
				
		if !value || value < 0 || ( value * Cards.ChipCost ) > Money() then
			value = math.Clamp( value or 0, 0, ( Money() / Cards.ChipCost ) )
			value = math.ceil( value )
			panel:SetText( value )
		end

		TextEntryDesc:SetText( string.FormatNumber( value * Cards.ChipCost ) .. " " .. typeName )
		TextEntryDesc:SizeToContents()
		TextEntryDesc:CenterHorizontal()

	end
	TextEntry.UpdateConvarValue = TextEntry.OnValueChange
	TextEntry.AllowInput = function( panel, sInt )
		local strNumericNumber = "1234567890"

    	/* We're going to make it only allow numbers ONLY, fuck floats, fuck negatives */
 		if sInt == "." || sInt == "-" || sInt == "[" || sInt == "]" || sInt == "(" || sInt == "%" then return true end
 		if !string.find(strNumericNumber, sInt) then return true end

 		return false
 	end
	
	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall( 30 )
		
	local Button = vgui.Create( "DButton", ButtonPanel )
	Button:SetText( strButtonText or "OK" )
	Button:SizeToContents()
	Button:SetTall( 20 )
	Button:SetWide( Button:GetWide() + 20 )
	Button:SetPos( 5, 5 )
	Button.DoClick = function() Window:Close() fnEnter( TextEntry:GetValue() ) end
		
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
	
	Window:SetSize( w + 50, h + 25 + 75 + 10 + 20 )
	Window:Center()
	
	InnerPanel:StretchToParent( 5, 25, 5, 45 )
	
	Text:StretchToParent( 5, 5, 5, 35 )

	TextEntry:CenterHorizontal()
	TextEntry:AlignBottom( 20 )
	TextEntryDesc:CenterHorizontal()
	TextEntryDesc:AlignBottom( 5 )
	
	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )
	
	Window:MakePopup()
	Window:DoModal()

end