
ENT.Type = "point"

function ENT:KeyValue( key, val )
  if key == "track" then
    self.Track = val
  end
end
