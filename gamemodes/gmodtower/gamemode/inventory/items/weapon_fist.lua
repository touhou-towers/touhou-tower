
-----------------------------------------------------

ITEM.Name = "Puncher 500"

ITEM.ClassName = "weapon_rage"

ITEM.Description = "Tired of getting beat up by the man? Punch your way to a new future!"

ITEM.Model = "models/weapons/w_pvp_ire.mdl"

ITEM.DrawModel = true

ITEM.CanEntCreate = false



ITEM.EquipType = "Weapon"

ITEM.Equippable = true

ITEM.WeaponSafe = true



ITEM.StoreId = 22

ITEM.StorePrice = 5000


function ITEM:IsWeapon()

	return true

end