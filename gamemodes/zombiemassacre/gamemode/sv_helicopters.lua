function GM:GetHelicopterPosition()
  return ents.FindByClass("info_boss_spawn")[1]:GetPos()
end
