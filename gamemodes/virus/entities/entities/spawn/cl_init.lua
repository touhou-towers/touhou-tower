include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local GlowMat = Material( "sprites/light_glow02_add" )

function ENT:Draw()

	self:DrawShadow( false )

	local R = 82 
	local G = 71
	local B = 180

	if self:GetOwner().IsVirus then
		R = 69
		G = 165
		B = 82
	end
	
	if !IsValid( self:GetOwner() ) then
		R = 255
		G = 0
		B = 0
	end
	
	local DLight = DynamicLight( self:EntIndex() )
	if ( DLight ) then

		DLight.Pos = self:GetPos()
		DLight.r = R
		DLight.g = G
		DLight.b = B
		DLight.Brightness = 255
		DLight.Size = 512
		DLight.Decay = 1024
		DLight.DieTime = CurTime() + 1

	end
	
	render.SetMaterial( GlowMat )

	R = R / 255
	G = G / 255
	B = B / 255
	
	for i = 1, 180 do

		local Ang = ( self:EntIndex() + 1337 + CurTime() ) * i //Yeah, random math makes awesome shit!
		local Size = ( 155 - i ) / 1.5
		local Seed1 = self:GetDTFloat( 0 )
		local Seed2 = self:GetDTFloat( 1 )
		local Forward = Angle( Ang * Seed1, Ang * Seed2, 0 ):Forward()
		local Pos = self:GetPos() + Forward * i * 0.2
		local Gray = i / 150 * 255
		Gray = Color( Gray * R, Gray * G, Gray * B, 255 )
		render.DrawSprite( Pos, Size, Size, Gray )

	end

end