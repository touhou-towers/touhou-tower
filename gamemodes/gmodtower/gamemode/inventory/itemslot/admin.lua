
local ITEMSLOT = {}
ITEMSLOT.PlaceId = 3

function ITEMSLOT:Name()
	return tostring( self.Slot ) .. "-".. self.PlaceId
end

function ITEMSLOT:Create( ply, slot )
	self.Ply = ply
	self.Slot = slot
end

function ITEMSLOT:FindUnusedSlot( Item )
	self.Slot = Item
end

function ITEMSLOT:CanManage()
	if self.Ply:GetSetting("GTInvAdminBank") == true || self.Ply:IsAdmin() then
		local Item = GTowerItems.Items[ self.Slot ]

		if ( Item == nil ) then return false end

		if Item.BankAdminOnly == true then
			return self.Ply:IsAdmin()
		end

		return true
	end
	return false
end

function ITEMSLOT:Remove()
end

function ITEMSLOT:Get()
	return GTowerItems:CreateById( self.Slot, self.Ply )
end

function ITEMSLOT:Set( item )
end

function ITEMSLOT:IsValid()
	return true
end

function ITEMSLOT:Allow( Item )
	//Only allow blank slots to go here
	//Otherwise some stuff might disapear
	return Item == nil
end

function ITEMSLOT:ItemChanged()
end

function ITEMSLOT:Compare( ItemSlot )
	return self.Ply == ItemSlot.Ply &&
		self.Slot == ItemSlot.Slot &&
		self.PlaceId == ItemSlot.PlaceId
end

GTowerItems.AddItemSlot( ITEMSLOT )
