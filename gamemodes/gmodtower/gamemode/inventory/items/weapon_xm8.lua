
ITEM.Name = "XM8"
ITEM.ClassName = "weapon_xm8"
ITEM.Description = "XM8"
ITEM.Model = "models/weapons/w_pvp_xm8.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
