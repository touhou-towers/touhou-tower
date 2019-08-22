
ITEM.Name = "SPAS 12"
ITEM.ClassName = "weapon_spas12"
ITEM.Description = "SPAS 12"
ITEM.Model = "models/weapons/w_pvp_s12.mdl"
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
