
util.AddNetworkString("gmt_timer_net")

include("shared.lua")
include("sh_error.lua")
include("sh_screens.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_ctrlpanel.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_error.lua")
AddCSLuaFile("sh_screens.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
end

/*
	POWER = 0,
	TIMER_MODE = 1,
	TIMER_TIME = 2,		// needs uint19
	TIMER_START = 3,
	TIMER_PAUSE = 4,
	TIMER_STOP = 5,
	TITLE = 6,			// needs string
	DESC = 7,			// needs string
	CELEB = 8,
	LOCAL = 9,
	TARGET_TIME = 10,	// needs string
	NOPLUS = 11,
	NEWYEAR = 12,
	LOCK = 13,
	REALTIME = 14
*/

net.Receive("gmt_timer_net",function( len, ply )

  if !ply:IsAdmin() then return end

  local ent = net.ReadEntity()
  local int = net.ReadInt(8)

  if !IsValid(ent) then return end

  if int == ent.Net.POWER then ent:SetNWBool( "Power", !ent:GetNWBool("Power") ) end
  if int == ent.Net.LOCK then ent:SetNWBool( "Locked", !ent:GetNWBool("Locked") ) end

  if int == ent.Net.TITLE then ent:SetNWString( "Title", net.ReadString() ) end
  if int == ent.Net.DESC then ent:SetNWString( "Desc", net.ReadString() ) end

  if int == ent.Net.REALTIME then ent:SetNWBool( "RealTime", !ent:GetNWBool("RealTime") ) ent:SetNWBool( "TimerMode", false ) ent:SetNWBool( "Local", false ) end
  if int == ent.Net.LOCAL then ent:SetNWBool( "Local", !ent:GetNWBool("Local") ) ent:SetNWBool( "RealTime", false ) ent:SetNWBool( "TimerMode", false ) end
  if int == ent.Net.NOPLUS then ent:SetNWBool( "NoPlus", !ent:GetNWBool("NoPlus") ) end
  if int == ent.Net.TIMER_MODE then ent:SetNWBool( "TimerMode", !ent:GetNWBool("TimerMode") ) ent:SetNWBool( "RealTime", false ) ent:SetNWBool( "Local", false ) end
  if int == ent.Net.CELEB then ent:SetNWBool( "Celeb", !ent:GetNWBool("Celeb") ) end

  if int == ent.Net.TARGET_TIME then ent:SetNWString( "TargetTime", net.ReadString() ) end
  if int == ent.Net.TIMER_TIME then ent:SetNWFloat( "TimerLength", net.ReadUInt(19) ) end
  if int == ent.Net.TIMER_START then ent:SetTimerBegin() ent:SetNWBool( "TimerRunning", true ) end
  if int == ent.Net.TIMER_PAUSE then ent:SetNWBool( "TimerRunning", false ) end
  if int == ent.Net.TIMER_STOP then ent:SetNWBool( "TimerRunning", false ) ent:SetNWBool( "TimerMode", false ) end
  if int == ent.Net.NEWYEAR then ent:SetNWBool( "NewYears", !ent:GetNWBool("NewYears") ) end

end)
