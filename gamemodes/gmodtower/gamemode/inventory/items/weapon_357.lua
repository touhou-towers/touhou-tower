
ITEM.Name = ".357 Magnum"
ITEM.ClassName = "weapon_357"
ITEM.Description = ""
ITEM.Model = "models/weapons/w_357.mdl"
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end