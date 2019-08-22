
/*
local function GtowerHelpButtons( ply , btn )
    umsg.Start("GT", ply)
    umsg.Char( btn )
    umsg.End()
end

hook.Add("ShowHelp", "GTowerHelpButtonsA",   function( ply ) GtowerHelpButtons( ply, 0 ) end ) 
hook.Add("ShowTeam", "GTowerHelpButtonsB",   function( ply ) GtowerHelpButtons( ply, 1 ) end )
hook.Add("ShowSpare1", "GTowerHelpButtonsC", function( ply ) GtowerHelpButtons( ply, 2 ) end )
hook.Add("ShowSpare2", "GTowerHelpButtonsD", function( ply ) GtowerHelpButtons( ply, 3 ) end )
*/

hook.Add("PlayerSpawn", "SendToClient", function( ply )
	--ply:ResetEquipmentAfterVehicle()

	umsg.Start("GT", rp )
		umsg.Char( id )
		umsg.Char( 4 )
	umsg.End() 
	
end )

ClientNetwork = {}
ClientNetwork.Players ={}

function ClientNetwork.AddPacket( ply, Name, func, ... )
	
	if ply == nil then
		for _, v in ipairs( player.GetAll() ) do
			self.AddPacket( v, Name, func, ... )
		end
		return
	end
	
	if ply:IsBot() then
		return
	end

	if !ply._NetworkList then
		ply._NetworkList = {}
	else
		for _, v in pairs( ply._NetworkList ) do
			if v[1] == Name then
				return
			end		
		end	
	end
	
	if !ply._LastNetworkSend then
		ply._LastNetworkSend = 0
	end

	table.insert( ply._NetworkList, { Name, func, { ... } } )
	
	if !table.HasValue( ClientNetwork.Players, ply ) then
		table.insert( ClientNetwork.Players, ply )
	end
	
	hook.Add("Think", "NetworkPlayerSend", ClientNetwork.Think )

end

ClientNetwork.Think = function()

	local Time = CurTime()

	for k, ply in pairs( ClientNetwork.Players ) do
		
		if ply._NetworkList && (!ply._LastNetworkSend || Time > ply._LastNetworkSend) then
		
			local ItemId, Item = next( ply._NetworkList )
			local TimeToAdd = 0.1
			
			if Item then
				
				local b, rtn, addtime = SafeCall( Item[2], ply, unpack( Item[3] ) )
				
				if rtn != true then
					table.remove( ply._NetworkList, ItemId )
				end
				
				if addtime then
					TimeToAdd = addtime
				end
				
			else
				table.remove( ply._NetworkList, ItemId )
			end
			
			if #ply._NetworkList == 0 then
				table.remove( ClientNetwork.Players, k )
			end
			
			ply._LastNetworkSend = Time + TimeToAdd
		
		end
		
	end
	
	if #ClientNetwork.Players == 0 then
		hook.Remove( "Think", "NetworkPlayerSend" )
	end

end

hook.Add("PlayerDisconnected", "CleanClientNetwork", function( ply )

	for k, v in pairs( ClientNetwork.Players ) do
		
		if !IsValid( v ) || v == ply then
			
			ClientNetwork.Players[ k ] = nil
			
		end
		
	end

end )



