
concommand.Add("gmt_leavetrain",function(ply)
  ply:ExitVehicle()
  ply:SetPos(Vector("-9963.607422 3896.702393 88.031250"))

  if IsValid(ply.Cart) then
    TrainLeave( ply, ply.Cart )
    ply.Cart = nil
  end

end)

hook.Add("PlayerDisconnected","DisconnectTrainLeave",function(ply)
  if IsValid(ply.Cart) then
    TrainLeave( ply, ply.Cart )
  end
end)

function TrainLeave( ply, cart )
  if table.HasValue( cart.Players, ply ) then
    table.RemoveByValue( cart.Players, ply )
  end
  cart.Passengers = cart.Passengers - 1
  if cart.Passengers == 2 then cart.IsFull = true else cart.IsFull = false end
end

hook.Add("TrainEnter","CheckTrainLogic",function( ply, ent )

  if !IsValid( ply ) or !IsValid( ent ) then return end

  local cart = ent:GetParent()

  if !IsValid( cart ) then return end

  ply.Cart = cart

  if !cart.Passengers then cart.Passengers = 0 end
  if !cart.Players then cart.Players = {} end

  --cart.Players[ply] = true
  table.insert( cart.Players, ply )

  cart.Passengers = cart.Passengers + 1

  if cart.Passengers == 2 then cart.IsFull = true else cart.IsFull = false end

  /*timer.Simple(5,function()
    if cart.Passengers > 0 then
      cart:Fire("StartForward","")
      print("STARTING CART "..tostring(cart))
      cart.Going = true
      timer.Simple( ((3*60) + 30), function()
        cart.Going = false
        cart:Fire("TeleportToPathTrack","1_hr_t163")
        cart:Fire("StartForward","",3)
      end)
    end
  end)*/

end)
