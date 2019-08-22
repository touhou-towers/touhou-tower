include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("gmt_bezier_start")

ENT.Offset = Vector(0,0,0)

function ENT:Initialize()
    self:DrawShadow(false)

    timer.Simple(10,function()
      if IsValid(self) then self:Remove() end
    end)

end

function ENT:Begin()
  timer.Simple(0.5,function()

  net.Start( "gmt_bezier_start" )
    net.WriteEntity(self.Entity)
    net.WriteEntity(self.GoalEntity)
    net.WriteVector(self.Offset)
    net.WriteShort(math.Clamp( (self.GMC / 4), 1, 150 ))
    net.WriteFloat(self.RandPosAmount)
    net.WriteFloat(1)
    net.WriteFloat(1)
  net.Broadcast()

  end)
end
