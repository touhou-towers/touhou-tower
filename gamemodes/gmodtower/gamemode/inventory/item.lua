
local ItemSlotList = {}

function GTowerItems.AddItemSlot( tbl )

	setmetatable( tbl, GTowerItems.SlotBaseMetaTable ) 

	ItemSlotList[ tbl.PlaceId ] = {
		__index = tbl
	}
	
end


function GTowerItems:NewItemSlot( ply, str )

	if !str then
		str = ""
	elseif type( str ) == "table" then
		if !str.PlaceId then return end //Not the type of table I want
		return str
	end

	local Exploded = string.Explode( "-", str )
	
	local Slot = tonumber( Exploded[1] )
	local Place = tonumber( Exploded[2] ) or 1
	
	if !ItemSlotList[ Place ] then
		return
	end
	
	local ItemSlot = setmetatable( {}, ItemSlotList[ Place ]  )
	
	ItemSlot:Create( ply, Slot )
	
	return ItemSlot
	
end

include("itemslot/base.lua")
include("itemslot/inv.lua")
include("itemslot/bank.lua")
include("itemslot/admin.lua")
include("itemslot/wearable.lua")