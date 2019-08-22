

-----------------------------------------------------

ENT.Base		= "base_anim"
ENT.Type		= "anim"

ENT.PrintName		= "Racing Ring"
ENT.Author			= "Zachary Blystone"
ENT.Information		= "Ring ding ding ding ding"
ENT.Category		= "Fun + Games"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

local ActivateSound = Sound( "gmodtower/arcade/trivia/guess3.wav" )
local BlipSound = Sound( "buttons/blip1.wav" )
local BlipSound2 = Sound( "buttons/button15.wav" )

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 0, "RingSize"  );
	self:NetworkVar( "Int", 1, "State" );

end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos

	--[[local ent = ents.Create( "race_ring" )
	ent:SetPos(ply:GetPos() + ply:OBBCenter() + ply:EyeAngles():Forward() * 200)
	ent:SetAngles(ply:EyeAngles())
	ent:Spawn()
	ent:Activate()
	ent:SetRingSize(60)]]

	return ent

end

if SERVER then

	function ENT:SetTriggerCallback(cb)
		if type(cb) ~= "function" then return end
		self.callback = cb
	end

	function ENT:SetNextRing(r)
		self.nextRing = r
	end

	function ENT:GetNextRing()
		return self.nextRing
	end

	function ENT:Initialize()
		self:NetworkVarNotify( "State", self.OnStateChanged );
		if SERVER then
			self:DrawShadow( false )
		end
	end

	function ENT:GetActivator()
		return self.Activator
	end

	function ENT:OnStateChanged( varname, pstate, istate )

		if self.callback and istate == 2 and pstate == 1 then
			local b,e = pcall(self.callback, self:GetActivator())
			if b and e then return end
		end

		if istate == 1 and pstate ~= istate then
			sound.Play( BlipSound, self:GetPos(), 120, math.random( 90, 120 ), 1 )
		end

		if istate == 2 then
			sound.Play( BlipSound2, self:GetPos(), 120, 40, 1 )
			if pstate ~= istate then
				sound.Play( ActivateSound, self:GetPos(), 120, math.random( 90, 120 ), 1 )
				local nextring = self:GetNextRing()
				if nextring then
					nextring:SetState(1)
				end
			end
		end

	end

	function ENT:Intersects(p0, p1)
		local pos = self:GetPos()
		local n = self:GetForward()
		local ndist = n:Dot(pos)
		local d0 = p0:Dot(n) - ndist
		local d1 = p1:Dot(n) - ndist

		if d0 == d1 then return 0 end

		local t = d0 / (d0 - d1)
		local i = p0 + (p1 - p0) * t

		local lx = self:GetRight():Dot(i - pos)
		local ly = self:GetUp():Dot(i - pos)
		local ld = math.sqrt(lx*lx + ly*ly)

		if ld > self:GetRingSize() + 10 then return 0 end

		if d0 < 0 and d1 > 0 then --Entering front
			return 1
		elseif d0 > 0 and d1 < 0 then --Entering back
			return -1
		end

		return 0
	end

	function ENT:Think()

		if self:GetState() ~= 0 then

			self.ptab = self.ptab or {}

			for k,v in pairs(player.GetAll()) do

				local pos = (v:GetPos() + v:OBBCenter())
				self.ptab[k] = self.ptab[k] or pos

				if self:Intersects(self.ptab[k], pos) ~= 0 then
					self.Activator = v
					self:SetState(2)
					self.Activator = nil
				end

				self.ptab[k] = pos

			end

		end

		self:NextThink(CurTime() + .04)
		return true

	end

end

if SERVER then return end

local params = {
	["$basetexture"] = "color/white",
	["$additive"] = 0,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
}
local whiteTex = CreateMaterial("White01", "UnlitGeneric", params)

function ENT:DrawCircle(radius, color)

	local r1 = radius
	local r2 = radius + 10
	local w = 3

	local color2 = Color(60,60,60,255)

	local pos = self:GetPos()
	local f,r,u = self:GetForward(), self:GetRight(), self:GetUp()
	local rad = math.pi / 180
	local front = pos - f * w
	local back = pos + f * w
	local rot = CurTime()

	for i=0, 340, 40 do
		local a0 = i * rad + rot
		local a1 = (i + 40) * rad + rot
		local ca0 = math.cos(a0)
		local ca1 = math.cos(a1)
		local sa0 = math.sin(a0)
		local sa1 = math.sin(a1)

		local v0 = u * sa0 * r2 + r * ca0 * r2 + back
		local v1 = u * sa1 * r2 + r * ca1 * r2 + back
		local v2 = u * sa1 * r1 + r * ca1 * r1 + back
		local v3 = u * sa0 * r1 + r * ca0 * r1 + back
		local v4 = u * sa0 * r2 + r * ca0 * r2 + front
		local v5 = u * sa1 * r2 + r * ca1 * r2 + front
		local v6 = u * sa1 * r1 + r * ca1 * r1 + front
		local v7 = u * sa0 * r1 + r * ca0 * r1 + front
		--render.DrawLine(p, c, color, true)
		render.SetMaterial(whiteTex)
		render.DrawQuad(v0,v1,v2,v3,color)
		render.DrawQuad(v7,v6,v5,v4,color)
		render.DrawQuad(v1,v0,v4,v5,color2)
		render.DrawQuad(v3,v2,v6,v7,color2)
		--render.DrawQuad(v3,v2,v1,v0,color)

		render.DrawQuad(v6,v7,front,front,Color(255,255,255,10))
		p = c
	end
end

function ENT:Draw()

	local dist = LocalPlayer():GetPos():Distance( self:GetPos() )
	if dist > 1024 then return end

	local color = Color(120,120,120)
	local one = Vector(1,1,1)
	local pos = self:GetPos()
	local state = self:GetState()

	self:SetRenderBoundsWS(pos - one * 110, pos + one * 110)

	if state == 1 then
		color = Color(255,100,100)
		self.closetween = nil
	elseif state == 2 then
		color = Color(100,255,100)

		if not self.closetween then
			self.closetween = CurTime()
		end
	end

	local rm = 1
	if self.closetween then
		rm = 1 - math.min( CurTime() - self.closetween, 1 )
	end

	local dist = math.min( (LocalPlayer():EyePos() - self:GetPos()):Length() / 300, 1 ) / 2
	rm = math.max(rm - dist * dist, 0)
	rm = rm * rm

	--self:DrawModel()
	self:DrawCircle(self:GetRingSize() * rm,color)

end
