ENT.Base			= "base_anim"
ENT.Type			= "anim"
ENT.Distance = 1000
ENT.Color = Color( 255, 0, 0, 255 )
if SERVER then

	AddCSLuaFile("shared.lua")
	function ENT:Initialize()
	
		self:UpdateEndPos()
		self:SetPos( self.StartPos )
		self:DrawShadow( false )
	end
end
function ENT:UpdateEndPos()
	local weapon = self:GetOwner()
	if !IsValid( weapon ) then
		return
	end
	local attach = 1 //weapon:LookupAttachment("muzzle")
	local AttachInfo = weapon:GetAttachment(attach)
	local pos, ang = weapon:GetPos(), weapon:GetOwner():GetForward()
	if AttachInfo then
		pos, ang = AttachInfo.Pos, AttachInfo.Ang:Forward()
	end
	local Trace = util.QuickTrace( pos, ang * self.Distance, weapon.Owner )
	self.StartPos = pos
	self.HitPos = Trace.HitPos
end
if CLIENT then
	ENT.Flare = Material("effects/blueflare1")
	ENT.Mat = Material("trails/physbeam")
	ENT.RenderGroup = RENDERGROUP_BOTH
	function ENT:Initialize() end
	function ENT:Think()
		self:UpdateEndPos()
		if self.StartPos then
			local min, max = self.StartPos * 1, self.HitPos * 1
			
			OrderVectors( min, max )
			self:SetRenderBoundsWS( min, max )
		end
	end
	function ENT:Draw() end
	function ENT:DrawTranslucent()
	
		if !self.HitPos then
			return
		end
		render.SetMaterial( self.Mat )
		render.DrawBeam( self.StartPos, self.HitPos, 6, 0, 1, self.Color )
		render.SetMaterial( self.Flare )
		render.DrawSprite( self.StartPos, 25, 25, self.Color )
		render.DrawSprite( self.HitPos, 15, 15, self.Color )
	end
end //End if CLIENT