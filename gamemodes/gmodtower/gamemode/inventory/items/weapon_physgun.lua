
ITEM.Name = "Physgun"
ITEM.ClassName = "weapon_physgun"
ITEM.Description = ""
ITEM.Model = "models/weapons/w_physics.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end