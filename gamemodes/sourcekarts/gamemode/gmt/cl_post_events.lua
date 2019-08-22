
-----------------------------------------------------
AddPostEvent( "fadeon", function( mul, time )

	local layer = postman.NewColorLayer()
	layer.brightness = -2
	postman.FadeColorIn( "fade", layer, 1 )
	
end )

AddPostEvent( "fadeoff", function( mul, time )

	postman.ForceColorFade( "fade" )
	postman.FadeColorOut( "fade", .5 )
	
end )


AddPostEvent( "test2on", function( mul, time )

	-- Ripple overlay
	
end )

AddPostEvent( "test2off", function( mul, time )

	
end )

AddPostEvent( "fluxon", function( mul, time )

	layer = postman.NewBloomLayer()
	layer.sizex = 15.0
	layer.sizey = 0.0
	layer.multiply = 1.0
	layer.color = 0.0
	layer.passes = 1.0
	layer.darken = .9
	postman.FadeBloomIn( "fluxon", layer, 1 )
	
	local layer = postman.NewColorLayer()
	layer.color = 0.25
	postman.FadeColorIn( "fluxon", layer, 1 )

end )

AddPostEvent( "fluxoff", function( mul, time )

	postman.ForceColorFade( "fluxon" )
	postman.FadeColorOut( "fluxon", 1 )
	
	postman.ForceBloomFade( "fluxon" )
    postman.FadeBloomOut( "fluxon", 1 )

end )

AddPostEvent( "teleon", function( mul, time )

	local layer = postman.NewColorLayer()
	layer.contrast = 1
	layer.color = 2.0
	postman.FadeColorIn( "teleon", layer, 1 )
	
	layer = postman.NewBloomLayer()
	layer.sizex = 9.0
	layer.sizey = 9.0
	layer.multiply = 0.45
	layer.color = 1.0
	layer.passes = 0.0
	layer.darken = 0.0
	postman.FadeBloomIn( "teleon", layer, 1 )
	
	layer = postman.NewSharpenLayer()
	layer.contrast = .20
	layer.distance = 3
	postman.FadeSharpenIn( "teleon", layer, 1.5 )

	layer = postman.NewMaterialLayer()
	layer.material = "models/props_combine/portalball001_sheet"
	layer.alpha = 1
	layer.refract = 0.5
	postman.FadeMaterialIn( "teleon", layer, 3 )
	
end )

AddPostEvent( "teleoff", function( mul, time )

	postman.ForceColorFade( "teleon" )
	postman.FadeColorOut( "teleon", 1 )
	
	postman.ForceBloomFade( "teleon" )
    postman.FadeBloomOut( "teleon", 2 )
	
	postman.ForceSharpenFade( "teleon" )
    postman.FadeSharpenOut( "teleon", 1 )

    postman.ForceMaterialFade( "teleon" )
	postman.FadeMaterialOut( "teleon", .5 )
	
end )