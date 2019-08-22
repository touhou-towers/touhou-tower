
-----------------------------------------------------
function EFFECT:Init(data)
	self.DieTime = CurTime() + 0.25

	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()
	
	local vBounds = Vector(12, 12, 12)
	local vNBounds = Vector(-12, -12, -12)
	for i=1, math.random( 5, 8 ) do
		local dir = ( normal + VectorRand() ):GetNormal()
		local ent = ClientsideModel( "models/props_debris/concrete_spawnchunk001a.mdl", RENDERGROUP_OPAQUE )
		ent:SetPos( pos + dir )
		ent:PhysicsInitBox( vNBounds, vBounds )
		ent:SetCollisionBounds( vNBounds, vBounds )
		ent:GetPhysicsObject():SetMaterial( "rock" )
		ent:GetPhysicsObject():ApplyForceOffset( ent:GetPos() + VectorRand(), dir * math.Rand( 5, 10 ) )
		timer.Simple( math.Rand( 4, 6 ), ent.Remove, ent )
	end

	local ang = normal:Angle()
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

function EFFECT:Render()
end