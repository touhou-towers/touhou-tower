

-----------------------------------------------------
if SERVER then

	util.AddNetworkString( "SprayInfo" )
	util.AddNetworkString( "SprayInfoClear" )

	local PlayerSprays = {}

	local SPRAY_LIFETIME = 60 * 15

	local lastCheck = 0
	local function CheckSprays()
		local curTime = os.time()

		-- only check sprays every so often
		if (curTime - lastCheck) < SPRAY_LIFETIME then return end

		for steamid, spray in pairs( PlayerSprays ) do

			-- Remove expired sprays
			if (curTime - spray.time) > SPRAY_LIFETIME then
				PlayerSprays[steamid] = nil
			end

		end

		lastCheck = curTime
	end

	hook.Add( "PlayerSpray", "SprayTracking", function( ply )

		CheckSprays()

		local trace = ply:GetEyeTrace()
		local steamid = ply:SteamID()

		PlayerSprays[steamid] = {
			pos = trace.HitPos,
			ang = trace.HitNormal,
			name = ply:Name(),
			time = os.time()
		}

		net.Start( "SprayInfo" )
			net.WriteString( steamid )
			net.WriteTable( PlayerSprays[steamid] )
		net.Broadcast()
		--net.Send( Admins.GetAll() )

	end )

	local function SyncSprays()

		CheckSprays()

		for steamid, spray in pairs( PlayerSprays ) do

			net.Start( "SprayInfo" )
				net.WriteString( steamid )
				net.WriteTable( spray )
			net.Broadcast()
			--net.Send( Admins.GetAll() )

		end

	end

	hook.Add( "PlayerInitialSpawn", "SpraySync", function( ply )
		SyncSprays()
	end )

	concommand.Add( "gmt_clearsprays", function( ply )

		if ply:IsAdmin() then
			PlayerSprays = {}
			net.Start( "SprayInfoClear" )
			net.Broadcast()
			--net.Send( Admins.GetAll() )

			ply:Msg2("Cleared spray information.")
		end

	end )

else -- CLIENT

	local showSprays = CreateClientConVar( "gmt_admin_sprays", 0, true, false )
	local ClPlayerSprays = {}

	hook.Add( "HUDPaint", "PaintSprays", function()

		--if not LocalPlayer():IsAdmin() then return end
		--if not showSprays:GetBool() then return end
		--if not GTowerMainGui.MenuEnabled then return end

		if !string.StartWith( game.GetMap() , "gmt_build" ) then
			hook.Remove("HUDPaint","PaintSprays")
			return
		end

		for steamid, spray in pairs( ClPlayerSprays ) do

			local pos = ( spray.pos ):ToScreen()
			local distance = ( spray.pos - LocalPlayer():GetShootPos() ):Length()
			local alpha = math.Clamp( 300 - distance, 0, 1 )
			local text = spray.name .. "'s Spray (" .. steamid .. ")"

			surface.SetFont( "TabLarge" )
			local tw, th = surface.GetTextSize( text )

			draw.RoundedBox( 3, pos.x - 5 - (tw/2), pos.y - 3, tw + 10, th + 5, Color( 0, 0, 0, alpha * 150 ) )
			draw.DrawText( text, "TabLarge", pos.x, pos.y, Color( 255, 255, 255, alpha * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

	end )

	net.Receive( "SprayInfo", function( len, ply )

		local steamid = net.ReadString()
		local spray = net.ReadTable()

		if steamid and spray then
			ClPlayerSprays[steamid] = spray
		end

	end )

	net.Receive( "SprayInfoClear", function( len, ply )
		ClPlayerSprays = {}
	end )

end
