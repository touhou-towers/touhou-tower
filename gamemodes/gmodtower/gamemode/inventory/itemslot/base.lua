
local SLOTBASE = {}
GTowerItems.SlotBaseMetaTable = {
	__index = SLOTBASE,
	__eq = function( o1, o2 )
		return o1:Compare( o2 )
	end
}

SLOTBASE.BaseClass = SLOTBASE

function SLOTBASE:Name()
	return tostring( self.Slot ) .. "-".. self.PlaceId
end

function SLOTBASE:Create( ply, slot )
	self.Ply = ply
	self.Slot = slot
end

function SLOTBASE:CanManage()
	return true
end

function SLOTBASE:Set( Item )

	if self:IsEquipSlot() then
		local OldItem = self:Get()

		if OldItem then
			GTowerItems.OnRemoveEquip( self, OldItem )
		end
	end

	self.Ply._GtowerPlayerItems[ self.PlaceId ][ self.Slot ] = Item

	if Item then
		Item.Slot = self:Name()
		Item:OnMove( self )

		if self:IsEquipSlot() then
			GTowerItems.OnEquip( self, Item )
		end

	end

end

function SLOTBASE:Allow( Item, grabbing )

	if Item then

		if grabbing == true then

			if Item.UniqueInventory == true && self.Ply:HasItemById( Item.MysqlId, true ) then
				return false
			end

		end

		if self:IsEquipSlot() then
			if Item.Equippable != true then
				return false
			end

			//Check the equipment can only be put on once of a kind
			if Item.UniqueEquippable == true then
				local Equipment = self.Ply:GetEquipment( Item.EquipType )

				if Equipment && Equipment != self:Get() && Equipment != Item then
					return false
				end

			end

			//Check if the player is already wearing that specific mysql id
			for _, v in pairs( self.Ply:GetEquipedItems() ) do

				if v.MysqlId == Item.MysqlId then
					return false
				end

			end

		end

		if Item.AllowSlot && Item:AllowSlot( self, grabbing ) == false then
			return false
		end

	end

	return true

end

function SLOTBASE:Remove()
	local Item = self:Get()

	if Item then
		Item:OnRemove()
		Item.ValidItem = false
	end

	self:Set( nil )
	hook.Call("InvRemove", GAMEMODE, self.Ply, self, Item )
end

function SLOTBASE:IsEquipSlot()
	return false
end

function SLOTBASE:IsValid()
	return self.Slot && self.Slot >= 1 && self.Slot <= self:Limit()
end

function SLOTBASE:_SendNetwork()

	local Item = self:Get()

	umsg.Start("Inv", self.Ply )

	umsg.Char( 1 )
	umsg.Char( self.PlaceId )
	umsg.Char( self.Slot - 128 )

	if !Item then
		umsg.Bool( false )
	else
		umsg.Bool( true )
		umsg.Short( Item.MysqlId - 32768 )

		if type( Item.CustomNW ) == "function" then
			Item:CustomNW()
		end

	end

	umsg.End()

end

local function ReceiveItem( ply, Slot )
	Slot:_SendNetwork()
end

function SLOTBASE:ItemChanged()
	if GTowerItems.NetworkLoaded == true then
		NetworkQueue.Add( self.Ply, ReceiveItem, self )
	end
end



function SLOTBASE:Get()
	if !IsValid(self) then return end
	if self.Ply._GtowerPlayerItems then
		return self.Ply._GtowerPlayerItems[ self.PlaceId ][ self.Slot ]
	end
end

function SLOTBASE:Empty()
	return !self:Get()
end

function SLOTBASE:Compare( ItemSlot )
	return self.Ply == ItemSlot.Ply &&
		self.Slot == ItemSlot.Slot &&
		self.PlaceId == ItemSlot.PlaceId
end
