

-----------------------------------------------------
include( "shared.lua" )

ENT.ModelString = Model( "models/gmt_money/one.mdl" )
ENT.MaterialOverride = nil

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.SpinSpeed = 100
ENT.MoneySound = Sound( "GModTower/misc/money.wav" )
ENT.MoneyVolume = 75
ENT.VecOffset = Vector( 0, 0, 0 )

ENT.Model = nil
ENT.GoalEntity = nil
ENT.GoalOffset = Vector( 0, 0, 0 )
ENT.FinishCount = 0 //The number of models that have so far arrived
ENT.Models = {} //Array to hold info about each model

net.Receive("gmt_bezier_start",function()

	local self = net.ReadEntity()
	local entGoal = net.ReadEntity()

	if !IsValid( self ) || !IsValid( entGoal ) then return end //This is kind of important

	self.GoalEntity = entGoal
	self.GoalOffset = net.ReadVector()
	local pos = GetCenterPos( self.GoalEntity )

	self.Models = {}
	self.ModelCount 		= net.ReadShort()
	self.RandomPosAmount 	= net.ReadFloat()
	self.ApproachTime 		= net.ReadFloat()
	self.RandomTime 		= net.ReadFloat()

	self.Active = true

	if !self.ModelString || !util.IsValidModel( self.ModelString ) then return end

	for i=1, self.ModelCount do


		local rand = VectorRand() * self.RandomPosAmount + self:GetPos() + self.VecOffset
		local randTime = self.ApproachTime + (i/self.ModelCount)*self.RandomTime

		//Create the clientside model
		local mdl = ClientsideModel( self.ModelString, RENDER_GROUP_OPAQUE_ENTITY )

		if !IsValid( mdl ) || mdl:GetModel() == "dicks" then
			return -- not continue. if this model didn't work, none will
		end

		mdl:SetMaterial( self.MaterialOverride )

		mdl:SetPos( rand )
		mdl:SetAngles( Angle( math.Rand( -180, 180), math.Rand( -180, 180), math.Rand( -180, 180) ) )

		mdl.P0 = rand
		mdl.P1 = rand + Vector( 0, 0, 50 )
		mdl.P2 = pos + self.VecOffset + Vector( 0, 0, 50 )
		mdl.P3 = pos + self.VecOffset

		mdl.ApproachTime = randTime
		mdl.Percent = 0
		mdl.StartTime = CurTime()

		-- Slap that model in there
		self.Models[#self.Models+1] = mdl
	end

end )

function ENT:Initialize() self:SetNoDraw( true ) end

function ENT:Think()

	if !self.Active || !self.Models then return end

	//Update the positions for the flying models

	for i=1, #self.Models do

		local model = self.Models[i]

		if IsValid( model ) && IsValid( self.GoalEntity ) then

			model.P3 = GetCenterPos( self.GoalEntity ) + self.VecOffset + self.GoalOffset
			model.P2 = model.P3 + Vector( 0, 0, 50 )

			local NewPosition = Bezier(model.P0, model.P1, model.P2, model.P3, model.Percent)
			model.Percent = model.Percent + ( FrameTime() / model.ApproachTime )

			model:SetPos(NewPosition)
			model:SetAngles( model:GetAngles() + Angle( 0, FrameTime() * self.SpinSpeed, FrameTime() * self.SpinSpeed ) )

			if model.Percent >= 1.0 then

				self.FinishCount = self.FinishCount + 1
				self:Arrived()

				-- Remove the model and it's entry in the table
				model:Remove()
				table.remove(self.Models, i)
				i=i-1 -- Go backward, since we just modified the list we're looping through

			end

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

	self:EmitSound( self.MoneySound, self.MoneyVolume, 140 - ( self.FinishCount / self.ModelCount ) * (40 + self.ModelCount*0.20) )

end

function ENT:OnRemove()

	if self.Models then
		for _, v in pairs( self.Models ) do
			if IsValid( v ) then v:Remove() end
		end
	end

	self.Models = nil

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
