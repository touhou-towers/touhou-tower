ITEM.Name = "Suite Painting"
ITEM.Description = "A nice painting to decorate your suite with."
ITEM.Model = "models/gmod_tower/suite_art_large.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = true
ITEM.ModelSkinId = 0

ITEM.StoreId = 1
ITEM.StorePrice = 100

ITEM.Manipulator = function( ang, pos, normal )

	ang:RotateAroundAxis( ang:Right(), 90 )
	ang:RotateAroundAxis( ang:Up(), 0 )
	ang:RotateAroundAxis( ang:Forward(), 90 )

	return pos

end
