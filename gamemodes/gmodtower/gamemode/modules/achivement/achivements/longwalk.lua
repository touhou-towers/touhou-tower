

GtowerAchivements:Add( ACHIVEMENTS.WALKTOOLONG, {
	Name = "Long Walk Through GMT",
	Description = "Walk more than 200000 feet.",
	Value = 200000,
	GiveItem = "trophy_longwalk",
	GMC = 20000,
})

if CLIENT then return end

local PlysLastPlace = {}

hook.Add("PlayerThink", "AchiLongWalk", function(ply)

		if ply:AchivementLoaded() && ply:Alive() then
			local PlyIndex = ply:EntIndex()
			local CurPos = ply:GetPos()

			if PlysLastPlace[ PlyIndex ] then

				local Distance = PlysLastPlace[ PlyIndex ]:Distance( CurPos )

				if Distance > 0 && Distance < 150 then

					ply:AddAchivement(  ACHIVEMENTS.WALKTOOLONG, Distance / 16 )

				end

			end

			PlysLastPlace[ PlyIndex ] = CurPos

		end

end )

hook.Add("PlayerDisconnected","ResetLongWalk", function( ply )

	PlysLastPlace[ ply:EntIndex() ] = nil

end )
