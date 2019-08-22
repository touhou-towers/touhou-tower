
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
include('network.lua')
include('game.lua')
include('hook.lua')


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create( "gmt_tetris" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( Angle(0,180,0) )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:ClearTetris()
	self.Ply = nil
	self.LastPress = 0.0
	self.NextMove = 0.0
	self.Blocks = {}

	self.LastBlocks = {}
	self.LastPlayersSend = {}

	self.Points = 0
	self.GameStart = 0
	self.SendSound = 1

	self.ChangeMade = false
	self.BlockArea = self.TETRISBLOCKS[1]

	self:CreateNewBlock()
end

function ENT:Initialize()
	self.Entity:SetModel( self.Model )

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	self.Entity:SetUseType(SIMPLE_USE)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	self:ClearTetris()
end

function ENT:AddPoints( pts )
	self.Points = self.Points + pts
end


function ENT:Think()

	if IsValid( self.Ply ) then

		if !self:CheckDistance( self.Ply ) or !self.Ply:Alive() then
			self:EndGame()
			return
		end

		if self.NextMove < SysTime() then
			self.NextMove = SysTime() + 0.2

			self:ProcessMove(0,1)
			//self:SendToPlayer()
		end


		if self.ChangeMade then
			self:SendData()
			self.ChangeMade = false
		end

	elseif self:GetNetworkedBool("initGame") == true then
		self:EndGame()
	end

end

function ENT:CheckDistance( ply )
	return ply:GetPos():Distance( self:GetPos() ) < self.DoorHeight * 3
end


function ENT:SetPly( ply )

	ply.InTetris = true

	self.Ply = ply
	self.Blocks = {}
	self.Points = 0

	self:SetNetworkedBool("initGame", true )
	//self:SetNetworkedInt("Ply", self.Ply:EntIndex() )
	self:SetOwner( self.Ply )

	self.OldMoveType = self.Ply:GetMoveType()

	self.Ply:SetVelocity( Vector(0,0,0) )
	self.Ply:SetMoveType( MOVETYPE_NONE )
	self.Ply:GodEnable()
	self.Ply:SetPos( self:GetPos() + self:GetForward() * 128 )

	self.NextMove = SysTime() + 0.9
	self.GameStart = SysTime()

	self:AddPlayerHook()
end



function ENT:Use( ply )
	if !ply:IsPlayer() || IsValid( ply.BallRaceBall ) then return end

	if SysTime() < self.LastPress then
		return
	end

	self.LastPress = SysTime() + 0.5

	if IsValid( self.Ply ) then //Another player already playing?
		return
	end

	self:SetPly( ply )

	self:StartSound("gmodtower/arcade/tetris_gamestart.wav")


end

function ENT:StartSound(snd)
	self.Ply:SendLua([[surface.PlaySound("]]..snd..[[")]])
end

function ENT:EndGame()
	if IsValid(self.Ply) then
		if GtowerAchivements then

			self:EmitSound("gmodtower/arcade/tetris_Gameover.wav",70)
			self.Ply:AddAchivement( ACHIVEMENTS.TETRISMANYPOINTS, self.Points )
			self.Ply:AddAchivement( ACHIVEMENTS.TETRISMUCHTIME, (SysTime() - self.GameStart) / 60 )

			if self.Points > self.Ply:GetAchivement( ACHIVEMENTS.TETRIS1000AGAME ) then
				self.Ply:SetAchivement( ACHIVEMENTS.TETRIS1000AGAME, self.Points )
			end

		end

		self.Ply.InTetris = false

		self.Ply:SetMoveType( self.OldMoveType )
		self.Ply:ResetGod()

		self:RemovelayerHook()

		hook.Call("TetrisEnd", GAMEMODE, self.Ply, self )
	end

	self:SetNetworkedBool("initGame", false )
	self:SetOwner( Entity(0) )

	self:ClearTetris()
end

function ENT:OnRemove()

end

hook.Add("CanTool", "DisableTetris", function(pl, tr)
	if IsValid( tr.Entity ) && tr.Entity:GetClass() == "gmt_tetris" then
		return !IsValid( tr.Entity.Ply )
	end

	return true
end )
