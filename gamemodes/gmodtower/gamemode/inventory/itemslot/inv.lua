
local ITEMSLOT = {}
ITEMSLOT.PlaceId = 1

function ITEMSLOT:FindUnusedSlot( Item, grabbing )

    for i=1, self.Ply:MaxItems() do
        if !self.Ply:InvGetSlot( i, self.PlaceId ) then

			self.Slot = i

			if self:Allow( Item, grabbing ) then
				return
			end

			self.Slot = nil

        end
    end

end

function ITEMSLOT:CanManage()
	return true
end

function ITEMSLOT:IsEquipSlot()
	return GTowerItems:IsEquipSlot( self.Slot )
end

function ITEMSLOT:Limit()
	return self.Ply:MaxItems()
end


GTowerItems.AddItemSlot( ITEMSLOT )
