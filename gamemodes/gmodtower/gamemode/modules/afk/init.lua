
--------------------------------
-- Antiafk
--------------------------------

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("jumping.lua")

AntiAFK.Time = 360
AntiAFK.WarningTime = AntiAFK.Time / 8

local PlayerMeta = FindMetaTable("Player")

//No need to go kicking players when the server is not full!
//It's publicity!
timer.Create("CheckAfkKickerPlayerThink", 10.0, 0, function()

	local MaxSlots = GetMaxSlots()
	--local Count = #player.GetAll()) --gatekeeper.GetNumClients()
	local Count = gatekeeper.GetNumClients()
	
	local notFull  = hook.Call( "AFKNotFull", GAMEMODE ) or false
	
	if ( MaxSlots - Count.total <= 5 ) || notFull then
		if !hook.GetTable().PlayerThink.CheckPlayerAfkTime then
			hook.Add("PlayerThink", "CheckPlayerAfkTime", AntiAFK.PlayerThink )
			
			//Reset alll timers, since people might be automatically kicked
			for _, ply in ipairs( player.GetAll() ) do
				ply:AFKTimer()
			end
		end
		
	else
		hook.Remove("PlayerThink", "CheckPlayerAfkTime" )
	end

end )

AntiAFK.PlayerThink =  function( ply )

	if !ply._AfkKickTime || ply:IsAdmin() then
		return 
	end

	local TimeDifference = ply._AfkKickTime - CurTime()
	
	if TimeDifference < 0 then
		
		ply:Kick("AFK")
		
	elseif TimeDifference < AntiAFK.WarningTime then	
	
		if ply._SentAfkWarning != true then
			
			umsg.Start("GTAfk", ply )
				umsg.Char( 0 )
				umsg.Long( ply._AfkKickTime )
			umsg.End()
			
			ply._SentAfkWarning = true
		end
	
	end

end

local function GetAFKTime( ply )
	
	// gamemodes don't have the location module
	if ( !Location ) then return AntiAFK.Time end
	
	--if Location.IsTheater( ply:Location() ) then
	if GTowerLocation:IsTheater( GTowerLocation:GetName( GTowerLocation:GetPlyLocation( ply ) ) ) then
		return AntiAFK.Time * 2
	end
	
	return AntiAFK.Time
	
end

function PlayerMeta:SetAFKExcluded(isExcluded)
	self.ExcludeAFK = isExcluded
end

function PlayerMeta:IsAFKExcluded()
	return self.ExcludeAFK
end

function PlayerMeta:AFKTimer()
	
	if self:IsAFKExcluded() then return end
	
	self._AfkKickTime = CurTime() + GetAFKTime( self )
	
	if self._SentAfkWarning then
		umsg.Start("GTAfk", self )
			umsg.Char( 1 )
		umsg.End()
		
		self._SentAfkWarning = false
	end
end

hook.Add("PlayerSay", "AntiAFKResetChat", function( ply )
	ply:AFKTimer()
end )