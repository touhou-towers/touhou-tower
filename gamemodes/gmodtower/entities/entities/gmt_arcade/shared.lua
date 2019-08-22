
ENT.Base		= "browser_base"
ENT.Type		= "anim"
ENT.PrintName		= "Arcade Cabinet"
ENT.Contact		= ""
ENT.Purpose		= "For GMod Tower"
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.Model		= "models/gmod_tower/arcadecab.mdl"

GtowerPrecacheModel( ENT.Model )

ENT.GameIDs		= {	"Generic Game",
				"Patapon",
				"Fancy Pants",
				"Go Go Happy Smile",
				"Neverending Light",
				"Super Mario 63",
				"Shift",
				"Portal",
				"The Game",
				"Dino Run",
				"Morning Star",
				"The Last Stand",
				"Super Karoshi",
				"n",
				"Sprite Smash",
				"Heavy Weapons",
				"Metal Slug",
				"flow",
				"Hover Kart",
				"Ballracer",
				"Mirrors Edge 2D",
				"Paws",
				"Vox Populi",
				"More Zombies"
			}
ENT.GameHTML	= {	"http://uploads.ungrounded.net/467000/467574_THe_game_Maxgames.swf?123",
				"http://m.flashgame6.com/flash_games/patapon.swf",
				"https://uploads.ungrounded.net/301000/301341_The_Fancy_Pants_Adventures.swf?123",
				"https://uploads.ungrounded.net/288000/288598_happyGame_win.swf?123",
				"https://uploads.ungrounded.net/484000/484591_neverending_light_v1.3.swf?123",
				"https://uploads.ungrounded.net/498000/498969_Super_Mario_63__2009_.swf?123",
				"https://uploads.ungrounded.net/422000/422855_Shiftfla5.swf?123",
				"http://uploads.ungrounded.net/404000/404612_Portal.swf?123",
				"http://uploads.ungrounded.net/467000/467574_THe_game_Maxgames.swf?123",
				"http://uploads.ungrounded.net/443000/443828_dinorun.swf?123",
				"http://armorgames.com/files/games/morningstar-3814.swf?v=1373587521",
				"http://uploads.ungrounded.net/375000/375622_ZombiesShell_070426_FINAL..swf?123",
				"http://uploads.ungrounded.net/497000/497593_SuperKaroshi_final_notSL.swf?123",
				"http://www.addictinggames.com/newGames/action-games/n-game/n-game.swf",
				"http://uploads.ungrounded.net/409000/409346_spritesmash.swf?123",
				"http://uploads.ungrounded.net/497000/497779_HeavyWeapons.swf?123",
				"http://uploads.ungrounded.net/475000/475284_MetalSlugBrutal2.swf?123",
				"http://www.xgenstudios.com/flow/flow.swf",
				"http://uploads.ungrounded.net/494000/494302_arcadeLoader_newgrounds_ba.swf?123",
				"http://uploads.ungrounded.net/494000/494302_arcadeLoader_newgrounds_ba.swf?123",
				"http://www8.agame.com/mirror/flash/m/mirrorsedge.swf?gp=1",
				"https://uploads.ungrounded.net/507000/507298_Paws.swf?123",
				"https://armorgames.com/files/games/vox-populi-vox-dei-a-4460.swf?v=1373587522",
				"https://uploads.ungrounded.net/506000/506341_MoreZombies.swf?123"
			}
//This is the ID to start with, since "Generic Game" is not a game, start a 2
ENT.StartId = 2

ENT.AchiCount = #ENT.GameIDs - ENT.StartId + 1
local Count = ENT.AchiCount

hook.Add("LoadAchivements","AchiArcadeJunkie", function () 
	
/* the achievement has issues + the arcades aren't all there

	GtowerAchivements:Add( ACHIVEMENTS.ArcadeJunkie, {
		Name = "Arcade Junkie", 
		Description = "Play each flash arcade game. ", 
		Value = Count,
		Group = 4,
		BitValue = true,
		GiveItem = "trophy_arcadejunkie"
	})
*/

	GtowerAchivements:Add( ACHIVEMENTS.FANCYPANTS, {
		Name = "Fancy Pants", 
		Description = "Play Fancy Pants Adventure while wearing a top hat.", 
		Value = 1,
		Group = 4,
		GiveItem = "trophy_fancypants"
	})
	
end )