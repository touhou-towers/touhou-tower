AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

ENT.TargetZ = 0
ENT.StartPos = 0
ENT.StartLoc = 0

util.AddNetworkString("gmt_raveroomset")
util.AddNetworkString("gmt_raveset")

function ENT:Use( ply )

	if ply:IsAdmin() then
		net.Start("gmt_raveset")
		net.WriteEntity(self)
		net.WritePlayer(ply)
		net.Broadcast()
		return
	end

	if ply:IsPlayer() and ply.GRoom then

		if GtowerRooms.PositionInRoom( self:GetPos() ) != ply.GRoom.Id then return end

		net.Start("gmt_raveset")
		net.WriteEntity(self)
		net.WritePlayer(ply)
		net.Broadcast()

	end

end

function ENT:Initialize()
	self:SetModel( Model("models/gmod_tower/discoball.mdl") )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	self:StartMotionController()

	self:SetFadeDistance( 200*3 )

	timer.Create("gmt_raveupdate" .. self:EntIndex(),1,0,function()

		if self.StartPos == 0 then self.StartPos = self:GetPos() end

		local curloc = GTowerLocation:FindPlacePos(self:GetPos())

		if self.StartLoc == 0 then self.StartLoc = curloc end

		if curloc != self.StartLoc then self:SetPos(self.StartPos) end

		net.Start("gmt_raveroomset")
		net.WriteEntity(self)
		net.WriteInt( curloc, 16)
		net.Broadcast()
	end)

end

function ENT:OnRemove()
    if timer.Exists("gmt_raveupdate" .. self:EntIndex()) then
			timer.Destroy("gmt_raveupdate" .. self:EntIndex())
		end
end

concommand.Add( "boxvis_set", function( ply, cmd, args, fcmd )
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		args[1] = args[1] or ""
		for _, ent in pairs( ents.FindByClass("gmt_raveball") ) do
			if string.find(args[2],"www.dropbox.com") then
				ent:SetSong(string.Replace( args[2] , "www.", "dl."))
				return
			elseif string.find(args[2],"drive.google.com") then
				local gID = string.match(args[2], "/d/(.-)/")
				ent:SetSong( "http://docs.google.com/uc?export=open&id=" .. gID )
				return
			end
			ent:SetSong( args[1] )
		end
	end
end )

concommand.Add( "gmt_rave_set", function( ply, cmd, args, fcmd )
		local ent = ents.GetByIndex(args[1])

		if ply:IsAdmin() then
			args[2] = args[2] or ""
			if string.find(args[2],"www.dropbox.com") then
				ent:SetSong(string.Replace( args[2] , "www.", "dl."))
				return
			elseif string.find(args[2],"drive.google.com") then
				local gID = string.match(args[2], "/d/(.-)/")
				ent:SetSong( "http://docs.google.com/uc?export=open&id=" .. gID )
				return
			end
			ent:SetSong( args[2] )
			return
		end

		if !ply.GRoom then return end

		if GtowerRooms.PositionInRoom( ent:GetPos() ) != ply.GRoom.Id then return end

		args[2] = args[2] or ""
		if string.find(args[2],"www.dropbox.com") then
			ent:SetSong(string.Replace( args[2] , "www.", "dl."))
			return
		elseif string.find(args[2],"drive.google.com") then
			local gID = string.match(args[2], "/d/(.-)/")
			ent:SetSong( "http://docs.google.com/uc?export=open&id=" .. gID )
			return
		end
		ent:SetSong( args[2] )
end )

function ENT:SpawnFunction( ply, tr, Class )
	if( !tr.Hit ) then return end
	local Ent = ents.Create( Class )
	Ent:SetPos( ( tr.HitPos + tr.HitNormal ) )
	Ent:SetAngles( ply:GetAngles() )
	Ent:Spawn()
	Ent:Activate()
	return Ent
end


function ENT:Trace( pos, dir )

	return util.TraceLine( {
		start = pos,
		endpos = pos + dir,
		filter = self,
		mask = MASK_SOLID_BRUSHONLY
	} )

end

function ENT:Think()

	local DownTrace = self:Trace( self:GetPos(),  Vector(0,0,-1000) )
	local UpTrace = self:Trace( DownTrace.HitPos,  Vector(0,0,1000) )

	if DownTrace.HitSky || UpTrace.HitSky then
		return
	end

	local Target = ( DownTrace.HitPos + UpTrace.HitPos ) / 2

	self.TargetZ = Target.z

	self:NextThink( CurTime() + 0.25 )

end

function ENT:PhysicsSimulate( phys, deltatime )

	local Pos = phys:GetPos()
	local Vel = phys:GetVelocity()
	local Distance = self.TargetZ - Pos.z
	local AirResistance = 0.1

	if ( Distance == 0 ) then return end

	local Exponent = Distance^2

	if ( Distance < 0 ) then
		Exponent = Exponent * -1
	end

	Exponent = Exponent * deltatime * 300

	local physVel = phys:GetVelocity()
	local zVel = physVel.z

	Exponent = Exponent - (zVel * deltatime * 600 * ( AirResistance + 1 ) )
	// The higher you make this 300 the less it will flop about
	// I'm thinking it should actually be relative to any objects we're connected to
	// Since it seems to flop more and more the heavier the object

	Exponent = math.Clamp( Exponent, -5000, 5000 )

	local Linear = Vector(0,0,0)
	local Angular = Vector(0,0,0)

	Linear.z = Exponent

	if ( AirResistance > 0 ) then

		Linear.y = physVel.y * -1 * AirResistance
		Linear.x = physVel.x * -1 * AirResistance

	end

	return Angular, Linear, SIM_GLOBAL_ACCELERATION

end
