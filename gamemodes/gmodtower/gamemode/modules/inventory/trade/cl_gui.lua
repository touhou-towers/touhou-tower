
GTowerTrade.Gui = nil
GTowerTrade.GuiItems = nil

surface.CreateFont( "TradeButton", { font = "Bebas Neue", size = 22, weight = 200 } )
surface.CreateFont( "TradeBG", { font = "Bebas Neue", size = 64, weight = 200 } )

local gradient = surface.GetTextureID("vgui/gradient_up")

function GTowerTrade:OpenTrade( ply )

	GTowerTrade:CloseTrade()
	GtowerMainGui:GtowerShowMenus()
	GTowerItems:OpenDropInventory()
	GTowerTrade.MyAccepted = false
	GTowerTrade.OtherAccepted = false
	GTowerTrade.MyFinished = false
	GTowerTrade.OtherFinished = false
	GTowerTrade.TradingMoney = 0


	local TotalWidth = GTowerItems.InvItemSize * 1.1 * 8 + 30

	self.Gui = vgui.Create("DFrame")
	self.Gui:SetSize( TotalWidth, TotalWidth * 0.8 )
	self.Gui:SetTitle( T("trade_trading_with", ply:GetName() ) ) // Title of the frame
   // self.Gui:SetVisible( true )
	//self.Gui:SetKeyBoardInputEnabled( true )
	//self.Gui:MakePopup()
	self.Gui:Center()
	self.Gui.CheckDrop = function( gui, panel )


		local CommandId = panel:GetCommandId()

		for k, v in pairs( GTowerTrade.GuiItems ) do
			if v.OldCommandId == CommandId then
				return
			end
		end

		if #GTowerTrade.GuiItems >= 32 then
			Msg2("You can not trade more than 32 items at a time.")
			return
		end

		local InvItem = panel:GetItem()

		if InvItem.Tradable == false then
			Msg2("Item is not tradable")
			return
		end

		local Item = vgui.Create("GtowerInvItem")

		GTowerTrade:UpdateMyItem( Item )
		Item:UpdateParent()
		Item.ActualItem = table.Copy( InvItem )
		Item.OldCommandId = CommandId
		Item.OldActualItem = panel

		GTowerTrade.Gui.MyList:AddItem( Item )
		GTowerTrade:SendItems()
	end
	self.Gui.Close = function()
		GTowerTrade:CloseTrade()
		RunConsoleCommand("gmt_closetrade")
	end


	self.Gui.MyList = vgui.Create("DPanelList", self.Gui)
	self.Gui.MyList:SetSize( self.Gui:GetWide() * 0.5 - 10, self.Gui:GetTall() - 55 - 30 - 20 )
	self.Gui.MyList:SetPos( self.Gui:GetWide() * 0.25 - self.Gui.MyList:GetWide() * 0.5, 55 )
	self.Gui.MyList:EnableHorizontal( true )
	self.Gui.MyList:SetSpacing( 2 )
	self.Gui.MyList:SetPadding( 2 )
	self.Gui.MyList:EnableVerticalScrollbar()
	self.Gui.MyList.Paint = function()
		surface.SetDrawColor( 15 - 15, 78 - 15, 132 - 15, 255 )
		surface.DrawRect( 0, 0, self.Gui.MyList:GetSize() )

		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.SetTexture( gradient )
		surface.DrawTexturedRect( 0, 0, self.Gui.MyList:GetSize() )

		draw.SimpleText( "GIVE", "TradeBG", self.Gui.MyList:GetWide() / 2, self.Gui.MyList:GetTall() / 2, Color( 15, 78, 132 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	GTowerTrade.GuiItems = self.Gui.MyList.Items //Copy memory reference


	self.Gui.OtherList = vgui.Create("DPanelList", self.Gui)
	self.Gui.OtherList:SetSize( self.Gui:GetWide() * 0.5 - 10, self.Gui:GetTall() - 55 - 30 - 20 )
	self.Gui.OtherList:SetPos( self.Gui:GetWide() * 0.75 - self.Gui.OtherList:GetWide() * 0.5, 55 )
	self.Gui.OtherList:EnableHorizontal( true )
	self.Gui.OtherList:SetSpacing( 2 )
	self.Gui.OtherList:SetPadding( 2 )
	self.Gui.OtherList:EnableVerticalScrollbar()
	self.Gui.OtherList.Paint = function()
		surface.SetDrawColor( 15 - 15, 78 - 15, 132 - 15, 255 )
		surface.DrawRect( 0, 0, self.Gui.OtherList:GetSize() )

		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.SetTexture( gradient )
		surface.DrawTexturedRect( 0, 0, self.Gui.OtherList:GetSize() )

		draw.SimpleText( "RECIEVE", "TradeBG", self.Gui.MyList:GetWide() / 2, self.Gui.MyList:GetTall() / 2, Color( 15, 78, 132 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	/*========
		MONEY INPUT
	==========*/

	local TextEntry = vgui.Create( "DTextEntry", self.Gui )
		TextEntry:SetText( GTowerTrade.TradingMoney )
		TextEntry:SetFont( "TradeButton" )
		TextEntry:SetNumeric( true )
		TextEntry:SetUpdateOnType( true )
		TextEntry:SetWide( 80 )
		//TextEntry:RequestFocus()
		//TextEntry:SetKeyBoardInputEnabled( true )
		TextEntry:MakePopup()
		TextEntry.Think = function()
			TextEntry:SetPos( self.Gui.x + self.Gui.MyList.x + self.Gui.MyList:GetWide() - TextEntry:GetWide() - 2, self.Gui.y + self.Gui.MyList.y - TextEntry:GetTall() - 2 )
		end
		TextEntry.OnValueChange = function(panel)
			timer.Simple( 0.0, function()
				if !ValidPanel( panel ) then
					return
				end

				value = tonumber( panel:GetValue() )

		if !value || value < 0 || value > Money() then
			value = math.Clamp( value or 0, 0, Money() )
			panel:SetText( value )
		end

				if GTowerTrade.TradingMoney == value then
					return
				end

				GTowerTrade.TradingMoney = value
				GTowerTrade:SendItems()
			end )
		end
		TextEntry.UpdateConvarValue = TextEntry.OnValueChange
		TextEntry.AllowInput = function( panel, sInt )
		local strNumericNumber = "1234567890"

		-- We're going to make it only allow numbers ONLY, fuck floats, fuck negatives
		if sInt == "." || sInt == "-" || sInt == "[" || sInt == "]" || sInt == "(" || sInt == "%" then return true end
		if !string.find(strNumericNumber, sInt) then return true end

		return false
		end
		TextEntry.CheckNumeric = function( panel, strValue )
			if strValue == "y" || strValue == "u" then
				GAMEMODE:StartChat( strValue == "u" )
				return true
			end

			if ( !string.find ( "1234567890", strValue ) ) then
				return true
			end

			return false

		end

		local MoneyIcon = vgui.Create( "DImage", self.Gui )
	MoneyIcon:SetMaterial( "gmod_tower/scoreboard/icon_money.png" )
	MoneyIcon:SetSize( 16, 16 )
	MoneyIcon.Think = function()
		MoneyIcon:SetPos( self.Gui.MyList.x + self.Gui.MyList:GetWide() - 80 - 16 - 4, self.Gui.MyList.y - 16 - 6 )
	end

	local OtherOffer = Label( "0", self.Gui )
		OtherOffer:SetFont( "TradeButton" )
		OtherOffer.UpdatePos = function( panel )
			panel:SizeToContents()
			panel:SetPos( self.Gui.OtherList.x + 6 + 16, self.Gui.OtherList.y - panel:GetTall() - 2 )
		end
		OtherOffer:UpdatePos()
	self.Gui.OtherOffer = OtherOffer

	local OtherMoneyIcon = vgui.Create( "DImage", self.Gui )
OtherMoneyIcon:SetMaterial( "gmod_tower/scoreboard/icon_money.png" )
OtherMoneyIcon:SetSize( 16, 16 )
OtherMoneyIcon.Think = function()
	OtherMoneyIcon:SetPos( OtherOffer.x - 16 - 4, OtherOffer.y + 2 )
end

	/*========
		ACCEPT BUTTON
	==========*/

	local AcceptButton = vgui.Create( "DPanel", self.Gui )
	AcceptButton:SetPos( self.Gui.MyList.x, self.Gui.MyList.y + self.Gui.MyList:GetTall() + 2 )
	AcceptButton:SetSize( self.Gui.MyList:GetWide(), 20 )
	AcceptButton.Paint = function( panel )
		local w, h = panel:GetSize()
		if GTowerTrade.MyAccepted == false then
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,0,0,125) )
		else
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,125,0,125) )
		end
	end
	AcceptButton.OnMousePressed = function()
		GTowerTrade.MyAccepted = !GTowerTrade.MyAccepted
		RunConsoleCommand("gmt_accepttrade", tostring( GTowerTrade.MyAccepted ) )
	end

	local AcceptLabel = Label( "ACCEPT", AcceptButton )
	AcceptLabel:SetFont("MikuHUDMainSmall")
	AcceptLabel:SizeToContents()
	AcceptLabel:Center()

	/*========
		THE OTHER ACCEPT BUTTON
	==========*/
	local AcceptButton = vgui.Create( "DPanel", self.Gui )
	AcceptButton:SetPos( self.Gui.OtherList.x, self.Gui.OtherList.y + self.Gui.OtherList:GetTall() + 2 )
	AcceptButton:SetSize( self.Gui.OtherList:GetWide(), 20 )
	AcceptButton.Paint = function( panel )
		local w, h = panel:GetSize()
		if GTowerTrade.OtherAccepted == false then
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,0,0,125) )
		else
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,125,0,125) )
		end
	end

	local AcceptLabel = Label( string.upper(ply:Name()), AcceptButton )
	AcceptLabel:SetFont("MikuHUDMainSmall")
	AcceptLabel:SizeToContents()
	AcceptLabel:Center()

	/*======
		FINISH BUTTON
	========*/
	local FinishButton = vgui.Create( "DPanel", self.Gui )
	FinishButton:SetPos( self.Gui.MyList.x, self.Gui.MyList.y + self.Gui.MyList:GetTall() + 22 )
	FinishButton:SetSize( self.Gui.MyList:GetWide(), 20 )
	FinishButton.Paint = function( panel )
		local w, h = panel:GetSize()
		if GTowerTrade.MyFinished == false then
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,0,0,125) )
		else
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,125,0,125) )
		end
	end
	FinishButton.OnMousePressed = function()
		if GTowerTrade.MyAccepted && GTowerTrade.OtherAccepted then
			GTowerTrade.MyFinished = !GTowerTrade.MyFinished
			RunConsoleCommand("gmt_finishtrade", tostring( GTowerTrade.MyFinished ) )
		end
	end

	local FinishLabel = Label( "FINISH", FinishButton )
	FinishLabel:SetFont("MikuHUDMainSmall")
	FinishLabel:SizeToContents()
	FinishLabel:Center()

	/*========
		THE OTHER FINISH BUTTON
	==========*/
	local FinishButton = vgui.Create( "DPanel", self.Gui )
	FinishButton:SetPos( self.Gui.OtherList.x, self.Gui.OtherList.y + self.Gui.OtherList:GetTall() + 22 )
	FinishButton:SetSize( self.Gui.OtherList:GetWide(), 20 )
	FinishButton.Paint = function( panel )
		local w, h = panel:GetSize()
		if GTowerTrade.OtherFinished == false then
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,0,0,125) )
		else
			draw.RoundedBox( 4, 0, 0, w, h, Color(0,125,0,125) )
		end
	end

	local FinishLabel = Label( string.upper(ply:Name()), FinishButton )
	FinishLabel:SetFont("MikuHUDMainSmall")
	FinishLabel:SizeToContents()
	FinishLabel:Center()
end

function GTowerTrade:CloseTrade()

	self.GuiItems = nil

	if IsValid( self.Gui ) then
		self.Gui:Remove()
	end

	self.Gui = nil

end

function GTowerTrade:OtherTrading( Money, List )
	if !self.Gui then
		return
	end

	self.Gui.OtherOffer:SetText( "GMC: " .. tostring(Money) )
	self.Gui.OtherOffer:UpdatePos()

	local Panels = self.Gui.OtherList.Items

	for k, v in pairs( Panels ) do
		v._UnusedItem = true
	end

	local function CheckForItem( Item )
		for k1, v1 in pairs( List ) do
			if Item:IsMyItem( v1 ) then
				table.remove( List, k1 )
				return true
			end
		end
		return false
	end

	for _, v in pairs( Panels ) do
		if v._UnusedItem == true && CheckForItem( v.ActualItem ) == true then
			v._UnusedItem = false
		end
	end

	for k, v in pairs( Panels ) do
		if v._UnusedItem == true then
			v:OnCursorExited()
			v:Remove()
			table.remove( Panels, k )
		end
	end

	for _, v in pairs( List ) do

		local Item = vgui.Create("GtowerInvItem")

		GTowerTrade:UpdateOtherItem( Item )
		Item:UpdateParent()
		Item.ActualItem = v

		GTowerTrade.Gui.OtherList:AddItem( Item )

	end

	self.Gui.OtherList:InvalidateLayout()
end

function GTowerTrade:IsMouseInWindow()
    local x,y = self.Gui:CursorPos()
    return x >= 0 && y >= 0 && x <= self.Gui:GetWide() && y <= self.Gui:GetTall()
end

function GTowerTrade:RemoveItem( CommandId, msgid )

	if GTowerTrade.GuiItems then

		local DidChange = false

		for k, v in pairs( GTowerTrade.GuiItems ) do
			if v.OldCommandId == CommandId then

				if msgid == 1 then
					Msg2( v.ActualItem.Name .. " can not be managed.")
				elseif msgid == 2 then
					Msg2( v.ActualItem.Name .. " is not tradable.")
				elseif msgid == 3 then
					Msg2( v.ActualItem.Name .. ", other player already has that unique item.")
				end

				v:OnCursorExited()
				v:Remove()
				table.remove( GTowerTrade.GuiItems, k )
				DidChange = true
			end
		end

		if DidChange == true then
			self.Gui.MyList:InvalidateLayout()
			GTowerTrade:SendItems()
		end

	end

end

local function TradeRemoveItems( ... )
	for _, v in pairs( {...} ) do
		GTowerTrade:RemoveItem( v )
	end
end

hook.Add("GTowerInvHover", "CheckTradeArea", function( Item )
	if ValidPanel( GTowerTrade.Gui ) && GTowerTrade:IsMouseInWindow() then
		return GTowerTrade.Gui
	end
end )

hook.Add("InventoryRemove", "CheckTradeArea", TradeRemoveItems )
hook.Add("InventoryUse", "CheckTradeArea", TradeRemoveItems )
hook.Add("InventorySwap", "CheckTradeArea", TradeRemoveItems )
hook.Add("InventoryDrop", "CheckTradeArea", TradeRemoveItems )
hook.Add("CanCloseMenu", "Trading", function()
	if ValidPanel( GTowerTrade.Gui ) then
		return false
	end
end )
hook.Add("InvDropCheckClose", "Trading", function()
	if ValidPanel( GTowerTrade.Gui ) then
		return false
	end
end )
