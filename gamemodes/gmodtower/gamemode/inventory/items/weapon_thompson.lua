
ITEM.Name = "Thompson"
ITEM.ClassName = "weapon_thompson"
ITEM.Description = "Thompson"
ITEM.Model = "models/weapons/w_pvp_tom.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
