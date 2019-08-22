
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("helper.lua")

AddCSLuaFile("anti_script_hook/cl_scripthookpwnd.lua")
AddCSLuaFile("client/messages.lua")
AddCSLuaFile("client/network.lua")
AddCSLuaFile("client/menu.lua")
AddCSLuaFile("client/alltalk.lua")
AddCSLuaFile("client/helper.lua")
AddCSLuaFile("client/clientmenu.lua")
AddCSLuaFile("client/sidemenu.lua")
AddCSLuaFile("client/hud_hide.lua")
AddCSLuaFile("client/cl_admin.lua")
AddCSLuaFile("client/cl_selection.lua")
AddCSLuaFile("client/cl_admin_usermessage.lua")
AddCSLuaFile("client/cl_dbug_profiler.lua")
AddCSLuaFile("client/dmodel.lua")
AddCSLuaFile("client/cl_question.lua")
AddCSLuaFile("client/clientmenu_action.lua")
AddCSLuaFile("client/cl_resizer.lua")
AddCSLuaFile("sh_extensions.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_spray.lua")


AddCSLuaFile( "translation/shared.lua" )
AddCSLuaFile( "postprocess/init.lua" )
AddCSLuaFile( "cl_debug.lua" )
AddCSLuaFile( "cl_playermenu.lua" )

AddCSLuaFile( "modules/modules.lua" )

include("network_queue.lua")
AddCSLuaFile("network_queue.lua")

//Obligatory at first

include("anti_script_hook/sv_scripthookpwnd.lua")

include("debug/init.lua")
include("nwvar/nwvars.lua")
include("sh_extensions.lua")

//Nornal loads
include("shared.lua")
include("helper.lua")
include("sh_player.lua")
include("sh_spray.lua")

include( "translation/init.lua" )
include("enchant/init.lua")

include("server/mysql.lua")
include("server/basicsql.lua")

include("server/player.lua")
include("icons/init.lua")
include("server/betatester.lua")
include("server/network.lua")
include("gtrivia/init.lua")
include("clientsettings/init.lua")
include("postprocess/init.lua")
include( "modules/modules.lua" )
include("chat/init.lua")
include("store/init.lua")
include("server/question.lua")
include("server/admin.lua")
include("server/loadsql.lua")
include("server/admin/noclip.lua")
include("server/admin/god.lua")
include("server/admin/teleport.lua")
include("server/admin/entityreset.lua")
include("server/admin/decal.lua")
include("server/entitydump.lua")
include("server/admin/rement.lua")
include("multiserver/init.lua")
include("inventory/init.lua")
include("models/init.lua")
include("mapchange.lua")
include("server/alltalk.lua")


include("server/rocket.lua")
include("bit/bit.lua")
include("bit/hex.lua")

AddCSLuaFile( 'theater/cl_init.lua' )
AddCSLuaFile( 'theater/init.lua' )

include( 'theater/cl_init.lua' )
include( 'theater/init.lua' )

MultiUsers = {}

function GTowerAddEmotes( list )
  for k,v in pairs( list ) do
    resource.AddWorkshop( v )
  end
end

IncludeList = {
-- content
"1781208310", -- accessories
"1781210042", -- ballrace
"1781211876", -- base
"1781260422", -- halloween
"1781214610", -- lobby
"1781215856", -- lobby 2
"1781219797", -- maps
"1781221477", -- maps 2
"1781224138", -- minigolf
"1781224870", -- new
"1781227298", -- oldpack
"1781229190", -- player models
"1781232401", -- pvp
"1781233910", -- rave
"1781235454", -- seasonal
"1781237108", -- sound
"1781241780", -- source karts
"1781243032", -- summer lobby
"1781244940", -- uch
"1781246466", -- virus
"1781248258", -- zombie massacre
"1827365908", -- gourmet
--[[ backup content
"1791831578", -- accessories
"1791837196", -- ballrace
"1791856107", -- base
"1791861245", -- halloween
"1791866522", -- lobby
"1791871956", -- lobby 2
"1791875365", -- maps
"1791882028", -- maps 2
"1791893853", -- minigolf
"1792115204", -- new
"1792124049", -- oldpack
"1792212147", -- player models
"1792214863", -- pvp













--]]
-- media player
"546392647",
-- IrZipher's Ballrace Maps
"975414181",
-- playable piano
"104548572",
--zoephixs mapchange
"1799400497",
}

GTowerAddEmotes( IncludeList )

-- Modules
for k,v in pairs (file.Find("gmodtower/gamemode/oboy/*.lua","LUA")) do
	AddCSLuaFile("gmodtower/gamemode/oboy/" .. v);
end

-- Derma
for k,v in pairs (file.Find("gmodtower/gamemode/derma/*.lua","LUA")) do
	AddCSLuaFile("gmodtower/gamemode/derma/" .. v);
end

/*require("luaerror")

hook.Add("LuaError", "LE", function(err)
	SQLLog('error', err)
end)*/

local aumsg = umsg.Start
local bumsg = umsg.End
local s = false
local LastTraceBack = ""
local startedumsg = ""

umsg.Start = function(a, b)

	if s == true then
		bumsg()
		SQLLog('error',"Umsg started without ending! (" .. startedumsg .. ") ORIGINAL TRACEBACK: " .. LastTraceBack .. "\n END ORIGINAL TRACEBACK.\n\n")
	end

	startedumsg = a
	LastTraceBack = debug.traceback()

	aumsg(a, b)
	s = true
end


umsg.End = function()
	bumsg()
	startedumsg = ""
	s = false
end

// 1 second tick player think, this should be pretty efficient
timer.Create( "GTowerPlayerThink", 1.0, 0, function()

	for _, v in ipairs( player.GetAll() ) do
		if IsValid(v) then
			hook.Call("PlayerThink", GAMEMODE, v)
		end
	end

end)




hook.Add("InitPostEntity", "AddTempBot", function()

	if GetConVarNumber("sv_voiceenable") != 1 then
		RunConsoleCommand("sv_voiceenable","1")
	end

	if string.StartWith(game.GetMap(),"gmt_build") then

--[[
		local board = ents.Create( "gmt_board" )

		// Aniversary
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(936, -647, 336) )
		board:SetAngles(Angle(0,90,0))
		board:SetSkin(6)
		board:Spawn()
--]]
		local board = ents.Create( "gmt_board" )

		// TU 1
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(439,-3714,-214) )
		board:SetAngles(Angle(0,0,0))
		board:SetSkin(1)
		board:Spawn()

		local board = ents.Create( "gmt_board" )

		// TU 2
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(1417, -3770, -212) )
		board:SetAngles(Angle(0,0,0))
		board:SetSkin(1)
		board:Spawn()

		local board = ents.Create( "gmt_board" )

		// Rules
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(929, -3327, -92) )
		board:SetAngles(Angle(0,0,0))
		board:SetSkin(4)
		board:Spawn()

		local board = ents.Create( "gmt_board" )

		// Lobby pool 1
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(1416, -3581, -213) )
		board:SetAngles(Angle(0,0,0))
		board:SetSkin(3)
		board:Spawn()

		local board = ents.Create( "gmt_halloween2014_connection" )
		// Halloween Connection
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(-420, -1000, 32) )
		board:SetAngles(Angle(0,-90,0))
		board:Spawn()
		local board = ents.Create( "gmt_board" )

		// Lobby pool 2
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(438, -3582, -213) )
		board:SetAngles(Angle(0,0,0))
		board:SetSkin(2)
		board:Spawn()

		local board = ents.Create( "gmt_skymsg" )
		// Monotone SkyMsg
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(11330,9290,6915) )
		board.KVText = "Monotone"
		board:Spawn()

		local board = ents.Create( "gmt_jukebox" )

		// Casino Jukebox
		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(2327, 374, 192) )
		board:SetAngles(Angle(0,90,0))
		board:Spawn()

		local board = ents.Create( "gmt_board" )

		if ( !IsValid( board ) ) then return end
		board:SetPos( Vector(930.15,-3314.44, -134.82) )
		board:Spawn()
	end
	if game.SinglePlayer() then return end

	// Needed for multiservers to initialize, don't remove m8.
	RunConsoleCommand("bot")

	timer.Simple( 1.0, function()
		for _, v in pairs( player.GetAll() ) do
			if v:IsBot() then
				v:Kick("A bot")
			end
		end
	end )

	SQLLog('start', "Server start - ", game.GetMap() )

end )

hook.Add("CanPlayerUnfreeze", "GMTOnPhysgunReload", function(ply, ent, physObj)
		return ply:GetSetting( "GTAllowPhysGun" )
end)

function GM:Initialize()
    --SetIfDefault( "sv_loadingurl", LOADING_URL ) Let's force it instead
		RunConsoleCommand( "sv_loadingurl", "http://gmodtower.org/loading/?mapname=%m&steamid=%s" )
end

function GM:CheckPassword(steam, IP, sv_pass, cl_pass, name)

	if engine.ActiveGamemode() == "gmodtowerlobby" || engine.ActiveGamemode() == "intothechaos" then return end

	steam = util.SteamIDFrom64(steam)

	local PortRemove = string.find(IP,"%:")

	if PortRemove != nil then IP = string.sub( IP, 1, PortRemove - 1 ) end

	--PrintTable(MultiUsers)
	--print("IP:"..tostring(IP))

	if table.HasValue(GTowerAdmins,steam) or table.HasValue(GTowerSecretAdmin,steam) or MultiUsers[IP] then
		return true
	else
		MsgC(Color(51, 204, 51),name.." <"..steam.."> ("..IP..") tried to join the server.\n")
		return false, "Please join gamemodes from the Lobby server. (gmodtower.org:27015)"
	end

	return true
end

function GetMaxSlots()

	local Slots = GetConVarNumber("sv_visiblemaxplayers")

	if Slots <= 1 then //If MaxSlots is not set, just adjust it to the true maxplayers
		return game.MaxPlayers() --MaxPlayers()
	end

	return Slots

end

// use GetHostName()
timer.Remove( "HostNameThink" )
//Garrys function is no longer aprecicated
//Handled in server/admin.lua
hook.Remove( "PlayerInitialSpawn", "PlayerAuthSpawn")

local function CanUseFuckingModel(ply,model,skin)
	if !ply.SQL then
		ply._ReloadPlayerModel = true
		return
	end

	local Model = GTowerItems.ModelItems[ model .. "-" .. (skin or "none") ]

	if Model && ply:HasItemById( Model.MysqlId ) then
		return true
	end
end

function GM:PlayerSetModel( ply )

	if ( !IsValid(ply) || ply:IsBot() ) then return end

	local model, skin = GTowerModels.GetModelName( ply:GetInfo( "cl_playermodel" ) )

	local allow = CanUseFuckingModel( ply, model, skin )

	if allow == nil then
		timer.Simple(2,function()
			self:PlayerSetModel(ply)
			return
		end)
	end

	if !model || allow != true then
		model, skin = "none", 0
	end

	local modelName = player_manager.TranslatePlayerModel( model )
	util.PrecacheModel( modelName )
	ply:SetModel( modelName )
	ply:SetSkin( skin )

	local list = ply:GetEquipedItems()
	SpawnPlayerUCH(ply, list)

	hook.Call("PlayerSetModelPost", GAMEMODE, ply, model, skin )
end

function GM:AllowModel( ply, model )
	return GTowerModels.AdminModels[ model ] == nil || ply:IsAdmin()
end
