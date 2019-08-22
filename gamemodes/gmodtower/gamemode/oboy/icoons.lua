
local surface = surface
local Material = Material

module("GTowerIcoons")


local path = "gmod_tower/panelos/icons/"

local function Create( png, filter, path_override )
	return Material( (path_override or path).. png, filter or "unlitsmooth" )
end

Icoons = {
	["gmt"] = Create( "logo_flat.png", "unlitsmooth", "gmod_tower/hud/" ),
	["gmtsmall"] = Create( "gmt.png" ),
	["home"] = Create( "home.png" ),
	["back"] = Create( "back.png" ),
	["camera"] = Create( "video.png" ),
	["music"] = Create( "music.png" ),
	["options"] = Create( "settings.png" ),
	["lock"] = Create( "lock.png" ),
	["unlock"] = Create( "unlock.png" ),
	["alarm"] = Create( "alarms.png" ),
	["time"] = Create( "time.png" ),
	["backspace"] = Create( "backspace.png" ),
	["label"] = Create( "label.png" ),
	["about"] = Create( "about.png" ),
	["storage"] = Create( "storage.png" ),
	["skip"] = Create( "skip.png" ),
	["rewind"] = Create( "rewind.png" ),
	["pause"] = Create( "pause.png" ),
	["play"] = Create( "play.png" ),
	["shuffle"] = Create( "shuffle.png" ),
	["addqueue"] = Create( "addqueue.png" ),
	["images"] = Create( "images.png" ),
	["doorclose"] = Create( "door_closed.png" ),
	["dooropen"] = Create( "door_open.png" ),
	["condo"] = Create( "condo.png" ),
	["players"] = Create( "players.png" ),
	["controller"] = Create( "controller.png" ),
	["movies"] = Create( "movies.png" ),
	["beer"] = Create( "beer.png" ),
	["tv"] = Create( "tv.png" ),
	["party"] = Create( "party.png" ),
	["musicpage"] = Create( "musicpage.png" ),
	["instrument"] = Create( "instrument.png" ),
	["accept"] = Create( "accept.png" ),
	["cancel"] = Create( "cancel.png" ),
	["ban"] = Create( "ban.png" ),
	["heart"] = Create( "heart.png" ),
	["box"] = Create( "box.png" ),
	["broom"] = Create( "broom.png" ),
	["safe"] = Create( "safe.png" ),
	["money"] = Create( "money.png" ),
	["moneylost"] = Create( "money.png" ),
	["trophy"] = Create( "trophy.png" ),
	["present"] = Create( "present.png" ),
	["clipboard"] = Create( "clipboard.png" ),
	["hat"] = Create( "hat.png" ),
	["arcade"] = Create( "arcade.png" ),
	["cards"] = Create( "cards.png" ),
	["slots"] = Create( "slots.png" ),
	["pool"] = Create( "pool.png" ),
	["flag"] = Create( "flag.png" ),
	["admin"] = Create( "admin.png" ),
	["announce"] = Create( "announce.png" ),
	["exclamation"] = Create( "exclamation.png" ),
	["next"] = Create( "next.png" ),
	["light"] = Create( "light.png" ),
	["floor1"] = Create( "floor1.png" ),
	["floor2"] = Create( "floor2.png" ),
	["volume_on"] = Create( "volume_on.png" ),
	["volume_off"] = Create( "volume_off.png" ),
	["volume"] = Create( "volume.png" ),
	["volume16"] = Create( "volume16.png", "unlit" ),
	["chips"] = Create( "chip.png", nil, "gmod_tower/icons/" ),
}


function GetIcoon( name )
	return Icoons[ name ]
end
