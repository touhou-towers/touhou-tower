include( "shared.lua" )
local matBeam = Material( "effects/laser1" )
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Beams = {}
ENT.Size = 0
ENT.SpriteMat = Material( "sprites/powerup_effects" )
function ENT:Draw()
	local owner = self:GetOwner()
	if IsValid( owner ) then
		pos = util.GetCenterPos( owner )
		render.SetMaterial( self.SpriteMat )
		render.DrawSprite( pos, 128, 128, self.Color )
	end
end
function ENT:DrawTranslucent()
	self.Color = Color( math.random( 50, 100 ), math.random( 50, 100 ), math.random( 50, 100 ) )
	for id, ent in pairs( ents.GetAll() ) do
		// Players
		if ent:IsPlayer() && self:ShouldHealPlayer( ent ) then
			self:DrawBeam( ent, true )
			continue
		end
		// NPCs
		if ent:IsNPC() && self:IsInRadius( ent, self.Radius ) then
			self:DrawBeam( ent, false )
		end
	end
end
function ENT:DrawBeam( ent, isplayer )
	local owner = self:GetOwner()
	if !IsValid( ent ) || !IsValid( owner ) then return end
	local pos1 = self:GetCenterPos()
	local pos2 = self:GetEnemyPos( ent )
	// Beam
	local size = 10
	self.Color = Color( 255, math.random( 50, 100 ), math.random( 50, 100 ) )
	if isplayer then
		size = 20
		self.Color = Color( math.random( 50, 100 ), 255, math.random( 50, 100 ) )
	end
	self.Size = math.Approach( self.Size, size, FrameTime() * 600 )
	render.SetMaterial( matBeam )
	render.DrawBeam( pos1, pos2, self.Size, 3, 0, self.Color )
	/*local eff = EffectData()
		eff:SetOrigin( pos2 )
		eff:SetNormal( entend:GetUp() )
	util.Effect( "ManhackSparks", eff, true, true )*/
end