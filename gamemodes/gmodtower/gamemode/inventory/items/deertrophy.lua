ITEM.Name = "Deer Trophy"
ITEM.Description = "You accidentally shot this deer at Narnia, better make good use of it!"
ITEM.Model = "models/props_swamp/trophy_deer.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = true

ITEM.StoreId = 6
ITEM.StorePrice = 350

ITEM.Manipulator = function( ang, pos, normal )

	ang:RotateAroundAxis( ang:Right(), 270 )
	ang:RotateAroundAxis( ang:Up(), 0 )
	ang:RotateAroundAxis( ang:Forward(), 180 )

	return pos

end
