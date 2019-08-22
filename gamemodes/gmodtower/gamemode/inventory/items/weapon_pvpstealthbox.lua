
ITEM.Name = "Stealth Box"
ITEM.ClassName = "weapon_pvpstealthbox"
ITEM.Description = "Hide yourself inside a box and dissapear completely from your enemies' view.  Taunt them over towards you, then pop out and end their lives.  Snake used it, so can you."
ITEM.Model = "models/weapons/w_pvp_ire.mdl"
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
