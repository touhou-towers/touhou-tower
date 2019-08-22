
local VecRight = Vector( 0 , 1 , 0 )
local VecUp = Vector( 0 , 0 , 1 )

function EFFECT:Init( data )

	local life = 3
	local life_low = ( life * 0.8 ) * 10
	local life_high = ( life * 1.2 ) * 10
	local angle = Angle( 0, 0, 0 )
	local pos = data:GetOrigin()

	self.Leaves = {}
	self.Color = data:GetStart()
	self.Emitter = ParticleEmitter( pos )

	for i = 1, 100 do

		local spin = math.random( 0, 360 )
		local dir = Vector(
			math.cos( spin ),
			math.sin( spin ),
			math.random( 4, 10 )
		):Angle()

		table.insert( self.Leaves, {
			dir = dir,
			speed = math.random( 1, 3 ),
			pos = pos,
			dietime = CurTime() + ( math.random( life_low, life_high ) * 0.1 )
		} )

	end

	local pitch = angle.p
	local yaw = angle.y
	local PartSpawnPos = pos + Vector( 0, 0, -150 )

	for i = 1, 300 do

		local rot = math.rad( ( 360 / 300 ) * i )

		local dir = Vector(
			math.cos( rot ),
			math.sin( rot ),
			0
		):Angle()

		dir:RotateAroundAxis( VecRight , pitch )
		dir:RotateAroundAxis( VecUp , yaw )

		dir = dir:Forward()

		local particle = self.Emitter:Add( "effects/spark", PartSpawnPos )
		particle:SetVelocity( dir * 200 )
		particle:SetDieTime( math.random( life_low, life_high ) * 0.1 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 30 )
		particle:SetEndSize( 0 )
		particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
		particle:SetStartLength( 24 )
		particle:SetEndLength( 40 )
		particle:SetAirResistance( 150 )
		--particle:VelocityDecay( false )
		particle:SetGravity( dir * 25 + Vector( 0 , 0 , -math.random( 50, 80 ) ) )

	end

end

function EFFECT:Think()

	local keepalive = false

	for _, v in pairs( self.Leaves ) do

		if v.dietime > CurTime() then

			v.dir.p = math.ApproachAngle( v.dir.p, 90, math.random( 1, 2 ) )

			v.pos = v.pos + ( v.dir:Forward() * v.speed )

			local lifeleft = ( v.dietime - CurTime() ) * 0.5
			local life_low = ( lifeleft * 0.8 )
			local life_high = ( lifeleft * 1.2 )

			local particle = self.Emitter:Add( "particles/flamelet" .. math.random( 1 , 5 ), v.pos )
			particle:SetVelocity( v.dir:Forward() * 20 )
			particle:SetDieTime( math.random( life_low, life_high ) )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 30 )
			particle:SetEndSize( 0 )
			particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
			particle:SetStartLength( 2 )
			particle:SetEndLength( 64 )
			particle:SetCollide( true )
			--particle:VelocityDecay( false )
			particle:SetAirResistance( 60 )
			particle:SetGravity( Vector( 0, 0, -math.random( 100, 200 ) ) )

			keepalive = true

		end

	end

	if !keepalive then

		self.Emitter:Finish()
		return false

	end

	return true

end

function EFFECT:Render() end
