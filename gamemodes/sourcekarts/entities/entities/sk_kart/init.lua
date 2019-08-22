AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_camera.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	--self:SetSolid(SOLID_VPHYSICS)
	--self:PhysicsInit(SOLID_VPHYSICS)
	--self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetMoveCollide(MOVECOLLIDE_FLY_SLIDE)
	--self:SetCollisionGroup(COLLISION_GROUP_VEHICLE)

	self:PhysicsInitBox( Vector(-25,-15,0), Vector(25,15,25) )

	local phys = self:GetPhysicsObjectNum(0)
	phys:SetMass(100)
	--phys:SetDamping( 0.05, 1 )
	phys:Wake()
	phys:SetMaterial("kart") // Kart

	phys:EnableGravity(false)

	self:SetCustomCollisionCheck( true )

	self:DrawShadow(false)
	self:StartMotionController()
	//self:SetFriction( 0.0 )

	self.LastJump = 0
	self.WeightsNWheels = {}

	for k,v in pairs(self.Wheels) do

		local att = self:GetAttachment( self:LookupAttachment( v.Att ) )
		local pos, attang = att.Pos, att.Ang

		local e = ents.Create("sk_wheel")
		e:SetPos(pos)
		e:SetAngles(attang)
		e:SetSize(16*2)
		e:Enable(true)
		e:Spawn()

		table.insert(self.WeightsNWheels,e)

		constraint.Weld( e, self, 0, 0, 0, true, false )
	end

end

function ENT:OnRemove()
    for k,v in pairs( self.WeightsNWheels ) do
			if IsValid(v) then v:Remove() end

		end
end

function ENT:GetDriver()
  return self:GetOwner()
end

function ENT:Think()

	if game.GetMap() == "gmt_sk_island01_fix" && GAMEMODE:GetState() == STATE_BATTLE then

			if self:GetPos().z < 7000 then 
				self:GetOwner():SendLua([[RunConsoleCommand("sk_reset")]])
			end
	end

    local phys = self:GetPhysicsObject()
    if IsValid(phys) and phys:IsAsleep() then
      phys:Wake()
    end

		local tractionNum, tractionType = self:GetTraction()

		if (tractionType != self.OldTraction or !self.OldTraction) then
			self.OldTraction = tractionType
			self:OnMaterialChange( self.OldTraction )
		end

		local ply = self:GetOwner()

		if !IsValid( ply ) then return end

		if ply:KeyDown(IN_MOVELEFT) then
			self:SetTurnAngleNet(-1)
		elseif ply:KeyDown(IN_MOVERIGHT) then
			self:SetTurnAngleNet(1)
		else
			self:SetTurnAngleNet(0)
		end

end

function ENT:OnMaterialChange( mat )
	// Checks for boost pads

	if !self.PrevMat then self.PrevMat = mat end

	local delay = 2

	if game.GetMap() == "gmt_sk_rave" then delay = 1 end

	if mat == "boost" then
		self:SetIsBoosting( true )
	elseif mat != "boost" && self.PrevMat == "boost" then
		timer.Simple(delay,function()
			self:SetIsBoosting( false )
		end)
	end

	self.PrevMat = mat

end

function ENT:PhysicsCollide( data, collider )
    local ent = data.HitEntity

		local ply = self:GetOwner()

		local it = ply:GetActiveItem()

		if it != nil then
			it = ply:GetActiveItem().Name
		end

		if it == nil then return end

		if it != "Disco" then return end

		if !IsValid(ply) then return end

		if self:IsGhost() then return end

		if ent:GetClass() == "sk_kart" then
			if !self.HitDelay then self.HitDelay = 0 end

			if CurTime() < self.HitDelay then return end

			self.HitDelay = CurTime() + 1

			if GAMEMODE:IsBattle() then
				ent:GetOwner():TakeBattleDamage( self:GetOwner() )
			end

			ent:EmitSound( SOUND_REFLECT, 80 )
			ent:Spin( self:GetOwner() )
			net.Start( "HUDMessage" )
				net.WriteString( "YOU HIT "..string.upper( ent:GetOwner():Name() ) )
			net.Send( self:GetOwner() )

		elseif ent:GetClass() == "player" then
			if !self.HitDelay then self.HitDelay = 0 end

			if CurTime() < self.HitDelay then return end

			self.HitDelay = CurTime() + 1
			ent:GetKart():EmitSound( SOUND_REFLECT, 80 )

			if GAMEMODE:IsBattle() then
				ent:SetDeaths( ent:Deaths() + 1 )
				ent:GetKart():SetIsGhost( true )
				ent:GetKart():SetIsInvincible( true )
				timer.Simple(3,function()
					ent:GetKart():SetIsGhost( false )
					ent:GetKart():SetIsInvincible( false )
				end)
			end

			ent:GetKart():Spin( self:GetOwner() )
			net.Start( "HUDMessage" )
				net.WriteString( "YOU HIT "..string.upper( ent:Name() ) )
			net.Send( self:GetOwner() )
		end

end

function ENT:IsSpinning()
	return (self.Spinning or false)
end

function ENT:Spin( ply, hitSelf )
	net.Start( "KartSpin" )
		net.WriteEntity( self )
	net.Broadcast()

	if IsValid(ply) then

		ply:AddAchivement( ACHIVEMENTS.SKHITPOWERUP, 1 )
		self:GetOwner():AddAchivement( ACHIVEMENTS.SKPOWERUP, 1 )

		if !hitSelf then
			net.Start( "HUDMessage" )
				net.WriteString( "YOU HAVE BEEN HIT BY "..string.upper( ply:Name() ) )
			net.Send( self:GetOwner() )
		end

	end

	self.Spinning = true

	timer.Simple(1.5,function()
		self.Spinning = false
	end)

end

function ENT:Boost( power, time )

	if timer.Exists( "BoostTimer" .. tostring( self:EntIndex() ) ) then
		timer.Adjust( "BoostTimer" .. tostring( self:EntIndex() ), time, 1,function()
			self:SetIsBoosting( false )
		end)
		return
	end

	self:SetIsBoosting( true )

	timer.Create( "BoostTimer" .. tostring( self:EntIndex() ), time, 1, function()
		self:SetIsBoosting( false )
	end)

end

function ENT:UpdateHookedValue( key, Val )

	local Owner = self:GetOwner()

	if (IsValid( self ) && IsValid( Owner )) then

		if self.Settings && self.Settings[ key ] then
			Val = self.Settings[ key ]
		end

		if Owner.PowerupHooks then
			for k, powerup in pairs( Owner.PowerupHooks ) do

				if IsValid(powerup) then
					local NewVal = powerup:SettingHook( Owner, key, Val )

					if NewVal then
						Val = NewVal
					end
				else
					Owner.PowerupHooks[ k ] = nil
				end

			end
		end

	end

	return Val


end

function ENT:GetSetting( key )
	--return self:UpdateHookedValue( key, self.Settings[ key ][1] )
	if self.Settings && self.Settings[ key ] then
		Val = self.Settings[ key ]
	end

	return Val[1]
end

module("KartPhysics", package.seeall )

function ENT:StartDrift()

	self:SetNWBool( "Drifting", true )
	self:SetIsDrifting( true )
	self:SetDriftStart( CurTime() )

	self.DriftData = {
		MoveLeft = self:GetDriver():KeyDown(IN_MOVELEFT),
		TurnValue = self.CarPhysics.PlayerAngularAccel
		//MoveRight = CarPhysics.Driver:KeyDown(IN_MOVERIGHT)
	}

	self.CarPhysics.PlayerAngularAccel = self.DriftData.TurnValue * self:GetSetting("DriftingJumpPower")

end

function ENT:EndDrift()

	self:SetNWBool( "Drifting", false )
	self:SetIsDrifting( false )

	if !self:InDrift() then
		return
	end

	//Make the player rotate back to it's original angle
	self.CarPhysics.PlayerAngularAccel = self.DriftData.TurnValue * -self:GetSetting("DriftingJumpPower")

	self.DriftData = nil

	local time = CurTime() - self:GetDriftStart()


	local DriftTimes = {
		0.25,
		0.5,
		1,
	}

	local DriftLevel = 0

		if time >= self.DriftLevels[1] then

			DriftLevel = 1
		end
		if time >= self.DriftLevels[2] then

			DriftLevel = 2
		end
		if time >= self.DriftLevels[3] then

			DriftLevel = 3
		end


		if DriftLevel == 0 then return end

		self:SetIsBoosting( true )

		timer.Simple( DriftTimes[ DriftLevel ], function()
			self:SetIsBoosting( false )
		end)

	--self:GetOwner():ChatPrint( tostring( "FIRE: " .. time .. " DRIFT LEVEL: " .. DriftLevel .. " DRIFT TIME: "..DriftTimes[ DriftLevel ] ) )

end

function ENT:InDrift()
	return self.DriftData != nil
end

function ENT:CanKeepDrift()

	if !self:InDrift() then
		return
	end

	if !self:GetDriver():KeyDown(IN_FORWARD) then
		return false
	end

	if !self:GetDriver():KeyDown(IN_JUMP) then
		return false
	end

	/*if self.DriftData.MoveLeft then
		if !self:GetDriver():KeyDown(IN_MOVELEFT) then
			return false
		end
	else
		if !self:GetDriver():KeyDown(IN_MOVERIGHT) then
			return false
		end
	end*/

	return true

end

function ENT:DriftPhysicsSimulate()

	if !self:InDrift() then
		return
	end

	self.CarPhysics.TargetVel = (self.CarPhysics.TargetVel / 3.5)

	if self.DriftData.MoveLeft then
		self.CarPhysics.TargetVel:Rotate( Angle(0,-45,0) )
	else
		self.CarPhysics.TargetVel:Rotate( Angle(0,45,0) )
	end

	local testval = self:GetTurnYaw(self:GetOwner())

	if testval > 0 then

		if self.DriftData.MoveLeft then
			testval = 0.75
		else
			testval = 0.25
		end

	elseif testval < 0 then

		if self.DriftData.MoveLeft then
			testval = 0.25
		else
			testval = 0.75
		end

	end

	local Yaw = self.DriftData.TurnValue * self:GetSetting("DriftingYawPower") * testval

	-- Do angle changing stuff.
	local AngleVel = self.CarPhysics.Phys:GetAngleVelocity()
	local AngleFriction = AngleVel * -0.2
	local Angular = (AngleFriction + Vector(0, 0, Yaw)) * self.CarPhysics.DeltaTime * 1000

	self.CarPhysics.TargetAngular = Angular

	return true

end

function ENT:GetEndAccel( )

	//self.CarPhysics.TargetAngular = Vector(0,0,0)
	//self.CarPhysics.TargetVel = Vector(400,0,0)

	//print( self.CarPhysics.TargetVel, "\t",  self.CarPhysics.TargetAngular)
	if self:GetIsEngineOn() && !self:IsSpinning() then
		return self.CarPhysics.TargetAngular, self.CarPhysics.TargetVel, SIM_LOCAL_ACCELERATION
	end

	return nil, nil, SIM_NOTHING

end

function ENT:PhysicsSimulate(phys, DeltaTime)

	local angle = phys:GetAngles()
	local Driver = self:GetDriver()
	local Trace = util.QuickTrace( self:GetPos() + Vector(0,0,2), Vector(0,0,-128), {Driver, self} )

	local Velocity = phys:GetVelocity()
	local RightVel = angle:Right():Dot(Velocity)
	local ForwardVel = angle:Forward():Dot(Velocity)

	self.CarPhysics = {
		Phys = phys, //The actual car physics
		Driver = Driver, //The player entity
		DeltaTime = DeltaTime,
		Angle = angle, //Physics angles
		Up = angle:Up(), //Up velocity Vector
		Right = angle:Right(), //Right velocity Vector
		Forward = angle:Forward(), //Forward velocity vector
		Velocity = Velocity, //The car actual velocity
		RightVel = RightVel,
		ForwardVel = ForwardVel,
		GroundTrace = Trace, //A trace being fired directly below the player
		TargetAngular = Vector(0,0,0), //Anglar velocity
		TargetVel = Vector(0,0, -600 ), //-12 is the force of gravity pulling it down
		PlayerForwardAccel = self:GetForwardAcceleration( Driver ), //Depended on keys W/S, how much force to apply forward or backwards
		PlayerAngularAccel = self:GetTurnYaw( Driver ) //Depended on keys A/D, how much force to apply for rotation
	}

	local Trac, MatType = self:GetTraction()

	//Make sure the player is parallel to the floor
	if (self:FixUpRight() && MatType != "surface" && MatType != "lava" ) then

		/*if !self.UpRightDieTime then
			//The player has 3 seconds to fix himself, before being sent to a safe point
			self.UpRightDieTime = CurTime() + 3.1

		elseif CurTime() > self.UpRightDieTime then

			Driver:SendSafePoint()
			self.UpRightDieTime = nil

			return nil, nil, SIM_NOTHING

		end*/

		//If we can keep the player upright
		self:GetUpRight()
		local AngleVel = phys:GetAngleVelocity()
		local AngleFriction = AngleVel * - self:GetSetting("TurnFricton")
		self.CarPhysics.TargetAngular = (AngleFriction + Vector(0, 0, self.CarPhysics.PlayerAngularAccel)) * DeltaTime * 1000
		return self:GetEndAccel()

	end

	self.CarPhysics.TargetVel = self:GetLinearForward()

	//Do not save the variable, keep the timer reset
	if self.ResetPosUpsideDown then
		self.ResetPosUpsideDown = nil
	end


	if self:InDrift() then

		if !self:CanKeepDrift() then
			self:EndDrift()

		elseif self:DriftPhysicsSimulate() then
			return self:GetEndAccel()
		end

	elseif Driver:KeyDown(IN_JUMP) then

		if self:CanJump() then
			self:Jump()
		end

	end

	local AngleVel = phys:GetAngleVelocity()
	local AngleFriction = AngleVel * - self:GetSetting("TurnFricton")
	self.CarPhysics.TargetAngular = (AngleFriction + Vector(0, 0, self.CarPhysics.PlayerAngularAccel)) * DeltaTime * 1000

	return self:GetEndAccel()

end

function ENT:Jump()
	self.LastJump = CurTime()

	if math.abs(  self.CarPhysics.PlayerAngularAccel ) > 1 && self.CarPhysics.ForwardVel > 0 then
		self:StartDrift()
	end

end

function ENT:CanJump()
	return CurTime() - self.LastJump > self:GetSetting("JumpWaitTime")
end

function ENT:GetLinearForward()

	//Get the traction rate of the road, multiply it with the general settion

	local Trac, MatType = self:GetTraction()

	local Traction = Trac * self:GetSetting("FrictionFactor") * 10

	//Get the forward velocity and subtract the friction
	local Forward = self.CarPhysics.PlayerForwardAccel - self.CarPhysics.ForwardVel * 0.2 //Traction

	//Just take the right velocity, and multiply it by the friction factor
	local Right = self.CarPhysics.RightVel * self:GetSetting("FrictionRightFactor")

	Forward = self:UpdateHookedValue( "ExtraAccel", Forward )

	local DownForce = self:GetSetting("UpwardForce") * -100

	return Vector(
			Forward,
			Right,
			DownForce
		)
		* self.CarPhysics.DeltaTime
end

function ENT:GetUpRight() //phys, DeltaTime, Driver, up )

	local Angles = self:GetAngles()
	Angles:RotateAroundAxis( Vector(0,0,1), -Angles.y )

	local AngleFriction =  self.CarPhysics.Phys:GetAngleVelocity() * -0.1

	local KeepUprightX, KeepUprightY = 0, 0
	local Yaw = self:GetTurnYaw( self:GetDriver() ) * 2

	if self.CarPhysics.Up.z < 0.9 then
		local Cross = Angles:Up():Cross(Vector(0,0,1))
		KeepUprightX = Cross.x * 380
		KeepUprightY = Cross.y * 380
	end

	self.CarPhysics.TargetAngular  = (AngleFriction + Vector(KeepUprightX, KeepUprightY, Yaw)) * self.CarPhysics.DeltaTime * 1000

	return true //Angular, Vector(0,0,-12), SIM_LOCAL_ACCELERATION

end

function ENT:FixUpRight()

	//Car is too tilted to one way or another
	if( self.CarPhysics.Up.z < 0.88)  then
		//print("Z too low upright")
		return true
	end

	//Player is too far from the floor
	if !self.CarPhysics.GroundTrace || self.CarPhysics.GroundTrace.Fraction > 0.3 then
		//print("Too far!", self.CarPhysics.GroundTrace.Fraction )
		return true
	end

	return false

end

function ENT:GetForwardAcceleration(Driver)

	if self:GetIsBoosting() then
		if self:GetIsDrifting() then
			return self:GetSetting("MaxBoostVel") * 45
		else
			return self:GetSetting("MaxBoostVel") * 4 * 45
		end
	end

	local traction, matType = self:GetTraction()

	if Driver:KeyDown(IN_FORWARD) then

		local pwr = 100

		if (matType == "grass" || matType == "dirt" || matType == "sand" || self.IsFluxxed) then
			pwr = 50
		end

		return self:GetSetting("PowerForward") * pwr //80 * self:GetKartSpeed()
	end
	if Driver:KeyDown(IN_BACK) then
		return self:GetSetting("PowerBackwards") * 100 //-30 * self:GetKartSpeed()
	end
	return 0
end

function ENT:GetTurnYaw(Driver)

	if !self.SmoothSteerL then self.SmoothSteerL = 0 end
	if !self.SmoothSteerR then self.SmoothSteerR = 0 end

	if Driver:KeyDown(IN_MOVELEFT) then
		self.SmoothSteerR = 0
		self.SmoothSteerL = Lerp( 10 * FrameTime() , self.SmoothSteerL , self:GetSetting("TurnPower") )
	elseif Driver:KeyDown(IN_MOVERIGHT) then
		self.SmoothSteerL = 0
		self.SmoothSteerR = Lerp( 10 * FrameTime() , self.SmoothSteerR , self:GetSetting("TurnPower") )
	else
		self.SmoothSteerL = 0
		self.SmoothSteerR = 0
	end

	if Driver:KeyDown(IN_MOVELEFT) then
		return self.SmoothSteerL
	end
	if Driver:KeyDown(IN_MOVERIGHT) then
		return -self.SmoothSteerR
	end
	return 0
end
