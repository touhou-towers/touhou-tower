
-----------------------------------------------------

local ScoreTable = {"LOADING DATA"}

net.Receive("UpdateTetrisBoard",function()
  local tbl = net.ReadTable()

  if !tbl then ScoreTable = {"No scores available!"} return end
  ScoreTable = tbl

end)

hook.Add( "PostDrawOpaqueRenderables", "DrawTetrisBoard", function()

  /*local PlyAng = (LocalPlayer():EyeAngles().y - 90)
  local Wobbl = (math.sin( CurTime() ) * 2)

  local pos = Vector(-1400, 2275, (-50 + Wobbl))

  if (LocalPlayer():GetPos():Distance(Vector(-1400, 2275, -50)) > 785) then return end

	cam.Start3D2D( Vector(-1400, 2275, (-50 + Wobbl)), Angle(0,PlyAng,90), 0.235 )
    draw.DrawText([[
    TETRIS HIGHSCORES
    ]]..table.concat(ScoreTable,"\n")..[[
    ]],"GTowerSkyMsgSmall",0,0,Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER)
	cam.End3D2D()*/
end )
