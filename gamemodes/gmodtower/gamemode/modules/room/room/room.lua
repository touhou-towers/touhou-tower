
local setmetatable = setmetatable
local getfenv = getfenv
local CurTime = CurTime
local _G = _G
local table = table
local CurTime = CurTime
local hook = hook
local ipairs = ipairs
local SQLLog = SQLLog
local tostring = tostring
local math = math

include("entity.lua")
include("sql.lua")
include("reset.lua")
include("load.lua")

module( "Suite" )

local modenv = getfenv()

function New( pos1, pos2, refent )

	if !refent || !refent:IsValid() then
		Error("Loading room with invalid refent!")
	end

	_G.OrderVectors( pos1, pos2 )

	local o = setmetatable( {
		Id = Id,
		Owner = nil,
		RefEnt = refent,
		StartPos = pos2,
		EndPos = pos1,
		Middle = (pos1 + pos2) / 2,
		LastActive = CurTime(),
		ToAdd = {},
		StartEnts = {}
	}, { __index = modenv } )

	o.Id = table.insert( _G.GtowerRooms.Rooms, o )
	o.LocationId = _G.GtowerRooms.LocationTranslation[ o.Id ]

	refent:SetId( o.Id )
	o:SaveDefault()

	return o

end

function IsValid( self )
	return self.Owner && self.Owner:IsValid()
end

function CanRent( self )
	return !self:IsValid()
end

function SetLock( self, state )
	if self.Owner then
		self.Owner.GRoomLock = state
	end
end

function Lock( self )
	self:SetLock( true )
end

function Unlock( self )
	self:SetLock( false )
end

function CanManageDoor( self, ply )
	return self.Owner && (self.Owner.GRoomLock == false || ply == self.Owner || ply:IsAdmin() )
end

function Location( self )
	return _G.GtowerRooms.LocationTranslation[ self.Id ]
end

local function CheckPlayer( ply, room, group, owner )

	if room:CanManageDoor( ply ) then return end

	if group && group:HasPlayer( ply ) then return end

	if ply:GetSetting( "GTNoClip" ) || ply:IsAdmin() then return end

	ply:Msg2( "You have been removed from a locked suite." )
	if math.random( 1, 3 ) == 1 then
		ply:Msg2( "If you purposely glitch into suites you will be banned!" )
	end

	room.RemovePlayer( ply )

	local Name = ply:Name()
	local steamid = ply:SteamID()


	local ownerName = owner:Name()
	local ownerSteam = owner:SteamID()

	SQLLog( 'suiteglitch', tostring( Name ) .. " (" .. tostring( steamid ) .. ") has been removed from " .. tostring( ownerName ) .. " (" .. tostring( ownerSteam ) .. " )'s suite." )

end
hook.Add( "RoomThink", "GRoomThink", function( ply )

	local room = ply:GetRoom()

	if !room then return end

	if !room.Owner.GRoomLock then return end // so far we're only thinking for locked rooms

	local players = room:GetPlayers()
	local group = ply:GetGroup()

	for _, v in ipairs( players ) do

		CheckPlayer( v, room, group, ply )

	end

end )
