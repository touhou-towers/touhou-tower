
ITEM.Name = "Rocket Launcher"
ITEM.ClassName = "weapon_rpg"
ITEM.Description = ""
ITEM.Model = "models/weapons/w_rocket_launcher.mdl"
ITEM.UniqueInventory = true
ITEM.DrawModel = true
ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true

GtowerPrecacheModel( ITEM.Model )

function ITEM:IsWeapon()
	return true
end

if SERVER then
	function ITEM:OnEquip()
		if self.Ply:IsAdmin() then
			self.Ply:GiveAmmo(100, "RPG_Round", false )
		end		
	end
end