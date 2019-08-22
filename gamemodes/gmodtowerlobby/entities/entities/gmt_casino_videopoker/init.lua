
-----------------------------------------------------
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "marquee.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/sam/videopoker.mdl" )
    self:PhysicsInit(SOLID_VPHYSICS)
  	self:SetMoveType(MOVETYPE_NONE)
  	self:SetSolid(SOLID_VPHYSICS)
  	self:SetUseType(SIMPLE_USE)
  	self:DrawShadow( false )
    self:SetAngles(Angle(0,90,0))
    
    timer.Simple(1,function()
      self:SetupChair()
    end)

    local phys = self.Entity:GetPhysicsObject()
    if (phys:IsValid()) then
      phys:EnableMotion(false)
      phys:Sleep()
    end

end

local function HandleRollercoasterAnimation( vehicle, player )
	return player:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER )
end

function ENT:SetupChair()

	// Chair Model
	self.chairMdl = ents.Create("prop_physics_multiplayer")
	self.chairMdl:SetModel("models/gmod_tower/aigik/casino_stool.mdl")
	//self.chairMdl:SetModel(self.ChairModel)
	--self.chairMdl:SetParent(self)

	if self:GetAngles().y == 270 then
		self.chairMdl:SetPos( self:GetPos() + Vector(0,-35,-2) )
	else
		self.chairMdl:SetPos( self:GetPos() + Vector(0,35,-2) )
	end

	if self:GetAngles().y == 270 then
		self.chairMdl:SetAngles( Angle(0, 90, 0) )
	else
		self.chairMdl:SetAngles( Angle(0, -90, 0) )
	end

	self.chairMdl:DrawShadow( false )

	self.chairMdl:PhysicsInit(SOLID_VPHYSICS)
	self.chairMdl:SetMoveType(MOVETYPE_NONE)
	self.chairMdl:SetSolid(SOLID_VPHYSICS)

	self.chairMdl:Spawn()
	self.chairMdl:Activate()
	self.chairMdl:SetParent(self)

	local phys = self.chairMdl:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

	self.chairMdl:SetKeyValue( "minhealthdmg", "999999" )

end

function ENT:SetupVehicle()
	// Chair Vehicle
	self.chair = ents.Create("prop_vehicle_prisoner_pod")
	self.chair:SetModel("models/nova/airboat_seat.mdl")
	self.chair:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
	self.chair:SetParent(self.chairMdl)
	self.chair:SetPos( self.chairMdl:GetPos() + Vector(0,0,30) )

	self.chair:SetAngles( Angle(0,self:GetAngles().y+90,0) )

	self.chair:SetNotSolid(true)
	self.chair:SetNoDraw(true)
	self.chair:DrawShadow( false )

	self.chair.HandleAnimation = HandleRollercoasterAnimation
	self.chair.bSlots = true

	self.chair:Spawn()
	self.chair:Activate()

	local phys = self.chair:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end

end

function ENT:IsInUse()

	if IsValid(self.chair) && self.chair:GetDriver():IsPlayer() then
		return true
	else
		return false
	end

end

function ENT:Use( ply )

	if !IsValid(ply) || !ply:IsPlayer() then
		return
	end

	if !self:IsInUse() then
		self:SetupVehicle()

		if !IsValid(self.chair) then return end -- just making sure...

		ply.SeatEnt = self.chair
		ply.EntryPoint = ply:GetPos()
		ply.EntryAngles = ply:EyeAngles()

		ply:EnterVehicle( self.chair )
		self:SendPlaying( ply )
	else
		return
	end

end

hook.Add( "PlayerLeaveVehicle", "ResetCollisionVehicle", function( ply )

	ply.SeatEnt = nil
	ply.EntryPoint = nil
	ply.EntryAngles = nil
	ply.SlotMachine = nil

	umsg.Start("slotsPlaying", ply)
	umsg.End()

end )

hook.Add( "CanPlayerEnterVehicle", "PreventEntry", function( ply, vehicle )

	/*if ( ply:GetBilliardTable() ) then
		//GAMEMODE:PlayerMessage( ply, "Warning!", "You cannot play slots while you are in a billiards game.\nYou must quit your billiards game!" )
		return false
	end*/

	return true

end )

function ENT:GetPlayer()

	local ply = player.GetByID( self.SlotsPlaying )

	if IsValid(ply) && ply:IsPlayer() && self:IsInUse() then
		return ply
	end


end
