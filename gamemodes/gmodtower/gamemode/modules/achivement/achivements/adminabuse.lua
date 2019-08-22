

GtowerAchivements:Add( ACHIVEMENTS.ADMINABUSE, {
	Name = "Admin Abuse",
	Description = "Be slapped by an admin twice.", 
	Value = 2
})

if CLIENT then return end

hook.Add("AdminCommand", "AchivementAdminAbuse", function( args, admin, ply )

	if args[1] == "slap" then
		ply:AddAchivement( 	ACHIVEMENTS.ADMINABUSE, 1 )
	end

end )