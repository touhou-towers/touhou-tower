
include('shared.lua')

function ENT:Initialize()
    self:SetSequence(self.CurAnimation)
    timer.Create("ShopAnimationLoop",0.5,0,function()
      self:SetSequence(self.CurAnimation)
    end)
end

function ENT:OnRemove()
    if !timer.Exists("ShopAnimationLoop") then return end
    timer.Destroy("ShopAnimationLoop")
end
