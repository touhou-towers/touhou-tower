
ITEM.Name = "Scope Enhanced Sniper Rifle"
ITEM.ClassName = "weapon_sniperrifle"
ITEM.Description = "Scope Enhanced Sniper Rifle"
ITEM.Model = "models/weapons/w_pvp_as50.mdl"
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
