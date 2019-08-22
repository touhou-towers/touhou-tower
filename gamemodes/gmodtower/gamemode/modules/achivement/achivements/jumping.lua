
GtowerAchivements:Add( ACHIVEMENTS.JUMPINGJACK, {
	Name = "Jumping Jack Rabbit",
	Description = "Jump 200,000 times.",
	Value = 200000,
	GiveItem = "trophy_jackrabbit",
	GMC = 50000
})

if SERVER then
	local TimerCheck = {}

	hook.Add( "KeyPress", "CheckJumpAchivement", function( ply, key )
		if ply:AchivementLoaded() && key == IN_JUMP && ply:OnGround() && ply:Alive() && (!ply.NextJump || CurTime() > ply.NextJump) then
			ply.NextJump = CurTime() + 0.5
			ply:AddAchivement( ACHIVEMENTS.JUMPINGJACK, 1 )
		end
	end )
end
