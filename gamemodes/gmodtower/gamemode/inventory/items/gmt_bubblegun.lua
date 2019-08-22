ITEM.Name = "Bubble Gun"
ITEM.ClassName = "gmt_bubblegun"
ITEM.Description = "Shoot as many bubbles as you'd like."
ITEM.Model = "models/weapons/w_pistol.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = true

ITEM.EquipType = "Weapon"
ITEM.Equippable = true
ITEM.WeaponSafe = true

ITEM.StoreId = 22
ITEM.StorePrice = 375

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
