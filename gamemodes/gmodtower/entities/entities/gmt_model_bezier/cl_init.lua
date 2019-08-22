

-----------------------------------------------------
include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.SpinSpeed = 100
ENT.VecOffset = Vector( 0, 0, 0 )

ENT.Model = nil
ENT.GoalEntity = nil
ENT.FinishCount = 0 //The number of models that have so far arrived

net.Receive( "gmt_mdlbezier_start", function()

	local self = net.ReadEntity()
	local entGoal = net.ReadEntity()

	if !IsValid( self ) || !IsValid( entGoal ) then return end //This is kind of important

	self.GoalEntity = entGoal
	local pos = GetCenterPos( self.GoalEntity )

	self.Models = {}
	self.ModelString 		= net.ReadString()
	self.RandomPosAmount 	= net.ReadFloat()
	self.ApproachTime 		= net.ReadFloat()
	self.RandomTime 		= net.ReadFloat()

	self.Active = true

	if self.ModelString then
		self.Model = ClientsideModel( self.ModelString, RENDER_GROUP_OPAQUE_ENTITY )
	end

	if !self.Model then return end

	local rand = VectorRand() * self.RandomPosAmount + self:GetPos() + self.VecOffset
	local randTime = self.ApproachTime + (math.Rand( -self.RandomTime, self.RandomTime ) )

	self.Model:SetPos( rand )
	self.Model:SetAngles( Angle( math.Rand( -180, 180), math.Rand( -180, 180), math.Rand( -180, 180) ) )

	self.P0 = rand
	self.P1 = rand + Vector( 0, 0, 50 )
	self.P2 = pos + self.VecOffset + Vector( 0, 0, 50 )
	self.P3 = pos + self.VecOffset

	self.ApproachTime = randTime
	self.Percent = 0
	self.StartTime = RealTime()


end )

function ENT:Initialize() self:SetNoDraw( true ) end

function ENT:Think()

	if !self.Active || !self.Model then return end

	//Update the positions for the flying model

	if self.Model != nil && IsValid( self.GoalEntity ) then

		self.P3 = GetCenterPos( self.GoalEntity ) + self.VecOffset
		self.P2 = self.P3 + Vector( 0, 0, 50 )

		local NewPosition = Bezier( self.P0, self.P1, self.P2, self.P3, self.Percent)

		self.Percent = self.Percent + ( FrameTime() / self.ApproachTime )
		//self.Model:SetAngles( self.Angle + Angle( 0, FrameTime() * self.SpinSpeed, FrameTime() * self.SpinSpeed ) )
		self.Model:SetPos( NewPosition )

		if self.Percent >= 1.0 then

			self.FinishCount = self.FinishCount + 1
			self:Arrived()

		end

		-- this is definitely 100% totally the right place for this
		if self.Model:GetModel() != "models/gmod_tower/halloween_candybucket.mdl" then
			self.Model:SetModelScale( .95, 0 )
		end

	end

end

-- don't draw at all ever in the world
function ENT:Draw()
	return
end

//Warning: math
function Bezier( a, b, c, d, t )

	local ab,bc,cd,abbc,bccd

	ab = LerpVector(t, a, b)
	bc = LerpVector(t, b, c)
	cd = LerpVector(t, c, d)
	abbc = LerpVector(t, ab, bc)
	bccd = LerpVector(t, bc, cd)
	dest = LerpVector(t, abbc, bccd)

	return dest //HOLY SHIT BEZIERSS

end

//Called whenever a model has arrived to the ending position
function ENT:Arrived()

	//print(tostring( self.FinishCount ) .. "/" .. tostring( self.ModelCount ))
	//self:EmitSound( self.MoneySound, 80, 120 - ( self.FinishCount / self.ModelCount ) * 40 )

end

function ENT:OnRemove()

	if self.Model then
		self.Model:Remove()
		self.Model = nil
	end

end

function GetCenterPos( ent )

	if !IsValid( ent ) then return end

	if ent:IsPlayer() && !ent:Alive() && IsValid( ent:GetRagdollEntity() ) then
		ent = ent:GetRagdollEntity()
	end

	local Torso = ent:LookupBone( "ValveBiped.Bip01_Spine2" )

	if !Torso then return ent:GetPos() end

	local pos, ang = ent:GetBonePosition( Torso )

	if !ent:IsPlayer() then return pos end

	return pos

end
