
local EntityPlayers = {}

local function TetrisKeyDown(ply, key)
	if !IsValid(ply) then return end

	local PlyIndex = ply:EntIndex()
	local Ent = EntityPlayers[ PlyIndex ]

	if IsValid( Ent ) then

		if key == IN_MOVELEFT then
			Ent:ProcessMove(-1,0)
		elseif key == IN_MOVERIGHT then
			Ent:ProcessMove(1,0)
		elseif key == IN_BACK then
			Ent:DropDown()
		elseif key == IN_FORWARD then
			Ent:RotateBlocks()
		elseif key == IN_USE && SysTime() > Ent.GameStart then
			Ent:EndGame()
		end

	end

end

local function TetrisRelease(ply)
	local PlyIndex = ply:EntIndex()
	local Ent = EntityPlayers[ PlyIndex ]

	if IsValid( Ent ) then
		Ent:EndGame()
	end
end

hook.Add( "KeyPress", "TetrisKeyPress", TetrisKeyDown )
hook.Add( "PlayerDisconnected", "TetrisRelease", TetrisRelease )

function ENT:AddPlayerHook()
	EntityPlayers[ self.Ply:EntIndex() ] = self
end

function ENT:RemovelayerHook()
	EntityPlayers[ self.Ply:EntIndex() ] = nil
end
