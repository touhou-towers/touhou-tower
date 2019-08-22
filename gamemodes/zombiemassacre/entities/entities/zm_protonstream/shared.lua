ENT.Base			= "base_anim"
ENT.Type			= "anim"
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
	local Trace = util.QuickTrace( AttachInfo.Pos, AttachInfo.Ang:Forward() * 500, weapon.Owner )
	self.StartPos = AttachInfo.Pos
	self.HitPos = Trace.HitPos
	self.Normal = Trace.HitNormal
end
if CLIENT then
	local matBeam				= Material( "particle/bendibeam" )
	local matBeam2				= Material( "effects/tool_tracer" )
	local matLight				= Material( "sprites/powerup_effects" )
	ENT.Color = Color( 255, 10, 10, 255 )
	ENT.Size = 0
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
		local weapon = self:GetOwner()
		self.Size = math.Approach( self.Size, 1, .5 * FrameTime() )

		if IsValid( weapon.Owner.Ghost ) then
			self.Size = math.Approach( self.Size, 4, 2 * FrameTime() )
			self.HitPos = weapon.Owner.Ghost:GetPos() + Vector( 0, 0, 40 )
		end
		self.Dir = ( self.HitPos - self.StartPos )
		self.Inc = self.Dir:Length() / 12 * self.Size
		self.Dir = self.Dir:GetNormal()
		// Inner Beam
		render.SetMaterial( matBeam )
		render.StartBeam( 14 )
			render.AddBeam( self.StartPos, math.Clamp( self.Inc * 1.8, 6, 30 ), CurTime(), Color( self.Color.r * math.Rand( .5, 1 ), self.Color.g, self.Color.b, self.Color.a ) )
			for i = 1, 12 do
				local length = self.Dir:Length() or 1
				local rnd = math.Rand( 1, length * 2 )
				self.Point = ( self.StartPos + self.Dir * ( i * self.Inc ) ) + VectorRand() * rnd
				self.Coord = CurTime() + ( 1 / 12 ) * i
				render.AddBeam( self.Point, math.Clamp( self.Inc * 1.8, 6, 30 ), self.Coord, Color( self.Color.r * math.Rand( .5, 1 ), self.Color.g, self.Color.b, self.Color.a ) )
			end
			render.AddBeam( self.HitPos, math.Clamp( self.Inc * 1.8, 6, 30 ), CurTime() + 1, Color( self.Color.r * math.Rand( .5, 1 ), self.Color.g, self.Color.b, self.Color.a ) )
		render.EndBeam()
		// Inner blue Beam
		local TexOffset = CurTime() * 3
		render.SetMaterial( matBeam2 )
		
		render.StartBeam( 2 )
			render.AddBeam( self.StartPos, 32, TexOffset * .4 - self.StartPos:Distance(self.StartPos) / 256, Color( 255, 255, 255, 80 ) )
			render.AddBeam( self.HitPos, 32, TexOffset * .4 - self.StartPos:Distance(self.HitPos) / 256, Color( 255, 255, 255, 80 ) )
		render.EndBeam()
		// Beam Start Sprite
		render.SetMaterial( matLight )
			render.DrawQuadEasy( self.StartPos + self.Normal, self.Normal, 64 * self.Size, 64 * self.Size, Color( 25, 150, 255 ) )
			render.DrawQuadEasy( self.StartPos + self.Normal, self.Normal, math.Rand(32, 128) * self.Size, math.Rand(32, 128) * self.Size, Color( 25, 150, 255 ) )
			render.DrawQuadEasy( self.StartPos + self.Normal, self.Normal, math.Rand(64, 200), math.Rand(64, 200), Color( 255, 150, 255 ) )
		render.DrawSprite( self.StartPos + self.Normal, 64, 64, Color( 255, 150, 255, self.Size * 255 ) )
		// Beam End Sprite
		render.SetMaterial( matLight )
		
			render.DrawQuadEasy( self.HitPos + self.Normal, self.Normal, 64 * self.Size, 64 * self.Size, Color( 255, 150, 25 ) )
			render.DrawQuadEasy( self.HitPos + self.Normal, self.Normal, math.Rand(32, 128) * self.Size, math.Rand(32, 128) * self.Size, Color( 255, 150, 25 ) )
			render.DrawQuadEasy( self.HitPos - self.Normal, -self.Normal, math.Rand(64, 200), math.Rand(64, 200), Color( 255, 150, 25 ) )
		render.DrawSprite( self.HitPos + self.Normal, 64, 64, Color( 255, 150, 25, self.Size * 255 ) )
		// Sparks
		local effect2 = EffectData()
			effect2:SetOrigin( self.HitPos )
			if self.Normal then effect2:SetNormal( self.Normal ) end
		util.Effect( "proton_spark", effect2 )

		// Decals
		if decal && ( !self.LastDecal || self.LastDecal < CurTime() ) then
			util.Decal( "FadingScorch", self.HitPos + self.Normal, self.HitPos + self.Normal * -20 + VectorRand() * 15 )
			self.LastDecal = CurTime() + 0.01
		end
		if ConVarDLights:GetInt() < 1 then return end
		//Dlights
		local dlight_start = DynamicLight( self:EntIndex() .. "start" )
		if dlight_start then
			dlight_start.Pos = self.StartPos
			dlight_start.r = 255
			dlight_start.g = 150
			dlight_start.b = 150
			dlight_start.Brightness = 1
			dlight_start.Decay = 340
			dlight_start.size = 120
			dlight_start.DieTime = CurTime() + .5
		end
		if ConVarDLights:GetInt() < 2 then return end
		local dlight_end = DynamicLight( self:EntIndex() .. "end" )
		if dlight_end then
			dlight_end.Pos = self.HitPos
			dlight_end.r = 255
			dlight_end.g = 150
			dlight_end.b = 55
			dlight_end.Brightness = 4
			dlight_end.Decay = 320
			dlight_end.size = 80
			dlight_end.DieTime = CurTime() + .5
		end
	end
end //End if CLIENT