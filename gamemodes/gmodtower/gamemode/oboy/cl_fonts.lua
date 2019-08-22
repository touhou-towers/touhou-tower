
// Create GMT fonts
surface.CreateFont( "tiny", { font = "Arial", size = 10, weight = 100 } )
surface.CreateFont( "smalltiny", { font = "Arial", size = 12, weight = 100 } )
surface.CreateFont( "small", { font = "Arial", size = 14, weight = 400 } )
surface.CreateFont( "smalltitle", { font = "Arial", size = 16, weight = 600 } )

local mainFont = "CenterPrintText"
surface.CreateFont( "GTowerhuge", { font = mainFont, size = 45, weight = 100 } )
surface.CreateFont( "GTowerbig", { font = mainFont, size = 28, weight = 125 } )
surface.CreateFont( "GTowerbigbold", { font = mainFont, size = 20, weight = 1200 } )
surface.CreateFont( "GTowerbiglocation", { font = mainFont, size = 28, weight = 125 } )
surface.CreateFont( "GTowermidbold", { font = mainFont, size = 16, weight = 1200 } )
surface.CreateFont( "GTowerbold", { font = mainFont, size = 14, weight = 700 } )

local mainFont2 = "Oswald"
surface.CreateFont( "GTowerHUDHuge", { font = mainFont2, size = 50, weight = 400 } )
surface.CreateFont( "GTowerHUDMainLarge", { font = mainFont2, size = 38, weight = 400 } )
surface.CreateFont( "GTowerHUDMain", { font = mainFont2, size = 24, weight = 400 } )
surface.CreateFont( "GTowerHUDMainMedium", { font = mainFont2, size = 20, weight = 400 } )
surface.CreateFont( "GTowerHUDMainSmall", { font = mainFont2, size = 18, weight = 400 } )
surface.CreateFont( "GTowerHUDMainSmall2", { font = "Clear Sans", size = 18, weight = 800 } )
surface.CreateFont( "GTowerHUDMainTiny", { font = mainFont2, size = 16, weight = 400 } )
surface.CreateFont( "GTowerHUDMainTiny2", { font = "Clear Sans", size = 12, weight = 400 } )
surface.CreateFont( "GTowerNPC", { font = mainFont2, size = 100, weight = 800 } )

surface.CreateFont( "GTowerHudCText", { font = "default", size = 35, weight = 700 } )
surface.CreateFont( "GTowerHudCSubText", { font = "default", size = 18, weight = 700, } )
surface.CreateFont( "GTowerHudCNoticeText", { font = "default", size = 16, weight = 700, } )
surface.CreateFont( "GTowerHudCNewsText", { font = "default", size = 16, weight = 700, } )

surface.CreateFont( "GTowerTabNotice", { font = "Impact", size = 30, weight = 400 } )
surface.CreateFont( "GTowerMinigame", { font = "Impact", size = 24, weight = 400 } )
surface.CreateFont( "GTowerGMTitle", { font = "Impact", size = 24, weight = 400 } )
surface.CreateFont( "GTowerMessage", { font = "Arial", size = 16, weight = 600 } )
surface.CreateFont( "GTowerToolTip", { font = "Tahoma", size = 16, weight = 400 } )


// FONTS
surface.CreateFont( "SCTitle", { font = "TodaySHOP-BoldItalic", size = 64, weight = 400 } )
surface.CreateFont( "SCTNavigation", { font = "Oswald", size = 24, weight = 400 } )

surface.CreateFont( "SCPlyName", { font = "Oswald", size = 32, weight = 400 } )
surface.CreateFont( "SCPlyTeam", { font = "Oswald", size = 22, weight = 400 } )
surface.CreateFont( "SCPlyGroupName", { font = "Oswald", size = 20, weight = 400 } )
surface.CreateFont( "SCPlyGroupLocName", { font = "Oswald", size = 16, weight = 400 } )
surface.CreateFont( "SCPlyValue", { font = "Oswald", size = 24, weight = 400 } )
surface.CreateFont( "SCPlyLabel", { font = "Oswald", size = 18, weight = 400 } )
surface.CreateFont( "SCPlyLoc", { font = "Oswald", size = 18, weight = 400 } )
surface.CreateFont( "SCMapName", { font = "TodaySHOP-Bold", size = 24, weight = 500 } )

surface.CreateFont( "SCAwardCategory", { font = "Oswald", size = 18, weight = 400 } )
surface.CreateFont( "SCAwardTitle", { font = "Oswald", size = 26, weight = 400 } )
surface.CreateFont( "SCAwardDescription", { font = "Arial", size = 14, weight = 400 } )
surface.CreateFont( "SCAwardProgress", { font = "Akfar", size = 12, weight = 400 } )

/*surface.CreateFont( "SCAwardDescription", { font = "Oswald Light", size = 28, weight = 400 } )
surface.CreateFont( "SCAwardProgress", { font = "Oswald Light", size = 24, weight = 400 } )*/


//surface.CreateFont( "GTowerFuel", { font = "Impact", size = 18, weight = 400 } )

// Recreate old fonts
local tblFonts = {

	["DebugFixed"] = {
		font = "Courier New",
		size = 10,
		weight = 500,
		antialias = true,
	},

	["DebugFixedSmall"] = {
		font = "Courier New",
		size = 7,
		weight = 500,
		antialias = true,
	},

	["DefaultFixedOutline"] = {
		font = "Lucida Console",
		size = 10,
		weight = 0,
		outline = true,
	},

	["MenuItem"] = {
		font = "Tahoma",
		size = 12,
		weight = 500,
	},

	["Default"] = {
		font = "Tahoma",
		size = 13,
		weight = 500,
	},

	["TabLarge"] = {
		font = "Tahoma",
		size = 13,
		weight = 700,
		shadow = true,
	},

	["DefaultBold"] = {
		font = "Tahoma",
		size = 13,
		weight = 1000,
	},

	["DefaultUnderline"] = {
		font = "Tahoma",
		size = 13,
		weight = 500,
		underline = true,
	},

	["DefaultSmall"] = {
		font = "Tahoma",
		size = 1,
		weight = 0,
	},

	["DefaultSmallDropShadow"] = {
		font = "Tahoma",
		size = 11,
		weight = 0,
		shadow = true,
	},

	["DefaultVerySmall"] = {
		font = "Tahoma",
		size = 10,
		weight = 0,
	},

	["DefaultLarge"] = {
		font = "Tahoma",
		size = 16,
		weight = 0,
	},

	["UiBold"] = {
		font = "Tahoma",
		size = 12,
		weight = 1000,
	},

	["MenuLarge"] = {
		font = "Verdana",
		size = 15,
		weight = 600,
		antialias = true,
	},

	["ConsoleText"] = {
		font = "Lucida Console",
		size = 10,
		weight = 500,
	},

	["Marlett"] = {
		font = "Marlett",
		size = 13,
		weight = 0,
		symbol = true,
	},

	["Trebuchet24"] = {
		font = "Trebuchet MS",
		size = 24,
		weight = 900,
	},

	["Trebuchet22"] = {
		font = "Trebuchet MS",
		size = 22,
		weight = 900,
	},

	["Trebuchet20"] = {
		font = "Trebuchet MS",
		size = 20,
		weight = 900,
	},

	["Trebuchet19"] = {
		font = "Trebuchet MS",
		size = 19,
		weight = 900,
	},

	["Trebuchet18"] = {
		font = "Trebuchet MS",
		size = 18,
		weight = 900,
	},

	["HUDNumber"] = {
		font = "Trebuchet MS",
		size = 40,
		weight = 900,
	},

	["HUDNumber1"] = {
		font = "Trebuchet MS",
		size = 41,
		weight = 900,
	},

	["HUDNumber2"] = {
		font = "Trebuchet MS",
		size = 42,
		weight = 900,
	},

	["HUDNumber3"] = {
		font = "Trebuchet MS",
		size = 43,
		weight = 900,
	},

	["HUDNumber4"] = {
		font = "Trebuchet MS",
		size = 44,
		weight = 900,
	},

	["HUDNumber5"] = {
		font = "Trebuchet MS",
		size = 45,
		weight = 900,
	},

	["HudHintTextLarge"] = {
		font = "Verdana",
		size = 14,
		weight = 1000,
		antialias = true,
		additive = true,
	},

	["HudHintTextSmall"] = {
		font = "Verdana",
		size = 11,
		weight = 0,
		antialias = true,
		additive = true,
	},

	["CenterPrintText"] = {
		font = "Trebuchet MS",
		size = 18,
		weight = 900,
		antialias = true,
		additive = true,
	},

	["DefaultFixed"] = {
		font = "Lucida Console",
		size = 10,
		weight = 0,
	},

	["DefaultFixedDropShadow"] = {
		font = "Lucida Console",
		size = 10,
		weight = 0,
		shadow = true,
	},

	["CloseCaption_Normal"] = {
		font = "Tahoma",
		size = 16,
		weight = 500,
	},

	["CloseCaption_Italic"] = {
		font = "Tahoma",
		size = 16,
		weight = 500,
		italic = true,
	},

	["CloseCaption_Bold"] = {
		font = "Tahoma",
		size = 16,
		weight = 900,
	},

	["CloseCaption_BoldItalic"] = {
		font = "Tahoma",
		size = 16,
		weight = 900,
		italic = true,
	},

	["TargetID"] = {
		font = "Trebuchet MS",
		size = 22,
		weight = 900,
		antialias = true,
	},

	["TargetIDSmall"] = {
		font = "Trebuchet MS",
		size = 18,
		weight = 900,
		antialias = true,
	},

	["BudgetLabel"] = {
		font = "Courier New",
		size = 14,
		weight = 400,
		outline = true,
	},

	["ScoreboardText"] = {
		font = "Tahoma",
		size = 16,
		weight = 1000,
		antialias = true,
	}
}
 
for k,v in SortedPairs( tblFonts ) do
	surface.CreateFont( k, tblFonts[k] )
end