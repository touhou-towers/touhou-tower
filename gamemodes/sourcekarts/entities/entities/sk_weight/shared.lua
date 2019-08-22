
-----------------------------------------------------
AddCSLuaFile()

local BaseClass = baseclass.Get( "base_anim" )

ENT.Size = 16 * 1.6

function ENT:SphereInit( r )
	self:PhysicsInitSphere( r, "Ice" )
end

function ENT:Initialize()

	self:SetCustomCollisionCheck( true )

	self:SetModel( "models/gmod_tower/ball.mdl" )
	self:DrawShadow( false )
	self:SetNoDraw( true )
	self:SetNotSolid( true )

	self:SphereInit( self.Size )

	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
		phys:SetMass(2)
		phys:SetDamping( 0, 0 )
		phys:SetBuoyancyRatio(0.5)
		phys:SetMaterial("Ice")
		phys:EnableDrag( false )
	end

end

local devcvar = true--GetConVar("developer")
hook.Add( "PostDrawTranslucentRenderables", "DrawWeight", function()

	if !DEBUG then return end
	if !devcvar then return end
	for _, ent in pairs( ents.FindByClass( "sk_weight" ) ) do
		render.DrawWireframeSphere( ent:GetPos(), ent.Size, 16, 16, Color( 128, 255, 64, 255 ) )
	end

end )
