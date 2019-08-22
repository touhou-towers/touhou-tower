
local ITEMSLOT = {}
ITEMSLOT.PlaceId = 4

function ITEMSLOT:FindUnusedSlot( Item, grabbing )

	for i=1, GTowerItems.EquippableSlots do
			if !self.Ply:InvGetSlot( i, self.PlaceId ) then

		self.Slot = i

		if self:Allow( Item, grabbing ) then
			return
		end

		self.Slot = nil

			end
	end

end

function ITEMSLOT:Allow( Item, grabbing )


	return self.BaseClass.Allow( self, Item, grabbing )

end

function ITEMSLOT:CanManage()
	return true
end

function ITEMSLOT:IsEquipSlot()
	return true
end

function ITEMSLOT:Limit()
	return GTowerItems.EquippableSlots
end


GTowerItems.AddItemSlot( ITEMSLOT )
