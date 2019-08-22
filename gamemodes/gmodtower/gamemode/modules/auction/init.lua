
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("ToggleClAuction")

local AuctionDuration = (60 * 5)

concommand.Add("gmt_startauction",function(ply)
  if ply:IsAdmin() then StartAuction(ply) end

  net.Start("ToggleClAuction")
    net.WriteBool(true)
    net.WriteInt( AuctionDuration, 32 )
  net.Broadcast()

end)

local TablePos = {
  Vector(671.59375, -801.65625, 0.25),
  Vector(799.21875, -800.84375, 0.25),
  Vector(928.3125, -803.5625, 0.25),
  Vector(1056.28125, -801.375, 0.25),
  Vector(1184.125, -800.53125, 0.25)
}

local Tables = {}

function StartAuction(ply)

  for k,v in pairs(player.GetAll()) do
    v.WonAuction = false
    v:SetNWInt( "BetTotal", 0 )
  end

  AdminNotify( ply:Name() .. " has started an auction in the lobby." )

  for k,v in pairs(player.GetAll()) do v:Msg2("Please check your inventory space before joining!") end

  Tables = {}

  for k,v in pairs( TablePos ) do
    local Table = ents.Create( "gmt_auctiontable" )
    Table:SetPos( TablePos[k] )
    Table:Spawn()

    table.insert( Tables, Table )

    if k == 3 then Table:EmitSound("gmodtower/casino/cards/round2.mp3") end

  end

  timer.Simple( AuctionDuration, function()
    EndAuction()
  end)

end

local function giveItem(ply, item)
  local itemID = GTowerItems:Get(item)

  if !GTowerItems:NewItemSlot(ply):Allow(itemID, true) then

    local SellPrice = itemID:SellPrice()

    if SellPrice > 0 then
      ply:AddMoney(SellPrice)
    end

    for k,v in pairs(player.GetAll()) do
      v:Msg2("[AUCTION] "..ply:Name().." doesn't have enough inventory space! 50% of the price will be awarded instead.")
    end
    return
  end

  ply:InvGiveItem(item)

  for k,v in pairs(player.GetAll()) do
    v:Msg2("[AUCTION] "..ply:Name().." has won '".. itemID.Name .."'")
  end
end

function EndAuction()

  net.Start("ToggleClAuction")
    net.WriteBool(false)
  net.Broadcast()

  for k,v in pairs(Tables) do
    if IsValid(v) then

      local ply = v:GetNWEntity("ply")
      if IsValid(ply) then
        ply.WonAuction = true
      end

      timer.Simple(1,function() v:Remove() end)

      if IsValid(ply) and v.NetworkItemId then
        giveItem(ply, v.NetworkItemId)
      end

    end
  end

  for k,v in pairs(player.GetAll()) do
    if (!v.WonAuction and v:GetNWInt("BetTotal",0) > 0) then
      v:AddMoney(v:GetNWInt("BetTotal",0),true)
      v:Msg2("[AUCTION] Your money has been refunded.")
    end
  end

end
