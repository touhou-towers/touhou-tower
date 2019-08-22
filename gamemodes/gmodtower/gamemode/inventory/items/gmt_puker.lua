
ITEM.Name = "Puker"
ITEM.ClassName = "gmt_puker"
ITEM.Description = "For the sick admins."
ITEM.Model = ""
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
