
/* ===============================
	DO NOT CHANGE OR REMOVE THE IDS  (Ex.: [1] )
	IT CAN SCREW UP THE SAVING
	JUST CREATE A NEW ID OR SET DISABLED

	MinValue/MaxValue = Set the min/max
	Disabled = Disable the setting from displaying on the admin menu
	AllowReset = Allow to be reseted with the RESET command
	Order = Sorting order for the specific type
  =============================== */

ClientSettings.Items = {
	[1] = {
		Name = "Jetpack",
		Order = "4",
		Var = "JetpackGrav",
		NWType = "Float",
		Default = 0.0,
		MinValue = 0.0,
		MaxValue = 6.0,
		SendType = false, //false=Admins, true=Player+admins
		AllowReset = false,
		Disabled = true,
		SQLSave = false,
	},
	[2] = {
		Name = "Godmode",
		Order = "2",
		Var = "GTGodMode",
		NWType = "Bool",
		Default = false,
		SendType = false, //false=Admins, true=Player+admins
		Disabled = true,
		SQLSave = false
	},
	[3] = {
		Name = "Noclip",
		Order = "3",
		Var = "GTNoClip",
		NWType = "Bool",
		Default = false,
		SendType = false //false=Admins, true=Player+admins
	},
	[4] = {
		Name = "Money",
		Order = "1",
		Var = "GTMoney",
		NWType = "Long",
		Default = 0,
		SQLSave = false,
		SendType = true, //false=Admins, true=Player+admins
		AllowReset = false
	},
	[5] = {
		Name = "Allow Gravity Gun",
		Order = "5",
		Var = "GTAllowGravGun",
		NWType = "Bool",
		Default = false,
		SendType = false //false=Admins, true=Player+admins
	},
	[6] = {
		Name = "Allow Physics Gun",
		Order = "6",
		Var = "GTAllowPhysGun",
		NWType = "Bool",
		Default = false,
		SendType = false //false=Admins, true=Player+admins
	},
	[7] = {
		Name = "Allow Weapons",
		Order = "7",
		Var = "GTAllowWeapons",
		NWType = "Bool",
		Default = false,
		SendType = false //false=Admins, true=Player+admins
	},
	[8] = {
		Name = "Allow Suite", //TODO: make false
		Order = "9",
		Var = "GTAllowSuite",
		NWType = "Bool",
		Default = true,
		SendType = false //false=Admins, true=Player+admins
	},
	[9] = {
		Name = "Allow Inventory Grab Anywhere",
		Order = "11",
		Var = "GTAllowInvAllEnts",
		NWType = "Bool",
		Default = false,
		SendType = false //false=Admins, true=Player+admins
	},
	[10] = {
		Name = "Physgun Grabs Only Inventory Items", //TODO: Make disabled
		Order = "8",
		Var = "GTAllowPhysInventory",
		NWType = "Bool",
		Default = true,
		SendType = true //false=Admins, true=Player+admins
	},
	[11] = {
		Name = "Allow to Edit Trivia",
		Order = "13",
		Var = "GTAllowEditTrivia",
		NWType = "Bool",
		Default = false,
		SendType = false //false=Admins, true=Player+admins
	},
	[12] = {
		Name = "Suite Entity Limit",
		Order = "10",
		Var = "GTSuiteEntityLimit",
		NWType = "Short",
		Default = 145,
		MinValue = 1,
		MaxValue = 160,
		Decimals = 0,
		SendType = true //false=Admins, true=Player+admins
	},
	[13] = {
		Name = "Allow Theater Control",
		Order = "14",
		Var = "GTTeatherControl",
		NWType = "Bool",
		Default = false,
		SendType = true //false=Admins, true=Player+admins
	},
	[14] = {
		Name = "Allow Admin Bank",
		Order = "12",
		Var = "GTInvAdminBank",
		NWType = "Bool",
		Default = false,
		SendType = true //false=Admins, true=Player+admins
	},
	[15] = {
		Name = "Disable Spray",
		Order = "6",
		Var = "GTAllowSpray",
		NWType = "Bool",
		Default = false,
		SendType = false
	},
	[16] = {
		Name = "Theater Access", //TODO: Make false
		Order = "6",
		Var = "GTAllowThater",
		NWType = "Bool",
		Default = true,
		SendType = false
	},
	[17] = {
		Name = "Edit Hats",
		Order = "6",
		Var = "GTAllowEditHat",
		NWType = "Bool",
		Default = false,
		SendType = true
	},
	[18] = {
		Name = "Allow +alltalk",
		Order = "12",
		Var = "GTAllowAllTalk",
		NWType = "Bool",
		Default = false,
		SendType = false //false=Admins, true=Player+admins
	},
	[19] = {
		Name = "Allow portable trunk (INTERNAL)",
		Order = "12",
		Var = "GTAllowPortableTrunk",
		NWType = "Bool",
		Default = false,
		SendType = false //false=Admins, true=Player+admins
	},
	[20] = {
		Name = "Allow voice in suite (INTERNAL)",
		Order = "12",
		Var = "GTAllowVoiceInSuite",
		NWType = "Bool",
		Default = false,
		SendType = false, //false=Admins, true=Player+admins
		Disabled = true,
		SQLSave = false
	},
	[21] = {
		Name = "Allow Emitstream",
		Order = "13",
		Var = "GTAllowEmitStream",
		NWType = "Bool",
		Default = false,
		SendType = false, //false=Admins, true=Player+admins
	},
	[22] = {
		Name = "Allow Emitsound",
		Order = "13",
		Var = "GTAllowEmitSound",
		NWType = "Bool",
		Default = false,
		SendType = false, //false=Admins, true=Player+admins
	},
	[23] = {
		Name = "Allow Self-Ragdolling",
		Order = "12",
		Var = "GTAllowRagdoll",
		NWType = "Bool",
		Default = false,
		SendType = false, //false=Admins, true=Player+admins
	},
	[24] = {
		Name = "Can Start Vote",
		Order = "12",
		Var = "GTAllowVote",
		NWType = "Bool",
		Default = false,
		SendType = false, //false=Admins, true=Player+admins
	},
	[25] = {
		Name = "Unaffected By Shield",
		Order = "12",
		Var = "GTNoShield",
		NWType = "Bool",
		Default = false,
		SendType = false, //false=Admins, true=Player+admins
	},
	[26] = {
		Name = "Can Force Model",
		Order = "12",
		Var = "GTAllowForceModel",
		NWType = "Bool",
		Default = false,
		SendType = false, //false=Admins, true=Player+admins
	},
	[27] = {
		Name = "Open Entity Limit",
		Order = "10",
		Var = "GTOpenEntityLimit",
		NWType = "Short",
		Default = 5,
		MinValue = 0,
		MaxValue = 5,
		Decimals = 0,
		SendType = true,  //false=Admins, true=Player+admins
	},
}
