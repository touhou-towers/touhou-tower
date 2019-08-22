
function ENT:MakeList( players, maxspace )
	local playerres, colors = {}, {}

	if #players == 0 then
		return playerres, colors
	end

	local GroupMembers = { LocalPlayer() }

	if GTowerGroup && GTowerGroup:InGroup() then
		GroupMembers = GTowerGroup:GetGroup() //The group does include the local player
	end
	
	local groupnum = 0
	local groupoverflow = {}
	local n = 0

	for k, ply in pairs(players) do
		if IsValid(ply) then
			local ingroup = false
			if table.HasValue(GroupMembers, ply) then
				ingroup = true
			end

			local name = ""
			if ply.Name then
				name = ply:Name()
			end

			if n < maxspace then
				local index = table.insert(playerres, string.format("%d. %s", k, name))
				if ingroup then
					colors[index] = true
				end

				n = n + 1
			elseif ingroup then
				table.insert(groupoverflow, string.format("%d. %s", k, name))
				groupnum = groupnum + 1
			end
		end
	end

	if groupnum > 0 then
		for i=1, groupnum do
			local inv = groupnum - i
			local index = table.insert(playerres, #playerres-inv, groupoverflow[i])
			colors[index] = true
			
			table.remove(playerres)
		end
	end

	return playerres, colors
end