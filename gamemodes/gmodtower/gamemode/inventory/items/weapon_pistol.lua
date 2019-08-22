
ITEM.Name = "Pistol"
ITEM.ClassName = "weapon_pistol"
ITEM.Description = ""
ITEM.Model = "models/weapons/w_pistol.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end