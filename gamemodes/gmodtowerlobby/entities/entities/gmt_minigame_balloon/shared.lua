AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Balloon"
ENT.Spawnable = true

function ENT:Initialize()

	if ( CLIENT ) then return end

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )

	-- Set up our physics object here
	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then

		phys:SetMass( 100 )
		phys:Wake()
		phys:EnableGravity( false )

	end

	self:SetForce( 1 )
	self:StartMotionController()

end

function ENT:SetForce( force, mul ) 
   
	if (force) then	self.force = force end 
	
	mul = mul or 1 

	local max = self.Entity:OBBMaxs()
	local min = self.Entity:OBBMins()

	self.ThrustOffset 	= Vector( 0, 0, max.z )
	self.ThrustOffsetR 	= Vector( 0, 0, min.z )
	self.ForceAngle		= self.ThrustOffset:GetNormalized() * -1
	
	local phys = self.Entity:GetPhysicsObject() 
	if (!phys:IsValid()) then  
		return
	end 
	
 	// Get the data in worldspace 
	local ThrusterWorldPos = phys:LocalToWorld( self.ThrustOffset ) 
	local ThrusterWorldForce = phys:LocalToWorldVector( self.ThrustOffset * -1 ) 
	 
	// Calculate the velocity 
	ThrusterWorldForce = ThrusterWorldForce * self.force * mul * 10 
	self.ForceLinear, self.ForceAngle = phys:CalculateVelocityOffset( ThrusterWorldForce, ThrusterWorldPos ); 
	self.ForceLinear = phys:WorldToLocalVector( self.ForceLinear ) 
 	 
end 

function ENT:OnTakeDamage( dmginfo )

	if ( self.Indestructible ) then return end

	local c = self:GetColor()

	local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetStart( Vector( c.r, c.g, c.b ) )
	util.Effect( "balloon_pop", effectdata )

	if ( self.Explosive ) then

		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetScale( 1 )
		effectdata:SetMagnitude( 25 )
		util.Effect( "Explosion", effectdata, true, true )

	end

	self:Remove()

end

function ENT:PhysicsSimulate( phys, deltatime )

	local vLinear = Vector( 0, 0, 45 * 5000 ) * deltatime
	local vAngular = Vector( 0, 0, 0 )

	return vAngular, vLinear, SIM_GLOBAL_FORCE

end
