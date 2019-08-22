--OUTDATED
/*require("bass")
module("BassStream", package.seeall )

ValidStreams = {}

local ZeroVec = Vector(0,0,0)
local MetaTable = {
	__index = getfenv()
}
DEBUG = false

local function EndStream( ent )
	if !IsValid( ent ) && !ent.EmitStream then return end

	ent:StopStream()
end

CreateClientConVar( "gmt_ignoreemitstream", 0, false, false )

local function ignoreStreamChange( cvar, previous, new )
	if ( new == "1" ) then
		for _, v in ipairs( ents.FindByClass( "gmt_emitstream" ) ) do
			EndStream( v )
		end
	end
end
cvars.AddChangeCallback( "gmt_ignoreemitstream", ignoreStreamChange )



function New( RequestSong )

	if BASS == nil then
		ErrorNoHalt("Could not find BASS module.")
		return
	end

	if ( GetConVarNumber( "gmt_ignoreemitstream" ) == 1 ) then
		Msg( "Notice: gmt_ignoreemitstream is set to 1, ignoring stream!\n" )
		return
	end

	if string.sub( RequestSong, 0, 5 ) != "http:" then

		if string.sub( RequestSong , -4) == ".mp3" then
			RequestSong = GAMEMODE.WebsiteUrl .. "radio/radiodata/" .. RequestSong
		else
			RequestSong = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=" .. RequestSong
		end

	else


	end


	print("New bass: ", RequestSong )

	local o = setmetatable( {
		Song = RequestSong,
		Loading = false,
		InvalidStream = false,
		Stream = nil,
		Lastfft2048 = 0,
		Savedfft2048 = {}
	}, MetaTable )

	return o


end

function SetEntity( self, Entity )
	self.Entity = Entity
	if DEBUG then print("Entity set: ", self, Entity ) end
end

function GetEntity( self )
	return self.Entity
end

function LocationLimit( self, limit )

	self.CheckLimitVal = limit

	local LimitType = type( self.CheckLimitVal )

	if LimitType == "number" then
		self.InLimit = self.InLimitNumber
	elseif LimitType == "table" then
		self.InLimit = self.InLimitTable
	elseif LimitType == "function" then
		self.InLimit = self.InLimitFunc
	else
		//Setting it to nil will cause it to go to it's metatable, which is to return true
		self.InLimit = nil
	end

end

function CheckLimit( self, PlyLoc )

	if self:InLimit( PlyLoc ) then

		if !self.Stream && self.Loading != true then
			if DEBUG then print("Starting stream by limit") end
			self:Play()
		end

	else

		if self.Stream then
			if DEBUG then print("STOPPING stream by limit") end
			self:Stop()
			self.Stream = nil
		end

	end

end

function InLimitTable( self, loc )
	return table.HasValue( self.CheckLimitVal, loc )
end

function InLimitNumber( self, loc )
	return self.CheckLimitVal == loc
end

function InLimitFunc( self, loc )
	return self.CheckLimitVal( loc )
end

function InLimit( self, loc )

	if self.Entity && self.Entity:IsValid() && self.Entity.InLimit then

		return self.Entity:InLimit( loc )
	end

	return true
end

function Stop( self )
	if DEBUG then print("STREAM: Stopping stream") end

	if self.Stream then
		self.Stream:stop()
	end

	table.RemoveValue( ValidStreams, self )

	self.Stream = nil
	self.Loading = false
end

function Play( self )

	if self.InvalidStream == true then
		return
	end

	if DEBUG then print("STREAM: Loading: ", self.Song ) end

	self:Stop()
	self.Loading = true

	BASS.StreamFileURL( self.Song, 0, function(basschannel, error)

		local WasLoading = self.Loading

		self.Loading = false

		if !basschannel then
			if error == 40 || error == 2 then
				error = T("RadioTimeout")
			elseif error == 41 then
				error = T("RadioUnsupportedFormat")
			elseif error == 8 then
				error = T("RadioBASSInitError")
			else
				error = T("RadioUnknown") .. " " .. tostring(error)
			end

			print("ES Err: ", error)
			self.Stream = nil
			self.InvalidStream = true

			return
		end

		self.Stream = basschannel

		//Something might have called :Stop() in the mean time?
		if WasLoading == true then
			self.Stream:play()
		end

		timer.Simple( 0.0, self.UpdateVolume, self )
		table.insert( ValidStreams, self )

	end )

end

function GetAvgScale( Total )
	local Bands = self:fft2048()

	local Sum = 0
	local Max = 0
	Total = Total or 40

	for i=1, Total do
		Max = math.max( Max, Bands[i] )
		Sum = Sum + Bands[i]
	end

	local Avg = Sum / Total


	self.NextScale = 0.2 + math.Clamp( ( Avg / Max ) * 0.8, 0, 0.8 )

end

function fft2048( self )

	if self.Lastfft2048 == CurTime() then
		return self.Savedfft2048
	end

	self.Lastfft2048 = CurTime()
	self.Savedfft2048 = self.Stream:fft2048()

	return self.Savedfft2048

end

function IsRadio( self )
	local Length = self.Stream:getlength()

	return Length < 0
end

function IsPlaying( self )
	return self.Stream && self.Stream:getplaying()
end

function IsValid( self )
	return self.Stream != nil && self.InvalidStream == false
end

function Think( self, pos )
	if self.InvalidStream == true then
		return
	end

	if Location then
		self:CheckLimit( LocalPlayer():Location() )
	end

	if self.Stream then
		self:UpdatePos( pos )

		if !self:IsPlaying() then
			self:Stop()
		end
	end

end

function UpdateVolume( self, vol )
	if self.Stream && !self.IsMuted then
		self.Stream:setvolume( vol or Volume.GetNormal() )
	end
end

function UpdatePos( self, pos )
	pos.z = -pos.z

	self.Stream:set3dposition( pos / 5, ZeroVec, ZeroVec )
end

local function BassThink()

	local ply = LocalPlayer()
	local eyepos = ply:EyePos() / 5
	local vel = ply:GetVelocity()
	local eyeangles = ply:GetAimVector():Angle()

	// threshold, 89 exact is backwards accord to BASS
	eyeangles.p = math.Clamp(eyeangles.p, -89, 88.9)
	eyepos.z = -eyepos.z

	local forward = eyeangles:Forward()
	local up = eyeangles:Up() * -1

	BASS.SetPosition(eyepos, vel * 0.005, forward, up)
end

function CheckBassLocation( ply, loc )
	if ply == LocalPlayer() then
		for _, v in pairs( ValidStreams ) do
			v:CheckLimit( loc )
		end
	end
end

function UpdateBassVolumes( vol )
	for _, v in pairs( ValidStreams ) do
		v:UpdateVolume( vol )
	end
end

if BASS then
	hook.Add("Think", "UpdateBassPosition", BassThink )
	hook.Add("Location", "CheckBass", CheckBassLocation )
	hook.Add("Volume", "UpdateBassValues", UpdateBassVolumes )
end*/
