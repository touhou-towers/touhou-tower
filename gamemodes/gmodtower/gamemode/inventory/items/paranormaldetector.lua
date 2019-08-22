ITEM.Name = "Paranormal Detector"
ITEM.ClassName = "tracker"
ITEM.Description = "Track ghosts, reveal the truth. From the Halloween 2015 Event."
ITEM.Model = "models/weapons/v_alyxgun.mdl"
ITEM.DrawModel = true
ITEM.CanEntCreate = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true
ITEM.WeaponSafe = true

ITEM.StoreId = 29
ITEM.StorePrice = 500

ITEM.Tradable = false
ITEM.UniqueInventory = true

function ITEM:IsWeapon()
	return true
end