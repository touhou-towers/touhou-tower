

-----------------------------------------------------
ENT.Events = {}

function ENT:RegisterEvent( name, eventinfo )

	if !eventinfo then MsgN( "Event failed to register." ) return end
	self.Events[name] = eventinfo

end

// ========================================================
// EFFECTS
// ========================================================

function ENT:DLight( pos, color, uniquename )

	uniquename = uniquename or "main"

	local dlight = DynamicLight( self:EntIndex() .. uniquename )
	if dlight then
		dlight.Pos = pos
		dlight.r = color.r
		dlight.g = color.g
		dlight.b = color.b
		dlight.Brightness = 5
		dlight.Decay = 1024
		dlight.size = 512
		dlight.DieTime = CurTime() + 1
	end

end

function ENT:DrawBasicSprite( mat, pos, ang, scale, color )

	render.SetMaterial( mat )
	render.DrawSprite( pos, 5, 80, Color( 255, 255, 255, math.random( 0, 255 ) ) )
	render.DrawQuadEasy( pos - ang:Forward() * 1, ang:Forward() * -1, scale, scale, color )

end

function ENT:ScreenShake( pos, power )

	util.ScreenShake( pos, 2.5 * power, 2.5, .5 * power, 2048 )

end

// ========================================================
// EVENTS
// ========================================================

ENT:RegisterEvent( "Light", {

	AttTable = "Lights",
	Duration = .2,
	EndOnDT = true,

	Start = function( self, pos, ang, power )

		self:DLight( pos, colorutil.Smooth( .25 ) )

	end,

	Draw = function( self, pos, ang, dt, power )

		local color = colorutil.Smooth( .25, dt * 255 )
		self:DrawBasicSprite( self.Mat.Flare2, pos, ang, 150 * power, color )

	end

} )

ENT:RegisterEvent( "Flame", {

	AttTable = "Emitters",
	Duration = .5,
	EndOnDT = true,

	Draw = function( self, pos, ang, dt, power, id )

		local emitter, go = self:CreateNewEmitter( "flames" .. id, pos, 0 )
		local particle = emitter:Add( Material("particles/flamelet"..math.random(1,5)), pos + ( VectorRand() * 5 ) )

		local flare = Vector( CosBetween( -6, 6, CurTime() * 10 ), SinBetween( -6, 6, CurTime() * 10 ), 0 )
		particle:SetVelocity( ang:Forward() * ( power * -50 ) + flare )
		particle:SetDieTime( math.random( 1, 2 ) )
		particle:SetStartAlpha( math.random( 150, 255 ) )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 1, 5 ) )
		particle:SetEndSize( 0 )
		particle:SetColor( 255, 255, 255 )
		particle:SetCollide( true )
		particle:SetGravity( Vector( 0, 0, 50 * power ) )

		render.SetMaterial( self.Mat.Flare2 )
		render.DrawQuadEasy( pos - ang:Up() * 1, ang:Up(), SinBetween( 15, 50 * power, CurTime() * 5 ), SinBetween( 150, 1000 * power, CurTime() * 5 ), Color( 255, 0, 0 ) )

		local dlight = DynamicLight( self:EntIndex() .. math.random( 1, 256 ) )
		if dlight then
			dlight.Pos = pos
			dlight.r = 255
			dlight.g = 50
			dlight.b = 50
			dlight.Brightness = 4
			dlight.Decay = 512
			dlight.size = 256
			dlight.DieTime = CurTime() + .1
		end

	end,

	End = function( self, pos, ang, id )
		--self:FinishEmitter( "flames" .. id )
	end

} )

ENT:RegisterEvent( "Spark", {

	AttTable = "Emitters",
	Duration = .15,
	EndOnDT = true,

	Draw = function( self, pos, ang, dt, power, id )

		local emitter, go = self:CreateNewEmitter( "sparks" .. id, pos, 1 )
		//if !go then return end

		local particle = emitter:Add( self.Mat.Spark, pos + ( VectorRand() * 5 ) )

		if !particle then return end

		particle:SetVelocity( ( ( VectorRand() + Vector( 0, 0, -1 ) ) * math.Rand( 20, 100 * power ) ) * -1 )
		particle:SetDieTime( .5 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 15 * power )
		particle:SetEndSize( 0 )
		particle:SetColor( math.random( 240, 255 ), math.random( 240, 255 ), math.random( 240, 255 ) )
		particle:SetStartLength( 15 )
		particle:SetEndLength( 80 )
		particle:SetAirResistance( 150 )

	end,

	End = function( self, pos, ang, id )
		--self:FinishEmitter( "sparks" .. id )
	end

} )

ENT:RegisterEvent( "Smoke", {

	AttTable = "Emitters",
	Duration = 5,
	EndOnDT = true,

	Draw = function( self, pos, ang, dt, power, id )

		local emitter, go = self:CreateNewEmitter( "smoke" .. id, pos, 5 )
		if !go then return end

		local particle = emitter:Add( Material("particles/smokey"), pos + ( VectorRand() * 5 ) )

		if !particle then return end

		particle:SetVelocity( Vector( 0, 0, 1 ) + VectorRand() * 15 )
		particle:SetDieTime( 7 )
		particle:SetStartAlpha( math.Rand( 195, 200 ) )
		particle:SetStartSize( math.Rand( 68, 128 ) )
		particle:SetEndSize( math.Rand(128, 256 ) )
		particle:SetColor(90,90,90, 20)
		particle:SetAirResistance( 100 )
		particle:SetCollide( false )

	end,

	End = function( self, pos, ang, id )
		--self:FinishEmitter( "smoke" .. id )
	end

} )


ENT:RegisterEvent( "Acoustic", {

	AttTable = "Emitters",
	Duration = .1,
	EndOnDT = true,

	Draw = function( self, pos, ang, dt, power, id )

		local emitter, go = self:CreateNewEmitter( "acoustic" .. id, pos, 0 )

		local particle = emitter:Add( self.Mat.Effects, pos + ( VectorRand() * 5 ) )

		if !particle then return end

		local color = colorutil.Smooth( .2, ( 1 - dt ) * 100 )

		for i=1, 6 do

			local vel = ( VectorRand() * 50 ) + Vector( 0, 0, math.random( 100, 175 ) * 2 )
			if i == 1 then
				particle:SetVelocity( vel )
				particle:SetDieTime( math.Rand( 1, 4 ) )
				particle:SetStartSize( math.random( 8, 16 ) )
				particle:SetColor( color.r, color.g,color.b )
				particle:SetGravity( Vector( 0, 0, -100 ) )
			else
				particle:SetVelocity( vel * .95 )
				particle:SetGravity( Vector( math.random( -10, 10 ), math.random( -10, 10 ), -50 ) )
			end

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
			particle:SetCollide( true )
			particle:SetBounce( 1 )
			particle:SetAirResistance( 85 )

		end

	end,

	End = function( self, pos, ang, id )
		--self:FinishEmitter( "acoustic" .. id )
	end

} )


// ========================================================
// SCREEN EVENTS
// ========================================================

surface.CreateFont( "LyricYeah", { font = "Impact", size = 24, weight = 300 } )
surface.CreateFont( "Lyric", { font = "Impact", size = 100, weight = 300 } )
surface.CreateFont( "LyricSmall", { font = "Impact", size = 64, weight = 300 } )
surface.CreateFont( "LyricSmaller", { font = "Impact", size = 48, weight = 300 } )

ENT:RegisterEvent( "Lyric", {

	AlwaysOn = true,

	Setup = function( self )
		self.LyricsTable = breakLyrics( self.Lyrics )
		self.LyricsOn = false
		self.LyricStartTime = 0
		self.LyricEndTime = 0
	end,

	Reset = function( self )
		self.CurrentLyric = 1
		self.LyricsOn = false
		self.LyricStartTime = 0
		self.LyricEndTime = 0
	end,

	Start = function( self )

		if self.CurrentLyric <= #self.LyricsTable then

			self.LyricsOn = true
			self.LyricStartTime = self.midiPlayer:GetClock()

			cprint( self.LyricsTable[self.CurrentLyric] )

		end
		self.CurrentLyric = self.CurrentLyric + 1

	end,

	DrawScreen = function( self, w, h )

		if !self.LyricsOn || self.CurrentLyric == 0 then return end

		local time = self.midiPlayer:GetClock()
		local dt = (time - self.LyricStartTime)/3000

		local color = colorutil.Smooth( .2, ( 1 - dt ) * 100 )
		surface.SetDrawColor( color )
		surface.DrawTexturedRect( 0, 0, w, h )

		if dt > 1 then dt = 1 end
		local alpha = 100 + (1-dt) * 155

		if self.LyricEndTime > self.LyricStartTime then
			local dt = (time - self.LyricEndTime)/500
			if dt > 1 then dt = 1 end
			alpha = alpha * (1-dt)
		end

		local text = self.LyricsTable[self.CurrentLyric-1]
		local font = "Lyric"

		if string.find( text, "yeah" ) then
			font = "LyricYeah"
		end

		// Make the text smaller
		surface.SetFont( font )
		local tw, th = surface.GetTextSize( text )
		if tw > w then
			font = "LyricSmall"
			surface.SetFont( font )

			local tw, th = surface.GetTextSize( text )
			if tw > w then
				font = "LyricSmaller"
			end
		end

		draw.SimpleText( text, font, w/2 + CosBetween( -15, 15, CurTime() * 2 ), h/2 + SinBetween( -15, 5, CurTime() * 5 ), Color( 255,255,255,alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end,

	End = function( self )

		self.LyricEndTime = self.midiPlayer:GetClock()

	end

} )

ENT:RegisterEvent( "ScreenFlash", {

	Duration = .75,

	DrawSideScreen = function( self, w, h, dt )

		if dt > 0 then
			surface.SetDrawColor( colorutil.Smooth( .5, dt * 255 ) )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

	end,

} )

ENT:RegisterEvent( "ScreenLongFlash", {

	Duration = 2,

	DrawSideScreen = function( self, w, h, dt )

		surface.SetDrawColor( colorutil.Smooth( 1, dt * 255 ) )
		surface.DrawTexturedRect( 0, 0, w, h )

	end,

} )

ENT:RegisterEvent( "ScreenIdle", {

	DrawSideScreen = function( self, w, h, dt )
		surface.SetDrawColor( colorutil.Smooth( .5 ) )
		surface.DrawTexturedRect( 0, 0, w, h )
	end,

} )

ENT:RegisterEvent( "ScreenJazz", {

	Start = function( self )
		self.ScreenBar = { 0, CurTime() }
	end,

	DrawSideScreen = function( self, w, h, dt )

		local bars = 4
		local spacing = 30

		local dt = 0

		if self.ScreenBar then
			dt = math.Clamp( ( CurTime() - ( self.ScreenBar[2] or 0 ) ) / .06, 0, 1 )
		end

		dt = ( 1 - dt )

		if !self.ScreenBar || self.ScreenBar[1] > bars then
			self.ScreenBar = { 0, CurTime() }
		end

		if dt == 0 then
			self.ScreenBar = { self.ScreenBar[1] + 1, CurTime() }
		end

		surface.SetDrawColor( colorutil.Smooth( .5, dt * 255 ) )
		surface.DrawTexturedRect( 0, self.ScreenBar[1] * spacing, w, 30 )

	end,

} )

ENT:RegisterEvent( "ScreenBass", {

	Duration = .8,

	DrawScreen = function( self, w, h, dt, note )

		local spacing = 30

		surface.SetDrawColor( colorutil.Smooth( .5, dt * 255 ) )
		surface.DrawTexturedRect( 0, ( math.fmod( note, 4 ) or 0 ) * spacing, w, 30 )

	end,

} )
