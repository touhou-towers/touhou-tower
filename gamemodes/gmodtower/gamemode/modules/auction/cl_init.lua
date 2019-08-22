
local AuctionActive = false
local AuctionTime = 0

net.Receive("ToggleClAuction",function()
  local bool = net.ReadBool()
  AuctionActive = bool

  if !bool then return end

  local time = net.ReadInt(32)

  AuctionTime = CurTime() + time

end)

hook.Add( "PostDrawOpaqueRenderables", "DrawAuctionTimer", function()

  if !AuctionActive then return end

  local time = math.Round(AuctionTime - CurTime())

  local bg = math.Clamp(math.sin(CurTime() * 4) * 32,0,255)

	cam.Start3D2D( Vector(928.3125, -803.5625, 155.25), Angle(math.sin(CurTime() * 2),0,90), 0.25 )
    draw.TextBackground( "AUCTION! TIME LEFT: " .. time .. " SECONDS" , "GTowerSkyMsg", 0, 0, 150, 140, Color(bg,bg,bg) )
    draw.DrawText("AUCTION! TIME LEFT: " .. time .. " SECONDS","GTowerSkyMsg",0,0,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
	cam.End3D2D()

  cam.Start3D2D( Vector(928.3125, -803.5625, 155.25), Angle(180 + math.sin(CurTime() * 2),0,-90), 0.25 )
    draw.DrawText("AUCTION! TIME LEFT: " .. time .. " SECONDS","GTowerSkyMsg",0,0,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
  cam.End3D2D()
end )
