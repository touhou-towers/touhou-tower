
require("glon")

local function ShowBMPanel( um )
	MarketPanel:SetVisible( true )
end
usermessage.Hook("showblackmarket", ShowBMPanel)

local function BMUpdate( um )
	local list = {}
	status, error = pcall( function() list = glon.decode(um:ReadString()) end )
	local nooffers = true
	OffersList:Clear()
	for k, v in pairs(list) do
		Offer = OffersList:AddItem( k..": "..v )
		Offer.Ply = k
		nooffers = false
	end
	if nooffers then
		Offer = OffersList:AddItem( "No offers available" )
	end
end
usermessage.Hook("blackmarketupdate", BMUpdate)

function CreateBlackMarketPanel()
	MarketPanel = vgui.Create( "DFrame" )
	MarketPanel:SetPos( ScrW() / 2 - 600 / 2, ScrH() / 2 - 425 / 2 )
	MarketPanel:SetSize( 600, 425 )
	MarketPanel:SetTitle( "Black Market" )
	MarketPanel:SetVisible( false )
	MarketPanel:SetDraggable( false )
	MarketPanel:ShowCloseButton( true )
	MarketPanel:MakePopup()
	MarketPanel.Close = function()
	MarketPanel:SetVisible( false )
	end
	CreateControls()
end

function CreateControls()

	OffersList = vgui.Create( "DComboBox", MarketPanel )
	OffersList:SetPos( 2, 25 )
	OffersList:SetSize( MarketPanel:GetWide() - 4, MarketPanel:GetTall() - 70 ) 
	OffersList:SetMultiple( false )
	Offer = OffersList:AddItem( "No offers available" )
	
	local buttonWrite = vgui.Create( "DButton", MarketPanel )
	buttonWrite:SetSize( 100, 30 )
	buttonWrite:SetPos( 20, 385 )
	buttonWrite:SetText( "Write offer" )
	buttonWrite.Disabled = false
	buttonWrite.DoClick = function( button )
		if buttonWrite.Disabled then return end
			Derma_StringRequest("Creating new offer", 
			"Please write your offer here", 
			"",
			function( out ) 
				RunConsoleCommand( "gmt_bmwrite", out )
				buttonWrite.Disabled = true
				buttonWrite:SetText( "Wait 60 sec." )
				timer.Simple(60, function() buttonWrite.Disabled = false buttonWrite:SetText( "Write offer" ) end)
			end,
			nil,
			"Write", 
			"Cancel" 
	)
	end
	
	local buttonContact = vgui.Create( "DButton", MarketPanel )
	buttonContact:SetSize( 100, 30 )
	buttonContact:SetPos( 250, 385 )
	buttonContact:SetText( "Contact author" )
	buttonContact.Disabled = false
	buttonContact.DoClick = function( button )
		local SelItem = OffersList:GetSelected()
		if !SelItem or buttonContact.Disabled then return end
		buttonContact.Disabled = true
		buttonContact:SetText( "Wait 60 sec." )
		timer.Simple(60, function() buttonContact.Disabled = false buttonContact:SetText( "Contact author" ) end)
		RunConsoleCommand("gmt_bmcontact", SelItem.Ply)
	end
	
	local buttonDelete = vgui.Create( "DButton", MarketPanel )
	buttonDelete:SetSize( 100, 30 )
	buttonDelete:SetPos( 480, 385 )
	buttonDelete:SetText( "Delete my offer" )
	buttonDelete.Disabled = false
	buttonDelete.DoClick = function( button )
		if buttonDelete.Disabled then return end
		buttonDelete.Disabled = true
		buttonDelete:SetText( "Wait 60 sec." )
		timer.Simple(60, function() buttonDelete.Disabled = false buttonDelete:SetText( "Delete my offer" ) end)		
		RunConsoleCommand("gmt_bmdelete")
	end
end
CreateBlackMarketPanel()