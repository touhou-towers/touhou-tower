local matRefract = Material( "gmod_tower/mono/mono_spawn" )
local matLight	 = Material( "gmod_tower/mono/mono_spawn2" )

function EFFECT:Init( data )
	self.Time = 1
	self.LifeTime = CurTime() + self.Time
	
	local ent = data:GetEntity()
	if ( ent == NULL ) then return end
	
	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent:GetAngles() )
	self:SetParent( ent )
end

function EFFECT:Think( )
	if (!self.ParentEntity || !self.ParentEntity:IsValid()) then return false end

	return ( self.LifeTime > CurTime() ) 
end

function EFFECT:Render()
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	Fraction = math.Clamp( Fraction, 0, 1 )
	
	self:SetColor( 255, 255, 255, 1 + math.sin( Fraction * math.pi ) * 100 )

	local EyeNormal = self:GetPos() - EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()
	
	local Pos = EyePos() + EyeNormal * Distance * 0.01

	cam.Start3D( Pos, EyeAngles() )
		render.MaterialOverride( matLight )
			self:DrawModel()
		render.MaterialOverride( 0 )

		if ( render.GetDXLevel() >= 80 ) then
			render.UpdateRefractTexture()
			
			matRefract:SetFloat( "$refractamount", Fraction ^ 2 )

			render.MaterialOverride( matRefract )
				self:DrawModel()
			render.MaterialOverride( 0 )
		end
	cam.End3D()
end