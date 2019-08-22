
ENT.Base = "info_zombie_spawn"
ENT.Type = "point"

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
end

local function GetCartNum( name )
  for i=1, 6 do
    if string.EndsWith( name, tostring(i) ) then
      return i
    end
  end
end

function ENT:AcceptInput( name, activator, caller, data )
    if name == "Stop" then
      for k,v in pairs( ents.FindByClass("func_tracktrain") ) do

        v.Leaving = false

        if activator == v then

          v.QueueNum = GetCartNum( caller:GetName() )

          if caller:GetName() == "1_hr_trainstation1" then
            v.Leaving = true
          else
            v:Fire("Stop","")
          end
        end

        if v.Leaving then
          timer.Simple(1,function()
            v:Fire("StartForward","")
            v.Going = true
            v.Leaving = false
          end)
        end

      end
    elseif name == "StartForward" then
      for k,v in pairs( ents.FindByClass("func_tracktrain") ) do
        if activator == v then
          v:Fire("StartForward","")
        end
      end
    elseif name == "TeleportToPathTrack" then
      for k,v in pairs( ents.FindByClass("func_tracktrain") ) do
        if activator == v then
          v.Going = false
          v:Fire("TeleportToPathTrack","1_hr_t163")
          v:Fire("StartForward","",3)

          timer.Simple(5,function()
            if v.Players then
              for _, ply in pairs( player.GetAll() ) do
                if table.HasValue( v.Players, ply ) then
                  ply:AddAchivement( ACHIVEMENTS.HALLOWEENRIDE, 1 )
                  ply:SendLua([[RunConsoleCommand("gmt_leavetrain")]])
                end
              end
            end
          end)

        end
      end
    end
end
