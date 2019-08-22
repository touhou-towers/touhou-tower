include("shared.lua")
include("cl_choose.lua")

local model_offset = Vector(0,0,35)

surface.CreateFont( "BallPlayerName", { font = "Coolvetica", size = 26, weight = 400 } )

// thirdperson support
if ThirdPerson then
	ThirdPerson.ExcludeEnt( "gmt_ballrace" )
else
	Msg( "ThirdPerson module not loaded, camera for ball orb will be bugged!!\n" )
end

hook.Add( "ForceThirdperson", "ForceThirdpersonBall", function( ply )

	return IsValid( ply.BallRaceBall )

end )

hook.Add( "OverrideHatEntity", "OverrideHatBallRace", function( ply )

	//local ball = ply:GetBallRaceBall()
	if IsValid( ply ) and ply:IsPlayer() and IsValid( ply.BallRaceBall ) then
		return ply.BallRaceBall.PlayerModel
	end

end )

function ENT:Initialize()

	self.PlayerModel = nil
	self:InitPlayer()

end

function ENT:InitPlayer()

	local ply = self:GetOwner()
	if !IsValid( ply ) || self.PlayerModel then return end

	local Model = ply:GetModel()

	self.PlayerModel = ClientsideModel( Model )
	if !IsValid( self.PlayerModel ) then return end

	self.PlayerModel:SetSkin( ply:GetSkin() or 1 )

	self.IdleSeq = self.PlayerModel:LookupSequence( "idle_all_01" )

	if self.IdleSeq <= 0 then

		local model = ply:GetTranslatedModel()
		self.PlayerModel:Remove()

		if util.IsValidModel( model ) then

			self.PlayerModel = ClientsideModel( model ) // using SetModel messes up everything, recreate it
			self.IdleSeq = self.PlayerModel:LookupSequence("idle_all_01")

		end

	end

	if !IsValid( self.PlayerModel ) then return end

	self.PlayerModel:SetNoDraw( true )

	if Model == "models/uch/pigmask.mdl" then
		self.WalkSeq = self.PlayerModel:LookupSequence("walk")
		self.IdleSeq = self.PlayerModel:LookupSequence("idle")
		self.RunSeq = self.PlayerModel:LookupSequence("run")
	elseif Model == "models/uch/mghost.mdl" then
		self.WalkSeq = self.PlayerModel:LookupSequence("walk")
		if ply:IsVIP() then
			self.IdleSeq = self.PlayerModel:LookupSequence("Idle2")
			self.WalkSeq = self.PlayerModel:LookupSequence("walk2")
		else
			self.IdleSeq = self.PlayerModel:LookupSequence("Idle1")
		end
		self.RunSeq = self.WalkSeq
	else
		self.WalkSeq = self.PlayerModel:LookupSequence("walk_all")
		self.RunSeq = self.PlayerModel:LookupSequence("run_all_01")
	end


	self.PlayerModel:ClearPoseParameters()
	self.PlayerModel:ResetSequenceInfo()
	self.PlayerModel:SetBodygroup( 0, 1 ) // Hat.Bodygroup would probably be something to consider in the future

	self.PlayerModel:ResetSequence(self.IdleSeq)
	self.PlayerModel:SetCycle(0.0)

	self.BodyAngle = 0

	self.LastAngle = Angle(0,0,0)
	self.LastBlip = 0
	self.AngleAccum = Angle(0,0,0)

end

function ENT:OnRemove()

	if IsValid(self.PlayerModel) then
		self.PlayerModel:Remove()
		self.PlayerModel = nil
	end

	local owner = self:GetOwner()

	if IsValid( owner ) then
		--owner:ResetEquipmentScale()
	end

end

function ENT:SelectSequence( ply )

	local velocity = self:GetVelocity():Length()
	local veln = self:GetVelocity():GetNormal()
	local velangle = self:GetVelocity():Angle()

	local seq = self.IdleSeq

	local aim = ply:EyeAngles()

	local rate = 1

	if velocity > 200 then
		seq = self.RunSeq
		rate = velocity / 300
	elseif velocity > 10 then
		seq = self.WalkSeq
		rate = velocity / 100
	end

	rate = math.Clamp(rate, 0.1, 2)

	if ( self.PlayerModel:GetSequence() != seq ) then
		self.PlayerModel:SetPlaybackRate( 1.0 )
		self.PlayerModel:ResetSequence( seq )
		self.PlayerModel:SetCycle( 0 )
	end

	if seq != self.IdleSeq then
		self.BodyAngle = aim.y
	else
		local diff = math.NormalizeAngle( aim.y - self.BodyAngle )
		local abs = math.abs( diff )
		if abs > 45 then
			local norm = math.Clamp( diff, -1, 1 )
			self.BodyAngle = math.NormalizeAngle( self.BodyAngle + ( diff - 45 * norm ) )
		end
	end

	local HeadYaw = math.NormalizeAngle( aim.y - self.BodyAngle )
	local MoveYaw = math.NormalizeAngle( velangle.y - self.BodyAngle )

	self.PlayerModel:SetAngles( Angle( 0, self.BodyAngle, 0 ) )
	self.PlayerModel:SetPos( self:GetPos() - model_offset )

	self.PlayerModel:SetPoseParameter( "breathing", 0.4 )


	self.PlayerModel:SetPoseParameter( "head_pitch", math.Clamp( aim.p - 40, -19, 20 ) )
	self.PlayerModel:SetPoseParameter( "head_yaw", HeadYaw )
	self.PlayerModel:SetPoseParameter( "move_yaw", MoveYaw )

	local forward, right = aim:Forward(), aim:Right()
	local dot = veln:Dot( forward )
	local dotr = veln:Dot(right)

	local spd = math.Clamp( velocity / 100, 0, 1 )

	self.PlayerModel:SetPoseParameter( "body_pitch", -aim.p )

	self.PlayerModel:SetPoseParameter( "move_x", spd * dot )
	self.PlayerModel:SetPoseParameter( "move_y", spd * dotr )

	self.PlayerModel:FrameAdvance( FrameTime() * rate )

end

function ENT:Think()
	// BUG: Invisible players inside the ball
	// the CSEnt is IsValid, but GetModel throws an error
	/*
	] lua_run_cl print(LocalPlayer():GetBall().PlayerModel)
	CSEnt: 02EA39B8
	] lua_run_cl print(LocalPlayer():GetBall().PlayerModel:GetModel())
	:1: Tried to use a NULL entity!
	*/

	if !IsValid(self.PlayerModel) || !self.PlayerModel:GetModel() then
		self.PlayerModel = nil
		self:InitPlayer()
		if !IsValid(self.PlayerModel) then return end
	end

	local pl = self:GetOwner()

	if !IsValid(pl) then return end

	self:SelectSequence(pl)

	local velocity = self:GetVelocity():Length()

	local anglediff = self:GetAngles() - self.LastAngle
	self.LastAngle = self:GetAngles()
	anglediff.p, anglediff.y, anglediff.r = math.abs(anglediff.p), math.abs(anglediff.y), math.abs(anglediff.r)
	self.AngleAccum = self.AngleAccum + anglediff

	if CurTime() > (self.LastBlip + (100/velocity) ) && (self.AngleAccum.p > 180 || self.AngleAccum.y > 180 || self.AngleAccum.r > 180) then
		self.Entity:EmitSound(self.RollSound, 100, 150)
		self.AngleAccum = Angle(0,0,0)
		self.LastBlip = CurTime()
	end

end

function ENT:DrawTranslucent()

	local ply = self:GetOwner()
	if !IsValid(ply) then return end

	if IsValid( self.PlayerModel ) then

		local scale = GTowerModels.GetScale( self.PlayerModel:GetModel() )
		if string.StartWith(self.PlayerModel:GetModel(), "models/player/redrabbit") then scale = 0.7 end
		self.PlayerModel:SetModelScale( scale * .775, 0 )

		self.PlayerModel:DrawModel()
		ply:ManualEquipmentDraw()
		ply:ManualBubbleDraw()

	end

	self.Entity:SetModelScale( 0.875, 0 )
	self.Entity:DrawModel()

end
