
GtowerClintClick = {}
GtowerClintClick.MaxDis = 2048

local oldGuiEnable = gui.EnableScreenClicker

IsClickerEnabled = false

function gui.EnableScreenClicker( bool )
	oldGuiEnable( bool )
	IsClickerEnabled = bool
end

function gui.ScreenClickerEnabled()
	return IsClickerEnabled
end

function GetMouseVector()
	return gui.ScreenToVector( gui.MousePos() )
end

function GetMouseAimVector()
	if gui.ScreenClickerEnabled() then
		return GetMouseVector()
	else
		return LocalPlayer():GetAimVector()
	end
end

local function CanMouseEnt()
	return hook.Call("CanMousePress", GAMEMODE ) != false
end

hook.Add("GUIMousePressed", "GtowerMousePressed", function( mc )
	if !CanMouseEnt() then return end

	GtowerMenu:CloseAll()
	if string.StartWith(game.GetMap(),"gmt_minigolf") then return end
	if string.StartWith(game.GetMap(),"gmt_zm") then return end
	local trace = LocalPlayer():GetEyeTrace()

	local cursorvec = GetMouseVector()
	local origin = LocalPlayer():GetShootPos()
	trace = util.TraceLine( { start = origin,
							  endpos = origin + cursorvec * 9000,
							  filter = { LocalPlayer() }
	} )

	if !IsValid(trace.Entity) then return end

	if trace.Entity:IsPlayer() then
		GtowerClintClick:ClickOnPlayer( trace.Entity, mc )
	else
		hook.Call("GtowerMouseEnt", GAMEMODE, trace.Entity )
	end
end )



hook.Add( "KeyPress", "GtowerMousePressedEmpty", function( ply, key )
	if !IsFirstTimePredicted() || key != IN_ATTACK || !CanMouseEnt() || IsValid(LocalPlayer():GetActiveWeapon()) then return end

	if string.StartWith(game.GetMap(),"gmt_minigolf") then return end
	if string.StartWith(game.GetMap(),"gmt_zm") then return end
	
	local trace = LocalPlayer():GetEyeTrace()


	if !IsValid(trace.Entity) || trace.Entity:IsPlayer() then return end

	hook.Call("GtowerMouseEnt", GAMEMODE, trace.Entity )
end )
hook.Add( "GUIMousePressed", "GTowerMousePressed", function( mc )

	if !CanMouseEnt() then return end

	GTowerMenu:CloseAll()
	if string.StartWith(game.GetMap(),"gmt_minigolf") then return end
	if string.StartWith(game.GetMap(),"gmt_zm") then return end

	local trace = LocalPlayer():GetEyeTrace()

	// More precise handling of mouse vector + third person support
	if IsLobby then

		local cursorvec = GetMouseVector()
		local origin = LocalPlayer().CameraPos
		trace = util.TraceLine( {
			start = origin, 
			endpos = origin + cursorvec * 9000,
			filter = { LocalPlayer() }
		} )

	end

	// World click pulls up menu
	if LocalPlayer():IsAdmin() && trace.HitWorld && mc != MOUSE_LEFT then
		GTowerClick:ClickOnPlayer( LocalPlayer(), mc )
		return
	end

	if !IsValid( trace.Entity ) then return end

	// Click on players
	if trace.Entity:IsPlayer() then
		GTowerClick:ClickOnPlayer( trace.Entity, mc )

	// Click on players in a ball
	elseif trace.Entity:GetClass() == "gmt__ballrace" then
		GTowerClick:ClickOnPlayer( trace.Entity:GetOwner(), mc )

	// Inventory items
	else
		hook.Call("GTowerMouseEnt", GAMEMODE, trace.Entity, mc )
	end

end )

hook.Add( "KeyPress", "GTowerMousePressedEmpty", function( ply, key )

	if !IsFirstTimePredicted() || key != IN_ATTACK || !CanMouseEnt() || IsValid(LocalPlayer():GetActiveWeapon()) then return end

	if string.StartWith(game.GetMap(),"gmt_minigolf") then return end
	if string.StartWith(game.GetMap(),"gmt_zm") then return end
	
	local trace = LocalPlayer():GetEyeTrace()

	if IsLobby then
		local cursorvec = GetMouseVector()
		local origin = LocalPlayer().CameraPos
		trace = util.TraceLine( { 
			start = origin, 
			endpos = origin + cursorvec * 9000,
			filter = { LocalPlayer() }
		} )
	end

	if !IsValid(trace.Entity) || trace.Entity:IsPlayer() then return end

	hook.Call("GTowerMouseEnt", GAMEMODE, trace.Entity, mc )

end )

function GtowerClintClick:ClickOnPlayer( ply, mc )

    if !IsValid( ply ) then return end

		local function GetFriendStatus(ply)

			if file.Exists("gmtower/friends.txt", "DATA") then
	    	local Friends = string.Explode(" ", file.Read(LocalFilename, "DATA"))
	    	if table.HasValue(Friends, ply:SteamID64()) then return "Remove friend" else return "Add friend" end
			else
				return "Add friend"
			end
		end

		local function GetFriendCommand(ply)
			if GetFriendStatus(ply) == "Add friend" then
				return "gmt_friend"
			else
				return "gmt_unfriend"
			end
		end

    local tabl = {
        {
            ["type"] = "text",
            ["Name"] = ply:GetName(),
            ["order"] = -10,
            ["closebutton"] = true
        },
				{
					["Name"] = GetFriendStatus(ply),
					["function"] = function() if ply:IsBot() then return end	LocalPlayer():ConCommand( GetFriendCommand(ply).." "..ply:SteamID64() ) end,
					["order"] = 1,
				},
    }

	if CurTime() < ( ply.LastPlyClick or 0 ) then
		hook.Call("PlyDoubleClick", GAMEMODE, ply )
		return
	end
	ply.LastPlyClick = CurTime() + 0.4


	if ply == LocalPlayer() then
		local AdminTable = GTowerAdmin:AddEnts()

		if AdminTable then
			for _, v in pairs( AdminTable ) do
				table.insert( tabl, v )
			end
		end

	else

		local HookTbl = hook.GetTable().ExtraMenuPlayer

		if HookTbl != nil then

		    for _, v in pairs( HookTbl ) do
		        local temp = v( ply )

		        if temp != nil then
		            table.insert( tabl, temp )
		        end
		    end

		end

	end

    if #tabl == 1 then return end //just the Name?!

    GtowerMenu:OpenMenu( tabl )

end
