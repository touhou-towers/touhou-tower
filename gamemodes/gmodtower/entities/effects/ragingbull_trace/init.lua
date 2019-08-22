

-----------------------------------------------------
EFFECT.Mat = Material( "effects/spark" )

function EFFECT:Init( data )
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Dir 		= self.EndPos - self.StartPos
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.TracerTime = 0.1
	self.DieTime = CurTime() + self.TracerTime

	sound.Play( Sound("weapons/fx/rics/ric4.wav"), self.StartPos, 80, math.random( 110, 180 ) )
end

function EFFECT:Think()
	if ( CurTime() > self.DieTime ) then return false end
	return true
end

function EFFECT:Render()
	local fDelta = (self.DieTime - CurTime()) / self.TracerTime
	fDelta = math.Clamp( fDelta, 0, 1 )

	render.SetMaterial( self.Mat )

	local sinWave = math.sin( fDelta * math.pi )

	render.DrawBeam( self.EndPos - self.Dir * (fDelta - sinWave * 0.3 ), 		
					 self.EndPos - self.Dir * (fDelta + sinWave * 0.3 ),
					 2 + sinWave * 8,					
					 1,					
					 0,				
					 color_white )
end
