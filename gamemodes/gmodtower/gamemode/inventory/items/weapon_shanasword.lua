
ITEM.Name = "Shana's Sword"
ITEM.ClassName = "weapon_shanasword"
ITEM.Description = "Shana's Sword"
ITEM.Model = "models/weapons/w_shanasw.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
