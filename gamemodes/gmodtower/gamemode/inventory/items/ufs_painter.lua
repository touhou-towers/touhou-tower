
ITEM.Name = "Monotone Painter"
ITEM.ClassName = "ufs_painter"
ITEM.Description = "PLOP PLOP BLOB PLOP BLOB"
ITEM.Model = "models/Weapons/w_rocket_launcher.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
