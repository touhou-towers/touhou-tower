
ITEM.Name = "Double Barrel Shotgun"
ITEM.ClassName = "weapon_doublebarrel"
ITEM.Description = "Double Barrel Shotgun"
ITEM.Model = "models/weapons/w_vir_doubleb.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = false
ITEM.Tradable = false
ITEM.DrawName = true
ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
