
local LifeLength = 1.2
local FONT = "GTowerSkyMsgSmall"

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	self.Pos = data:GetOrigin()
	self.EndLife = CurTime() + LifeLength
	self.Value = math.ceil( data:GetMagnitude() )
	
	self:SetRenderBounds( Vector(16,16,16), Vector(-16,-16,-16)  )
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	return self.EndLife > CurTime()

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	
	local ang = Angle(0,90,0)
	local pos = self.Pos
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	if (LocalPlayer():EyePos() - pos ):DotProduct( ang:Up() ) < 0 then
		ang:RotateAroundAxis( ang:Right(), 180 )
	end
	
	cam.Start3D2D( pos, ang, 0.45 )
		surface.SetFont( FONT )
		surface.SetTextColor( 0, 255, 0, math.max( (self.EndLife-CurTime()) * 255, 0 ) )
		
		local w, h = surface.GetTextSize( "+" .. tostring( self.Value ) )
		
		surface.SetTextPos( -w/2, -h/2 )
		surface.DrawText(  "+" .. tostring( self.Value ) )
	cam.End3D2D()

end
