

-----------------------------------------------------

function player.GetAdmins()
	local tbl = {}
	local tblAdmins = {}
	local players = player.GetAll()

	for _, ply in pairs( players ) do
		if ply:IsAdmin() then
			table.insert( tblAdmins, ply )
		else
			table.insert( tbl, ply )
		end
	end

	return tblAdmins
end
