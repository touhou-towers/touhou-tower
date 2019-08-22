include("shared.lua")

surface.CreateFont("TextScreenFont",{
	font = "Apple Kid", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 100,
	weight = 500,
	blursize = 0.25,
	scanlines = 2,
} )

function ENT:Draw()

  self:DrawModel()

  local dx = Vector(50,-1,13) -- position offset
  local dx2 = Vector(50,-1,13) -- position offset
	local da = Angle(0,180,90) -- angle offset
	local scale = 0.25 -- scale

  local w, h = 25

  local x = RealTime() * 250 % w * -1


	if (LocalPlayer():GetPos():Distance(self:GetPos()) > 1880) then return end
	cam.Start3D2D(self:LocalToWorld(dx), self:LocalToWorldAngles(da), scale)
    surface.SetDrawColor(25,25,25,255)
    surface.DrawRect(0,0,395,100)
  cam.End3D2D()
  cam.Start3D2D(self:LocalToWorld(dx2), self:LocalToWorldAngles(da), scale)
    draw.DrawText("test","TextScreenFont",x, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
  cam.End3D2D()
end
