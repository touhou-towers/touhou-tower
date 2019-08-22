
local meta = FindMetaTable("Player")
if !meta then return end

function meta:GetRTLocation()
	return self:GetDTInt(0) or 0
end

function meta:GetLastRTLocation()
	return self.LastLocation or -1
end

function meta:GetRTLocationName()
	return Location.GetRTLocationNameByIndex( self:GetRTLocation() )
end

function meta:SetRTLocation(locationId)
	self.LastLocation = self:GetRTLocation()
	return self:SetDTInt(0, locationId)
end 