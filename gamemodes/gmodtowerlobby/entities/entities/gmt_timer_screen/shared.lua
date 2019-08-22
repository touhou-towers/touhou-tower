
-----------------------------------------------------
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.Spawnable		= true
ENT.AdminSpawnable  = true
ENT.PrintName		= "Countdown Timer"
ENT.Category 		= "mitterdoo"
ENT.Model			= "models/map_detail/new_years/big_countdown_board.mdl"

ENT.StartAngles		= Angle( 0, 0, 0 )
ENT.StartPos		= Vector( 592.453613, -1.725400, -895.96875 )

ENT.PanelPos		= Vector( -7.462866, 0, 48.111664 )
ENT.LockTime		= 45

ENT.Net = { // networking for control panel (8 bits)
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

}

function ENT:GetPower()
	return self:GetNWBool("Power")
end

function ENT:GetLocked()
	return self:GetNWBool("Locked")
end

function ENT:GetTitle()
	return self:GetNWString("Title")
end

function ENT:GetDescription()
	return self:GetNWString("Desc")
end

function ENT:GetIsNewYears()
	return self:GetNWBool("NewYears")
end

function ENT:GetTimerMode()
	return self:GetNWBool("TimerMode")
end

function ENT:GetTimerRunning()
	return false
end

function ENT:GetTimerLength()
	return self:GetNWFloat("TimerLength")
end

function ENT:GetRealTime()
	return self:GetNWBool("RealTime")
end

function ENT:GetLocal()
	return self:GetNWBool("Local")
end

function ENT:GetCeleb()
	return self:GetNWBool("Celeb")
end

function ENT:GetNoPlus()
	return self:GetNWBool("NoPlus")
end

function ENT:GetServerTarget()
	return 1
end

function ENT:GetPowerOnTime()
	return 2
end

function ENT:GetTimerRunning()
	return self:GetNWBool("TimerRunning")
end

function ENT:GetTargetTime()
	return self:GetNWString("TargetTime")
end

function ENT:SetTimerBegin(t)
	self:SetNWFloat("BeginTime",CurTime())
end

function ENT:GetTimerBegin()
	return self:GetNWFloat("BeginTime")
end

function ENT:GetLocalTimezone()
  local now = os.time()
  return os.difftime(now, os.time(os.date("!*t", now)))
end
function ENT:LocalUnix()
	return os.time( os.date( "*t" ) )
end
function ENT:GetTimeTable()
	local isdst = os.date( "*t" ).isdst
	// DATE FORMAT: "HH:MM:SS mm-dd-yyyy"

	local f1, f2 = self:GetTargetTime():find( "%d%d:%d%d:%d%d %d%d%-%d%d%-%d%d%d%d" )
	local TargetTime = f1 and self:GetTargetTime():sub( f1, f2 ) or "00:00:00 01-01-2015"
	local TargetTab = {}
	TargetTab.hour = tonumber( TargetTime:sub( 1, 2 ) )
	TargetTab.min = tonumber( TargetTime:sub( 4, 5 ) )
	TargetTab.sec = tonumber( TargetTime:sub( 7, 8 ) )
	TargetTab.month = tonumber( TargetTime:sub( 10, 11 ) )
	TargetTab.day = tonumber( TargetTime:sub( 13, 14 ) )
	TargetTab.year = tonumber( TargetTime:sub( 16, 19 ) )

	TargetTab.isdst = isdst
	return TargetTime, TargetTab
end

function ENT:SetupDataTables()

	/*self:NetworkVar( "String",	0, 	"TargetTime" )
	self:NetworkVar( "String",	1, 	"Title" )
	self:NetworkVar( "String",	2, 	"Description" )

	self:NetworkVar( "Bool",	0, 	"Local" )
	self:NetworkVar( "Bool",	1, 	"Celeb" )
	self:NetworkVar( "Bool",	2, 	"TimerMode" )
	self:NetworkVar( "Bool",	3, 	"TimerRunning" )
	self:NetworkVar( "Bool",	4, 	"IsNewYears" )
	self:NetworkVar( "Bool",	5, 	"NoPlus" )
	self:NetworkVar( "Bool",	6,	"Power" )
	self:NetworkVar( "Bool",	7,	"Locked" )
	self:NetworkVar( "Bool",	8,	"RealTime" )

	self:NetworkVar( "Int",		0,	"TimerOriginal" )

	self:NetworkVar( "Float",	0,	"TimerBegin" )
	self:NetworkVar( "Float",	1, 	"TimerLength" ) // for timer mode
	self:NetworkVar( "Float",	2,	"PowerOnTime" )
	self:NetworkVar( "Float",	3,	"LockTime" )
	self:NetworkVar( "Float",	4,	"ServerTarget" )*/

end
function ENT:IsPoweringOn()
	return self:GetPowerOnTime() > CurTime()
end

function ENT:GetRemaining()

	if self:GetTimerMode() then
		return math.min( math.floor( self:GetTimerBegin() + self:GetTimerLength() - CurTime() ), self:GetTimerLength() )
	else
		if self:GetRealTime() then
			local tab = os.date( '*t', os.time() )
			return tab.sec + tab.min * 60 + tab.hour * 60 * 60
		else
			if CLIENT and !self:GetLocal() then
				return math.floor( self:GetServerTarget() - CurTime() )
			end
			local f1, f2 = self:GetTargetTime():find( "%d%d:%d%d:%d%d %d%d%-%d%d%-%d%d%d%d" )
			local TargetTime = f1 and self:GetTargetTime():sub( f1, f2 ) or "20:00:00 24-11-2018"

			local Target = {}
			Target.hour = tonumber( TargetTime:sub( 1, 2 ) )
			Target.min = tonumber( TargetTime:sub( 4, 5 ) )
			Target.sec = tonumber( TargetTime:sub( 7, 8 ) )
			Target.month = tonumber( TargetTime:sub( 10, 11 ) )
			Target.day = tonumber( TargetTime:sub( 13, 14 ) )
			Target.year = tonumber( TargetTime:sub( 16, 19 ) )

			Target.isdst = isdst
			local Tgt = os.time( Target )
			return Tgt - os.time()
		end

	end

end

