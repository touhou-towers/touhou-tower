function Putt( ball, vec )
	if !IsValid(ball) then return end
	if vec:IsZero() then return end
	local phys = ball:GetPhysicsObject()
	local ply = ball:GetOwner()
	local oldputts = ply:Swing()
	ball:EnableMotion( true )
	phys:SetVelocity(vec)
end

net.Receive( "MinigolfPutt", function (ln, ply)
	local ball = ply:GetGolfBall()
	local delta = net.ReadVector();
	local target = ball:GetPos() + Vector(0,0,-3)
	local Swing = {}
		
	Swing.midpoint = target + delta / 2
	Swing.delta = delta
	Swing.power = math.Clamp( delta:Length(), 0, MaxPower )
	ply:Putt(ball, Swing.power, (delta*4)*1.325)
end)
