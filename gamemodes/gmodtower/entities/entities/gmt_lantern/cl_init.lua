
include('shared.lua')

ENT.Brightness = 2
ENT.Alpha = 255

function ENT:Initialize()

	self.PixVis = util.GetPixelVisibleHandle()

end

function ENT:Draw()

	self.Entity:DrawModel()

end

function ENT:Think()

	if !self:isOn() then return end

	self.LightPos = self:GetPos()

	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		dlight.Pos = self:GetPos() 
		dlight.r = 255
		dlight.g = 225
		dlight.b = 125
		dlight.Brightness = self.Brightness
		dlight.Decay = 1024
		dlight.Size = 256
		dlight.DieTime = CurTime() + 1
	end

end

function ENT:DrawTranslucent()

	self.BaseClass:DrawTranslucent()

	--render.SetMaterial( Material("sprites/splodesprite") )

	self.R, self.G, self.B = self:GetColor()

	self.Visible = util.PixelVisible( self.LightPos, 4, self.PixVis )

	if !self.Visible then return end

	if !self:isOn() then

		render.DrawSprite( self.LightPos, 16, 16, Color(40, 40, 40, 255 * self.Visible) )
		return

	end

	render.DrawSprite( self.LightPos, 8, 8, Color(255, 255, 255, self.Alpha), self.Visible )
	render.DrawSprite( self.LightPos, 32, 32, Color( self.R, self.G, self.B, 64 ), self.Visible )

end

function ENT:isOn()
	return self.On
end

function ENT:EnableLamp(isOn)
	self.On = isOn
end

usermessage.Hook("ToggleLamp", function(um)
		local ent = um:ReadEntity()
		if !IsValid(ent) then return end
		ent:EnableLamp(um:ReadBool())
	end)
