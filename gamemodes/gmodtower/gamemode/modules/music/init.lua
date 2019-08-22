
-----------------------------------------------------
include( "sh_init.lua" )
AddCSLuaFile( "sh_init.lua" )
AddCSLuaFile( "cl_init.lua" )

util.AddNetworkString("MusicEvent")

module( "music", package.seeall )

function Play( event, id, ply )

  /*
  EVENT_PLAY
  EVENT_STOP
  EVENT_VOLUME
  */

  if !id then return end

  net.Start("MusicEvent")
  net.WriteInt( tonumber(event) , 4 )
  net.WriteInt( tonumber(id) , 8 )

  if IsValid(ply) then
    net.Send(ply)
  else
    net.Broadcast()
  end

end

function StopAll( fade, time )

  net.Start("MusicEvent")
  net.WriteInt( 3 , 4 )

  if fade then
    net.WriteBool( fade )
  end

  if time then
    net.WriteInt( time, 8 )
  end

  net.Broadcast()

end
