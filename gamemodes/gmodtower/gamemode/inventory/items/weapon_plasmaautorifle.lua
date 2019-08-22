
ITEM.Name = "Plasma Auto-rifle"
ITEM.ClassName = "weapon_plasmaautorifle"
ITEM.Description = "Plasma Auto-rifle"
ITEM.Model = "models/weapons/w_vir_par.mdl"
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
