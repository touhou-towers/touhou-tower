
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.AddNetworkString( "InstrumentNetworkDrum" )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	self:DrawShadow( true )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end

	self:InitializeAfter()

end

function ENT:InitializeAfter()
end

local function HandleRollercoasterAnimation( vehicle, player )
	return player:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER )
end

function ENT:SetupChair( vecmdl, angmdl, vecvehicle, angvehicle )

	// Chair Model
	self.ChairMDL = ents.Create( "prop_physics_multiplayer" )
	self.ChairMDL:SetModel( self.ChairModel )
	self.ChairMDL:SetParent( self )
	self.ChairMDL:SetPos( self:GetPos() + vecmdl )
	self.ChairMDL:SetAngles( angmdl )
	self.ChairMDL:DrawShadow( false )
	self.ChairMDL:SetNoDraw( true )

	self.ChairMDL:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self.ChairMDL:Spawn()
	self.ChairMDL:Activate()
	self.ChairMDL:SetOwner( self )

	local phys = self.ChairMDL:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

	self.ChairMDL:SetKeyValue( "minhealthdmg", "999999" )

	// Chair Vehicle
	self.Chair = ents.Create( "prop_vehicle_prisoner_pod" )
	self.Chair:SetModel( "models/nova/airboat_seat.mdl" )
	self.Chair:SetKeyValue( "vehiclescript","scripts/vehicles/prisoner_pod.txt" )
	self.Chair:SetPos( self.ChairMDL:GetPos() + vecvehicle )
	self.Chair:SetParent( self.ChairMDL )
	self.Chair:SetAngles( angvehicle )
	self.Chair:SetNotSolid( true )
	self.Chair:SetNoDraw( true )
	self.Chair:DrawShadow( false )
	self.Chair:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self.Chair.HandleAnimation = HandleRollercoasterAnimation
	self.Chair:SetOwner( self )

	self.Chair:Spawn()
	self.Chair:Activate()

	local phys = self.Chair:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

end

local function HookChair( ply, ent )

	local inst = ent:GetOwner()

	if IsValid( inst ) && inst.Base == "gmt_instrument_base_drum" then

		if !IsValid( inst.Owner ) then
			inst:AddOwner( ply )
			return true
		else
			if inst.Owner == ply then
				return true
			end
		end

		return false

	end

	return true

end

// Quick fix for overriding the instrument chair seating
hook.Add( "CanPlayerEnterVehicle", "InstrumentChairHook", HookChair )
hook.Add( "PlayerUse", "InstrumentChairModelHook", HookChair )

function ENT:Use( ply )

	if IsValid( self.Owner ) then return end

	self:AddOwner( ply )

end

function ENT:AddOwner( ply )

	if IsValid( self.Owner ) then return end

	net.Start( "InstrumentNetwork" )
		net.WriteEntity( self )
		net.WriteInt( INSTNET_USE, 4 )
	net.Send( ply )

	ply:SetNWVector("PianoEntry",ply:GetPos())
	ply:SetNWAngle("PianoEntryAng",ply:EyeAngles())

	self.Owner = ply

	ply:EnterVehicle( self.Chair )

	self.Owner:SetEyeAngles( Angle( 25, 90, 0 ) )

end

function ENT:RemoveOwner()

	if !IsValid( self.Owner ) then return end

	net.Start( "InstrumentNetworkDrum" )
		net.WriteEntity( nil )
		net.WriteInt( INSTNET_USE, 3 )
	net.Send( self.Owner )

	self.Owner:ExitVehicle( self.Chair )

	self.Owner:SetPos( self.Owner:GetNWVector("PianoEntry") )
	self.Owner:SetEyeAngles( self.Owner:GetNWAngle("PianoEntryAng") )

	self.Owner = nil

end

/*function ENT:NetworkKeys( keys )

	if !IsValid( self.Owner ) then return end // no reason to broadcast it

	net.Start( "InstrumentNetwork" )

		net.WriteEntity( self )
		net.WriteInt( INSTNET_HEAR, 3 )
		net.WriteTable( keys )

	net.Broadcast()

end*/

function ENT:NetworkKey( key )
	if !IsValid( self.Owner ) then return end // no reason to broadcast it

	net.Start( "InstrumentNetworkDrum" )

		net.WriteEntity( self )
		net.WriteInt( INSTNET_HEAR, 3 )
		net.WriteString( key )

	net.Broadcast()

end

// Returns the approximate "fitted" number based on linear regression.
function math.Fit( val, valMin, valMax, outMin, outMax )
	return 1
end

net.Receive( "InstrumentNetworkDrum", function( length, client )
	local ent = net.ReadEntity()
	if !IsValid( ent ) then return end

	local enum = net.ReadInt( 3 )

	// When the player plays notes
	if enum == INSTNET_PLAY then

		// Filter out non-instruments
		if ent.Base != "gmt_instrument_base_drum" then return end

		// This instrument doesn't have an owner...
		if !IsValid( ent.Owner ) then return end

		// Check if the player is actually the owner of the instrument
		if client == ent.Owner then

			// Gather note
			local key = net.ReadString()

			// Send it!!
			ent:NetworkKey( key )

			// Offset the note effect
			local pos = string.sub( key, 2, 3 )
			pos = math.Fit( tonumber( pos ), 1, 36, -3.8, 4 )

			// Note effect
			local eff = EffectData()
				eff:SetOrigin( client:GetPos() + Vector( -15, pos * 10, -5 ) )
			util.Effect( "musicnotes", eff, true, true )

			// Gather notes
			/*local keys = net.ReadTable()

			// Send them!!
			ent:NetworkKeys( keys )*/

		end

	end

end )

concommand.Add( "instrument_leave_drum", function( ply, cmd, args )

	if #args < 1 then return end // no ent id

	// Get the instrument
	local entid = args[1]
	local ent = ents.GetByIndex( entid )

	// Filter out non-instruments
	if !IsValid( ent ) || ent.Base != "gmt_instrument_base_drum" then return end

	// This instrument doesn't have an owner...
	if !IsValid( ent.Owner ) then return end

	// Leave instrument
	if ply == ent.Owner then
		ent:RemoveOwner()
	end

end )
