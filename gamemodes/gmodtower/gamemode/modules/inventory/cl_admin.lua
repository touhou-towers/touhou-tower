
GTowerItems.AdminBankGUI = nil
GTowerItems.Categories =
{
	{ Internal = "1",		Friendly = "Suite" },
	{ Internal = "build",	Friendly = "Build" },
	{ Internal = "8",		Friendly = "Merchant" },
	{ Internal = "7",		Friendly = "Elect." },
	{ Internal = "10",		Friendly = "Holiday" },
	--{ Internal = "16",		Friendly = "Basical" },
	{ Internal = "18",		Friendly = "Thanks Giving" },
	{ Internal = "19",		Friendly = "Halloween" },
	--{ Internal = "20",		Friendly = "Nature" },
	{ Internal = "6",		Friendly = "Souvenir" },
	{ Internal = "posters",		Friendly = "Posters" },
	{ Internal = "22",		Friendly = "Toys" },
	{ Internal = "24",		Friendly = "Duel" },
	{ Internal = "25",		Friendly = "Food" },
	{ Internal = "model",	Friendly = "Player" },
	{ Internal = "9",	Friendly = "Rabbits" },
	{ Internal = "17",		Friendly = "Body" },
	{ Internal = "fireworks",	Friendly = "Fireworks" },
	{ Internal = "trophy",	Friendly = "Trophies" },
	{ Internal = "weapon",	Friendly = "Weapons" },
	{ Internal = "uncat",	Friendly = "Misc" },
}

local function GetItem( panel )
	return panel.AdmInvItem
end

local function GetCommandId( panel )
	return panel.Id .. "-3"
end

local function UpdateDrawBackground( panel )
	panel.CanDrawBackground = true
end

local function HasCategory( int )

	for _, v in ipairs( GTowerItems.Categories ) do
		if ( v.Internal == tostring( int ) ) then return true end
	end

	return false

end

function GTowerItems:AddGUIItem( v )

	local Item = self:CreateById( v.MysqlId )
	local itemInfo = GTowerItems.Items[ v.MysqlId ]

	local cate = "uncat"

	if ( itemInfo.InvCategory == nil ) then

		if ( HasCategory( itemInfo.StoreId ) ) then
			cate = tostring( itemInfo.StoreId )
		end

	else

		cate = itemInfo.InvCategory

	end

	local tab = self.AdminBankGUI.Tabs.List[ cate ]

	local Vgui = vgui.Create("GtowerInvItem")

	Vgui.AllowPosition = function( panel, target )
		return target:GetItem() == nil
	end

	Vgui.UpdateDrawBackground = UpdateDrawBackground
	Vgui.GetCommandId = GetCommandId
	Vgui.AdmInvItem = Item
	Vgui.GetOriginalParent = function()
		if ( GTowerItems.AdminBankGUI && tab ) then
			return tab:GetCanvas()
		end
	end
	Vgui.GetItem = GetItem
	Vgui.ForcePosition = function()
		if ( GTowerItems.AdminBankGUI && tab ) then
			return tab:InvalidateLayout()
		end
	end
	Vgui.CheckParentLimit = tab

	Vgui:SetId( v.MysqlId )
	Vgui:UpdateParent()

	tab:AddItem( Vgui )


end


function GTowerItems:OpenAdmin()

	self:CloseAdmin()
	GtowerMainGui:GtowerShowMenus()

	if IsValid( self.AdminBankGUI ) then self.AdminBankGUI:SetVisible( true ) return end

	self.AdminBankGUI = vgui.Create("DFrame")
	self.AdminBankGUI:SetSize( 465, 400 )
	self.AdminBankGUI:SetPos( ScrW() - self.AdminBankGUI:GetWide() * 1.1, 100 )
	self.AdminBankGUI:SetVisible( true )
	self.AdminBankGUI:SetTitle("ADMIN BANK - FREE ITEMS!")
	self.AdminBankGUI.Close = function()
		GTowerItems:CloseAdmin()
	end

	self.AdminBankGUI.Tabs = vgui.Create( "DPropertySheet", self.AdminBankGUI )
	self.AdminBankGUI.Tabs:SetPos( 4, 25 )
	self.AdminBankGUI.Tabs:SetSize( self.AdminBankGUI:GetWide() - 8, self.AdminBankGUI:GetTall() - 28 )

	self.AdminBankGUI.Tabs.List = {}

	for k, v in ipairs( self.Categories ) do

		self.AdminBankGUI.Tabs.List[ v.Internal ] = vgui.Create( "DPanelList2", self.AdminBankGUI.Tabs )
		self.AdminBankGUI.Tabs.List[ v.Internal ]:SetPos( 4, 25 )
		self.AdminBankGUI.Tabs.List[ v.Internal ]:SetSize( self.AdminBankGUI:GetWide() - 8, self.AdminBankGUI:GetTall() - 28 )
		self.AdminBankGUI.Tabs.List[ v.Internal ]:EnableHorizontal( true )
		self.AdminBankGUI.Tabs.List[ v.Internal ]:SetSpacing( 2 )
		self.AdminBankGUI.Tabs.List[ v.Internal ]:EnableVerticalScrollbar()
		self.AdminBankGUI.Tabs.List[ v.Internal ]:SetScrollBarColors( Scoreboard.Customization.ColorNormal, Scoreboard.Customization.ColorBackground )

		self.AdminBankGUI.Tabs:AddSheet( v.Friendly, self.AdminBankGUI.Tabs.List[ v.Internal ], nil, false, false, nil /*v.Tooltip or v.Friendly*/ )

	end

	table.sort( self.SortedItems, function(a, b)
		return a.Name < b.Name
	end )

	for _, v in ipairs ( self.SortedItems ) do
		self:AddGUIItem( v )
	end

end


function GTowerItems:CloseAdmin()
	if IsValid( self.AdminBankGUI ) then
		self.AdminBankGUI:SetVisible( false )
	end
	GtowerMainGui:GtowerHideMenus()
end

hook.Add("GTowerAdminMenus", "AdminBank", function()
	return {
		["Name"] = "Admin Bank",
		["function"] = function() GTowerItems:OpenAdmin() end
	}
end )

hook.Add("CanCloseMenu", "GTowerInvAdmin", function()
	if GTowerItems.AdminBankGUI && GTowerItems.AdminBankGUI:IsVisible() then
		return false
	end
end )

hook.Add("InvDropCheckClose", "GTowerAdmin", function()
	if GTowerItems.AdminBankGUI then
		for k, v in pairs( GTowerItems.AdminBankGUI.Tabs.List ) do
			if v && v:IsDragging() then
				return false
			end
		end
	end
end )

local function MouseInWindow( panel )
	local x,y = panel:CursorPos()
    return x >= 0 && y >= 0 && x <= panel:GetWide() && y <= panel:GetTall()
end

hook.Add("GTowerInvHover", "GTowerAdminBank", function( panel )
	if IsValid( GTowerItems.AdminBankGUI ) && GTowerItems.AdminBankGUI:IsVisible() && MouseInWindow( GTowerItems.AdminBankGUI ) then
		return GTowerItems.AdminBankGUI
	end
end )

concommand.Add("gmt_invadmin", function()
	if LocalPlayer():GetSetting("GTInvAdminBank") == true || LocalPlayer():IsAdmin() then
		GTowerItems:OpenAdmin()
	end
end )
