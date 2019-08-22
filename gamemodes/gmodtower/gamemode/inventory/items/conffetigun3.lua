
ITEM.MaxUses = 10
ITEM.Name = "Confetti! ("..ITEM.MaxUses..")"
ITEM.ClassName = "gmt_confetti"
ITEM.Description = ""
ITEM.Model = "models/gmod_tower/item_confetti.mdl"
ITEM.DrawModel = true
ITEM.CanEntCreate = false

ITEM.EquipType = "Weapon"
ITEM.Equippable = true
ITEM.WeaponSafe = true

ITEM.StoreId = 22
ITEM.StorePrice = 180

function ITEM:OnCreate( data )
	self.UsesLeft = tonumber( data ) or self.MaxUses

	if SERVER then
		self.Ply.UsesLeft = self.UsesLeft
		self.Ply.MaxUses = self.MaxUses
	end

	if CLIENT then
		self:UpdateString()
	end
end

function ITEM:IsWeapon()
	return true
end

if SERVER then

	function ITEM:WeaponDeployed()
		self.Ply.UsesLeft = self.UsesLeft
		self.Ply.MaxUses = self.MaxUses
	end

	function ITEM:WeaponHolstered()
		self.Ply.UsesLeft = -1
		self.Ply.MaxUses = -1
	end

	function ITEM:WeaponFired()
		self.UsesLeft = self.UsesLeft - 1
		self.Ply.UsesLeft = self.UsesLeft

		self:CheckUses()
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
		surface.DrawText( self.UsesLeftString )
	end

end
