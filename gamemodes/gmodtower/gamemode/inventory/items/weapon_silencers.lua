
ITEM.Name = "Dual Silencers"
ITEM.ClassName = "weapon_silencers"
ITEM.Description = "Dual Silencers"
ITEM.Model = "models/weapons/w_vir_dsilen.mdl"
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
