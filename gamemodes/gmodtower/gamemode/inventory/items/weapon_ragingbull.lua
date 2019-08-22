
ITEM.Name = "Raging Bull"
ITEM.ClassName = "weapon_ragingbull"
ITEM.Description = "Raging Bull"
ITEM.Model = "models/weapons/w_pvp_ragingb.mdl"
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
