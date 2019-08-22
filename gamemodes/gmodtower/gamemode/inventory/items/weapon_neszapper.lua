
ITEM.Name = "NES Zapper"
ITEM.ClassName = "weapon_neszapper"
ITEM.Description = "NES Zapper"
ITEM.Model = "models/weapons/w_pvp_neslg.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
