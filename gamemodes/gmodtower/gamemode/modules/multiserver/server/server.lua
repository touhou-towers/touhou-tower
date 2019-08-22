ServerMeta = {}

local LocalServerMeta = ServerMeta

include("gamemode.lua")
include("player.lua")
include("batch.lua")
include("mapvote.lua")
include("sql.lua")
include("ready.lua")

function GTowerServers:CreateServer( Id )

	LocalServerMeta:CreateServer( Id )

end

function ServerMeta:CreateServer( Id )

	local o = setmetatable( {}, self )
	self.__index = self

	o.Id = Id
	o.GamemodeValue = ""
	o.PlayerList = {} -- List of player waiting to join the server

	-- some custom fields to allow the game to start depending on
	-- if someone has been queued up for a while and if there are not
	-- enough players queued
	o.QueuedAt = CurTime()

	o.Ip = ""
	o.Port = ""
	o.Password = ""
	o.Msg = ""

	o.MaxPlayers = 0
	o.ServerMaxPlayers = 0
	o.PlayerCount = 0
	o.Status = 0
	o.LastUpdate = 0
	o.CurrentPlayers = {}
	o.PlayerBuffer = {}

	o.SendPlayersFinal = nil

	GTowerServers.Servers[ Id ] = o

end

function ServerMeta:Online()
	return self:CheckOnline( self.LastUpdate )
end

ServerMeta.OnLine = ServerMeta.Online

function ServerMeta:CheckOnline( time )
	return time > (os.time() - GTowerServers.UpdateTolerance)
end


function ServerMeta:NetworkNeedSend()
	self.NeedNetworkSend = true
end

function ServerMeta:NetworkSend( rp )
	if rip != nil && !IsValid(rp) then return end

	local Online = self:Online()

	umsg.Start("GServ", rp)
		umsg.Char( 1 )

		umsg.Char( self.Id )
		umsg.Bool( Online )

		if Online then
			umsg.Bool( self.Status == 1 )

			local players = self:GetListedPlayers()
			local plybits = {}
			local maxbit = 0

			for k,v in pairs(players) do
				local bit = v:EntIndex()
				maxbit = math.max(maxbit, bit)
				plybits[bit] = true
			end

			// if maxbit is player 80 (1 bit each), this would only be 10 bytes, easy to network!
			umsg.Char(maxbit)
			for i=1,maxbit do
				umsg.Bool(plybits[i] or false)
			end
		end

	umsg.End()

end

function ServerMeta:NetworkThink()

	if self.NeedNetworkSend != true then
		return
	end

	self:NetworkSend( nil )

	self.NeedNetworkSend = false

end

ServerMeta = nil
