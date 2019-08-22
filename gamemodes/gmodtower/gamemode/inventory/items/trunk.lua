
ITEM.Name = "Trunk"
ITEM.Description = "Store tons of items in here."
ITEM.Model = "models/gmod_tower/suitetrunk.mdl"
ITEM.ClassName = "gmt_trunk"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.CanRemove = false
ITEM.Tradable = false
ITEM.InvCategory = "1" // suite

function ITEM:AllowSlot( slot, grabbing )
	return slot.PlaceId != 2
end