
function EFFECT:Init( data )
	local ent = data:GetEntity()
	if !IsValid(ent) then return end

	local pos = ent:GetPos()
	//local offset = Vector(0,0,40)
	local emitter = ParticleEmitter( pos )
	local BoxCoords = {-15,15,-15,15}
	local coord = Vector(math.random(BoxCoords[1], BoxCoords[2]), math.random(BoxCoords[3], BoxCoords[4]), 64)

	local particle = emitter:Add( "sprites/karpar", pos + coord )
	particle:SetLifeTime( 0 )
	particle:SetDieTime( 5 )
	particle:SetStartAlpha( 200 )
	particle:SetEndAlpha( 0 )
	particle:SetStartSize( 1 )
	particle:SetEndSize( 0 )
	particle:SetCollide( true )
	particle:SetColor( 255,128,64 )
	particle:SetRoll( math.Rand(0, 360) )
	particle:SetRollDelta( math.Rand(-1, 1) )
	particle:SetGravity( Vector(math.random(0, 5), 0, -math.random(15,25)) )
	particle:SetAngleVelocity( Angle( math.Rand( -2, 2 ), math.Rand( -2, 2 ), math.Rand( -2, 2 ) ) ) 

	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render( )
end