
include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

surface.CreateFont( "PokerText", { font = "Bebas Neue", size = 48, weight = 500 } )

function ENT:Initialize()
	self.Spinning = false
	self.LastTime = CurTime()
	self.FakeRotation = 0
	self.Rotation = 0
	self.Speed = 0
	self.SpinDir = 0
	self.WasPulling = false
	self.P_WheelAngle = 0
	self.P_PaddleAngle = 0
	self.C_WheelAngle = 0
	self.C_PaddleAngle = 0
end

function ENT:PlayClick()
	self:EmitSound( self.SoundClicker, 80, 100 )
end

function ENT:CheckClientsideModels()
	if not IsValid( self.Wheel ) then
		self.Wheel = ClientsideModel( self.ModelSpinner )
	end
	if not IsValid( self.Paddle ) then
		self.Paddle = ClientsideModel( self.ModelPaddle )
	end
end

function ENT:UpdatePositions()
	self.Paddle:SetPos( self:GetPos() + self:GetUp() * 50 )
	self.Wheel:SetPos( self:GetPos() )

	local mat = Matrix()
	mat:Scale( Vector(1,1,.5) )
	self.Paddle:EnableMatrix( "RenderMultiply", mat )
end

function ENT:UpdateAngles(alpha)
	local wheelR = self.C_WheelAngle * alpha + self.P_WheelAngle * (1 - alpha)
	local paddleR = self.C_PaddleAngle * alpha + self.P_PaddleAngle * (1 - alpha)

	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Forward(), wheelR )
	self.Wheel:SetAngles( ang )

	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Forward(), paddleR )
	self.Paddle:SetAngles( ang )
end

function ENT:SetWheelAngle(r)
	self.P_WheelAngle = self.C_WheelAngle
	self.C_WheelAngle = r
end

function ENT:SetPaddleAngle(r)
	self.P_PaddleAngle = self.C_PaddleAngle
	self.C_PaddleAngle = r
end

function ENT:GetPegAngle(rot, i)
	return rot + self.NotchSize * i - self.NotchSize / 2
end

function ENT:GetNotchAngle(rot, i)
	return self:GetPegAngle(rot, i) + self.NotchSize / 2
end

function ENT:GetPaddleSpring()
	if not self.PaddleSpring then
		self.PaddleSpring = {
			pos = 0,
			vel = 0,
			target = 0,
		}
	end
	return self.PaddleSpring
end

function ENT:GetWheelSpring()
	if not self.WheelSpring then
		self.WheelSpring = {
			pos = 0,
			vel = 0,
			target = 0,
		}
	end
	return self.WheelSpring
end

function ENT:IntegrateSpring(spring, dt, friction, speed)
	friction = dt * friction
	spring.vel = spring.vel + (spring.target - spring.pos) * dt * speed
	spring.vel = spring.vel * (1 - friction)
	spring.pos = spring.pos + spring.vel * dt
end

function ENT:DoPaddlePhysics(dt)

	local spring = self:GetPaddleSpring()
	local rotation = self.FakeRotation --self.Rotation
	local radius = self.Wheel:GetModelRadius() - 2
	local pos = self:GetPos() + self:GetForward() * 2.5
	local xaxis = self:GetRight()
	local yaxis = self:GetUp()
	local paddlePull = false
	local paddlePullAngle = 0

	for i=0,self.NumNotches do
		local notch = math.rad(self:GetPegAngle(rotation, i))
		local ox = math.sin(notch) * radius
		local oy = math.cos(notch) * radius
		if oy > 0 then
			ox = -ox - (self.SpinDir > 0 and 1.2 or -1.2)
			local pl = self.PaddleLength
			local flick = math.min(ox, pl) / pl
			local dy = oy - (radius + 3)
			local angle = math.atan2(dy,ox) + math.pi/2

			if self.SpinDir > 0 then
				flick = -math.min(-ox, pl) / pl
			end

			angle = angle * 1.1 - flick * .1

			if (self.SpinDir < 0 and ox - pl < 0 and ox > 0) or
			   (self.SpinDir > 0 and ox + pl > 0 and ox < 0) then
				paddlePull = true
				paddlePullAngle = angle
			end
		end
	end

	if paddlePull then
		spring.pos = paddlePullAngle
		spring.vel = 0

		if self.WasPulling == false then
			self.WasPulling = true
		end

	else
		self:IntegrateSpring(spring, dt, 8, 600)
		if self.WasPulling == true then
			self:PlayClick()
			self.WasPulling = false
		end
	end

	self:SetPaddleAngle(math.deg(spring.pos))

end

function ENT:VelOverTime(t)
	return self.SpinSpeed * (1 - t * self.InvSpinDuration)
end

function ENT:DoWheelPhysics(dt)

	local spring = self:GetWheelSpring()

	spring.target = self.Rotation
	self:IntegrateSpring(spring, dt, 8, 2.5)
	self.FakeRotation = spring.pos

	self:SetWheelAngle(self.FakeRotation)

	if not self.Spinning then return end

	if (self.SpinDir > 0 and self.Speed <= 0) or (self.SpinDir < 0 and self.Speed >= 0) then
		self.Speed = 0

		if self.Spinning then
			--print("Landed on: " .. self.Rotation)
			--print("Delta error: " .. ( self.TargetRotation - self.Rotation ) )
			self.Spinning = false
		end

		self.Rotation = self.TargetRotation
	else
		self.Speed = self:VelOverTime(self.SpinTime) -- [>0] (counter clockwise) [<0] (clockwise)
		self.SpinTime = self.SpinTime + dt
		self.Rotation = (self.Rotation or 0) + self.Speed * dt

		if (self.SpinDir > 0 and self.Rotation > self.TargetRotation) or (self.SpinDir < 0 and self.Rotation < self.TargetRotation) then
			self.Rotation = self.TargetRotation
		end
	end
end

--Integrates speed over time to determine where the wheel stops
--Turns out that because this is a linear deceleration it can be solved as the area of a triangle :P
function ENT:Integrate(speed, time)
	return (speed * time) / 2
end

function ENT:Fit()

	local targetNotch = self:GetTarget()

	--Play with target angle to get clicker to land in odd ways (almost on a payout but not quite)
	--Tweak these values if wheel doesn't land right
	local pullBack = math.Rand(-self.NotchSize / 1.8, self.NotchSize / 7)
	if self.SpinDir > 0 then pullBack = -pullBack end

	local targetAngle = self:GetNotchAngle(pullBack,targetNotch)
	if targetAngle > 180 then targetAngle = (targetAngle % 180) - 180 end

	local rot = self.Rotation + self:Integrate(self.SpinSpeed, self.SpinDuration)
	local closestNotch = (targetAngle + math.Round(rot / 360) * 360) - self.Rotation

	--Solve for area of triangle to get target speed
	self.SpinSpeed = (closestNotch * 2) / self.SpinDuration

end

function ENT:StartSpin()
	--print("STARTED SPIN")

	self.SpinDir = math.random(0,1) == 1 and -1 or 1
	self.SpinSpeed = 800 * self.SpinDir
	self.Rotation = self.Rotation % 360
	self.InvSpinDuration = 1.0 / self.SpinDuration

	self:Fit()

	self.Spinning = true
	self.Speed = self.SpinSpeed
	self.SpinTime = 0

	self.TargetRotation = self.Rotation + self:Integrate(self.SpinSpeed, self.SpinDuration)

	local spring = self:GetWheelSpring()
	spring.pos = self.Rotation

	self.C_WheelAngle = self.Rotation
	self.P_WheelAngle = self.C_WheelAngle

end

function ENT:Sim(dt)
	self:DoWheelPhysics(dt)
	self:DoPaddlePhysics(dt)
end

function ENT:CheckSpin()
	self.SpinState = self.SpinState or 0
	local nextState = self:GetState()

	if nextState ~= self.SpinState then
		self.SpinState = nextState
		if self.SpinState == self.SPIN.STARTING then
			self:StartSpin()
		end
	end
end

function ENT:Think()

	self.physAcc = self.physAcc or 0

	local time = CurTime()
	local timeStep = 1.0 / 240
	local frameTime = time - (self.LastTime or 0)
	self.LastTime = time

	frameTime = math.min(frameTime, 2)

	self:CheckSpin()
	self:CheckClientsideModels()
	self:UpdatePositions()

	self.physAcc = self.physAcc + frameTime
	local simSteps = 0

	while ( self.physAcc >= frameTime ) do
		self:Sim(timeStep)
		self.physAcc = self.physAcc - timeStep
		simSteps = simSteps + 1
	end

	--print("SimSteps: " .. simSteps)

	local alpha = self.physAcc / timeStep
	self:UpdateAngles(alpha)

end

function ENT:Draw()

	self:DrawModel()

end

function ENT:DrawTranslucent()

	local distance = self:GetPos():Distance( LocalPlayer():GetPos() )
	if distance > 512 then return end

	local pos = self:GetPos() + Vector( 0, 0, 62 ) + Vector(0,0, math.sin( RealTime() ) * 4 )
	local ang = self:GetAngles() + Angle( 0,90,90 )

	cam.Start3D2D( pos, ang, .25 )

		pcall(function()
		local label = "SPIN FOR " .. tostring( self.Cost ) .. " GMC"

		if IsValid( self:GetUser( ply ) ) then
			label = self:GetUser( ply ):GetName() .. " IS SPINNING"
		end

		draw.TextBackground( label, "PokerText", 0, -22, 8, nil, Color( 0, 0, 0, 150 ) )
		draw.SimpleShadowText( label, "PokerText", 0, 0 )
		end)

	cam.End3D2D()

end

function ENT:OnRemove()

	if self.Wheel then
		self.Wheel:Remove()
	end

	if self.Paddle then
		self.Paddle:Remove()
	end

end
