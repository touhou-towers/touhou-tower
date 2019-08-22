
-----------------------------------------------------
--[[STORED_CURVES = STORED_CURVES or {}
local curve = CreateBezierCurve()

curve:Add(Vector(-4110.53125,-4664.09375,-8420.5625), Angle(0,90,0), 485.96875, 306.0625, nil, nil)
curve:Add(Vector(-4087.6875,-4090.625,-8438.9375), Angle(6.416015625,85.9130859375,-0.263671875), 181.69366765847, 396.74204958165, nil, nil)
curve:Add(Vector(-3534.75,-3733.25,-8475), Angle(1.23046875,0.1318359375,0.0439453125), 93.615977118625, 168.19709478856, nil, nil)
curve:Add(Vector(-2785.71875,-3731.21875,-8629.75), Angle(0,1.5380859375,0), 369.03756001676, 99.098105785694, nil, nil)
curve:Add(Vector(-2323.03125,-3726.21875,-8629.625), Angle(0,-2.4169921875,0), 194.7557220459, 355.44320678711, nil, nil)
curve:Add(Vector(-2374.71875,-4372.8125,-8631.15625), Angle(1.0107421875,179.12109375,0), 517.02056884766, 274.43438720703, nil, nil)
curve:Add(Vector(-3110.21875,-4199.46875,-8732.78125), Angle(4.3505859375,171.650390625,0.3076171875), 273.46383666992, 251.74003601074, nil, nil)
curve:Add(Vector(-3627.15625,-4165.59375,-8749.6875), Angle(0,179.033203125,0), 207.49671025254, 183.93174738286, nil, nil)
curve:Add(Vector(-4033.15625,-3706.03125,-8749.65625), Angle(0,90.87890625,0), 265.56426695399, 378.98450609408, nil, nil)
curve:Add(Vector(-4026.125,-3035.375,-8754.9375), Angle(1.494140625,89.0771484375,0), 176.55225080872, 183.02404960653, nil, nil)
curve:Add(Vector(-3697.34375,-2683.0625,-8798.0625), Angle(5.4052734375,-1.669921875,-1.0107421875), 169.50769997721, 303.84793463641, nil, nil)
curve:Add(Vector(-3307.90625,-3072.96875,-8848.96875), Angle(5.009765625,-88.2861328125,-1.494140625), 132.81286764655, 416.23039321315, nil, nil)
curve:Add(Vector(-4032.125,-3063.5,-8945.96875), Angle(6.0205078125,90.17578125,3.1640625), 450.07336533024, 191.93075584456, nil, nil)
curve:Add(Vector(-4033.84375,-2176.71875,-9074.21875), Angle(0,89.560546875,0), 244.13196234631, 499.98328585345, nil, nil)

STORED_CURVES["waterslide_a"] = curve

-- This point is the exact center between the two slides
-- Only the x value matters
local pivotPos = Vector(-4215.354980, -4547.199707, -8359.968750)
local offsetPos = Vector(0,0,8192.0)

-- We're going to mirror the curve on the x axis
local mirrorCurve = CreateBezierCurve()
for i=1, #curve.Points do

	-- First offset all the points because FUCK GAMEDEV
	curve.Points[i].Pos = curve.Points[i].Pos + offsetPos


	-- Now duplicate it for the other side
	local point = table.Copy(curve.Points[i])
	local offset = pivotPos - point.Pos
	point.Pos = Vector(pivotPos.X + offset.x, point.Pos.y, point.Pos.z)
	point.Angle = Angle(point.Angle.p, 180 - point.Angle.y , point.Angle.r)

	mirrorCurve.Points[i] = point
end

STORED_CURVES["waterslide_b"] = mirrorCurve]]