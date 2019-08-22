--[[
 	Post-Processing Events

	Put the code for your PostEvents
	in here.
]]--

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

local function playerHeal( mul, time )

	-- Green fade
	local layer = postman.NewColorLayer()
	layer.addg = mul
	postman.AddColorLayer( "pheal", layer )
	postman.FadeColorOut( "pheal", mul * 2, 0.8 )

end
AddPostEvent( "pheal", playerHeal )

//Power-ups
local function powerupTakeOn_On( mul, time )
	layer = postman.NewMotionBlurLayer()
	layer.addalpha = 0.11
	layer.drawalpha = 0.36
	postman.AddMotionBlurLayer( "putakeon_on", layer )

	local layer = postman.NewColorLayer()
	layer.color = 0.0
	layer.brightness = -0.02
	layer.contrast = 0.98
	postman.FadeColorIn( "putakeon_on", layer, 1 )

	layer = postman.NewSharpenLayer()
	layer.contrast = -0.55
	layer.distance = 1.75
	postman.FadeSharpenIn( "putakeon_on", layer, 2 )
end
AddPostEvent( "putakeon_on", powerupTakeOn_On )

local function powerupTakeOn_Off( mul, time )
	postman.FadeMotionBlurOut( "putakeon_on", mul * 3 )

	postman.ForceColorFade( "putakeon_on" )
	postman.FadeColorOut( "putakeon_on", 1 )

	postman.ForceSharpenFade( "putakeon_on" )
    postman.FadeSharpenOut( "putakeon_on", 1 )
end
AddPostEvent( "putakeon_off", powerupTakeOn_Off )


local function powerupShaft_On( mul, time )
	layer = postman.NewBloomLayer()
	layer.sizex = 0
	layer.sizey = 165
	layer.multiply = 1
	layer.color = 0
	layer.passes = 5
	layer.darken = 0.55
	postman.FadeBloomIn( "pushaft_on", layer, 1 )

	local layer = postman.NewColorLayer()
	layer.color = .55
	layer.contrast = 1.30
	layer.brightness = -0.60
	layer.addr = 0.25
	layer.addg = 0.10
	layer.addb = 0.50
	postman.FadeColorIn( "pushaft_on", layer, 1 )
end
AddPostEvent( "pushaft_on", powerupShaft_On )

local function powerupShaft_Off( mul, time )
	postman.ForceColorFade( "pushaft_on" )
	postman.FadeColorOut( "pushaft_on", 1 )

	postman.ForceBloomFade( "pushaft_on" )
    postman.FadeBloomOut( "pushaft_on", 1 )
end
AddPostEvent( "pushaft_off", powerupShaft_Off )


local function powerupTimeStop_On( mul, time )
	layer = postman.NewBloomLayer()
	layer.sizex = 15.0
	layer.sizey = 0.0
	layer.multiply = 2.0
	layer.color = 0.0
	layer.passes = 1.0
	layer.darken = 0.3
	postman.FadeBloomIn( "putimestop_on", layer, 1 )

	local layer = postman.NewColorLayer()
	layer.color = 0.5
	postman.FadeColorIn( "putimestop_on", layer, 1 )
end
AddPostEvent( "putimestop_on", powerupTimeStop_On )

local function powerupTimeStop_Off( mul, time )
	postman.ForceColorFade( "putimestop_on" )
	postman.FadeColorOut( "putimestop_on", 1 )

	postman.ForceBloomFade( "putimestop_on" )
    postman.FadeBloomOut( "putimestop_on", 1 )
end
AddPostEvent( "putimestop_off", powerupTimeStop_Off )


local function powerupHeadphones_On( mul, time )
	local layer = postman.NewColorLayer()
	layer.contrast = 1.15
	layer.color = 4.0
	postman.FadeColorIn( "puheadphones_on", layer, 0.2 )

	layer = postman.NewBloomLayer()
	layer.sizex = 9.0
	layer.sizey = 9.0
	layer.multiply = 0.45
	layer.color = 1.0
	layer.passes = 0.0
	layer.darken = 0.0
	postman.FadeBloomIn( "puheadphones_on", layer, 1 )

	layer = postman.NewSharpenLayer()
	layer.contrast = .20
	layer.distance = 3
	postman.FadeSharpenIn( "puheadphones_on", layer, 1.5 )

	LocalPlayer().Headphones = true
end
AddPostEvent( "puheadphones_on", powerupHeadphones_On )

local function powerupHeadphones_Off( mul, time )
	postman.ForceColorFade( "puheadphones_on" )
	postman.FadeColorOut( "puheadphones_on", 1 )

	postman.ForceBloomFade( "puheadphones_on" )
    postman.FadeBloomOut( "puheadphones_on", 1 )

	postman.ForceSharpenFade( "puheadphones_on" )
    postman.FadeSharpenOut( "puheadphones_on", 1 )

	LocalPlayer().Headphones = false
end
AddPostEvent( "puheadphones_off", powerupHeadphones_Off )


local function powerupRage_On( mul, time )
	local layer = postman.NewColorLayer()
	layer.brightness = 0
	layer.contrast = 1
	layer.color = 1.94
	layer.addr = 0.15
	layer.addg = 0.0
	layer.addb = 0.0
	postman.FadeColorIn( "purage_on", layer, .8 )
end
AddPostEvent( "purage_on", powerupRage_On )

local function powerupRage_Off( mul, time )
	postman.ForceColorFade( "purage_on" )
	postman.FadeColorOut( "purage_on", 1 )
end
AddPostEvent( "purage_off", powerupRage_Off )

local function powerupBag_On( mul, time )
	local layer = postman.NewColorLayer()
	layer.brightness = 0.1
	layer.contrast = 1
	layer.color = 2
	layer.addr = 0.0
	layer.addg = 0.1
	layer.addb = 0.15
	postman.FadeColorIn( "bag_on", layer, .8 )
end
AddPostEvent( "bag_on", powerupBag_On )

local function powerupBag_Off( mul, time )
	postman.ForceColorFade( "bag_on" )
	postman.FadeColorOut( "bag_on", 1 )
end
AddPostEvent( "bag_off", powerupBag_Off )

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


local function Cloak_On( mul, time )
	local layer = postman.NewColorLayer()
	layer.color = 0.20
	layer.addr = 0.0
	layer.addg = 0.15
	layer.addb = 0.45
	postman.FadeColorIn( "cloak_on", layer, 0.5 )

	layer = postman.NewBloomLayer()
	layer.sizex = 0.0
	layer.sizey = 50.0
	layer.multiply = 1.0
	layer.color = 1.0
	layer.passes = 1.0
	layer.darken = 0.45
	postman.FadeBloomIn( "cloak_on", layer, 0.5 )
end
AddPostEvent( "cloak_on", Cloak_On )

local function Cloak_Off( mul, time )
	postman.ForceColorFade( "cloak_on" )
	postman.FadeColorOut( "cloak_on", 0.5 )

	postman.ForceBloomFade( "cloak_on" )
    postman.FadeBloomOut( "cloak_on", 0.5 )
end
AddPostEvent( "cloak_off", Cloak_Off )


// karpar
local function karparEverywhere( mul, time )
	local ent = ents.GetByIndex(mul)
	local edata = EffectData()
	edata:SetOrigin(ent:GetPos())
	util.Effect("karpar", edata)
end
AddPostEvent( "karpar", karparEverywhere )


local function ironsightsOn( mul, time )

	-- Dark edges
	layer = postman.NewMaterialLayer()
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
