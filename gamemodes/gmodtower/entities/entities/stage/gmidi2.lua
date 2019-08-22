

-----------------------------------------------------
AddCSLuaFile()
local MidiT = {}

-----------GLOBALS-------------

MICROSECONDS_PER_MINUTE = 60000000

META = {
	SQUENCE 	= 0x00,
	TEXT 		= 0x01,
	COPYRIGHT 	= 0x02,
	TRACKNAME 	= 0x03,
	INSTRUMENT 	= 0x04,
	LYRIC 		= 0x05,
	MARKER 		= 0x06,
	CUE 		= 0x07,
	PREFIX 		= 0x20,
	EOT 		= 0x2F,
	TEMPO 		= 0x51,
	SMTPE 		= 0x54,
	TIMESIG 	= 0x58,
	KEYSIG 		= 0x59,
	SEQEVENT 	= 0x7F,
}

EVENT = {
	NOTE_OFF 	= 0x08,
	NOTE_ON 	= 0x09,
	AFTERTOUCH 	= 0x0A,
	CONTROLLER 	= 0x0B,
	PROGRAM 	= 0x0C,
	CAFTERTOUCH = 0x0D,
	BEND 		= 0x0E,
}

CONTROL = {
	BANK 		= 0x00,
	MODULATION 	= 0x01,
	BREATH 		= 0x02,
	FOOT 		= 0x04,
	PORTO 		= 0x05,
	DATA 		= 0x06,
	VOLUME 		= 0x07,
	BALANCE 	= 0x08,
	PAN 		= 0x0A,
	EXP 		= 0x0B,
	EFFECT1 	= 0x0C,
	EFFECT2 	= 0x0D,
	GENERAL0 	= 0x10,
	GENERAL1 	= 0x11,
	GENERAL2 	= 0x12,
	GENERAL3 	= 0x13,
}

--Flip Tables For Reverse Lookup
local function tflip(t) for k,v in pairs(table.Copy(t)) do t[v] = k end end
tflip(EVENT)
tflip(META)
tflip(CONTROL)

local function dontprint() end
----------------END GLOBALS-------------------

------------------FILE IO---------------------

local FILE_HANDLE = nil
local FILE_PTR = 1
local FILE_STR = false
local HEX = {
	['0'] = 0,
	['1'] = 1,
	['2'] = 2,
	['3'] = 3,
	['4'] = 4,
	['5'] = 5,
	['6'] = 6,
	['7'] = 7,
	['8'] = 8,
	['9'] = 9,
	['A'] = 10,
	['B'] = 11,
	['C'] = 12,
	['D'] = 13,
	['E'] = 14,
	['F'] = 15,
}

local function mark() return FILE_PTR / 2 end
local function frame(n) return (FILE_PTR / 2) - n end

local function readChar()
	local block = string.sub(FILE_HANDLE,FILE_PTR,FILE_PTR)
	if not block then Msg("READ ERROR\n") return "" end
	FILE_PTR = FILE_PTR + 1
	return block
end

local function readByte(formatted)
	local c1 = readChar() --High order
	local c2 = readChar() --Low order
	--dontprint(c1 .. "[" .. HEX[c1] .. "]..." .. c2 .. "[" .. HEX[c2] .. "]")

	if formatted then
		return string.char(tonumber(c1..c2,16))
	end

	return c1 .. c2
end

local function readBytes(n,formatted)

	if FILE_STR then
		local str = ""
		for i=1, n do
			str = str .. readByte(formatted)
		end
		return str
	end

	if n == 0 then return "" end
	FILE_PTR = FILE_PTR + n
	return FILE_HANDLE:Read(n)
end

local function toHex(byte)
	return string.format("%02X", string.byte(byte))
end

local function hexToString(bytes)
	local len = string.len(bytes)
	local out = ""
	if len % 2 ~= 0 then return out end
	for i=1, len, 2 do
		local c1 = string.sub(bytes,i,i)
		local c2 = string.sub(bytes,i+1,i+1)
		out = out .. string.char(tonumber(c1..c2,16))
	end
	return out
end

local function bytesToHex(bytes)
	local v = ""
	local len = string.len(bytes)
	for i=1, len do
		local hex = string.sub(bytes,i,i+1)
		v = v .. hex
	end
	return v
end

local function splitStatus(s)
	local event = "0" .. string.sub(s,1,1)
	local channel = "0" .. string.sub(s,2,2)
	--MsgN("SPLIT: " .. event .. ", " .. channel)
	return tonumber(event,16),tonumber(channel,16)
end

local function toDec(bytes)
	local v = 0
	local len = string.len(bytes)
	if len % 2 ~= 0 then return 0 end
	--dontprint("Len: " .. len)
	for i=1, len, 2 do
		local hex = string.sub(bytes,i,i+1)
		local byte = tonumber(hex,16)
		if byte == nil then 
			--dontprint("BAD BYTE: " .. tostring(bytes) .. "[" .. i .. "][" .. tostring(hex) .. "]") 
			return 0
		end
		v = bit.lshift(v,8)
		v = bit.bor(v,byte)
	end
	return v
end
local function readNumber(n) return toDec(readBytes(n)) end
local function readString(n) return readBytes(n,true) end

-----------------END FILE IO------------------

--------------------MIDI IO-------------------

local function readHeader()
	local sig = readString(4) dontprint(sig .. "\n")
	local size = readNumber(4) dontprint("SIZE: " .. size .. "\n")
	local ftype = readNumber(2) dontprint("FORMAT: " .. ftype .. "\n")
	local tracks = readNumber(2) dontprint("TRACKS: " .. tracks .. "\n")
	local timediv = readNumber(2) dontprint("TIMEDIV: " .. timediv .. "\n")
	
	return {timediv=timediv,size=size,ftype=ftype,tracks=tracks}
end

local function readVarLen()
	local value = readNumber(1)
	local c = 0

	if(bit.band(value,0x80) ~= 0) then
		value = bit.band(value,0x7F)
		repeat
			c = readNumber(1)
			local r2 = bit.band(c,0x7F)
			value = bit.bor(bit.lshift(value,7),r2)
		until (bit.band(c,0x80) == 0)
	end
	
	return value
end

local function readEvent(self,tracktab,rtime)
	local m = mark()
	local ntime = tonumber(readVarLen()) + rtime
	local status = readBytes(1)

	--dontprint("STATUS: " .. status)
	
	if(status == "FF") then
		local meta = readNumber(1)
		local length = readVarLen()
		local data = readBytes(tonumber(length))
		local ndata = toDec(data)
		local mname = META[meta] or "Unknown"

		data = hexToString(data)
	
		if(meta == META.TRACKNAME) then
			tracktab.name = data
		end

		dontprint("META: [" .. mname .. "] .. " .. ntime .. " | " .. meta .. " | " .. length .. " : \"" .. data .. "\" | " .. ndata .. "\n") 

		return frame(m),{ntime=ntime,meta=meta,length=length,data=data,ndata=ndata},ntime
	elseif(status == "F0") then
		error("SYSEX EVENTS NOT SUPPORTED\n")
		return -1,{},ntime
	else
		--local meta = readNumber(1)
		local event,channel = splitStatus(status)
		local param1 = readNumber(1)
		local param2 = 0
		
		self.channelData[channel] = self.channelData[channel] or {trackname = tracktab.name}

		if(event ~= EVENT.PROGRAM and event ~= EVENT.CAFTERTOUCH) then param2 = readNumber(1) end
		if(event == nil) then error("NULL EVENT\n") end
		//if(EVENT[event] == nil) then error("UNKNOWN CHANNEL EVENT[" .. event .. "]: " .. status .. " on channel " .. channel .. " at time " .. ntime .. "\n") end

		local param3 = bit.bor(bit.lshift(param2,7),param1) - 8192
		return frame(m),{event=event,channel=channel,ntime=ntime,params={param1,param2,param3}},ntime
	end
	
	return frame(m),{},ntime
end

local function readTrackData(self)
	--dontprint("READ TRACK!")

	local track = {events={},current=1,running=true}
	local time0 = 0
	local sig = readString(4) dontprint("\tSIG: " .. sig .. "\n")
	local size = readNumber(4) dontprint("\tSIZE: " .. size .. "\n")
	
	if(sig ~= "MTrk") then return false,track end
	
	local i = 0
	while i < size do
		local f,event,ntime = readEvent(self,track,time0) time0 = ntime
		if(f == -1) then return false,track end
		table.insert(track.events,event) i = i + f
		if(event.meta == META.EOT) then break end
	end
	--[[
	local over = (i - size)
	dontprint("FINISHED TRACK: OVER:" .. over .. "\n")
	
	if(over < 0) then
		local scratch = readString(-over)
		dontprint("SCRATCH: " .. scratch .. "\n")
	else
		--FILE_PTR = FILE_PTR + (over*2)+2
	end
	]]
	return true,track
end

-----------------END MIDI IO------------------

---------------MIDI INTERFACE-----------------

function MidiT:Load()
	FILE_HANDLE = self.midiFile

	FILE_PTR = 1
	local h = readHeader()
	self.midi = {header=h,tracks={}}

	for i=1, h.tracks do
		local s,track = readTrackData(self)
		table.insert(self.midi.tracks,track)
		if not s then return end
	end
end

function MidiT:GetChannelNoteRange(channel)
	local min = 127
	local max = 0
	for _,track in pairs(self.midi.tracks) do
		for _,event in pairs(track.events) do
			if(event.event == EVENT.NOTE_ON and event.channel == channel) then
				local n = event.params[1]
				if(n < min) then min = n end
				if(n > max) then max = n end
			end
		end
	end
	return min,max
end

function MidiT:GetChannelName(channel)
	if(self.channelData[channel]) then
		return self.channelData[channel].trackname
	end
	return "unknown"
end

function MidiT:GetChannelByName(channel)
	for k,v in pairs(self.channelData) do
		if(string.lower(v.trackname) == string.lower(channel)) then
			return k
		end
	end
	return -1
end

function MidiT:GetNumberOfChannels()
	local max = 0
	for _,track in pairs(self.midi.tracks) do
		for _,event in pairs(track.events) do
			if(event.channel ~= nil and event.channel > max) then
				max = event.channel
			end
		end
	end
	return max
end

function MidiT:GetFirstChannelEvent(channel,filter)
	local earliest = -1
	local event = nil
	for _,track in pairs(self.midi.tracks) do
		if(filter == nil) then
			if(track.events[1].channel == channel) then
				return track.events[1]
			end
		else
			for i=1,#track.events do
				if(track.events[i].channel == channel) then
					if(track.events[i].event == filter) then
						if(track.events[i].ntime < earliest or earliest == -1) then
							event = track.events[i]
							earliest = event.ntime
						end
					end
				end
			end
		end
	end
	return event
end

function MidiT:GetTracks()
	return self.midi.tracks
end

function MidiSequence(mfile, isString)
	local o = {}

	setmetatable(o,MidiT)
	MidiT.__index = MidiT
	
	if not isString then
		FILE_STR = false
		o.midiFile = assert(file.Open(mfile,"rb","GAME"),"Unable to open .midi file: " .. mfile .. "\n")
	else
		FILE_STR = true
		o.midiFile = mfile
	end
	--Msg(string.len(o.midiFile) .. "\n")
	
	o.channelData = {}
	o:Load()
	
	return o;
end

-------------END MIDI INTERFACE---------------

------------START FILTER CODE-----------------
--[[
	Event Structure:
	event = EVENT.*
	channel = number
	ntime = number
	params = {
		[1] = number (NOTE)
		[2] = number (VEL)
		[3] = number (CTRL DATA) (1 | 2)
	}
]]

local function procEventFilter(event, filter)
	if not filter then return true end
	if filter.event and event.event ~= filter.event then return false end
	if filter.channel and event.channel ~= filter.channel then return false end
	if filter.params then
		if filter.params[1] and event.params[1] ~= filter.params[1] then return false end
		if filter.params[2] and event.params[2] ~= filter.params[2] then return false end
		if filter.params[3] and event.params[3] ~= filter.params[3] then return false end
	end
	return true
end

local function procMetaFilter(meta, filter)
	if not filter then return true end
	if not filter.meta then return true end
	if filter.meta ~= meta then return false end
	return true
end
-----------END FILTER CODE--------------------

-----------START MIDI PLAYER------------------

local PlayerT = {}

local function TIMEFUNC()
	return RealTime()
end

function PlayerT:Reset()
	if(self.midi == nil) then error("Midi file not loaded yet\n") end
	for k,v in pairs(self.midi.tracks) do
		self.trackInfo[k] = {}
		self.trackInfo[k].current = 1
		self.trackInfo[k].running = true
	end
	self.EOSAlert = false
	self.STARTAlert = false
end

function PlayerT:ConvertTime(time)
	local ntime = time / self.midi.header.timediv
	ntime = ntime / (self.tempo / 60)
	return ntime * 1000
end

function PlayerT:GetEventTime(event)
	if(event == nil) then return 0 end
	return self:ConvertTime(event.ntime)
end

function PlayerT:GetTempo()
	return self.dynamicTempo
end

function PlayerT:Stop()
	self.started = false
end

function PlayerT:Start()
	self:Reset()
	self.clock = 0 --os.clock() * 1000
	self.lastClock = TIMEFUNC() * 1000
	self.started = true
end

function PlayerT:GetClock()
	local t = (TIMEFUNC() * 1000)
	local dt = t - self.lastClock
	self.lastClock = t

	self.clock = self.clock + dt * (self.dynamicTempo / self.tempo)

	return self.clock - 1000
end

function PlayerT:RunTrackEvents(trackid,time0)
	if(self.started == false) then return end
	local track = self.midi.tracks[trackid]
	local trackInfo = self.trackInfo[trackid]
	if(track == nil) then error("Null Track") end
	
	local running = trackInfo.running
	local current = trackInfo.current
	if(trackInfo.current > #track.events) then return end
	
	local cevent = track.events[trackInfo.current]
	if(cevent.ntime == nil) then 
		self.trackInfo[trackid].current = current + 1
		return running
	end
	
	local ntime = cevent.ntime / self.midi.header.timediv
	ntime = ntime / (self.tempo / 60)
	ntime = ntime * 1000
	
	local canExec = ntime <= time0
	if(canExec) then
		if(cevent.meta ~= nil) then 
			if(cevent.meta == META.TEMPO) then
				self.dynamicTempo = MICROSECONDS_PER_MINUTE / cevent.ndata
				if(self.tempo == 1) then self.tempo = self.dynamicTempo end
				dontprint("TEMPO: " .. self.dynamicTempo .. " => " .. self.tempo .. "\n")
			end
			self.OnMetaEvent(trackid,cevent.meta,cevent.data,cevent.ndata)
			if(cevent.meta == META.EOT) then
				self.trackInfo[trackid].running = false
			end
			if(self.STARTAlert == false) then
				self.STARTAlert = true
				self:SongStarted()
			end
		elseif(cevent.event ~= nil) then
			self.OnMidiEvent(trackid,cevent.event,cevent.params,cevent.channel)
			if(cevent.event == 9) then
				local b,e = pcall(self.NoteOn, cevent.params[1],cevent.params[2],cevent.channel)
				if not b then MsgN("Error in NoteOn: " .. e) end
			elseif(cevent.event == 8) then
				local b,e = pcall(self.NoteOff, cevent.params[1],cevent.params[2],cevent.channel)
				if not b then MsgN("Error in NoteOff: " .. e) end
			end
		end
	
		self.trackInfo[trackid].current = current + 1
		running = self:RunTrackEvents(trackid,time0)
	end
	return running
end

function PlayerT:RunSequenceEvents(time0)
	if(self.started == false) then return end
	local trackrunning = false
	for k,v in pairs(self.midi.tracks) do
		self:RunTrackEvents(k,time0)
		if(self.trackInfo[k].running == true) then
			trackrunning = true
		end
	end
	
	if(trackrunning == false and self.EOSAlert == false) then
		self.EOSAlert = true
		self.SongFinished()
	end
	
	return trackrunning
end

function PlayerT:GetNextTrackEvent(trackid,filter)
	local track = self.midi.tracks[trackid]
	local trackInfo = self.trackInfo[trackid]
	if(track == nil) then error("Null Track") end
	
	if(filter == nil) then
		return track.events[trackInfo.current+1]
	else
		for i=trackInfo.current+1,#track.events do
			local current = track.events[i]
			if procEventFilter(current, filter) then return track.events[i] end
			if procMetaFilter(current.meta, filter) then return track.events[i] end
		end
	end
	return nil
end

function PlayerT:GetActiveNotes(channel, time, cache, start)
	start = start or 1
	local last = start
	for _,track in pairs(self.midi.tracks) do
		for i=start,#track.events do
			local event = track.events[i]
			if event.channel == channel then
				local t = self:GetEventTime(event)
				if t <= time then
					if cache then
						if(event.event == EVENT.NOTE_ON) then
							cache[event.params[1]] = event.params[2] / 127
						elseif(event.event == EVENT.NOTE_OFF) then
							cache[event.params[1]] = 0
						end
					end
					last = i
				else
					return last
				end
			end
		end
	end
	return last
end

function PlayerT:GetFirstChannelEvent(...)
	return self.sequence:GetFirstChannelEvent(unpack({...}))
end

function PlayerT:GetTracks()
	return self.sequence:GetTracks()
end

function PlayerT:GetNumberOfChannels()
	return self.sequence:GetNumberOfChannels()
end

function PlayerT:GetChannelName(...)
	return self.sequence:GetChannelName(unpack({...}))
end

function PlayerT:GetChannelByName(...)
	return self.sequence:GetChannelByName(unpack({...}))
end

function PlayerT:GetChannelNoteRange(...)
	return self.sequence:GetChannelNoteRange(unpack({...}))
end

function MidiPlayer(sequence)
	local o = {}

	setmetatable(o,PlayerT)
	PlayerT.__index = PlayerT

	o.midi = sequence.midi
	o.sequence = sequence
	o.trackInfo = {}
	o.tempo = 1

	o.dynamicTempo = 1
	o.clock = 0
	o.lastClock = 0
	o.started = false
	o.EOSAlert = false
	o.STARTAlert = false
	o.OnMetaEvent = function() end
	o.OnMidiEvent = function() end
	o.SongFinished = function() end
	o.SongStarted = function() end
	o.NoteOn = function() end
	o.NoteOff = function() end

	return o
end