
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_rabbit.lua")
include('shared.lua')
include('list.lua')
include('admin.lua')

local  hook, table, player, umsg, concommand, math, timer = hook, table, player, umsg, concommand, math, timer
local GTowerSQL = GTowerSQL
local pairs, tonumber, Msg, PrintTable = pairs, tonumber, Msg, PrintTable
local _G = _G


module("GTowerModels")

hook.Add("SQLStartColumns", "SQLForcePlySize", function()
	_G.SQLColumn.Init( {
		["column"] = "plysize",
		["update"] = function( ply ) 
			return ply._ForcePlayerSize or 1.0
		end,
		["onupdate"] = function( ply, val )
			Set( ply, tonumber( val ) )
		end
	} )
end )

function Get( ply )
	return ply._TempPlayerSize or ply._ForcePlayerSize
end

function SendToClients( ply )	
	ply._PlyModelSize = Get( ply ) or 1.0
end

function Set( ply, size )
	
	if hook.Call("PlayerResize", _G.GAMEMODE, ply, size ) == false then
		return 
	end

	size = math.Clamp( size or 0, 0, MaxScale )
	
	if size <= 0.01 || size == 1 then
		ply._ForcePlayerSize = nil	
		ply._TempPlayerSize = nil
	else
		ply._ForcePlayerSize = size
	end
	
	ChangeHull( ply )
	SendToClients( ply )	
end

function SetTemp( ply, size )

	if hook.Call("PlayerResize", _G.GAMEMODE, ply, size ) == false then
		return 
	end
	
	size = math.Clamp( size or 0, 0, MaxScale )
	local OldSize = ply._TempPlayerSize
	
	if size <= 0.01 || size == 1 then
		ply._TempPlayerSize = nil	
	else
		ply._TempPlayerSize = size
	end
	
	if OldSize != ply._TempPlayerSize then
		ply._IginoreChangeSize = true
		timer.Simple( 0.1, function() ply.Spawn( ply ) end)
		timer.Simple( 0.15, function() ply.SetPos( ply:GetPos() ) end)
	end
	
	ChangeHull( ply )
	SendToClients( ply )
	
end

function RemoveTemp( ply )
	if ply._TempPlayerSize then
		ply._TempPlayerSize = nil
		ChangeHull( ply, Get( ply ) )
		SendToClients( ply )
	end
end

hook.Add("PlayerSetModel", "AllowModelOverride", function( ply )

	if ply._PlyModelOverRide then
		local OverRide = ply._PlyModelOverRide
		ply._PlyModelOverRide = nil
		ply:SetModel( OverRide[1] )
		ply:SetSkin( OverRide[2] )
		return true
	end
	
end )
	
hook.Add("PlayerDeath","GTowerChangePlyDeath", RemoveTemp )
hook.Add("PlayerSpawn","GTowerChangePlySpawn", function( ply )
	if !ply._IginoreChangeSize then
		RemoveTemp( ply )
	end
	ply._IginoreChangeSize = nil
	ply:UnDrunk()
end )

concommand.Add("gmt_plysize", function( ply, cmd, args )
	if ply:IsAdmin() then	
		Set( ply, tonumber(args[1]) )
	end
end )

concommand.Add("gmt_plysize2", function( ply, cmd, args )
	if ply:IsAdmin() then	
		SetTemp( ply, tonumber(args[1]) )
	end
end )

hook.Add("AdminCommand", "ChangePlayerSize", function( args, admin, target )
	
	if args[1] == "plysize" then
		Set( target, tonumber(args[3]) )
	elseif args[1] == "plytsize" then
		SetTemp( target, tonumber(args[3]) )
	elseif args[1] == "remsize" then
		Set( target, 1 )
		SetTemp( target, 1 )
	end
	
end )
