
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("gmt_killgmtc")

local Depression = false
--[[
concommand.Add("gmt_enditall",function()

  // Networks the default texts since you can't get the texts from Skymsgs that aren't loaded in
  // on the client.

  for k,v in pairs( ents.FindByClass("gmt_skymsg") ) do
    v:SetNWString("DefaultText",tostring(v.Messages[v.Text]))
  end

  net.Start("gmt_killgmtc")
  net.Broadcast()

  Depression = true

  timer.Simple((4*60)+40,function()
    for k,v in pairs(player.GetAll()) do
      if v:IsAdmin() then return end
      v:Kick("GMTC has been shutdown, thank you for playing!")
    end
  end)

end)

hook.Add("CheckPassword","NoGMTCAnymore",function()
  if Depression then
    return false, "GMTC has been shutdown, thank you so much for playing!"
  end
end)
--]]