ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:StartTouch( ply )

	if ply:GetClass() != "player_ball" then return end

	if self.Effect then
	local sfx = EffectData()
		sfx:SetOrigin( ply:GetPos() )
	util.Effect( self.Effect, sfx )
else
	local sfx = EffectData()
		sfx:SetOrigin( ply:GetPos() )
	util.Effect( "confetti", sfx )
end

end

function ENT:EndTouch( ply )
end

function ENT:Touch()
end

function ENT:KeyValue( key, value )
	if key == "effect" then
		self.Effect = value
	end
end

function ENT:AcceptInput( input, activator, ply )

end
