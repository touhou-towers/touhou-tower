

-----------------------------------------------------
include("shared.lua")
include("gmidi2.lua")
include("foreplay.lua")
include("cl_util.lua")
include("cl_songinfo.lua")
include("cl_events.lua")
include("cl_lasers.lua")

// ========================================================
// SETUP/DEFINES
// ========================================================

ENT.Emitters = {}
ENT.Mat = {
	Flare = Material( "effects/blueflare1" ),
	Flare2 = Material( "sprites/powerup_effects" ),
	Effects = "sprites/powerup_effects",
	Fire = Material( "sprites/fire1" ),
	Flamelet = "particles/flamelet",
	Spark = "effects/spark",
	Smoke = "particles/smokey",
}

// ========================================================
// MIDI
// ========================================================

local EVENT_LYRICS = 27
local EVENT_INTERMISISON = 28
local EVENT_ORGANRIFF = 29
local EVENT_ORGANCHORD = 30
local EVENT_FINALE = 31
local EVENT_CYMBAL = 32

local DRUM_KICK1 = 60
local DRUM_KICK2 = 61
local DRUM_CLAP = 62
local DRUM_HAT1 = 63
local DRUM_HAT2 = 66
local DRUM_SNARE = 64
local DRUM_CRASH = 65
local DRUM_CYMBAL = 67

local CHAN_EVENTS = 9
local CHAN_DRUMS = 0
local CHAN_BASS = 1
local CHAN_PIANO = 2
local CHAN_ELEGUITAR = 3
local CHAN_ACOGUITAR = 4

ShowDelay = 3600
ShowTimeRemaining = ShowDelay
function ENT:Initialize()

	timer.Create("BumpyStageRepeat",1,0,function()

		ShowTimeRemaining = ShowTimeRemaining - 1


		if ShowTimeRemaining == 60 then
			chat.AddText( Color( 255, 50, 50 ), "4th of July Show Starting In 1 minute!" )
		elseif ShowTimeRemaining == 0 then
			for k,v in pairs(ents.GetAll()) do if v:GetClass() == "stage" then v:Start() end end
			chat.AddText( Color( 255, 50, 50 ), "4th of July Show Starting Now!" )
			timer.Create("RestartTimer",700,1,function()
				net.Start("ResetStage")
				net.SendToServer()
			end)
		end

	end)

	self.FinaleTime = false
	self.NextFinaleDoThing = 0

	// Setup all events
	for name, eventinfo in pairs( self.Events ) do
		if eventinfo.Setup then
			eventinfo.Setup( self )
		end
	end

	self.midiPlayer = MidiPlayer( self.MidiData )

	self:SetLaserNoteRange( self.MidiData:GetChannelNoteRange( CHAN_ELEGUITAR ) )

	self.midiPlayer.OnMidiEvent = function(trackid, event, params, channel)

		if event == EVENT.BEND then
		
			self:LaserPitchBend( params[3] )
		
		end

	end

	self.midiPlayer.NoteOn = function( note, vel, channel ) 

		if channel == CHAN_EVENTS then

			cprint("raw event: " .. note .. "[" .. vel .. "]")

			if note == EVENT_ORGANCHORD then
				self:StartEvent( "ScreenLongFlash" )

				for i=1, 9 do
					self:StartEvent( "Smoke", i, vel )
				end
			end

			if note == EVENT_ORGANRIFF then
				self:StopEvent( "ScreenIdle" )
				self:StartEvent( "ScreenJazz" )
			end

			if note == EVENT_INTERMISISON then
				self:StopEvent( "ScreenJazz" )
				self:StartEvent( "ScreenIdle" )
			end

			if note == EVENT_LYRICS then
				self:StartEvent( "Lyric" )
			end

			if note == EVENT_FINALE then
				for i=1, 9 do
					self:StartEvent( "Flame", i, vel, 60 )
				end
				for i=1, 9 do
					self:StartEvent( "Light", i, vel, 60 )
				end
				self.FinaleTime = true
				self.NextFinaleDoThing = CurTime()
			end

		end

		if channel == CHAN_DRUMS then

			cprint("drum: " .. note .. "[" .. vel .. "]")

			// Clamp
			if note == DRUM_CLAP then
				for i=1, 11 do
					self:StartEvent( "Light", i, vel )
				end

				self:StopEvent( "ScreenIdle" )
				self:StopEvent( "ScreenJazz" )
				self:StartEvent( "ScreenFlash" )
			end

			if note == DRUM_CYMBAL then
				self:StartEvent( "Light", 1, vel )
				self:StartEvent( "Light", 11, vel )
			end

			// Hats
			if note == DRUM_HAT1 then
				self:StartEvent( "Light", 2, vel * 1.25, .05 )
				self:StartEvent( "Light", 10, vel * 1.25, .05 )
			elseif note == DRUM_HAT2 then
				self:StartEvent( "Light", 2, vel )
				self:StartEvent( "Light", 10, vel )
			end

			// Bass
			if note == DRUM_KICK1 then
				self:StartEvent( "Light", 3, vel )
				self:StartEvent( "Light", 9, vel )
			end
			if note == DRUM_KICK2 then
				self:StartEvent( "Light", 4, vel )
				self:StartEvent( "Light", 8, vel )
			end

			if note == DRUM_SNARE then
				self:StartEvent( "Light", 5, vel )
				self:StartEvent( "Light", 7, vel )

				self:StartEvent( "Flame", 1, vel )
				self:StartEvent( "Flame", 9, vel )
			end

			if note == DRUM_CRASH then
				self:StartEvent( "Light", 6, vel * 1.5, .5 )

				self:StartEvent( "Spark", 2, vel )
				self:StartEvent( "Spark", 5, vel )
				self:StartEvent( "Spark", 8, vel )

				self:ScreenShake( self.Att.Emitters[5].pos, 1 )
			end

		end

		if channel == CHAN_BASS then
			self:StartEvent( "ScreenBass", nil, nil, nil, note )
		end

		if channel == CHAN_PIANO then
			cprint("piano: " .. note .. "[" .. vel .. "]")
		end

		if channel == CHAN_ELEGUITAR then
			cprint("electric guitar: " .. note .. "[" .. vel .. "]")

			self:LaserNote( note )
		end

		if channel == CHAN_ACOGUITAR then
			self:StartEvent( "Acoustic", math.random( 1, 9 ), vel )
		end

		--cprint("chanL " .. channel)

	end

	self.midiPlayer.NoteOff = function( note, vel, channel )

		if channel == CHAN_EVENTS && note == EVENT_LYRICS then
			self:StopEvent( "Lyric" )
		end

		if channel == CHAN_ELEGUITAR then
			self:LaserOff( note )
		end

		if channel == CHAN_EVENTS && note == EVENT_FINALE then
			self.FinaleTime = false
		end

	end

end

// ========================================================
// ENTITY
// ========================================================

function ENT:Start()

	ShowTimeRemaining = 0

	timer.Simple( 1, function()
		sound.PlayFile( "sound/GModTower/stage/" .. self.Song .. ".mp3", "3d", function( station )
			if ( IsValid( station ) ) then
				station:SetPos(self:GetPos() + Vector(0,0,255))
				station:Set3DFadeDistance(1024,-1)
				station:Play()
			end
		end )
	 end )

	--timer.Simple( 1, function() if IsValid( self ) then RunConsoleCommand( "play", "GModTower/stage/" .. self.Song .. ".mp3" ) end end )

	/*self.Music = CreateSound( LocalPlayer(), song .. ".mp3" )
	timer.Simple( 1, function() self.Music:PlayEx( 1, 100 ) end )*/

	if self.midiPlayer then
		self.midiPlayer:Start()
	end

	// Reset all events
	for name, eventinfo in pairs( self.Events ) do
		if eventinfo.Reset then
			eventinfo.Reset( self )
		end
	end

	self.Playing = true

	//MsgN( "start" )

end

function ENT:End()

	ShowTimeRemaining = 3600

	for name, eventinfo in pairs( self.Events ) do

		if eventinfo.Reset then

			eventinfo.Reset( self )

		end

	end


	RunConsoleCommand( "stopsound" ) // welp fuck my lite
	//if self.Music then self.Music:Stop() end

	if self.midiPlayer then
		self.midiPlayer:Stop()
	end

	self.Playing = false
	self.FinaleTime = false
	self:DrawFacts()
	//MsgN( "end" )

	net.Start("ResetStage")
	net.SendToServer()

end

concommand.Add("resetshow",function(ply)
	if ply:IsAdmin() then
	net.Start("ResetStage")
	net.SendToServer()
	end
end)

function ENT:OnRemove()

	self:ClearEmitters()
	self:End()

end

usermessage.Hook( "Stage", function( um )

	local ent = um:ReadEntity()
	local start = um:ReadBool()

	if !IsValid( ent ) then return end
	if start then ent:Start() else ent:End() end

end )

function ENT:Draw()

	self:DrawModel()
	self:UpdateAttachments()

	if self.midiPlayer then
		self.midiPlayer:RunSequenceEvents( self.midiPlayer:GetClock() )
	end

	self:DrawScreens()

	// Draw all active events
	for name, eventinfo in pairs( self.Events ) do
		if eventinfo.Draw then
			self:DrawEvent( name )
		end
	end

	// Draw lights
	/*for id, att in pairs( self.Att.Lights ) do
		self:DrawBasicSprite( self.Mat.Flare2, att.pos, att.ang, 150, colorutil.Smooth( .25 ) )
	end*/

	self:DrawLasers()

	if self.FinaleTime then

		if self.NextFinaleDoThing < CurTime() then
			self.NextFinaleDoThing = CurTime() + .06
			self:RandomLaserThing()
		end

	end

end

// ========================================================
// SCREENS
// ========================================================

function ENT:DrawScreens()

	local ang = self:GetAngles()
	local right = ang:Forward() --right from screen
	local forward = ang:Right() * -1 --in to screen
	local up = right:Cross(forward) --up from screen

	local screenAngle = forward:Angle()
	screenAngle:RotateAroundAxis( screenAngle:Forward(), 90 )
	screenAngle:RotateAroundAxis( screenAngle:Right(), -90 )

	// Draw screen
	cam.Start3D2D( self:GetPos() + ( self:GetAngles():Forward() * 169 ) + ( self:GetAngles():Up() * 273 ) + ( self:GetAngles():Right() * 72 ), screenAngle, 1 )
		pcall(self.DrawScreen, self, 334, 153 )
	cam.End3D2D()

	// Draw left screen
	cam.Start3D2D( self:GetPos() + ( self:GetAngles():Forward() * 227 ) + ( self:GetAngles():Up() * 222 ) + ( self:GetAngles():Right() * 72 ), screenAngle, 1 )
		pcall(self.DrawLeftScreen, self, 31 - 4, 151 - 4 )
	cam.End3D2D()

	// Draw right screen
	cam.Start3D2D( self:GetPos() + (	self:GetAngles():Forward() * -198 ) + ( self:GetAngles():Up() * 222 ) + ( self:GetAngles():Right() * 72 ), screenAngle, 1 )
		pcall(self.DrawRightScreen, self, 31 - 4, 151 - 4 )
	cam.End3D2D()

end


surface.CreateFont( "FactsLarge", { font = "Impact", size = 100, weight = 300 } )
surface.CreateFont( "FactsTitle", { font = "Impact", size = 32, weight = 300 } )
surface.CreateFont( "FactsStart", { font = "Impact", size = 25, weight = 300 } )
surface.CreateFont( "FactsMain", { font = "Arial", size = 14, weight = 300 } )

net.Receive("UpdateShowDelay",function() ShowTimeRemaining = net.ReadFloat() * 60 end)

function ENT:StartEasteregg()
		CurCreditLight = 1
		timer.Create("LightShuffle",0.125,64,function()
			self:StartEvent( "Light", CurCreditLight, 5 )
			self:StartEvent( "Acoustic", 1, 25 )
			self:StartEvent( "Acoustic", 9, 25 )
			CurCreditLight = CurCreditLight + 1
			if CurCreditLight > 11 then CurCreditLight = 1 end
		end)
		self:StartEvent( "ScreenJazz" )
		EasterEggEnabled = true
 		RunConsoleCommand("play","gmodtower/casino/cards/win2.mp3")
		timer.Simple(8,function()
			EasterEggEnabled = false
			self:StopEvent( "ScreenJazz" )
			self:StartEvent( "ScreenLongFlash" )
		end)
end

function ENT:DrawFacts( w, h )

	// Show timer
	local timeleft = ShowTimeRemaining
	local timeformat = string.NiceTime( timeleft )
	self2 = self
	if timeleft > 4 then
		draw.SimpleText( "NEXT SHOW WILL START IN " .. string.upper(timeformat), "FactsStart", w/2, h - 12, Color( 150, 150, 150, 50 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	else
		local countdown = math.floor(timeleft)
		local color = colorutil.Smooth( 5 )
		if countdown > 0 then
			draw.SimpleText( countdown, "FactsLarge", w/2 + CosBetween( -15, 15, CurTime() * 5 ), h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "ROCK OUT", "FactsLarge", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		return
	end

	if EasterEggEnabled then
		local color = colorutil.Smooth( 5 )
		draw.DrawText( "This stage was brought\nto you by\n https://knockout.chat/thread/1820/1", "FactsTitle", w/2 + math.sin(CurTime()*4)*16, h/4 + math.sin(CurTime()*2)*16, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		self.CurrentFact = 1000
		self.NextFact = CurTime() + 1
	end

	if !self.CurrentFact then
		self.CurrentFact = 1
	end

	if !self.NextFact || self.NextFact < CurTime() then

		self.NextFact = CurTime() + 10
		self.CurrentFact = self.CurrentFact + 1

		if self.CurrentFact > #self.Facts then
			self.CurrentFact = 1
		end

	end

	local color = colorutil.Smooth( .25 )
	if !EasterEggEnabled then
			draw.SimpleText( "REAL FACTS ABOUT BOSTON", "FactsTitle", w/2 + CosBetween( -15, 15, CurTime() * 5 ), 20, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	// Fact
	local fact = self.Facts[self.CurrentFact]
	local text = markup.Parse( "<font=FactsMain><color=white>" .. fact .. "</color></font>" )

	surface.SetFont( "FactsMain" )
	local tw, th = surface.GetTextSize( fact )

	text:Draw( w/2 + CosBetween( -5, 5, CurTime() / 2 ) - ( tw / 2), h/2 + SinBetween( -5, 5, CurTime() ) )


end
function ENT:DrawScreen( w, h )

	surface.SetTexture( 0 )
	surface.SetDrawColor( 0, 0, 0, 250 )
	surface.DrawTexturedRect( 0, 0, w, h )

	if !self.Playing then
		self:DrawFacts( w, h )
		return
	end

	// Draw screen events
	for name, eventinfo in pairs( self.Events ) do

		if eventinfo.DrawScreen then

			local dt = math.Clamp( ( CurTime() - eventinfo.time ) / ( eventinfo.Duration or 1 ), 0, 1 )
			dt = ( 1 - dt )

			local s,e = pcall( eventinfo.DrawScreen, self, w, h, dt, eventinfo.note )
			if e then MsgN( e ) end

		end

	end

end

function ENT:DrawLeftScreen( w, h )

	// Draw side screen events
	for name, eventinfo in pairs( self.Events ) do

		if eventinfo.DrawSideScreen && eventinfo.started then

			local dt = math.Clamp( ( CurTime() - eventinfo.time ) / ( eventinfo.Duration or 1 ), 0, 1 )
			dt = ( 1 - dt )

			local s,e = pcall( eventinfo.DrawSideScreen, self, w, h, dt )
			if e then MsgN( e ) end

		end

	end

end

function ENT:DrawRightScreen( w, h )

	self:DrawLeftScreen( w, h ) // Yeah we're gonna be lame here

end

// ========================================================
// EVENT SYSTEM
// ========================================================

function ENT:GetEventPos( id, atttbl )

	local pos, ang = self:GetPos(), self:GetAngles()

	if id && atttbl then pos, ang = self.Att[atttbl][id].pos, self.Att[atttbl][id].ang end

	return pos, ang

end

function ENT:StartEvent( name, id, power, dur, note )

	local eventinfo = self.Events[name]
	if !eventinfo then MsgN( "Failed to start event " .. name ) return end

	local pos, ang = self:GetEventPos()

	if id then

		if !eventinfo.active then eventinfo.active = {} end

		// Gather pos/ang
		pos, ang = self:GetEventPos( id, eventinfo.AttTable )

		// Start the active ID
		eventinfo.active[id] = {
			power = math.Fit( power, 0, 100, 0, 1 ),
			time = CurTime(),
			duration = dur or eventinfo.Duration
		}

	end

	if eventinfo.Start then
		eventinfo.Start( self, pos, ang, power )
	end

	eventinfo.time = CurTime()
	eventinfo.started = true
	eventinfo.note = note

end

function ENT:DrawEvent( name )

	local eventinfo = self.Events[name]
	if !eventinfo || !eventinfo.active then return end

	for id, active in pairs( eventinfo.active ) do

		local dt = math.Clamp( ( CurTime() - active.time ) / active.duration, 0, 1 )
		dt = ( 1 - dt )

		// Gather pos/ang
		local pos, ang = self:GetEventPos( id, eventinfo.AttTable )

		// Automatically remove on DT
		if eventinfo.EndOnDT && dt == 0 then

			// End the active ID
			eventinfo.active[id] = nil

			if eventinfo.End then
				eventinfo.End( self, pos, ang, id )
			end

			continue

		end

		// Draw
		eventinfo.Draw( self, pos, ang, dt, active.power, id )

	end

end

function ENT:StopEvent( name, id )

	local eventinfo = self.Events[name]
	if !eventinfo then MsgN( "Failed to end event " .. name ) return end
	
	local pos, ang = self:GetEventPos()

	if eventinfo.active then

		// Gather pos/ang
		pos, ang = self:GetEventPos( id, eventinfo.AttTable )

		// End the active ID
		eventinfo.active[id] = nil

	end

	if eventinfo.End then
		eventinfo.End( self, pos, ang, id )
	end

	eventinfo.started = false

end

// ========================================================
// EMITTER CONTROLS
// ========================================================

function ENT:CreateNewEmitter( name, pos, delay )

	local emitter = self.Emitters[name]

	if !emitter then
		emitter = { emit = ParticleEmitter( pos ), delay = CurTime() + delay }
		self.Emitters[name] = emitter
	end

	if emitter.delay < CurTime() then
		emitter.delay = CurTime() + delay
		return emitter.emit, true
	end

	return emitter.emit, false

end

function ENT:FinishEmitter( name )

	local emitter = self.Emitters[name]
	if emitter && IsValid( emitter.emit ) then
		emitter.emit:Finish()
		emitter = nil
	end

end

function ENT:ClearEmitters()

	for id, emitter in pairs( self.Emitters ) do
		if emitter.emit then
			emitter.emit:Finish()
		end
	end

	self.Emitters = {}

end
