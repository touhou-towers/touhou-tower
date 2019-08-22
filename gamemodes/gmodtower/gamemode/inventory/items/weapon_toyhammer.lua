
ITEM.Name = "Toy Hammer"
ITEM.ClassName = "weapon_toyhammer"
ITEM.Description = "Toy Hammer"
ITEM.Model = "models/weapons/w_pvp_toy.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
