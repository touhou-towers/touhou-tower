
function EFFECT:Init( data )
	local pos = data:GetOrigin()
	local emitter = ParticleEmitter( pos )

	for i=1,math.random(10,15) do
		local particle = emitter:Add( "particles/smokey", pos )

		particle:SetVelocity(Vector(math.random(-60, 60),math.random(-60, 60), math.random(-60, 60)))
		particle:SetDieTime( math.random(15,20)/10 )
		particle:SetStartAlpha( math.Rand( 60, 125 ) )
		particle:SetEndAlpha(1)
		particle:SetStartSize( math.Rand( 10, 20 ) )
		particle:SetEndSize( math.Rand( 30, 40 ) )
		particle:SetRoll( math.Rand( -360, 360 ) )
		particle:SetRollDelta( math.Rand( -0.1, 0.1 ) )
		particle:SetColor( 190,190,255 )

		emitter:Finish()
	end
	
	for i=0,math.random(6,12) do
		local emitter = ParticleEmitter(pos)
		local particle = emitter:Add("effects/fleck_glass"..math.random(1,3).."", pos )
		particle:SetVelocity( Vector(math.random(-200,200),math.random(-200,200),math.random(200,300)) )
		particle:SetDieTime(math.random(35,45)/10)
		particle:SetStartAlpha(math.random(140,220))
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.random(2,3))
		particle:SetEndSize(0)
		particle:SetRoll(math.random(-200,200))
		particle:SetRollDelta( math.random( -1, 1 ) )
		particle:SetColor( 150,150,255 )
		particle:SetGravity(Vector(0,0,-520)) //-600 is normal
		particle:SetCollide(true)
		particle:SetBounce(0.55) 
		emitter:Finish()
	end
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end