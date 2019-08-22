
module("enchantbase", package.seeall )

local function GetAllSharedId()
	
	local i = 0
	local SharedTable = enchant.AllSharedItems
	
	for i=16000,32100,1 do
		if !SharedTable[i] || !SharedTable[i]:IsValid() then
			return i
		end
	end
	
	return nil
	
end

local function GetNewId( tbl )
	
	local i = 0
	
	for i=-32000,15999,1 do
		if !tbl[i] || !tbl[i]:IsValid() then
			return i
		end
	end
	
	return nil
	
end

function GetRP( self )

	if !self._PlayersToSend then
		return self.Player
	end
	
	local rp = RecipientFilter()
	
	for _, v in pairs( self._PlayersToSend ) do
		if v:IsValid() then
			rp:AddPlayer( v )
		end
	end
	
	return rp
	
end

function EnableShared( self, toall )

	local Id
	
	if !self.Player._EnchantmentList then
		self.Player._EnchantmentList = {}
	end
	
	if toall == true then
		
		Id = GetAllSharedId()
		self._PlayersToSend = player.GetAll()
		
	else
		Id = GetNewId( self.Player._EnchantmentList )
	end
	
	if Id == nil then
		Error("Could not create new ID for '" .. self._Type .. "'"  )
	end
	
	self._Id = Id
	self.Player._EnchantmentList[ Id ] = self
	
	if toall == true then
		enchant.AllSharedItems[ Id ] = self
	end	
	
	self:_SendToPlayer()
	
end

function _SendToPlayer( self, rp )

	if DEBUG then
		Msg("Sending ".. self._Type .." to players.\n")
	end
	
	umsg.Start("enchant", rp or self:GetRP() ) 
		umsg.Char( 1 )
		umsg.String( self._Type )
		umsg.Short( self._Id )
		umsg.Entity( self.Player )
		
		if self._DieTime then
			umsg.Bool( true )
			umsg.Float( self._DieTime )
		else
			umsg.Bool( false )
		end
		
		SafeCall( self.ExtraInfo, self )
		
	umsg.End()
	
end

function _DestroyFromTables( self )
	
	if self._Id then
		if self.Player._EnchantmentList then
			self.Player._EnchantmentList[ self._Id ] = nil
		end
		
		enchant.AllSharedItems[ self._Id ] = nil
	
	end
	
end

function ExtraInfo( self )
	
end

function StartNW( self, um )

	if self._Id == -1 then
		Error("Can not send non-shared enchentment message (".. self._Type ..")")
	end
	
	umsg.Start("enchant", um or self:GetRP() ) 
		umsg.Char( 0 )
		umsg.Short( self._Id )
end

function EndNW( self )
	umsg.End()
end	

//If the player dies, this item is going to evoke remove
function StayAlive( self, ply )
	
	enchant._NewDeathHook( self, ply )
	
end

function DisableStayAlive( self, ply )

	enchant._RemoveDeathHook( self, ply )
	
end