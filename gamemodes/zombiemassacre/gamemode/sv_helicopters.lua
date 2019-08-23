function GM:GetHelicopterPosition()

--[[
self.MapTable = {
  ["foundation03"] = Vector(1798.453125, 680.245056, 383.256012),
  ["acrophobia01"] = Vector(49.054100, -138.920593, 448.031250),
  ["gasoline01"] = Vector(423.939850, -823.919312, 128.031250),
  ["scrap01"] = Vector(343.946411, -745.678589, 76.218704),
  ["thedocks01"] = Vector(-724.417969, -3185.324707, -895.968750),
  ["trainyard01"] = Vector(282.766724, -75.519150, -383.985352),
  ["underpass02"] = Vector(1359.319458, 528.413391, 64.031250),
}

local map = string.gsub( game.GetMap(), "gmt_zm_arena_", "" )

if self.MapTable[ map ] then
  return self.MapTable[ map ]
else
  return Vector(0,0,0)
end
]]
  return ents.FindByClass("info_boss_spawn")[1]:GetPos()
end
