
ITEM.Name = "Tommy Gun"
ITEM.ClassName = "weapon_tommygun"
ITEM.Description = "Tommy Gun"
ITEM.Model = "models/weapons/w_pvp_tom.mdl"
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
