
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

-- Let's get started
function ENT:Initialize()

	-- Set Model
	self:SetModel( "models/func_touchpanel/terminal04.mdl" )

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:DrawShadow( false )

	self.Think = self.LookingRoomThink
	//self:SharedInit()

	self:SetUseType(SIMPLE_USE)
end

function ENT:LookingRoomThink()

	if !GtowerRooms then
		return
	end

	local NewRoomId =  GtowerRooms.ClosestRoom( self:GetPos() )

	if NewRoomId then
		self:SetId( NewRoomId )

		self.Think = EmptyFunction

		if GtowerRooms.DEBUG then Msg("Found room for: " .. tostring( self ) .. " to roomID: " .. tostring( self:Id() ) .. "\n") end
	end

	self:NextThink( CurTime() + 1.0 )

	return true
end

function ENT:Use( ply )
	local cur_x, cur_y = self:MakeEyeTrace( ply )
	self:UsePanel( ply, cur_x, cur_y )
end

function ENT:SetId( id )
	self.RoomId = id
	self:SetSkin( self.RoomId )
end

function ENT:Id()
	return self.RoomId
end


function ENT:DoorFire(str, ti)
	for k,v in pairs(ents.FindInSphere( self.Entity:GetPos(), 75 )) do
        if v:GetClass() == "func_door_rotating" then
            v:Fire(str, "", ti)

						if ( str == "Lock" ) then
							v:Fire("close","")
							for _,ply in pairs(player.GetAll()) do
								if GtowerRooms.GetOwner(self:Id()) != ply and !ply:IsAdmin() and GTowerLocation:FindPlacePos(ply:GetPos()) == GTowerLocation:FindPlacePos(GtowerRooms.Get( self:Id() ).RefEnt:GetPos()) then
									Suite.RemovePlayer(ply)
									ply:Msg2("You have been removed from a locked suite.")
								end
							end
						end

        end
    end
end

function ENT:RoomUnload( room )
	self:CloseDoor()
end

local function Allow( owner, ply, Room )
	if !IsValid( ply ) || !IsValid( owner ) then return false end

	// admins always get access
	if ( ply:IsAdmin() ) then return true end

	if ( owner.GRoomLock && owner != ply ) then
		if Room:PlayerInRoom( ply ) then
			Suite.RemovePlayer( ply )
		end
		return false
	end
	return true

end

local function LockAllow( owner, ply, Room )

	if !IsValid( ply ) || !IsValid( owner ) then return false end

	// admins always get access
	if ( ply:IsAdmin() ) then return true end

	if ( owner != ply ) then return false end

	return true

end

function ENT:Think()
	local Room = GtowerRooms.Get( self:Id() )
	local owner = GtowerRooms.GetOwner(self:Id())

	for k,v in pairs(player.GetAll()) do
		Allow( owner, ply, Room )
	end
end

-- Use Terminal
function ENT:UsePanel( ply, cur_x, cur_y )
	local Room = GtowerRooms.Get( self:Id() )
	local owner = GtowerRooms.GetOwner(self:Id())

	if !Allow( owner, ply, Room ) then return end

	if ply != owner && ply._SuitePanelClick && ply._SuitePanelClick > CurTime() then
		return
	end

	ply._SuitePanelClick = CurTime() + 0.34

    if ( cur_x < 80 && cur_x > -70 && cur_y > -30 && cur_y < 160 ) then // Button 1: Open

        self.Entity:EmitSound( self.soundGranted )
		self:DoorFire("Open")

    elseif ( cur_x > 80 && cur_x < 240 && cur_y > -30 && cur_y < 160 ) then // Button 2: Close

        self.Entity:EmitSound( self.soundGranted )
		self:DoorFire("Close")

	elseif ( cur_x < -70 && cur_x > -240 && cur_y > -30 && cur_y < 60 ) then // Button 3: Lock

		if !LockAllow( owner, ply, Room ) then return end

		if owner:GetNWBool("Party") then
			owner:Msg2("You cannot lock your suite while you are throwing a party.")
			return
		end

        self.Entity:EmitSound( self.soundGranted )
		//GtowerRooms:RoomLock( self:Id(), true )
		self:DoorFire("Lock")
		owner.GRoomLock = true

	elseif ( cur_x < -70 && cur_x > -240 && cur_y > 70 && cur_y < 160 ) then // Button 4: Unlock

		if !LockAllow( owner, ply, Room ) then return end

        self.Entity:EmitSound( self.soundGranted )
		//GtowerRooms:RoomLock( self:Id(), false )
		self:DoorFire("Unlock")
		owner.GRoomLock = false

	end

end

concommand.Add( "gtower_suitepanel", function(ply, command, args)

    if #args != 3 then return end

    local ent = ents.GetByIndex( tonumber( args[1] ) )

    if !IsValid(ent) || ent:GetClass() != "func_suitepanel" then return end
    if ent:GetPos():Distance( ply:GetShootPos() ) > 65 then return end

    ent:UsePanel( ply, tonumber( args[2] ), tonumber( args[3] ) )

end )
