
ITEM.Name = "Babynade"
ITEM.ClassName = "weapon_babynade"
ITEM.Description = "Babynade"
ITEM.Model = "models/props_c17/doll01.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
