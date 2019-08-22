
ITEM.Name = "Physcannon"
ITEM.ClassName = "weapon_physcannon"
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