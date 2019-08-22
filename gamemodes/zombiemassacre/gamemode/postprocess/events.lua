
-----------------------------------------------------
local function playerDamage( mul, time )
	local layer = postman.NewColorLayer()
	layer.addr = .25
	postman.AddColorLayer( "damageflash", layer )
	postman.FadeColorOut( "damageflash", mul * .4 )
end
AddPostEvent( "damageflash", playerDamage )
local function playerPickup( mul, time )
	local layer = postman.NewColorLayer()
	layer.contrast = 1.15
	layer.color = 4.0
	postman.FadeColorIn( "ppickup", layer, 0.2 )
	layer = postman.NewBloomLayer()
	layer.sizex = 9.0
	layer.sizey = 9.0
	layer.multiply = 0.45
	layer.color = 1.0
	layer.passes = 0.0
	layer.darken = 0.0
	postman.FadeBloomIn( "ppickup", layer, 1 )
	layer = postman.NewSharpenLayer()
	layer.contrast = .20
	layer.distance = 3
	postman.FadeSharpenIn( "ppickup", layer, 1.5 )
	postman.ForceColorFade( "ppickup" )	
	postman.FadeColorOut( "ppickup", 1 )
	postman.ForceBloomFade( "ppickup" )
    postman.FadeBloomOut( "ppickup", 1 )
	postman.ForceSharpenFade( "ppickup" )
    postman.FadeSharpenOut( "ppickup", 1 )
end
AddPostEvent( "ppickup", playerPickup )
local function deathOn( mul, time )
	layer = postman.NewBloomLayer()
	layer.sizex = 0
	layer.sizey = 165
	layer.multiply = 1
	layer.color = 0
	layer.passes = 5
	layer.darken = .60
	postman.FadeBloomIn( "death_on", layer, 1 )
	local layer = postman.NewColorLayer()
	layer.color = 0
	layer.contrast = 1.3
	layer.brightness = 0
	layer.addr = 0
	layer.addg = 0
	layer.addb = 0
	postman.FadeColorIn( "death_on", layer, 2 )
end
AddPostEvent( "death_on", deathOn )
local function deathOff( mul, time )
	postman.ForceColorFade( "death_on" )
	postman.FadeColorOut( "death_on", 1 )
	postman.ForceBloomFade( "death_on" )
    postman.FadeBloomOut( "death_on", 1 )
end
AddPostEvent( "death_off", deathOff )
local function survivorCameraFlash( mul, time )
	local layer = postman.NewColorLayer()
	layer.contrast = 2.0
	layer.brightness = 0.5
	postman.AddColorLayer( "survivorCamera", layer )
	postman.FadeColorOut( "survivorCamera", mul * 1 )
	layer = postman.NewSharpenLayer()
	layer.contrast = 0.55
	layer.distance = 5.25
	
	postman.AddSharpenLayer( "survivorCamera", layer, 2 )
	postman.FadeSharpenOut( "survivorCamera", mul * 1 )
end
AddPostEvent( "survivorCamera", survivorCameraFlash )