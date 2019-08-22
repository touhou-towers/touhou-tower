AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( false )
	end

	self.Lit = 0

end

function ENT:Think()

	if self.Lit > 0 && CurTime() > self.Lit + 0.15 then

		self.Lit = 0
		self:SetMaterial( "" )

	end

end

local function ValidPhysics( ent )

	local PushableProps = {
		"gmt_ballrace",

		//typical source stuff
		"prop_physics", "prop_physics_respawnable",
		"prop_multiplayer", "prop_multiplayer_respawnable",
		"prop_ragdoll", "prop_dynamic", "func_physbox",

		//merchant crap
		"gmt_discoball", "gmt_pet", "gmt_piano", "firework_*",

		//small ones
		"prop_snowball", "ammo_candycorn", "candycorn*",

		//buyable electronics
		"gmt_clock", "gmt_lamp",

		//alcoholics
		"gmt_beer*", "alcohol_bottle",

		//bigger stuff
		"gmt_suitebed", "gmt_trampoline",

		//rockets
		"rynov_rpg", "rpg_missile"
	}

	for _, propType in ipairs( PushableProps ) do
		if ent:GetClass() == propType then
			return true
		end
	end

	return false

end

function ENT:PhysicsCollide( data, phys )

	local ent = data.HitEntity

	if self.Lit == 0 && IsValid( ent ) then

		local norm = data.HitNormal * -1		
		local dot = self:GetUp():Dot( data.HitNormal )
		if math.abs( dot ) > 0.2 then return end

		if ValidPhysics( ent ) then

			local vel = data.TheirOldVelocity
			local mass = data.HitObject:GetMass()
			local force = norm * mass * math.min( 400, vel:Length() ) * 2
			
			data.HitObject:ApplyForceCenter( force )

		end

		if ent:IsPlayer() then

			local scale = math.Rand( 1, 1.25 )
			local dist = 650 * scale
			local mulNorm = norm * dist

			ent:SetVelocity( mulNorm + Vector( 0, 0, 100 ) )

		end

		self:SetMaterial( self.LitMaterial )
		self.Lit = CurTime()
		self:EmitSound( self.BumpSound )

		local edata = EffectData()
		edata:SetOrigin( data.HitPos )
		edata:SetNormal( data.HitNormal * -1 )
		util.Effect( "ball_hit", edata )

	end

end