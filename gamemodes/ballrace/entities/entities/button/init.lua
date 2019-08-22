AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.ShowArrow = 1

function ENT:Initialize()
	self:SetModel( self.Model )

	if self.Parent then
		local Parent = ents.FindByName( self.Parent )

		if IsValid(Parent[1]) then
			self:SetParent( Parent[1] )
		end
	end

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.isPressed = false

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end

	if self.ShowArrow == 1 then
		local arrow = ents.Create( "arrow" )
		if !IsValid( arrow ) then return end

		arrow:SetPos( self:GetPos() + Vector( 0, 0, 165 ) )
		arrow:SetParent( self )
		arrow:SetOwner( self )
		arrow:Spawn()

		self.Arrow = arrow
	end

	/*local base = ents.Create( "prop_physics" )
	if !IsValid( base ) then return end

	base:SetModel( self.Model2 )
	base:SetPos( self:GetPos() )
	base:SetParent( self )
	base:SetOwner( self )
	base:Spawn()
	base:SetCollisionGroup( COLLISION_GROUP_NONE )
	base:SetSolid( SOLID_NONE )
	base:PhysicsInit( SOLID_NONE )

	self.Base = base

	local phys2 = base:GetPhysicsObject()
	if IsValid( phys2 ) then
		phys2:EnableMotion( false )
	end*/
end

function ENT:PhysicsCollide(data, phys)
	if !self.isPressed && IsValid( data.HitEntity ) && data.HitEntity:GetClass() == "player_ball" then
		local norm = data.HitNormal * -1
		local dot = self:GetUp():Dot( data.HitNormal )
		if math.abs(dot) < 0.1 then return end

		data.HitEntity:GetOwner():SetNWBool( "PressedButton", true )

		self.isPressed = true

		self:EmitSound("ballrace/button.wav",80)

		if self.Relay then ents.FindByName( self.Relay )[1]:Fire( "Trigger", 0, 0 ) end
		if self.Arrow then self.Arrow:Remove() end

		local rp = RecipientFilter():AddAllPlayers()
		umsg.Start( "ButtonPress", rp )
			umsg.Entity( self )
		umsg.End()
	end
end

function ENT:KeyValue( key, value )
	if key == "relay" then
		self.Relay = value
	elseif key == "arrow" then
		self.ShowArrow = value
	elseif key == "parentname" then
		self.Parent = value
	end
end
