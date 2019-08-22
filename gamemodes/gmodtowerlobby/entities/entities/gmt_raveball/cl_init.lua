include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Scale = 8
ENT.IsLoading = false
ENT.FFT = {}
ENT.CurrentSong = ""
ENT.LastH = 0
ENT.Beam = nil
ENT.BeamEnd = {}
ENT.BigCol = Color(255, 255, 255)
ENT.LastSong = ""
ENT.Location = 0

net.Receive("gmt_raveroomset",function()
	local ent = net.ReadEntity()
	local loc = net.ReadInt(16)

	if !IsValid(ent) then return end

	ent:SetRaveLoc(loc)

end)

net.Receive("gmt_raveset",function()
	local ent = net.ReadEntity()
	local ply = net.ReadPlayer()

	if LocalPlayer() != ply then return end

	Derma_StringRequest(
	"Rave Ball",
	"Please enter your music URL. (SoundCloud, Dropbox, Google Drive or direct MP3 link.)",
	"",
	function( text ) RunConsoleCommand("gmt_rave_set",ent:EntIndex(),text) end,
	function( text ) end
 	)
end)

local function DrawRave(self)
	local myloc = (GTowerLocation:GetPlyLocation( LocalPlayer() ) or 0)
	if myloc == self.Location then return true end
	return false
end

function ENT:SetRaveLoc(loc)
	self.Location = (loc or 0)
end

function ENT:Initialize()
	for i=1, 1028 do
		self.FFT[i] = 0
	end
end

function ENT:OnRemove()
	if IsValid( self.Song ) then
		self.Song:Stop()
		self.Song = nil
	end
end

function ENT:DrawParticles( )

	if !DrawRave(self) then return end

	local pos = self:GetPos()

	if !self.Emitter then
		self.Emitter = ParticleEmitter( pos )
	end

	for i=0, 4 do
		local smoke = self.Emitter:Add( "particle/particle_noisesphere", pos )
		if smoke then
			local fftAverage = self:GetAverage( self.Song, 1, 5 )
			local vel = VectorRand():GetNormal() * math.Rand( 150, 300 ) * (fftAverage * 3)
			smoke:SetVelocity( vel )
			smoke:SetLifeTime( 0 )
			smoke:SetDieTime( 2 )
			smoke:SetStartAlpha( 10 )
			smoke:SetEndAlpha( 0 )

			smoke:SetRoll( 0, 360 )
			smoke:SetRollDelta( math.Rand( -1, 1 ) )

			local Size = math.Rand( 5, 10 )
			smoke:SetStartSize( Size * (fftAverage * 5) )
			smoke:SetEndSize( Size * math.Rand( 2, 5 ) )

			smoke:SetAirResistance( 100 )
			smoke:SetGravity( Vector( 0, 0, 0 ) )

			local RandDarkness = math.Rand( 0.25, 1 )
			smoke:SetColor( 255 * RandDarkness, 255 * RandDarkness, 255 * RandDarkness )
		end
	end
end

// youtube-mp3 api
function ENT:_cc( a )
	local b = 1
	local c = 0
	local d, e
	for e = 1, string.len(a) do
		d = string.byte( string.sub( a, e, e ) )
		b = (b + d) % 65521
		c = (c + b) % 65521
	end
	return bit.bor( bit.lshift( c, 16 ), b )
end

function ENT:HandleParsing( Service )
	if Service == "Soundcloud" then
		http.Fetch( "https://api.soundcloud.com/resolve.json?url=" .. self.LastSong .. "&client_id=" .. "831fdf2953440ea6e18c24717406f6b2",
		function( body, len, headers, code )
			local tbl = util.JSONToTable( body )
			if tbl and tbl["stream_url"] and tbl["title"] then
				self:SetSong( tbl["stream_url"] .. "?client_id=" .. "831fdf2953440ea6e18c24717406f6b2" )
			else
				Msg2("This song is not available for streaming, please try a different one.")
				Error( "[SOUNDCLOUD] Failed to fetch song No Stream_URL. Please input a new song/same song\n" )
				self.LastSong = ""
			end
		end,
		function( error )
			Error( "[SOUNDCLOUD] Failed to fetch song error " .. error .. ". Please input a new song/same song\n" )
			self.LastSong = ""
		end )
	end

	if Service == "Youtube" then
		self.LastSong = self.LastSong .. "&" // Append & just in case
		local VideoID = string.match(self.LastSong, "%?v=(.-)&")
		http.Fetch( "http://www.youtube-mp3.org/a/itemInfo/?video_id=" .. VideoID .. "&ac=www&t=grp&r=" .. os.time(),
		function( body, len, headers, code )
			if body == "$$$ERROR$$$" then
				Error( "[Youtube] Failed to fetch song error $$$ERROR$$$\n" )
				self:SetSong("")
				return
			end

			local _, hashStart = string.find( body, '"h" : "', titleEnd, true )
			if !hashStart then
				Error( "[Youtube] Failed to fetch song error $$$ERROR$$$\n" )
				self:SetSong("")
				return
			end
			hashStart = hashStart + 1
			local hashEnd, _ = string.find( body, '"', hashStart, true )
			hashEnd = hashEnd - 1
			local Hash = string.sub( body, hashStart, hashEnd )
			local time = os.time()
			local time2 = self:_cc( VideoID .. time )
			self:SetSong("http://www.youtube-mp3.org/get?ab=128&video_id=" .. VideoID .. "&h=" .. Hash .. "&r=" .. time .. "." .. time2)
		end,
		function( error )
			Error( "[Youtube] Failed to fetch song error " .. error .. "\n" )
			self:SetSong( "" )
		end )
	end
end

function ENT:Think()

	if !DrawRave(self) then
		if IsValid( self.Song ) then
			self.Song:SetVolume(0.0001)
		end
		return
	else
		if IsValid( self.Song ) then
			self.Song:SetVolume(1)
		end
	end

	self.LastSong = self:GetSong()
	if(!self.Beam) then
		self:SetupBeams()
	end
	if( self.LastSong ~= self.CurrentSong ) then
		self.LastAng = Angle(0,0,0)
		self.CurrentSong = self.LastSong
		self.IsLoading = true

		if string.find( self.LastSong or "", "soundcloud.com/" ) and string.find( self.LastSong or "", "api." ) == nil then
			self:HandleParsing( "Soundcloud" )
		end
		if string.find( self.LastSong or "", "youtu.be/" ) then
			self.LastSong = "https://www.youtube.com/watch?v=" .. string.Replace(self.LastSong, "http://youtu.be/", "")
		end
		if string.find( self.LastSong or "", "youtube.com/" ) then
			self:HandleParsing( "Youtube" )
		end
		if IsValid( self.Song ) then
			self.Song:Stop()
			self.Song = nil
		end
		sound.PlayURL( self.CurrentSong, "noplay 3d", function(channel)
			self.IsLoading = false
			if IsValid( channel ) then
				channel:SetPos( self:GetPos() )
				channel:Play()
				self.Song = channel
			end
		end )
	end

	if( IsValid( self.Song ) ) then
		self.Song:Set3DFadeDistance( self:GetFadeDistance(), 1000000000 )
		self.Song:FFT( self.FFT, FFT_2048 )
		self.Song:SetPos( self:GetPos() )
		self.Scale = 16 + self:GetAverage( self.Song, 1, 3 ) * 32
	end

	self.LastH = self.LastH + 0.2
	self.LastH = math.fmod( self.LastH, 360 )


	local a,b = Vector(-1, -1, -1) * 2048, Vector(1,1,1) * 2048

	OrderVectors( a,b )

	self:SetRenderBounds( a, b )

	for i=1, 9 do
		self.BeamEnd[i] = self.BeamEnd[i] or {Pos = self:GetPos(), Col = Color(0,0,0,0)}
		local dlight = DynamicLight( self:EntIndex() + i )
		if ( dlight ) then
			dlight.Pos = self.BeamEnd[i].Pos or self:GetPos()
			dlight.r = self.BeamEnd[i].Col.r
			dlight.g = self.BeamEnd[i].Col.g
			dlight.b = self.BeamEnd[i].Col.b
			dlight.Brightness = 0.5
			dlight.Size = self:GetAverage( self.Song, 1, 5 ) * 2024
			dlight.Decay = (self:GetAverage( self.Song, 1, 5 ) * 2024) * 2
			dlight.DieTime = CurTime() + 1
			dlight.Style = 0
		end
	end
	local dlight = DynamicLight( self:EntIndex() + 10)
	if ( dlight ) then
		local r, g, b, a = col
		dlight.Pos = self:GetPos()
		dlight.r = self.BigCol.r
		dlight.g = self.BigCol.g
		dlight.b = self.BigCol.b
		dlight.Brightness = 1
		dlight.Size = self.Scale * 12
		dlight.Decay = (self.Scale * 12) * 2
		dlight.DieTime = CurTime() + 1
		dlight.Style = 0
	end
	if self.Scale > 18 then
		self:DrawParticles()
	end
end

function ENT:GetAverage( stream, lower, upper )

	lower = math.Round( math.Clamp( lower, 1, 2048 ) )
	upper = math.Round( math.Clamp( upper, 1, 2048 ) )

	local n = 0
	for i = lower, upper do
		n = n + (self.FFT[i] or 0)
	end

	local div = ( upper - lower )
	return div == 0 && 0 || n / div

end

function ENT:Draw()
	if( !IsValid(self.Song) ) then
		self.LastAng = self:GetAngles()
		self:DrawModel() -- Draw the Model()
	end
end

function ENT:SetupBeams()
	self.Beam = {}
	for i=1, 9 do
		self.Beam[i] = RealTime()
	end
end

local boxMaterial = Material( "hlmv/floor" )
local lasermat = Material("effects/laser1.vmt")
local matLight = CreateMaterial("boxvisLight", "UnLitGeneric", {
	["$basetexture"] = "sprites/light_glow01",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
	["$ignorez"] = 0,
}) //Material( "sprites/glow_test02" )

function ENT:DrawTranslucent()

	if !DrawRave(self) then return end

	if !self.LastAng then
		self.LastAng = self:GetAngles()
	end
	local fftAverage = self:GetAverage( self.Song, 1, 5 )
	local Ang = self:GetAngles()
	local col = HSVToColor(self.LastH, 1, 0.8)
	render.SetMaterial( boxMaterial )

	boxMaterial:SetFloat( "$alpha", 0.8 )

	boxMaterial:SetVector( "$color", Vector(col.r / 255, col.g / 255, col.b / 255) )
	--render.DrawBox( self:GetPos(), self.LastAng - Angle(self.LastAng.p*2, self.LastAng.p*-2, 0), Vector(-1, -1, -1) * self.Scale, Vector(1, 1, 1) * self.Scale, col, false )

	self.BigCol = col
	col = HSVToColor(self.LastH + 128, 1, 1)
	boxMaterial:SetVector( "$color", Vector(1, 1, 1) )
	self.LastAng.p = self.LastAng.p + fftAverage * 2
	self:DrawModel()
	self:SetModelScale(math.Clamp( (self.Scale / 12) , 1, 1000))
	self:SetColor(HSVToColor(self.LastH + 256, 1, 1))
	--render.DrawBox( self:GetPos(), self.LastAng - Angle(0, 0, self.LastAng.p*3), Vector(-1, -1, -1) * self.Scale * 0.5, Vector(1, 1, 1) * self.Scale * 0.5, Color(255, 255, 255, 255), false )


	if( IsValid(self.Song) ) then
		col = HSVToColor(self.LastH + 256, 1, 1)
		boxMaterial:SetVector( "$color", Vector(col.r / 255, col.g / 255, col.b / 255) )

		for i=1, 25 do
			local lscale = 1.6 + (self.FFT[i] + self.FFT[i + 1]) * (8 + i)
			local base = self:GetPos()
			local basepos1 = base + Vector(math.sin(RealTime() + i) * 18, math.cos(RealTime() + i) * 18, math.cos(RealTime()*2 + i) * 18) * self.Scale * 0.1
			local basepos2 = base + Vector(math.sin(RealTime() + i) * 18, math.cos(RealTime() + i) * 18, math.sin(RealTime()*2 + i) * 18) * self.Scale * 0.1

			render.DrawBox( basepos1, (base - basepos1):Angle(), Vector(-1, -1, -1) * lscale, Vector(1, 1, 1) * lscale, col, false )
			lscale = 1.6 + math.pow(self.FFT[i], 2) * (8*i)//(math.abs(math.log(2048)/math.log(self.FFT[i])))// * (8 + i)
			render.DrawBox( basepos2, (base - basepos2):Angle(), Vector(-1, -1, -1) * lscale, Vector(1, 1, 1) * lscale, col, false )
		end

		col = HSVToColor(self.LastH + 300, 1, 1)

		for i=1, 9 do
			local add = fftAverage * 2
			local tr = util.TraceLine( {
				start = self:GetPos(),
				endpos = self:GetPos() + Vector(math.sin(RealTime() + i*2 + add * 0.5)*2048 + (i*16),math.cos(RealTime() + i*2 + add * 0.5)*2048 + (i*16),math.cos(self.Beam[i]) - math.sin(self.Beam[i]) * 2048 + (i*64)),
				filter = {self},
			})

			self.Beam[i] = self.Beam[i]+(self.FFT[i] * 0.1)

			if tr.Hit then
				render.SetMaterial( lasermat )
				render.StartBeam( 2 )
				render.AddBeam(
					self:GetPos(),
					30,
					CurTime(),
					col		// Color
				)
				render.AddBeam(
					tr.HitPos,
					30,
					CurTime() + 1,
					Color( 0, 0, 0, 255 )
				)
				render.EndBeam()
				render.SetMaterial( matLight )
				render.DrawSprite( tr.HitPos, 32, 32, col )
				self.BeamEnd[i] = {Pos = tr.HitPos, Col = col}
			end
		end
	end

end

local enableeffects = CreateClientConVar("gmt_visualizer_effects","1",true,false)

hook.Add( "RenderScreenspaceEffects", "screenspaceBoxVis", function()

	if !enableeffects:GetBool() then return end

	local w, h = ScrW(), ScrH()
	local eyepos, eyeangles = EyePos(), EyeAngles()
	for _, boxvisStream in ipairs( ents.FindByClass("gmt_raveball") or {} ) do
		if !DrawRave(boxvisStream) then continue end
		if IsValid( boxvisStream ) then
			local pos = boxvisStream:GetPos()

			local tr = util.TraceLine( {
				start = EyePos(),
				endpos = pos,
				filter = {LocalPlayer()}
			} )
			if tr.HitWorld then continue end

			local screenPos = pos:ToScreen()
			local distance = eyepos:Distance( pos )
			local multi = math.max( eyeangles:Forward():DotProduct( ( pos - eyepos ):GetNormal() ), 0 ) ^ 3
			multi = multi * math.Clamp( ( -distance / 6000 ) + 1, 0, 1 )
			if multi < 0.001 then return end
			multi = math.Clamp( multi, 0, 1 )
			local r = 1 - math.Clamp( pos:Distance(eyepos) / 2048, 0, 1 )
			local volume = (boxvisStream:GetAverage( boxvisStream.Song, 1, 15 )) * -1
			local blur = math.Clamp( ( volume * -10 ) + 1, 0.3, 1 )
			local invert = volume * -10 + 1
			local darkness = -multi + 1
			DrawSunbeams( math.Clamp( 1 * volume, .9, 1 ), math.Clamp( .8 * volume, .1, .8 ), math.Clamp( 3 * boxvisStream:GetAverage( boxvisStream.Song, 1, 5 ), 2.5, 3 ), screenPos.x / w, screenPos.y / h )
			DrawSunbeams( darkness, math.max( volume * 0.8, 0.1 ), math.max( volume * 0.5, 0.3 ), screenPos.x / w, screenPos.y / h )
			DrawBloom( darkness, invert * ( multi / 10 ), math.max( invert * 40 + 2, 5 ), math.max( invert * 40 + 2, 5 ), 4, 8, 1, 1, 1 )
			DrawMotionBlur( blur, 0, 0.01 )
			//DrawBloom( 0.34, 0.12, 5, 5, 14, 1, 1, 1, 1 ) -- Is it really worth it?!
		end
	end
end )
