
function frand(v,mag)
	v = math.random(v-mag,v+mag)
	v = math.Clamp(v,0,255)
	return v
end

function randomVector(x)
	return Vector(frand(0,x),frand(0,x),frand(0,x))
end

function alphaFix(color,float)
	color.r = color.r*float
	color.g = color.g*float
	color.b = color.b*float
	return color
end

local beam		= Material( "effects/laser1" )
local matLight 		= Material( "sprites/light_ignorez" )

function EFFECT:Init( data )
	self.User = data:GetEntity()
	self.StartPos = data:GetOrigin()
	self.EndPos = self.User:GetPos() + self.User:OBBCenter()
	self.alpha = 255
	self.beamvals = {}
	self.startTime = CurTime()
	self.Entity:SetRenderBoundsWS( self.EndPos, self.StartPos, Vector()*8 )
	self.speed = 3
	self.resolution = 6 --Higher = faster(less lag) , Lower = better quality
end

function EFFECT:Think( )
	self.alpha = self.alpha - (self.speed*2);
	--self.alpha = math.Clamp(self.alpha,0,255)
	if(self.alpha <= 0) then 
		return false 
	else
		return true
	end
	--return false
end

function EFFECT:timeVec(amp,vec)
	local v = vec*(self.startTime - (CurTime()))*(3*self.speed)
	return v
end

function EFFECT:Render( )
	local npos = self.User:GetPos() + self.User:OBBCenter()
	--self.EndPos = self.EndPos + (npos - self.EndPos)*.8
	render.SetMaterial(beam)
	local a = (self.alpha/255)
	local color = alphaFix(Color(70, 255, 70, 255),a)
	for i=1,4 do
		self:DrawCurlyLaser(self.resolution,5,self.StartPos,self.EndPos,color,i)
	end
	self:DrawMainLaser(5,self.StartPos,self.EndPos,color)
	
	render.SetMaterial(matLight)
	render.DrawSprite( self.StartPos, 64, 64, color )
	render.DrawSprite( self.EndPos, 32, 32, color )
	
end

function EFFECT:DrawMainLaser(spd,startpos,endpos,color)
	local r = color.r
	local g = color.g
	local b = color.b
	local a = color.a
	local length = (endpos - startpos):Length()
	local beamcolor = Color( frand(r,20), frand(g,20), frand(b,20), a )
	render.DrawBeam(
	startpos,
	endpos,
	35, CurTime()*(spd*self.speed), (CurTime()*(spd*self.speed)) + length/256, beamcolor )
end

function EFFECT:DrawCurlyLaser(spacing,spd,startpos,endpos,color,iter)
	local r = color.r
	local g = color.g
	local b = color.b
	local a = color.a
	local amp = math.random(3,6)
	local lastrand = self:timeVec(amp,Vector(0,0,0))--randomVector(amp)
	local length = (endpos - startpos):Length()
	local angle = (endpos - startpos):Normalize()
	local beamcolor = Color( frand(r,20), frand(g,20), frand(b,20), a )
	for i=1, length do
		if(self.beamvals[i] == nil) then self.beamvals[i] = {} end
		--if(self.beamvals[i][iter] == nil) then
			local t = i/10 - CurTime()*(self.speed*1.5)
			local a2 = angle:Angle()
			if(iter == 1) then
				self.beamvals[i][iter] = a2:Right()*math.sin(t)
			elseif(iter == 2) then
				self.beamvals[i][iter] = a2:Right()*math.cos(t)/2
			elseif(iter == 3) then
				self.beamvals[i][iter] = a2:Up()*math.sin(t)
			elseif(iter == 4) then
				self.beamvals[i][iter] = a2:Up()*math.cos(t)/2
			end
		--end
		if(math.fmod(i,spacing) == 1) then
		local ix = i+spacing
		local ix2 = ix
		local clamped = false
		if(ix > length) then ix = length clamped = true end
		if(ix == length) then clamped = true end
		local pos = startpos
		local newrand = self:timeVec(amp,self.beamvals[i][iter])
		if(clamped == true) then
			newrand = self:timeVec(amp,Vector(0,0,0))
		end
		render.DrawBeam(
		(pos + lastrand) + angle*(ix2-spacing),
		(pos + newrand) + angle*ix,
		5, CurTime()*(spd*self.speed), (CurTime()*(spd*self.speed)) + length/256, beamcolor )
		lastrand = newrand
		end
	end
end