

-----------------------------------------------------
EFFECT.Mat = Material( "gmod_tower/pvpbattle/toyzap" )

function EFFECT:Init( data )
	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()
	self.Alpha = 255
end

function EFFECT:Think( )
	self.Alpha = self.Alpha - FrameTime() * 2048

	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )

	if (self.Alpha < 0) then return false end
	return true
end

function EFFECT:Render( )
	if ( self.Alpha < 1 ) then return end

	self.Length = (self.StartPos - self.EndPos):Length()
		
	render.SetMaterial( self.Mat )
	local texcoord = math.Rand( 0, 1 )
	for i=1, 6 do
		render.DrawBeam( self.StartPos, self.EndPos, 8, texcoord, texcoord + self.Length / 128, Color( 255, 255, 255, self.Alpha ) )
	end
end