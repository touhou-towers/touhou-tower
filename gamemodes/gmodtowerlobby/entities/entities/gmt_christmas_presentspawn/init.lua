ENT.Type = "point"

function isChristmasTime()
	local str = string.Explode(":", os.date("%m:%d"))
	
	return tonumber(str[1]) == 12 and tonumber(str[2]) >= 25
end
	
function ENT:Initialize()
	if !isChristmasTime() then
		self.Standby = true
		return
	end
	self:SpawnPresent()
end

function ENT:Think()
	if self.Standby and isChristmasTime() then
		self:SpawnPresent()
		self.Standby = false
	end
end

function ENT:QueueSpawn(queue)
	self.Queue = queue
end

function ENT:SpawnPresent()
	if IsValid(self.CurrentPresent) then return false end 
	
	self:CheckSpawnArea()
	self.CurrentPresent = ents.Create("gmt_christmas_present")
	self.CurrentPresent:TimedPickup(true)
	self.CurrentPresent:SetPos(self:GetPos())
	self.CurrentPresent.OnRemove = function()
			math.randomseed(os.time())
			timer.Simple(math.random(60, 180), function() self:SpawnPresent() end) 
		end
	self.CurrentPresent:Spawn()
	
end

function ENT:CheckSpawnArea()
	for _, v in ipairs(ents.FindInSphere(self:GetPos(), 32)) do
		v:SetVelocity(Vector(0, 0, 1000))
	end
end

/*function ENT:GetValidSpawnPos(count)

	math.randomseed(os.time())
	local pos = Vector(math.random(-200, 200), math.random(-200, 200), 0)
	
	if count == 100 then 
		self:QueueSpawn(true)
		return
	end
	
	for _, v in ipairs(ents.FindInSphere(pos, 32)) do
		if IsValid(v) and (v:IsPlayer() or v:GetClass() == "gmt_christmas_present") then return self:GetValidSpawnPos(count + 1) end
	end
	
	return pos
	
end*/