
ITEM.Name = "Flak Handgun"
ITEM.ClassName = "weapon_flakhandgun"
ITEM.Description = "Flak Handgun"
ITEM.Model = "models/weapons/w_vir_flakhg.mdl"
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
