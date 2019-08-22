

-----------------------------------------------------
if SERVER then
	AddCSLuaFile( "shared.lua" )
end

ENT.Type = "anim"

ENT.Model	= Model( "models/props/cs_assault/Money.mdl" )

function ENT:Initialize()

	if CLIENT then return end

	self:SetModel( self.Model )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetTrigger(true)

	self:DrawShadow( false )

	self.DieTime = CurTime() + 10

end

function ENT:Think()

	if CLIENT || self.IsDead then return end

	if CurTime() > self.DieTime then

		self.IsDead = true
		self:Delete()

	end

end

function ENT:StartTouch(ply)

	if IsValid(ply) and ply:IsPlayer() and ply != self.Owner then
		ply:AddMoney(math.random(1,100))
		self:Delete()
	end

end

function ENT:Delete()

	self:Remove()

end


if CLIENT then

	function ENT:Draw()

		self:DrawModel()

		if self.Scale && self.Scale > 0 then

			local num, spd = 1, 2
			self.Scale = math.Approach( self.Scale, 0, ( FrameTime() * ( self.Scale * spd ) ) )
			self:SetModelScale( self.Scale, 0 )

			local rot = self:GetAngles()
			rot.y = rot.y + 90 * ( FrameTime() * 10 )

			self:SetAngles( rot )
			self:SetRenderAngles( rot )

		else

			local r = math.abs( math.sin( CurTime() * 4 ) ) * 255
			local g = -r

			self:SetColor( Color( r, g, 0, 255 ) )

		end

	end


end
