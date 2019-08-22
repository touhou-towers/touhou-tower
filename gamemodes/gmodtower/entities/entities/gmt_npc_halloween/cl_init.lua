
include('shared.lua')

function ENT:Initialize()
    self:SetSequence(self.CurAnimation)
    timer.Create("ShopAnimationLoop"..tostring(self:EntIndex()),0.5,0,function()
      self:SetSequence(self.CurAnimation)
    end)
end

function ENT:OnRemove()
    if !timer.Exists("ShopAnimationLoop"..tostring(self:EntIndex())) then return end
    timer.Destroy("ShopAnimationLoop"..tostring(self:EntIndex()))
end
