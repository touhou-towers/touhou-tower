
function ServerMeta:GetGamemode()
	
	local GamemodeName = self:GetGamemodeName()	
	local Gamemode = GTowerServers:GetGamemode( GamemodeName )
	
	if !Gamemode then
		Error("Unknown gamemode " .. GamemodeName)
	end
	
	return Gamemode

end

ServerMeta.Gamemode = ServerMeta.GetGamemode

function ServerMeta:GetGamemodeName()
	return self.GamemodeValue
end

function ServerMeta:GetMap()
	return self.Map
end