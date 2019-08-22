include('shared.lua')

local FONT = "GTowerSkyMsgSmall"
local NUMSides = 5

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize() 
	self:SetRenderBounds(Vector(-128,-128,-128), Vector(128,128,128))
	
	self:SetText( "Minigame" )
	
	self:SetNetworkedVarProxy("Name", self.NameChanged )
	
end

function ENT:Think() end

function ENT:Draw()
	self:DrawModel()
end

function ENT:NameChanged( name, old, new )
	self:SetText( new )
end

function ENT:DrawTranslucent()
	// Aim the screen forward
	/*
	local ang = LocalPlayer():EyeAngles()
	local pos = self.Entity:GetPos() + Vector( 0, 0, 70 ) + ang:Up() * math.sin( CurTime() ) * 8
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	*/
	
	// Aim the screen forward
	local ang = self.Entity:GetAngles()
	local pos = self.Entity:GetPos() + ang:Up() * math.sin( CurTime() ) * 2
	local AngleDivision = 360 / NUMSides
	local LocalPos = LocalPlayer():EyePos()
	local DrawList = {}
	
	ang:RotateAroundAxis( ang:Up(), math.fmod( CurTime() * 5, 360 ) )
	
	for i = 1, NUMSides do
		local DrawPos = pos + ang:Forward() * self.Distance
	
		table.insert( DrawList, 
			{DrawPos, Angle( ang.p, ang.y, ang.r ), LocalPos:Distance( DrawPos ) }
		)
		
		ang:RotateAroundAxis( ang:Up(), AngleDivision )
	end
	
	table.sort( DrawList, function( a, b )
		return a[3] > b[3]
	end )
	
	for _, v in ipairs( DrawList ) do
		self:DrawFace( v[1], v[2] )
	end
	
end

function ENT:SetText( text )

	surface.SetFont( FONT )
	
	local w,h = surface.GetTextSize( text )
	
	self.NegativeX = -w / 2
	self.PositiveY = -h
	
	self.TextWidth, self.TextHeight = w, h
	self.Distance = w / 2
	self.StrText = text
	
end

function ENT:DrawFace( pos, ang )

	local Alpha = 100
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	if (LocalPlayer():EyePos() - pos ):DotProduct( ang:Up() ) < 0 then
		Alpha = 255
		ang:RotateAroundAxis( ang:Right(), 180 )
	end
	
	// Start the fun
	cam.Start3D2D( pos, ang, 0.5 )
	
		surface.SetDrawColor( 20, 40, 200, Alpha )
		surface.DrawRect( self.NegativeX - 10, self.PositiveY - 10, self.TextWidth + 20, self.TextHeight + 20 )
		
		surface.SetFont( FONT )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( self.NegativeX, self.PositiveY )
		surface.DrawText( self.StrText )
		
	cam.End3D2D()


end