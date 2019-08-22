
include('shared.lua')

ENT.matBeam		 		= Material( "cable/blue_elec" )
ENT.TeslaColor = Color(255,0,0, 255 )
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:SetRenderBounds( Vector(-128, -128, -128), Vector(128, 128, 128) )
	self:DrawShadow(false)
	self.OffSet = CurTime() + math.Rand(0,10)
	self.TimeOffset = CurTime() + math.Rand(0,10)
end

local StartPos = Vector( 17, -3, 22 )
local EndPos   = Vector( 20, -7, 42 )
local TimeSpawn = 4
local MaxWidth = 12

local function MulVec( vec1, vec2 )
	return Vector(
		vec1.x * vec2,
		vec1.y * vec2,
		vec1.z * vec2
	)
end

function ENT:Draw()
end

function ENT:DrawTranslucent()

	self:Position()
	//self:DrawBeans( self:GetOwner() )

end

function ENT:PositionItem( ply )
	if ply.IsRabbit then
		self.IsRabbit = ply:IsRabbit()
	end

	if self.IsRabbit then
		self:DrawBeans( ply )
	end
end
/*
function ENT:GetRandomEarPos()

	local ply = self:GetOwner()

	if IsValid( ply ) then
		return
	end

	self:PrepareValues( ply )

	local Up = self.BoneAng:Up()
	local Forward = self.BoneAng:Forward()
	local Right = self.BoneAng:Right()

	local Vec = LerpVector( math.Rand( 0, 1 ) , self.StartPos, self.EndPos )

	if math.random( 0, 1 ) == 0 then
		return self.BonePos + Forward * Vec.z + Up * Vec.x + Right * Vec.y
	end

	return self.BonePos + Forward * Vec.z - Up * Vec.x + Right * Vec.y

end
*/

function ENT:PrepareValues( ply )

	self.BonePos, self.BoneAng = self:GetPosHead( ply )

	if !self.BonePos then
		return
	end

	local Scale = ply:GetModelScale()

	self.StartPos = MulVec( StartPos, Scale )
	self.EndPos = MulVec( EndPos, Scale )
	self.Width = Scale * MaxWidth

end

function ENT:DrawBeans( ply )

	if !string.StartWith(ply:GetModel(),"models/player/redrabbit") then return end

	self:PrepareValues( ply )

	render.SetMaterial( self.matBeam )

	if LocalPlayer() == ply && !LocalPlayer().ThirdPerson then return end

	self:DrawTeslaBeam( CurTime() + self.TimeOffset, self.OffSet )
	self:DrawTeslaBeam( CurTime() + self.TimeOffset + 2, self.OffSet + 0.852 )

end

function ENT:DrawTeslaBeam( GTime, offset )

	local TexOffset = CurTime() * 5 + offset
	local TexOffsetEnd = TexOffset + 2
	local Perc = math.fmod( GTime, TimeSpawn ) / TimeSpawn

	local Up = self.BoneAng:Up()
	local Forward = self.BoneAng:Forward()
	local Right = self.BoneAng:Right()

	if Perc < 0.75 then

		local Vec = LerpVector( Perc / 0.75, self.StartPos, self.EndPos )
		local Pos = self.BonePos + Forward * Vec.z + Up * Vec.x + Right * Vec.y
		local Pos2 = self.BonePos + Forward * Vec.z - Up * Vec.x + Right * Vec.y

		render.StartBeam( 11 )

		for i=0, 1, 0.1 do

			render.AddBeam(
				LerpVector( i, Pos, Pos2 ),
				math.sin( i * math.pi ) * self.Width,
				Lerp( i, TexOffset, TexOffsetEnd),
				self.TeslaColor )

		end

		render.EndBeam();

	else

		local Perc = (Perc-0.75)/0.25

		local EndPos = self.EndPos
		local Begin = self.BonePos + Forward * EndPos.z + Up * EndPos.x + Right * EndPos.y
		local End = self.BonePos + Forward * EndPos.z - Up * EndPos.x + Right * EndPos.y
		//local LastVector = Begin

		render.StartBeam( 11 );

		for i=0, 1, 0.1 do

			local SinWave = math.sin( i * math.pi )
			local Next = LerpVector( i, Begin, End ) + SinWave * self.Width * 2 * Perc * Forward
			local Perc2 = math.min( Perc + SinWave * 0.5, 1 )
			local Width = math.max( SinWave + math.min( SinWave * -2 + 2 - Perc * 1.5, 0 ), 0 )

			render.AddBeam(
				Next,
				Width * self.Width, // * (1-SinWave) * (1-Perc),
				Lerp( i, TexOffset, TexOffsetEnd ),
				Color(self.TeslaColor.r,self.TeslaColor.g,self.TeslaColor.b, 255 - 255 * Perc2 )
			)

		end

		render.EndBeam();
	end

end
