
local string, math, timer = string, math, timer
local Vector, tostring, tonumber = Vector, tostring, tonumber
local CLIENT = CLIENT

local Msg = Msg
local _G = _G
local IsValid = IsValid
local Matrix = Matrix
local Scale = Scale

module("GTowerModels")

DEBUG = false
MaxScale = 4.0
AdminModels = {}
NormalModels = {}

local function AddValidModel( Name, model, admin )

	_G.player_manager.AddValidModel( Name, model );
	_G.list.Set( "PlayerOptionsModel", Name, model );

	if admin == true then
		AdminModels[Name] = true
	else
		NormalModels[Name] = true
	end
end

// Private Use
// ============================
-- TODO, renable these
--[[AddValidModel( "infected", "models/player/virusi.mdl", nil, true ) -- for virus
AddValidModel( "minigolf", "models/sunabouzu/golf_ball.mdl", nil, true ) -- minigolf!
AddValidModel( "uchghost", "models/uch/mghost.mdl", nil, true ) -- uch
AddValidModel( "uchpigmask", "models/uch/pigmask.mdl", nil, true ) -- uch]]

// Public Use
// ============================

AddValidModel( "normal", "models/player/normal.mdl" ) // Used in Duels and PVP Battle!
AddValidModel( "teslapower", "models/player/teslapower.mdl" )
AddValidModel( "spytf2", "models/player/drpyspy/spy.mdl" )
AddValidModel( "shaun", "models/player/shaun.mdl" )
AddValidModel( "isaac", "models/player/security_suit.mdl" )
AddValidModel( "midna", "models/player/midna.mdl" )
AddValidModel( "sunabouzu", "models/player/Sunabouzu.mdl" )
AddValidModel( "zoey", "models/player/zoey.mdl" )
AddValidModel( "sniper", "models/player/robber.mdl" )
AddValidModel( "spacesuit", "models/player/spacesuit.mdl" )
AddValidModel( "scarecrow", "models/player/scarecrow.mdl" )
AddValidModel( "smith", "models/player/smith.mdl" )
AddValidModel( "libertyprime", "models/player/sam.mdl" )
AddValidModel( "rpcop", "models/player/azuisleet1.mdl" )
AddValidModel( "altair", "models/player/altair.mdl" )
AddValidModel( "dinosaur", "models/player/foohysaurusrex.mdl" )
AddValidModel( "rorschach", "models/player/rorschach.mdl" )
AddValidModel( "aphaztech", "models/player/aphaztech.mdl" )
AddValidModel( "faith", "models/player/faith.mdl" )
AddValidModel( "robot", "models/player/robot.mdl" )
AddValidModel( "niko", "models/player/niko.mdl" )
AddValidModel( "zelda", "models/player/zelda.mdl" )
AddValidModel( "dude", "models/player/dude.mdl" )
AddValidModel( "leon", "models/player/leon.mdl" )
AddValidModel( "chris", "models/player/chris.mdl" )
AddValidModel( "gmen", "models/player/gmen.mdl" )
AddValidModel( "joker", "models/player/joker.mdl" )
AddValidModel( "hunter", "models/player/hunter.mdl" )
AddValidModel( "steve", "models/player/mcsteve.mdl" )
AddValidModel( "gordon", "models/player/gordon.mdl" )
AddValidModel( "masseffect", "models/player/masseffect.mdl" )
AddValidModel( "scorpion", "models/player/scorpion.mdl" )
AddValidModel( "subzero", "models/player/subzero.mdl" )
AddValidModel( "undeadcombine", "models/player/clopsy.mdl" )
AddValidModel( "boxman", "models/player/nuggets.mdl" )
AddValidModel( "macdguy", "models/player/macdguy.mdl" )
AddValidModel( "rayman", "models/player/rayman.mdl" )
AddValidModel( "raz", "models/player/raz.mdl" )
AddValidModel( "knight", "models/player/knight.mdl" )
AddValidModel( "bobafett", "models/player/bobafett.mdl" )
AddValidModel( "chewbacca", "models/player/chewbacca.mdl" )
AddValidModel( "assassin", "models/player/dishonored_assassin1.mdl" )
AddValidModel( "haroldlott", "models/player/haroldlott.mdl" )
AddValidModel( "harry_potter", "models/player/harry_potter.mdl" )
AddValidModel( "jack_sparrow", "models/player/jack_sparrow.mdl" )
AddValidModel( "jawa", "models/player/jawa.mdl" )
AddValidModel( "marty", "models/player/martymcfly.mdl" )
AddValidModel( "samuszero", "models/player/samusz.mdl" )
AddValidModel( "skeleton", "models/player/skeleton.mdl" )
AddValidModel( "stormtrooper", "models/player/stormtrooper.mdl" )
AddValidModel( "luigi", "models/player/suluigi_galaxy.mdl" )
AddValidModel( "mario", "models/player/sumario_galaxy.mdl" )
AddValidModel( "zero", "models/player/lordvipes/MMZ/Zero/zero_playermodel_cvp.mdl" )
AddValidModel( "yoshi", "models/player/yoshi.mdl" )
--AddValidModel( "helite", "models/player/lordvipes/h2_elite/eliteplayer.mdl", "models/player/lordvipes/h2_elite/arms/elitearms.mdl" )
--AddValidModel( "grayfox", "models/player/lordvipes/Metal_Gear_Rising/gray_fox_playermodel_cvp.mdl" )
--AddValidModel( "jcdenton", "models/player/lordvipes/de_jc/jcplayer.mdl" )
AddValidModel( "crimsonlance", "models/player/lordvipes/bl_clance/crimsonlanceplayer.mdl" )
--[[AddValidModel( "nighthawk", "models/player/lordvipes/residentevil/nighthawk/nighthawk_playermodel_cvp.mdl", "models/player/lordvipes/residentevil/nighthawk/nighthawkARMS_cvp.mdl" )
AddValidModel( "hunk", "models/player/lordvipes/residentevil/HUNK/hunk_playermodel_cvp.mdl", "models/player/lordvipes/residentevil/HUNK/hunkarms_cvp.mdl" )
AddValidModel( "geth", "models/player/lordvipes/masseffect/geth/geth_trooper_playermodel_cvp.mdl", "models/player/lordvipes/masseffect/geth/Arms/getharms_cvp.mdl" )]]
AddValidModel( "walterwhite", "models/agent_47/agent_47.mdl" )
--[[AddValidModel( "franklin", "models/GrandTheftAuto5/Franklin.mdl" )
AddValidModel( "trevor", "models/GrandTheftAuto5/Trevor.mdl" )
AddValidModel( "michael", "models/GrandTheftAuto5/Michael.mdl" )]]
AddValidModel( "jackskellington", "models/vinrax/player/Jack_player.mdl" ) -- by Vinrax
AddValidModel( "deadpool", "models/player/deadpool.mdl" )
AddValidModel( "deathstroke", "models/norpo/ArkhamOrigins/Assassins/Deathstroke_ValveBiped.mdl" )
AddValidModel( "carley", "models/nikout/carleypm.mdl" )
AddValidModel( "solidsnake", "models/player/big_boss.mdl" )
--AddValidModel( "atlas", "models/bots/survivor_mechanic.mdl", "models/bots/arms/v_arms_mechanic_new.mdl" ) -- by Voikanaa
AddValidModel( "tronanon", "models/player/anon/anon.mdl" ) -- by Rokay "Rambo"
AddValidModel( "alice", "models/player/alice.mdl" )
--AddValidModel( "windranger", "models/heroes/windranger/windranger.mdl" )
AddValidModel( "ash", "models/player/red.mdl" )
AddValidModel( "megaman", "models/vinrax/player/megaman64_player.mdl" )
AddValidModel( "kilik", "models/player/hhp227/kilik.mdl" )
--AddValidModel( "bond", "models/player/bond.mdl" )
AddValidModel( "ironman", "models/Avengers/Iron Man/mark7_player.mdl" )
AddValidModel( "masterchief", "models/player/lordvipes/haloce/spartan_classic.mdl" )
AddValidModel( "doomguy", "models/ex-mo/quake3/players/doom.mdl" )
AddValidModel( "freddykruger", "models/player/freddykruger.mdl" )
AddValidModel( "greenarrow", "models/player/greenarrow.mdl" )
AddValidModel( "linktp", "models/player/linktp.mdl" )
AddValidModel( "roman", "models/player/romanbellic.mdl" )
--AddValidModel( "ornstein", "models/nikout/darksouls2/characters/olddragonslayer.mdl" )

// Remove bad playermodels
// ============================
/*local PlayerModels = player_manager.AllValidModels()
PlayerModels["american_assault"] = nil
PlayerModels["german_assault"] = nil
PlayerModels["scientist"] = nil
PlayerModels["gina"] = nil
PlayerModels["magnusson"] = nil*/



List = {
	[ "models/player/redrabbit2.mdl" ] = 0.55,
	[ "models/player/redrabbit3.mdl" ] = 0.55,
	[ "models/player/digi.mdl" ] = 0.75,
	["models/player/rayman.mdl"] = 0.75,
	["models/player/midna.mdl"] = 0.45,
	["models/player/mcsteve.mdl"] = 0.75,
	["models/player/raz.mdl"] = 0.50,
	["models/player/jawa.mdl"] = 0.65,
	["models/player/sumario_galaxy.mdl"] = 0.45,
	["models/player/suluigi_galaxy.mdl"] = 0.5,
	["models/player/lordvipes/mmz/zero/zero_playermodel_cvp.mdl"] = 0.85,
	["models/vinrax/player/megaman64_player.mdl"] = 0.7,
	["models/player/alice.mdl"] = 0.85,
	["models/player/harry_potter.mdl"] = 0.75,
	["models/player/yoshi.mdl"] = 0.5,
	["models/player/linktp.mdl"] = 0.85,
	["models/player/red.mdl"] = 0.85,
	["models/player/martymcfly.mdl"] = 0.85,
	["models/player/hhp227/kilik.mdl"] = 1.05,
}


local ScaledModels = {
	/*["models/player/sackboy.mdl"] = 0.55,*/
	["models/player/rayman.mdl"] = 0.75,
	["models/player/midna.mdl"] = 0.45,
	["models/player/mcsteve.mdl"] = 0.75,
	["models/player/raz.mdl"] = 0.50,
	["models/player/jawa.mdl"] = 0.65,
	["models/player/sumario_galaxy.mdl"] = 0.45,
	["models/player/suluigi_galaxy.mdl"] = 0.5,
	["models/player/lordvipes/mmz/zero/zero_playermodel_cvp.mdl"] = 0.85,
	["models/vinrax/player/megaman64_player.mdl"] = 0.7,
	["models/player/alice.mdl"] = 0.85,
	["models/player/harry_potter.mdl"] = 0.75,
	["models/player/yoshi.mdl"] = 0.5,
	["models/player/linktp.mdl"] = 0.85,
	["models/player/red.mdl"] = 0.85,
	["models/player/martymcfly.mdl"] = 0.85,
	["models/player/hhp227/kilik.mdl"] = 1.05,
}

local BodyGroupHatModels = {
	["models/player/freddykruger.mdl"] = { 1, 1 },
	["models/player/linktp.mdl"] = { 1, 1 },
	["models/heroes/windranger/windranger.mdl"] = { 1, 0 },
}

function GetScale( model )
	return ScaledModels[ model ] or 1
end

function SetHull( ply, scale )
	if DEBUG then
		Msg("Changing " .. tostring(ply) .. " scale to: " .. scale .. "\n" )
	end

	if scale != 1.0 then
		ply:SetHull( Vector( -16, -16, 0 ) * scale, Vector( 16,  16,  72 ) * scale)
		ply:SetHullDuck( Vector( -16, -16, 0 ) * scale , Vector( 16,  16,  36 ) * scale )
	else
		ply:ResetHull()
	end

	local ViewOffset = Vector(0,0,64) * scale
	local ViewOffsetDucket = Vector(0,0,28) * scale

	if ViewOffset.z < 1 then
		ViewOffset.z = 1
	end

	if ViewOffsetDucket.z < 1 then
		ViewOffsetDucket.z = 1
	end

	ply:SetViewOffset( ViewOffset )
	ply:SetViewOffsetDucked( ViewOffsetDucket )

	ply:SetJumpPower( math.Clamp( 240 * ( 1 / scale ), 240, 400 ) )
	ply:SetStepSize( math.Clamp( 18 * scale, 1, 36 ) )

	ply.GTowerPlyScale = scale

end

function ChangeHull( ply )
	if SERVER && ply:InVehicle() then
		ply:ExitVehicle()
	end

	timer.Simple( 0.0, function()
		ChangeHull2(ply)
	end)
end

function UpdateOnClient( ply )

	local scale = Get( ply ) or 1.0
	local ModelScale = math.Round( GetScale( ply:GetModel() ) * scale, 2 )

	if math.Round( ply:GetModelScale(), 2 ) != ModelScale then

		Msg( "rescaling", ply )
		Msg( ModelScale, " ", math.Round( ply:GetModelScale(), 2 ) )

		local mat = Matrix()
		mat:Scale(Vector(ModelScale,ModelScale,ModelScale))
		ply:EnableMatrix("RenderMultiply", mat)
		ply:SetRenderBounds( Vector( -16, -16, 0 ) * ModelScale, Vector( 16,  16,  72 ) * ModelScale )

	end

end

ChangeHull2 = function( ply )
	if IsValid( ply ) && _G.GAMEMODE.AllowChangeSize != false then
		local model = ply:GetModel()
		local scale = Get( ply ) or 1.0

		if ply.GTowerPlyScale != scale then
			ply:SetModelScale(scale,0)
			SetHull( ply, scale )
		end

		if CLIENT then
			local ModelScale = scale

			if scale == 1.0 && List[ model ] then
				ModelScale = List[ model ]
			end
			ply:SetModelScale( ModelScale )

			ply:SetRenderBounds( Vector( -16, -16, 0 ) * ModelScale, Vector( 16,  16,  72 ) * ModelScale)
		end

	end
end

function GetModelName( Name )
	local model, skin = string.match( string.lower( Name ), "([%a%d_]+)[%-]*(%d*)" )

	return model, tonumber( skin ) or 0
end

_G.hook.Add("Location","MikuScaleHook", function( ply )
	timer.Create("Replace"..tostring(ply).."Size", 0.1, 1, function()
		ChangeHull2(ply)
	end)
end )

_G.RegisterNWTablePlayer({
	{"_PlyModelSize", 1.0, _G.NWTYPE_FLOAT, _G.REPL_EVERYONE, ChangeHull},
})
