
-----------------------------------------------------
AddCSLuaFile()

local BaseClass = baseclass.Get( "base_anim" )

function ENT:SphereInit( r )

	self:PhysicsInitSphere( r, "Ice" )

end

function ENT:Initialize()

	self:SetCustomCollisionCheck( true )
	self:SetupDataTables()

	self:SetModel( "models/gmod_tower/ball.mdl" )
	self:DrawShadow( false )
	self:SetNoDraw( true )

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

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "CSize" )
end

function ENT:SetSize( size )

	self.Size = size or ( 16 * 2 ) // anything less than 10 will cause bumps
	self:SphereInit( size )
	self:SetCSize( size )

end

function ENT:Enable( bool )

	self:SetNotSolid( !bool )

	if bool then
		self:SetSolid( SOLID_VPHYSICS )
	else
		self:SetSolid( SOLID_NONE )
	end

end

local devcvar = true--GetConVar("developer")
hook.Add( "PostDrawTranslucentRenderables", "DrawWheels", function()

	if true then return end
	--if !DEBUG then return end
	--if !devcvar:GetBool() then return end
	for _, ent in pairs( ents.FindByClass( "sk_wheel" ) ) do

		color = Color( 255, 128, 64, 255 )
		if ent:GetCSize() > 16 then
			color = Color( 128, 255, 64, 255 )
		end

		render.DrawWireframeSphere( ent:GetPos(), ent:GetCSize(), 16, 16, color )

	end

end )
