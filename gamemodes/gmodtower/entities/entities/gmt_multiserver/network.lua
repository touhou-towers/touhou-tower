
function ENT:BuildInformation()
	local Gamemode = GTowerServers:Get( self:Id() )
	if !Gamemode then return end

	local status = Gamemode.Status
	local map = Gamemode:GetMap()
	local gm = Gamemode:GetGamemodeName()
	local maxplayers = Gamemode.MaxPlayers
	local msg = Gamemode.Msg

	local rp = RecipientFilter()
	rp:AddPVS(self:GetPos())

	umsg.Start("GSInfo", rp)
		umsg.Entity(self.Entity)
		umsg.Char(status)
		umsg.Char(maxplayer)
		umsg.String(map)
		umsg.String(gm)
		if Gamemode:GetGamemode().ProcessData then
			umsg.String(msg)
		end
	umsg.End()
end

umsg.PoolString("GSPlayer")
umsg.PoolString("GSWait")

function ENT:BuildWaitingPlayers()
	local Gamemode = GTowerServers:Get( self:Id() )
	if !Gamemode then return end
end

function ENT:BuildPlayerInfo()
	local Gamemode = GTowerServers:Get( self:Id() )
	if !Gamemode then return end

	local rp = RecipientFilter()
	rp:AddPVS(self:GetPos())

	if Gamemode.PlayerCount == 0 then
		umsg.Start("GSPlayer", rp)
			umsg.Entity(self.Entity)
			umsg.Char(-128) umsg.Char(-128) umsg.Char(-128)
		umsg.End()
		return
	end

	local cpcount = Gamemode.PlayerCount
	if !self.PlayerIndex || self.PlayerIndex >= cpcount || self.LastCount != cpcount then
		self.PlayerIndex = 1
		self.LastCount = cpcount
	end

	local endi = self.PlayerIndex
	local bytecount = 0

	for i=self.PlayerIndex, cpcount do
		local len = string.len(Gamemode.PlayerCount) + 1
		if (bytecount + len) > 128 then
			break
		end

		endi = i
		bytecount = bytecount + len
	end

	umsg.Start("GSPlayer", rp)
		umsg.Entity(self.Entity)
		umsg.Char(self.PlayerIndex - 128)
		umsg.Char(endi - 128)
		umsg.Char(cpcount - 128)

		for i=self.PlayerIndex, endi do
			umsg.String(Gamemode.CurrentPlayers[i])
		end
	umsg.End()

	self.PlayerIndex = endi + 1
end
