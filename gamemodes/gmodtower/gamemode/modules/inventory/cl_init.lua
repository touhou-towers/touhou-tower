
include("shared.lua")
include("cl_maininv.lua")
include("cl_maindrop.lua")
include("cl_mainitem.lua")
include("cl_grab.lua")
include("cl_admin.lua")
include("cl_bank.lua")
include("cl_bankitem.lua")
include("cl_debug.lua")
include("cl_weapon.lua")
include("cl_tooltip.lua")
include("cl_tooltipgui.lua")
include("trade/cl_init.lua")
include("cl_playermodel.lua")
include("inventorysaver/cl_init.lua")


GTowerItems.MainInvPanel = nil
GTowerItems.DropInvPanel = nil
GTowerItems.InvItemSize = 52

GTowerItems.GtowerItems = {}
GTowerItems.InvDesc = nil

table.insert( GtowerHudToHide, "CHudWeaponSelection" )

function GTowerItems:MaxItems()
	return LocalPlayer().GtowerMaxItems or GTowerItems.DefaultInvCount
end

function GTowerItems:MaxBank()
	if !LocalPlayer().GtowerBankMax then
		return GTowerItems.DefaultBankCount
	end

	return LocalPlayer().GtowerBankMax + 100
end


hook.Add( "GtowerShowMenus","OpenInventory", function()
	GTowerItems:OpenMainInventory()
end )


hook.Add( "GtowerHideMenus","CloseInventory", function()

	if GTowerItems.MainInvPanel then
		GTowerItems.MainInvPanel:Close()
	end

	if GTowerItems.DropInvPanel then
		GTowerItems.DropInvPanel:Close()
	end

end )

hook.Add( "InvGuiDrop", "GTowerMainDrop", function( panel )
	for k, v in pairs( GTowerItems.GtowerItems[1] ) do
		if v._VGUI && panel != v._VGUI && v._VGUI:IsMouseInWindow() then
			return v._VGUI
		end
	end
end )

function GTowerItems:OpenAll()
	self:OpenMainInventory()
	self:OpenDropInventory()
end

function GTowerItems:OpenMainInventory()

	if !self.MainInvPanel then
		self.MainInvPanel = vgui.Create( "GTowerInvMain" )
		self.MainInvPanel:ForceClose()
	end

	self.MainInvPanel:Open()
	self.MainInvPanel:InvalidateLayout()

end

function GTowerItems:OpenDropInventory()

	if !self.DropInvPanel then
		self.DropInvPanel = vgui.Create( "GTowerInvDrop" )
	end

	self.DropInvPanel:Open()
	self.DropInvPanel:InvalidateLayout()

end


function GTowerItems:GetItem( id )
	if self.GtowerItems[1][ id ] then
		return self.GtowerItems[1][ id ].Item
	end
	return nil
end


function GTowerItems:AllowSwap( slot1, slot2 )

	local Item1 = self:GetItem( slot1 )
	local Item2 = self:GetItem( slot2 )

	if Item1 then
		if !self:AllowPosition( Item1, slot2 ) then
			return false
		end
	end

	if Item2 then
		if !self:AllowPosition( Item2, slot1 ) then
			return false
		end
	end

	if hook.Call("GTowerAllowSwap", GAMEMODE, slot1, slot2, Item1, Item2 ) == false then
		return false
	end

	return true
end


/* ===================================
 == INTERNAL FUNCTIONS
====================================== */

function GTowerItems:CreateItemOfID( id )

	if !self.GtowerItems[1][ id ] then
		self.GtowerItems[1][ id ] = {}
	end

	if !self.GtowerItems[1][ id ]._VGUI then
		local panel = vgui.Create("GtowerInvItem")

		panel:SetId( id )
		panel:UpdateParent()

		self.GtowerItems[1][ id ]._VGUI = panel
	end

end

function GTowerItems:GetOriginalParent( id )

	if self:IsEquipSlot( id ) then
		return GTowerItems.MainInvPanel
	end

	return GTowerItems.DropInvPanel

end

function GTowerItems:CheckSubClose()

	if GTowerItems.DropInvPanel then
		GTowerItems.DropInvPanel:CheckClose()
	end

end

function GTowerItems:ReloadMaxItems()

	local function CheckLimits( Place, limit )

		if !GTowerItems.GtowerItems[ Place ] then
			GTowerItems.GtowerItems[ Place ] = {}
		end

		local Tbl = GTowerItems.GtowerItems[ Place ]

		for k, v in pairs( Tbl ) do
			if k < 1 || k > limit then
				Tbl[ k ] = nil
			end
		end

		for i=1, limit do
			if !Tbl[ i ] then
				Tbl[ i ] = {}
			end
		end

	end

	CheckLimits( 1, GTowerItems:MaxItems() )
	CheckLimits( 2, GTowerItems:MaxBank() )
	CheckLimits( 4, GTowerItems.EquippableSlots)

	GTowerItems:InvalidateBankLayout()

end
GTowerItems:ReloadMaxItems()


usermessage.Hook("Inv", function( um )

	local MsgId = um:ReadChar()

	if MsgId == 1 then

		local Place = um:ReadChar()
		local Slot = um:ReadChar() + 128
		local Valid = um:ReadBool()

		if !GTowerItems.GtowerItems[ Place ] then
			GTowerItems.GtowerItems[ Place ] = {}
		end

		if !GTowerItems.GtowerItems[ Place ][ Slot ] then
			GTowerItems.GtowerItems[ Place ][ Slot ] = {}
		end

		local ItemObj = GTowerItems.GtowerItems[ Place ][ Slot ]

		if ItemObj.Item then
			if ItemObj.Item then
				ItemObj.Item:OnRemove()
				ItemObj.Item.ValidItem = false
			end

			hook.Call("InventoryChanged", GAMEMODE, ItemObj )

			ItemObj.Item = nil
		end

		if Valid then

			local ItemId = um:ReadShort() + 32768
			local Item = GTowerItems:CreateById( ItemId )

			if !Item then
				print("Could not create item of Id: " .. ItemId )
				return
			end

			Item.SlotId = Slot
			Item.PlaceId = Place

			if Item.ReadFromNW then
				Item:ReadFromNW( um )
			end

			ItemObj.Item = Item

			if ValidPanel( ItemObj._VGUI ) then
				Item._VGUI = ItemObj._VGUI
			end

		end

		if ValidPanel( ItemObj._VGUI ) then
			ItemObj._VGUI:InvalidateLayout()
		end

		hook.Call("InventoryChanged", GAMEMODE, ItemObj )

		/*
		local IsBank = um:ReadBool()
		local Slot = um:ReadChar() + 127
		local ItemObj = GTowerItems:GetSpecialItem( Slot, IsBank )

		if ItemObj.Item then
			ItemObj.Item:OnRemove()
			ItemObj.Item.ValidItem = false
		end

		hook.Call("InventoryChanged", GAMEMODE, ItemObj )

		ItemObj.Item = nil

		if IsValid( ItemObj._VGUI ) then
			ItemObj._VGUI:InvalidateLayout()
		end

		if IsBank then
			GTowerItems:InvalidateBankLayout()
		end

	elseif MsgId == 2 then

		local IsBank = um:ReadBool()
		local Slot = um:ReadChar() + 128
		local Id = um:ReadShort() + 32768
		local BaseItem = GTowerItems:Get( Id )
		local ItemObj = GTowerItems:GetSpecialItem( Slot, IsBank )

		if ItemObj.Item then
			ItemObj.Item:OnRemove()
			ItemObj.Item.ValidItem = false
			hook.Call("InventoryChanged", GAMEMODE, ItemObj )
		end

		local Item = GTowerItems:CreateById( Id )

		if !Item then
			print("Could not create item of Id: " .. Id )
		end

		ItemObj.Item = Item
		Item.SlotId = Slot
		Item.IsBankSlot = IsBank

		if ValidPanel( ItemObj._VGUI ) then
			Item._VGUI = ItemObj._VGUI
			ItemObj._VGUI:InvalidateLayout()
		end

		if Item.ReadFromNW then
			Item:ReadFromNW( um )
		end

		if IsBank then
			GTowerItems:InvalidateBankLayout()
		end

		hook.Call("InventoryChanged", GAMEMODE, ItemObj )
		*/

	elseif MsgId == 3 then
		GTowerItems:OpenBank()
	end

end )
