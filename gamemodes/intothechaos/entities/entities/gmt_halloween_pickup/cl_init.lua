
include( "shared.lua" )

ENT.Color = nil
ENT.SpriteMat = Material( "sprites/powerup_effects" )

surface.CreateFont( "HalloweenFont", {
	font = "Kerberos Fang",
	size = 128,
	weight = 500,
	antialias = true,
	italic = true,
} )

function ENT:Initialize()
    timer.Simple(1,function()
      if IsValid(self) then
        self.NextParticle = CurTime()
        self.Emitter = ParticleEmitter( self:GetPos() )
        self.OriginPos = self:GetPos()
      end
    end)
end

function ENT:Draw()

    if !self.OriginPos then return end

    self.Color = colorutil.Rainbow( 75 )

    render.SetMaterial( self.SpriteMat )
    render.DrawSprite( self:GetPos(), 50, 50, self.Color )

    local FloatingOffset = Vector( 0, 0, ( math.sin( CurTime() * 2 ) * 2 ) )

    self:SetPos( self.OriginPos + FloatingOffset + Vector(0,0,30) )

    local rot = self:GetAngles()
    rot.y = rot.y + 90 * FrameTime()

    self:SetAngles( rot )
    cam.Start3D2D( self:GetPos() + Vector(0,0,25) + FloatingOffset, Angle( math.sin( CurTime() * 2 ) * 2, LocalPlayer():EyeAngles().y - 90, 90 ), 0.1 )
      draw.DrawText("GEAR",
      "HalloweenFont",
      0,
      0,
      Color( 255, 255, 255, 255 ),
      TEXT_ALIGN_CENTER)
    cam.End3D2D()

    self:DrawModel()

end
