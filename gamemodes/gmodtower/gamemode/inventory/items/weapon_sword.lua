
ITEM.Name = "Sword"
ITEM.ClassName = "weapon_sword"
ITEM.Description = "Sword"
ITEM.Model = "models/weapons/w_pvp_swd.mdl"
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
