function ENT:AddSchedule(desc, time, chance, endfunc, func, ...)

	local num = #self.SCHED
	self.SCHED[num + 1] = {}
	self.SCHED[num + 1].desc = desc
	self.SCHED[num + 1].time = time
	self.SCHED[num + 1].chance = chance //1 in "chance" chance of it choosing this one
	self.SCHED[num + 1].endfunc = endfunc
	self.SCHED[num + 1].func = func
	self.SCHED[num + 1].args = ...

end

function ENT:SetupSchedules()

	self.SCHED = {}
	if SERVER then
		self.CurrentSCHED = nil
		self.SCHEDTime = 0
		self.Fishing = false
		self.FishAngle = 0
		self.Idling = false
		self.Sitting = false
		self.Flying = false
		self.Descending = false
		self.FlyCheck = false
		self.Stacking = false
		self.IsBottomOfStack = false
		self.StackTbl = {}
		
		//Walking around is special, it doesn't need a time or chance
		self:AddSchedule( "Walk around", {3, 6}, nil, self.EndWalkAround, self.WalkAround )
	end
	
	//Add our schedules
	self:AddSchedule( "Fish for dem birdies", {15, 30}, 75, self.EndFish, self.StartFish )
	self:AddSchedule( "Take a break", {12, 24}, 25, self.EndSit, self.StartSit )
	self:AddSchedule( "Stand still", {4, 8}, 12, self.EndIdle, self.StartIdle )
	self:AddSchedule( "Fly", {4, 12}, 100, self.EndFly, self.StartFly )

end