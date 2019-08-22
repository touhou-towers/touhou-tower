include( "shared.lua" )
ENT.Color 			= Color( 255, 0, 0, 200 )
ENT.SpriteOffset 	= Vector( 0, 0, 10 )
local matBeam 		= Material( "effects/laser1" )
local matGlow 		= Material( "sprites/light_glow02_add" )
local colBeam 		= Color( 255, 0, 0 )
local colBeamInner 	= Color( 255, 150, 150 )
ENT.RenderGroup 	= RENDERGROUP_BOTH
ENT.CNPCS 			= {}
ENT.CNPCSShoot		= {}
ENT.LaserBeamSize	= 300
function ENT:DrawTranslucent()
	for id, ent in pairs( ents.GetAll() ) do
		if ent:IsNPC() && self:IsInRadius( ent ) then
			if !ent._LaserDelay then
				ent._LaserDelay = CurTime() + self.ShootDelay
			end
			if ent._LaserDelay < CurTime() then
				self:DrawLaserBeam( ent )
			end
			// Beam from unit
			render.SetMaterial( matBeam )
			render.DrawBeam( self:GetPos(), ent:GetPos(), 5, 3, 0, colBeam )
		end
	end
end
function ENT:DrawLaserBeam( ent )
	if !IsValid( ent ) then return end
	local startpos = ent:GetPos()
	local endpos = ent:GetPos() + Vector( 0, 0, 2000 )
	self:SetRenderBoundsWS( startpos, endpos, Vector( 256, 256, 256 ) )
	if !ent._LaserSize then ent._LaserSize = 0 end
	ent._LaserSize = math.Approach( ent._LaserSize, self.LaserBeamSize, 8 )
	local size = ent._LaserSize
	// Main beam
	render.SetMaterial( matBeam )
	render.DrawBeam( startpos, endpos, size, 3, 0, colBeam )
	// Inner beam
	local size2 = math.min( size, 32 )
	render.DrawBeam( startpos, endpos, size2, 3, 0, colBeamInner )
	// Sprite hit
	local spritepos = startpos
	render.SetMaterial( matGlow )
	render.DrawQuadEasy( spritepos, ent:GetUp(), size, size, colBeam )
	//render.DrawSprite( spritepos, math.max( 48, size * 2.5 ), size, colBeamInner )
	//render.DrawSprite( spritepos, math.max( 64, size * 3.25 ), size * 1.25, colBeam )
	// Sprite sun
	local sunsize = size * 32 + 256
	local sunsizewhite = size * 28 + 256
	render.DrawSprite( endpos, sunsizewhite, sunsizewhite, color_white )
	render.DrawSprite( endpos, sunsize, sunsize, colBeam )
	render.DrawSprite( endpos, sunsizewhite, sunsizewhite, color_white )
	render.DrawSprite( endpos, sunsize, sunsize, colBeam )
	// DLight
	/*local dlight_start = DynamicLight( self:EntIndex() .. ent:EntIndex() )
	if dlight_start then
		dlight_start.Pos = startpos
		dlight_start.r = 255
		dlight_start.g = 0
		dlight_start.b = 0
		dlight_start.Brightness = 1
		dlight_start.Decay = 128
		dlight_start.size = 80
		dlight_start.DieTime = CurTime() + .1
	end*/
end
function ENT:DrawLaserTarget( ent )
	if !IsValid( ent ) then return end
	local pos = ( ent:GetPos() ):ToScreen()
	local size = 32
	local x, y = pos.x, pos.y
	// Work out sizes.
	local a, b = size / 2, size / 6
	surface.SetDrawColor( 255, 0, 0, 255 )
	// Top left.
	surface.DrawLine(x - a, y - a, x - b, y - a)
	surface.DrawLine(x - a, y - a, x - a, y - b)
	// Bottom right.
	surface.DrawLine(x + a, y + a, x + b, y + a)
	surface.DrawLine(x + a, y + a, x + a, y + b)
	// Top right.
	surface.DrawLine(x + a, y - a, x + b, y - a)
	surface.DrawLine(x + a, y - a, x + a, y - b)
	// Bottom left.
	surface.DrawLine(x - a, y + a, x - b, y + a)
	surface.DrawLine(x - a, y + a, x - a, y + b)
end
hook.Add( "HUDPaint", "LaserTargeting", function()
	local lasers = ents.FindByClass( "zm_item_special_laser" )
	for id, ent in pairs( ents.GetAll() ) do
		if ent:IsNPC() then
			for _, lps in pairs( lasers ) do
				if lps:IsInRadius( ent ) then
					lps:DrawLaserTarget( ent )
				end
			end
		end
	end
end )