util.AddNetworkString("JoinFriendCheck")

GTowerAdmins = {
}

GTowerVIPS = {
}

-- this is used for multiserver bypassing now, for testing gamemodes
GTowerAdminPrivileged = {
}

GTowerSecretAdmin = {
}

GtowerAdmin = {}

function IsAdmin(steamid)
	return (GTowerAdmins and table.HasValue(GTowerAdmins, steamid))
		or (GTowerAdminPrivileged and table.HasValue(GTowerAdminPrivileged, steamid))
			or (GTowerSecretAdmin and table.HasValue(GTowerSecretAdmin, steamid))
end

concommand.Add("gmt_create",function(ply,cmd,args,str)
	if !ply:IsAdmin() then return end

	if !util.IsValidModel(args[1]) then
		local ent = ents.Create(args[1])
		ent:SetPos(ply:GetEyeTrace().HitPos)
		ent:Spawn()
	end

	local ent = ents.Create("prop_physics_multiplayer")

	ent:SetPos(ply:GetEyeTrace().HitPos)
	ent:SetModel(args[1])
	ent:Spawn()

end)

concommand.Add( "gt_act", function(ply, command, args)
    if !ply:IsAdmin() then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 5, command, args )
		end
		return
	end

    if #args < 1 then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 1, command, args )
		end
		return
	end

	if args[1] == "addent" && !hook.Call("DisableAdminCommand", GAMEMODE, args[1]) && ply:IsSuperAdmin() then

		local EntName = args[2]
		local EntTable = scripted_ents.GetList()[ EntName ]

		if !EntTable then
			return
		end

		if EntTable.t.SpawnFunction then
			local DropEnt = EntTable.t:SpawnFunction( ply, ply:GetEyeTrace() )

			if ( !DropEnd ) then return end

			if DropEnt.LoadRoom && type( DropEnt.LoadRoom ) == "function" then
				DropEnt:LoadRoom()
			end
		end

		return

	elseif args[1] == "rement" && !hook.Call("DisableAdminCommand", GAMEMODE, args[1]) then
		local Ent = ply:GetEyeTrace().Entity

		if IsValid( Ent ) && !Ent:IsPlayer() && Ent:GetClass() != "func_brush" then
			Ent:Remove()
		end

		return

	elseif args[1] == "physgun" && !hook.Call("DisableAdminCommand", GAMEMODE, args[1]) then

		if !ply:HasWeapon("weapon_physgun") then
			ply:Give("weapon_physgun")
		end

		return

	end

	if #args < 2 then
		return
	end


	//Player based answers
    local TargetPly = Entity( tonumber( args[2] ) )

    if TargetPly == nil then return end
    if !TargetPly:IsPlayer() then return end

    if args[1] == "slay" && !hook.Call("DisableAdminCommand", GAMEMODE, args[1]) then

        TargetPly:Kill()

		elseif args[1] == "givemoney" then

				player.GetByID(args[2]):AddMoney(tonumber(args[3]))

				if ply != TargetPly then
				net.Start("AdminMessage")
				net.WriteEntity(nil)
				net.WriteString(ply:Name().." gave you "..tonumber(args[3]).." GMC")
				net.Send(player.GetByID(args[2]))
				end

		elseif args[1] == "gag" then

				local SanitizedName = SafeChatName(player.GetByID(args[2]):Name())
				ply:Msg2( SanitizedName .. " is now gagged for this session")
				player.GetByID(args[2]):SetNWBool("GlobalGag",true)

				for k,v in pairs(player.GetAll()) do
					local SanitizedName2 = SafeChatName( ply:Name() )
					v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedName2..[[ has gagged ]]..SanitizedName..[[.", Color(150, 35, 35, 255))]])
				end

		elseif args[1] == "mute" then

			local SanitizedName = SafeChatName(player.GetByID(args[2]):Name())
			ply:Msg2(SanitizedName .. " is now muted for this session")
			player.GetByID(args[2]):SetNWBool("GlobalMute",true)

			for k,v in pairs(player.GetAll()) do
				local SanitizedName2 = SafeChatName( ply:Name() )
				v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedName2..[[ has muted ]]..SanitizedName..[[.", Color(150, 35, 35, 255))]])
			end

		elseif args[1] == "revive" then

				local RevPly = player.GetByID(args[2])

				RevPly:UnSpectate()

				local pos = RevPly:GetPos()
				local ang = RevPly:EyeAngles()

				RevPly:Spawn()

				RevPly:SetPos( pos )
				RevPly:SetEyeAngles( ang )

    elseif args[1] == "slap" && !hook.Call("DisableAdminCommand", GAMEMODE, args[1]) then

		TargetPly:TakeDamage( tonumber(args[3] or 5), ply, ply )

		if TargetPly:Alive() then
			 TargetPly:SetVelocity( VectorRand() * 2048 )
		end

	elseif args[1] == "money" && args[3] then

		local Amount = tonumber( args[3] )
		if Amount == nil then Amount = 0 end

		TargetPly:SetMoney( Amount )

		ply:Msg2( "You set \"" .. TargetPly:Name() .. "\"'s money to " .. Amount .. "." )

		if ply != TargetPly then
				net.Start("AdminMessage")
				net.WriteEntity(nil)
				net.WriteString(T("AdminSetMoney", ply:GetName(), Amount))
				net.Send(TargetPly)
		end

    end 

	hook.Call("AdminCommand", GAMEMODE, args, ply, TargetPly )

end )

hook.Add("PlayerDisconnected","LeaveMessage",function(ply)

	if ply.HasResetData then
		for k,v in pairs(player.GetAll()) do
			local SanitizedName = SafeChatName(ply:Name())
			v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedName..[[ has reset his data and left the tower.", Color(100, 100, 100, 255))]])
		end
		return
	end

	for k,v in pairs(player.GetAll()) do
		local SanitizedName = SafeChatName(ply:Name())
		v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedName..[[ has left the tower.", Color(100, 100, 100, 255))]])
	end
end)

hook.Add("PlayerInitialSpawn", "GTowerCheckAdmin", function(ply)
	for k, v in pairs(player.GetAll()) do
		if v == ply then continue end
		local SanitizedName = SafeChatName(ply:Name())
		v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedName..[[ is now in the tower.", Color(65, 115, 200, 255))]])
	end

	if table.HasValue(GTowerAdmins, ply:SteamID()) || game.SinglePlayer() then
		ply:SetUserGroup( "superadmin" )
	elseif table.HasValue(GTowerAdminPrivileged, ply:SteamID()) then
		ply:SetUserGroup( "privadmin" )
	elseif table.HasValue( GTowerSecretAdmin, ply:SteamID()) then
		ply:SetUserGroup( "superadmin" )
		ply:SetNWBool( "SecretAdmin", true )
	elseif table.HasValue( GTowerVIPS, ply:SteamID()) then
		ply:SetNWBool( "VIP", true )
	end

	timer.Simple(0.5,function()
		net.Start("JoinFriendCheck")
		net.WriteEntity(ply)
		net.Broadcast()
	end)
	
	if ply:IsBot() then return end
	
	local apikey = "FA416F9756E30676884A145BD9A9158B"
    local steamid = ply:SteamID64()

	http.Fetch( "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key="..apikey.."&steamid="..steamid.."&format=json",
	function(body)
		ply.glist = util.JSONToTable(body)
		if ply.glist.response.games then
			for k,v in pairs(ply.glist.response.games) do
				if v.appid == 394690 then
					ply:SetNWBool("VIP",true)
				end
			end
		end
	end,
	function(error)
		ErrorNoHalt(error)
	end
	)

end )

function GetAdminRP()

	local rp = RecipientFilter()

	for _, ply in ipairs( player.GetAll() ) do
		if ply:IsAdmin() then rp:AddPlayer( ply ) end
	end

	return rp

end

-- Increasing security, maybe someday it will be safe to bring these back

concommand.Add("gmt_runlua", function( ply, cmd, args )
	if ply:IsAdmin() then
		local Lua = table.concat( args, " ")
		RunString("function GmtRunLua() " .. Lua .. " end ")
		local B, retrn = SafeCall( GmtRunLua )
	end

end )


concommand.Add("gmt_svrunlua", function( ply, cmd, args )
	if ply:IsAdmin() then
		local Lua = table.concat( args, " ")
		RunString("function GmtRunLua() " .. Lua .. " end ")
		local B, retrn = SafeCall( GmtRunLua )
		if type( retrn ) == "table" then
			retrn = table.ToNiceString( retrn )
		end
		ply:Msg2( tostring(retrn) )
	end
end )

concommand.Add("gmt_sendlua", function( ply, cmd, args )
	if ply:IsAdmin() then
		BroadcastLua( table.concat( args, " ")  )
	end
end )

concommand.Add("gmt_cvar", function( ply, cmd, args )
	if ply:IsAdmin() then

		local Cvar = args[1]

		if args[2] then
			RunConsoleCommand(Cvar , args[2] )
		else
			ply:Msg2( Cvar .. " = " .. GetConVarString( Cvar ) )
		end

	end

end )

concommand.Add( "gmt_warn", function( ply, cmd, args )
	if !ply:IsAdmin() then return end

	net.Start("AdminWarnMessage")
	net.WriteEntity(ply)
	net.WriteEntity(player.GetByID(args[1]))
	net.WriteString(args[2])
	net.Broadcast()

end)

util.AddNetworkString("AdminWarnMessage")