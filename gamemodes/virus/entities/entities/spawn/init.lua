AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize() 

	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:DrawShadow( false )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self.RemoveTime = CurTime() + 2

	self:SetDTFloat( 0, math.Rand( 0.5, 1.3 ) )
	self:SetDTFloat( 1, math.Rand( 0.3, 1.2 ) )

end

function ENT:SetupDataTables()

	self:DTVar( "Float", 0, "RotationSeed1" )
	self:DTVar( "Float", 1, "RotationSeed2" )

end

function ENT:Think()

	if !self.ShouldRemove then return end

	if !self.RemoveTime then self:Remove() return end

	if self.RemoveTime < CurTime() then

		self:Remove()

	end

end

function ENT:SetSpawnOwner( ply ) //lol, just in case

	self:SetOwner( ply )

end

function ENT:ShouldRemove( bool )

	self.ShouldRemove = bool
	
end