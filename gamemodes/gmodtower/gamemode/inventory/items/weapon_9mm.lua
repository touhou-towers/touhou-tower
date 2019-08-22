
ITEM.Name = "9mm Handgun"
ITEM.ClassName = "weapon_9mm"
ITEM.Description = "9mm Handgun"
ITEM.Model = "models/weapons/w_vir_9mm1.mdl"
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
