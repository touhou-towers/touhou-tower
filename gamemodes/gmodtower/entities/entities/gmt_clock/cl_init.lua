
include('shared.lua')

surface.CreateFont( "clock",{ font = "Trebuchet", size = 30, weight = 800, antialias = true, additive = false })

function ENT:Draw()

	self:DrawModel()
	
	local pos = self:GetPos() - ( self:GetForward() * 4.50 ) - ( self:GetRight() * 1.25 ) - ( self:GetUp() * -3.4 )
	--local scale = math.Clamp(LocalPlayer():EyePos():Distance(pos) / 6048, 0.055, 0)
	local dist = LocalPlayer():EyePos():Distance(pos)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 180)

	--if scale == 0.055 then
	if dist < 1000 then
		cam.Start3D2D(pos, ang, 0.055)

			draw.DrawText(os.date("%I:%M %p"), "clock", -140, -68, Color(200, 235, 255, 200))
	
		cam.End3D2D()
	end
end