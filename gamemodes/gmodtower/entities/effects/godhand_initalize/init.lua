
function EFFECT:Init(data)
	local Pos = data:GetOrigin() + Vector(0, 0, 1)
	self.EndPos = Pos
	self.DieTime = RealTime() + 2
	self.StartPos = Pos + Vector(0, 0, 22500)
	self.EndPos = util.TraceLine({start=Pos, endpos=Pos + Vector(0, 0, -40000), mask=MASK_SOLID}).HitPos
	self:SetRenderBoundsWS(self.StartPos, self.EndPos, Vector(256, 256, 256))
	self.Emitter = ParticleEmitter(Pos)
	local emitter = self.Emitter
	emitter:SetNearClip(32, 48)

	local i = math.random(1,4)
	if i == 2 then i = math.random(3,4) end

	for i=1, 5 do
		local particle = emitter:Add("particles/flamelet2", Pos + Vector(math.random(-80,80),math.random(-80,80),math.random(0,180)))
			particle:SetVelocity(Vector(math.random(-6,16),math.random(-6,16),math.random(15,40)))
			particle:SetDieTime(math.Rand(1, 2.7))
			particle:SetStartAlpha(math.Rand(220, 240))
			particle:SetStartSize(18)
			particle:SetEndSize(math.Rand(26, 29))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetAirResistance(20)
	end

	for i=1, 13 do
		local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(-30,50)))
			particle:SetVelocity(Vector(math.random(-12,15),math.random(-12,15),math.random(17,27)))
			particle:SetDieTime(math.Rand(1, 2.4))
			particle:SetStartAlpha(math.Rand(220, 240))
			particle:SetStartSize(3)
			particle:SetEndSize(math.Rand(22, 26))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetAirResistance(20)
	end

	for i=1, 5 do
		local particle = emitter:Add("particles/flamelet1", Pos + Vector(math.random(-30,30),math.random(-30,30),math.random(-40,50)))
			particle:SetVelocity(Vector(math.random(-6,6),math.random(-6,6),math.random(3,7)))
			particle:SetDieTime(math.Rand(1, 2.4))
			particle:SetStartAlpha(math.Rand(220, 240))
			particle:SetStartSize(3)
			particle:SetEndSize(math.Rand(23, 26))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetAirResistance(20)
	end

	for i=1, math.max(3, 3.5 * 4) do
		local particle = emitter:Add("particles/flamelet3", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(10,170)))
			particle:SetVelocity(Vector(math.random(-40,40),math.random(-40,40),math.random(-2,18)))
			particle:SetDieTime(math.Rand(1, 1.7))
			particle:SetStartAlpha(math.Rand(220, 240))
			particle:SetStartSize(5)
			particle:SetEndSize(math.Rand(17, 19))
			particle:SetRoll(math.Rand(0,359))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetAirResistance(20)
	end

	for i=1, 4 do
		local particle = emitter:Add("particles/smokey", Pos + Vector(math.random(-40,40),math.random(-40,40),math.random(-30,10)))
			particle:SetVelocity(Vector(math.random(-18,18),math.random(-18,18),math.random(0,48)))
			particle:SetDieTime(math.Rand(1.9, 2.3))
			particle:SetStartAlpha(math.Rand(205, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(42, 68))
			particle:SetEndSize(math.Rand(192, 256))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(170, 160, 160)
			--particle:VelocityDecay(false)
	end

	for i=1, 2 do
		local particle = emitter:Add("particles/smokey", Pos + Vector(math.random(-30,30),math.random(-30,30),math.random(10,100)))
			particle:SetVelocity(Vector(math.random(-280,280),math.random(-280,280),math.random(64,320)))
			particle:SetDieTime(math.Rand(1.5, 2.7))
			particle:SetStartAlpha(math.Rand(60, 80))
			particle:SetStartAlpha(math.Rand(60, 80))
			particle:SetStartSize(math.Rand(3, 8))
			particle:SetEndSize(math.Rand(19, 25))
			particle:SetRoll(math.Rand(0,359))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(170, 170, 170)
			--particle:VelocityDecay(false)
	end

	local particle = emitter:Add("particles/smokey", Pos + Vector(math.random(-40,40),math.random(-40,50),math.random(20,280)))
			particle:SetVelocity(Vector(math.random(-180,180),math.random(-180,180),math.random(60,140)))
			particle:SetDieTime(math.Rand(1.5, 2.7))
			particle:SetStartAlpha(math.Rand(140, 160))
			particle:SetStartSize(math.Rand(3, 4))
			particle:SetEndSize(math.Rand(19, 25))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(170, 170, 170)
			--particle:VelocityDecay(false)

	for i=1, 2 do
		local particle = emitter:Add("particles/smokey", Pos + Vector(math.random(-200,200),math.random(-200,200),math.random(5,10)))
			particle:SetVelocity(Vector(math.random(-20,20),math.random(-20,20),math.random(-2,20)))
			particle:SetDieTime(math.Rand(1.1, 2.4))
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetStartSize(math.Rand(4, 7))
			particle:SetEndSize(math.Rand(19, 27))
			particle:SetRoll(math.Rand(480, 540))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(170, 170, 170)
			--particle:VelocityDecay(false)
	end

	util.Decal("Scorch", Pos, Pos + Vector(0, 0, -1))
end

function EFFECT:Think()
	if self.DieTime < RealTime() then
		self.Emitter:Finish()
		return false
	end

	return true
end

local matBeam = Material("Effects/laser1")
local matGlow = Material("sprites/light_glow02_add")
local colBeam = Color(255, 180, 0)
function EFFECT:Render()
	local delta = self.DieTime - RealTime()
	local size

	if delta > 1 then
		size = 270 + (1 - delta) * 70
	else
		size = delta * 270
	end

	render.SetMaterial(matBeam)
	render.DrawBeam(self.StartPos, self.EndPos, size, 3, 0, colBeam)
	render.DrawBeam(self.StartPos, self.EndPos, size, 3, 0, colBeam)
	render.DrawBeam(self.StartPos, self.EndPos, size, 3, 0, colBeam)
	local size2 = math.min(size, 32)
	render.DrawBeam(self.StartPos, self.EndPos, size2, 3, 0, color_white)
	render.DrawBeam(self.StartPos, self.EndPos, size2, 3, 0, color_white)
	render.DrawBeam(self.StartPos, self.EndPos, size2, 3, 0, color_white)

	local spritepos = self.EndPos + Vector(0, 0, 64)
	render.SetMaterial(matGlow)
	render.DrawSprite(spritepos, math.max(48, size * 2.5), size, color_white)
	render.DrawSprite(spritepos, math.max(64, size * 3.25), size * 1.25, colBeam)

	local sunsize = size * 32 + 256
	local sunsizewhite = size * 28 + 256
	render.DrawSprite(self.StartPos, sunsizewhite, sunsizewhite, color_white)
	render.DrawSprite(self.StartPos, sunsize, sunsize, colBeam)
	render.DrawSprite(self.StartPos, sunsizewhite, sunsizewhite, color_white)
	render.DrawSprite(self.StartPos, sunsize, sunsize, colBeam)
end
