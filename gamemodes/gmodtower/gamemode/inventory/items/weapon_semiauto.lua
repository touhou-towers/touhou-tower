
ITEM.Name = "Semi-auto Glock"
ITEM.ClassName = "weapon_semiauto"
ITEM.Description = "Semi-auto Glock"
ITEM.Model = "models/weapons/w_pvp_semiauto.mdl"
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
