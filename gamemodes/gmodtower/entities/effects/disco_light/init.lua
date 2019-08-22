
local MaterialList = {
	"cable/blue_elec",
	//"cable/cable2",
	"cable/physbeam",
	"effects/tool_tracer"
}

EFFECT.Mat = Material( "effects/tool_tracer" )
local matLight 	= Material( "effects/yellowflare" )
local ThinkDelay = 0.18

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	//self.StartPos = data:GetStart()
	//self.EndPos = data:GetOrigin()
	
	self.Entity = data:GetEntity()
	
	if !IsValid( self.Entity ) then
		Msg("Attempted to start disco light with invalid entity!")
		return
	end
	
	self.Color = Color( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ), 255 ) 
	
	self.Life = data:GetMagnitude()
	self.SpawnTime = CurTime()
	self.NextTrace = 0
	
	self.OriginalBeamSize = math.Rand( 6, 12 )
	self.BeatScale = 1.0
	
	self.Mat = Material( MaterialList[ math.random(1, #MaterialList ) ] )
	self.Speed = math.Rand( 0.5, 2 )
	
	if math.random( 0,1 ) == 0 then
		self.Speed = self.Speed * -1
	end
	
	self.Rotation = self.Entity:WorldToLocalAngles( VectorRand():Angle() )
	
	self:FindNextPlace()

end

function EFFECT:GetEntStart()
	return self.Entity:GetPos()
end

function EFFECT:MakeTrace()
	
	return util.QuickTrace(
		self:GetEntStart(),
		self.Entity:LocalToWorldAngles( self.Rotation ):Forward() * 2048,
		self.Entity
	).HitPos
	
end

function EFFECT:FindNextPlace()
	
	if !self.TargetPos then
		self.TargetPos = self:MakeTrace()
	end
	
	self.Rotation:RotateAroundAxis( Vector(0,0,1), self.Speed * self.BeatScale )
	
	self.CurPos = self.TargetPos
	self.TargetPos = self:MakeTrace()
	
	local a,b = self:GetEntStart(), self.TargetPos  * 1 
	
	OrderVectors( a,b )
	
	self:SetRenderBoundsWS( a, b )
		
	self.NextTrace = CurTime() + ThinkDelay
	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	if !IsValid( self.Entity ) then	
		return false
	end
	
	if self.Life > 0 && CurTime() > self.SpawnTime + self.Life then 
		return false 
	end
	
	if self.NextTrace > CurTime() then
		self:FindNextPlace()	
	end
	
	if self.Entity.NextScale then
		self.BeatScale = math.Clamp((self.Entity.NextScale-0.2)/0.2, 0, 1)
	end
	
	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	
	local Start = self:GetEntStart()
	local Target = LerpVector( 
		math.Clamp( self.NextTrace - CurTime(), 0, ThinkDelay ) / ThinkDelay, 
		self.CurPos,
		self.TargetPos )
	self.Length = (Start - Target):Length()
		
	
	local TexStart = CurTime() * -0.2
	local TexEnd = TexStart + 1.0
	local DieRatio = 1.0
	
	local TimeLeft = self.Life + self.SpawnTime - CurTime()
	
	if TimeLeft < 0.25 then
		DieRatio = TimeLeft / 0.25
	end
	
	
	render.SetMaterial( self.Mat )	
	render.DrawBeam( Start, 										// Start
					Target,											// End
					(1.5 + self.BeatScale * self.OriginalBeamSize) * DieRatio,													// Width
					TexStart,														// Start tex coord
					TexEnd,									// End tex coord
					Color( self.Color.r, self.Color.g,self.Color.b, 100 + 155 * self.BeatScale )  )
	
	render.SetMaterial( matLight )
	render.DrawSprite( Target, 32, 32, self.Color )

end
