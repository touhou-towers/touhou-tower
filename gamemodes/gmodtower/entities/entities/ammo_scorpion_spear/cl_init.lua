

-----------------------------------------------------
include("shared.lua")

ENT.RopeMat = Material( "cable/rope" )

function ENT:Think()

	local ShootPos = self:GetOwnerShootPos()
	if !ShootPos then return end

	self:SetRenderBoundsWS( self:GetPos(), ShootPos )
	
	if IsValid( self:GetParent() ) then
		self:SetPos( self:GetParent():GetPos() + Vector( 0, 0, 48 ) )
	end

	self:NextThink( CurTime() + 0.1 )

end

function ENT:Draw()

	--SetModelScaleVector( Vector( .1, .5, .5 ) )
	self:DrawModel()

	local ShootPos = self:GetOwnerShootPos()

	if !ShootPos then return end

	render.SetMaterial( self.RopeMat )
	render.DrawBeam( self:GetPos(), ShootPos, 2, 0, 0, Color( 255, 255, 255, 255 ) )
	
	
end

function ENT:GetOwnerShootPos()

	if !IsValid( self:GetOwner() ) then return false end

	if GetViewEntity() == self:GetOwner() then
	end

	return self:GetOwner():GetShootPos() + Vector( 0, 0, -10 )

end
