
local DEBUG = false
GTowerItems.NetworkLoaded = true

function GTowerItems:ItemChanged( ply, id )

	if id == nil then
		Error("GTowerItems:ItemChanged called with nil id!")
	end

	//if !ply.InvNetSend then
	//	ply.InvNetSend = {}
	//end

	if DEBUG then
		Msg("InvetoryNW: Adding " .. tostring(ply) .. " for item id " .. id .. "\n")
	end

	//if !table.HasValue( ply.InvNetSend, id ) then
	//	table.insert( ply.InvNetSend, id )
	//end

	ClientNetwork.AddPacket( ply, "InvNetItem" .. id , self.PlyNetworkThink, id, false )

end

function GTowerItems:BankItemChanged( ply, id )

	//if !ply.InvBankNetSend then
	//	ply.InvBankNetSend = {}
	//end

	if DEBUG then
		Msg("InvetoryNW: Adding " .. tostring(ply) .. " for item id " .. id .. "\n")
	end

	//if !table.HasValue( ply.InvBankNetSend, id ) then
	//	table.insert( ply.InvBankNetSend, id )
	//end

	ClientNetwork.AddPacket( ply, "InvNetBank" .. id , self.PlyNetworkThink, id, true )

end

local function SendNwItem( ply, SlotId, IsBank )

	local Item

	if IsBank then
		Item = ply:GetBankSlot( SlotId )
	else
		Item = ply:InvGetSlot( SlotId )
	end

	if DEBUG then Msg("InvetoryNW: " .. tostring(ply) .. " finish sending " .. tostring(Item) .. " (" .. SlotId .. ")\n" ) end

	umsg.Start("Inv", ply )

	if !Item then

		umsg.Char( 1 )
		umsg.Bool( IsBank )
		umsg.Char( SlotId - 127 )


	else

		umsg.Char( 2 )
		umsg.Bool( IsBank )
		umsg.Char( SlotId - 128 )
		umsg.Short( Item.MysqlId - 32768 )

		if type( Item.CustomNW ) == "function" then
			Item:CustomNW()
		end

	end

	umsg.End()

end

GTowerItems.PlyNetworkThink = function( ply, SlotId, IsBank )

	SendNwItem( ply, SlotId, IsBank )

	return false, 0.1

end

/*
timer.Create("GTowerInvSendItem", 0.1, 0, function()

	//for ply, tbl in pairs( GTowerItems.NetworkSend ) do
	for _, ply in ipairs( player.GetAll() ) do

		if ply.InvNetSend && #ply.InvNetSend > 0 then

			local SlotId = table.remove( ply.InvNetSend )
			local Item =  ply:InvGetSlot( SlotId )

			if DEBUG then Msg("InvetoryNW: " .. tostring(ply) .. " finish sending " .. tostring(Item) .. " (" .. SlotId .. ")\n" ) end

			SendNwItem( ply, SlotId, Item, false )

		end

		if ply.InvBankNetSend && #ply.InvBankNetSend > 0 then

			local SlotId = table.remove( ply.InvBankNetSend )
			local Item =  ply:GetBankSlot( SlotId )

			SendNwItem( ply, SlotId, Item, true )

		end

	end

end )
*/
