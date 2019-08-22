
ITEM.Name = "Admin Beatstick"
ITEM.ClassName = "gmt_beatstick"
ITEM.Description = "Beat em up."
ITEM.Model = "models/weapons/w_stunbaton.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
