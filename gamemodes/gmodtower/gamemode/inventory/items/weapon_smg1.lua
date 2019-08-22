
ITEM.Name = "Sub-machine Gun"
ITEM.ClassName = "weapon_smg1"
ITEM.Description = ""
ITEM.Model = "models/weapons/w_smg1.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end