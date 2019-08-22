
//lua_run_cl Msg( LocalPlayer():GetEyeTrace().HitPos )

module("Location", package.seeall )

local MapPositions = {
	{ 2, Vector( -279, -2796, -119 ), Vector( 1850, -736, 2551 ) }, //Lobby
	{ 43, Vector( 2000, -3200, 2500 ), Vector( -350,  -552, 3460) }, //Lobby roof
	{ 8, Vector( 1852, -1213, 0 ), Vector( 3090, -1730, 384 ) }, //Lobby Teleporter
	{ 44, Vector( -12, 1295, 383 ), Vector( -768, 1935, 192 ) }, //Electorinic Store
	{ 45, Vector( 1863, 1807, 383 ), Vector( 2431, 1392, 192 ) }, //Souvenir Store
	{ 3, Vector( 238, -736, -35 ), Vector( 1600, 2050, 506 ) }, //Plaza
	{ 9, Vector( -548, -1346, 0 ), Vector( -159, -1009, 773 ) }, //Dev HQ.
	//{ 9, Vector( 1787, -874, -64 ), Vector( -1375, -3700, -1140 ) }, //Dev HQ.
	{ 46, Vector( -773, -400, 265 ), Vector( -261, -772, 2598 ) }, //Theater vent
	//{ 31, Vector( 2168, 895, -24 ), Vector( 1600,  256, 168) }, //East store
	{ 31, Vector( 1960, 895, -24 ), Vector( 1600, 256, 168) }, //Appearance Store
	//{ 32, Vector( -1024, 895, 384 ), Vector( 256,  256, -25) }, //West store
	{ 32, Vector( -710, 895, 190 ), Vector( 256,  256, -25) }, //Furniture Store
	{ 10, Vector( 1864, 1280, 168 ), Vector( 3300, 112, 381 ) }, //Casino
	{ 7, Vector( -580, 128, 190 ), Vector( -12, 1060, 381 ) }, //Restaurant
	{ 33, Vector( 5440, -10432, 4090 ), Vector( 6160, -9920, 4480 ) }, //Suite Teleporters
	{ 4, Vector( 5440, -10600, 4096 ), Vector( 4048, -9792, 4480 ) }, //Suite
	{ 49, Vector( 4736, -9792, 4096 ), Vector( 4356, -7855, 4328 ) }, //Party suite
	{ 5, Vector( 4736, -10600, 4096 ), Vector( 4356, -12508, 4328 ) }, //Suites 1-5
	{ 6, Vector( 1800, -10370, 4096 ), Vector( 4048, -9985, 4328 ) }, //Suites 6-10
	{ 34, Vector( 12127, 10386, 6650 ), Vector( 11039, 10879, 7040 ) }, //Gamemode Teleporters
	{ 35, Vector( 9840, 11007, 6650 ), Vector( 11039, 10240, 7103 ) }, //Gamemode Ports
	{ 36, Vector( 9980, 8880, 6650 ), Vector( 11045, 10240, 7103 ) }, //West GM Ports
	{ 37, Vector( 9980, 11007, 6650 ), Vector( 11050, 12355, 7103 ) }, //East GM Ports
	//{ 38, Vector( -200, 1512, 263 ), Vector( -2200, 3047, -650 ) }, //Game area
	{ 38, Vector( -2196, 1508, -679 ), Vector( -796, 3051, 506 ) }, //Arcade
	{ 58, Vector( -796, 2012, -37 ), Vector( -17, 2495, 506 ) }, //Arcade Stairs
	//{ 39, Vector( 1852, 2200, 160 ), Vector( 3431, 2935, -16 ) }, //Bar
	{ 39, Vector( 1864, 2050, -24 ), Vector( 3436, 2935, 506 ) }, //Bar
	//{ 40, Vector( 2688, 3456, 160 ), Vector( 3328, 2935, -16 ) }, //Bar bathroom
	{ 40, Vector( 2688, 3456, -24 ), Vector( 3328, 2935, 506 ) }, //Bar Restrooms
	{ 41, Vector( -2100, 355, -2 ), Vector( -410, -800, 1000 ) }, //Theater
	{ 50, Vector( -6714, -11841,  3200 ), Vector( -11721, -6735, 5800 ) }, //Moon Theater
	{ 42, Vector( -276, -1600, 0 ), Vector( -831, -800, 191 ) }, //Theater hallway
	{ 47, Vector( 1408, -4271, -323 ), Vector( 1867, -3040, 1 ) }, //Train station
	{ 47, Vector( 447, -4271, -323 ), Vector( 28, -3040, 1 ) }, //Train station
	{ 48, Vector( 1408, -2791, -256 ), Vector( 447, -3583, 150 ) }, //Train stairs
	//{ 51, Vector( -3008, -6100, -256 ), Vector( -10000, -13483 , 2024 ) }, //Narnia
	{ 51, Vector( -3008, -6100, -512 ), Vector( -10000, -13483 , 2224 ) }, //Narnia
	{ 59, Vector( -17, 112, 181 ), Vector( 1864, 2495, 506 ) }, //Food Court
	{ 56, Vector( -9267, 4958, -550 ), Vector( -1130, 15381, 3693 ) }, //Pool
	{ 57, Vector( -15419, 4958, -550 ), Vector( -9267, 15381, 3693 ) }, //Lakeside
	{ 32, Vector( 3360, -10816, 4084 ), Vector( 4048, -10370, 4328 ) }, //Suite Furniture Store
	{ 62, Vector( 3360, -9985, 4084 ), Vector( 4048, -9525, 4328 ) }, //Suite Building Store
	{ 74, Vector( 10512.805664, 8900.727539, 6589.746582 ), Vector(9931.981445, 8467.902344, 7096.779297) }, //Minigolf Port
	{ 75, Vector( 9982.151367, 9024.776367, 7164.083984 ), Vector(9623.632813, 9557.327148, 6607.956055) }, //Source Karts Port
	{ 76, Vector( 9982.511719, 9561.395508, 7102.123535 ), Vector(9634.414063, 10105.034180, 6553.928711) }, //PVP Battle Port
	{ 77, Vector( 9983.404297, 11161.226563, 7109.980469 ), Vector(9572.683594, 11678.227539, 6619.046387) }, //Ballrace Port
	{ 78, Vector( 9470.082031, 12297.280273, 7107.578613 ), Vector(9982.288086, 11691.755859, 6618.224609) }, //UCH Port
	{ 79, Vector( 9975.600586, 12352.126953, 6571.575684 ), Vector(10511.842773, 12677.255859, 7167.942871) }, //Gourmet Race Port
	{ 80, Vector( 10523.416992, 12350.396484, 7272.190430 ), Vector(11072.001953, 12686.518555, 6521.653809) }, //Conquest Port
	{ 81, Vector( 11040.503906, 12217.260742, 7181.680176 ), Vector(11327.876953, 11676.507813, 6545.638184) }, //ZM Port
	{ 82, Vector( 11046.933594, 11680.425781, 6587.111816 ), Vector(11429.869141, 11080.302734, 7076.871094) }, //Virus Port
	{ 83, Vector( 11043.552734, 10102.039063, 7082.580566 ), Vector(11373.348633, 9567.859375, 6626.402344) }, //GMT Adventure Port
	{ 84, Vector( 11470.217773, 8991.557617, 6532.794922 ), Vector(11044.097656, 9570.459961, 7147.701660) }, //Monotone Port
	{ 85, Vector( 11049.779297, 8895.711914, 7163.955078 ), Vector(10517.468750, 8567.005859, 6573.260742) } //Construction Port
}


for _, v in pairs( MapPositions ) do
	OrderVectors( v[2], v[3] )
end


function GTowerLocation:DefaultLocation( pos )

	for _, v in ipairs( MapPositions ) do
		if self:InBox( pos, v[2], v[3] ) then
			return v[1]
		end
	end

	return nil

end

function ShowGMTALPHALocations()
	for _, v in ipairs( MapPositions ) do
		DEBUG:Box( v[2], v[3] )
	end
end

function IsTheater(id)
	return ( id == 41 )
end

concommand.Add("gmt_showlocations", function( ply, cmd, args )

	for k, v in ipairs( MapPositions ) do
		Msg( k .. ". " , GTowerLocation:GetName( v[1] ), " (".. v[1] ..")\n" )
		Msg("\t", v[2], "\n" )
		Msg("\t", v[3], "\n" )
	end

	if GetConVarNumber("sv_cheats") != 1 then
		Msg("Sorry, cheats needs to be on to draw boxes")
	end

	ShowGMTALPHALocations()
end )
