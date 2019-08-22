include( "SCHED.lua" )

local movetypes = {
	MOVETYPE_WALK,
	MOVETYPE_NOCLIP
}

function ENT:CheckForSchedule( chk )

	local sched = self.SCHED
	if self.ShouldWalk then //We should start walking
		self.ShouldWalk = false
		return sched[1]
	end
	if chk > #sched then //All the others failed, just walk
		return sched[1]
	end

	sched = sched[chk]
	local rnd = math.random( 1, sched.chance )
	if rnd == 1 then //We did it!
		return sched
	else //Check the next one
		return self:CheckForSchedule( chk + 1 )
	end

end

function ENT:RandomSchedule()

	if CurTime() <= self.SCHEDTime then
		return
	end
	if IsValid( self.PlayerSaturn ) && self.ShouldWalk then //We should start walking
		self.ShouldWalk = false
		self.PlayerSCHED = 1
	end
	if self.CurrentEndFunc then
		local f, err = pcall( self.CurrentEndFunc, self )
		if !f then
			print( "ERROR: " .. err )
			return
		end
	end
	local sched = self:CheckForSchedule( 2 )
	//sched = self.SCHED[5]

	local t = sched.time
	if type( t ) == "table" then
		t = math.Rand( t[1], t[2] )
	end
	if sched.func then
		local f, err = pcall( sched.func, self )
		if !f then
			return
		end
		self.CurrentEndFunc = sched.endfunc
	end
	if !self.TimeOverride then
		self.SCHEDTime = ( CurTime() + t )
	end
	self.TimeOverride = false

end

function ENT:WalkSC( delta )

	local shadow = {}
	shadow.secondstoarrive = math.Rand( self.WalkTimeMin, self.WalkTimeMax )
	shadow.pos = Vector( 0, 0, 0 )
	shadow.angle = self.WalkAngle	
	shadow.maxangular = 5000
	shadow.maxangulardamp = 10000
	shadow.maxspeed = 0
	shadow.maxspeeddamp = 0
	shadow.dampfactor = 1
	shadow.teleportdistance = 0
	shadow.deltatime = delta
	return shadow

end

function ENT:FishSC( delta )

	local shadow = {}
	shadow.secondstoarrive = math.Rand( .5, .9 )
	shadow.pos = Vector( 0, 0, 0 )
	shadow.angle = Angle( -90, 0, self.FishAngle )
	shadow.maxangular = 5000
	shadow.maxangulardamp = 10000
	shadow.maxspeed = 0
	shadow.maxspeeddamp = 0
	shadow.dampfactor = 1
	shadow.teleportdistance = 0
	shadow.deltatime = delta
	return shadow

end

function ENT:FlySC( delta )

	local shadow = {}
	shadow.secondstoarrive = math.Rand( .5, .9 )
	shadow.pos = Vector( 0, 0, 0 )
	shadow.angle = Angle( 90, 0, self.FishAngle )
	shadow.maxangular = 5000
	shadow.maxangulardamp = 10000
	shadow.maxspeed = 0
	shadow.maxspeeddamp = 0
	shadow.dampfactor = 1
	shadow.teleportdistance = 0
	shadow.deltatime = delta
	return shadow

end

function ENT:WalkAround()

	if !IsValid( self ) then return end

	local pos = self:GetPos()
	self.Walking = true

	self.WalkAngle = Angle( 0, math.random( 0, 360 ), 0 )
	local chk = math.random( 1, 2 )
	if chk == 1 then
		for k, v in ipairs( player.GetAll() ) do
			local pos, pos2 = self:GetPos(), v:GetPos()
			local dist = pos:Distance( pos2 )
			if dist <= 300 then
				self.WalkAngle = ( pos2 - pos ):GetNormal():Angle() //Let's hang around them a bit
			end
		end
	end

end

function ENT:EndWalkAround()

	if !IsValid( self ) then return end
	self.Walking = false
end

function ENT:StartFish()

	if !IsValid( self ) then return end

	self.FishAngle = math.random( 0, 360 )
	self.Fishing = true
	if !IsValid( self.Balloon ) then
		self:MakeBalloon( 12, 100, Vector( 0, 0, 0 ) )
	end

end

function ENT:EndFish()

	if !IsValid( self ) then return end

	self.ShouldWalk = true //We should walk after we're done fishing
	self.CanGetUp = true
	self:EmitSound( "UCH/saturn/saturn_getup.wav", 60, 100 )
	self.Fishing = false
	self:RemoveBalloon()

end

function ENT:StartIdle()
	if !IsValid( self ) then return end

	self.Idling = true
end

function ENT:EndIdle()
	if !IsValid( self ) then return end

	self.Idling = false
end

function ENT:StartSit()

	if !IsValid( self ) then return end

	self.FishAngle = math.random( 0, 360 )
	self.Sitting = true

end

function ENT:EndSit()

	if !IsValid( self ) then return end

	self.ShouldWalk = true
	self.CanGetUp = true
	self:EmitSound( "UCH/saturn/saturn_getup.wav", 60, 100 )
	self.Sitting = false

end

function ENT:StartFly()

	if !IsValid( self ) then return end

	local off = self:GetForward()
	off = ( off * -1 ) * 12
	self:MakeBalloon( 350, 48, off )
	self.ShouldWalk = true
	self.Flying = true

	if IsValid( self.Balloon ) then self.FlyCheck = true end

end

function ENT:EndFly()

	if !IsValid( self ) then return end

	self.IsScared = false
	self.ShouldWalk = true
	self.Flying = false
	self.Descending = false
	self.FlyCheck = false
	self.WalkAngle.r = 0
	self:RemoveBalloon()

end