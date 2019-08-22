AddCSLuaFile( "shared.lua" )

ENT.Type = "anim"

ENT.PrintName	= "Soundscape"
ENT.Author		= ""
ENT.Contact		= ""
ENT.Purpose		= ""
ENT.Instructions	= ""


ENT.SoundFile = ""
ENT.SoundThink = 0

ENT.Debug = false


function ENT:Initialize()
	RegisterNWTable( self, {
		{ "SoundFile", "", NWTYPE_STRING, REPL_EVERYONE },
		{ "VolScale", 1, NWTYPE_FLOAT, REPL_EVERYONE }
	} )
end

local soundScapes = CreateClientConVar( "gmt_soundscapes_enable", "1", true, false )
local soundVol = CreateClientConVar( "gmt_soundscapes_volume", "100", true, false )

if SERVER then return end

function ENT:Think()

	if self.SoundThink >= CurTime() then return end
	
	local delay = SoundDuration( self.SoundFile )
	local randDelay = math.random( 1, 10 )
	
	local vol = math.random( 60, 80 ) * self.VolScale
	local volScale = ( soundVol:GetInt() / 100 )
	vol = vol * volScale
	
	self.Volume = vol
	
	local pitch = math.random( 50, 180 )
	
	if soundScapes:GetBool() then
		self:EmitSound( self.SoundFile, vol, pitch )
	end
	
	self.SoundThink = CurTime() + delay + randDelay

end

function ENT:Draw()
	
	if LocalPlayer():IsAdmin() && self.Debug then
	
		local ang = LocalPlayer():EyeAngles()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		
		local color = Color( 255, 0, 0, 255 )
		if soundScapes:GetBool() then
			color = Color( 0, 255, 0, 255 )
		end
		
		cam.Start3D2D( self:GetPos(), Angle( 0, ang.y, ang.r ), 1 )
			draw.DrawText( "Soundscape: " .. self.SoundFile, "ScoreboardText", 0, 0, color, TEXT_ALIGN_CENTER )
		cam.End3D2D()
			
	end
	
end
