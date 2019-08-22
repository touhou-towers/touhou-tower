
GtowerAchivements:Add( ACHIVEMENTS.GTOWERADDICTION, {
	Name = "GMod Tower Addiction",
	Description = "Stay in a GMod Tower server for ".. (60*24*7) .." minutes.",
	Value = 60*24*7,
	GiveItem = "trophy_gmodtoweraddiction",
	GMC = 50000
	}
)


if CLIENT then return end

timer.Create( "AchiGtowerAddict", 60.0, 0, function()
	for _, v in pairs( player.GetAll() ) do
		if  v:AchivementLoaded() then
			v:AddAchivement(  ACHIVEMENTS.GTOWERADDICTION, 1 )
		end
	end

end )
