
ITEM.Name = "Shield"
ITEM.ClassName = "weapon_shield"
ITEM.Description = "Keep the players away."
ITEM.Model = "models/weapons/w_pvp_ire.mdl"
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
