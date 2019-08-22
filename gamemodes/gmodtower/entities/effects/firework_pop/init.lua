
// pretty much a modified version of Team Garry's balloon pop effect!
// precache sounds.
util.PrecacheSound( "weapons/explode3.wav" )
util.PrecacheSound( "weapons/explode4.wav" )
util.PrecacheSound( "weapons/explode5.wav" )

function EFFECT:Init( data )
	local origin = data:GetOrigin( )
	local color = data:GetStart( )

	local sound = "weapons/explode" .. math.random( 3, 5 ) .. ".wav"
	--WorldSound( sound, origin, 60, 200 )
	self:EmitSound( sound, 60, 200, 1, CHAN_AUTO )

	local count = math.random( 20, 35 )

	local emitter = ParticleEmitter( origin, true )

	for i = 0, count do

		local dir = Vector( math.Rand( -1, 1 ) , math.Rand( -1, 1 ) , math.Rand( -1, 1 ) )
		local particle = emitter:Add( "particles/balloon_bit" , origin + dir * 8 )
		
		if particle then

			particle:SetVelocity( dir * math.random( 300, 500 ) )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( math.random( 5, 8 ) )
			particle:SetStartAlpha( math.random( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			local size = math.Rand( 1, 3 )
			particle:SetStartSize( size )
			particle:SetEndSize( size )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -2, 2 ) )
			particle:SetAirResistance( math.random( 300, 450 ) )
			particle:SetGravity( Vector( 0, 0 , -math.random( 270, 320 ) ) )
			particle:SetColor( color.r, color.g, color.b )
			particle:SetCollide( true )
			particle:SetAngleVelocity( Angle( math.Rand( -160, 160 ) , math.Rand( -160, 160 ) , math.Rand( -160, 160 ) ) )
			particle:SetBounce( 1 )
			particle:SetLighting( false )
	
		end

	end

	emitter:Finish()
end

function EFFECT:Think( ) return false end
function EFFECT:Render( ) end