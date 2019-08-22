
--[[
 	Post-Processing Events

	Put the code for your PostEvents
	in here.
]]--




local function playerDeath( mul, time )

	-- Fade to near black and white
	local layer = postman.NewColorLayer()
	layer.color = 0.2
	postman.FadeColorIn( "pdeath", layer, 2 )

	-- Fade to sharp edges
	layer = postman.NewSharpenLayer()
	layer.contrast = 3
	layer.distance = 1
	postman.FadeSharpenIn( "pdeath", layer, 2 )

	-- Slow fade to white
	layer = postman.NewColorLayer()
	layer.contrast = 2
	layer.brightness = 0.5
	postman.FadeColorIn( "pdeathslow", layer, 20 )

	-- Slow bloom
	layer = postman.NewBloomLayer()
	layer.sizex = 10
	layer.sizey = 10
	layer.multiply = 0.9
	layer.color = 0.2
	layer.passes = 2
	postman.FadeBloomIn( "pdeathslow", layer, 20 )

end
AddPostEvent( "pdeath", playerDeath )


//Adrenaline
local function Adrenaline_On( mul, time )
	local layer = postman.NewSharpenLayer()
	layer.distance = 0.62
	layer.contrast = 1.81
	postman.FadeSharpenIn( "adrenaline_on", layer, 1 )

	layer = postman.NewBloomLayer()
	layer.passes = 1
	layer.darken = 0.8
	layer.multiply = 3.25
	layer.sizex = 10
	layer.sizey = 4.57
	layer.color = 0.23
	postman.FadeBloomIn( "adrenaline_on", layer, 4 )
	
end
AddPostEvent( "adrenaline_on", Adrenaline_On )

local function Adrenaline_Off( mul, time )
    postman.ForceSharpenFade( "adrenaline_on" )
    postman.RemoveSharpenLayer( "adrenaline_on" )
   
	postman.ForceBloomFade( "adrenaline_on" )
	postman.FadeBloomOut( "adrenaline_on", 2 )
end
AddPostEvent( "adrenaline_off", Adrenaline_Off )

local function playerSpawn( mul, time )

	-- Undo death effects
	postman.ForceColorFade( "pdeath" )
    postman.RemoveColorLayer( "pdeath" )
    postman.ForceSharpenFade( "pdeath" )
    postman.RemoveSharpenLayer( "pdeath" )
    
	postman.ForceColorFade( "pdeathslow" )
	postman.FadeColorOut( "pdeathslow", 2 )
	postman.ForceBloomFade( "pdeathslow" )
	postman.FadeBloomOut( "pdeathslow", 2 )

end
AddPostEvent( "pspawn", playerSpawn )




local function playerDamage( mul, time )

	-- Red fade
	local layer = postman.NewColorLayer()
	layer.addr = mul
	postman.AddColorLayer( "pdamage", layer )
	postman.FadeColorOut( "pdamage", mul * 3 )

	-- Motionblur fade
	layer = postman.NewMotionBlurLayer()
	layer.addalpha = 0.02
	postman.AddMotionBlurLayer( "pdamage", layer )
	postman.FadeMotionBlurOut( "pdamage", mul * 3 )

end
AddPostEvent( "pdamage", playerDamage )




local function ironsightsOn( mul, time )

	-- Dark edges
	layer = postman.NewMaterialLayer()
		layer.material = "refract/bluredges"
		layer.alpha    = math.Clamp( mul, 0, 1 )
	postman.FadeMaterialIn( "ironsights", layer, time )

end
AddPostEvent( "isights_on", ironsightsOn )




local function ironsightsOff( mul, time )

    postman.ForceMaterialFade( "ironsights" )
	postman.FadeMaterialOut( "ironsights", time )

end
AddPostEvent( "isights_off", ironsightsOff )




local function cloakOn( mul, time )

	-- Grey/blue fade
	local layer = postman.NewColorLayer()
	layer.addr = -0.1
	layer.addg = -0.1
	layer.addb = 0.25
	layer.mulr = 0.2
	layer.mulg = 0.2
	layer.mulb = 0.2
	layer.color = 0.1
	layer.contrast = 1.1
	layer.brightness = 0.1
	postman.FadeColorIn( "cloak", layer, 0.5 )
	
	-- Fade to sharp edges
	layer = postman.NewSharpenLayer()
	layer.contrast = 3
	layer.distance = 0.75
	postman.FadeSharpenIn( "cloak", layer, 0.5 )
	
	-- Ripple overlay
	layer = postman.NewMaterialLayer()
	layer.material = "models/props_combine/com_shield001a"
	layer.alpha = 0.5
	layer.refract = 0.1
	postman.FadeMaterialIn( "cloak", layer, 0.5 )
	
end
AddPostEvent( "cloakon", cloakOn )


local function cloakOff( mul, time )

	postman.ForceColorFade( "cloak" )
	postman.FadeColorOut( "cloak", 0.5 )

	postman.ForceSharpenFade( "cloak" )
	postman.FadeSharpenOut( "cloak", 0.5 )

    postman.ForceMaterialFade( "cloak" )
	postman.FadeMaterialOut( "cloak", 0.5 )
	
end
AddPostEvent( "cloakoff", cloakOff )


local function testOn( mul, time )

	-- Grey/green fade
	local layer = postman.NewColorLayer()
	layer.addr = -0.1
	layer.addg = -0.1
	layer.addb = 0.25
	layer.mulr = 0.2
	layer.mulg = 0.2
	layer.mulb = 0.2
	layer.color = 0
	layer.contrast = 1.1
	layer.brightness = 0.1
	postman.FadeColorIn( "nvg", layer, 0.2 )
	
	-- Fade to sharp edges
	layer = postman.NewSharpenLayer()
	layer.contrast = 3
	layer.distance = 0.75
	postman.FadeSharpenIn( "nvg", layer, 0.2 )

	-- Dark edges
	layer = postman.NewMaterialLayer()
	layer.material = "refract/bluredges"
	layer.alpha = 1
	postman.FadeMaterialIn( "nvg", layer, 0.2 )
	
end
AddPostEvent( "teston", testOn )

local function testOff( mul, time )

	postman.ForceColorFade( "nvg" )
	postman.FadeColorOut( "nvg", 0.2 )

	postman.ForceSharpenFade( "nvg" )
	postman.FadeSharpenOut( "nvg", 0.2 )

    postman.ForceMaterialFade( "nvg" )
	postman.FadeMaterialOut( "nvg", 0.2 )
	
end
AddPostEvent( "testoff", testOff )


local function test2On( mul, time )

	-- Ripple overlay
	layer = postman.NewMaterialLayer()
	layer.material = "refract/tank_glass"
	layer.alpha = 0.5
	layer.refract = 0.1
	postman.FadeMaterialIn( "test2", layer, 3 )
	
end
AddPostEvent( "test2on", test2On )

local function test2Off( mul, time )

    postman.ForceMaterialFade( "test2" )
	postman.FadeMaterialOut( "test2", 3 )
	
end
AddPostEvent( "test2off", test2Off )