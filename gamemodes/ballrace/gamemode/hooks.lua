--[[
    this file adds hooks
]]
hook.Add("DisableAdminCommand", "BallraceNoAdmin", function(cmd)
	if cmd == "addent" || cmd == "rement" || cmd == "physgun" then return true end
end)

hook.Add("GTAfk","BRAFK", function(afk, ply)
	afks[ply] = afk
end)

hook.Add("PlayerDisconnected", "NoPlayerCheck", function(ply)
	if ply:IsBot() then return end
	
	-- on empty server, end it
	timer.Simple(5, function()
		if player.GetCount() == 0 then GAMEMODE:EndServer() end
	end)
end)

hook.Add("PlayerInitialSpawn", "PlayerSetup", function(ply)
    ply:SetModel('models/player/kleiner.mdl')

	timer.Simple(2.5,function()
		music.Play(1, MUSIC_LEVEL, ply)
	end)
end)

hook.Add("AFKNotFull", "GamemodeNotFull", function()
    -- not sure about always returning true but its
    -- what was used before i touched the code
    return true
end)

hook.Add("PlayerSpawn", "whee", function(ply)
	ply:SetNoDraw(true)
	hook.Call("PlayerSetModel", GAMEMODE, ply )
end)

hook.Add( "AntiTranqEnable", "GamemodeAntiTranq", function()
    return false
end) 

hook.Add("GTowerMsg", "GamemodeMessage", function()
	if player.GetCount() < 1 then
		return "#nogame"
	else
		local added = LEVEL_COUNT + 1
		if LateSpawn != nil && (LateSpawn:GetName() == 'bonus_start' || LateSpawn:GetName() == 'bns_start' || LateSpawn:GetName() == 'bonus') then
			return "-1/" .. added
		else
			return tostring(math.Clamp(level, 1, added)) .. "/" .. added
		end
	end
end 