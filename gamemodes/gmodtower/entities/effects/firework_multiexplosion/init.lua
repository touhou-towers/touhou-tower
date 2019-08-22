
function EFFECT:Init(data)

	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local em = ParticleEmitter( pos )

	local color = data:GetStart()
	local color2 = self:GetRandomColor()

	local maxParts = 500

	for i = 1, maxParts do

		local pt = em:Add( "sprites/powerup_effects", pos + norm * math.random( 0, 32 ) + VectorRand() * math.random( 4, 6 ) )
		pt:SetVelocity( VectorRand():GetNormal() * 700 )
		pt:SetDieTime( 5 )

		if i < ( maxParts / 2 ) then

			pt:SetAirResistance( 150 )
			pt:SetStartSize( 30 )
			pt:SetColor( color.r, color.g, color.b )

		else

			pt:SetAirResistance( 125 )
			pt:SetStartSize( 20 )
			pt:SetColor( color2.r, color2.g, color2.b )

		end

		pt:SetStartAlpha( 255 )
		pt:SetEndAlpha( 0 )
		pt:SetEndSize( 8 )
		--pt:VelocityDecay( false )
		pt:SetGravity( Vector( 0, 0, -50 ) )

	end

	em:Finish()

end

function EFFECT:Think() return false end
function EFFECT:Render() end

function EFFECT:GetRandomColor()

	local rand = math.Rand( 0, 6 )
	local color = Color( math.random( 125, 255 ), math.random( 125, 255 ), math.random( 125, 255 ) )
	if rand == 1 then
		color = Color( math.random( 125, 255 ), math.random( 30, 80 ), math.random( 30, 80 ) )
	elseif rand == 2 then
		color = Color( math.random( 30, 80 ), math.random( 125, 255 ), math.random( 30, 80 ) )
	elseif rand == 3 then
		color = Color( math.random( 30, 80 ), math.random( 30, 80 ), math.random( 125, 255 ) )
	elseif rand == 4 then
		color = Color( math.random( 30, 80 ), math.random( 125, 255 ), math.random( 125, 255 ) )
	elseif rand == 5 then
		color = Color( math.random( 125, 255 ), math.random( 30, 80 ), math.random( 125, 255 ) )
	elseif rand == 6 then
		color = Color( math.random( 125, 255 ), math.random( 125, 255 ), math.random( 30, 80 ) )
	end

	return color

end
