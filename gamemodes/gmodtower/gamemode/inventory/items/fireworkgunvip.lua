
ITEM.Name = "Firework RPG Unlimited!"
ITEM.ClassName = "gmt_firework_gun"
ITEM.Description = "Shoot fireworks!"
ITEM.Model = "models/weapons/w_rocket_launcher.mdl"
ITEM.DrawModel = true
ITEM.CanEntCreate = false
ITEM.UniqueInventory = true

ITEM.Tradable = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true
ITEM.WeaponSafe = true

ITEM.StoreId = 29
ITEM.StorePrice = 6000



function ITEM:IsWeapon()
	return true
end

if SERVER then

	function ITEM:WeaponDeployed()

	end

	function ITEM:WeaponHolstered()

	end

	function ITEM:WeaponFired()
	
		self:ItemChanged()
	end

	function ITEM:CheckUses()
		if self.UsesLeft <= 0 then
			local Slot = self:GetSlot()

			if Slot:IsValid() then
				Slot:Remove()
			end
		end
	end

	function ITEM:CustomNW()
		umsg.Char( self.UsesLeft )
	end

	function ITEM:GetSaveData()
		return self.UsesLeft
	end
else

	function ITEM:CreateFromNW( um )
		self.UsesLeft = um:ReadChar()
		self:UpdateString()
	end

	function ITEM:UpdateString()
		self.UsesLeftString = tostring( self.UsesLeft ) .. "/" .. self.MaxUses
	end

	function ITEM:PaintOver()
		surface.SetFont("Default")
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 2, 2 )
	end

end
