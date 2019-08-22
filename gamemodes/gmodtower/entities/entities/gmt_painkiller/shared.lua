
AddCSLuaFile("shared.lua")

ENT.Base		= "base_anim"
ENT.Type		= "anim"
ENT.PrintName	= "Painkilers"

ENT.Model		= Model("models/props_lab/jar01a.mdl")
ENT.Sound		= Sound("HL1/fvox/medical_repaired.wav")

function ENT:Initialize()
	if CLIENT then return end

	self:SetModel(self.Model)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( 0 )
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()

	if IsValid( phys ) then
		phys:EnableMotion( false )
	end

	self.Used = false
end

function ENT:Use(ply)
	if CLIENT || self.Used then return end

	self.Used = true
	self:EmitSound( self.Sound, 100, 150 )
	
	ply:Extinguish()
	ply:SetHealth( 100 )
	ply:Freeze( false )
	ply:UnDrunk()
	PostEvent( ply, "ppainkiller" )
	ply:AddAchivement( ACHIVEMENTS.PILLSHERE, 1 )

	self:Remove()
end

if SERVER then return end

ENT.Color = Color( 200, 200, 200, 255 )
ENT.SpriteMat = Material( "sprites/powerup_effects" )

function ENT:Initialize()
	self.BaseClass:Initialize()
	self.OriginPos = self:GetPos()
	self.NextParticle = CurTime()
	self.TimeOffset = math.Rand( 0, 3.14 )

	self.Emitter = ParticleEmitter( self:GetPos() )
end

function ENT:Draw()
	self:DrawModel()

	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self:GetPos(), 50, 50, self.Color ) 
end

function ENT:Think()
	local rot = self:GetAngles()
	rot.y = rot.y + 90 * FrameTime()

	self:SetAngles(rot)	
	self:SetRenderAngles(rot)
	
	if CurTime() > self.NextParticle then
		local emitter = self.Emitter

		local pos = self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * 0.75 ) )
		local vel = VectorRand() * 3

		vel.z = vel.z * ( vel.z > 0 && -3 or 3 )

		local particle = emitter:Add( "sprites/powerup_effects", pos )

		if particle then
			particle:SetVelocity( vel )
			particle:SetDieTime( math.Rand( 1, 3 ) )
			particle:SetStartAlpha( 100 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 18 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
			particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
		end

		self.NextParticle = CurTime() + 0.15
	end
end