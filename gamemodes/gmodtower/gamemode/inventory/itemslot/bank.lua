
local ITEMSLOT = {}
ITEMSLOT.PlaceId = 2


function ITEMSLOT:FindUnusedSlot( Item )

    for i=1, self.Ply:BankLimit() do
        if !self.Ply:InvGetSlot( i, self.PlaceId ) then
			self.Slot = i
			return
        end
    end

end

function ITEMSLOT:Limit()
	return self.Ply:BankLimit()
end

GTowerItems.AddItemSlot( ITEMSLOT )
