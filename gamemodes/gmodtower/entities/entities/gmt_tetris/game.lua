
ENT.TETRISBLOCKS = {
	{{0,0},{1,0},{0,1},{1,1}}, //square
	{{0,0},{0,1},{0,2},{0,3}}, //long piece
	{{0,0},{0,1},{0,2},{1,2}}, //right L
	{{1,0},{1,1},{1,2},{0,2}}, //left L
	{{0,0},{0,1},{1,1},{1,2}},
	{{1,0},{1,1},{0,1},{0,2}},
	{{0,1},{1,0},{1,1},{1,2}}, //montain
}

function ENT:EraseFullRows()

	local MaxSide = self.WidthSize
	local MaxDown = MaxSide * 2
	local RowsPushDown = {}
	local i, a

	MaxSide = MaxSide - 1

	local function CanDelete( i )

		for a=0, MaxSide do
			if self.Blocks[ self:XYToNum( a, i ) ] == nil then
				return false
			end
		end

		return true

	end

	for i=MaxDown, 0, -1 do

		if CanDelete( i ) == true then
			table.insert( RowsPushDown, i + #RowsPushDown )
		end

	end

	local RowCount = #RowsPushDown

	if RowCount == 0 then
		return
	end

	if RowCount == 4 && GtowerAchivements then
		self.Ply:SetAchivement( ACHIVEMENTS.TETRIS4ONETIME, 1 )
	end

	self:AddPoints( RowCount * 10 + (RowCount-1) * 5 )

	table.sort(RowsPushDown, function(a, b) return a > b end)

	local NumberToGoDown = self.WidthSize

	for _, v in pairs( RowsPushDown ) do


		local Start = v * self.WidthSize
		local End = Start + self.WidthSize - 1

		for i=Start, End do
			self.Blocks[ i ] = nil
		end

		for i=Start-1, 0, -1 do
			self.Blocks[ i + NumberToGoDown ] = self.Blocks[ i ]
			self.Blocks[ i ] = nil
		end

	end

	self:StartSound("gmodtower/arcade/Tetris_Clear.wav")

end


function ENT:CreateNewBlock()
	self:EraseFullRows()

	math.randomseed( SysTime() )

	self.CurBlock = math.random( 1, #self.TETRISBLOCKS )
	self.CurBlockX = math.floor( self.WidthSize / 2 )
	self.CurBlockY = 0

	self.BlockArea = self.TETRISBLOCKS[ self.CurBlock ]

	if self:CheckBlocks( self.CurBlockX, self.CurBlockY , self.BlockArea ) == false then
		self:EndGame()
	end

	self:ResetSendTable()
end


function ENT:GetRotatedTable()

	local Copied = table.Copy( self.BlockArea )
	local LeastX, LeastY = 0,0

	for _, v in pairs( Copied ) do
		v[1], v[2] = -v[2], v[1]

		if v[1] < LeastX then
			LeastX = v[1]
		end

		if v[2] < LeastY then
			LeastY = v[2]
		end
	end

	for _, v in pairs( Copied ) do
		v[1] = v[1] - LeastX
		v[2] = v[2] - LeastY
	end

	return Copied

end

function ENT:RotateBlocks()
	self:RemoveCurBlock()

	local OldRotation = self.BlockArea
	self.BlockArea = self:GetRotatedTable()

	if self:CheckNextPos( 0, 0, true ) == false then
		 self.BlockArea = OldRotation
	else
		self.ChangeMade = true
		self:StartSound("gmodtower/arcade/tetris_rotate.wav")
	end

	self:DrawCurBlock()

	if self.ChangeMade then
		self:SendToPlayer()
	end

end

function ENT:CheckBlocks( x,y,tbl )

	for _, v in pairs( tbl ) do
		local global = self:XYToNum( v[1] + x, v[2] + y  )

		if self.Blocks[ global ] != nil then
			return false
		end

	end

	return true

end

function ENT:CheckNextPos( xchange, ychange, checkitself )
	local GlobalPos = {}
	local MaxSide = self.WidthSize
	local MaxDown = MaxSide * 2



	for _, v in pairs( self.BlockArea ) do
		local NewPosY = self.CurBlockY + v[2] + ychange
		local NewPosX = self.CurBlockX + v[1] + xchange

		if NewPosY > MaxDown then
			return false
		end

		if NewPosX < 0 || NewPosX >= MaxSide then
			return false
		end

		table.insert( GlobalPos, self:XYToNum( NewPosX, NewPosY ) )
	end


	for k, color in pairs( self.Blocks ) do
		for _, pos in pairs( GlobalPos ) do

			if k == pos then

				if checkitself != true && !self:IsItSelf( pos ) then
					return false
				end

			end
		end
	end

	return true

end

function ENT:IsItSelf( pos )

	for _, v in pairs( self.BlockArea ) do
		if pos == self:XYToNum( self.CurBlockX + v[1], self.CurBlockY + v[2] ) then
			return true
		end
	end

	return false
end

function ENT:RemoveCurBlock()
	for _, v in pairs( self.BlockArea ) do
		local NewPosY = self.CurBlockY + v[2]
		local NewPosX = self.CurBlockX + v[1]

		self.Blocks[ self:XYToNum( NewPosX, NewPosY ) ] = nil
	end
end

function ENT:DrawCurBlock()
	for _, v in pairs( self.BlockArea ) do
		local NewPosY = self.CurBlockY + v[2]
		local NewPosX = self.CurBlockX + v[1]

		self.Blocks[ self:XYToNum( NewPosX, NewPosY ) ] = self.CurBlock
	end
end


function ENT:ProcessMove(x,y)

	if self:CheckNextPos(x,y) == false then
		if y > 0 then
			self:CreateNewBlock()
		end

		return
	end

	self:RemoveCurBlock()

	self.CurBlockY = self.CurBlockY + y
	self.CurBlockX = self.CurBlockX + x

	self:DrawCurBlock()

	self.ChangeMade = true
	self:SendToPlayer()

	if self.SendSound == 1 then
		self.SendSound = 8
	end

end

function ENT:GetMaxYChange()
	local ychange = 1
	local MaxDown = self.WidthSize * 2

	while ychange < MaxDown do
		local canmove = self:CheckNextPos(0, ychange)

		if canmove == false then
			break
		end

		ychange = ychange + 1
	end

	return ychange
end


function ENT:GetShadowTable()
	local ychange = self:GetMaxYChange()

	local ReturnTable = {}

	for _, v in pairs( self.BlockArea ) do
		local NewPosY = self.CurBlockY + ychange + v[2] - 1
		local NewPosX = self.CurBlockX + v[1]

		ReturnTable[ self:XYToNum( NewPosX, NewPosY ) ] = 8
	end


	return ReturnTable
end

function ENT:DropDown()

	local ychange = self:GetMaxYChange()

	self:AddPoints( math.floor( ychange / 5 ) )
	self:StartSound("gmodtower/arcade/tetris_hitbottom.wav")
	self:ProcessMove(0, ychange - 1)
end
