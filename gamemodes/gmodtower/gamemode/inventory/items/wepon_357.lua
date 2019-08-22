ITEM.Name = ".357"
ITEM.ClassName = "wepon_357"
ITEM.Description = "A gun? Better be careful with this."
ITEM.Model = "models/weapons/w_357.mdl"
ITEM.DrawModel = true
ITEM.CanEntCreate = false
ITEM.DrawName = true
ITEM.StorePrice = 250

ITEM.EquipType = "Weapon"
ITEM.Equippable = true
ITEM.WeaponSafe = true

function ITEM:IsWeapon()
	return true
end
