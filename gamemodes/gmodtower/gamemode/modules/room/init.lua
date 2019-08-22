
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile("shared.lua")
AddCSLuaFile("room_maps.lua")
AddCSLuaFile("cl_closet.lua")

module("GtowerRooms", package.seeall )

include("shared.lua")
include("sql.lua")
include("room_maps.lua")
include("concommand.lua")
include("hook.lua")
include("closet.lua")
include("network.lua")
include("player.lua")
include("room/room.lua")

Rooms = {}
AddingEntsRooms = {}

//The items that will be added in the default room
//Any item can be put more than once
DefaultItems = {
	//"tablecoffe",
	//"potted_plant1",
	//"microwave",
	--"radio",
	"chair1", //"chair1",
	//"suiteshelf",
	"barstool", //"barstool",
	//"suitespeaker", "suitespeaker",
	//"suitecouch",
	//"suitetable",
	//"remotecontrol",
	"tvcabinet",
	"tv",
	//"potted_plant2",
	//"deskchair",
	//"gmtdesk",
	//"computer_display",
	//"computer",
	//"cabitnetdarw",
	//"plant1",
	//"sofachair",
	"trunk",
	"bed",
	//"sidetable",
	//"suitelamp"
}

function Get( id )
	return Rooms[ id ]
end

function GetOwner( id )

	if !id then return end
	local Room = Get( id )

	if Room then
		return Room.Owner
	end

end

function OpenStore( ply )
	GTowerStore:OpenStore( ply, StoreId )
end

function ClosestRoom( vec )

	local Shortest = nil
    local GoRoom = nil

	for k, v in pairs( Rooms ) do

		local VecDistance = vec:Distance( v.Middle )

        if Shortest == nil || Shortest > VecDistance then

			Shortest = VecDistance
			GoRoom = k

		end

	end

	return GoRoom

end

util.AddNetworkString("gmt_senddoortexts")

hook.Add("InitPostEntity", "RoomsAddOtherEnts", function()

	timer.Create("CheckDoorNames",1,0,function()
		local names = {}
		for k,v in pairs(player.GetAll()) do
			local curname = v:GetInfo("gmt_suitename")
			if string.len( curname ) > 50 then
				names[v] = string.sub(curname,1,50)
			else
				names[v] = curname
			end
		end
		net.Start("gmt_senddoortexts")
		net.WriteTable(names)
		net.Broadcast()
	end)

	local function OrderEntities( entlist )

		local EntMidPoint = Vector(0,0,0)
		local EntAngle = {}

		for _, v in pairs( entlist ) do
			EntMidPoint = EntMidPoint + v:GetPos()
		end

		EntMidPoint = EntMidPoint / #entlist

		for k, v in pairs( entlist ) do
			local AngDif = ( v:GetPos() - EntMidPoint ):Angle()

			EntAngle[ v ] = AngDif.y

			if EntAngle[ v ] < 0 then
				EntAngle[ v ] = EntAngle[ v ] + 360
			end

		end

		table.sort( entlist, function(a,b)
			return EntAngle[a] > EntAngle[b]
		end )

	end

	local MapTbl = {
        ["refobj"] = "gmt_roomloc",
        ["min"] = Vector(-32, -600, -33.1250),
        ["max"] = Vector(336, 715, 246.8750),
        ["closethats"] = {
            [1] = { Vector(246, 704, 248.5), Vector(220, 535, 204.5) },
            [2] = { Vector(246, 704, 203.5), Vector(220, 535, 180.5) },
            [3] = { Vector(246, 704, 179.5), Vector(220, 535, 156.5) }
        }
    }

	if MapTbl then

		local EntList = ents.FindByClass( "gmt_roomloc" )

		OrderVectors( MapTbl.min, MapTbl.max )

		OrderEntities( EntList )

		for _, v in pairs( EntList ) do
			SafeCall( Suite.New, v:LocalToWorld( MapTbl.min ), v:LocalToWorld( MapTbl.max ), v )
		end

		if #EntList == 0 then
			Msg("ROOM: Could not find suites for entity: " .. MapTbl.refobj .. "\n")
		end

	end

end )

function VecInRoom( vec )

	for _, v in pairs( Rooms ) do
		if IsVecInRoom( v, vec ) then
			return v
		end
	end

end

function SendEntIDs( ply )

	umsg.Start("GRoom", ply)

		umsg.Char( 14 )

		local MaxIndex = table.maxn(GtowerRooms.Rooms)

		umsg.Char( MaxIndex )

		for i=1, MaxIndex do
			umsg.Short( Get( i ).RefEnt:EntIndex() )
		end

	umsg.End()

end

hook.Add("InvUniqueItem", "CheckInRoom", function( ply, id )

	local Room = ply:GetRoom()

	if Room then
		Room:UpdateRoomSaveData()
	end

	if ply._RoomSaveData then

		for _, v in pairs( ply._RoomSaveData ) do
			if v.InvItem == id then
				return true
			end
		end

	end

end )

/*hook.Add("PlayerCanHearPlayersVoice", "GMTRoomTalk", function(listener, talker)
	local group = talker:GetGroup() --Maybe i should add some check if groups module turned on?
	if group then return end

	local Room = Get(ClosestRoom( listener:GetPos() ))

	if !Room then
		return
	end

	if GTowerLocation:FindPlacePos(listener:GetPos()) == nil or GTowerLocation:FindPlacePos(talker:GetPos()) == nil or Room.Owner == nil then return end
	if GTowerLocation:FindPlacePos(listener:GetPos()) == GTowerLocation:FindPlacePos(talker:GetPos()) and Location.IsSuite(GTowerLocation:FindPlacePos(listener:GetPos())) and Room.Owner:GetSetting( 20 ) then
		return true
	end
end)*/

// 0.25 seconds for room precision, PlayerThink's 1 second is too slow for protecting suites
timer.Create( "GTowerRoomThink", 1, 0, function()
	for _, v in ipairs( player.GetAll() ) do
		if IsValid( v ) then
			hook.Call( "RoomThink", GAMEMODE, v )
		end
	end
end)

timer.Create( "AchiSuiteParty", 60.0, 0, function()
	for _, v in pairs( player.GetAll() ) do
		if !v:AchivementLoaded() then return end

		local Room = v:GetRoom()

		if Room then
			local Players = Room:GetPlayers()

			if #Players >= 5 then
				v:AddAchivement(  ACHIVEMENTS.SUITEPARTY, 1 )
			end
		end
	end
end )
