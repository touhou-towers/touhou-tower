
ITEM.Name = "Sonic Shotgun"
ITEM.ClassName = "weapon_sonicshotgun"
ITEM.Description = "Sonic Shotgun"
ITEM.Model = "models/weapons/w_vir_scattergun.mdl"
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
