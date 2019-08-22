AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

module( "BoneMod", package.seeall )

function SetBoneMod( ply, id )
	net.Start( "BoneMod" )
		net.WriteEntity( ply )
		net.WriteInt( id, 6 )
	net.Broadcast()
end

util.AddNetworkString( "BoneMod" )
