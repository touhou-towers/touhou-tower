
local function CanBuyItem( Item )

	if !Item.InvSqlId then //WTF Inventory item with no SQL id?
		Msg("Inventory store: Item does not have a SQL ID (".. tostring(Item.Id) ..")\n")
		return true
	end

	local InvItem = GTowerItems:Get( Item.InvSqlId )
	local IsWeapon = InvItem.Equippable

	for i=1, GTowerItems:MaxItems() do //Look trough all items
		if !GTowerItems:GetItem( i ) && GTowerItems:AllowPosition( InvItem, i ) then //Check if there is  a free slot
			return true
		end
	end

	//No free slots, no new items
	Msg2( T("StoreNoSlots") )

	return false
end


function GTowerItems:CreateStoreItemEnd( item )
	local StoreItem = GTowerStore:SQLInsert( {
		storeid = item.StoreId,
		upgradable = false,
		ClientSide = true,
		unique_Name = "Inv_" .. item.UniqueName,
		InvSqlId = item.MysqlId,
		Name  = item.Name,
		description = item.Description,
		model = item.Model,
		drawmodel = true,
		price = item.StorePrice or 0,
		IsNew = item.NewItem,
		canbuy = CanBuyItem,
		ModelSkin = item.ModelSkinId
	} )

	item.StoreItem = StoreItem

end
