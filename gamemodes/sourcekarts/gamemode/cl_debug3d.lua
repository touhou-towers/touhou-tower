
-----------------------------------------------------
module( "Debug3D", package.seeall )

// the material to use when drawing edges in space
DebugMat = Material( "effects/laser1" )

// other materials
DebugLaser 	=	Material( "effects/laser1.vmt" )
DebugWire 	=	Material( "models/wireframe.vmt" )
DebugColor 	=	Material( "color.vmt" )
DebugArrow 	=	Material( "gui/arrow.vmt" )
DebugSprite	= 	Material( "sprites/powerup_effects" )

function DrawBeam( startpos, endpos, color )
	render.DrawBeam( startpos, endpos, 8, 0, math.Rand( 0, 1 ), color or Color( 255, 255, 255, 255 ) )
end

// draws an outlined box in 3d space with the specified color
function DrawBox( vecStart, vecEnd, color )

	local min = vecStart
	local max = vecEnd

	if ( min:Length() > max:Length() ) then
		local temp = min
		min = max
		max = temp
	end

	// borrowed from gmt's invload_box
	render.SetMaterial( DebugMat )

	//Bottom face
	DrawBeam( Vector( min.x, min.y, min.z ), Vector( max.x, min.y, min.z ) )
	DrawBeam( Vector( min.x, min.y, min.z ), Vector( min.x, max.y, min.z ) )
	DrawBeam( Vector( max.x, max.y, min.z ), Vector( min.x, max.y, min.z ) )
	DrawBeam( Vector( max.x, max.y, min.z ), Vector( max.x, min.y, min.z ) )

	//Top face
	DrawBeam( Vector( min.x, min.y, max.z ), Vector( max.x, min.y, max.z ) )
	DrawBeam( Vector( min.x, min.y, max.z ), Vector( min.x, max.y, max.z ) )
	DrawBeam( Vector( max.x, max.y, max.z ), Vector( min.x, max.y, max.z ) )
	DrawBeam( Vector( max.x, max.y, max.z ), Vector( max.x, min.y, max.z ) )

	//All 4 sides
	DrawBeam( Vector( min.x, min.y, max.z ), Vector( min.x, min.y, min.z ) )
	DrawBeam( Vector( min.x, max.y, max.z ), Vector( min.x, max.y, min.z ) )
	DrawBeam( Vector( max.x, max.y, max.z ), Vector( max.x, max.y, min.z ) )
	DrawBeam( Vector( max.x, min.y, max.z ), Vector( max.x, min.y, min.z ) )

end

// draws 3d2d'd text in 3d space
// the text will be centered at the position
function DrawText( vecPos, strText, strFont, color, scale, angle )

	if ( !strFont ) then
		strFont = "Default"
	end

	if ( !color ) then
		color = Color( 255, 255, 255, 255 )
	end

	if ( !scale ) then
		scale = 1
	end

	local ang = angle or LocalPlayer():EyeAngles()

	if not angle then
		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		angle = Angle( 0, ang.y, 90 )
	end

	surface.SetFont( strFont )

	local width, height = surface.GetTextSize( strText )
	height = height * scale

	cam.Start3D2D( vecPos + Vector( 0, 0, height / 2 ), angle, scale )
		draw.DrawText( strText, strFont, 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	cam.End3D2D()

end

function DrawSolidBox( pos, angle, min, max, bcolor )
	render.SetMaterial( DebugColor )
	render.DrawBox( pos, angle or Angle(0,0,0), min, max, bcolor or Color(255,255,255,255) )
end

function DrawPlane( pos, normal, width, height, bcolor )
	local vec = normal:Angle()
	render.SetMaterial( DebugColor )
	render.DrawBox( pos, vec, Vector(0,-width,-height), Vector(0.01,width,height), bcolor or Color(0,0,255,100) )
end

function DrawArrowOnPlane( pos, normal, dir, width, height, bcolor )
	local vec = normal:Angle() + Angle(0,0,180)
	vec:RotateAroundAxis(normal, dir)

	pos = pos + vec:Up() * height

	render.SetMaterial( DebugArrow )
	render.DrawBox( pos, vec, Vector(0,-width,-height), Vector(0.01,width,height), bcolor or Color(255,0,0,100) )
end

//Draws an axis in world space
function DrawAxis(pos, forward, right, up, scale)
	scale = scale or 1

	local min = Vector(0,-0.2,-0.2) * scale
	local max = Vector(6,0.2,0.2) * scale

	render.SetMaterial( DebugColor )
	render.DrawBox( pos, forward:Angle(), min, max, Color(255,0,0,255) )
	render.DrawBox( pos, right:Angle(), min, max, Color(0,255,0,255) )
	render.DrawBox( pos, up:Angle(), min, max, Color(0,0,255,255) )
end

function DrawLine( startpos, endpos, thickness, color, sprite )

	render.SetMaterial( DebugLaser )
	render.DrawBeam( startpos, endpos, thickness or 8, 0, 1, color or Color( 255, 255, 255, 255 ) )

	if sprite then
		render.SetMaterial( DebugSprite )
		render.DrawSprite( startpos, thickness * 2, thickness * 2, color or Color( 255, 255, 255, 255 ) )
	end

end
