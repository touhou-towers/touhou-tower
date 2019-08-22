
-----------------------------------------------------
function EFFECT:Init(data)
	
	local maxParts = 100
	local pos = data:GetOrigin()
	local em = ParticleEmitter( pos )

	for i = 1, maxParts do

		local color = colorutil.GetRandomColor()

		local pt = em:Add( "sprites/powerup_effects", pos )
		pt:SetVelocity( VectorRand():GetNormal() * 150 )
		pt:SetDieTime( 1 )
		pt:SetAirResistance( 100 )
		pt:SetStartAlpha( 255 )
		pt:SetEndAlpha( 0 )
		pt:SetStartSize( 8 )
		pt:SetEndSize( 0 )
		pt:SetColor( color.r, color.g, color.b )
		pt:SetGravity( Vector( 0, 0, -50 ) )

	end

	em:Finish()
	em = nil

end

function EFFECT:Think() return false end
function EFFECT:Render() end