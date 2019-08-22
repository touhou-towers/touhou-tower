
local GTowerItems = GTowerItems
local pairs = pairs

module("Suite")

function ResetRoom( self )

	self:UpdateRoomSaveData()

	for _, ent in pairs( self:EntsInRoom() ) do
	
		local ItemId = self:InventorySave( ent )
		
		if ItemId then
		
			local Item = GTowerItems:CreateById( ItemId, self.Owner )
			local ItemSlot = GTowerItems:NewItemSlot( self.Owner, "-2" )
			
			ItemSlot:FindUnusedSlot( Item, true )
			
			if ItemSlot:IsValid() && ItemSlot:Allow( Item, true ) then
				
				ItemSlot:Set( Item )
				ItemSlot:ItemChanged()
				
				ent:Remove()
				
			end
				
		end
		
	end

end
