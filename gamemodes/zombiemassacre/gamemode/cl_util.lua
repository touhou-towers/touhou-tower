local oldUtilTR = util.TraceLine

module("util", package.seeall)

function TraceLine(traceData, debugLine, time, color)
	local ret = oldUtilTR(traceData)

	if (debugLine) then
		if (SERVER) then
			umsg.Start("UTL")
			umsg.Vector(traceData.start)
			umsg.Vector(traceData.endpos)
			umsg.Char(time or 5)
			umsg.Color(color or Color(255, 255, 255, 255))
			umsg.End()
		else
			debugoverlay.Line(traceData.start, traceData.endpos, time or 5, color)
		end
	end

	return ret
end

function QuickTrace(origin, dir, filter, debugLine, time, color)
	local trace = {
		start = origin,
		endpos = origin + dir,
		filter = filter
	}

	return util.TraceLine(trace, debugLine, time, color)
end

function GetCenterPos(ent)
	if not IsValid(ent) then
		return
	end

	if ent:IsPlayer() and not ent:Alive() and IsValid(ent:GetRagdollEntity()) then
		ent = ent:GetRagdollEntity()
	end

	if ent:IsPlayer() and isfunction(ent.GetClientPlayerModel) and IsValid(ent:GetClientPlayerModel()) then
		ent = ent:GetClientPlayerModel():Get()
	end

	local Torso = ent:LookupBone("ValveBiped.Bip01_Spine2")

	if not Torso then
		return ent:GetPos()
	end

	local pos, ang = ent:GetBonePosition(Torso)

	if not ent:IsPlayer() then
		return pos
	end

	local drivable = ent:GetNet("DrivingObject")
	if IsValid(drivable) then
		return drivable:GetPos()
	end

	return pos
end

function GetHeadPos(ent)
	if not IsValid(ent) then
		return
	end

	if ent:IsPlayer() and IsValid(ent:GetClientPlayerModel()) then
		ent = ent:GetClientPlayerModel():Get()
	end

	local Head = ent:LookupBone("ValveBiped.Bip01_Head1")

	if not Head then
		return ent:GetPos() + Vector(0, 0, 64)
	end

	local pos, ang = ent:GetBonePosition(Head)

	if not ent:IsPlayer() then
		return pos
	end

	if ent.GetBallRaceBall and IsValid(ent:GetBallRaceBall()) then
		return ent:GetBallRaceBall():GetPos() + Vector(0, 0, 64)
	end

	return pos
end

function MultiTrace(startPos, normals, length, filter, debugLine)
	local results = {}

	for _, v in pairs(normals) do
		local res = util.QuickTrace(startPos, v * length, filter, debugLine or false)

		table.insert(results, res)
	end

	return results
end

function TranslateToPlayerModel(model)
	if model == "models/player/urban.mbl" then
		return "models/player/urban.mdl"
	end

	if model == "models/killingfloor/haroldlott.mdl" then
		return "models/player/haroldlott.mdl"
	end

	model = string.Replace(model, "models/humans/", "models/")
	model = string.Replace(model, "models/", "models/")

	return model
end

function TranslateOffset(vec, ent)
	return (ent:GetForward() * vec.x) + (ent:GetRight() * -vec.y) + (ent:GetUp() * vec.z)
end

function FindValidEnt(str)
	if (not str) then
		return nil
	end

	local ent = ents.FindByName(str)[1]

	if (IsValid(ent)) then
		return ent
	end

	return nil
end

function TriggerValidEnt(str)
	if (not str) then
		return
	end

	local ent = util.FindValidEnt(str)

	if (IsValid(ent)) then
		ent:Fire("Trigger", 0, 0)
	end
end

function FindSkyboxEnt(str)
	for _, ent in pairs(ents.FindByClass("gmt_skycam")) do
		if ent.GetSkyboxName and ent:GetSkyboxName() == str then
			return ent
		end
	end
end

function InFront(pos, ent)
	return (pos - ent:GetPos()):DotProduct(ent:GetForward()) > 0
end

if CLIENT then
	usermessage.Hook(
		"UTL",
		function(um)
			local startpos = um:ReadVector()
			local endpos = um:ReadVector()

			local time = um:ReadChar()

			local color = um:ReadColor()

			debugoverlay.Line(startpos, endpos, time, color)
		end
	)
end
 --

--[[
	= Circular Queue =
	
	Store queued object efficently. This utility saves memory by tricking lua
	 to store the queue using backing arrays, making it way faster than
	 inserting into a tables first index.
	
	queue = CircularQueue( <size = 8> )
	
	queue:Add( entry )
	
	queue:Peek()
	queue:Pop()
	
	queue:IsEmpty()
	queue:Count()
]] local META = {}
META.__index = META

function META:Add(entry)
	local index = self.writeIndex

	-- Catched up with readIndex
	if (self.readIndex == index and self[index] ~= nil) then
		local size = self.capacity
		local toCopy = size - index

		-- Copy the remairing data to the end of the queue
		for offset = 0, toCopy do
			self[size + offset + 1] = self[index + offset]
			self[index + offset] = nil
		end

		self.readIndex = size + 1
		self.capacity = self.capacity + toCopy + 1
	end

	-- Set
	self[index] = entry

	-- Increase (Wrap around) index
	index = index + 1

	if (index > self.capacity) then
		index = 1
	end

	self.writeIndex = index
end

META.Push = META.Add

function META:Peek()
	return self[self.readIndex]
end

META.Tell = META.Peek

function META:IsEmpty()
	return self.readIndex == self.writeIndex
end

function META:Pop()
	if (self:IsEmpty()) then
		return
	end

	local index = self.readIndex

	-- Pop
	local value = self[index]
	self[index] = nil

	-- Increase (Wrap around) index
	index = index + 1

	if (index > self.capacity) then
		index = 1
	end

	self.readIndex = index

	-- Return popped
	return value
end

function META:Count()
	if (self.writeIndex < self.readIndex) then
		return self.writeIndex + self.capacity - self.readIndex
	end

	return self.writeIndex - self.readIndex
end

function CircularQueue(size)
	local obj = {}
	obj.readIndex = 1
	obj.writeIndex = 1

	obj.capacity = size or 8

	return setmetatable(obj, META)
end
