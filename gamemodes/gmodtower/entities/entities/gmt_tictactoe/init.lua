
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create( "gmt_tictactoe" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:UpdateModel()
	self.Entity:SetModel( self.Model )
end

function ENT:Initialize()
	self:UpdateModel()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end

	self.Ply1 = nil
	self.Ply2 = nil

	self.PlyTurn = 1

	self.BlockPly = {}
	self.LastPress = {}

	self:ReloadOBBBounds()
	self:SharedInit()
end

function ENT:Think()
	local missing = false

	if !IsValid( self.Ply1 ) || !self:CheckDistance( self.Ply1 ) then
		self:SetPly1( nil )
		missing = true
	end

	if !IsValid( self.Ply2 ) || !self:CheckDistance( self.Ply2 ) then
		self:SetPly2( nil )
		missing = true
	end

	if missing && self:OnGame() then
		self:ResetData()
	end

	self:NextThink( CurTime() + 0.5 )

	return true
end

function ENT:CheckDistance( ply )
	return ply:GetPos():Distance( self:GetPos() ) < self.TblSize * 3.75
end


function ENT:SetPly1( ply )
	self.Ply1 = ply or NULL
end

function ENT:SetPly2( ply )
	self.Ply2 = ply or NULL
end

function ENT:Use( ply )
	if !IsValid(ply) || !ply:IsPlayer() then return end

	if !self:CheckDistance( ply ) then
		return
	end

	local PlyIndex = ply:EntIndex()
	if CurTime() < (self.LastPress[ PlyIndex ] or 0) then
		return
	end

	self.LastPress[ PlyIndex ] = CurTime() + 0.5

	if !self:OnGame() then

		if self.Ply1 == ply then
			self:SetPly1( nil )
			return
		elseif self.Ply2 == ply then
			self:SetPly2( nil )
			return
		end


		if !IsValid( self.Ply1 ) then
			self:SetPly1( ply )
		elseif !IsValid( self.Ply2 ) then
			self:SetPly2( ply )
		end

		if IsValid( self.Ply1 ) && IsValid( self.Ply2 ) && self:CheckDistance( self.Ply1 ) && self:CheckDistance( self.Ply2 ) then
			self:BeginGame()
		end

	else

		local PlyNum = 0

		if ply == self.Ply1 then
		  PlyNum = 1
		elseif ply == self.Ply2 then
		  PlyNum = 2
		else
		  return
		end

		if self.PlyTurn != PlyNum then
		  return
		end

		local x,y = self:GetEyeBlock( ply )

		if x < 0 or y < 0 or x > self:GetNumBlocks() - 1 or y > self:GetNumBlocks() - 1 then
			return
		end

		local NumBlock = self:XYToNum( x, y )



		local x,y = self:GetEyeBlock( ply )

		local NumBlock = self:XYToNum( x, y )

		if self.BlockPly[NumBlock] != nil && self.BlockPly[NumBlock] != 0 then
			return
		end

		self.BlockPly[NumBlock] = PlyNum

		//If it is 2 it is going to 1
		//If it is 1 it is going to 2
		self.PlyTurn = self.PlyTurn % 2 + 1

		self:CheckBoard()

		//Maybe the game ended
		if self.initGame == true then
			self:SendToClients()
		end

	end

end

function ENT:CheckBoard()

	//Check colums
	for x=0, self:GetNumBlocks() - 1 do

		local LastBlock = nil
		local Passing = true

		for y=0, self:GetNumBlocks() - 1 do

			local CurBlock = self.BlockPly[ self:XYToNum( x, y ) ]

			if y != 0 then
				if CurBlock != LastBlock then
					Passing = false
					break
				end
			end

			LastBlock = CurBlock

			if LastBlock == nil then
				Passing = false
				break
			end

		end

		if Passing == true then
			//WINNER!
			self:WinPlayer( LastBlock, x, 0, x, self:GetNumBlocks() - 1 )
			return
		end

	end

	//Check colums
	for y=0, self:GetNumBlocks() - 1 do

		local LastBlock = nil
		local Passing = true

		for x=0, self:GetNumBlocks() - 1 do

			local CurBlock = self.BlockPly[ self:XYToNum( x, y ) ]

			if x != 0 then
				if CurBlock != LastBlock then
					Passing = false
					break
				end
			end

			LastBlock = CurBlock

			if LastBlock == nil then
				Passing = false
				break
			end

		end

		if Passing == true then
			//WINNER!
			self:WinPlayer( LastBlock, 0, y, self:GetNumBlocks() - 1, y )
			return
		end

	end

	local LastBlock = nil
	local Passing = true

	//check diagonals
	for x=0, self:GetNumBlocks() - 1 do

		local CurBlock = self.BlockPly[ self:XYToNum( x, x ) ]

		if CurBlock == nil then
			Passing = false
			break
		end

		if x != 0 && CurBlock != LastBlock then
			Passing = false
			break
		end

		LastBlock = CurBlock
	end

	if Passing == true then
		//WINNER!
		self:WinPlayer( LastBlock, 0, 0, self:GetNumBlocks() - 1, self:GetNumBlocks() - 1 )
		return
	end

	local LastBlock = nil
	local Passing = true





	//check other diagonals
	for x=0, self:GetNumBlocks() - 1 do

		local CurBlock = self.BlockPly[ self:XYToNum( x, self:GetNumBlocks() - x - 1) ]

		if CurBlock == nil then
			Passing = false
			break
		end

		if x != 0 && CurBlock != LastBlock then
			Passing = false
			break
		end

		LastBlock = CurBlock
	end

	if Passing == true then
		//WINNER!
		self:WinPlayer( LastBlock, 0, self:GetNumBlocks() - 1, self:GetNumBlocks() - 1, 0 )
		return
	end


	if table.Count( self.BlockPly ) == (self:GetNumBlocks() * self:GetNumBlocks()) then // 3x3 = 9 or the number of blocks
		self:ResetData()
	end


end

function ENT:ResetData()
	//self:SetNetworkedBool("initGame", false)
	self.initGame = false
	self:SetPly1( nil )
	self:SetPly2( nil )
	self.BlockPly = {}
end

function ENT:WinPlayer( LastBlock, x1, y1, x2, y2 )
	self.Ply1:AddAchivement( ACHIVEMENTS.TICTACTOEPERSITANT, 1 )
	self.Ply2:AddAchivement( ACHIVEMENTS.TICTACTOEPERSITANT, 1 )

	local ply = self.Ply1

	if LastBlock == 2 then
		ply = self.Ply2
	end

	ply:AddAchivement( ACHIVEMENTS.TICTACTOEWIN, 1 )

	local sfx = EffectData()
		sfx:SetOrigin( ply:GetPos() )
	util.Effect( "confetti", sfx, true, true )

	ply:EmitSoundInLocation( self.WinSound, 80 )

	self:ResetData()
end


function ENT:BeginGame()
	self.initGame = true
	self.PlyTurn = 1
	self.BlockPly = {}

	self:SendToClients()
end

function ENT:SendToClients()

	umsg.Start( "TicTacToe", nil )

		umsg.Entity( self )
		umsg.Char( 0 )

		for i=1, (self:GetNumBlocks() * self:GetNumBlocks()) do

			if !self.BlockPly[i] then
				umsg.Bool( false )
			else
				umsg.Bool( true )
				umsg.Bool( self.BlockPly[i] == 1 )
			end

		end

	umsg.End()

end

function ENT:OnRemove()

end
