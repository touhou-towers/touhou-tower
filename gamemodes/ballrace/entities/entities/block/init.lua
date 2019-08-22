AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Radius = 150

function ENT:Initialize()

	self:SetModel( self.Model )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()

	if IsValid( phys ) then
		phys:EnableMotion( false )
	end

	self:IdleThink()

	//self.Check = CurTime() + 1
end

function ENT:KeyValue( key, value )

	if key == "model" then
		self.Model = value
	elseif key == "radius" then
		self.Radius = value
	end

end

function ENT:PlayEffect( appear )

	umsg.Start( "BlockEffect" )
		umsg.Bool( appear )
		umsg.Entity( self )
	umsg.End()

	effectType = "disappear"

	if appear then
		effectType = "reappear"
	end

	local eff = EffectData()
	eff:SetEntity( self )

	util.Effect( effectType, eff )
end

function ENT:IdleThink()
	//print("idle")

	if ( !self.Disappeared ) then

		self:PlayEffect( false )

		self.Disappeared = true
		self.Appeared = false

	end

	--self:SetCollisionGroup( COLLISION_GROUP_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )

	self:DrawShadow( false )
	self:SetNoDraw( true )
end

function ENT:ActiveThink()
	//print("active")

	if ( !self.Appeared ) then

		self:PlayEffect( true )

		self.Disappeared = false
		self.Appeared = true

	end

	--self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )

	self:DrawShadow( true )
	self:SetNoDraw( false )
end

function ENT:Think()

	//if self.Check < CurTime() then return end
	//self.Check = CurTime() + 0.5

	self.FoundPlayer = false

	local entList = ents.FindInSphere( self:GetPos(), self.Radius )

	//PrintTable( entList )

	for _, ent in ipairs( entList ) do

		if IsValid( ent ) && ent != self && ent:GetClass() == "player_ball" then
			//Msg( "found a player\n" )
			self.FoundPlayer = true

		end

	end

	if self.FoundPlayer then
		self:ActiveThink()
	else
		self:IdleThink()
	end

	self:NextThink( CurTime() + .5 )

end
