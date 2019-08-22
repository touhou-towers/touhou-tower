
ITEM.Name = "AR2 Rifle"
ITEM.ClassName = "weapon_ar2"
ITEM.Description = ""
ITEM.Model = "models/weapons/w_irifle.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end