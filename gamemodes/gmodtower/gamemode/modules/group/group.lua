
local GROUP = {}

util.AddNetworkString( "GGroup" )

function GROUP:Create()

	local o = {}

	setmetatable( o, self )
	self.__index = self

	o.Id = 0
	o.Members = {}
	o.Owner = nil
	o.NeedSendNetwork = false
	o.PlayerRequests = {}

	return o

end

function GROUP:GetPlayers()
	return self.Members
end

function GROUP:IsValid()
	return #self.Members > 0
end

function GROUP:GetRP()

	local rp = RecipientFilter()

	for _, ply in pairs( self.Members ) do
		rp:AddPlayer( ply )
	end

	return rp

end

function GROUP:SendNetwork()

	if !self:IsValid() then
		return
	end

	net.Start( "GGroup" )
		net.WriteInt( 0, 16 )
		net.WriteInt( #self.Members, 16 )
		net.WriteInt( self.Owner:EntIndex(), 16 )
		for _, ply in pairs( self.Members ) do

			if self.Owner != ply then
				net.WriteInt( ply:EntIndex(), 16 )
			end

		end
	net.Send( self:GetRP() )

	/*umsg.Start("GGroup", self:GetRP() )

		umsg.Char( 0 )
		umsg.Char( #self.Members )
		umsg.Char( self.Owner:EntIndex() )

		for _, ply in pairs( self.Members ) do

			if self.Owner != ply then
				umsg.Char( ply:EntIndex() )
			end

		end

	umsg.End()*/

	self.NeedSendNetwork = false

end

function GROUP:SendRequest( ply )

	if !IsValid( self.Owner ) then
		return
	end

	if self.PlayerRequests[ ply ] then
		//Do not allow to send that many requests to the player, just once every 15 seconds
		if CurTime() - self.PlayerRequests[ ply ] < 15 then
			Msg("Timer overflow on sending group request.\n")
			return
		end
	end

	self.PlayerRequests[ ply ] = CurTime()

	Msg("Sending group request to: " .. tostring(ply) .. "\n")

	net.Start("GGroup")
		net.WriteInt( 1, 16 )
		net.WriteInt( self.Id, 16 )
		net.WriteInt( self.Owner:EntIndex(), 16 )
	net.Send(ply)

	/*umsg.Start("GGroup", ply)
		umsg.Char( 1 )
		umsg.Char( self.Id )
		umsg.Char( self.Owner:EntIndex() )
	umsg.End()*/

end

function GROUP:AcceptRequest( ply )

	local RequestTime = self.PlayerRequests[ ply ]

	if !RequestTime then return end

	if CurTime() - self.PlayerRequests[ ply ] < 30 then
		self:AddPlayer( ply )
		self:Update()
	end

end

function GROUP:DenyRequest( ply )
	local RequestTime = self.PlayerRequests[ ply ]

	if !RequestTime then return end

	self.PlayerRequests[ ply ] = nil

	// don't leave a 1 person group if the person didn't accept
	if table.Count(self.PlayerRequests) == 0 then
		self:Remove()
	end

	net.Start( "GGroup" )
		net.WriteInt( 9, 16 )
		net.WriteInt( ply:EntIndex(), 16 )
	net.Send( self.Owner )

	/*umsg.Start("GGroup", self.Owner )
		umsg.Char( 9 )
		umsg.Char( ply:EntIndex() )
	umsg.End()*/
end

function GROUP:AddPlayer( ply )

	if #self.Members >= GTowerGroup.MaxPlayers then
		return false
	end

	if table.HasValue( self.Members, ply ) then
		return false
	end

	local OldGroup = ply:GetGroup()
	if OldGroup then
		OldGroup:RemovePlayer( ply )
	end

	ply._SendNoGroup = nil
	ply._GTowerPlyGroup = self

	table.insert( self.Members, ply )
	hook.Call("GroupJoined", GAMEMODE, ply, Group )

	return true

end

function GROUP:HasPlayer( ply )
	return table.HasValue( self.Members, ply )
end

function GROUP:RemovePlayer( ply )

	if !self:HasPlayer( ply ) then return end

	for k, v in pairs( self.Members ) do
		if v == ply then
			table.remove( self.Members, k )
		end
	end

	if ply == self.Owner then
		self:FindNewOwner()
	end

	//This variable will be read on network.lua to send to the client that he is no longer in a group
	ply._SendNoGroup = true
	ply._GTowerPlyGroup = nil
	self:Update()

	hook.Call("GroupLeft", GAMEMODE, Group, ply )

	if #self.Members == 1 then
		self:Remove()
	end
end

function GROUP:FindNewOwner()

	table.ClearKeys( self.Members )

	if #self.Members <= 1 then
		self:Remove()
	else
		self:SetOwner( self.Members[1] )
	end

end

function GROUP:SetOwner( ply )
	if !self:HasPlayer( ply ) then
		if self:AddPlayer( ply ) == false then
			return false
		end
	end

	local OldOwner = self.Owner
	self.Owner = ply

	hook.Call("GTowerGroupOwner", GAMEMODE, ply, self, OldOwner )

	self:Update()
end

function GROUP:Update()
	if self:IsValid() then
		hook.Call("GTowerGroupUpdate", GAMEMODE, self)
	end

	self.NeedSendNetwork = true
end

function GROUP:Remove()

	for _, ply in pairs( self.Members ) do
		if ply != self.Owner then
			self:RemovePlayer( ply )
		end
	end

	self:RemovePlayer( self.Owner )

	GTowerGroup.Groups[ self.Id ] = nil
end



function GROUP:__tostring()
	local Return = "Group: " .. self.Id .. " (Owner: " .. tostring( self.Owner ) .. ")\n"

	for k, v in pairs( self.Members ) do
		Return = Return .. "\t" .. k .. ". " .. tostring(v) .. "\n"
	end

	return Return
end








function GTowerGroup:NewGroup( owner )
	local Group = GROUP:Create()
	local i = 1

	while GTowerGroup.Groups[ i ] != nil do
		i = i + 1
	end

	GTowerGroup.Groups[ i ] = Group
	Group.Id = i

	Group:SetOwner( owner )

	return Group
end
