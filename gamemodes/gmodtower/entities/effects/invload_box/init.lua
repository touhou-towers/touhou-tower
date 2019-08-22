


EFFECT.Mat = Material( "effects/tool_tracer" )

function EFFECT:GetMinMax()
	
	local OldAngs = LocalPlayer():GetAngles()
	
	LocalPlayer():SetAngles( Angle( 0, 0, 0 ) )
	
	local Min = LocalPlayer():LocalToWorld( InventorySaver.MinLoadPosition )
	local Max = LocalPlayer():LocalToWorld( InventorySaver.MaxLoadPosition )
	
	LocalPlayer():SetAngles( OldAngs )
	
	self.Entity:SetRenderBoundsWS( Min, Max )
	
	return Min, Max
	
end

/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init()	

end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	self:GetMinMax()
	
	return InventorySaver.OnLoadStage

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	
	local Min, Max = self:GetMinMax()
	
	local Length = (Max - Min):Length()
	
	
		
	render.SetMaterial( self.Mat )
	local texcoord = math.Rand( 0, 1 )
	
	local function DrawBeam( startpos, endpos )
		render.DrawBeam( 
			startpos,
			endpos,
			8,
			texcoord,
			texcoord + Length / 128,
			Color( 255, 255, 255, 255 ) 
		)
	end
	
	//Bottom face
	DrawBeam( Vector( Min.x, Min.y, Min.z ), Vector( Max.x, Min.y, Min.z ) )
	DrawBeam( Vector( Min.x, Min.y, Min.z ), Vector( Min.x, Max.y, Min.z ) )
	DrawBeam( Vector( Max.x, Max.y, Min.z ), Vector( Min.x, Max.y, Min.z ) )
	DrawBeam( Vector( Max.x, Max.y, Min.z ), Vector( Max.x, Min.y, Min.z ) )
	
	//Top face
	DrawBeam( Vector( Min.x, Min.y, Max.z ), Vector( Max.x, Min.y, Max.z ) )
	DrawBeam( Vector( Min.x, Min.y, Max.z ), Vector( Min.x, Max.y, Max.z ) )
	DrawBeam( Vector( Max.x, Max.y, Max.z ), Vector( Min.x, Max.y, Max.z ) )
	DrawBeam( Vector( Max.x, Max.y, Max.z ), Vector( Max.x, Min.y, Max.z ) )
	
	//All 4 sides
	DrawBeam( Vector( Min.x, Min.y, Max.z ), Vector( Min.x, Min.y, Min.z ) )
	DrawBeam( Vector( Min.x, Max.y, Max.z ), Vector( Min.x, Max.y, Min.z ) )
	DrawBeam( Vector( Max.x, Max.y, Max.z ), Vector( Max.x, Max.y, Min.z ) )
	DrawBeam( Vector( Max.x, Min.y, Max.z ), Vector( Max.x, Min.y, Min.z ) )
	
end
