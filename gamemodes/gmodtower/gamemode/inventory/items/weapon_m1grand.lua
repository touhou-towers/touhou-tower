
ITEM.Name = "M1 Grand"
ITEM.ClassName = "weapon_m1grand"
ITEM.Description = "M1 Grand"
ITEM.Model = "models/weapons/w_pvp_m1.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
