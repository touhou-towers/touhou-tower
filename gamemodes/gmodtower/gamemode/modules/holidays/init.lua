
-----------------------------------------------------

local Interval = 60 * 5

local function SendHolidayMsg( msg, clr )
  for k,v in pairs(player.GetAll()) do
    v:SendLua([[GTowerChat.Chat:AddText("]]..msg..[[", ]]..clr..[[)]])
  end
end

hook.Add("InitPostEntity","HolidayManager",function()
  CheckHolidays(false)

  timer.Create("HolidayChecker",Interval,0,function()
    if time.IsHoliday() then
      if time.IsChristmas() and !time.IsNewYears() then CheckHolidays(true) end
    else
      CheckHolidays(false)
    end
  end)

end)

function CheckHolidays(OnlyNewyears)

  if OnlyNewyears then
    if time.IsNewYears() then InitNewYears() end
    return
  end

  if time.IsChristmas() then InitChristmas() end
  if time.IsHalloween() then InitHalloween() end
  if time.IsIndepedenceDay() then InitIndepedenceDay() end
  if time.IsThanksgiving() then InitThanksgiving() end
  if time.IsNewYears() then InitNewYears() end
end

function InitChristmas()
  SendHolidayMsg('Merry Christmas! Christmas mode is now active!','Color(215,215,255)')
end

function InitHalloween()
  SendHolidayMsg("It's halloween! Halloween mode is now active!",'Color(155,55,55)')

  local stand = ents.Create("prop_physics")
  stand:SetPos(Vector(1659,-930,0.45))
  stand:SetAngles(Angle(0,225,0))
  stand:SetModel("models/gmod_tower/shopstand.mdl")
  stand:Spawn()

  stand:GetPhysicsObject():EnableMotion(false)

  local bucket = ents.Create("prop_physics")
  bucket:SetPos(Vector(1669,-942,44))
  bucket:SetAngles(Angle(0,225,0))
  bucket:SetModel("models/gmod_tower/halloween_candybucket.mdl")
  bucket:Spawn()

  bucket:GetPhysicsObject():EnableMotion(false)

  local npc = ents.Create("gmt_npc_halloween")
  npc:SetPos(Vector(1687,-903,0.45))
  npc:SetAngles(Angle(0,225,0))
  npc:Spawn()
end

function InitIndepedenceDay()
end

function InitThanksgiving()
  local npc = ents.Create("gmt_npc_thanksgiving")
  npc:SetPos(Vector(927.412292, -1887.839844, 19.787308))
  npc:SetAngles(Angle(0,-90,0))
  npc:Spawn()
end

function InitNewYears()
  SendHolidayMsg('Added the new years countdown.','Color(215,215,255)')

  local ball = ents.Create("gmt_newyearorb")
  ball:SetPos(Vector(927.136658, -1472.362915, 115.348526))
  ball:Spawn()
end
