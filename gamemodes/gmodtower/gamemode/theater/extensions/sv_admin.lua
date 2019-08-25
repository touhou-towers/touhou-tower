local SuperAdmins = {}

local Admins = {}

hook.Add(
	"PlayerInitialSpawn",
	"AuthAdmin",
	function(ply)
		if table.HasValue(SuperAdmins, ply:SteamID()) then
			ply:SetUserGroup("superadmin")
		end

		if table.HasValue(Admins, ply:SteamID()) then
			ply:SetUserGroup("admin")
		end
	end
)

concommand.Add(
	"cinema_runlua",
	function(ply, cmd, args)
		if not ply:IsSuperAdmin() then
			return
		end

		local lua = table.concat(args, " ")

		RunString("function CinemaRunLua() end") -- clear out the last function, incase the new code is invalid
		RunString("function CinemaRunLua() " .. lua .. " end ")

		status, err = pcall(CinemaRunLua)

		if not status then
			ply:PrintMessage(HUD_PRINTCONSOLE, "Lua error: " .. err .. "\n")
		end
	end
)

concommand.Add(
	"cinema_rcon",
	function(ply, cmd, args)
		if not ply:IsSuperAdmin() then
			return
		end

		if #args == 0 then
			ply:PrintMessage(HUD_PRINTCONSOLE, "No commands specified.\n")
			return
		end

		local cmd = args[1]
		local args = table.concat(args, " ", 2)

		RunConsoleCommand(cmd, args)
	end
)

concommand.Add(
	"cinema_changelevel",
	function(ply, cmd, args)
		if ply == NULL or ply:IsSuperAdmin() then
			local map = args[1]

			if map == nil then
				map = game.GetMap()
			elseif type(map) ~= "string" then
				return
			end

			local MapName = string.lower(tostring(map))
			local FilePlace = "../maps/" .. string.Trim(MapName) .. ".bsp"

			ply:PrintMessage(HUD_PRINTCONSOLE, "Starting process to change map to: " .. MapName .. "\n")

			if file.Exists(FilePlace, "GAME") == false then
				ply:PrintMessage(HUD_PRINTCONSOLE, "Map " .. MapName .. " does not exist!\n")
				return
			end

			for k, v in ipairs(player.GetAll()) do
				v:ChatPrint("Changing level to " .. MapName)
			end

			-- Finally, change level!
			timer.Simple(
				2,
				function()
					RunConsoleCommand("changelevel", MapName)
				end
			)
		end
	end
)
