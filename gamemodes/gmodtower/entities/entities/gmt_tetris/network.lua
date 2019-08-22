
function ENT:SendData()

	local SendFull = {}
	local SendUpdate = {}

	local NewTable = {}
	local plys = player.GetAll()
	local entpos = self:GetPos()
	local GoTable = table.Merge( self:GetShadowTable(), self.Blocks )


	for _, v in pairs( plys ) do

		if v != self.Ply && v:Visible( self ) && entpos:Distance( v:GetPos() ) < 512 then

			local plyindex = v:EntIndex()

			if self.LastPlayersSend[ plyindex ] == true then
				table.insert( SendUpdate, v )
			else
				table.insert( SendFull, v )
			end

			NewTable[ plyindex ] = true
		end

	end

	self.LastPlayersSend = NewTable



	if #SendFull > 0 then
		local rp = RecipientFilter() // Grab a RecipientFilter object

		for _, v in pairs( SendFull ) do
			rp:AddPlayer( v )
		end

		self:SendMsgFull( GoTable, rp )
	end

	if #SendUpdate > 0 then
		local rp = RecipientFilter() // Grab a RecipientFilter object

		for _, v in pairs( SendUpdate ) do
			rp:AddPlayer( v )
		end

		self:SendMsgUpdate( GoTable, rp )
	end

	self.LastBlocks = table.Copy( GoTable )
end

function ENT:SendToPlayer()

	local GoTable = table.Merge( self:GetShadowTable(), self.Blocks )

	self:SendMsgFull( GoTable, self.Ply )

end

function ENT:SendMsgUpdate( GoTable, rp )

	local ToRemove = {}
	local ToAdd = {}

	for k, v in pairs( GoTable ) do
		if self.LastBlocks[ k ] != v || self.LastBlocks[ k ] != nil then
			table.insert( ToAdd, k )
		end
	end

	for k, v in pairs( self.LastBlocks ) do
		if GoTable[ k ] == nil then
			table.insert( ToRemove, k )
		end
	end

	umsg.Start("Tetr", rp)

		umsg.Entity( self )
		umsg.Bool( true )
		umsg.Short( self.Points - 32000 )

		umsg.Char( table.Count( ToRemove ) )
		for _, v in pairs( ToRemove ) do
			umsg.Char( v - 127 )
		end

		umsg.Char( table.Count( ToAdd ) )
		for _, v in pairs( ToAdd ) do
			umsg.Char( v - 127 )
			self:UmsgSendBlock( GoTable[v] - 1 )
		end

		self:UmsgSendBlock( self.SendSound - 1 )
		self.SendSound = 1

	umsg.End()

end

/*
Sending informatiion of tetris to client
There are 3 methods with I could think of to send data to the client
1 =
	Send one char containing the size of the array
	Send a char first containg the item index, then send 3 bits containg the value
	The bandwidth use is calculated as 8 + (8+3) * x

2=
	Send 200 UmsgSendBlock,
	The bandwidth will always be a containt of 200 * 3
	NOTE: This method is invalid because umsgsendblock sends exacly 8 different numbers, and there are 8 different colors, there are no null values

3=
	From 1 to 200 send a bool,
	if the value contains something, the bool is true, and a message is send after
	bandwidth calculated at 200 + 3 * x

Method 1 uses least bandwidth untul 24 blocks
Method 3 uses least bandwidth until 133 blocks
*/

function ENT:SendMsgFull( GoTable, rp )

	umsg.Start("Tetr", rp)

	umsg.Entity( self )
	umsg.Bool( false )
	umsg.Short( self.Points - 32000 )

	local TableCount = table.Count( GoTable )

	if TableCount <= 24 then

		umsg.Bool( true )
		umsg.Char( table.Count( GoTable ) )

		for k, v in pairs( GoTable ) do
			umsg.Char( k - 127 )
			self:UmsgSendBlock( v - 1 )
		end

	else
		umsg.Bool( false )

		for i = 9, 209 do
			if GoTable[ i ] then
				umsg.Bool( true )
				self:UmsgSendBlock( GoTable[ i ] - 1 )
			else
				umsg.Bool( false )
			end
		end
	end

	self:UmsgSendBlock( self.SendSound - 1 )
	self.SendSound = 1

	umsg.End()

end




function ENT:UmsgSendBlock( id )

    umsg.Bool( bit.band(id,1) == 1 )
    umsg.Bool( bit.band(id,2) == 2 )
    umsg.Bool( bit.band(id,4) == 4 )

end

function ENT:ResetSendTable()
	self.LastPlayersSend = {}
end
