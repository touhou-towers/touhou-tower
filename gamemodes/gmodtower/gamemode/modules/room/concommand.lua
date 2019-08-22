
util.AddNetworkString("gmt_partymessage")

module("GtowerRooms", package.seeall )

TimeToLeaveRoom = 6 * 60
TalkingTo = {}


timer.Create( "CheckPlayerOnRoom", 1.0, 0, function()

	for k, Room in pairs( Rooms ) do

		if Room:IsValid() then

			if Room:OwnerInRoom() then
				Room.LastActive = CurTime()

			elseif CurTime() - Room.LastActive > TimeToLeaveRoom then

				umsg.Start("GRoom", Room.Owner)
			    umsg.Char( 5 )
			    umsg.Char( TimeToLeaveRoom / 60 )
			    umsg.End()

				Room:Finish()
			end

		end

	end

end )


function OnlyInYourRoom( ply )

	umsg.Start("GRoom", ply)
    umsg.Char( 8 )
    umsg.End()

end

function NowAllowedSuite( ply )

	umsg.Start("GRoom", ply)
    umsg.Char( 12 )
    umsg.End()

end

function ShowRentWindow( ent, ply )

	if ClientSettings && ClientSettings:Get( ply, "GTAllowSuite" ) == false then
		NowAllowedSuite( ply )
		return
	end

	if ply._LastRoomExit && CurTime() - ply._LastRoomExit < 3 then
		return
	end

	TalkingTo[ ply ] = ent

	local Answer = -1

	//Does he have a room?
	if ply:GetRoom() != nil then
		Answer = -1

	else

		Answer = 0

		//Get how many rooms are avalible
		for k, v in pairs( Rooms ) do
			if v:CanRent() then
				Answer = Answer + 1
			end
		end

	end

	umsg.Start("GRoom", ply)
    umsg.Char( 2 )
    umsg.Char( Answer )
    umsg.End()

	if ply.BAL > 0 then
		ply:SetAchivement( ACHIVEMENTS.SUITEPICKUPLINE, 1 )
	end

	ply:AddAchivement( ACHIVEMENTS.SUITELADYAFF, 1 )

end

local Settings = {
	[1] = "Drinks",
	[2] = "Movies",
	[3] = "Music",
	[4] = "Games",
	[5] = "TV Shows",
	[6] = "A Piano",
}

function StartParty( ply, flags )
	if not IsValid(ply) then return end
	
	if !flags then return end
	
	if ply:GetNWBool("Party") then return end
	
	if !ply.NextParty then ply.NextParty = 0 end
	
	if CurTime() < ply.NextParty then
		ply:Msg2("You cannot throw another party for 1 minute.")
		return
	end
	
	local flags = string.Explode( ",", flags )
	PrintTable(flags)

	local amount = 0
	
	for k,v in pairs(flags) do
		if v == "1" then amount = amount + 1 end
	end

	local invString = ply:Name() .. " is throwing a Party in Suite #" .. tostring(ply.GRoomId) .. "!"
	
	if amount != 0 then
		invString = invString .. " There will be " 
		local num = 0
		for k,v in pairs(flags) do
			if v == "0" then continue end
			num = num + 1
			
			if amount == 1 then
				invString = invString .. Settings[k] .. "!"
			elseif num == amount then
				invString = invString .. "and " .. Settings[k] .. "!"
			elseif num == amount - 1 then
				invString = invString .. Settings[k] .. " "
			else
				invString = invString .. Settings[k] .. ", "
			end
			
		end
	end
	
	local roomid = ply.GRoomId
	
	if roomid == 0 then return end
	
	if !ply:Afford( 250 ) then
		ply:Msg2("You cannot afford to start a party!")
		return
	end
	
	ply:AddMoney(-250)
	
	ply:SetNWBool("Party",true)
	
	ply.NextParty = CurTime() + (60*3)
	
	timer.Simple( 60*2, function() 
		if IsValid(ply) && ply:GetNWBool("Party") then
			ply:SetNWBool("Party",false)
			ply:Msg2("Your suite party has ended.")
		end
	end)
	
	net.Start("gmt_partymessage")
		net.WriteString(invString)
		net.WriteString(tostring(roomid))
	net.Broadcast()
	
end

concommand.Add("gmt_startroomparty", function( ply, cmd, args )
	StartParty(ply,args[1])
end)

concommand.Add("gmt_endroomparty", function( ply, cmd, args )
	ply:SetNWBool("Party",false)
	ply:Msg2("You have ended your suite party.")
end)


SuitePanelPos = {

  Vector(4732.000000, -11127.599609, 4152.009766),
  Vector(4732.000000, -11511.599609, 4152.009766),
  Vector(4732.000000, -11895.599609, 4152.009766),
  Vector(4732.000000, -12279.599609, 4152.009766),
  Vector(4496.000000, -12507.599609, 4152.009766),
  Vector(4356.000000, -12071.599609, 4152.009766),
  Vector(4356.000000, -11687.599609, 4152.009766),
  Vector(4356.000000, -11303.599609, 4152.009766),
  Vector(4356.000000, -10919.599609, 4152.009766),
  Vector(2703.600098, -10364.000000, 4152.009766),
  Vector(2319.600098, -10364.000000, 4152.009766),
  Vector(1935.599976, -10364.000000, 4152.009766),
  Vector(2080.399902, -9987.990234, 4152.009766),
  Vector(2464.399902, -9987.990234, 4152.009766),
  Vector(2848.399902, -9987.990234, 4152.009766),
  Vector(4356.000000, -9223.629883, 4152.009766),
  Vector(4356.000000, -8839.629883, 4152.009766),
  Vector(4356.000000, -8455.629883, 4152.009766),
  Vector(4356.000000, -8071.629883, 4152.009766),
  Vector(4592.000000, -7855.629883, 4152.009766),
  Vector(4732.000000, -8279.629883, 4152.009766),
  Vector(4732.000000, -8663.629883, 4152.009766),
  Vector(4732.000000, -9047.629883, 4152.009766),
  Vector(4732.000000, -9431.629883, 4152.009766)

}

concommand.Add("gmt_joinparty", function(ply, cmd, args)
	if !args[1] then return end
	
	for k,v in pairs(ents.FindByClass('func_suitepanel')) do
		if !table.HasValue(SuitePanelPos,v:GetPos()) then continue end
		if v.RoomId == tonumber(args[1]) then
			ply.DesiredPosition = ( v:GetPos() + v:GetRight() * -75 + v:GetForward() * 50 )
		end
	end
	
end)

concommand.Add("gmt_roomkick", function( ply, cmd, args )

	if ply._NextCommand && ply._NextCommand > CurTime() then
		return
	end
	ply._NextCommand = CurTime() + 0.25

	local Room = ply:GetRoom()

	if Room then

		local Players = Room:GetPlayers()

		for _, ply in pairs( Players ) do
			if ply != Room.Owner && !ply:IsAdmin() then
				Suite.RemovePlayer( ply )
				Room.Owner:AddAchivement( ACHIVEMENTS.SUITELEAVEMEALONE, 1 )
			end
		end

	end

end )

concommand.Add( "gmt_dieroom", function( ply, cmd, args )

	if !IsValid( TalkingTo[ ply ] ) then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 7, cmd, args )
		end
		return
	end

	if ply.NextDieRoom && CurTime() < ply.NextDieRoom then
		return
	end
	ply.NextDieRoom = CurTime() + 5

	if TalkingTo[ ply ]:GetPos():Distance( ply:GetPos() ) > NPCMaxTalkDistance then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 8, cmd, args )
		end
		return
	end

	local Room = ply:GetRoom()

	if Room then
		Room:Finish()
	end


end )

concommand.Add( "gmt_acceptroom", function( ply, cmd, args )

	if !IsValid( TalkingTo[ ply ] ) then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 7, cmd, args )
		end
		return
	end

	if TalkingTo[ ply ]:GetPos():Distance( ply:GetPos() ) > NPCMaxTalkDistance then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 8, cmd, args )
		end
		return
	end

	if ply.NextNewRoom && CurTime() < ply.NextNewRoom then
		return
	end
	ply.NextNewRoom = CurTime() + 5

	//Already have a room?
	if ply:GetRoom() then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 10, cmd, args )
		end
		return
	end

	//Get all unused rooms
	local UnusedRooms = {}
	for k, v in pairs( Rooms ) do
		if v:CanRent() then
			table.insert(UnusedRooms, v )
		end
	end

	//If there are no rooms avalible
	if #UnusedRooms < 1 then
		umsg.Start("GRoom", ply)
		    umsg.Char( 3 )
		umsg.End()
		return
	end

	//Make random numbers a little less predictable
	math.randomseed( CurTime() )

	//Select a random one
	local PlyRoom = UnusedRooms[ math.random( 1, #UnusedRooms ) ]

	if !tmysql then
		PlyRoom:Load( ply )

		umsg.Start("GRoom", ply)
		umsg.Char( 4 )
		umsg.Char( PlyRoom.Id )
		umsg.End()
		return
	end
if string.StartWith(game.GetMap(),"gmt_build0s2b") or string.StartWith(game.GetMap(),"gmt_0c3") then
	SQL.getDB():Query("SELECT HEX(roomdata) as roomdata FROM `gm_users` WHERE steamid='"..ply:SteamID().."'", function(res)

			if !res or res == nil then return end
			local row = res[1].data[1]
			if row then
					local roomdata = row.roomdata
					Suite.SQLLoadData( ply, roomdata )
					PlyRoom:Load( ply )

					umsg.Start("GRoom", ply)
					umsg.Char( 4 )
					umsg.Char( PlyRoom.Id )
					umsg.End()

					ply.GRoomEntityCount = PlyRoom:ActualEntCount()

			end

	end)
elseif string.StartWith(game.GetMap(),"gmt_build0h") or string.StartWith(game.GetMap(),"gmt_002a") then
	SQL.getDB():Query("SELECT HEX(romdata) as romdata FROM `gm_users` WHERE steamid='"..ply:SteamID().."'", function(res)

			if !res or res == nil then return end
			local row = res[1].data[1]
			if row then
					local romdata = row.romdata
					Suite.SQLLoadData( ply, romdata )
					PlyRoom:Load( ply )

					umsg.Start("GRoom", ply)
					umsg.Char( 4 )
					umsg.Char( PlyRoom.Id )
					umsg.End()

					ply.GRoomEntityCount = PlyRoom:ActualEntCount()

			end

	end)
else
	SQL.getDB():Query("SELECT HEX(rumdata) as rumdata FROM `gm_users` WHERE steamid='"..ply:SteamID().."'", function(res)

			if !res or res == nil then return end
			local row = res[1].data[1]
			if row then
					local rumdata = row.rumdata
					Suite.SQLLoadData( ply, rumdata )
					PlyRoom:Load( ply )

					umsg.Start("GRoom", ply)
					umsg.Char( 4 )
					umsg.Char( PlyRoom.Id )
					umsg.End()

					ply.GRoomEntityCount = PlyRoom:ActualEntCount()

			end

	end)
end
	//Congratilaions!


end )


hook.Add("ClientSetting", "GTCheckSuite", function( ply, id, val )

	if ClientSettings:GetName( id ) == "GTAllowSuite" then
		TalkingTo[ ply ] = nil

		local Room = ply:GetRoom()

		if val == false && Room  then
			Room:Finish()
		end

	end

end )


concommand.Add("gmt_roomdebugpos", function( ply, cmd, args )

	local Room = ply:GetLocationRoom()

	if Room then

		print( Room.RefEnt:WorldToLocal( ply:GetPos() ) )
		print( Room.RefEnt:WorldToLocalAngles( ply:GetAngles() ) )

	end

end )
