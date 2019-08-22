
local _G = _G
local pairs = pairs
local type = type
local table = table
local IsValid = IsValid
local CurTime = CurTime
local hook = hook
local SafeCall = SafeCall
local GTowerItems = GTowerItems

module("Suite")

function RemovePlayer( ply )

	if !IsValid(ply) then return end

	if ply:InVehicle() then //Do not let player be teleported in a seat!
		ply:ExitVehicle()
	end

	//Reset him, and go back to spawn point
	local teleporters = {}
	
	for k,v in pairs(ents.FindByClass("gmt_teleporter")) do
		if ( GTowerLocation:FindPlacePos( v:GetPos() ) ) == 33 then table.insert( teleporters, v ) end
	end
	
	local tp = table.Random( teleporters )
	
	if IsValid(ply.BallRaceBall) then ply.BallRaceBall:SetPos(tp:GetPos() + Vector(0,0,5) + (tp:GetForward()*25)) end
	if IsValid(ply.GolfBall) then ply.GolfBall:SetPos(tp:GetPos() + Vector(0,0,5) + (tp:GetForward()*25)) end
	
	ply.DesiredPosition = (tp:GetPos() + Vector(0,0,5) + (tp:GetForward()*25))
	ply:ResetEquipmentAfterVehicle()

end

function SaveDefault( self )

	for _, ent in pairs ( self:EntsInRoom() ) do

		local SaveData = self:InventorySave( ent )

		if SaveData then
			table.insert( self.StartEnts, SaveData )
		end

	end

end

function LoadDefault( self )

	local AlreadySpawned = {}
	self.Owner._RoomSaveData = {}

	for _, v in pairs( _G.GtowerRooms.DefaultItems ) do

		for k, v1 in pairs( self.StartEnts ) do

			if v1.InvItem == _G.ITEMS[ v ] and not table.HasValue( AlreadySpawned, k ) then

				table.insert( AlreadySpawned, k )
				table.insert( self.Owner._RoomSaveData, v1 )

			end

		end

	end

end

function Cleanup( self )

    for _, v in pairs ( self:EntsInRoom() ) do
		if v:IsPlayer() && v:Alive() then
			RemovePlayer( v )

        elseif GTowerItems:FindByEntity( v ) then
 
            v:Remove()

        end

		if type( v.RoomUnload ) == "function" then
			SafeCall( v.RoomUnload, v, RoomId )
		end
    end

	self.ToAdd = {}

	if IsValid( self.Owner ) then
		self.Owner.GRoom = nil
		--for k,v in pairs(player.GetAll()) do v:SendLua([[ents.GetByIndex( ]]..self.Owner:EntIndex()..[[.GRoomId = 0)]]) end
		self.Owner.GRoomId = 0
    end

    self.Owner = nil
	self.LastActive = CurTime()

	hook.Call("RoomUnLoaded", GAMEMODE, self )

end

function Load( self, ply )

	self:Cleanup()

	self.Owner = ply
	self.LoadedTime = CurTime()
	self.SafeToSave = false
	ply.GRoom = self
	ply.GRoomId = self.Id
	--for k,v in pairs(player.GetAll()) do v:SendLua([[ents.GetByIndex( ]]..self.Owner:EntIndex()..[[.GRoomId = ]]..self.Id..[[)]]) end

	if ply._RoomSaveData == nil then
		self:LoadDefault()
	end

	for _, v in pairs( ply._RoomSaveData ) do

		local Pos = self.RefEnt:LocalToWorld( v.pos )
		local Ang = self.RefEnt:LocalToWorldAngles( v.ang )

		table.insert( self.ToAdd,  {
			["pos"] = Pos,
			["ang"] = Ang,
			["InvItem"] = v.InvItem
		} )

	end

	self:HookEntCreate()

	hook.Call("RoomLoaded", GAMEMODE, ply, self )

	self:CallOnEnts( 'OnRoomLoaded', ply )
	self:CallOnEnts( 'CheckLevel', ply )

end

function Finish( self )

	self.Owner._LastRoomExit = CurTime()

	self.Owner:SetNWBool("Party",false)

	if self.Owner.SQL then
		self.Owner.SQL:Update( false, true )
	end

	self:Cleanup()

end
