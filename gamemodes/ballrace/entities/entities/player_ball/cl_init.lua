include("shared.lua")

local model_offset = Vector(0,0,35)

function ENT:Initialize()

	self.PlayerModel = nil
	self:InitPlayer()

end

function ENT:GetPlayerColor()

	--
	-- Make sure there's an owner and they have this function
	-- before trying to call it!
	--
	local owner = self:GetOwner()
	if ( !IsValid( owner ) ) then return end
	if ( !owner.GetPlayerColor ) then return end

	return owner:GetPlayerColor()

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
	--self.PlayerModel:SetBodygroup( 0, 1 ) // Hat.Bodygroup would probably be something to consider in the future

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

end

function ENT:SelectSequence( ply )

	local velocity = self:GetVelocity():Length()
	local veln = self:GetVelocity():GetNormal()
	local velangle = self:GetVelocity():Angle()

	local seq = self.IdleSeq

	local aim = ply:EyeAngles()

	local rate = 1

	if velocity == 0 then
		ply.myspeed = 0
	elseif velocity > 200 then
		seq = self.RunSeq
		rate = velocity / 300
		ply.myspeed = velocity*1.5
	elseif velocity > 10 then
		seq = self.WalkSeq
		rate = velocity / 100
		ply.myspeed = velocity*1.5
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

local ScaledModels = {
	/*["models/player/sackboy.mdl"] = 0.55,*/
	["models/player/rayman.mdl"] = 0.75,
	["models/player/midna.mdl"] = 0.45,
	["models/player/mcsteve.mdl"] = 0.75,
	["models/player/raz.mdl"] = 0.50,
	["models/player/jawa.mdl"] = 0.65,
	["models/player/sumario_galaxy.mdl"] = 0.45,
	["models/player/suluigi_galaxy.mdl"] = 0.5,
	["models/player/lordvipes/mmz/zero/zero_playermodel_cvp.mdl"] = 0.85,
	["models/vinrax/player/megaman64_player.mdl"] = 0.7,
	["models/player/alice.mdl"] = 0.85,
	["models/player/harry_potter.mdl"] = 0.75,
	["models/player/yoshi.mdl"] = 0.5,
	["models/player/linktp.mdl"] = 0.85,
	["models/player/red.mdl"] = 0.85,
	["models/player/martymcfly.mdl"] = 0.85,
	["models/player/hhp227/kilik.mdl"] = 1.05,
}


function ENT:DrawTranslucent()

	local ply = self:GetOwner()
	if !IsValid(ply) then return end

	if IsValid( self.PlayerModel ) then

		self.PlayerModel:SetModelScale( ScaledModels[self.PlayerModel:GetModel()] or 1, 0 )

		if ply.CosmeticEquipment then
			for k,v in pairs(ply.CosmeticEquipment) do
				if !IsValid(v) then continue end
				v:SetModelScale( ScaledModels[self.PlayerModel:GetModel()] or 1 )
			end
		end

		self.PlayerModel:DrawModel()

		self:GetOwner():ManualBubbleDraw()
		self:GetOwner():ManualEquipmentDraw()

	end

	self.Entity:DrawModel()

	// Draw names
	local name = ply:Name()
	local pos = ( self.Entity:GetPos() + Vector( 0, 0, 48) ):ToScreen()

	if ply != LocalPlayer() then
		if LocalPlayer():GetPos():Distance(self.Entity:GetPos()) < 800 then
			local x, y = pos.x, pos.y
			cam.Start2D()
				draw.SimpleText(name, "BallPlayerName", x + 2, y + 2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(name, "BallPlayerName", x, y, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End2D()
		end
	end

end
