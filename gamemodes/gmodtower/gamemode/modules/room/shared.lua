

module("GtowerRooms", package.seeall )

DEBUG = false
StoreId = 1
NPCClassName = "gmt_npc_roomlady"
NPCMaxTalkDistance = 512

LocationTranslation = {
	[1] = 11,
	[2] = 12,
	[3] = 13,
	[4] = 14,
	[5] = 15,
	[6] = 16,
	[7] = 17,
	[8] = 18,
	[9] = 19,
	[10] = 20,
	[11] = 21,
	[12] = 22,
	[13] = 23,
	[14] = 24,
	[15] = 25,
	[16] = 26,
	[17] = 27,
	[18] = 28,
	[19] = 29,
	[20] = 30,
	[21] = 70,
	[22] = 71,
	[23] = 72,
	[24] = 73
}

hook.Add("FindLocation", "GTowerRooms", function( pos )
	local Room = PositionInRoom( pos )

	if !Room then return end

	return LocationTranslation[ Room ]
end)

hook.Add("LoadAchivements","AchiSuite", function ()

	GtowerAchivements:Add( ACHIVEMENTS.SUITEOCD, {
		Name = "OCD",
		Description = "Move any furniture item more than 100 times.",
		Value = 100,
		Group = 3
	})

	GtowerAchivements:Add( ACHIVEMENTS.SUITEPICKUPLINE, {
		Name = "Best Pickup Line",
		Description = "Talk to the suite lady while drunk.",
		Value = 1,
		Group = 3
	})

	GtowerAchivements:Add( ACHIVEMENTS.SUITELADYAFF, {
		Name = "Suite Lady Affixation",
		Description = "Talk to the suite lady more than 250 times.",
		Value = 250,
		Group = 3
	})

	GtowerAchivements:Add( ACHIVEMENTS.SUITEYOUTUBE, {
		Name = "TV Addiction",
		Description = "Watch TV for more than 10 hours.",
		Value = 10 * 60,
		Group = 3,
		GiveItem = "trophy_youtubeaddiction"
	})

	GtowerAchivements:Add( ACHIVEMENTS.SUITELEAVEMEALONE, {
		Name = "Leave Me Alone",
		Description = "Kick more than 15 players out of your suite.",
		Value = 15,
		Group = 3
	})

	GtowerAchivements:Add( ACHIVEMENTS.SUITEPARTY, {
		Name = "Party Animal",
		Description = "Have 4 or more players in your suite for an hour total.",
		Value = 60,
		Group = 3
	})

end )


function PositionInRoom( pos )

	for k, room in pairs( Rooms ) do

		if room.EndPos && room.StartPos then
			if IsVecInRoom( room, pos ) then
				return k
			end
		end

	end

	return nil
end

function IsVecInRoom( roomtable, vec )
	return PosInBox( vec, roomtable.EndPos, roomtable.StartPos )
end

function PosInBox( pos, min, max )
	return pos.x > min.x and pos.y > min.y and pos.z > min.z and
           pos.x < max.x and pos.y < max.y and pos.z < max.z
end

function RecvPlayerRoom(ply, name, old, new)
	if new > 0 then
		ReceiveOwner(ply, new)
	end
end

RegisterNWTablePlayer({ 
	{"GRoomLock", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	{"GRoomId", 0, NWTYPE_CHAR, REPL_EVERYONE, RecvPlayerRoom },
	{"GRoomEntityCount", 999, NWTYPE_NUMBER, REPL_PLAYERONLY },
})
