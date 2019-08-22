

-----------------------------------------------------
include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

local beammat	= Material( "cable/redlaser" )
local beamcolor	= Color( 255, 0, 0, 50 )

function ENT:Initialize()
	self:SharedInit()
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	if self:GetActive() then
		render.SetMaterial( beammat )
		local texoff = CurTime() * 3
		local dis = self:GetEndPos():Distance( self:GetPos() )
		local beamcalc = texoff + dis / 8
		render.DrawBeam( self:GetEndPos(), self:GetPos(), 8, texoff, dis, beamcolor )
		render.DrawBeam( self:GetEndPos(), self:GetPos(), 4, texoff, dis, beamcolor )
	end
end

function ENT:Think()
	if self:GetActive() then
		self:SetRenderBoundsWS(self:GetEndPos(), self:GetPos())
	end
end