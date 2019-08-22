
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile("sh_load.lua")
AddCSLuaFile("sh_trace.lua")
AddCSLuaFile("cl_store.lua")
AddCSLuaFile("itemslist.lua")
AddCSLuaFile("sh_rabbit.lua")
AddCSLuaFile("sh_potion.lua")
AddCSLuaFile("sh_playermodel.lua")
AddCSLuaFile("sh_baseitem.lua")

include("shared.lua")
include("hexsave.lua")
include("item.lua")
include("player.lua")
include("sh_load.lua")
include("playermodel.lua")
include("sh_playermodel.lua")
include("sh_trace.lua")
include("sql.lua")
include("sh_rabbit.lua")
include("sh_potion.lua")
include("sh_baseitem.lua")
include("equip.lua")

local ListOfStoreItems = {}
local DEBUG = false

local function OnBuyItem( ply, itemid )
	
	if DEBUG then
		Msg("Giving ", ply, " item# " , itemid , "(".. tostring(ListOfStoreItems[ itemid ]) ..")")
	end
	
	ply:InvGiveItem( ListOfStoreItems[ itemid ] )
	
end

local function CanBuyItem( ply, itemid )

	local InvItem = GTowerItems:Get( ListOfStoreItems[ itemid ] )
	
	if InvItem.UniqueInventory == true && ply:HasItemById( InvItem.MysqlId ) then
		ply:Msg2( "You already own this unique item." )
		return false
	end
	
	local InvSlot = GTowerItems:NewItemSlot( ply )
	
	InvSlot:FindUnusedSlot( InvItem, true )
	
	return InvSlot:IsValid() && InvSlot:Allow( InvItem, true )

end

function GTowerItems:CreateStoreItemEnd( item )
	
	local StoreItem = GTowerStore:SQLInsert( {
		storeid = item.StoreId,
		upgradable = false,
		ClientSide = true,
		unique_Name = "Inv_" .. item.UniqueName,
		Name  = item.Name,
		description = item.Description,
		model = item.Model,
		price = item.StorePrice or 0,
		onbuy = OnBuyItem,
		canbuy = CanBuyItem,
		InvItem = item
	} )
	
	item.StoreItem = StoreItem
	
	ListOfStoreItems[ StoreItem ] = item.MysqlId
	
	if DEBUG then
		Msg("Adding " .. item.Name .. "(".. item.MysqlId .. ") to store id " .. StoreItem .. "\n")
	end

end