include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
    self:DrawShadow(false)
    local owner = self:GetOwner()
    if IsValid(owner) then
      self:NetworkChanges(owner)
      timer.Create("CreateSetTexthat" .. tostring( owner ), 5, 5, function() self:NetworkChanges(owner) end)
    end
end

function ENT:OnRemove()

  local owner = self:GetOwner()

  if IsValid(owner) and timer.Exists("CreateSetTexthat" .. tostring( owner )) then
    timer.Destroy("CreateSetTexthat" .. tostring( owner ))
  end

end

function ENT:NetworkChanges( owner )
  self:SetNWString( "Text", owner:GetInfo( "gmt_hattext" ) )
  self:SetNWFloat( "Height", owner:GetInfoNum( "gmt_hatheight", 0 ) )
end
