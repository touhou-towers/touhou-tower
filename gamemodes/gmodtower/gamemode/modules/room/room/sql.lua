
module("Suite", package.seeall)

function UpdateRoomSaveData( self )

	self.Owner._RoomSaveData = {}

	for _, ent in pairs( self:EntsInRoom() ) do

		local ItemId = self:InventorySave( ent )

		if ItemId then

			//Make sure the player table keeps up to date
			//If the player check-out and check in, the old data will still be there
			table.insert( self.Owner._RoomSaveData, ItemId )

		end

	end

end

function GetSQLSave( self )

	if #self.ToAdd > 0 then
		return
	end

	local Data = _G.Hex()
	self:UpdateRoomSaveData()

	for _, v in pairs( self.Owner._RoomSaveData ) do

		//2147483648 = 2^(8*4)/2
		Data:Write( v.InvItem, 4 )
		Data:Write( 2147483648 + math.Round( v.pos.x * 100 ), 8 )
		Data:Write( 2147483648 + math.Round( v.pos.y * 100 ), 8 )
		Data:Write( 2147483648 + math.Round( v.pos.z * 100 ), 8 )
		Data:Write( 18000 + math.Round( v.ang.p * 100 ), 5 )
		Data:Write( 18000 + math.Round( v.ang.y * 100 ), 5 )
		Data:Write( 18000 + math.Round( v.ang.r * 100 ), 5 )

	end

	if table.Count( self.Owner._RoomSaveData ) < 1 then
		return "0xFFFFFF"
	end

	return Data:Get()

end

function SQLLoadData( Owner, val )

	if string.len( val ) < 20 && val != "FFFFFF" then
		return
	end

	Owner._RoomSaveData = {}

	local Data = _G.Hex( val )

	if DEBUG then
		Msg("Reading ", Owner, " MySQL data (".. Data:DataLenght() ..")\n")
	end

	while Data:CanRead( 8 ) do

		local ItemId = Data:Read( 4 )
		local PosX = (Data:Read( 8 ) - 2147483648) / 100
		local PosY = (Data:Read( 8 ) - 2147483648) / 100
		local PosZ = (Data:Read( 8 ) - 2147483648) / 100
		local AngP = (Data:Read( 5 ) - 18000) / 100
		local AngY = (Data:Read( 5 ) - 18000) / 100
		local AngR = (Data:Read( 5 ) - 18000) / 100

		if DEBUG then
			Msg("\t Read item: " .. ItemId .. "\n")
		end

		table.insert( Owner._RoomSaveData, {
			["InvItem"] = ItemId,
			["pos"] = Vector( PosX, PosY, PosZ ),
			["ang"] = Angle( AngP, AngY, AngR )
		} )

	end

	if DEBUG then
		PrintTable( Owner._RoomSaveData )
	end
end
