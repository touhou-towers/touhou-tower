
ITEM.Name = "Pulse Smart Pen"
ITEM.ClassName = "weapon_pulsesmartpen"
ITEM.Description = "Pulse Smart Pen"
ITEM.Model = "models/weapons/w_psmartpen.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
