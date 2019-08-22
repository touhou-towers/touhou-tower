
-----------------------------------------------------
include("shared.lua")

include("cl_camera.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

surface.CreateFont( "KartPlayerName", { font = "Days", size = 48, weight = 500 } )
surface.CreateFont( "KartBackText", { font = "Days", size = 40, weight = 500 } )
surface.CreateFont( "KartDebug", { font = "Arial", size = 16, weight = 500 } )


CreateClientConVar("sk_camera","1")

local devcvar = true--GetConVar("developer")

ENT.MaxWheelLift = 5
ENT.MaxWheelPitch = 2
ENT.FrameLift = -16
ENT.WheelLift = 2

ENT.Bones = {
	{ "ValveBiped.Bip01_Head1", Angle(0,15,0) },
	{ "ValveBiped.Bip01_Spine1", Angle(0,0,0) },

	{ "ValveBiped.Bip01_L_UpperArm", Angle(0,25,25) },
	{ "ValveBiped.Bip01_L_Forearm", Angle(0,-45,-35) },
	{ "ValveBiped.Bip01_L_Thigh", Angle(5,-15,0) },

	{ "ValveBiped.Bip01_R_UpperArm", Angle(0,25,-25) },
	{ "ValveBiped.Bip01_R_Forearm", Angle(-5,-45,35) },
	{ "ValveBiped.Bip01_R_Thigh", Angle(-10,-15,0) },

	{ "ValveBiped.Bip01_R_Foot", Angle(0,-15,0) },
	{ "ValveBiped.Bip01_L_Foot", Angle(0,-15,0) },

	// MODELS THAT DON'T HAVE FINGERS RIGGED PROPERLY WILL BREAK WITH THIS
	// Fingers... FUCK ME
	/*{ "ValveBiped.Bip01_L_Finger4", Angle(15,-45,0) },
	{ "ValveBiped.Bip01_L_Finger41", Angle(0,-20,0) },
	{ "ValveBiped.Bip01_L_Finger3", Angle(10,-65,0) },
	{ "ValveBiped.Bip01_L_Finger31", Angle(0,-20,0) },

	{ "ValveBiped.Bip01_L_Finger2", Angle(0,-75,0) },
	{ "ValveBiped.Bip01_L_Finger21", Angle(0,-20,0) },

	{ "ValveBiped.Bip01_L_Finger1", Angle(-12,-75,0) },
	{ "ValveBiped.Bip01_L_Finger11", Angle(0,-20,0) },

	{ "ValveBiped.Bip01_L_Finger0", Angle(40,50,80) },
	{ "ValveBiped.Bip01_L_Finger01", Angle(0,20,0) },

	// Fingers... FUCK ME x2
	{ "ValveBiped.Bip01_R_Finger4", Angle(-10,-45,0) },
	{ "ValveBiped.Bip01_R_Finger41", Angle(0,-20,0) },

	{ "ValveBiped.Bip01_R_Finger3", Angle(-10,-65,0) },
	{ "ValveBiped.Bip01_R_Finger31", Angle(0,-20,0) },

	{ "ValveBiped.Bip01_R_Finger2", Angle(0,-75,0) },
	{ "ValveBiped.Bip01_R_Finger21", Angle(0,-20,0) },

	{ "ValveBiped.Bip01_R_Finger1", Angle(12,-75,0) },
	{ "ValveBiped.Bip01_R_Finger11", Angle(0,-20,0) },

	{ "ValveBiped.Bip01_R_Finger0", Angle(-40,50,-80) },
	{ "ValveBiped.Bip01_R_Finger01", Angle(0,20,0) },*/
}

function ENT:Initialize()
	self:SetupDataTables()
	self:SetupSounds()
	//self:SetRenderBounds( Vector(256,256,256), Vector(-256,-256,-256) )

	// Setup wheels
	self.WheelModels = {}

	for id, wheel in pairs( self.Wheels ) do
		self.WheelModels[wheel] = ClientsideModel( "models/gmod_tower/kart/kart_" .. wheel.Model .. ".mdl" )
	end
end


function ENT:SetupSounds()
	self.Sounds = {}

	self.Sounds.Drift = CreateSound( self, "GModTower/sourcekarts/effects/skid_asphalt1.wav" )
	self.Sounds.Drift:PlayEx( 0, 100 )

	self.Sounds.Tire = CreateSound( self, "GModTower/sourcekarts/effects/tires_freeride.wav" )
	self.Sounds.Tire:PlayEx( 0, 80 )

	--if not DEBUG then
		self.Sounds.Engine = CreateSound( self, "GModTower/sourcekarts/effects/engine_idle_loop.wav" )
		self.Sounds.Engine:PlayEx( 1, 25 )
	--end
end


function ENT:GetSpeed()

	if !self:GetIsEngineOn() then
		local ply = self.Owner

		if !IsValid( ply ) then return 0 end

		local fakespeed = 0

		if ply:KeyDown( IN_FORWARD ) then
			fakespeed = 300
		end

		if !self.FakeSpeed then self.FakeSpeed = fakespeed end
		self.FakeSpeed = ApproachSupport2( self.FakeSpeed, fakespeed, 10 )

		return self.FakeSpeed
	end

	local Velocity = self:GetVelocity()
	return Velocity:Length()
end

function ENT:GetSpeedAngle()
	local angle = self:GetAngles()
	local Velocity = self:GetVelocity()

	return angle:Right():Dot( Velocity )
end

function ENT:GetIsDrifting()
	// TODO, use Anomaladox' GetNet() wrapper.
	return self:GetNWBool("Drifting")
end
function ENT:IsVisible()
	// Draw players that are near the leader only when looking at RT
	--[[if DrawRT then
		local leader = GAMEMODE:GetLeader()

		if IsValid( leader ) then
			local dist = self:GetPos():Distance( leader:GetPos() )

			if dist < 1024 then
				return true
			end
		end
	end

	local dist = self:GetPos():Distance( LocalPlayer():GetPos() )

	if dist > 4096 then
		return false
	end]]

	return true
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

function ENT:InitPlayer( ply )

	if !IsValid( ply ) || self.PlayerModel then return end

	self.PlayerModel = ClientsideModel( ply:GetModel() )

	if !IsValid( self.PlayerModel ) then return end

	self.IdleSeq = self.PlayerModel:LookupSequence( "drive_jeep" )

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

function ENT:SetNoDrawAll( bool )
	if IsValid( self.ClientModel ) then
		self.ClientModel:SetNoDraw( bool )
	end

	if IsValid( self.PlayerModel ) then
		self.PlayerModel:SetNoDraw( bool )
	end

	for wheel, model in pairs( self.WheelModels ) do
		model:SetNoDraw( bool )
	end
end

local matWhite = "models/debug/debugwhite"

function ENT:SetAlphaAll( alpha )
	//render.SuppressEngineLighting( alpha < 255 )
	if IsValid( self.ClientModel ) then
		self.ClientModel:SetColor( Color( 255, 255, 255, alpha ) )

		if alpha < 255 then
			self.ClientModel:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.ClientModel:SetMaterial( matWhite )
		else
			self.ClientModel:SetRenderMode( RENDERMODE_NORMAL )
			self.ClientModel:SetMaterial("")
		end
	end

	if IsValid( self.PlayerModel ) then
		self.PlayerModel:SetColor( Color( 255, 255, 255, alpha ) )

		if alpha < 255 then
			self.PlayerModel:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.PlayerModel:SetMaterial( matWhite )
		else
			self.PlayerModel:SetRenderMode( RENDERMODE_NORMAL )
			self.PlayerModel:SetMaterial("")
		end
	end

	for wheel, model in pairs( self.WheelModels ) do
		model:SetColor( Color( 255, 255, 255, alpha ) )
		if alpha < 255 then
			model:SetRenderMode( RENDERMODE_TRANSALPHA )
			model:SetMaterial( matWhite )
		else
			model:SetRenderMode( RENDERMODE_NORMAL )
			model:SetMaterial("")
		end
	end

	self.Alpha = alpha
end

function ENT:Think()
	//if !self.ThinkNext || self.ThinkNext > CurTime() then return end
	//self.ThinkNext = CurTime() + .005

	self.Owner = self:GetOwner()

	local ply = self.Owner

	if !IsValid( ply ) || !ply:Alive() then
		return
	end

	self:SetNoDrawAll( !self:IsVisible() )

	if !self:IsVisible() then
		if self.ItemModels then
			for _, model in pairs( self.ItemModels ) do
				if IsValid( model ) then
					model:Remove()
					model = nil
				end
			end
			self.ItemModels = nil
		end

		return

	end

	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	// Handle sequences
	if IsValid( self.PlayerModel ) then
		self:SelectSequence( ply, self.PlayerModel )
	end

	self.Trace = self:GetDownTrace()

	self:FrameThink( self.Trace )
	self:PlayerModelThink( ply )
	self:ItemModelThink( ply )
	self:WheelThink()

	self:BoostThink()
	self:HeadlightThink()
	self:SoundThink()

	self:IncomingThink( ply )

	// Skid marks
	if self:GetIsDrifting() then
		self:ApplySkidMarks()
	end
end

function ENT:SoundThink()
	// Handle sounds
	if !self.Sounds then return end

	local speed = self:GetSpeed()
	local vol = 0

	if self.Sounds.Tire then
		vol = self:IsGhost() and 0 or math.min( speed/8000, 1 )
		self.Sounds.Tire:ChangeVolume( vol, .5 )
	end

	if self.Sounds.Drift then
		vol = (self:GetIsDrifting() and !self:IsGhost()) and math.min( speed/2000, 1 ) or 0
		self.Sounds.Drift:ChangeVolume( vol, 0.33 )
	end

	if self.Sounds.Engine then
		local EngineSpeed = math.Fit( speed / 8, 0, 150, 50, 120 )

		self.Sounds.Engine:ChangePitch( EngineSpeed, .5 )
		self.Sounds.Engine:ChangeVolume( self:IsGhost() and 0 or 1, 0.1 )
	end
end


function ENT:ItemModelThink( ply )



	if !IsValid( self.ClientModel ) then return end



	// Get item info

	local item = items.Get( ply:GetItem() )



	// Remove unused items

	if !item || !item.Model || !ply:IsItemReady() then



		if self.ItemModels then

			for _, model in pairs( self.ItemModels ) do



				if IsValid( model ) then

					model:Remove()

					model = nil

				end



			end

			self.ItemModels = nil

		end



		return



	end



	// Create models

	if !self.ItemModels && item.Model then



		self.ItemModels = {}

		for i=1, ( item.MaxUses or 1 ) do

			local model = ClientsideModel( item.Model )

			model:SetParent( ply )

			table.insert( self.ItemModels, model )

		end



		ply.LastItemUses = ply:GetItemUses() or 1



	end



	// Auto remove model item

	if self.ItemModels && ply:GetItemUses() != ply.LastItemUses then



		local model = self.ItemModels[1]

		if IsValid( model ) then

			model:Remove()

			model = nil

		end



		table.remove( self.ItemModels, 1 )

		ply.LastItemUses = ply:GetItemUses()



	end



	local ang = self.ClientModel:GetAngles()

	local att = self.ClientModel:GetAttachment( self.ClientModel:LookupAttachment( "back" ) )

	local pos = att.Pos + ( ang:Up() * 8 )

	local color = colorutil.Rainbow( 150 )



	// Position items

	for id, model in pairs( self.ItemModels ) do



		local off = id - 1

		local wide = ply:GetItemUses() - 1

		local spacing = 10



		local scale = .3

		if model:GetModel() == "models/gmod_tower/ball.mdl" then

			scale = .1

		end

		if model:GetModel() == "models/gmod_tower/sourcekarts/stomp.mdl" then

			scale = .5

		end

		if model:GetModel() == "models/props/de_inferno/wine_barrel.mdl" then

			scale = .25

		end



		model:SetModelScale( scale, 0 )

		model:SetPos( pos + ang:Right() * ( ( ( wide * spacing ) / 2 ) - ( off * spacing ) ) )



		local ang = model:GetAngles()

		ang.y = ang.y + 90 * FrameTime()

		ang.p = ang.p + 90 * FrameTime()



		model:SetAngles( ang )

		model:SetRenderAngles( ang )



		model:SetMaterial( "models/wireframe" )

		model:SetColor( color )



	end



	if item.Name == "Shock" then



		local effectdata = EffectData()

			effectdata:SetMagnitude( 2 )

			effectdata:SetEntity( self )

		util.Effect( "TeslaHitBoxes", effectdata, true, true )



	end



	// Draw particle effects

	local particle = self.Emitter:Add( "sprites/powerup_effects", pos )

	if particle then



		particle:SetVelocity( VectorRand() * 30 )

		particle:SetDieTime( math.Rand( .25, .5 ) )

		particle:SetStartAlpha( 100 )

		particle:SetEndAlpha( 0 )

		particle:SetStartSize( math.random( 10, 18 ) )

		particle:SetEndSize( 0 )

		particle:SetRoll( math.Rand( 0, 360 ) )

		particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )

		particle:SetGravity( Vector( 0, 0, -150 ) )

		particle:SetColor( color.r, color.g, color.b )



	end



end

function ENT:BoostThink()
	if self:GetIsBoosting() && !self:IsGhost() then
		if !self.Sounds.Boost then
			self.Sounds.Boost = CreateSound( self, "GModTower/sourcekarts/effects/boost.mp3" )
		end

		local time = CurTime() - self:GetDriftStart()
		local pitch = 75

		if time >= self.Entity.DriftLevels[1] then
			pitch = 85
		end

		if time >= self.Entity.DriftLevels[2] then
			pitch = 95
		end

		if time >= self.Entity.DriftLevels[3] then
			pitch = 105
		end

		if !self.WasBoosting then
			self.Sounds.Boost:Stop()
			self.Sounds.Boost:PlayEx( 1, pitch )
			self.WasBoosting = true
		end
	else
		if self.Sounds.Boost then
			self.Sounds.Boost:FadeOut( .3 )
		end

		self.WasBoosting = false
	end
end

function ENT:PlayerModelThink( ply )
	if !IsValid( self.ClientModel ) then return end

	local KartModel = self.ClientModel

	if !IsValid( self.PlayerModel ) then
		self.PlayerModel = nil
		self:InitPlayer( ply )
	end

	if IsValid( self.PlayerModel ) then
		// Scale down the players
		local mdlscale =  ScaledModels[ self.PlayerModel:GetModel() ] or 1 --GTowerModels.GetScale( self.PlayerModel:GetModel() )
		self.PlayerModel:SetModelScale( mdlscale * .8 )

		local ang = KartModel:GetAngles()

		// Get position offset
		local offset = ( ang:Up() * 2 ) + ( ang:Forward() * -16 )

		// Scale down smaller models
		if mdlscale < 1 then
			offset = ( ang:Up() * ( mdlscale * 15 ) ) + ( ang:Forward() * -16 * ( mdlscale * 1.25 ) )
		end

		self.PlayerModel:SetPlayerProperties( ply )

		self.PlayerModel:SetPos( KartModel:GetPos() + offset )
		self.PlayerModel:SetAngles( ang )
		--ply:ManualEquipmentDraw()
		--ply:ManualBubbleDraw()
	end
end

function ENT:IncomingThink( ply )
	if !IsValid( ply ) then return end
	ply.Incoming = false

	if self:IsGhost() then return end

	local localkart = LocalPlayer():GetKart()

	for _, ent in pairs( ents.FindInSphere( self:GetPos(), 256 ) ) do
		if !IsValid( ent ) then continue end
		if ent.Base != "sk_item_base" then continue end

		local kart = ent:GetOwner()

		if !IsValid( kart ) then continue end

		local owner = kart:GetOwner()

		if !IsValid( owner ) || owner == ply then continue end

		if !util.InFront( ent:GetPos(), localkart ) then
			ply.Incoming = true
		end
	end
end


function ENT:GetTurnAngle()

	local ply = self:GetOwner()

	if ( IsValid(ply) && ply == LocalPlayer() ) then
		if ply:KeyDown(IN_MOVELEFT) then
			return -1
		elseif ply:KeyDown(IN_MOVERIGHT) then
			return 1
		else
			return 0
		end
	else
		return self:GetTurnAngleNet()
	end

end

function ENT:SelectSequence( ply, ent )
	// Reset sequence
	local seq = self.IdleSeq

	if ent:GetSequence() != seq then
		ent:SetPlaybackRate( 1.0 )
		ent:ResetSequence( seq )
		ent:SetCycle( 0 )
	end

	// Breathe
	ent:SetPoseParameter( "breathing", .5 )

	// Turn head
	local HeadYaw = math.NormalizeAngle( self.BodyAngle )
	local TurnAmt = 45

	if self:GetTurnAngle() == -1 then
		HeadYaw = math.NormalizeAngle( TurnAmt - self.BodyAngle )
	elseif self:GetTurnAngle() == 1 then
		HeadYaw = math.NormalizeAngle( -TurnAmt - self.BodyAngle )
	end

	if !self.CurYaw then self.CurYaw = HeadYaw end

	local speed = 5

	if ply:IsSlowed() then speed = speed / GAMEMODE.SlowDownScale end

	self.CurYaw = ApproachSupport2( self.CurYaw, math.Clamp( HeadYaw, -89, 89 ), speed )

	ent:SetPoseParameter( "head_yaw", self.CurYaw )

	// Up/down head
	local angle = self:GetAngles()
	local Velocity = self:GetVelocity()
	local aim = angle:Up():Dot( Velocity )
	local HeadPitch = math.Clamp( aim + 90, 0, 90 )

	if !self.CurPitch then self.CurPitch = HeadPitch end
	self.CurPitch = ApproachSupport2( self.CurPitch, HeadPitch, 5 )

	ent:SetPoseParameter( "head_pitch", self.CurPitch )

	// Adjust bones
	local mdlscale = 1 --GTowerModels.GetScale( self.PlayerModel:GetModel() )
	local speed = self:GetSpeed()

	// Handle feet pedals
	local PedalRAmt, PedalLAmt = 0, 0

	if ply:KeyDown( IN_FORWARD ) then
		PedalRAmt = 20
	end

	if ply:KeyDown( IN_BACK ) then
		PedalLAmt = 20
	end

	if !self.PedalRAmt then self.PedalRAmt = PedalRAmt end
	if !self.PedalLAmt then self.PedalLAmt = PedalLAmt end

	self.PedalRAmt = ApproachSupport2( self.PedalRAmt, PedalRAmt, 5 )
	self.PedalLAmt = ApproachSupport2( self.PedalLAmt, PedalLAmt, 5 )

	for _, bone in pairs( self.Bones ) do
		local name = bone[1]
		local angles = bone[2] * ( mdlscale / 2 )

		// Adjust head up
		if name == "ValveBiped.Bip01_Head1" then
			angles.y = 25
		end

		// Side
		if name == "ValveBiped.Bip01_Spine1" then
			angles.p = angles.p - ( self.CurYaw / 3 )
		end

		// Arms
		if name == "ValveBiped.Bip01_R_UpperArm" then
			angles.y = angles.y - ( self.CurYaw / 10 )
			angles.p = angles.p - ( self.CurYaw / 50 )
		end

		if name == "ValveBiped.Bip01_L_UpperArm" then
			angles.y = angles.y + ( self.CurYaw / 10 )
			angles.p = angles.p + ( self.CurYaw / 50 )
		end

		// Accel
		if name == "ValveBiped.Bip01_R_Foot" then
			angles.y = angles.y + self.PedalRAmt
		end

		// Brake
		if name == "ValveBiped.Bip01_L_Foot" then
			angles.y = angles.y + self.PedalLAmt
		end

		ent:ManipulateBoneAngles( self.PlayerModel:LookupBone( name ) or 0, angles )
	end
end

function ENT:Draw()
	if !self:IsVisible() then return end
	//self:DrawModel()

	local ply = self:GetOwner()
	if !IsValid( ply ) then return end

	if IsValid( self.ClientModel ) then
		self.ClientModel.GetPlayerColor = function()
			if IsValid( ply ) then
				return ply:GetPlayerColor2() / 255
			end

			return Vector(1,1,1)
		end

		if ply.CosmeticEquipment then
			for k,v in pairs( ply.CosmeticEquipment ) do
				v:SetModelScale( ScaledModels[ ply:GetModel() ] or 1 )
			end
		end
		hook.Call( "DrawKart", GAMEMODE, self, self.ClientModel, ply )
	end

	if ( self.Alpha or 1 ) > 0 then
		// Draw the wheel particles
		self:DrawWheels()

		// Draw particles
		self:DrawExhaustParticles()

		// Draw headlights
		self:DrawHeadlights()

		// Draw the player stuff
		self:DrawName( ply )

		if GAMEMODE:IsBattle() then
			self:DrawBattle( ply )
		end

	end

	if ply:IsGhost() then
		if LocalPlayer() == ply then
			self:SetAlphaAll( 50 )
		else
			if ply:Team() != LocalPlayer():Team() && ply:Team() == TEAM_FINISHED then
				self:SetAlphaAll( 0 )
			else
				self:SetAlphaAll( 50 )
			end
		end

		self._Ghost = true
	else
		if self._Ghost then
			self:SetAlphaAll( 255 )
			self._Ghost = false
		end
	end
end

local fallz = 0
local lastLava = 0

function ENT:FrameThink( trace )
	if !IsValid( self.ClientModel ) then
		local scale = LocalPlayer():GetModelScale()

		if scale < 1 then
			self.ClientModel = ClientsideModel( self.ModelSmall )
		else
			self.ClientModel = ClientsideModel( self.Model )
		end
	end

	local ply = self.Owner

	if IsValid( self.ClientModel ) then
		local angles = self:GetAngles()
		local origin = self:GetPos()
		local speed = self:GetSpeed()

		// Trace down for hit pos
		local Traction, MatType = self:GetTraction( trace )

		self.MatType = MatType
		self.HitNormal = trace.HitNormal
		self.HitPos = trace.HitPos

		if self:HitWorld( trace ) then
			local newz = trace.HitPos

			origin = newz + angles:Up() * ( 1 - fallz )

			self.IsInAir = false
		else
			origin = origin + angles:Up() * self.FrameLift

			self.IsInAir = true
		end

		if MatType == "lava" then
			fallz = math.Approach( fallz, 8, RealFrameTime() * 2 )
			lastLava = CurTime()
		else
			if CurTime() - lastLava > .1 then
				fallz = math.Approach( fallz, 0, RealFrameTime() * 50 )
			end
		end

		// Spin
		if self:IsSpinning() && self.SpinAmount then
			self.SpinAmount = ApproachSupport2( self.SpinAmount, 0, 1.5 )
		else
			self.SpinAmount = nil
		end

		angles:RotateAroundAxis( angles:Up(), self.SpinAmount or 0 )

		// Jump
		if self:IsJumping() then
			local speed = 5

			if ply:IsSlowed() then speed = speed / GAMEMODE.SlowDownScale end

			local dt = (RealTime() - self.JumpTime) * speed

			local a = self.JumpHeight

			// Accelerate down faster
			if dt > 1 then
				local downscale = self.JumpDownRate or 1
				dt = ((dt - 1) * downscale) + 1
			end

			self.JumpVel = a - a * math.pow(dt - 1, 2)

			// Jump is done
			if self.JumpVel < 0 then
				self.JumpVel = 0
				self.Jumping = false
			end
		end

		origin = origin + angles:Up() * ( self.JumpVel or 0 )

		self.CurZ = origin.z

		// Forward with speed
		//angles.p = angles.p + ( speed / 250 )

		// Roll with speed
		local yaw = self:GetSpeedAngle() / 100
		angles.r = angles.r - yaw

		// Rumble
		local firstperson = ( GetConVarNumber( "sk_camera" ) == 2 )

		if firstperson then
			origin.z = origin.z + SinBetween( -.05, .05, RealTime() * ( speed / 100 ) * math.random( 1, 2 ) )
			angles.r = angles.r + SinBetween( -.05, .05, RealTime() * ( speed / 100 ) * math.random( 1, 2 ) )
		else
			origin.z = origin.z + SinBetween( -.25, .25, RealTime() * ( speed / 100 ) * math.random( 1, 2 ) )
			angles.r = angles.r + SinBetween( -.15, .15, RealTime() * ( speed / 100 ) * math.random( 1, 2 ) )
		end

		self.ClientModel:SetPos( origin )
		self.ClientModel:SetAngles( angles )
		self.ClientModel:CreateShadow()
	end
end

function ENT:WheelThink()
	if !self.WheelModels then return end


	local KartModel = self.ClientModel

	local speed, forward
	local pitch, yaw, roll = 0, 0, 0
	local ply = self.Owner

	local dist = LocalPlayer():GetPos():Distance( self:GetPos() )

	local isowner = ply == LocalPlayer()
	local complex = isowner || dist < 128

	if complex then
		speed = self:GetSpeed()
		forward = self:GetVelocity():DotProduct( self:GetForward() )
	end

	local framepos = KartModel:GetPos()

	for wheel, model in pairs( self.WheelModels ) do
		// Get attachment
		if !model.Att then model.Att = KartModel:GetAttachment( KartModel:LookupAttachment( wheel.Att ) ) end

		local att = KartModel:GetAttachment( KartModel:LookupAttachment( wheel.Att ) )
		local pos, attang = att.Pos, att.Ang

		local leftwheel = (wheel.Ang == 180)
		local ang = KartModel:GetAngles()

		// === POSITION (LEFT/RIGHT)
		wheelyaw = -90

		if leftwheel then
			wheelyaw = 90
		end

		-- Offset wheels to fix bad attachments
		pos = pos + attang:Forward() * wheel.Extrude

		// === POSITION (UP/DOWN)
		// Wheel offsets
		local offz = ( self.CurZ - framepos.z ) + self.WheelLift // Offset from attachment and the current client body
		local newpos = pos + ang:Up() * offz // Apply offsets

		// More complex suspension stuff
		if isowner then
			local trace = self:GetDownTrace( newpos )
			model.Trace = trace

			// Fake suspension
			if self:HitWorld( trace ) && !self:IsJumping() then
				// Store the material type. We'll be using this for the particles
				local Traction, MatType = self:GetTraction( trace )
				model.MatType = MatType

				local suspos = trace.HitPos + ang:Up() * self.WheelLift
				suspos.z = math.Clamp( suspos.z, newpos.z + ( offz - self.MaxWheelLift ), newpos.z - 1 )

				-- HACK, will fix later
				local delta = math.abs(newpos.z - suspos.z)
				newpos = newpos - ang:Up() * delta

				// Adjust pitch on normal
				-- local Normal = trace.HitNormal:Angle()
				-- Normal.p = math.Clamp( Normal.p, 270 - self.MaxWheelPitch, 270 + self.MaxWheelPitch )
			// Force the wheels to stay up
			else
				newpos = pos
			end
		else
			newpos = pos + ang:Up() * ( offz - 3 )
		end

		pos = newpos

		// === YAW (LEFT/RIGHT)
		// Get wheel yaws

		if complex then
			if wheel.Model == "frontwheel" then
				yaw = self:GetFrontWheelYaw( wheel )
			end
		end

		if wheel.Model == "backwheel" then
			yaw = 0 //self:GetBackWheelYaw( wheel )
		end

		// === ROLL (FORWARD/BACK)
		// Roll the wheels
		if complex then
			if !self.WheelRoll then self.WheelRoll = ang.r end
			if self.WheelRoll > 180 then self.WheelRoll = 0 end

			if leftwheel then speed = speed * -1 end

			if forward < 0 then
				self.WheelRoll = self.WheelRoll - ( math.abs( speed ) / 50 )
			else
				self.WheelRoll = self.WheelRoll + ( math.abs( speed ) / 50 )
			end

			roll = self.WheelRoll

			// No roll for drift
			if self:GetIsDrifting() && wheel.Model == "backwheel" then
				roll = 0
			end

			// No back roll while the engine is off
			if !self:GetIsEngineOn() && wheel.Model == "backwheel" then
				roll = roll / 20
			end

			// Flip roll for opposite side
			if leftwheel then
				roll = roll * -1
			end
		end

		// === PITCH (SIDE)
		// Water transform
		/*local water = self:IsOnWater()
		if water then
			ang:RotateAroundAxis( ang:Forward(), -90 )
		end*/

		// === DRAW
		// Apply all the angles
		-- Rotate angles depending on left or right wheel
		ang:RotateAroundAxis( ang:Up(), leftwheel and -90 or 90 )

		-- Rotate wheel if the kart is turning
		ang:RotateAroundAxis( ang:Up(), yaw )

		-- Rotate the wheel based on velocity
		ang:RotateAroundAxis( ang:Forward(), roll )

		model.Origin = pos

		model:SetPos( pos )
		model:SetAngles( ang )

		model:CreateShadow()
	end
end



function ENT:DrawWheels()



	if !self.WheelModels then return end



	// === WHEEL PARTICLES

	local speed = self:GetSpeed()



	// Draw particles

	local forward = self:GetAngles():Forward()

	local angles = ( forward * 250 )



	for wheel, model in pairs( self.WheelModels ) do



		local pos = model.Origin

		/*if model.Trace then

			pos = model.Trace.HitPos + model:GetAngles():Up() * 4

		end*/



		// Draw smoke for drift/engine off

		if ( self:GetIsDrifting() || !self:GetIsEngineOn() ) && wheel.Model == "backwheel" && speed > 50 then



			if !self:GetIsEngineOn() then

				angles = ( forward * -250 )

			end



			self:DrawWheelParticles( model, pos, angles, "drift" )



		end



		// Draw main wheel particles

		local MatType = self.MatType

		if model.MatType then MatType = model.MatType end



		if MatType then

			self:DrawWheelParticles( model, pos, angles, MatType, speed )

		end



		/*if self.MatType == "surface" then

			local color = colorutil.Rainbow( 150 )

			local scale = SinBetween( 20, 30, RealTime() )

			render.SetMaterial( Material( "sprites/powerup_effects" ) )

			render.DrawSprite( model.Origin + VectorRand() * .5, scale, scale, color )

		end*/



	end



end


function ENT:GetFrontWheelYaw()



	// Turn with keys

	local yaw = 0

	local TurnAmt = 15



	if self:GetTurnAngle() == -1 then

		yaw = math.NormalizeAngle( TurnAmt )

	elseif self:GetTurnAngle() == 1 then

		yaw = math.NormalizeAngle( -TurnAmt )

	end



	// Flip while drifting

	if self:GetIsDrifting() then

		yaw = -math.Clamp( self:GetSpeedAngle(), -25, 25 )

	end



	if !self.WheelFrontYaw then self.WheelFrontYaw = yaw end



	local speed = 5

	if self.Owner:IsSlowed() then speed = speed / GAMEMODE.SlowDownScale end



	self.WheelFrontYaw = ApproachSupport2( self.WheelFrontYaw, math.Clamp( yaw, -80, 80 ), speed )



	return self.WheelFrontYaw



end



function ENT:GetBackWheelYaw( wheel )



	// Turn with velocity changes

	/*local yaw = self:GetSpeedAngle()



	if !self.WheelBackYaw then self.WheelBackYaw = yaw end

	self.WheelBackYaw = ApproachSupport2( self.WheelBackYaw, math.Clamp( yaw, -10, 10 ), 150 )*/



	return 0 //wheel.Yaw



end



function ENT:ThinkBattle( ply )



	if ply:IsGhost() then return end



	local amt = GAMEMODE.MaxLives - ply:Deaths()

	local drawSmokeDelay = nil



	if amt == 2 then

		drawSmokeDelay = .5

	end



	if amt == 1 then



		drawSmokeDelay = .025



		// Shake wheels

		for wheel, model in pairs( self.WheelModels ) do



			local ang = model:GetAngles()

			ang:RotateAroundAxis( ang:Up(), SinBetween( -10, 10, RealTime() * 20 ) )

			ang:RotateAroundAxis( ang:Right(), SinBetween( -10, 10, RealTime() * 20 ) )



			model:SetAngles( ang )



		end



		// Shake frame

		local ang = self.ClientModel:GetAngles()

		ang:RotateAroundAxis( ang:Forward(), SinBetween( -5, 5, RealTime() * 2 ) )



		self.ClientModel:SetAngles( ang )



	end





	if !drawSmokeDelay then return end



	if !self.NextParticle || self.NextParticle < CurTime() then



		self.NextParticle = CurTime() + drawSmokeDelay



		if IsValid( self.Emitter ) then



			// Smoke

			local particle = self.Emitter:Add( "particles/smokey", self.ClientModel:GetPos() + VectorRand():GetNormal() * 20 )

			particle:SetVelocity( VectorRand():GetNormal() * 25 + self.ClientModel:GetUp() * 50 )

			particle:SetDieTime( math.random( 2, 4 ) )

			particle:SetStartAlpha( 100 )

			particle:SetEndAlpha( 0 )

			particle:SetStartSize( math.random( 2, 8 ) )

			particle:SetEndSize( 50 )

			local dark = math.Rand( 100, 250 )

			particle:SetColor( dark, dark, dark )

			particle:SetGravity( Vector( 0, 0, 50 ) )



			// Spark

			if drawSmokeDelay >= .1 then return end

			local particle = self.Emitter:Add( "effects/yellowflare", self.ClientModel:GetPos() )

			particle:SetVelocity( VectorRand():GetNormal() * 50 + self.ClientModel:GetUp() * 150 )

			particle:SetDieTime( math.random( .5, 2 ) )

			particle:SetStartAlpha( 255 )

			particle:SetEndAlpha( 0 )

			particle:SetStartSize( 3 )

			particle:SetEndSize( 0 )

			particle:SetColor( math.random( 230, 255 ), math.random( 230, 255 ), math.random( 230, 255 ) )

			particle:SetRoll( math.random( 0, 360 ) )

			particle:SetGravity( Vector( 0, 0, -200 ) )

			particle:SetCollide( true )

			particle:SetBounce( 0.25 )



		end



	end



end



function ENT:DrawWheelParticles( model, pos, ang, MatType, speed )



	if self:IsJumping() || ( self.Trace && !self:HitWorld( self.Trace ) ) then return end



	pos.z = pos.z + -3



	if MatType == "grass" then



		if speed < 50 then return end

		if model.NextWheelParticle && model.NextWheelParticle > CurTime() then return end



		local particle = self.Emitter:Add( "sprites/skgrass", pos )

		particle:SetVelocity( VectorRand():GetNormal() * 20 )

		particle:SetDieTime( math.random( .5, 2 ) )

		particle:SetStartAlpha( 100 )

		particle:SetEndAlpha( 0 )

		particle:SetStartSize( math.random( 1, 5 ) )

		particle:SetEndSize( 0 )

		local dark = math.Rand( 100, 255 )

		particle:SetColor( dark, dark, dark )

		particle:SetStartLength( 8 )

		particle:SetEndLength( 8 )

		particle:SetCollide( true )

		particle:SetBounce( .1 )

		particle:SetGravity( Vector( 0, 0, -50 ) )



	end



	if MatType == "drift" then



		local particle = self.Emitter:Add( "particles/smokey", pos )

		particle:SetVelocity( VectorRand():GetNormal() * 100 + ang )

		particle:SetDieTime( math.Rand( .25, .5 ) )

		particle:SetStartAlpha( 100 )

		particle:SetEndAlpha( 0 )

		particle:SetStartSize( math.random( 2, 8 ) )

		particle:SetEndSize( 25 )

		local dark = math.Rand( 100, 200 )

		particle:SetColor( dark, dark, dark )

		particle:SetGravity( Vector( 0, 0, -500 ) )



	end



	if MatType == "dirt" then



		if speed < 50 then return end

		if model.NextWheelParticle && model.NextWheelParticle > CurTime() then return end



		local particle = self.Emitter:Add( "effects/fleck_cement1", pos )

		particle:SetVelocity( VectorRand():GetNormal() * 10 )

		particle:SetDieTime( math.random( .5, 2 ) )

		particle:SetStartAlpha( 100 )

		particle:SetEndAlpha( 0 )

		particle:SetStartSize( math.random( 1, 5 ) )

		particle:SetEndSize( 0 )

		local dark = math.Rand( 50, 200 )

		particle:SetColor( dark, dark, dark )

		particle:SetCollide( true )

		particle:SetBounce( .1 )

		particle:SetGravity( Vector( 0, 0, -50 ) )



	end



	if MatType == "sand" then



		if speed < 50 then return end

		if model.NextWheelParticle && model.NextWheelParticle > CurTime() then return end



		local particle = self.Emitter:Add( "effects/fleck_cement1", pos )

		particle:SetVelocity( VectorRand():GetNormal() * 20 )

		particle:SetDieTime( math.random( .5, 2 ) )

		particle:SetStartAlpha( 100 )

		particle:SetEndAlpha( 0 )

		particle:SetStartSize( math.random( 5, 12 ) )

		particle:SetEndSize( 0 )

		particle:SetColor( 239, 228, 176 )

		particle:SetCollide( true )

		particle:SetBounce( .1 )

		particle:SetGravity( Vector( 0, 0, -50 ) )



	end



	if MatType == "lava" then



		if model.NextWheelParticle && model.NextWheelParticle > CurTime() then return end



		if speed > 50 then

			local particle = self.Emitter:Add( "effects/fleck_cement" .. math.random( 1, 2 ), pos )

			particle:SetVelocity( VectorRand():GetNormal() * 50 )

			particle:SetDieTime( math.random( .5, 1 ) )

			particle:SetStartAlpha( 255 )

			particle:SetEndAlpha( 0 )

			particle:SetStartSize( math.random( 2, 5 ) )

			particle:SetEndSize( 10 )

			particle:SetColor( math.random( 150, 255 ), 0, 0 )

			particle:SetCollide( true )

			particle:SetBounce( .2 )

			particle:SetGravity( Vector( 0, 0, -150 ) )



			local particle = self.Emitter:Add( "effects/fleck_cement2", pos )

			particle:SetVelocity( VectorRand():GetNormal() * 50 )

			particle:SetDieTime( math.random( .5, 1 ) )

			particle:SetStartAlpha( 255 )

			particle:SetEndAlpha( 0 )

			particle:SetStartSize( math.random( 1, 2 ) )

			particle:SetEndSize( 0 )

			particle:SetColor( 255, 127, 20 )

			particle:SetCollide( true )

			particle:SetBounce( .2 )

			particle:SetGravity( Vector( 0, 0, -150 ) )

		end



		local particle = self.Emitter:Add( "particles/flamelet" .. math.random( 1 , 5 ), pos + ( VectorRand() * ( self:BoundingRadius() * .15 ) ) )

		particle:SetVelocity( Vector( 0, 0, 50 ) )

		particle:SetDieTime( math.Rand( .25, 1.25 ) )

		particle:SetStartAlpha( math.random( 150, 255 ) )

		particle:SetEndAlpha( 0 )

		particle:SetStartSize( math.Rand( .15, .75 ) )

		particle:SetEndSize( 10 )

		particle:SetColor( 255, 255, 255 )

		particle:SetCollide( true )

		particle:SetGravity( Vector( 0, 0, 50 ) )



		model.NextWheelParticle = CurTime() + .05

		return



	end



	model.NextWheelParticle = CurTime() + .015



end



local SkidMaterial = Material( "Decals/tread" )

local SkidColor = Color(255,255,255,140)

function ENT:ApplySkidMarks()



	if !self.WheelModels

		or self:IsGhost()

		or !self:IsVisible()

		or self:IsJumping() then return end



	for wheel, model in pairs( self.WheelModels ) do



		if wheel.Model == "frontwheel" then continue end



		local trace = model.Trace or self:GetDownTrace( model.Origin )



		if trace.Hit then



			local pos = trace.HitPos



			-- Don't draw skidmarks too closely to each other

			if model._lastSkidPos and ( pos - model._lastSkidPos ):Length() < 5 then

				continue

			end



			util.DecalEx( SkidMaterial, trace.Entity, pos, trace.HitNormal, SkidColor, 1, 1 )

			-- util.Decal( "decal_skidmark01", pos, trace.HitNormal )



			model._lastSkidPos = pos



		end



	end



end



local matFire		= Material( "effects/fire_cloud1" )

local matHeatWave	= Material( "sprites/heatwave" )

local matSprite 	= Material( "sprites/heatwave" )

function ENT:DrawExhaustParticles()



	if !IsValid( self.ClientModel ) then return end

	if not self.Emitter then return end



	local KartModel = self.ClientModel

	local speed = self:GetSpeed()



	// Get attachments

	local attL = KartModel:GetAttachment( KartModel:LookupAttachment( "exhaust_left" ) )

	local attR = KartModel:GetAttachment( KartModel:LookupAttachment( "exhaust_right" ) )



	// Get positions

	local posL, angL = attL.Pos, attL.Ang

	local posR, angR = attR.Pos, attR.Ang



	local scale = .25



	// Draw particles

	local function drawParticles( pos, ang )



		// Drift is ready

		/*if self:GetIsDriftReady() && !self:GetIsDrifting() then



			local color = Color( 0, 255, 0 )

			local scale = 10

			render.SetMaterial( Material( "sprites/powerup_effects" ) )

			render.DrawSprite( pos + VectorRand() * .5 + ang:Forward(), scale, scale, color )



		end*/



		// Drift indicator

		if self:GetIsDrifting() then



			local time = CurTime() - self:GetDriftStart()



			if time > self.Entity.DriftMinimum then



				local scale = math.Clamp( 10 * time, 5, 30 ) * 2

				local color = Color( 255, 255, 255 )



				if time >= self.Entity.DriftLevels[1] then

					color = Color( 155, 255, 255 )

				end

				if time >= self.Entity.DriftLevels[2] then

					color = Color( 150, 150, 255 )

				end

				if time >= self.Entity.DriftLevels[3] then

					color = Color( 255, 150, 255 )

				end



				self.DriftColor = color



				// TODO: Change this material!!

				render.SetMaterial( Material( "sprites/powerup_effects" ) )

				render.DrawSprite( pos + VectorRand() * 1 + ang:Forward() * -1, scale, scale, color )



			end



		end



		// Boosting

		if self:GetIsBoosting() || self:IsRevved() then



			// Flame puffs

			local particle = self.Emitter:Add( "effects/muzzleflash" .. math.random(1,4), pos )

			particle:SetVelocity( VectorRand():GetNormal() * 30 + Vector(0,0,20) )

			particle:SetDieTime( math.Rand( 0.1, 0.2 ) )

			particle:SetStartAlpha( 255 )

			particle:SetEndAlpha( 0 )

			particle:SetStartSize( math.random( 10, 15 ) )

			particle:SetEndSize( 0 )

			particle:SetColor( math.Rand( 150, 255 ), math.Rand( 100, 150 ), 100 )

			particle:SetAirResistance( 50 )



			// Flame throw

			local scroll = (CurTime() * -10)

			local normal = self:GetVelocity():GetNormal() * -1

			if self:IsRevved() then normal = self:GetForward() * -1 end



			render.SetMaterial( matFire )



			render.StartBeam( 3 )

				render.AddBeam( pos, 8 * scale, scroll, Color( 0, 0, 255, 128) )

				render.AddBeam( pos + normal * 60 * scale, 32 * scale, scroll + 1, Color( 255, 255, 255, 128) )

				render.AddBeam( pos + normal * 148 * scale, 32 * scale, scroll + 3, Color( 255, 255, 255, 0) )

			render.EndBeam()



			scroll = scroll * 0.5

			render.UpdateRefractTexture()

			render.SetMaterial( matHeatWave )

			render.StartBeam( 3 )

				render.AddBeam( pos, 8 * scale, scroll, Color( 0, 0, 255, 128) )

				render.AddBeam( pos + normal * 32 * scale, 32 * scale, scroll + 2, Color( 255, 255, 255, 255) )

				render.AddBeam( pos + normal * 128 * scale, 48 * scale, scroll + 5, Color( 0, 0, 0, 0) )

			render.EndBeam()



			scroll = scroll * 1.3

			render.SetMaterial( matFire )

			render.StartBeam( 3 )

				render.AddBeam( pos, 8 * scale, scroll, Color( 0, 0, 255, 128) )

				render.AddBeam( pos + normal * 60 * scale, 16 * scale, scroll + 1, Color( 255, 255, 255, 128) )

				render.AddBeam( pos + normal * 148 * scale, 16 * scale, scroll + 3, Color( 255, 255, 255, 0) )

			render.EndBeam()



			// Refract

			render.SetMaterial( matSprite )

			render.DrawSprite( pos, scale * 32, scale * 32, Color( 255, 0, 0, 15 ) )



			// Rainbow Sprite

			local color = self.DriftColor or colorutil.Rainbow( 200 )

			local scale = 15

			if self:IsRevved() then scale = 80 end



			render.SetMaterial( Material( "sprites/powerup_effects" ) )

			render.DrawSprite( pos + VectorRand() * 1 + ang:Forward() * -1, scale, scale, color )



		end



		// Small puffs of smoke

		if speed < 80 && LocalPlayer() == self.Owner then



			local particle = self.Emitter:Add( "particles/smokey", pos )

			particle:SetVelocity( VectorRand():GetNormal() * 5 )

			particle:SetDieTime( math.random( .1, .2 ) )

			particle:SetStartAlpha( 100 )

			particle:SetEndAlpha( 0 )

			particle:SetStartSize( math.Rand( 1, 1.5 ) )

			particle:SetEndSize( 2 )

			local dark = math.Rand( 100, 150 )

			particle:SetColor( dark, dark, dark, 150 )

			particle:SetGravity( Vector( 0, 0, 100 ) )



		end



		/*local dark = math.random( 50, 150 )

		local color = Color( dark, dark, dark, 50 )

		local scale = math.Fit( speed, 0, 800, 2, 10 )

		render.SetMaterial( Material( "particles/smokey" ) )

		render.DrawSprite( pos + VectorRand() * 2 + ang:Forward() * -2, scale, scale, color )*/



	end



	drawParticles( posL, angL )

	drawParticles( posR, angR )



end



function ENT:HeadlightThink()



	/*local color = render.GetLightColor( self:GetPos() + Vector( 0, 0, 32 ) )

	local brightness = color:Length()

	if !self.NextHeadlight || self.NextHeadlight > CurTime() then return end

	self.NextHeadlight = CurTime() + 1*/



	local on = true



	if self.HeadlightsOn != on then



		--net.Start( "KartLights" )

			--net.WriteEntity( self )

			--net.WriteBit( on )

		--net.SendToServer()



	end



	self.HeadlightsOn = on



end



function ENT:DrawHeadlights()



	if !IsValid( self.ClientModel ) then return end



	// Draw light

	local function drawLight( id, pos, ang )



		local color = Color( 255, 255, 200, math.random( 50, 255 ) )

		local scale = 15



		render.SetMaterial( Material( "sprites/powerup_effects" ) )

		render.DrawSprite( pos, scale, scale, color )



		local dlight = DynamicLight( self:EntIndex() .. id )

		if dlight then

			dlight.Pos = pos + ang:Forward() * 2

			dlight.r = 255

			dlight.g = 255

			dlight.b = 200

			dlight.Brightness = .5

			dlight.Decay = 512

			dlight.size = 256

			dlight.DieTime = CurTime() + .1

		end



	end



	if self.HeadlightsOn then



		local attL = self.ClientModel:GetAttachment( self.ClientModel:LookupAttachment( "light_left" ) )

		local attR = self.ClientModel:GetAttachment( self.ClientModel:LookupAttachment( "light_right" ) )



		// Get positions

		local posL, angL = attL.Pos, attL.Ang

		local posR, angR = attR.Pos, attR.Ang



		drawLight( 1, posL, angL )

		drawLight( 2, posR, angR )



	end



end



function ENT:DrawName( ply )



	if !IsValid( self.ClientModel ) then return end

	if ply:IsGhost() then return end



	local kart = ply:GetKart()

	local localkart = LocalPlayer():GetKart()

	if !IsValid( kart ) || !IsValid( localkart ) || ply == LocalPlayer() then return end



	/*local infront = false

	if IsValid( kart ) && IsValid( localkart ) then

		infront = ( kart:GetPos() - localkart:GetPos() ):DotProduct( localkart:GetForward() ) > 0

	end



	if !infront then return end*/



	local dist = localkart:GetPos():Distance( kart:GetPos() )

	local alpha = math.Fit( dist, 128, 1024, 0, 1 )

	if ply:Team() == TEAM_FINISHED then alpha = 50 end



	local ang = LocalPlayer():EyeAngles()

	local pos = self.ClientModel:GetPos() + self.ClientModel:GetAngles():Up() * ( 52 + ( math.sin( RealTime() ) * 2 ) )



	ang:RotateAroundAxis( ang:Forward(), 90 )

	ang:RotateAroundAxis( ang:Right(), 90 )



	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .5 )

		draw.SimpleShadowText( ply:GetName(), "KartPlayerName", 0, 0, Color( 255, 255, 255, 255 * alpha ), Color( 0, 0, 0, 50 * alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2 )

	cam.End3D2D()



end



function ENT:DrawBattle( ply )



	if !IsValid( self.ClientModel ) then return end

	if ply:IsGhost() || GAMEMODE:GetState() != STATE_BATTLE then return end



	local amt = GAMEMODE.MaxLives - ply:Deaths()

	local color = HSVToColor( 35 * amt, 1, 1 )



	local ang = LocalPlayer():EyeAngles()

	local pos = self.ClientModel:GetPos() + self.ClientModel:GetAngles():Up() * ( 40 + ( math.sin( RealTime() ) * 2 ) )



	ang:RotateAroundAxis( ang:Forward(), 90 )

	ang:RotateAroundAxis( ang:Right(), 90 )



	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .5 )

		for i=1, amt do

			draw.SimpleShadowText( "•", "KartPlayerName", ( 20 * ( amt - 1 ) ) - ( i * 20 ), 0,color, Color( 0, 0, 0, 50 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2 )

		end

	cam.End3D2D()



end



function ENT:Spin()

	local rnd = math.random( 0, 1 )

	if rnd == 0 then rnd = -1 end

	self.SpinAmount = 360 * 3 * rnd

end



function ENT:IsSpinning()

	return self.SpinAmount && self.SpinAmount != 0

end



/*usermessage.Hook( "KartSpin", function( um )



	local kart = um:ReadEntity()



	if IsValid( kart ) then

		kart:Spin()

	end



end )
*/

net.Receive( "KartSpin", function()
	local kart = net.ReadEntity()

	if IsValid( kart ) then
		kart:Spin()
	end
end)


function ENT:Jump( height, downrate )



	if self:IsJumping() then return end

	if self:IsSpinning() then return end

	if !self:HitWorld( self.Trace ) then return end



	self.JumpHeight = height or 10

	self.JumpDownRate = downrate or 1.5



	self.JumpVel = 0.1



	self.JumpTime = RealTime()

	self.Jumping = true


	if self:GetOwner() == LocalPlayer() then
		self:EmitSound("gmodtower/sourcekarts/effects/jump.wav",75)
	end

end



function ENT:IsJumping()

	return self.Jumping

end



/*usermessage.Hook( "KartJump", function( um )



	local kart = um:ReadEntity()

	local height = um:ReadChar() * 5

	local downrate = um:ReadChar() * .25



	if height == 0 then height = 10 end

	if downrate == 0 then downrate = 1.5 end



	if IsValid( kart ) then

		kart:Jump( height, downrate )

	end



end )
*/

net.Receive("KartJump",function()
	local ply = net.ReadEntity()
	local kart = net.ReadEntity()
	local height = net.ReadFloat() * 5

	local downrate = net.ReadFloat() * .25


	if ply == LocalPlayer() then return end

	if height == 0 then height = 10 end

	if downrate == 0 then downrate = 1.5 end



	if IsValid( kart ) then

		kart:Jump( height, downrate )

	end

end)


function ENT:Rev()



	if self:IsRevved() then return end

	self.RevTime = CurTime()



end



function ENT:IsRevved()

	return false

end







function ENT:OnRemove()



	if IsValid( self.ClientModel ) then

		self.ClientModel:Remove()

		self.ClientModel = nil

	end



	if IsValid( self.PlayerModel ) then

		self.PlayerModel:Remove()

		self.PlayerModel = nil

	end



	if self.WheelModels then

		for _, wheel in pairs( self.WheelModels ) do

			if IsValid( wheel ) then

				wheel:Remove()

			end

		end

		self.WheelModels = {}

	end


	if self.ItemModels then

		for _, model in pairs( self.ItemModels ) do



			if IsValid( model ) then

				model:Remove()

				model = nil

			end



		end

		self.ItemModels = nil

	end



	if IsValid( self.Owner ) then

		--self.Owner:ResetEquipmentScale()

	end



	if self.Sounds then

		for _, sound in pairs( self.Sounds ) do

			sound:Stop()

		end

	end



end







// ============ BUNCH OF DEBUG STUFF



/*local velocities = {}



hook.Add( "HUDPaint", "VisualizeVelocity", function()




	if !velocities then velocities = {} end



	local kart = LocalPlayer():GetKart()

	if !IsValid( kart ) then return end



	table.insert( velocities, { kart:GetVelocity():Length(), kart:GetIsDrifting(), kart:GetIsBoosting() } )



	if #velocities > ScrW() then

		table.remove( velocities, 1 )

	end



	for id, data in pairs( velocities ) do



		local x = id

		local speed = data[1]

		local drift = data[2]

		local boost = data[3]



		speed = speed * .2



		if x > ScrW() then

			velocities = {}

		end



		surface.SetDrawColor( Color( 255, 255, 255, 50 ) )



		if drift then

			surface.SetDrawColor( Color( 255, 0, 0, 50 ) )

		end



		if boost then

			surface.SetDrawColor( Color( 0, 255, 0, 50 ) )

		end



		surface.DrawRect( x, ScrH() - speed, 1, speed )



	end



end )
*/




--[[if (1+1==2) then



	local Car

	local AngleVel = Vector()

	local LinearVel = Vector()

	local IsDrifiting = false

	local Forward = Vector()

	local Angular = Vector()



	local Mat = Material( "effects/tool_tracer" )



	usermessage.Hook("KartInfo", function(um)

		AngleVel = um:ReadVector()

		LinearVel = um:ReadVector()

		Forward = um:ReadVector()

		Angular = um:ReadVector()

		IsDrifiting = um:ReadBool()

	end )



	hook.Add("HUDPaint", "GTowerDebugPaint223", function()



		Car = LocalPlayer():GetKart()

		if !IsValid( Car ) then

			return

		end



		local Trace = util.QuickTrace( Car:GetPos() + Vector(0,0,5), Vector(0,0,-500), {Car, LocalPlayer()} )



		local Str = ""



		//for k, v in pairs( Trace ) do

		//	Str = Str .. k .. " = " .. tostring(v) .. "\n"

		//end



		local Angles = Car:GetAngles()

		//Angles:RotateAroundAxis( Vector(0,0,1), -Angles.y )

		local Up = Angles:Up()



		Angles.p = 0



		Up:Rotate( Angles * -1 )



		Str = Str .. "\nVel = " .. tostring(Car:GetVelocity():Length()) .. "\n"

		Str = Str .. "AngVel = " .. tostring(AngleVel) .. "\n"

		Str = Str .. "Up = " .. tostring(Up) .. "\n"

		//Str = Str .. "VelAngle = " .. tostring(Car:GetVelocity():GetNormal():GetAngles()) .. "\n\n"







		//Str = Str .. "Cross = " .. tostring(Up:Cross(Vector(0,0,1))) .. "\n"

		//Str = Str .. "Dot = " .. tostring(Up:Dot(Vector(0,0,1)))



		Str = Str .. "Drifiting = " .. tostring( Car:GetIsDrifting() ) .. "\n"

		Str = Str .. "Dot = " .. tostring( LinearVel:Dot( Car:GetRight() ) )







		//Str = Str .. "\n\nGamestate: " .. tostring(GetWorldEntity().GameState) .. "\n"

		//Str = Str .. "Timeleft: " .. tostring(GetWorldEntity().NextTime) .. " (".. GAMEMODE:TimeLeft() ..")"



		surface.SetFont("Default")

		local w,h = surface.GetTextSize(Str)



		surface.SetDrawColor(0,0,0,255)

		surface.DrawRect( 0,0, w,h)



		draw.DrawText(Str, "Default", 0,0, Color(255,255,255,255))

	end)

end
]]


/*concommand.Add("gmt_kartprint", function( ply )



	if !ply:IsAdmin() then return end



	for k, v in pairs( Settings ) do



		print( k .. "=", v[1] )



	end



end )*/
