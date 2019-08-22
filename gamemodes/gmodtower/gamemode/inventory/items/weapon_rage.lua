
ITEM.Name = "Rage Fists"
ITEM.ClassName = "weapon_rage"
ITEM.Description = "Rage Fists"
ITEM.Model = "models/weapons/w_pvp_ire.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false
ITEM.DrawName = true

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
