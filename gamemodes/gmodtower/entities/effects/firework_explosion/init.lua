
function EFFECT:Init(data)

	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local em = ParticleEmitter( pos )
	local color = data:GetStart()

	local maxParts = 500

	for i = 1, maxParts do

		local pt = em:Add( "sprites/powerup_effects", pos + norm * math.random( 0, 32 ) + VectorRand() * math.random( 4, 6 ) )
		pt:SetVelocity( VectorRand():GetNormal() * 700 )
		pt:SetDieTime( 5 )
		pt:SetAirResistance( 150 )
		pt:SetStartAlpha( 255 )
		pt:SetEndAlpha( 0 )
		pt:SetStartSize( 30 )
		pt:SetEndSize( 8 )
		pt:SetColor( color.r, color.g, color.b )
		--pt:VelocityDecay( false )
		pt:SetGravity(  VectorRand():GetNormal() * 25 + Vector( 0, 0, -50 ) )

	end

	em:Finish()
	em = nil

end

function EFFECT:Think() return false end
function EFFECT:Render() end
