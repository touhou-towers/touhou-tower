
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName		= "TicTacToe table"
ENT.Author			= "Nican"
ENT.Contact			= ""
ENT.Purpose			= "For GMod Tower"
ENT.Instructions	= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.WinSound = Sound("gmodtower/misc/win.wav")

ENT.Model		= "models/gmod_tower/gametable.mdl"

GtowerPrecacheModel( ENT.Model )

hook.Add("LoadAchivements","AchiTicTacToe", function ()
	GtowerAchivements:Add( ACHIVEMENTS.TICTACTOEWIN, {
		Name = "30 Wins",
		Description = "Win a total of 30 Tic-Tac-Toe games.",
		Value = 30,
		Group = 4
		}
	)

	GtowerAchivements:Add( ACHIVEMENTS.TICTACTOEPERSITANT, {
		Name = "Toe Fetish",
		Description = "Play 100 Tic-Tac-Toe games.",
		Value = 100,
		Group = 4
		}
	)

end )

ENT.TblSize = 60 //Actually 64, but do not include the borders
ENT.NegativeSize = ENT.TblSize / 2
ENT.UpPos = 20.25

function ENT:ReloadOBBBounds()
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()

	local TblSize = maxs.x - mins.x

	if TblSize > maxs.y - mins.y then
		TblSize = maxs.y - mins.y
	end

	self.TblSize = math.floor( TblSize * 0.94 )
	self.UpPos = maxs.z
	self.NegativeSize = self.TblSize / 2
end

function ENT:SharedInit()
	RegisterNWTable(self, {
		{"Ply1", Entity(0), NWTYPE_ENTITY, REPL_EVERYONE },
		{"Ply2", Entity(0), NWTYPE_ENTITY, REPL_EVERYONE },
		{"PlyTurn", 0, NWTYPE_CHAR, REPL_EVERYONE, self.UpdateTurn },
		{"initGame", false, NWTYPE_BOOLEAN, REPL_EVERYONE, self.ChangeGameState }
	})
end


function ENT:Get2DPos( ply )

	local tr = util.QuickTrace( ply:GetShootPos(), ply:GetAimVector() * 128, ply )

	local LocalPos = self:WorldToLocal( tr.HitPos )

	return (LocalPos.x + self.NegativeSize) / self.TblSize, (LocalPos.y + self.NegativeSize) / self.TblSize

end


function ENT:GetEyeBlock( ply )

	//Y, X because it is rotated
	local y,x = self:Get2DPos( ply )
	local EachBlock = 1 / self:GetNumBlocks()

	return math.ceil( x / EachBlock ) - 1, math.ceil( y / EachBlock ) - 1

end


function ENT:NumToXY( num )
	local NumBlocks = self:GetNumBlocks()

	num = num - 1

	local y = num % NumBlocks
	local x = (num - y) / NumBlocks

	return x,y
end

function ENT:XYToNum( x, y )
	local NumBlocks = self:GetNumBlocks()

	return x * NumBlocks + y + 1
end

function ENT:GetNumBlocks()
	return 3
end


function ENT:OnGame()
	return self.initGame == true
end
