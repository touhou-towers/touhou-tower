
ITEM.Name = "RYNO V"
ITEM.ClassName = "weapon_rynov"
ITEM.Description = "America!"
ITEM.Model = "models/Weapons/w_rocket_launcher.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
