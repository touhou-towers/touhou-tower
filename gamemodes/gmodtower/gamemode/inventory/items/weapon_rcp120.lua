
ITEM.Name = "RCP 120"
ITEM.ClassName = "weapon_rcp120"
ITEM.Description = "RCP 120"
ITEM.Model = "models/weapons/w_rcp120.mdl"
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
