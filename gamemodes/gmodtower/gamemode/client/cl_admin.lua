

-----------------------------------------------------
GTowerAdmin = {}

local showEnts = CreateClientConVar( "gmt_admin_showents", 0, true, false )
local showNetInfo = CreateClientConVar( "gmt_admin_shownetinfo", 0, true, false )
local showNetInfo2 = CreateClientConVar( "gmt_admin_shownetinfo2", 0, true, false )
local showMapList = CreateClientConVar( "gmt_admin_showmaplist", 0, true, false )
local showPlayerCount = CreateClientConVar( "gmt_admin_showplaycount", 0, true, false )
local showRenders = CreateClientConVar( "gmt_admin_showrenders", 0, true, false )
local showGhosts = CreateClientConVar( "gmt_admin_playerghosts", 0, true, false )
local ghostAmt = CreateClientConVar( "gmt_admin_playerghosts_amount", 150, true, false )
local esp = CreateClientConVar( "gmt_admin_esp", 0, true, false )

function GTowerAdmin:PlayerCommand( cmd, target, ... )
	RunConsoleCommand( "gt_act", cmd, target:EntIndex(), ... )
end

local function MenuSetMoney( ply )
	Derma_StringRequest( "Set Money",
		"Set the money of: " .. ply:Name(),
		"",
		function( out ) RunConsoleCommand( "gt_act", "money", ply:EntIndex(), out ) end,
		nil,
		"Update",
		"Cancel"
	)
end

local function MenuGiveMoney( ply )
	Derma_StringRequest( "Give Money",
		"Give money to: " .. ply:Name(),
		"",
		function( out ) RunConsoleCommand( "gt_act", "givemoney", ply:EntIndex(), out ) end,
		nil,
		"Give",
		"Cancel"
	)
end

local function MenuWarn( ply )
	Derma_StringRequest( "Warn Player",
		"Send a warning message to: " .. ply:Name(),
		"",
		function( out ) RunConsoleCommand( "gmt_warn", ply:EntIndex(), out ) end,
		nil,
		"Send Warning",
		"Cancel"
	)
end

local function GetNPCTable()

	local Tabl = {}

	for k, v in pairs( scripted_ents.GetSpawnable() ) do

		if v.Base == "gmt_npc_base" || v.IsStore then

			local store = GTowerStore.Stores[v.StoreId]
			local name = v.GetTitle and v:GetTitle() or v.PrintName or v.Title
			if store then
				name = store.WindowTitle
			end

			table.insert( Tabl, {
				["Name"] = name,
				["function"] = function( ply )
					RunConsoleCommand("gmt_create", v.ClassName )
				end,
				["canclose"] = true,
			} )
		end

	end

	return Tabl

end


local function GetEntsTable()

	local Tabl = {}

	// NPCs
	local npcTable = GetNPCTable()
	if #npcTable > 0 then
		table.insert( Tabl, {
			["Name"] = "Stores",
			["canclose"] = true,
			["sub"] = npcTable
		} )
	end
	// Casino
	local casino = {}
	local newyear = {}
	for k, v in pairs( scripted_ents.GetSpawnable() ) do

		if v.ClassName:sub( 1, 11 ) == "gmt_casino_" then
			table.insert( casino, {
				Name = v.GetTitle and v:GetTitle() or v.PrintName,
				["function"] = function( ply )
					RunConsoleCommand("gmt_create", v.ClassName )
				end,
				canclose = true
			} )
		elseif v.ClassName == "gmt_newyearorb" or v.ClassName == "gmt_timer_screen" then
			table.insert( newyear, {
				Name = v.GetTitle and v:GetTitle() or v.PrintName,
				["function"] = function( ply )
					RunConsoleCommand( "gmt_create", v.ClassName )
				end,
				canclose = true
			} )
		end

	end
	table.insert( Tabl, {
		Name = "Casino",
		canclose = true,
		sub = casino
	} )
	table.insert( Tabl, {
		Name = "New Years",
		canclose = true,
		sub = newyear
	} )
	for k, v in pairs( scripted_ents.GetSpawnable() ) do

		if v.Base == "gmt_npc_base" ||
			v.IsStore ||
			v.ClassName:sub( 1, 11 ) == "gmt_casino_" or
			v.ClassName == "gmt_newyearorb"
			or v.ClassName == "gmt_timer_screen" then continue end

		table.insert( Tabl, {
			["Name"] = v.GetTitle and v:GetTitle() or v.PrintName,
			["function"] = function( ply )
				RunConsoleCommand("gmt_create", v.ClassName )
			end,
			["canclose"] = true,
		} )

	end

	return Tabl

end

local function GetLocsTable()

	local tbl = {}
	local suitetbl = {}
	local locations = table.Copy( Location.Locations )

	for id, loc in ipairs( locations ) do
		loc.id = id
	end

	table.sort( locations, function( a, b )
		if not a or not b then return false end
		return a.Name < b.Name
	end )

	for id, loc in pairs( locations ) do

		if string.find( loc.Name, "Suite #" ) then continue end
		if loc.Name == "Unknown" then continue end

		local tbltoadd = tbl

		if string.find( loc.Name, "Suite" ) then
			tbltoadd = suitetbl
		end

		table.insert( tbltoadd, {
			["Name"] = loc.Name,
			["function"] = function( ply )
				RunConsoleCommand("gt_act", "gotoloc", loc.id )
			end,
			["canclose"] = true,
			["order"] = id
		} )

	end

	table.insert( tbl, {
		["Name"] = "Suites...",
		["sub"] = suitetbl,
		["canclose"] = true
	} )

	return tbl

end

function GTowerAdmin:AddEnts()

	if !LocalPlayer():IsAdmin() then return nil end

	local Tabl = {
		{
			["Name"] = "Add Entity...",
			["sub"] = GetEntsTable
		},
		{
			["Name"] = "Remove Entity",
			["function"] = function()
				RunConsoleCommand("gt_act", "rement")
			end
		},
		/*{
			["Name"] = "Godmode",
			["canclose"] = true,
			["function"] = function() RunConsoleCommand("gt_act", "god", LocalPlayer():EntIndex() ) end,
			["checkenabled"] = function() return LocalPlayer().GTGodMode end
		},*/
		{
			["Name"] = "Set Money",
			["canclose"] = true,
			["function"] = function() MenuSetMoney( LocalPlayer() ) end
		},
		{
			["Name"] = "Give Physgun",
			["canclose"] = true,
			["function"] = function() RunConsoleCommand("gt_act", "physgun" ) end
		},
						{
					["Name"] = "Privileges",
					["canclose"] = true,
					["function"] = function() ClientSettings:OpenAdmin( LocalPlayer() ) end,
				},
	}

	--[[if Location then
		local tele =
		{
			["Name"] = "Teleport To...",
			["sub"] = GetLocsTable
		}
		table.insert( Tabl, tele )
	end]]

	local HookTbl = hook.GetTable().GTowerAdminMenus

	if HookTbl then
		for _, v in pairs( HookTbl ) do
			local b, ItemMenu = pcall( v, LocalPlayer() )

			if b then
				table.insert( Tabl, ItemMenu )
			else
				Msg("ERROR: " .. ItemMenu .. "\n")
			end
		end
	end


	return Tabl

end

local function BanPlayer( ply, time )
	if !IsValid( ply ) then return end
	local Name = ply:Name()
	local Steamid = ply:SteamID()

	Derma_StringRequest( "Ban " .. Name,
		"Ban " .. Name,
		"",
		function( reason )
			RunConsoleCommand( "gmt_ban", Steamid, time, reason )
		end,
		nil,
		"Ban " .. Name,
		"Cancel" )

end

local function KickPlayer( ply )

	local Name = ply:Name()

	Derma_StringRequest( "Kick " .. Name,
		"Kick " .. Name,
		"",
		function( reason )
			if IsValid( ply ) then
				RunConsoleCommand( "kickid2", ply:UserID(), reason )
			end
		end,
		nil,
		"Kick " .. Name,
		"Cancel" )

end

hook.Add( "ExtraMenuPlayer", "AddModFunctions", function( ply )

	if LocalPlayer():IsAdmin() then

		local Tabl = {
			["Name"] = "Moderate...",
			["order"] = 0,
			["extra"] = ply:EntIndex(),
			["sub"] = {
				{
					["Name"] = "Kick",
					["function"] = function() KickPlayer( ply ) end,
					["order"] = 1
				},
				{
					["Name"] = "Kick Quick",
					["function"] = function() RunConsoleCommand( "kickid2", ply:UserID(), "Your current action(s) are against our rules." ) end,
					["order"] = 2
				},
				{
					["Name"] = "Ban...",
					["extra"] = ply:SteamID(),
					["order"] = 3,
					["sub"] = {
						{
							["Name"] = "15 Minutes",
							["function"] = function()
								BanPlayer( ply, 900 )
							end,
							["order"] = 1
						},
						{
							["Name"] = "1 Hour",
							["function"] = function()
								BanPlayer( ply, 3600 )
							end,
							["order"] = 2
						},
						{
							["Name"] = "1 Day",
							["function"] = function()
								BanPlayer( ply, 86400 )
							end,
							["order"] = 3
						},
						{
							["Name"] = "2 Days",
							["function"] = function()
								BanPlayer( ply, 86400 * 2 )
							end,
							["order"] = 4
						},
						{
							["Name"] = "3 Days",
							["function"] = function()
								BanPlayer( ply, 86400 * 3 )
							end,
							["order"] = 5
						},
						{
							["Name"] = "1 Week",
							["function"] = function()
								BanPlayer( ply, 86400 * 7 )
							end,
							["order"] = 6
						},
						{
							["Name"] = "1 Month",
							["function"] = function()
								BanPlayer( ply, 2592000 )
							end,
							["order"] = 7
						},
						{
							["Name"] = "4Ever",
							["function"] = function()
								BanPlayer( ply, 0 )
							end,
							["order"] = 8
						}
					},
				},
				{
					["Name"] = "Slay",
					["function"] = function( ply ) RunConsoleCommand("gt_act", "slay", ply ) end,
					["order"] = 4
				},
				{
					["Name"] = "Revive",
					["function"] = function( ply ) RunConsoleCommand("gt_act", "revive", ply ) end,
					["order"] = 5
				},
				{
					["Name"] = "Mute/Unmute",
					["canclose"] = true,
					["function"] = function( ply ) RunConsoleCommand("gt_act", "mute", ply) end,
					["checkenabled"] = function() return ( false ) end,
					["order"] = 6
				},
				{
					["Name"] = "Gag/Ungag",
					["canclose"] = true,
					["function"] = function( ply ) RunConsoleCommand("gt_act", "gag", ply) end,
					["checkenabled"] = function() return ( false ) end,
					["order"] = 7
				},
				{
					["Name"] = "Send Warning",
					["canclose"] = true,
					["function"] = function() MenuWarn( ply ) end,
					["order"] = 8
				},
				{
					["Name"] = "Give Money",
					["canclose"] = true,
					["function"] = function() MenuGiveMoney( ply ) end,
					["order"] = 9
				},
			}
		}

		return Tabl

	end

end )

hook.Add( "ExtraMenuPlayer", "AddAdminFunctions", function( ply )

	if LocalPlayer():IsAdmin() then

		local Tabl = {
			["Name"] = "Admin...",
			["order"] = 0,
			["extra"] = ply:EntIndex(),
			["sub"] = {
				{
					["Name"] = "Send To Lobby",
					["function"] = function( ply ) RunConsoleCommand( "gmt_sendtolobby", ply ) end,
					["order"] = 1
				},
				{
					["Name"] = "Slay",
					["function"] = function( ply ) RunConsoleCommand("gt_act", "slay", ply ) end,
					["order"] = 2
				},
				{
					["Name"] = "Slap...",
					["function"] = function( ply ) RunConsoleCommand("gt_act", "slap", ply, 0 ) end,
					["canclose"] = true,
					["sub"] = function( pl ) // make a function that returns  the table
						local Tbl = {}
						local Dmgs = {0, 5,10,25,50,100}

						for _, v in pairs( Dmgs ) do
							table.insert( Tbl, {
								["Name"] = v .. " Damage",
								["canclose"] = true,
								["function"] = function( ply )
									RunConsoleCommand("gt_act", "slap", ply, v )
								end
							})
						end

						return Tbl
					end,
					["order"] = 3
				},
				{
					["Name"] = "Teleport...",
					["function"] = function( ply ) RunConsoleCommand("gt_act", "goto", ply ) end,
					["canclose"] = true,
					["sub"] =
					{
						{
								["Name"] = "Myself to player",
								["function"] = function( ply )
									RunConsoleCommand("gt_act", "goto", ply )
								end
						},
						{
								["Name"] = "Player to myself",
								["function"] = function( ply )
									RunConsoleCommand("gt_act", "teleport", ply )
								end
						}
					},
					["order"] = 4
				},
				{
					["Name"] = "Privileges",
					["canclose"] = true,
					["function"] = function() ClientSettings:OpenAdmin( ply ) end,
					["order"] = 6
				},
			}
		}

		local AdminHook = hook.GetTable().GTowerAdminPly

		if AdminHook then
			for k, v in pairs( AdminHook ) do

				local b, retn = pcall( v, ply )

				if !b then
					ErrorNoHalt( retn )

				elseif type( retn ) == "table" then
					table.insert( Tabl["sub"], retn )
				end

			end
		end

		return Tabl

	end

end )

local function GetFriendStatus(ply)
	if !IsValid( ply ) then return end

	if file.Exists("gmtower/friends.txt", "DATA") then
		local Friends = string.Explode(" ", file.Read(LocalFilename, "DATA"))
		if table.HasValue(Friends, ply:SteamID64()) then
			return "Unfriend"
		else
			return "Friend"
		end
	else
		return "Friend"
	end
end

local function GetBlockStatus(ply)
	if !IsValid( ply ) then return end

	if file.Exists(BlockList, "DATA") then
		local Blocked = string.Explode(" ", file.Read(BlockList, "DATA"))
		if table.HasValue(Blocked, ply:SteamID64()) then
			return "Unblock"
		else
			return "Block"
		end
	else
		return "Block"
	end
end

hook.Add( "PlayerActionBoxPanel", "AdminActions", function( panel )

	if string.StartWith(game.GetMap(),"gmt_build") then
		local cmd = panel:CreateItem()
	cmd:SetMaterial( Scoreboard.PlayerList.MATERIALS.Trade, 16, 16, 16, 16 )
	cmd:SetText( "Trade" )
	cmd.OnMousePressed = function( self )
		LocalPlayer():ConCommand("gmt_trade" .. " " .. panel:GetPlayer():EntIndex())
	end
	end

	local cmd = panel:CreateItem()
	cmd:SetMaterial( Scoreboard.PlayerList.MATERIALS.Friend, 16, 16, 16, 16 )
	cmd:SetText( "Friend" )	
	if IsValid( panel ) then
		cmd:SetText( GetFriendStatus(panel:GetPlayer()) )
	end
	
	cmd.OnMousePressed = function( self )
		if CheckFriendship(panel:GetPlayer()) then
			LocalPlayer():ConCommand("gmt_unfriend" .. " " .. panel:GetPlayer():SteamID64() )
			cmd:SetText( "Friend" )
		else
			LocalPlayer():ConCommand("gmt_friend" .. " " .. panel:GetPlayer():SteamID64() )
			cmd:SetText( "Unfriend" )
		end
	end

	local cmd = panel:CreateItem()
	cmd:SetMaterial( Scoreboard.PlayerList.MATERIALS.Block, 16, 16, 16, 16 )
	cmd:SetText( "Block" )
	
	if IsValid( panel ) then
		cmd:SetText( GetBlockStatus(panel:GetPlayer()) )
	end
	
	cmd.OnMousePressed = function( self )
		BlockPlayer(panel:GetPlayer())
		cmd:SetText( GetBlockStatus(panel:GetPlayer()) )
	end

	if string.StartWith(game.GetMap(),"gmt_build") then
	local cmd = panel:CreateItem()
	cmd:SetMaterial( Scoreboard.PlayerList.MATERIALS.Group, 16, 16, 16, 16 )
	cmd:SetText( "Group" )
	cmd.OnMousePressed = function( self )
		LocalPlayer():ConCommand("gmt_groupinvite".." "..panel:GetPlayer():EntIndex())
	end
	end

	if !LocalPlayer().IsAdmin || !LocalPlayer():IsAdmin() || !IsLobby then return end

	local cmd = panel:CreateItem()
	cmd:SetMaterial( Scoreboard.PlayerList.MATERIALS.Goto, 16, 16, 16, 16 )
	cmd:SetText( "Goto" )
	cmd.OnMousePressed = function( self )
		RunConsoleCommand("gt_act", "goto", panel:GetPlayer():EntIndex() )
	end

	local cmd = panel:CreateItem()
	cmd:SetMaterial( Scoreboard.PlayerList.MATERIALS.Tele, 16, 16, 16, 16 )
	cmd:SetText( "Bring" )
	cmd.OnMousePressed = function( self )
		RunConsoleCommand("gt_act", "teleport", panel:GetPlayer():EntIndex() )
	end

	local cmd = panel:CreateItem()
	cmd:SetMaterial( Scoreboard.PlayerList.MATERIALS.Gag, 16, 16, 16, 16 )
	cmd:SetText( "Gag" )
	cmd.OnMousePressed = function( self )
		RunConsoleCommand("gt_act", "gag", panel:GetPlayer():EntIndex() )
	end

	local cmd = panel:CreateItem()
	cmd:SetMaterial( Scoreboard.PlayerList.MATERIALS.Mute, 16, 16, 16, 16 )
	cmd:SetText( "Mute" )
	cmd.OnMousePressed = function( self )
		RunConsoleCommand("gt_act", "mute", panel:GetPlayer():EntIndex() )
	end

end )

hook.Add( "HUDPaint", "AdminShowEnts", function()

	if !LocalPlayer().IsAdmin || !LocalPlayer():IsAdmin() || !showEnts:GetBool() then return end

	for _, ent in pairs( ents.GetAll() ) do

		local dist = LocalPlayer():GetPos():Distance( ent:GetPos() )
		if dist > 1024 then continue end

		// Trace
		local tr = util.TraceLine( {
			start = LocalPlayer():EyePos(),
			endpos = ent:GetPos(),
			filter = LocalPlayer()
		} )

		if tr.HitWorld then continue end

		local entpos = ent:GetPos():ToScreen()
		surface.SetFont( "MenuItem" )

		local info = tostring( ent )
		local info2 = ""
		local info3 = ""
		local info4 = ""
		if ent.GetClass then
			info = info .. " " .. ent:GetClass()
		end
		if ent.GetModel && ent:GetModel() then
			info2 = tostring( ent:GetModel() )
		end
		if ent._GTInvSQLId then
			local Item = GTowerItems:Get( ent._GTInvSQLId )
			info3 = tostring( ent._GTInvSQLId ) .. " " .. Item.UniqueName .. " '" .. Item.Name .. "' " .. tostring( Item.Tradable ) .. " $" .. Item.StorePrice
		else
			info3 = tostring( ent:GetPos() ) .. " | " .. tostring( ent:GetAngles() )
		end
		if IsValid( ent:GetOwner() ) then
			info4 = tostring( ent:GetOwner() )
		elseif ent.PlayerName then
			info4 = "Spawned: " .. tostring( ent.PlayerName or "None" ) .. " [" .. ( ent.PlayerSteamID or "None" ) .. "]"
		end

		// Get total width (yes this is gross)
		local tw, th = 0, 0
		local w, h = surface.GetTextSize( info )
		if info != "" then
			tw, th = math.max( tw, w ), th + h
		end
		if info2 != "" then
			w, h = surface.GetTextSize( info2 )
			tw, th = math.max( tw, w ), th + h
		end
		if info3 != "" then
			w, h = surface.GetTextSize( info3 )
			tw, th = math.max( tw, w ), th + h
		end
		if info4 != "" then
			w, h = surface.GetTextSize( info4 )
			tw, th = math.max( tw, w ), th + h
		end

		//surface.SetDrawColor( 0, 0, 0, 250 )
		local color = Color( 0, 0, 0, 225 )
		if ent.PlayerName then color = Color( 0, 0, 150, 225 ) end
		draw.RoundedBox( 8, entpos.x - 5, entpos.y - 5, tw + 10, th + 5, color )
		//surface.DrawRect( entpos.x - 5, entpos.y - 5, 250, 50 )

		local off = 0
		if info != "" then
			surface.SetTextColor( 255, 255, 255 )
			surface.SetTextPos( entpos.x, entpos.y + off )
			surface.DrawText( info )
			off = 10
		end

		if info2 != "" then
			surface.SetTextColor( 150, 255, 255 )
			surface.SetTextPos( entpos.x, entpos.y + off )
			surface.DrawText( info2 )
			off = 20
		end

		if info3 != "" then
			surface.SetTextColor( 150, 255, 150 )
			surface.SetTextPos( entpos.x, entpos.y + off )
			surface.DrawText( info3 )
			off = 30
		end

		if info4 != "" then
			surface.SetTextColor( 255, 150, 150 )
			surface.SetTextPos( entpos.x, entpos.y + off )
			surface.DrawText( info4 )
			off = 40
		end

	end

end )

net.Receive( "EntInfo", function(len)

	local ent = net.ReadEntity()
	ent.PlayerName = net.ReadString()
	ent.PlayerSteamID = net.ReadString()

	Msg2( "Ent Info recieved." )

end )

hook.Add( "HUDPaint", "AdminShowNetInfo", function()

	if !LocalPlayer().IsAdmin || !LocalPlayer():IsAdmin() || !showNetInfo:GetBool() then return end

	// Entity trace
	local trace = LocalPlayer():GetEyeTrace()
	local ent = trace.Entity

	if trace.HitWorld then
		ent = LocalPlayer()
	end

	local off = 15

	if IsValid( ent ) then

		local info = ""

		if ent.GetClass then
			info = info .. tostring( ent:GetClass() ) .. " "
		end
		if ent.GetModel && ent:GetModel() then
			info = info .. tostring( ent:GetModel() ) .. " "
		end
		if IsValid( ent:GetOwner() ) then
			info = info .. tostring( ent:GetOwner() ) .. " "
		end

		surface.SetFont( "ChatFont" )
		local w, h = surface.GetTextSize( info )

		surface.SetDrawColor( 0, 0, 0, 250 )
		surface.DrawRect( 0, 0, w + 5, ScrH() )

		draw.SimpleText( info, "ChatFont", 5, 0, color_white )
		// Location!
		/*if Location then
			draw.SimpleText( tostring( ent:Location() ) .. " " .. Location.GetName( ent:Location() ), "ChatFont", 5, off, color_white )
			off = 30
		end*/

		// Network vars!
		local index = ent:EntIndex()
		local nwtable = NW_ENTITY_DATA[index]
		if nwtable then

			off = off + 15
			draw.SimpleText( "AzuiVars", "ChatFont", 5, off, Color( 255, 100, 100 ) )
			off = off + 15

			for id, item in ipairs( nwtable.__nwtable ) do

				draw.SimpleText( tostring( id ) .. " " .. tostring( item.name ) .. ": " .. tostring( nwtable[item.name] ), "ChatFont", 5, off, color_white )
				/*if Location && item.name == "GLocation" then
					draw.SimpleText( tostring( item.name ) .. ": " .. tostring( ent[item.name] ) .. " | " .. Location.GetName( ent[item.name] ), "ChatFont", 5, off, color_white )
				else*/
				//end

				off = off + 15

			end

		end

		if ent._NetworkVarTable then

			off = off + 15
			draw.SimpleText( "NetworkVars", "ChatFont", 5, off, Color( 100, 255, 100 ) )
			off = off + 15

			table.sort( ent._NetworkVarTable, function( a, b )

				if a.nettype == b.nettype then
					return a.id < b.id
				else
					return string.lower(a.nettype) < string.lower(b.nettype)
				end

			end )

			for id, item in pairs( ent._NetworkVarTable ) do

				draw.SimpleText( tostring( id ) .. " " .. tostring( item.name ) .. " (" .. tostring( item.nettype ) .. "," .. item.id .. ")" .. ": " .. tostring( ent:GetNet(item.name) ), "ChatFont", 5, off, color_white )
				off = off + 15

			end

		end

		// Other stuff!
		if showNetInfo2:GetBool() then

			local height = 150
			local cwidth = 265 * 2
			local xoff = cwidth
			local yoff = height

			local info = ent:GetTable()
			local sortedInfo = {}

			for prop, val in pairs( info ) do
				table.insert( sortedInfo, { prop = prop, val = val } )
			end

			table.sort( sortedInfo, function( a, b )
				return tostring( a.prop ) < tostring( b.prop )
			end )

			for _, val in pairs( sortedInfo ) do

				if type(val.val) == "function" || type(val.val) == "Panel" then continue end
				draw.SimpleText( tostring( val.prop ) .. ": " .. tostring( val.val ), "ChatFont", xoff, yoff, color_white )
				yoff = yoff + 15

				if yoff > 600 then
					yoff = height
					xoff = xoff + cwidth
				end

			end

		end

	end

	// World entity network vars!
	off = off + 15
	draw.SimpleText( "AzuiVars - World", "ChatFont", 5, off, Color( 255, 100, 100 ) )
	off = off + 15

	index = GetWorldEntity():EntIndex()
	nwtable = NW_ENTITY_DATA[index]
	if nwtable then

		for id, item in ipairs( nwtable.__nwtable ) do

			local val = nwtable[item.name]

			-- Handle time/round time
			if string.find( "time", string.lower( item.name ) ) then
				val = tostring( val ) .. " " .. tostring( math.Round( val - CurTime(), 2 ) )
			end

			draw.SimpleText( tostring( id ) .. " " .. tostring( item.name ) .. ": " .. tostring( val ), "ChatFont", 5, off, color_white )
			off = off + 15

		end

	end

end )

hook.Add( "HUDPaint", "AdminShowMapList", function()

	if !LocalPlayer().IsAdmin || !LocalPlayer():IsAdmin() || !showMapList:GetBool() then return end

	// Maps
	local maps = Maps.GetMapsInGamemode( engine.ActiveGamemode() )
	local off = 25

	surface.SetFont( "ChatFont" )
	for _, map in pairs( maps ) do

		local tw, th = surface.GetTextSize( map )

		draw.SimpleText( map, "ChatFont", ScrW() - tw - 15, off, color_white, color_black, TEXT_ALIGN_RIGHT, nil, 1 )
		off = off + 15

	end

end )

hook.Add( "HUDPaint", "AdminShowPlayerCount", function()

	if !LocalPlayer().IsAdmin || !LocalPlayer():IsAdmin() || !showPlayerCount:GetBool() then return end

	draw.SimpleShadowText( #player.GetAll() .. " / " .. game.MaxPlayers(), "ChatFont", ScrW() - 15, 15, color_white, color_black, TEXT_ALIGN_RIGHT, nil, 1 )

end )

hook.Add( "HUDPaint", "AdminESP", function()

	if !LocalPlayer().IsAdmin || !LocalPlayer():IsAdmin() || !esp:GetBool() then return end

	for k, v in ipairs( player.GetAll() ) do

		if IsValid( v ) && v != LocalPlayer() then

			local name = v:GetName()
			local pos = ( v:GetPos() + Vector( 0, 0, 64 ) ):ToScreen()
			local size = 64


			local x, y = pos.x, pos.y

			// Work out sizes.
			local a, b = size / 2, size / 6


			surface.SetDrawColor( 255, 255, 255, 255 )

			// Top left.
			surface.DrawLine(x - a, y - a, x - b, y - a)
			surface.DrawLine(x - a, y - a, x - a, y - b)

			// Bottom right.
			surface.DrawLine(x + a, y + a, x + b, y + a)
			surface.DrawLine(x + a, y + a, x + a, y + b)

			// Top right.
			surface.DrawLine(x + a, y - a, x + b, y - a)
			surface.DrawLine(x + a, y - a, x + a, y - b)

			// Bottom left.
			surface.DrawLine(x - a, y + a, x - b, y + a)
			surface.DrawLine(x - a, y + a, x - a, y + b)

			draw.SimpleText( name, "ChatFont", pos.x, pos.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

	end

end )

hook.Add( "PostDrawTranslucentRenderables", "AdminShowRenders", function()

	if !LocalPlayer().IsAdmin || !LocalPlayer():IsAdmin() then return end

	if !showRenders:GetBool() then return end

	for _, ent in pairs( ents.GetAll() ) do

		if ent == LocalPlayer() then continue end

		local dist = LocalPlayer():GetPos():Distance( ent:GetPos() )
		if dist > 1024 then continue end
		local min, max = ent:GetRenderBounds()
		Debug3D.DrawSolidBox( ent:GetPos(), ent:GetAngles(), min, max, Color( 255, 255, 255, 15 ) )

	end

end )

net.Receive("AdminWarnMessage",function()

	local ply = net.ReadEntity()
	local ply2 = net.ReadEntity()
	local Text = net.ReadString()

	if !ply:IsAdmin() then return end

	if LocalPlayer() != ply2 then return end

	local Message = Msg2(Text)
	Message:SetColor(Color( 255, 50, 50 ))
	Message:SetTargetAlpha(255)
	Message:SetTextColor(Color(0,0,0,255))
	Message:SetIcon("admin")


end)

hook.Add( "PostDrawTranslucentRenderables", "AdminShowGhosts", function()

	if !LocalPlayer().IsAdmin || !LocalPlayer():IsAdmin() || !showGhosts:GetBool() then LocalPlayer()._AdminGhosts = nil return end

	if !LastGhostDelay then
		LastGhostDelay = CurTime() + 1
	end

	if LastGhostDelay < CurTime() then

		LastGhostDelay = CurTime() + .01

		for _, ply in pairs( player.GetAll() ) do

			if !ply._AdminGhosts then
				ply._AdminGhosts = {}
			end

			local size = 2
			local min, max = Vector( -size, -size, -size ), Vector( size, size, size ) // ply:GetRenderBounds()
			local pos = ply:GetPos()
			local angle = ply:GetAngles()

			if ply.GetGolfBall && ply:GetGolfBall() then
				pos = ply:GetGolfBall():GetPos()
			end

			table.insert( ply._AdminGhosts, { min, max, pos, angle } )

			if #ply._AdminGhosts > ghostAmt:GetInt() then
				table.remove( ply._AdminGhosts, 1 )
			end

		end

	end

	for _, ply in pairs( player.GetAll() ) do

		local ghosts = ply._AdminGhosts
		if ghosts then

			for _, ghost in pairs( ghosts ) do

				local min, max, pos, angle = ghost[1], ghost[2], ghost[3], ghost[4]
				local color = ply:GetPlayerColor() * 255
				Debug3D.DrawSolidBox( pos, angle, min, max, Color( color.r, color.g, color.b, 150 ) )

			end

		end

	end

end )
