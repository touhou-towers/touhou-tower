
ITEM.Name = "Chainsaw"
ITEM.ClassName = "weapon_chainsaw"
ITEM.Description = "Chainsaw"
ITEM.Model = "models/weapons/w_pvp_chainsaw.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
