
function ENT:UpdateData(um)
	self.WaitingList = {}

	local Server = self:GetServer()
	
	if !Server then
		return
	end
	
	self.ServerOnline = Server.Online
	self.WaitingList = table.Copy( Server.Players )

	self:ReloadPositions()
end

function ENT:ParseInformation(um)
	self.ServerStatus = um:ReadChar()
	self.ServerMaxPlayers = um:ReadChar()
	local map = um:ReadString()
	self.ServerGamemode = um:ReadString()

	self.ServerMap = map

	local Gamemode = GTowerServers:GetGamemode( self.ServerGamemode )
	if Gamemode then
		self.ServerName = Gamemode.Name
		self.ServerMinPlayers = Gamemode.MinPlayers

		if Gamemode.ProcessData then
			Gamemode:ProcessData( self, um:ReadString() )
		end
		
		if Gamemode.DrawData then
			self.DrawGamemodeData = Gamemode.DrawData
		end
		
		if Gamemode.GetMapName then
			local NewMapname = Gamemode:GetMapName( map )
			if NewMapname then
				self.ServerMap = NewMapname
			end		
		end
		
		if Gamemode.GetMapTexture then
			local strImage = Gamemode:GetMapTexture( map )
			
			if strImage then
				local Mat = Material( strImage )
				self.MapTexture = Mat
			end
			
		end
	else
		self.ServerName = "TODO: NAME"
	end

	self:ReloadPositions()
end

function ENT:ParseUsers(um)
	local start = um:ReadChar() + 128
	local endi = um:ReadChar() + 128
	local numplayers = um:ReadChar() + 128

	if numplayers == 0 then
		self.ServerPlayers = {}
		self:ReloadPositions()
		return
	end

	if !self.ServerPlayers || #self.ServerPlayers > numplayers then
		self.ServerPlayers = {}
	end

	for i=start, endi do
		self.ServerPlayers[i] = um:ReadString()
	end

	self:ReloadPositions()
end

usermessage.Hook("GSInfo", function(um)
	local ent = um:ReadEntity()
	if !IsValid(ent) || !ent.ParseInformation then return end

	ent:ParseInformation(um)
end)

usermessage.Hook("GSPlayer", function(um)
	local ent = um:ReadEntity()
	if !IsValid(ent) || !ent.ParseUsers then return end

	ent:ParseUsers(um)
end)

function ENT:HTTPCallback( content )
	
	local Strings = string.Explode( "\n" ,content )

	local Map = string.lower( string.Trim( Strings[1] ) )
	local Status = Strings[2]
	self.ServerGamemode = Strings[3]
	local MaxPlayer = tonumber( Strings[4] )
	local Players = {}
	
	for i=5, #Strings - 1 do 
		table.insert( Players, Strings[i] )
	end
	
	local Gamemode = GTowerServers:GetGamemode( self.ServerGamemode )
	
	self.ServerPlayers = Players
	self.ServerMap = Map
	self.ServerName = "TODO: NAME"
	self.ServerStatus = Status
	self.MapTexture = nil
	
	if Gamemode then
		self.ServerName = Gamemode.Name
		self.ServerMaxPlayers = Gamemode.MaxPlayers
		
		
		if Gamemode.ProcessData then
			Gamemode:ProcessData( self, Status )
		end
		
		if Gamemode.DrawData then
			self.DrawGamemodeData = Gamemode.DrawData
		end
		
		if Gamemode.GetMapName then
			local NewMapname = Gamemode:GetMapName( Map )
			if NewMapname then
				self.ServerMap = NewMapname
			end		
		end
		
		if Gamemode.GetMapTexture then
			local strImage = Gamemode:GetMapTexture( Map )
			
			if strImage then
				local Mat = Material( strImage )
				
				self.MapTexture = Mat
			end
			
		end
		
	else
		self.ServerMaxPlayers = MaxPlayer
	end
	
	self:ReloadPositions()
	
end
