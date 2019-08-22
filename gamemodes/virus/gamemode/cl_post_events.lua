local function playerDamage( mul, time )
	//Red fade
	local layer = postman.NewColorLayer()
	layer.addr = mul
	postman.AddColorLayer( "pdamage", layer )
	postman.FadeColorOut( "pdamage", mul * .5, 0.4 )

	//Motionblur fade
	layer = postman.NewMotionBlurLayer()
	layer.addalpha = 0.02
	postman.AddMotionBlurLayer( "pdamage", layer )
	postman.FadeMotionBlurOut( "pdamage", mul * .4 )
end
AddPostEvent( "pdamage", playerDamage )

//SWEPS
local function swepNESZapper( mul, time )
	local layer = postman.NewColorLayer()
	layer.contrast = 2.0
	layer.brightness = 0.5
	postman.AddColorLayer( "neszapper", layer )
	postman.FadeColorOut( "neszapper", mul * .5 )
	
	layer = postman.NewSharpenLayer()
	layer.contrast = 0.55
	layer.distance = 5.25
	postman.AddSharpenLayer( "neszapper", layer, 2 )
	postman.FadeSharpenOut( "neszapper", mul * .5 )
end
AddPostEvent( "neszapper", swepNESZapper )

local function ironsightsOn( mul, time )
	local layer = postman.NewMaterialLayer()
		layer.material = "gmod_tower/pvpbattle/bluredges"
		layer.alpha    = math.Clamp( mul, 0, 1 )
	postman.FadeMaterialIn( "ironsights", layer, time )
end
AddPostEvent( "isights_on", ironsightsOn )

local function ironsightsOff( mul, time )
    postman.ForceMaterialFade( "ironsights" )
	postman.FadeMaterialOut( "ironsights", time )
end
AddPostEvent( "isights_off", ironsightsOff )


//Facility
local function facilityPost( mul, time )	
	local layer = postman.NewColorLayer()
	layer.brightness = -0.1
	layer.contrast = 1.21
	layer.color = 1.04
	postman.AddColorLayer( "gmt_virus_facility", layer )
end
AddPostEvent( "gmt_virus_facility", facilityPost )

//Lostarena
local function lostarenaPost( mul, time )	
	local layer = postman.NewColorLayer()
	layer.brightness = -0.11
	layer.contrast = 0.75
	layer.color = 0.87
	postman.AddColorLayer( "gmt_virus_lostarena", layer )
end
AddPostEvent( "gmt_virus_lostarena", lostarenaPost )

//Riposte
local function ripostePost( mul, time )	
	local layer = postman.NewColorLayer()
	layer.brightness = -0.08
	layer.contrast = 1.32
	layer.color = 0.87
	postman.AddColorLayer( "gmt_virus_riposte", layer )
end
AddPostEvent( "gmt_virus_riposte", ripostePost )

//Swamp
local function swampPost( mul, time )	
	local layer = postman.NewColorLayer()
	layer.brightness = -0.14
	layer.contrast = 0.53
	layer.color = 0.87
	postman.AddColorLayer( "gmt_virus_swamp", layer )
end
AddPostEvent( "gmt_virus_swamp", swampPost )

//SwampLight
local function swamplightPost( mul, time )	
	local layer = postman.NewColorLayer()
	layer.brightness = -0.07
	layer.contrast = 0.98
	layer.color = 0.83
	postman.AddColorLayer( "gmt_virus_swamplight", layer )
end
AddPostEvent( "gmt_virus_swamplight", swamplightPost )

//Infected
local function infection_On( mul, time )
	local layer = postman.NewBloomLayer()
	layer.sizex = 24
	layer.sizey = 0
	layer.multiply = 1.56
	layer.passes = 1
	layer.darken = 0.8
	layer.color = 0.15
	layer.colr = 0.99
	layer.colg = 0.247
	layer.colb = 0.25
	postman.FadeBloomIn( "infection_on", layer, 1 )
end
AddPostEvent( "infection_on", infection_On )

local function infection_Off( mul, time )	
	postman.ForceBloomFade( "infection_on" )
    postman.FadeBloomOut( "infection_on", 1 )
end
AddPostEvent( "infection_off", infection_Off )

//Last Alive
local function lastMan_On( mul, time )
	local layer = postman.NewSharpenLayer()
	layer.distance = 0.62
	layer.contrast = 1.81
	postman.FadeSharpenIn( "lastman_on", layer, 1 )

	layer = postman.NewBloomLayer()
	layer.passes = 1
	layer.darken = 0.8
	layer.multiply = 3.25
	layer.sizex = 10
	layer.sizey = 4.57
	layer.color = 0.23
	postman.FadeBloomIn( "lastman_on", layer, 4 )
	
end
AddPostEvent( "lastman_on", lastMan_On )

local function lastMan_Off( mul, time )
    postman.ForceSharpenFade( "lastman_on" )
    postman.RemoveSharpenLayer( "lastman_on" )
   
	postman.ForceBloomFade( "lastman_on" )
	postman.FadeBloomOut( "lastman_on", 2 )
end
AddPostEvent( "lastman_off", lastMan_Off )



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