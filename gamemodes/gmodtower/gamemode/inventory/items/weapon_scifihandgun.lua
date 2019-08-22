
ITEM.Name = "Sci-fi Handgun"
ITEM.ClassName = "weapon_scifihandgun"
ITEM.Description = "Sci-fi Handgun"
ITEM.Model = "models/weapons/w_vir_scifihg.mdl"
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
