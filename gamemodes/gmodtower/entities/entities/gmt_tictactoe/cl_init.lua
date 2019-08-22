
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.Ply1 = nil
	self.Ply2 = nil

	self.CurTurn = false

	self.ImageZoom = 0.4

	self.ActivePlayer = nil

	self:ReloadOBBBounds()
	self:SharedInit()

	if self.OtherInit != nil then
		self:OtherInit()
	end

	self.Blocks = {}
end

function ENT:UpdateTurn( name, old, new )
	if new == 1 then
		self.ActivePlayer = self.Ply1
	elseif new == 2 then
		self.ActivePlayer = self.Ply2
	else
		self.ActivePlayer = LocalPlayer()
	end
end

function ENT:ChangeGameState( name, old, new )
	if new == true then
		self.ImageZoom = 0.25
		self.SecondDraw = self.DrawBoard
		self.ActivePlayer = self.Ply1
	else
		self.ImageZoom = 0.4
		self.SecondDraw = self.DrawWaiting
	end
end

function ENT:DrawSidePlayer( ply )
	local col = Color( 255, 0, 0, 50 )
	local PlyName = "No Player"

	if IsValid( ply ) && ply:IsPlayer() then
		col = Color( 0, 255, 0, 50 )
		PlyName = ply:Nick()
	end

	local x,y = -self.NegativeSize / self.ImageZoom, 2
	local w,h = self.TblSize / self.ImageZoom, self.NegativeSize / self.ImageZoom - 4

	draw.RoundedBox(0, x,y,w,h,	col)


	draw.SimpleText(PlyName, "ScoreboardText", x + w / 2, y + h / 2, Color(255,255,255,255),1,1)
end



function ENT:DrawRotatingBoard( pos, ang )

	local LocalPos = LocalPlayer():EyePos()

	ang:RotateAroundAxis( ang:Up(), RealTime() * 25 % 360 )

	if (LocalPos - pos ):DotProduct( ang:Right() ) < 0 then
		ang:RotateAroundAxis( ang:Up(), 180 )
	end

	ang:RotateAroundAxis( ang:Forward(), 90 )

	local Scale = .35 //math.Clamp( LocalPos:Distance( pos ) / 450, 0.25, 1.0 )

	cam.Start3D2D( pos, ang, Scale )

		draw.RoundedBox(2, -40, -16, 80, 32, Color( 25,25,25,250) )
		draw.SimpleText("TIC TAC TOE", "GTowerHUDMain", 0,0, Color(255,255,255,255),1,1)

	cam.End3D2D()

end

function ENT:GetActivePlayer()
	if IsValid( self.ActivePlayer ) then
		return self.ActivePlayer
	end
	return LocalPlayer()
end

function ENT:DrawBoard()

	local EntPos = self:GetPos()
	local EyeForward = self:EyeAngles():Up()

	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Up(), 90 )

	local pos = EntPos + EyeForward * self.UpPos
	local TargetPly = self:GetActivePlayer()

	local x,y = self:GetEyeBlock( TargetPly )

	local SizeBlock = (self.TblSize / self.ImageZoom) / self:GetNumBlocks()
	local MinPos = self.NegativeSize / self.ImageZoom

	cam.Start3D2D( pos, ang, self.ImageZoom )

		for j=0, self:GetNumBlocks()-1 do
			for i=0, self:GetNumBlocks()-1 do

				local BoxId = self:XYToNum( j, i )
				local BoxOwner = self.Blocks[ BoxId ]
				local Boxcol = Color( 255, 255, 255, 50)

				if BoxOwner == 1 then
					Boxcol = Color( 255, 0, 0, 50 )
				elseif BoxOwner == 2 then
					Boxcol = Color( 0, 0, 255, 50 )
				elseif (!BoxOwner or BoxOwner == 0) && j == x && i == y then
					if TargetPly != LocalPlayer() then
						Boxcol = Color( 255, 255, 0, 50 )
					else
						Boxcol = Color( 0, 255, 0, 50 )
					end
				end

				draw.RoundedBox( 0,
					j * SizeBlock - MinPos,
					i * SizeBlock - MinPos,
					SizeBlock - 1,
					SizeBlock - 1,
					Boxcol
				)

			end
		end

	cam.End3D2D()

	self:DrawRotatingBoard( EntPos + EyeForward * 64, ang )

end


function ENT:DrawWaiting()

	local EntPos = self.Entity:GetPos()
	local EyeForward = self.Entity:EyeAngles():Up()

	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 		90 )

	local pos = EntPos + EyeForward * self.UpPos



	cam.Start3D2D( pos, ang, self.ImageZoom )
		self:DrawSidePlayer( self.Ply1 )
	cam.End3D2D()

	ang:RotateAroundAxis(ang:Up(), 		180 )


	cam.Start3D2D( pos, ang, self.ImageZoom )
		self:DrawSidePlayer( self.Ply2 )
	cam.End3D2D()

	self:DrawRotatingBoard( EntPos + EyeForward * 64, ang )
end


ENT.SecondDraw = ENT.DrawWaiting

function ENT:Draw()
	self.Entity:DrawModel()
end


function ENT:DrawTranslucent()
	self:SecondDraw()
end

function ENT:TicTacToeUm( um )
	local MsgId = um:ReadChar()

	if MsgId == 0 then
		self.Blocks = {}

		for i=1, (self:GetNumBlocks() * self:GetNumBlocks()) do

			if um:ReadBool() then
				self.Blocks[ i ] = um:ReadBool() == true && 1 || 2
			else
				self.Blocks[ i ] = 0
			end

		end
	end

end

usermessage.Hook("TicTacToe", function( um )

	local ent = um:ReadEntity()

	if IsValid( ent ) && ent.TicTacToeUm then

		ent:TicTacToeUm( um )

	end

end )
