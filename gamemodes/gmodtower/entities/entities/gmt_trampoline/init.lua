
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetModel( "models/gmod_tower/trampoline.mdl" )

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self:DrawShadow( true )

	local phys = self.Entity:GetPhysicsObject()
	
	if ( phys:IsValid() ) then
		phys:EnableMotion( false )
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
		"gmt_suitebed",

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
	if !IsValid( ent ) then return end

	local norm = data.HitNormal * -1
	local dot = self:GetUp():Dot( data.HitNormal )
	if math.abs( dot ) < 0.5 then return end

	local scale = math.Rand( 1, 1.25 )
	local dist = 250 * scale // at this scale, [250-312.5]
	local pitch = 100 * scale // [100-125]

	local mulNorm = norm * dist
	if ( mulNorm.z < 0 ) then mulNorm.z = -mulNorm.z end

	if ent:IsPlayer() then physent = ent end
	if ValidPhysics( ent ) then physent = ent:GetPhysicsObject() end

	if IsValid( physent ) then
		physent:SetVelocity( mulNorm )
	end

	ent:EmitSound( Sound("GModTower/misc/boing.wav"), 50, pitch )
	self:Boing()

	/*local loc = ent:Location()
	local rp = Location.RP( loc )*/

	umsg.Start( "GTramp" )
		umsg.Entity( self.Entity )
	umsg.End()

end