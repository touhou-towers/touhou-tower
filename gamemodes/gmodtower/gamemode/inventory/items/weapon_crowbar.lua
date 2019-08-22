
ITEM.Name = "Crowbar"
ITEM.ClassName = "weapon_crowbar"
ITEM.Description = ""
ITEM.Model = "models/weapons/w_crowbar.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end