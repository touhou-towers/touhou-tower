
-----------------------------------------------------
ENT.Type 	= "anim"
ENT.Base 	= "base_anim"

ENT.Model	= Model( "models/maxofs2d/hover_rings.mdl" )

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "Power" )
	self:NetworkVar( "Bool", 0, "Forwards" )

end

function ENT:UpdateEndPos()

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	local kart = owner:GetKart()
	if !IsValid( kart ) then return end

	local dir = self:GetDirection()
	local origin = kart:GetPos() + kart:GetForward() * ( 32 * dir ) + kart:GetUp() * 8
	local filtered = { self, kart, self:GetOwner() }
	local off = 16

	local trace = util.TraceLine( { start = origin, endpos = origin + ( kart:GetForward() * ( 1024 ) * dir ) + kart:GetUp() * 32, filter = filtered } )

	self.HitPos = trace.HitPos
	self.Normal = trace.HitNormal
	self.HitEntity = trace.Entity

	// Visually move this up
	/*if !trace.HitWorld then
		trace = util.TraceLine( { start = trace.HitPos, endpos = trace.HitPos + Vector( 0, 0, -1024 ), filter = filtered } )
		self.HitPos = trace.HitPos + Vector( 0, 0, off )
	end*/

end

function ENT:GetDirection()

	if self.SavedDir then return self.SavedDir end

	if self:GetOwner():KeyDown(IN_ATTACK2) then
		self.SavedDir = -1
		return -1
	end

	self.SavedDir = 1
	return 1

end
