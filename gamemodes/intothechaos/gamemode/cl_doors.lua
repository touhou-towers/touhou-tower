
local StaticMaterial = Material( "room209/static" )

surface.CreateFont( "HalloweenFontSmall", {
	font = "Roboto Cn",
	size = 72,
	weight = 1500,
	antialias = true,
  bold = true,
} )

surface.CreateFont( "HalloweenFontSmaller", {
	font = "Roboto Cn",
	size = 32,
	weight = 1500,
	antialias = true,
} )

hook.Add( "PostDrawOpaqueRenderables", "HalloweenDoors", function()
	cam.Start3D2D( Vector(-158, -900, 96), Angle(0, -90, 90), 0.15 )

  surface.SetMaterial( StaticMaterial )
  surface.SetDrawColor( Color( 255, 255, 255, 20 ) )
  surface.DrawTexturedRect( -500, -500, 1055, 1255 )

    draw.DrawText("HALLOWEEN RIDE",
      "HalloweenFontSmall",
      0,
      0,
      Color( 255, 255, 255, 255 ),
    TEXT_ALIGN_CENTER)

    draw.DrawText("YOU MUST BE AT LEAST THIS TALL TO RIDE",
      "HalloweenFontSmaller",
      0,
      64,
      Color( 255, 255, 255, 255 ),
    TEXT_ALIGN_CENTER)

	cam.End3D2D()
end )
