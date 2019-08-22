
-----------------------------------------------------
include('shared.lua')

ENT.MatBeam		= Material( "cable/blue_elec" )
ENT.Sprite 		= Material( "sprites/powerup_effects" )

function ENT:Initialize()

	self:SetRenderBoundsWS( self:GetPos(), self:GetPos(), Vector() * 2048 )

end

function ENT:Draw()

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	local kart = owner:GetKart()
	if !IsValid( kart ) then return end
	if !kart:IsVisible() then return end
	if !IsValid( kart.ClientModel ) then return end

	self:DrawModel()

	// Offset
	self:SetPos( kart.ClientModel:GetPos() + kart:GetUp() * 48 )

	// Main sprite
	local scale = SinBetween( 1.25, 1.5, RealTime() * 2 )
	local size = scale * 64
	render.SetMaterial( self.Sprite )
	render.DrawSprite( self:GetPos() + VectorRand():GetNormal() * 2, size, size, Color( 150, 150, 150, 150 ) )

	// Scale
	self:SetModelScale( scale, 0 )


	local color = Color( 255, 255, 255, 255 )

	for _, ent in pairs( ents.FindByClass( "sk_kart" ) ) do

		if ent == kart then continue end

		local entpos = ent:GetPos()
		local owner = ent:GetOwner()

		if entpos:Distance( kart:GetPos() ) < 2048 then

			color = Color( math.random( 0, 50 ), math.random( 0, 50 ), 255, 255 )

			local pos = entpos
			local length = ( pos - self:GetPos() ):Length()
			local scroll = RealTime() * 3

			// Beam
			render.SetMaterial( self.MatBeam )
			render.DrawBeam( pos,
				self:GetPos(),
				20,
				scroll,
				scroll + length / 256,
				Color( 255, 255, 255, 255 )
			)

			// Sprite
			render.SetMaterial( self.Sprite )
			render.DrawSprite( pos, 250, 250, color )

			local effectdata = EffectData()
				effectdata:SetMagnitude( 2 )
				effectdata:SetEntity( ent )
			util.Effect( "TeslaHitBoxes", effectdata, true, true )

		end

	end

end
