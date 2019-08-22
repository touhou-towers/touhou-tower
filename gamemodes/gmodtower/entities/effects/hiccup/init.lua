

-----------------------------------------------------
EFFECT.Mat = Material("effects/bubble")

// hiccup bubbles.
function EFFECT:Init( data )
	local ent = data:GetEntity();
	if !IsValid(ent) then return end

	local pos = ent:GetShootPos();
	if( ent == LocalPlayer() ) then
		pos = pos + ent:GetAimVector() * 24;
	end
	
	// create particle emitter.
	local emitter = ParticleEmitter( pos );
	
	// add particles.
	for i = 1, 16 do
		// create a particle.
		local particle = emitter:Add( "effects/bubble", pos );
		particle:SetVelocity( ( Vector( 0, 0, 1 ) + ( VectorRand() * 0.1 ) ) * math.random( 15, 45 ) );
		particle:SetDieTime( math.random( 0.5, 1.5 ) );
		particle:SetStartAlpha( 255 );
		particle:SetEndAlpha( 0 );
		particle:SetStartSize( 4 );
		particle:SetEndSize( 0.1 );
		particle:SetRoll( 0 );
		particle:SetRollDelta( 0 );
		particle:SetColor( 255, 255, 255 );
	end
	
	// finalize te emitter.
	emitter:Finish();
end

// think
function EFFECT:Think( )

	return false;
	
end

// render.
function EFFECT:Render( )
end
