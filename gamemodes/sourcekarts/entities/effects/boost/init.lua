
-----------------------------------------------------
local matLight 	= Material( "effects/select_ring" )
local matLight2 = Material( "sprites/powerup_effects" )

function EFFECT:Init( data )

	self.Color = colorutil.Rainbow( 5 )

	self.Resize = 0
	self.Size = 0
	self.MaxSpriteSize = 128
	self.Alpha = 255

	self.Pos = data:GetOrigin()
	self.Norm = data:GetNormal()

end

function EFFECT:Think()

	self.Alpha = ( self.Alpha or 255 ) - FrameTime() * 250
	self.Resize = self.Resize + 1.5 * FrameTime()
	self.Size = self.MaxSpriteSize * self.Resize^( 0.15 )
	
	if self.Alpha <= 0 then return false end
	return true

end

function EFFECT:Render()

	self.Color = colorutil.Rainbow( 150 )

	local Pos = self.Entity:GetPos() + ( self.Norm or 1 ) * -5 * ( self.Resize^( 0.3 ) ) * 0.8

	render.SetMaterial( matLight )
	render.DrawQuadEasy( Pos, ( self.Norm or 1 ), self.Size, self.Size, Color( self.Color.r, self.Color.g, self.Color.b, self.Alpha ) )

	local Distance = EyePos():Distance( self.Entity:GetPos() )
	local Pos2 = self.Entity:GetPos() + ( EyePos()-self.Entity:GetPos() ):GetNormal() * Distance * ( self.Resize^( 0.3 ) ) * 0.8

	render.SetMaterial( matLight2 )
	render.DrawQuadEasy( Pos2, ( self.Norm or 1 ), self.Size, self.Size, Color( self.Color.r, self.Color.g, self.Color.b, self.Alpha ) )

end