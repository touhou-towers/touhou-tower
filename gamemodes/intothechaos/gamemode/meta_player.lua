
local meta = FindMetaTable("Player")

if !meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:GetBattery()
  local battery = self:GetNWFloat("Battery",0)
  return (battery or 0)
end
