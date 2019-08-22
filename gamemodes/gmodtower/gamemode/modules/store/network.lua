
local DEBUG = false

function GTowerStore:AddPlayerNetwork( ply )
	if #ply._StoreNeedSend > 0 then
		ClientNetwork.AddPacket( ply, "StoreNetwork", self.PlyNetworkThink )
	end
end

function GTowerStore:AddNetworkItem( ply, ItemId )
	if !table.HasValue( ply._StoreNeedSend, ItemId ) && !table.HasValue( ply._StoreHasSent, ItemId ) then
		table.insert( ply._StoreNeedSend, ItemId )
	end
end

GTowerStore.PlyNetworkThink = function( ply )

	if #ply._StoreNeedSend == 0 then
		return
	end

	local SendItems = {}
	local BitsLeft = 248 * 8

	net.Start("Store")
	net.WriteInt(4,16)

	if DEBUG then
		Msg("Sending packet to: " .. tostring(ply), " (", #ply._StoreNeedSend ,")\n")
	end

	while #ply._StoreNeedSend > 0 do

		local ItemId = ply._StoreNeedSend[1]

		if !ItemId then
			print("WHAT?!")
			break
		end

		local Item = GTowerStore:Get( ItemId )
		local ItemLenght = 16 + 8 + 8

		if BitsLeft - ItemLenght <= 0 then
			break
		end

		BitsLeft = BitsLeft - ItemLenght

		table.remove( ply._StoreNeedSend, 1 )
		table.insert( ply._StoreHasSent, ItemId )

		local Level, MaxLevel = ply:GetLevel( ItemId ), ply:GetMaxLevel( ItemId )

		net.WriteInt( ItemId - 32768, 16 )
		net.WriteInt( Level, 16 )
		net.WriteInt( MaxLevel, 16 )

		/*umsg.Short( ItemId - 32768 )
		umsg.Char( Level )
		umsg.Char( MaxLevel )*/

		if DEBUG then
			Msg( string.format( "\tSending item: %d (%d) - %d %d - Left: %d", ItemId, ItemId - 32768, Level, MaxLevel, BitsLeft ) .. "\n")
		end

	end

	net.Send(ply)

	return #ply._StoreNeedSend > 0

end

hook.Add( "PlayerLevel", "GTowerResendData", function( ply, id, upgradable )
	if upgradable != true then
		return
	end

	table.insert( ply._StoreNeedSend, id )
	GTowerStore:AddPlayerNetwork( ply )

end )
