
ITEM.Name = "God Hand"
ITEM.ClassName = "gmt_godhand"
ITEM.Description = "God-o-hando!"
ITEM.Model = "models/weapons/w_pvp_ire.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false
ITEM.DrawName = true
ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
