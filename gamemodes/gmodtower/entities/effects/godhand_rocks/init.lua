
function EFFECT:Init(data)
	self.DieTime = CurTime() + 0.25

	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()



	local vBounds = Vector(6, 6, 6)
	local vNBounds = Vector(-6, -6, -6)
	for i=1, math.random(5, 8) do
		local dir = ((normal * 2 + VectorRand()) * 0.3333333)
		local ent = ClientsideModel("models/props_debris/concrete_spawnchunk001a.mdl", RENDERGROUP_OPAQUE)
		ent:SetPos(pos + dir * 16)
		ent:PhysicsInitBox(vNBounds, vBounds)
		ent:SetCollisionBounds(vNBounds, vBounds)
		ent:GetPhysicsObject():SetMaterial("rock")
		ent:GetPhysicsObject():ApplyForceOffset(ent:GetPos() + VectorRand() * 5, dir * math.Rand(300, 800))
		timer.Simple(math.Rand(4, 6), function()
			ent.Remove( ent)
		end)
	end

	local ang = normal:Angle()
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end


function EFFECT:Render()
end
