include( "shared.lua" )
ENT.CurAng = Angle( 0, 0, 0 )

local function SinBetween( min, max, time )
	local diff = max - min
	local remain = max - diff
	return ( ( ( math.sin( time ) + 1 ) / 2 ) * diff ) + remain
end

function ENT:Think()
	if !self.toprotor then
		self.toprotor = ClientsideModel(self.RotorModel)
		self.toprotor:SetPos(self:GetPos()+self.TopRotorPos)
		self.toprotor:Spawn()
		self.toprotor:SetParent(self)
	end

	if !self.backrotor then
		self.backrotor = ClientsideModel(self.BackRotorModel)
		self.backrotor:SetPos(self:GetPos()+self.BackRotorPos)
		self.backrotor:Spawn()
		self.backrotor:SetParent(self)
	end

	self.toprotor:SetAngles(self.toprotor:GetAngles()+Angle(0,CurTime()+25,0))
	self.backrotor:SetAngles(self.backrotor:GetAngles()+Angle(CurTime()+25,0,0))
end

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang.p = SinBetween( -4, 4, CurTime() )
	ang.r = SinBetween( -4, 4, CurTime() )
	ang.y = 90

	if !self.CurPos then self.CurPos = self:GetPos() end
	if !self.TargetPos then self.TargetPos = self:GetPos() - Vector(0,0,250) end

	if self.IsMoving then

		ang.y = 45

		self.CurAng.y = math.Approach( self.CurAng.y, ang.y + 90, FrameTime() * 50 )
		self.CurAng.p = math.Approach( self.CurAng.p, ang.p + 15, FrameTime() * 50 )
		self.CurAng.r = math.Approach( self.CurAng.r, ang.r, FrameTime() * 50 )

		local pos = self:GetPos()

		self.CurPos.x = math.Approach( self.CurPos.x, pos.x, FrameTime() * 50 )
		self.CurPos.y = math.Approach( self.CurPos.y, pos.y + 5000, FrameTime() * 250 )
		self.CurPos.z = math.Approach( self.CurPos.z, pos.z + 5000, FrameTime() * 75 )

	else

		self.CurAng.y = math.Approach( self.CurAng.y, ang.y, FrameTime() * 50 )
		self.CurAng.p = math.Approach( self.CurAng.p, ang.p, FrameTime() * 50 )
		self.CurAng.r = math.Approach( self.CurAng.r, ang.r, FrameTime() * 50 )

		local pos = self:GetPos()

		self.CurPos.x = math.Approach( self.CurPos.x, self.TargetPos.x, FrameTime() * 50 )
		self.CurPos.y = math.Approach( self.CurPos.y, self.TargetPos.y, FrameTime() * 50 )
		self.CurPos.z = math.Approach( self.CurPos.z, self.TargetPos.z, FrameTime() * 50 )

	end
	self:SetAngles( self.CurAng )
	self:SetPos( self.CurPos )
end

function ENT:OnRemove()
	self.toprotor:Remove()
	self.backrotor:Remove()
end

net.Receive("gmt_heli_fly",function()
	local heli = net.ReadEntity()

	heli.IsMoving = true

end)
