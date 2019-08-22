
-----------------------------------------------------
util.AddNetworkString("UpdateTetrisBoard")

local UpdateInterval = 60 * 5
local MaxPlayers = 10

local LatestScores = {}

hook.Add("InitPostEntity", "StartTetrisBoard", function()
  UpdateTetrisBoard()
  timer.Create("TetrisBoardUpdater", UpdateInterval, 0, function()
    UpdateTetrisBoard()
  end)
end)

hook.Add("PlayerInitialSpawn", "PlyJoinShowScores",function(ply)
  UpdateTetrisBoard( true, ply )
end)

function UpdateTetrisBoard( force, ply )
  if !tmysql then return end

  if (force && LatestScores && IsValid(ply)) then
    SendTetrisBoard(LatestScores, true, ply)
    return
  end

  local Query = "SELECT `id`,`name`,`tetrisscore` FROM gm_users WHERE tetrisscore > 0 ORDER BY cast(tetrisscore as int) DESC LIMIT "..MaxPlayers
  Query = "SELECT `id`,`name`,`tetrisscore` FROM gm_users WHERE tetrisscore > 0 ORDER BY tetrisscore DESC LIMIT 0,10"
  SQL.getDB():Query( Query, function(res)
    if !res or res == nil then return end
    local data = res[1].data

    local scores = {}

    for k,v in pairs(data) do
      table.insert(scores, k, "#"..k.." "..v.name..": "..v.tetrisscore)
    end

    SendTetrisBoard( scores )

  end)

end

function SendTetrisBoard( tbl, force, ply )

  if force then
    net.Start("UpdateTetrisBoard")
      net.WriteTable(tbl)
    net.Send( ply )
    return
  end

  LatestScores = tbl

  net.Start("UpdateTetrisBoard")
    net.WriteTable(tbl)
  net.Broadcast()

end

concommand.Add("gmt_updatetetrisboard",function(ply)
  if ply:IsAdmin() then UpdateTetrisBoard() end
end)
