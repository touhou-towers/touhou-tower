
ITEM.Name = "Camera"
ITEM.ClassName = "gmt_camera"
ITEM.Description = "Take screenshots without the HUD - and with zoom!"
ITEM.Model = "models/MaxOfS2D/camera.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = false
ITEM.Tradable = false
ITEM.DrawName = true
ITEM.EquipType = "Weapon"
ITEM.Equippable = true
ITEM.StoreId = 7
ITEM.StorePrice = 250
ITEM.WeaponSafe = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end
