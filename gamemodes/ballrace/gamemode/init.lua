AddCSLuaFile("cl_choose.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_message.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("draw_extras.lua")
AddCSLuaFile("globals.lua")
AddCSLuaFile("hooks.lua")
AddCSLuaFile("setup.lua")
AddCSLuaFile("sh_mapnames.lua")
AddCSLuaFile("sh_payout.lua")
AddCSLuaFile("sh_player.lua")

include("globals.lua")
include("setup.lua")
include("round.lua")
include("sh_payout.lua")

-- the following files are not cleaned up
include("player.lua")
include("sh_player.lua")

-- not sure what this is for
-- seems to identify a ball race server chat
-- but it doesnt line up with the one in sql
-- and it wont be good for multiple ball race
-- servers from what i can tell
CreateConVar("gmt_srvid", 4)

concommand.Add("gmt_requestballupdate",function(ply)
	net.Start( 'GtBall' )
		net.WriteInt( 0, 2 )
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerCube") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerIcosahedron") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerCatBall") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerBomb") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerGeo") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerSoccerBall") == 1)
		net.WriteBool(GTowerStore:GetPlyLevel(ply,"BallRacerSpikedd") == 1)
	net.Send( ply )
end)

timer.Create("AchiBallerRoll", 60.0, 0, function()
	for _, v in pairs(player.GetAll()) do
		if v:AchivementLoaded() then
			v:AddAchivement( ACHIVEMENTS.BRBALLERROLL, 1 )
		end
	end
end)

util.AddNetworkString("roundmessage")
util.AddNetworkString("BGM")
util.AddNetworkString("br_electrify")
util.AddNetworkString("pick_ball")
util.AddNetworkString("GtBall")