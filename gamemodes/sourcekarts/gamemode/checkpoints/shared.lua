
-----------------------------------------------------
module( "checkpoints", package.seeall )

NODE_DARK = 1
NODE_RAMP = 2

Dist = 1024
Points = {}
List = {
	["gmt_sk_lifelessraceway01"] = {
		[1] = {
			{ Vector( -222.47, 1186.46, 146.07 ), Angle( -0.29, 90.93, -0.06 ), },
			{ Vector( -154.41, 2263.24, 146.05 ), Angle( 0.36, 57.16, -0.40 ), },
			{ Vector( 1098.20, 3473.48, 145.98 ), Angle( 0.64, 40.52, -0.16 ), },
			{ Vector( 3051.70, 4064.35, 146.07 ), Angle( 0.27, -21.85, -0.16 ), },
			{ Vector( 3855.26, 1511.00, 217.97 ), Angle( 0.57, -82.70, 0.06 ), },
			{ Vector( 5710.20, -320.19, 218.05 ), Angle( 0.54, -20.02, 0.08 ), },
			{ Vector( 9096.51, -914.34, 217.96 ), Angle( 0.63, 5.46, 0.08 ), },
			{ Vector( 10439.70, 587.38, 132.55 ), Angle( 4.01, 89.52, -0.03 ), },
			{ Vector( 11223.13, 3773.39, 48.33 ), Angle( 3.30, -8.08, 6.96 ), },
			{ Vector( 12152.86, 1946.79, 18.07 ), Angle( 0.35, -114.73, -0.08 ), },
			{ Vector( 12059.34, -1269.21, 18.06 ), Angle( 0.53, -66.18, -0.17 ), },
			{ Vector( 12497.77, -4677.87, 18.00 ), Angle( 0.59, -88.95, 0.04 ), },
			{ Vector( 12381.07, -6752.63, 18.06 ), Angle( 0.24, -111.41, -0.19 ), },
			{ Vector( 10707.87, -7364.64, 18.06 ), Angle( 0.25, 172.51, -0.10 ), },
			{ Vector( 9927.33, -5069.98, 17.98 ), Angle( 0.52, 91.50, -0.07 ), },
			{ Vector( 8517.27, -2999.61, 17.97 ), Angle( 0.46, 175.24, -0.00 ), },
			{ Vector( 5106.03, -2985.70, -46.02 ), Angle( 0.65, -179.61, -0.07 ), },
			{ Vector( 2700.15, -3000.99, -46.01 ), Angle( 0.66, -179.66, -0.07 ), },
			{ Vector( 723.40, -2649.65, -13.27 ), Angle( -3.02, 150.38, 0.15 ), },
			{ Vector( -241.13, -875.19, 99.95 ), Angle( -6.08, 87.27, 0.16 ), },
			{ Vector( -238.56, 1156.79, 146.01 ), Angle( 0.75, 89.90, -0.06 ), },
		},
		[2] = {
			{ Vector( -10368.71, 2049.48, 210.06 ), Angle( -0.11, 88.40, -0.06 ), },
			{ Vector( -10358.54, 2853.94, 210.03 ), Angle( 0.47, 91.52, -0.11 ), },
			{ Vector( -10371.60, 3763.58, 209.96 ), Angle( 0.59, 89.60, -0.08 ), },
			{ Vector( -10285.30, 9338.25, 210.02 ), Angle( 0.40, 66.21, -0.26 ), },
			{ Vector( -7537.69, 10388.10, 209.99 ), Angle( 0.50, -1.46, 0.06 ), },
			{ Vector( -5562.85, 9653.35, 210.02 ), Angle( 0.37, -55.79, -0.09 ), },
			{ Vector( -5269.56, 7404.43, 210.04 ), Angle( 0.51, -98.80, -0.12 ), },
			{ Vector( -6328.43, 6203.59, 210.03 ), Angle( 0.56, -161.04, -0.10 ), },
			{ Vector( -11880.55, 6047.64, 380.15 ), Angle( -10.66, 178.81, 0.21 ), },
			{ Vector( -13991.31, 5672.04, 210.03 ), Angle( 0.37, -136.03, -0.02 ), },
			{ Vector( -14457.81, 3329.14, 210.02 ), Angle( 0.64, -89.34, -0.11 ), NODE_DARK },
			{ Vector( -14468.93, 1535.36, -232.85 ), Angle( 15.67, -89.50, 0.12 ), NODE_DARK },
			{ Vector( -13997.09, -68.77, -269.99 ), Angle( 0.41, -40.32, 0.20 ), NODE_DARK },
			{ Vector( -12150.27, -547.39, -270.07 ), Angle( 0.48, 4.06, 0.07 ), NODE_DARK },
			{ Vector( -10591.88, 730.80, -269.94 ), Angle( 0.52, 77.75, 0.02 ), NODE_DARK },
			{ Vector( -10718.58, 3066.30, -269.98 ), Angle( 0.37, 122.24, 0.03 ), NODE_DARK },
			{ Vector( -13534.76, 3195.72, -269.99 ), Angle( 0.62, -124.56, -0.00 ), NODE_DARK },
			{ Vector( -13824.91, 1058.68, -34.05 ), Angle( -14.67, -92.89, 0.75 ), NODE_DARK },
			{ Vector( -13843.49, -691.53, 209.86 ), Angle( 0.60, -86.05, 0.11 ), },
			{ Vector( -12531.66, -2202.06, 210.01 ), Angle( 0.52, -15.63, -0.10 ), },
			{ Vector( -11358.86, -2256.41, 210.05 ), Angle( 0.37, 28.72, 0.35 ), },
			{ Vector( -10401.49, -731.33, 210.02 ), Angle( 0.36, 87.23, -0.03 ), },
			{ Vector( -10368.13, 1979.47, 210.00 ), Angle( 0.67, 89.71, -0.07 ), },
		},
		[3] = {
			{ Vector( 8191.36, 10907.27, -5721.90 ), Angle( 0.63, 89.51, -0.12 ), },
			{ Vector( 8202.14, 11428.26, -5693.07 ), Angle( -3.82, 88.18, -0.09 ), },
			{ Vector( 8228.33, 12140.72, -5524.11 ), Angle( -25.53, 87.90, 0.53 ), },
			{ Vector( 8619.86, 13607.70, -4161.61 ), Angle( -30.32, 43.35, 29.75 ), },
			{ Vector( 10852.18, 13543.40, -4225.82 ), Angle( 43.10, -53.14, 24.83 ), },
			{ Vector( 11223.89, 11809.76, -5636.81 ), Angle( 14.77, -85.72, 0.84 ), },
			{ Vector( 11311.90, 9284.00, -5721.13 ), Angle( 2.21, -83.65, -0.03 ), },
			{ Vector( 12596.49, 7763.59, -5721.77 ), Angle( 2.07, -8.84, 0.15 ), },
			{ Vector( 14368.35, 7208.17, -5698.34 ), Angle( 1.14, -64.38, 5.61 ), },
			{ Vector( 13557.88, 5649.34, -5722.63 ), Angle( 4.51, 176.45, -0.71 ), },
			{ Vector( 11615.43, 5661.04, -5722.10 ), Angle( 2.02, 175.13, -0.37 ), },
			{ Vector( 9709.27, 7343.15, -5721.75 ), Angle( 2.06, 89.29, -0.03 ), },
			{ Vector( 9734.23, 9170.01, -5846.11 ), Angle( 5.49, 89.18, -0.15 ), },
			{ Vector( 9740.44, 11472.73, -5850.06 ), Angle( 2.06, 89.84, -0.15 ), },
			{ Vector( 9593.60, 13674.21, -5849.78 ), Angle( 1.96, 102.93, -0.02 ), NODE_DARK },
			{ Vector( 7371.69, 14840.71, -5849.96 ), Angle( 1.87, -167.72, -0.04 ), NODE_DARK },
			{ Vector( 6209.93, 13430.56, -5849.99 ), Angle( 1.85, -93.02, -0.12 ), NODE_DARK },
			{ Vector( 6153.98, 12281.78, -5850.08 ), Angle( 2.03, -90.49, -0.02 ), NODE_DARK },
			{ Vector( 6144.40, 11191.88, -5820.23 ), Angle( -2.51, -90.39, -0.03 ), },
			{ Vector( 6132.04, 9353.15, -5721.45 ), Angle( 2.22, -90.42, -0.30 ), },
			{ Vector( 7066.84, 7981.27, -5721.64 ), Angle( 2.12, -2.00, 0.26 ), },
			{ Vector( 8195.88, 9012.26, -5722.18 ), Angle( 2.08, 89.71, -0.08 ), },
			{ Vector( 8201.29, 10741.19, -5722.05 ), Angle( 2.07, 89.36, -0.13 ), },
		}
	},

	["gmt_sk_island01_fix"] = {
		[1] = {
			{ Vector( 4796.26, 9765.34, -621.94 ), Angle( -0.04, -1.64, -0.06 ), },
			{ Vector( 5200.96, 9770.88, -622.03 ), Angle( 0.51, 0.56, -0.06 ), },
			{ Vector( 5877.22, 9771.88, -622.05 ), Angle( 0.52, -0.61, -0.08 ), },
			{ Vector( 7490.27, 9154.07, -622.03 ), Angle( 0.49, -31.06, -0.03 ), },
			{ Vector( 8977.17, 8701.13, -621.86 ), Angle( 0.08, -0.69, -0.05 ), },
			{ Vector( 10862.16, 8696.52, -430.13 ), Angle( 0.63, -2.18, -0.02 ), },
			{ Vector( 12524.15, 9202.84, -430.03 ), Angle( 0.60, 86.34, -0.10 ), },
			{ Vector( 10336.03, 10227.24, -263.33 ), Angle( -7.73, 179.50, 0.04 ), },
			{ Vector( 8300.56, 9604.57, -238.04 ), Angle( 0.44, -146.16, -0.05 ), },
			{ Vector( 5883.83, 8714.50, -237.98 ), Angle( 0.40, -110.66, 0.33 ), },
			{ Vector( 11452.19, 7419.72, -813.91 ), Angle( 0.22, 90.13, -0.08 ), },
			{ Vector( 11419.51, 8779.68, -812.29 ), Angle( -0.76, 95.86, -0.49 ), },

			{ Vector( 11299.92, 9435.97, -359.69 ), Angle( -56.84, 120.48, -27.35 ), },
			{ Vector( 11021.66, 9199.08, 649.74 ), Angle( -41.56, -102.20, -172.22 ), },
			{ Vector( 10884.12, 8229.27, 664.45 ), Angle( 31.05, -99.45, 174.96 ), },
			{ Vector( 10617.78, 7948.71, -304.21 ), Angle( 67.20, 125.25, 32.84 ), },
			{ Vector( 10548.84, 8478.51, -782.18 ), Angle( 16.81, 93.60, 1.02 ), },

			{ Vector( 5528.89, 11900.00, -622.01 ), Angle( 0.39, 154.84, -0.14 ), },
			{ Vector( 3449.87, 12785.16, -621.91 ), Angle( 0.44, -172.10, 0.23 ), },
			{ Vector( 2264.66, 10579.63, -621.98 ), Angle( 0.33, -60.02, 0.13 ), },
			{ Vector( 4704.75, 9748.18, -622.00 ), Angle( 0.71, 0.00, -0.05 ), },
		},
		[2] = {
			{ Vector( -4859.44, 7585.43, -621.99 ), Angle( 0.72, 93.47, -0.06 ), },
			{ Vector( -4838.05, 8182.28, -621.99 ), Angle( 0.49, 88.58, -0.13 ), },
			{ Vector( -4986.40, 9131.95, -621.94 ), Angle( 0.32, 114.84, 0.05 ), },
			{ Vector( -6704.40, 10138.92, -622.04 ), Angle( 0.53, 165.94, -0.16 ), },
			{ Vector( -8557.90, 10995.44, -621.99 ), Angle( 0.43, 172.28, -0.06 ), },
			{ Vector( -10069.73, 9844.66, -621.94 ), Angle( 0.40, -83.47, 0.20 ), },
			{ Vector( -9239.42, 7791.30, -621.98 ), Angle( 0.47, -71.22, -0.21 ), },
			{ Vector( -9031.62, 5981.54, -622.11 ), Angle( 0.55, -90.12, -0.06 ), },
			{ Vector( -9015.46, 3822.32, -876.34 ), Angle( 13.30, -89.74, -0.01 ), },
			{ Vector( -8981.34, 1470.05, -1198.24 ), Angle( 0.48, -77.26, 0.11 ), },
			{ Vector( -7854.79, 569.50, -1197.98 ), Angle( 0.34, -7.62, 0.00 ), },
			{ Vector( -6647.26, 2641.48, -1198.03 ), Angle( 0.56, 124.81, 0.36 ), },
			{ Vector( -7512.60, 4920.59, -1198.03 ), Angle( 0.54, 92.74, -0.02 ), },
			{ Vector( -8848.18, 6847.19, -1198.00 ), Angle( 0.32, -172.65, 0.02 ), },
			{ Vector( -10075.13, 4930.43, -1164.67 ), Angle( -5.96, -84.14, -0.54 ), },
			{ Vector( -10078.88, 3107.18, -776.06 ), Angle( -12.14, -91.11, 0.20 ), },
			{ Vector( -9974.69, 1114.17, -622.01 ), Angle( 0.64, -73.02, 0.06 ), },
			{ Vector( -8282.84, -488.10, -622.01 ), Angle( 0.51, -15.97, 0.02 ), },
			{ Vector( -5828.27, 119.91, -621.94 ), Angle( 0.46, 30.55, -0.05 ), },
			{ Vector( -3280.02, 550.94, -622.04 ), Angle( 0.49, -2.31, -0.16 ), },
			{ Vector( -1742.00, 510.45, 314.50 ), Angle( -85.75, 42.61, -42.75 ), },
			{ Vector( -1742.38, 3032.06, 229.51 ), Angle( 80.94, 61.22, -118.67 ), },
			{ Vector( -3575.66, 3201.66, -621.96 ), Angle( 0.41, 146.43, -0.46 ), },
			{ Vector( -4680.90, 5330.00, -622.06 ), Angle( 0.61, 109.20, -0.04 ), },
			{ Vector( -4867.08, 7474.82, -622.00 ), Angle( 0.71, 87.88, -0.07 ), },
		},
		[3] = {
			{ Vector( 4874.64, -6091.08, -1402.01 ), Angle( 1.71, -90.01, -0.12 ), },
			{ Vector( 4879.59, -6955.61, -1401.76 ), Angle( 1.76, -85.55, 0.02 ), },
			{ Vector( 5426.64, -7837.25, -1401.81 ), Angle( 1.94, -31.30, -0.08 ), },
			{ Vector( 7315.74, -7236.53, -1401.91 ), Angle( 1.88, 74.42, -0.10 ), },
			{ Vector( 7416.87, -5947.95, -1341.76 ), Angle( -8.14, 87.71, 0.78 ), },
			{ Vector( 7453.17, -3957.39, -899.85 ), Angle( -10.37, 89.22, 0.07 ), },
			{ Vector( 7438.73, -1280.20, -825.97 ), Angle( 2.27, 89.48, -0.13 ), },
			{ Vector( 7729.97, -248.76, 260.83 ), Angle( -70.56, -45.06, 137.93 ), },
			{ Vector( 8075.85, -1761.76, 352.08 ), Angle( 55.60, -66.91, -159.86 ), },
			{ Vector( 8599.22, -1567.25, -1635.85 ), Angle( 48.11, 79.56, -7.06 ), },
			{ Vector( 8637.68, 404.86, -1738.05 ), Angle( -21.59, 89.42, 0.04 ), },
			{ Vector( 8494.44, 817.04, 165.13 ), Angle( -46.66, 175.55, -86.09 ), },
			{ Vector( 6363.18, 817.81, 713.37 ), Angle( 37.58, 174.82, -94.32 ), },
			{ Vector( 5647.27, 410.19, -1736.15 ), Angle( 35.46, -90.47, -0.48 ), },
			{ Vector( 5676.66, -1378.30, -1764.28 ), Angle( -17.42, -85.29, -2.02 ), },
			{ Vector( 6150.66, -1833.07, 155.46 ), Angle( -75.32, 7.95, -100.19 ), },
			{ Vector( 6584.20, -237.74, 234.12 ), Angle( 60.18, 60.00, 151.59 ), },
			{ Vector( 6898.16, -1589.03, -821.84 ), Angle( 1.98, -92.07, -0.11 ), },
			{ Vector( 6229.64, -4469.50, -825.72 ), Angle( 2.12, -122.08, 0.02 ), },
			{ Vector( 4748.83, -6868.16, -825.91 ), Angle( 2.26, 179.94, -0.39 ), },
			{ Vector( 3291.51, -4638.88, -895.97 ), Angle( 9.94, 90.95, 0.12 ), },
			{ Vector( 3277.30, -1770.08, -1401.07 ), Angle( 1.23, 81.65, -0.36 ), },
			{ Vector( 5524.55, -503.33, -1401.68 ), Angle( 2.06, -1.50, -0.12 ), },
			{ Vector( 9964.42, -971.74, -1402.08 ), Angle( 1.81, -53.38, -0.35 ), },
			{ Vector( 10020.25, -3233.37, -1401.95 ), Angle( 1.88, -131.56, -0.56 ), },
			{ Vector( 7581.58, -3808.95, -1402.10 ), Angle( 2.05, -178.67, -0.13 ), },
			{ Vector( 5224.52, -4260.21, -1401.93 ), Angle( 2.01, -133.53, -0.03 ), },
			{ Vector( 4879.17, -6014.20, -1401.81 ), Angle( 2.12, -93.66, -0.12 ), },
		}
	},

	["gmt_sk_rave"] = {
				[1] = {
					{ Vector( -4607.9921875, 6304.9252929688, 344.03125 ), Angle( 0, 91.848045349121, 0 ), },
					{ Vector( -4606.2153320313, 7083.5815429688, 344.03125 ), Angle( 0, 89.86799621582, 0 ), },
					{ Vector( -4610.9423828125, 8394.3818359375, -996.623046875 ), Angle( 0, 89.538024902344, 0 ), },
					--{ Vector( -4606.5107421875, 9195.84765625, -881.01281738281 ), Angle( 0, 90.7919921875, 0 ), },
					{ Vector( -4600.0034179688, 10301.248046875, -631.96875 ), Angle( 0, 107.88598632813, 0 ), },
					{ Vector( -5131.2924804688, 10875.7109375, -555.98834228516 ), Angle( 0, -153.24588012695, 0 ), },
					{ Vector( -5399.7016601563, 9851.228515625, -403.55523681641 ), Angle( 0, 0.93029451370239, 0 ), },
					{ Vector( -4539.919921875, 9853.5615234375, -369.56945800781 ), Angle( 0, 0.73229432106018, 0 ), },
					{ Vector( -3213.5187988281, 9836.0908203125, -450.41491699219 ), Angle( 0, -38.801742553711, 0 ), },
					{ Vector( -2714.7058105469, 9157.79296875, -456.74731445313 ), Angle( 0, -106.97981262207, -0 ), },
					{ Vector( -3130.1306152344, 8004.68359375, -423.96875 ), Angle( 0, -89.819892883301, -0 ), },
					{ Vector( -3132.9704589844, 7279.123046875, -423.96875 ), Angle( 0, -90.941741943359, -0 ), },
					{ Vector( -3125.7045898438, 5422.5751953125, 600.03125 ), Angle( 0, -111.92980957031, 0 ), },
					{ Vector( -4025.8098144531, 4808.1391601563, 600.03125 ), Angle( 0, -179.2498626709, 0 ), },
					{ Vector( -4983.7670898438, 4854.2309570313, 600.03125 ), Angle( 0, -152.78367614746, 0 ), },
					{ Vector( -5700.6704101563, 4349.080078125, 519.81896972656 ), Angle( 0, -66.851669311523, 0 ), },
					{ Vector( -4821.33984375, 3771.1823730469, 429.32873535156 ), Angle( 0, 66.666389465332, 0 ), },
					{ Vector( -4599.578125, 4803.240234375, 378.74139404297 ), Angle( 0, 89.898422241211, 0 ), },
					{ Vector( -4596.5668945313, 5871.2397460938, 344.03125 ), Angle( 0, 89.898422241211, 0 ), },

	},
	[2] = {
{ Vector( 10502.4375, 8385.7041015625, 264.03125 ), Angle( 0, 89.071365356445, 0 ), },
{ Vector( 10484.465820313, 11131.263671875, 423.98431396484 ), Angle( 0, 125.82479858398, 0 ), },
{ Vector( 8453.560546875, 11833.341796875, 425.17739868164 ), Angle( 0, -130.37428283691, 0 ), },
{ Vector( 8887.337890625, 9257.6220703125, 530.87609863281 ), Angle( 0, -45.580795288086, 0 ), },
{ Vector( 12506.793945313, 7700.3999023438, 472.03125 ), Angle( 0, 88.366004943848, -0 ), },
{ Vector( 10576.627929688, 5890.8173828125, 104.03125 ), Angle( 0, 179.76776123047, 0 ), },
{ Vector( 10505.3359375, 6168.7802734375, 568.03125 ), Angle( 0, 90.9326171875, 0 ), },


		},

		[3] = {
			{ Vector( 4138.8842773438, 8079.658203125, 264.03125 ), Angle( 0, 90.192565917969, 0 ), },
			{ Vector( 4134.806640625, 8792.2529296875, 712.03125 ), Angle( 0, 90.324554443359, 0 ), },
			{ Vector( 5332.107421875, 10634.348632813, 699.53125 ), Angle( 0, 13.764484405518, 0 ), },
			{ Vector( 4648.9057617188, 11784.572265625, 648.03125 ), Angle( 0, 179.7084197998, 0 ), },
			{ Vector( 2808.0207519531, 11785.4453125, 618.03125 ), Angle( 0, 179.97242736816, -0 ), },
			{ Vector( 1542.212890625, 11780.754882813, 728.03125 ), Angle( 0, 179.97242736816, 0 ), },
			{ Vector( 372.48745727539, 11755.19140625, 732.37933349609 ), Angle( 0, 134.23432922363, -0 ), },
			{ Vector( -6.749831199646, 12433.848632813, 745.69384765625 ), Angle( 0, 53.318286895752, -0 ), },
			{ Vector( 668.91052246094, 12755.716796875, 859.19903564453 ), Angle( 0, -42.315761566162, -0 ), },
			{ Vector( 997.98510742188, 11434.986328125, 920.03125 ), Angle( 0, -90.231803894043, -0 ), },
			{ Vector( 993.47833251953, 10312.986328125, 920.03125 ), Angle( 0, -90.231803894043, -0 ), },
			{ Vector( 990.08801269531, 9475.736328125, 837.98767089844 ), Angle( 0, -90.231803894043, 0 ), },
			{ Vector( 993.12542724609, 7318.681640625, 792.03125 ), Angle( 0, -88.713798522949, 0 ), },
			{ Vector( 1517.6782226563, 6547.8764648438, 792.03125 ), Angle( 0, -32.745704650879, 0 ), },
			{ Vector( 2005.4512939453, 5918.8159179688, 792.03125 ), Angle( 0, -89.439682006836, -0 ), },
			{ Vector( 2009.7850341797, 4664.1420898438, 840.03125 ), Angle( 0, -89.439727783203, -0 ), },
			{ Vector( 2646.9116210938, 3849.0185546875, 840.03125 ), Angle( 0, 0.32033890485764, -0 ), },
			{ Vector( 4149.501953125, 4308.8012695313, 792.03125 ), Angle( 0, 90.014350891113, -0 ), },

		}
	}
}

if SERVER then
	util.AddNetworkString( "LoadTrack" )
end

function Load( track )

	Points = {}

	local map = List[ game.GetMap() ]
	if !map then MsgN( "There are no check points for this map!" ) LoadedTrack = 1 return end

	local points = map[ track ]
	if !points then /*MsgN( "There are no check points!" )*/ LoadedTrack = 1 return end

	MsgN( "Loading " .. #points .. " points..." )

	for id, data in ipairs( points ) do
		Points[id] = {
			pos = data[1],
			ang = data[2],
			type = data[3],
			id = id,
		}
	end

	LoadedTrack = track

	if SERVER then
		net.Start( "LoadTrack" )
			net.WriteInt( track, 4 )
		net.Broadcast()
	end

end
Load( 1 )

if CLIENT then
	net.Receive( "LoadTrack", function( len, ply )
		local track = net.ReadInt( 4 )
		Load( track or 1 )
	end )
end

local MaxComplete = 5

function CheckForLap( ply, id )

	local total = #Points
	local totalpass = #ply.PassedPoints

	if ply.Lastpoint == total && id == 1 then

		// Make sure this was a valid race before giving it to them
		if totalpass == total then
			GAMEMODE:Lap( ply )
		end

		return true

	end

	return false

end

function SetPlayerPoint( ply, id, old )

	if ply:Team() == TEAM_FINISHED then return end
	if ply:GetCheckpoint() == id then return end

	local total = #Points

	// Make sure they can't skip a fuck ton
	if !( id == 1 && old == total ) then

		local diff = math.abs( old - id )
		if diff > MaxComplete then
			//print( "PLAYER ATTEMPTING TO CHEAT! ", ply )
			return
		end

	end

	// Set last and new point
	ply.Lastpoint = tonumber( old ) or 0

	if SERVER then

		ply:SetCheckpoint( id )
		//print( "SET CHECKPOINT TO: " .. id )

		// Mark them as actual racers
		if ply:Team() == TEAM_READY then
			if id == 2 && old == 1 then
				GAMEMODE:Ready( ply )
			end
		end

	end

	//MsgN( "Progress: ", ply, " ", id, "/", total )

	// Store progress for lapping
	if !ply.PassedPoints then ply.PassedPoints = {} end

	// Check if the player completed a lap
	local lapped = false
	if SERVER then
		lapped = CheckForLap( ply, id )
	end

	// Clear out when we hit 1 again
	if id == 1 then
		ply.PassedPoints = {}
		ply.PassedPoints[id] = true
	end

	// Forward
	if id >= ply.Lastpoint then

		ply.PassedPoints[id] = true

		if SERVER then
			ply:SetNWBool("Backwards", false)
			ply.BackwardsLast = false
		end

		if id > 1 && !ply.PassedPoints[id-1] then
			ply.PassedPoints[id-1] = true
		end

	// Backwards
	else

		ply.PassedPoints[ply.Lastpoint] = nil

		if !lapped && SERVER then

			if ply.BackwardsLast then
				ply:SetNWBool("Backwards", true)
			end

			ply.BackwardsLast = true

		end

	end

	AutoComplete( ply, id )

end

function AutoComplete( ply, id )

	local diff = math.Clamp( math.abs( ply.Lastpoint - id ), 0, MaxComplete )

	// Auto fill forwards
	if id > ply.Lastpoint then

		for i=1, diff do
			ply.PassedPoints[ply.Lastpoint + i] = true
		end

	// Auto fill backwards
	else

		for i=1, diff do
			ply.PassedPoints[ply.Lastpoint - i] = nil
		end

	end

end

function ClosestPoint( vec )

	local LowestDist = Dist
	local LowestId = nil

	for id, data in pairs( Points ) do

		if !data.pos then continue end

		local Dist = vec:Distance( data.pos )

		if !LowestId || Dist < LowestDist then
			LowestId = id
			LowestDist = Dist
		end

	end

	return LowestId

end

local VZERO = Vector(0,0,0)
function CalculateAlongCheckpoints( kart, checkpointA, checkpointB )

	if not IsValid( kart ) then
		return VZERO, 0
	end

	local n = #Points
	if checkpointA <= 0 then checkpointA = n end
	if checkpointB <= 0 then checkpointB = n end

	if checkpointA > n then checkpointA = 1 end
	if checkpointB > n then checkpointB = 1 end

	local posKart = kart:GetPos()
	local posA = Points[checkpointA]
	local posB = Points[checkpointB]

	if !posA || !posB then
		return VZERO, 0
	end

	posA = posA.pos
	posB = posB.pos

	if !posA || !posB then
		return
	end

	local dx = math.pow(posA.x - posKart.x, 2)
	local dy = math.pow(posA.y - posKart.y, 2)
	local dz = math.pow(posA.z - posKart.z, 2)
	local distSquared = dx + dy + dz

	if distSquared > 1000000 then
		--return VZERO, 2
	end

	local D = (posB - posA)
	local E = (posKart - posA)
	local Dlength = D:Length()

	D.x = D.x / Dlength
	D.y = D.y / Dlength
	D.z = D.z / Dlength

	local dot = D.x * E.x + D.y * E.y + D.z * E.z
	local coefficient = dot / Dlength

	return posA + D * Dlength * coefficient, coefficient

end

function Calculate( ply, kart )

	local pos = kart:GetPos()

	local Closest = ClosestPoint( pos )
	if !Closest then return end

	local pos, coefficient = CalculateAlongCheckpoints( kart, Closest - 1, Closest ) --Along Prev

	if coefficient > 0 and coefficient < 1 then Closest = Closest - 1 end
	if Closest <= 0 then Closest = #Points end

	if not Points[Closest] or not Points[Closest].pos then return end

	local trace = util.TraceLine( {
		start = Points[Closest].pos,
		endpos = kart:GetPos(),
		filter = { ply, kart },
	} )

	if trace.HitWorld then return end

	SetPlayerPoint( ply, Closest, ply:GetCheckpoint() )

end

function CalculateRealPosition( ply, kart )

	local pos, coefficient = CalculateAlongCheckpoints( kart, ply:GetCheckpoint(), ply:GetCheckpoint() + 1 )
	local chk = ( ply:GetCheckpoint() + coefficient - 1 ) / #Points

	local perc = ( chk + ( ply:GetLap() - 1 ) ) / GAMEMODE.MaxLaps

	return perc

end

function CalculatePosition( ply )

	if ply:Team() == TEAM_FINISHED then return end

	local players = team.GetPlayers( TEAM_PLAYING )
	local sortedPlayers = table.Copy( players )

	for _, ply in pairs( sortedPlayers ) do
		ply.RealPosition = CalculateRealPosition( ply, ply:GetKart() )
	end

	table.sort( sortedPlayers, function( a, b )

		// Sort by position
		local apos = a.RealPosition
		local bpos = b.RealPosition

		// Sort by lap
		if a:GetLap() + apos > b:GetLap() + bpos then
			return true
		end

		return false

	end )

	local finished = #team.GetPlayers( TEAM_FINISHED )
	for id, ply2 in ipairs( sortedPlayers ) do

		if ply2 == ply then
			ply:SetPosition( id + finished )
		end

	end

end

if SERVER then
	hook.Add( "Think", "PointThink", function()

		if GAMEMODE:GetState() != STATE_PLAYING then return end

		//if NextPointThink && NextPointThink > CurTime() then return end
		//NextPointThink = CurTime() + .01

		for _, ply in pairs( player.GetAll() ) do

			local kart = ply:GetKart()
			if IsValid( kart ) then
				Calculate( ply, kart )
				CalculatePosition( ply )
			end

		end

	end )
else

	local devcvar2 = false

	hook.Add( "PostDrawTranslucentRenderables", "CheckPointDebug2", function()

		//if true then return end
		--if !DEBUG then return end
		if !devcvar2 then return end

		for id, data in pairs( Points ) do

			local pos = data.pos
			local datatype = ""
			if data.type == checkpoints.NODE_DARK then
				datatype = " DARK"
			end
			if data.type == checkpoints.NODE_RAMP then
				datatype = " BOOST"
			end

			local ang = LocalPlayer():EyeAngles()
			ang:RotateAroundAxis( ang:Forward(), 90 )
			ang:RotateAroundAxis( ang:Right(), 90 )

			cam.Start3D2D( pos + Vector(0,0,20), Angle( 0, ang.y, 90 ), .4 )
				draw.SimpleShadowText( "CHECKPOINT #" .. id .. datatype, "CheckpointFont", 0, 0, Color( 255, 255, 255, 255 ), Color( 0, 0, 0, 255 ) )
			cam.End3D2D()

			// Draw box
			local color = Color( 255, 0, 0 )
			if LocalPlayer().PassedPoints && LocalPlayer().PassedPoints[id] then
				color = Color( 0, 255, 0 )
			end

			Debug3D.DrawSolidBox( pos, data.ang, Vector( -10, -10, -10 ), Vector( 10, 10, 10 ), color )

			/*if !IsValid( data.kart ) then
				data.kart = ClientsideModel( "models/gmod_tower/kart/kart_frame.mdl" )
			end

			data.kart:SetPos( data.pos + ( data.ang:Up() * -( 120 + 16 ) ) )
			data.kart:SetAngles( data.ang )*/

			// Draw radius line
			local kart = LocalPlayer():GetKart()
			if IsValid( kart ) then

				CalculateRealPosition( LocalPlayer(), kart )

				local poskart = kart:GetPos()
				local color = Color( 255, 255, 255 )

				local trace = util.TraceLine( {
					start = data.pos,
					endpos = poskart,
					filter = { ply, kart },
				} )

				if trace.HitWorld then color = Color( 255, 0, 0 ) end

				if poskart:Distance( pos ) < Dist then
					Debug3D.DrawLine( pos, poskart, 10, color )
				end

			end

		end

	end )

	function CheckpointChanged( ply, var, old, new )
		if ply == LocalPlayer() then
			SetPlayerPoint( LocalPlayer(), new, old )
		end
	end

end

concommand.Add( "sk_testpoint", function( ply, cmd, args )
	if !ply:IsAdmin() then return end
	SetPlayerPoint( ply, tonumber( args[1] ) )
end )

concommand.Add( "sk_testlap", function( ply, cmd, args )
	if !ply:IsAdmin() then return end
	for i=1, #Points do
		SetPlayerPoint( ply, i )
	end
end )

RegisterNWTablePlayer({
	{ "Checkpoint", 0, NWTYPE_NUMBER, REPL_EVERYONE, CheckpointChanged },
})
