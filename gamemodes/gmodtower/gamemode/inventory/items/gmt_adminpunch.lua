
ITEM.Name = "Admin Fistsmoke"
ITEM.ClassName = "gmt_adminpunch"
ITEM.Description = "Punch your enemies..."
ITEM.Model = "models/weapons/w_pvp_ire.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false
ITEM.DrawName = true
ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
