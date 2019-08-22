
local pairs = pairs
local pcall = pcall
local ipairs = ipairs
local SQLLog = SQLLog
local GTowerItems = GTowerItems
local ents = ents
local SafeCall = SafeCall
local GtowerRooms = GtowerRooms
local player = player
local table = table
local type = type
local tostring = tostring
local IsValid = IsValid
local _G = _G
local print = print
local string = string

module("Suite")

function InventorySave( self, ent )

	local InvItem = GTowerItems:FindByEntity( ent )

	if !InvItem then
		return
	end

	local Pos = self.RefEnt:WorldToLocal( ent:GetPos() )
	local Ang = self.RefEnt:WorldToLocalAngles( ent:GetAngles() )

	return {
		["InvItem"] = InvItem,
		["pos"] = Pos,
		["ang"] = Ang
	}

end

function PlayRadio( self, ply, music )

	local Ents = self:EntsInRoom()
	local ListOfRadios = {}
	local LowestEnt = nil

	for _, ent in pairs( Ents ) do

		if ent.RadioPriority then

			if !LowestEnt || LowestEnt.RadioPriority < ent.RadioPriority  then
				LowestEnt = ent
			end

			table.insert( ListOfRadios, ent )

		end

	end

	if LowestEnt != nil then

		/*if string.sub(music, -4) == ".mp3" then
			if music == "Lady%20GaGa%20-%20Poker%20Face.mp3" then
				ply:AddAchivement( ACHIVEMENTS.SUITEPOKERFACE, 1 )
			end
		end*/

		LowestEnt:LoadSong( music )

		for _, ent in pairs( ListOfRadios ) do
			if ent != LowestEnt then
				ent:SetOwner( LowestEnt )
			end
		end

		return true
	end

end

function CallOnEnts( self, funcName, ... )

	for _, v in ipairs( self:EntsInRoom() ) do

		if v[ funcName ] && type( v[ funcName ] ) == "function" then

			local b, rtn = SafeCall( v[ funcName ], v, ... )

			if b && rtn != nil then
				return rtn
			end

		end

	end

end

function HookEntCreate( self )

	if !table.HasValue( GtowerRooms.AddingEntsRooms, self ) then
		table.insert( GtowerRooms.AddingEntsRooms, self )
	end

end

function EntCreateThink( self )

	if table.Count( self.ToAdd ) <= 0 then

		for k, v in ipairs( GtowerRooms.AddingEntsRooms ) do
			if v == self then
				table.remove( GtowerRooms.AddingEntsRooms, k )
			end
		end

		return

	end

	local Tbl = table.remove( self.ToAdd )
	local Item = GTowerItems:CreateById( Tbl.InvItem, "room"  )

	if !Item then
		SQLLog('error',"ATTENTION: " .. tostring(Tbl.InvItem) .. " was not able to be created\n")
		return
	end

	local DropEnt = Item:OnDrop()
	local VarType = type( DropEnt )

	if VarType == "Entity" || VarType == "Weapon" then //Returned a entity to be set

		DropEnt:SetPos( Tbl.pos )
		DropEnt:SetAngles( Tbl.ang )
		DropEnt._GTInvSQLId = Item.MysqlId

		DropEnt:Spawn()

		if DropEnt.LoadRoom && type( DropEnt.LoadRoom ) == "function" then
			DropEnt:LoadRoom( self.Owner )
		end

		local phys = DropEnt:GetPhysicsObject()

		if IsValid( phys ) then
			phys:EnableMotion( Item.EnablePhyiscs )
		end

	else
		SQLLog('sqldebug', "WARNING! ROOM: DROPPED ENT AND OnDrop DID NOT RETURN AN ENTITY!\n")
	end

end


function EntsInRoom( self )
	return ents.FindInBox( self.StartPos, self.EndPos )
end

function GetPlayers( self )

	local List = {}

	for _, ply in pairs( player.GetAll() ) do

		if self:PlayerInRoom( ply ) then
			table.insert( List, ply )
		end

	end

	return List

end

function PlayerInRoom( self, ply )
	--return ply:Location() == self.LocationId
	return GTowerLocation:FindPlacePos(ply:GetPos()) == self.LocationId
end

function OwnerInRoom( self )
	return GTowerLocation:FindPlacePos(self.Owner:GetPos()) == self.LocationId
end

function EntCount( self )
	return #self:EntsInRoom()
end

function ActualEntCount( self )
	local Ents = self:EntsInRoom()
	local Count = 0

	for _, ent in ipairs( Ents ) do
		if GTowerItems:FindByEntity( ent ) then
			Count = Count + 1
		end
	end

	return Count

end
