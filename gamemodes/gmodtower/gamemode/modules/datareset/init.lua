AddCSLuaFile( "cl_init.lua" )

// If your last online time was before this date, prompt to reset your data.
local OutdatedPlaytime = 1514764800 -- January 1st, 2018

function CheckPlayerData( ply, lastonline )

  if ( !IsValid(ply) or lastonline == nil or ply:IsBot() ) then return end

  if ( lastonline < OutdatedPlaytime and lastonline != 0 ) then

    ply.CanResetData = true

    net.Start("SendDataReset")
    net.Send(ply)
  end

end

concommand.Add("gmt_resetdata",function(ply)

  if !ply.CanResetData then return end

  ply:Msg2("RESETTING YOUR DATA, PLEASE WAIT.")

  ply.HasResetData = true

  timer.Simple(1,function()
    ply:Kick("Your data has been reset, please rejoin the server!")
  end)

end)

hook.Add("PlayerInitialSpawn","CheckGMTCTime",function(ply)

  if ( !IsValid(ply) || ply:IsBot() ) then return end

  timer.Simple(1,function()
    local query = "SELECT `LastOnline` FROM `gm_users` WHERE id=" .. ply.SQL:SQLId()
    SQL.getDB():Query( query, function( res )
      if !res or res == nil then return end
      local row = res[1].data[1]
      if row then
          local time = tonumber(row.LastOnline)
          CheckPlayerData( ply, time )
      end
    end)
  end)
end)

util.AddNetworkString("SendDataReset")
