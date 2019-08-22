
hook.Add("LoadAchivements", "LoadBasicAchi", function()

	local AchimentsFolder = TowerModules.ModulesFolder .. "achivement/achivements/"

	local Achivements = {
		'addicted',
		'longwalk',
		'jumping',
		'adminabuse',
		'moon',
		'humanblur',
		'pvpbattle',
		'holiday',
		'ballrace',
		'sourcekarts',
		'minigolf',
		'minigames',
		'virus',
		'milestones',
		'ultimatechimera',
		'zombiemassacre',
	}

	for _, v in pairs( Achivements ) do

		if SERVER then
			AddCSLuaFile( AchimentsFolder .. v .. ".lua" )
		end

		include( AchimentsFolder .. v .. ".lua" )
	end

end )
