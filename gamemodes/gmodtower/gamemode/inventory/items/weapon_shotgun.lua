
ITEM.Name = "Shotgun"
ITEM.ClassName = "weapon_shotgun"
ITEM.Description = ""
ITEM.Model = "models/weapons/w_shotgun.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end