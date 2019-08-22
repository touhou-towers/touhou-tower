
ITEM.Name = "Grenade Launcher"
ITEM.ClassName = "weapon_glauncher"
ITEM.Description = "Grenade Launcher"
ITEM.Model = "models/weapons/w_pvp_grenade.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
