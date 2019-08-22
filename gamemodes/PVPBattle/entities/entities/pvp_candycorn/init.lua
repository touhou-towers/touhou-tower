AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include("shared.lua")

function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	
	local phys = self:GetPhysicsObject()
	if phys then

		phys:EnableGravity( false )
		phys:EnableDrag( false )
		phys:SetMass( 1 )
		phys:SetBuoyancyRatio( 0 )
	
	end
	
	self.RemoveTime = CurTime() + .5
	
	local owner = self:GetOwner()
	if IsValid( owner ) then

		owner:EmitSound( Sound("weapons/crossbow/bolt_fly4.wav"), 90, 150 )

	end
	
end

function ENT:PhysicsCollide( data, phys )
	
	local hitEnt = data.HitEntity

	if hitEnt == hitEnt:GetOwner() || hitEnt:GetClass() == self:GetClass() then return end
	
	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() + ( data.HitNormal * 50 ),
		filter = { self },
	} )

	if tr.HitSky then
		self:Remove()
		return
	end

	if hitEnt:IsPlayer() then

		hitEnt:TakeDamage( math.random( 15, 25 ), self:GetOwner(), self )
		self:Splat( true )
		return

	end
	
	self.RemoveTime = CurTime() + 2

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then

		phys:EnableMotion( false )
		phys:Sleep()

	end

	/*umsg.Start( "CornStuck" )
		umsg.Entity( self )
	umsg.End()*/
	
	sound.Play( self.Sound, self:GetPos(), 100, math.random( 125, 180 ) )

	util.Decal( "YellowBlood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
	
end

function ENT:Think()

	if self.RemoveTime > CurTime() then return end
	self:Splat( false )

end

function ENT:Splat( bool )

	if bool then

		local effectdata = EffectData()
			effectdata:SetStart( self:GetPos() )
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetMagnitude( .25 )
		util.Effect( "StriderBlood", effectdata )

		sound.Play( Sound("npc/antlion_grub/squashed.wav"), self:GetPos(), 100, 100 )
	
	end
	
	self:Remove()
	
end