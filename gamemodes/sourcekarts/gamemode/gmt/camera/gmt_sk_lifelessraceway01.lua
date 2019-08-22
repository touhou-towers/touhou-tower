
-----------------------------------------------------
// Track 1
local spline = Catmull.Controller:New()
	spline:Reset()
	spline:AddPointAngle( Vector( 706, -1287, 571 ), Angle( 23, 123, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 465, -1233, 503 ), Angle( 21, 117, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 227, -1140, 440 ), Angle( 19, 106, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 9, -1015, 385 ), Angle( 16, 102, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting11", spline, 2 )

spline = Catmull.Controller:New()
	spline:Reset()
	spline:AddPointAngle( Vector( 10769, 3629, 165 ), Angle( 23, -14, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 11016, 3768, 95 ), Angle( 17, -23, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 11303, 3862, 124 ), Angle( 18, -35, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 11627, 3863, 61 ), Angle( 14, -57, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 11902, 3774, 18 ), Angle( 9, -71, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting12", spline, 4 )

spline = Catmull.Controller:New()
	spline:Reset()
	spline:AddPointAngle( Vector( 7109, -3030, 108 ), Angle( 5, 179, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 6748, -3023, 77 ), Angle( 4, 179, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 6322, -3016, 45 ), Angle( 4, 179, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 5895, -3008, 12 ), Angle( 4, 179, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting13", spline, 4 )


// Track 2
spline = Catmull.Controller:New()
	spline:Reset()
	spline:AddPointAngle( Vector( -10083, -721, 478 ), Angle( 20, 125, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10258, -567, 408 ), Angle( 14, 122, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10399, -338, 351 ), Angle( 9, 120, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10574, -13, 310 ), Angle( 4, 117, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting21", spline, 2 )

spline = Catmull.Controller:New()
	spline:Reset()
	spline:AddPointAngle( Vector( -7971, 5335, 516 ), Angle( 9, 162, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -8280, 5439, 471 ), Angle( 7, 162, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -8559, 5532, 435 ), Angle( 7, 162, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -8834, 5622, 405 ), Angle( 3, 162, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting22", spline, 2 )

spline = Catmull.Controller:New()
	spline:Reset()
	spline:AddPointAngle( Vector( -13957, 5341, 454 ), Angle( 13, -72, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -14156, 4980, 387 ), Angle( 13, -75, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -14341, 4664, 329 ), Angle( 13, -75, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -14478, 4429, 286 ), Angle( 13, -75, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting23", spline, 2 )


// Track 3
spline = Catmull.Controller:New()
spline:Reset()
	spline:AddPointAngle( Vector( 7742, 9519, -5353 ), Angle( 19, 70, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 7833, 9751, -5427 ), Angle( 14, 68, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 7930, 9986, -5484 ), Angle( 11, 67, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 8050, 10269, -5538 ), Angle( 8, 67, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting31", spline, 2 )

spline = Catmull.Controller:New()
spline:Reset()
	spline:AddPointAngle( Vector( 12014, 5584, -5602 ), Angle( 9, 138, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 11704, 5575, -5634 ), Angle( 8, 134, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 11389, 5593, -5661 ), Angle( 6, 128, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 10881, 5684, -5694 ), Angle( 4, 120, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting32", spline, 2 )

spline = Catmull.Controller:New()
spline:Reset()
	spline:AddPointAngle( Vector( 6982, 14807, -5858 ), Angle( 2, -113, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 6684, 14646, -5865 ), Angle( 2, -102, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 6440, 14446, -5868 ), Angle( 0, -88, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 6205, 14179, -5873 ), Angle( 2, -85, 0 ), 1.0 )
	spline:AddPointAngle( Vector( 6095, 13767, -5884 ), Angle( 2, -84, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting33", spline, 2 )


// Waiting for players
spline = Catmull.Controller:New()
spline:Reset()
	spline:AddPointAngle( Vector( -9656, 3677, 296 ), Angle( 3, 109, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -9610, 4348, 244 ), Angle( 4, 95, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -9529, 5376, 449 ), Angle( 12, 64, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -9015, 5579, 577 ), Angle( 27, 77, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -8487, 5608, 577 ), Angle( 21, 111, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -8148, 5988, 526 ), Angle( 19, 129, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -7912, 6493, 504 ), Angle( 12, 172, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -8105, 7326, 611 ), Angle( 16, -152, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -8872, 7489, 507 ), Angle( 16, -150, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -9407, 7246, 380 ), Angle( 11, -132, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -9894, 6925, 293 ), Angle( 6, -141, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10379, 6536, 271 ), Angle( -3, -139, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10737, 6200, 333 ), Angle( -11, -134, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -11055, 5647, 452 ), Angle( -9, -105, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -11130, 4911, 427 ), Angle( 10, -92, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10972, 4563, 355 ), Angle( 13, -91, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10667, 4155, 288 ), Angle( 7, -106, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10436, 3676, 264 ), Angle( 0, -112, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10253, 3158, 288 ), Angle( -8, -121, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10165, 2658, 354 ), Angle( -12, -129, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10310, 2212, 446 ), Angle( -10, -129, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10647, 1753, 478 ), Angle( 5, -123, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10893, 1277, 384 ), Angle( 14, -92, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -11163, 812, 301 ), Angle( 9, -62, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10866, 491, 250 ), Angle( 4, -84, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10585, 45, 222 ), Angle( 4, -116, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10495, -434, 202 ), Angle( 2, -133, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10569, -896, 188 ), Angle( 2, -155, 0 ), 1.0 )
	spline:AddPointAngle( Vector( -10855, -1373, 177 ), Angle( 2, -176, 0 ), 1.0 )
camsystem.AddSplineLocation( "Waiting", spline, 5 )

// Battle
spline = Catmull.Controller:New()
spline:AddPointAngle( Vector( -7569, -6059, 163 ), Angle( 12, -51, 0 ), 1.0 )
spline:AddPointAngle( Vector( -7618, -6531, 95 ), Angle( 12, -49, 0 ), 1.0 )
spline:AddPointAngle( Vector( -7653, -6900, 48 ), Angle( 8, -48, 0 ), 1.0 )
spline:AddPointAngle( Vector( -7319, -7046, 117 ), Angle( 11, -55, 0 ), 1.0 )
spline:AddPointAngle( Vector( -6911, -7183, 333 ), Angle( 23, -72, 0 ), 1.0 )
spline:AddPointAngle( Vector( -6575, -7386, 376 ), Angle( 26, -84, 0 ), 1.0 )
spline:AddPointAngle( Vector( -6077, -7871, 417 ), Angle( 25, -97, 0 ), 1.0 )
spline:AddPointAngle( Vector( -5844, -8177, 411 ), Angle( 25, -106, 0 ), 1.0 )
spline:AddPointAngle( Vector( -5406, -8545, 534 ), Angle( 27, -128, 0 ), 1.0 )
spline:AddPointAngle( Vector( -5163, -8918, 478 ), Angle( 28, -140, 0 ), 1.0 )
spline:AddPointAngle( Vector( -5203, -9412, 317 ), Angle( 25, -152, 0 ), 1.0 )
camsystem.AddSplineLocation( "Battle", spline, 8 )