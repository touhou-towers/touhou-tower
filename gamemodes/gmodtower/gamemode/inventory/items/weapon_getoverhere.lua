
ITEM.Name = "GET OVER HERE!"
ITEM.ClassName = "weapon_getoverhere"
ITEM.Description = "FATALITY!"
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
