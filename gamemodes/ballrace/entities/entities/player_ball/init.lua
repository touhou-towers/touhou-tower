AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include("shared.lua")

function ENT:SphereInit(r)
	self:PhysicsInitSphere(r)

	local phys = self:GetPhysicsObjectNum(0)
	phys:SetMass(100)
	phys:SetDamping( 0.05, 1 )
	phys:SetBuoyancyRatio(0.5)

	self:StartMotionController()
end

function ENT:Initialize()

	self:SetCustomCollisionCheck( true )

	local ply = self:GetOwner()

	self.radius = 44

	self:SphereInit(self.radius)

	if ply.ModelSet == nil then
		self:SetModel( self.Model )
	else
		self:SetModel( ply.ModelSet )
	end

	self.links = {}
end

    function ENT:Think()
        -- By forcing a physics update, we can ensure PhysicsSimulate is called every tick
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()

            -- If we're stuck, auto kill the player
            if phys:GetStress() > 1000 then
                local ply = self:GetOwner()
                if not IsValid(ply) then return end
                -- ply:Kill()
            end
        end
    end

function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 100 && data.DeltaTime >= 1 then
		local edata = EffectData()
		edata:SetOrigin(data.HitPos)
		edata:SetNormal(data.HitNormal * -1)
		util.Effect("ball_hit", edata)
	end
end

function ENT:PhysicsSimulate( phys, deltatime )
	local ply = self:GetOwner()

	if !IsValid(ply) then return SIM_NOTHING end

	local vMove = Vector(0,0,0)
	local vAngle = Vector(0,0,0)
	local aEyes = ply:EyeAngles()

	local mass = phys:GetMass()
	local velocity = phys:GetVelocity()
	local anglevel = phys:GetAngleVelocity()

	if velocity:Length() >= 3000 then
		ply:SetAchivement( ACHIVEMENTS.BRSPEEDSTER, 1 )
	end

	if ( ply:KeyDown( IN_FORWARD ) ) then vMove = vMove + aEyes:Forward() end
	if ( ply:KeyDown( IN_BACK) ) then vMove = vMove - aEyes:Forward() end
	if ( ply:KeyDown( IN_MOVELEFT ) ) then vMove = vMove - aEyes:Right() end
	if ( ply:KeyDown( IN_MOVERIGHT ) ) then vMove = vMove + aEyes:Right() end

	vMove.z = 0;

	if vMove:Length() > 0 then
		local dir = vMove:GetNormal()

		local dot = 1 - dir:Dot(velocity:GetNormal())

		vMove = dir * mass * 20000 * deltatime

		vMove = vMove + (vMove * dot)

	elseif math.abs(velocity.z) <= 10 then

		velocity.z = 0

		local length = velocity:Length()
		velocity:Normalize()

		vMove = velocity * -length * 200 * (1 - deltatime)
	end

	vMove = self:ApplyRepellers(phys, deltatime, vMove)

	return vAngle, vMove, SIM_GLOBAL_FORCE

end

local repellers
function ENT:ApplyRepellers(phys, deltatime, vMove)
	//if !repellers then
		local repellers = ents.FindByClass("repeller")
	//end

	for k,v in pairs(repellers) do
		local diff = (phys:GetPos() - v:LocalToWorld(v:OBBCenter()))
		local dist = diff:Length()
		local scaledist = dist / 100

		if dist < v.Radius then
			if !self.links[v] then
				self:LinkWithRepeller(v)
			end

			diff:Normalize()

			if v.Repel <= 0 then
				diff = diff * -1
			end

			local accel = v.Power * phys:GetMass() / (scaledist * scaledist)
			vMove = vMove + (diff * accel)

		elseif self.links[v] then
			self:LinkWithRepeller(v)
		end
	end

	return vMove
end

function ENT:LinkWithRepeller(repel)
	if self.links[repel] then
		self.links[repel] = false
	else
		self.links[repel] = true
	end

	umsg.Start("br_electrify")

	umsg.Entity(repel)
	umsg.Entity(self)

	umsg.Bool(self.links[repel])

	umsg.End()
end
