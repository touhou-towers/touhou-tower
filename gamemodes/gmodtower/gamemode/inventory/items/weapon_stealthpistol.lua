
ITEM.Name = "Stealth Pistol"
ITEM.ClassName = "weapon_stealthpistol"
ITEM.Description = "Stealth Pistol"
ITEM.Model = "models/weapons/w_pistol.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
