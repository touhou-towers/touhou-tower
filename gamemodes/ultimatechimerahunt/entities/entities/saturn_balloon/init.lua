AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

//local MODEL = Model( "models/dav0r/balloon/balloon.mdl" )
local MODEL = Model( "models/maxofs2d/balloon_classic.mdl" )

function ENT:Initialize()

	// Use the helibomb model just for the shadow (because it's about the same size)
	self:SetModel( MODEL )
	self:PhysicsInit( SOLID_VPHYSICS )
	
	// Set up our physics object here
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
	
		phys:SetMass( 100 )
		phys:Wake()
		phys:EnableGravity( false )
		
	end
	
	self:SetForce( 1 )
	self:StartMotionController()
	
end

function ENT:SetForce( force )

	self.Force = force * 5000

end

function ENT:OnTakeDamage( dmginfo )
	
	local r, g, b = self:GetColor()
	
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart( Vector( r, g, b ) )
	util.Effect( "piggy_pop", effectdata )
	
	self:Remove()
	
end

function ENT:PhysicsSimulate( phys, deltatime )

	local vLinear = Vector( 0, 0, self.Force ) * deltatime
	local vAngular = Vector( 0, 0, 0 )

	return vAngular, vLinear, SIM_GLOBAL_FORCE
	
end