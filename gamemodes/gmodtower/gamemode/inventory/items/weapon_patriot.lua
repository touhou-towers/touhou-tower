
ITEM.Name = "Patriot"
ITEM.ClassName = "weapon_patriot"
ITEM.Description = "Patriot"
ITEM.Model = "models/weapons/w_pvp_patriotmg.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
