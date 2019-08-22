util.AddNetworkString("ServerPing")
AddCSLuaFile("cl_init.lua")
-----------------------------------------

timer.Create("ServerPinger",5,0,function()

  net.Start("ServerPing")
  net.Broadcast()

end)
