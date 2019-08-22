
ITEM.Name = "Rubber Grenade"
ITEM.ClassName = "weapon_bouncynade"
ITEM.Description = "Rubber Grenade"
ITEM.Model = "models/weapons/w_eq_fraggrenade.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
