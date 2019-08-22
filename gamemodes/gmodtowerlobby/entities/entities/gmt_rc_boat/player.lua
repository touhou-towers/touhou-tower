local meta = FindMetaTable("Player")

if !meta then
	ErrorNoHalt("ERROR: Could not find Player meta table!")
	return
end

function meta:SetRCBoat(boat)
	self.RCBoat = boat
end

function meta:GetRCBoat()
	return self.RCBoat
end
