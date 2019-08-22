
ITEM.Name = "Super Shotty"
ITEM.ClassName = "weapon_supershotty"
ITEM.Description = "Super Shotty"
ITEM.Model = "models/weapons/w_pvp_supershoty.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
