
ITEM.Name = "Sniper"
ITEM.ClassName = "weapon_sniper"
ITEM.Description = "Sniper"
ITEM.Model = "models/weapons/w_pvp_as50.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
