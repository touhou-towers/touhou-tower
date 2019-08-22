

-----------------------------------------------------
EFFECT.Mat = Material( "trails/smoke" )

function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()

	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.TracerTime = 2
	self.DieTime = CurTime() + self.TracerTime
end

function EFFECT:Think()
	if ( CurTime() > self.DieTime ) then return false end
	return true
end

function EFFECT:Render()
	local fadeout = ( self.DieTime - CurTime() ) / self.TracerTime
	local color = Color( 255, 255, 255 )
	color.a = math.Clamp( fadeout * 255, 0, 255 )
	
	render.SetMaterial( self.Mat )
	
	render.DrawBeam( self.StartPos, 		
					self.EndPos,
					2,					
					.5,					
					0,				
					color )
end