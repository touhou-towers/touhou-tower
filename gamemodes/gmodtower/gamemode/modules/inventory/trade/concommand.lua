

concommand.Add("gmt_trade", function( ply, cmd, args )

	if ply._NextTradeRequest && ply._NextTradeRequest > CurTime() then
		return
	end
	
	ply._NextTradeRequest = CurTime() + 0.25
	
	local TargetId = tonumber( args[1] )
	
	if !TargetId then return end
	
	local Target = ents.GetByIndex( TargetId )
	
	if IsValid( Target ) && Target:IsPlayer() && Target != ply then
		ply:InvTrade( Target )
	end

end )

concommand.Add("gmt_tradeitems", function( ply, cmd, args )

	if #args == 0 then
		return
	end
	
	local Money = tonumber( table.remove( args, 1 ) )
	local Items = args
	local Trade = GTowerItems:FindActiveTrade( ply )
	
	if !Trade then
		return
	end
	
	Trade:PlayerOffer( ply, Money, Items )

end )

concommand.Add("gmt_accepttrade", function( ply, cmd, args )
	
	local Trade = GTowerItems:FindActiveTrade( ply )
	
	if !Trade then
		return
	end
	
	Trade:PlayerAccept( ply, tobool( args[1] ) )

end )

concommand.Add("gmt_finishtrade", function( ply, cmd, args )
	
	local Trade = GTowerItems:FindActiveTrade( ply )
	
	if !Trade then
		return
	end
	
	Trade:PlayerFinish( ply, tobool( args[1] ) )

end )

concommand.Add("gmt_closetrade", function( ply, cmd, args )

	local Trade = GTowerItems:FindActiveTrade( ply )
	
	if !Trade then
		return
	end
	
	Trade:EndTrade()
	

end )