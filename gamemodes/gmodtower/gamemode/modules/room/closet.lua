


function GtowerRooms:SendHatLevels( ply )
	
	for k, v in ipairs( GTowerHats.Hats ) do
		if v.unique_Name then
			local level = ply:GetLevel( v.id )
			umsg.Bool( level > 0 )
		end
	end
	
end

concommand.Add("gmt_closethat", function( ply, cmd, args )

	if #args != 1 then
		return
	end

	local Room = ply:GetRoom()
	
	if Room && Room:OwnerInRoom() then
		GTowerHats:SetHat( ply, args[1] )
	end

end )