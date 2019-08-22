
GTowerLocation = GTowerLocation or {}
GTowerLocation.DEBUG = false

include("maps/gmt_alpha.lua")

if SERVER then
	AddCSLuaFile("maps/gmt_alpha.lua")
end

GTowerLocation.SUITETELEPORTERS = 33

GTowerLocation.Locations = {
	[1] = "Unknown",
	[2] = "Lobby",
	[3] = "Entertainment Plaza",
	[4] = "Suites",
	[5] = "Suites 1-9",
	[6] = "Suites 10-16",
	[7] = "Smoothie Bar",
	[8] = "Lobby Teleporters",
	[9] = "Dev. HQ",
	[10] = "Casino",
	[11] = "Suite #1",
	[12] = "Suite #2",
	[13] = "Suite #3",
	[14] = "Suite #4",
	[15] = "Suite #5",
	[16] = "Suite #6",
	[17] = "Suite #7",
	[18] = "Suite #8",
	[19] = "Suite #9",
	[20] = "Suite #10",
	[21] = "Suite #11",
	[22] = "Suite #12",
	[23] = "Suite #13",
	[24] = "Suite #14",
	[25] = "Suite #15",
	[26] = "Suite #16",
	[27] = "Suite #17",
	[28] = "Suite #18",
	[29] = "Suite #19",
	[30] = "Suite #20",
	[31] = "Hat Store",
	[32] = "Furniture Store",
	[33] = "Suite Teleporters",
	[34] = "Gamemode Teleporters",
	[35] = "Gamemode Ports",
	[36] = "West GM Ports",
	[37] = "East GM Ports",
	[38] = "Arcade",
	[39] = "Bar",
	[40] = "Bar Corner",
	[41] = "Theater",
	[42] = "Theater Hallway",
	[43] = "Lobby Roof",
	[44] = "Electronic Store",
	[45] = "General Goods",
	[46] = "Theater Vents",
	[47] = "Train Station",
	[48] = "Train Stairs",
	[49] = "Suites 17-24",
	[50] = "Moon",
	[51] = "Narnia",
	[58] = "Arcade Hallway",
	[59] = "Food Court",
	[62] = "Building Store",
	[56] = "Pool",
	[57] = "Lakeside",
	[70] = "Suite #21",
	[71] = "Suite #22",
	[72] = "Suite #23",
	[73] = "Suite #24",
	[74] = "Minigolf Port",
	[75] = "Source Karts Port",
	[76] = "PVP Battle Port",
	[77] = "Ball Race Port",
	[78] = "UCH Port",
	[79] = "Gourmet Race Port",
	[80] = "Conquest Port",
	[81] = "Zombie Massacre Port",
	[82] = "Virus Port",
	[83] = "GMT: Adventure Port",
	[84] = "Monotone Port",
	[85] = "Construction Port",
	[86] = "Furniture Store Entrance",
	[87] = "Suites 1-5",
	[88] = "Suites 6-10",
	[89] = "Spawn",
	[90] = "Elevator",
	[91] = "Secret Room",
	[92] = "Dev. HQ",
	[93] = "Abandoned Site",
	[94] = "Haunted Mansion",
	[95] = "Haunted Mansion Entrance",
	[96] = "Cave",
	[97] = "Party Suite",
	[98] = "Lakeside Cabin",
}

function GTowerLocation:IsSuite( id )
	return id >= 11 && id <= 30 or id >= 70 && id <= 73
end

function GTowerLocation:IsTheater( id )
	return id == 41 or id == 50
end

GTowerLocation.TeleportLocations = {
	[8] = {
		["name"] = "Lobby",
		["desc"] = "A place to play and chat.",
		["ents"] = {},
		["failpos"] = Vector(2721.0, -1482.1, 304.4)
	},
	[33] = {
		["name"] = "Suites",
		["desc"] = "Relax and store items.",
		["ents"] = {},
		["failpos"] = Vector(11837.0, 10615.3, 6910.0)
	},
	[34] = {
		["name"] = "Gamemodes",
		["desc"] = "Join the gamemode servers.",
		["ents"] = {},
		["failpos"] = Vector(11848, 10628, 6948 )
	}
}

function GTowerLocation:Add( id, name )

	if type( id ) != "number" then
		Msg("Adding location that is not a number")
		return
	end

	if self.Locations[ id ] then
		Msg("GTowerLocation: ATTENTION: Adding the same location twice for id: " .. id .. " OldName:" .. self.Locations[ id ] .. ", new name: " .. name)
	end

	self.Locations[ id ] = name

end

function GTowerLocation:GetName( id )
	if self.Locations[ id ] == "Suites 10-16"  then
	    return "Suites 10-15"
	elseif self.Locations[ id ] == "Suites 17-24" then
	    return "Suites 16-24"
	end

	if self.Locations[ id ] == "Hat Store" then
		return "Appearance Store"
	end
	return self.Locations[ id ]
end

function GTowerLocation:FindPlacePos( pos )
	local HookTbl = hook.GetTable().FindLocation

	if HookTbl then
		for _, v in pairs( HookTbl ) do

			local b, location = SafeCall( v, pos )

			if b && location then
				return location
			end
		end
	end

	return GTowerLocation:DefaultLocation( pos )
end

function GTowerLocation:GetPlyLocation( ply )
	return (ply.GLocation || 0)
end

function GTowerLocation:InBox( pos, vec1, vec2 )
	return pos.x >= vec1.x && pos.x <= vec2.x &&
		pos.y >= vec1.y && pos.y <= vec2.y &&
		pos.z >= vec1.z && pos.z <= vec2.z
end

local function LocationChanged( ply, var, old, new )
	hook.Call("Location", GAMEMODE, ply, new )
end

function GTowerLocation:GetPlayersInLocation( location )

	if isstring( location ) then

		location = GetName( location )

	end

	local players = {}

	for _, ply in pairs( player.GetAll() ) do
		if not IsValid(ply) then continue end

		-- Same location
		if GTowerLocation:GetPlyLocation( ply ) == location then
			table.insert(players, ply)
			continue
		end
	end

	return players

end

RegisterNWTablePlayer({
	{"GLocation", 0, NWTYPE_CHAR, REPL_EVERYONE, LocationChanged },
})
